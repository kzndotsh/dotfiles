/**
 * proxy — fetch relay worker
 *
 * Usage:
 *   GET  https://proxy.<acct>.workers.dev/?url=<encoded-url>
 *   POST https://proxy.<acct>.workers.dev/?url=<encoded-url>
 */

const STRIP_REQ = new Set([
  "host", "cf-connecting-ip", "cf-ipcountry", "cf-ray", "cf-visitor",
  "x-forwarded-for", "x-forwarded-proto", "x-real-ip",
  "origin", "referer",
]);

const STRIP_RES = new Set([
  "cf-ray", "cf-cache-status", "cf-apo-via",
  "nel", "report-to", "server-timing",
]);

const BROWSER_HEADERS = {
  "User-Agent":      "Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0",
  "Accept":          "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
  "Accept-Language": "en-US,en;q=0.5",
  "Accept-Encoding": "gzip, deflate, br",
  "DNT":             "1",
  "Upgrade-Insecure-Requests": "1",
};

async function handleRequest(request) {
  const { searchParams } = new URL(request.url);
  const raw = searchParams.get("url");

  if (!raw) {
    return new Response(
      "Usage: ?url=<percent-encoded target URL>\n",
      { status: 400, headers: { "Content-Type": "text/plain" } }
    );
  }

  let target;
  try {
    target = new URL(decodeURIComponent(raw));
  } catch (_) {
    return new Response("Invalid URL: " + raw, { status: 400 });
  }

  if (!["http:", "https:"].includes(target.protocol)) {
    return new Response("Only http/https targets allowed", { status: 400 });
  }

  const outHeaders = new Headers(BROWSER_HEADERS);
  for (const [k, v] of request.headers) {
    const lk = k.toLowerCase();
    if (!STRIP_REQ.has(lk) && lk.startsWith("content-")) {
      outHeaders.set(k, v);
    }
  }

  const isBodyMethod = !["GET", "HEAD"].includes(request.method.toUpperCase());

  let upstream;
  try {
    upstream = await fetch(target.toString(), {
      method:   request.method,
      headers:  outHeaders,
      body:     isBodyMethod ? request.body : null,
      redirect: "follow",
    });
  } catch (err) {
    return new Response("Fetch failed: " + err.message, { status: 502 });
  }

  const resHeaders = new Headers();
  for (const [k, v] of upstream.headers) {
    if (!STRIP_RES.has(k.toLowerCase())) {
      resHeaders.set(k, v);
    }
  }
  resHeaders.set("X-Probe-Status", String(upstream.status));
  resHeaders.set("X-Probe-URL",    target.toString());

  return new Response(upstream.body, {
    status:  upstream.status,
    headers: resHeaders,
  });
}

addEventListener("fetch", event => {
  event.respondWith(handleRequest(event.request));
});
