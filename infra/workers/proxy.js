/**
 * proxy — fetch relay using raw TCP sockets
 *
 * Uses connect() from cloudflare:sockets instead of fetch() so CF never
 * injects Cf-Worker / Cf-Ray / Cf-Ew-Via into the outbound request.
 * The target sees only a plain Cloudflare edge IP with no CF metadata.
 *
 * Usage:
 *   GET  https://proxy.kzn-sh.workers.dev/?url=<encoded-url>
 *   POST https://proxy.kzn-sh.workers.dev/?url=<encoded-url>
 */

import { connect } from 'cloudflare:sockets';

const BROWSER_HEADERS = [
  ['User-Agent',      'Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0'],
  ['Accept',          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8'],
  ['Accept-Language', 'en-US,en;q=0.5'],
  ['DNT',             '1'],
  ['Upgrade-Insecure-Requests', '1'],
];

// Headers from the caller we forward (only Content-* for POST bodies)
const FORWARD_RE = /^content-/i;

// Headers in the upstream TCP response we suppress before returning
const STRIP_RES = new Set([
  'transfer-encoding', // we reassemble chunks ourselves
]);

export default {
  async fetch(request) {
    const { searchParams } = new URL(request.url);
    const raw = searchParams.get('url');

    if (!raw) {
      return new Response('Usage: ?url=<percent-encoded target URL>\n', {
        status: 400,
        headers: { 'Content-Type': 'text/plain' },
      });
    }

    let target;
    try {
      target = new URL(decodeURIComponent(raw));
    } catch (_) {
      return new Response('Invalid URL', { status: 400 });
    }

    if (!['http:', 'https:'].includes(target.protocol)) {
      return new Response('Only http/https targets allowed', { status: 400 });
    }

    const useTLS = target.protocol === 'https:';
    const port   = target.port ? parseInt(target.port) : (useTLS ? 443 : 80);
    const host   = target.hostname;
    const path   = (target.pathname || '/') + (target.search || '');
    const method = request.method.toUpperCase();

    // ── Build raw HTTP/1.1 request ──────────────────────────────────────
    const headerLines = [`${method} ${path} HTTP/1.1`, `Host: ${host}`];

    for (const [k, v] of BROWSER_HEADERS) {
      headerLines.push(`${k}: ${v}`);
    }

    // Forward safe caller-supplied headers (e.g. Content-Type for POST)
    for (const [k, v] of request.headers) {
      if (FORWARD_RE.test(k)) headerLines.push(`${k}: ${v}`);
    }

    // Disable keep-alive so the server closes after the response
    headerLines.push('Connection: close');

    let bodyBytes = null;
    if (!['GET', 'HEAD'].includes(method)) {
      bodyBytes = new Uint8Array(await request.arrayBuffer());
      if (bodyBytes.length > 0) {
        headerLines.push(`Content-Length: ${bodyBytes.length}`);
      }
    }

    headerLines.push('', ''); // blank line ending headers
    const rawRequest = headerLines.join('\r\n');

    // ── Open raw TCP/TLS socket — no CF headers injected here ───────────
    let socket;
    try {
      socket = connect(`${host}:${port}`, {
        secureTransport: useTLS ? 'on' : 'off',
        allowHalfOpen:   false,
      });
    } catch (err) {
      return new Response(`Connect failed: ${err.message}`, { status: 502 });
    }

    const writer = socket.writable.getWriter();
    const enc = new TextEncoder();
    try {
      await writer.write(enc.encode(rawRequest));
      if (bodyBytes && bodyBytes.length > 0) await writer.write(bodyBytes);
      await writer.close();
    } catch (err) {
      return new Response(`Write failed: ${err.message}`, { status: 502 });
    }

    // ── Read response ────────────────────────────────────────────────────
    const chunks = [];
    const reader = socket.readable.getReader();
    try {
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        chunks.push(value);
      }
    } catch (_) { /* connection closed by server is normal */ }

    // Concatenate all chunks
    const total = chunks.reduce((n, c) => n + c.length, 0);
    const buf   = new Uint8Array(total);
    let   off   = 0;
    for (const c of chunks) { buf.set(c, off); off += c.length; }

    // ── Parse HTTP response headers ──────────────────────────────────────
    const dec  = new TextDecoder();
    const text = dec.decode(buf);
    const sep  = text.indexOf('\r\n\r\n');

    if (sep === -1) {
      return new Response('Malformed HTTP response from upstream', { status: 502 });
    }

    const headerSection = text.slice(0, sep);
    const headerLines2  = headerSection.split('\r\n');
    const statusLine    = headerLines2[0];
    const statusMatch   = statusLine.match(/^HTTP\/\d(?:\.\d)?\s+(\d+)/);
    const status        = statusMatch ? parseInt(statusMatch[1]) : 200;

    const resHeaders = new Headers();
    for (let i = 1; i < headerLines2.length; i++) {
      const colon = headerLines2[i].indexOf(':');
      if (colon === -1) continue;
      const k = headerLines2[i].slice(0, colon).trim().toLowerCase();
      const v = headerLines2[i].slice(colon + 1).trim();
      if (!STRIP_RES.has(k)) resHeaders.append(headerLines2[i].slice(0, colon).trim(), v);
    }

    resHeaders.set('X-Probe-Status', String(status));
    resHeaders.set('X-Probe-URL',    target.toString());

    // Body starts after the double CRLF
    const bodyStart = sep + 4;
    const bodyBuf   = buf.slice(bodyStart);

    // Handle chunked transfer encoding if present
    let finalBody = bodyBuf;
    if ((resHeaders.get('transfer-encoding') || '').includes('chunked')) {
      finalBody = dechunk(bodyBuf);
    }

    return new Response(finalBody, { status, headers: resHeaders });
  },
};

/** Minimal chunked transfer-encoding decoder. */
function dechunk(buf) {
  const out   = [];
  let   i     = 0;
  const dec   = new TextDecoder();
  while (i < buf.length) {
    // Find end of chunk-size line
    let j = i;
    while (j < buf.length - 1 && !(buf[j] === 0x0d && buf[j+1] === 0x0a)) j++;
    const sizeLine = dec.decode(buf.slice(i, j)).split(';')[0].trim();
    const size     = parseInt(sizeLine, 16);
    if (isNaN(size) || size === 0) break;
    i = j + 2; // skip CRLF after size
    out.push(buf.slice(i, i + size));
    i += size + 2; // skip chunk data + trailing CRLF
  }
  const total = out.reduce((n, c) => n + c.length, 0);
  const res   = new Uint8Array(total);
  let   off   = 0;
  for (const c of out) { res.set(c, off); off += c.length; }
  return res;
}
