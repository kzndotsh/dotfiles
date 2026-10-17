# /// script
# requires-python = ">=3.12"
# dependencies = ["fastapi", "uvicorn", "httpx"]
# ///
"""CORS pass-through for an OpenAI-compatible API (for browser RisuAI).

Experiential Labs sends no Access-Control-Allow-Origin, so a browser blocks it.
This forwards every request to UPSTREAM, streams the reply back, and adds CORS.
The client's own Authorization header is forwarded; no key is stored here.

  uv run packages/llm-cors-proxy/server.py
  RisuAI URL: http://127.0.0.1:8850/v1   key: your xpl_... key
"""
from __future__ import annotations

import json
import logging
import os
import time

import httpx
import uvicorn
from fastapi import FastAPI, Request
from fastapi.responses import Response, StreamingResponse
from starlette.background import BackgroundTask

UPSTREAM = os.environ.get("LLM_UPSTREAM", "https://api.experientiallabs.ai").rstrip("/")
HOST = os.environ.get("LLM_PROXY_HOST", "127.0.0.1")
PORT = int(os.environ.get("LLM_PROXY_PORT", "8850"))
# Forced into every chat-completions body (this model route only takes low|high|max
# and spends the whole token budget thinking otherwise). Empty string disables it.
REASONING_EFFORT = os.environ.get("LLM_REASONING_EFFORT", "low")
# LLM_PROXY_DUMP=/some/dir saves each chat request body and the start of its reply there
# (full chat text, so keep it local and out of git).
DUMP = os.environ.get("LLM_PROXY_DUMP", "")
# LLM_PROXY_DEBUG=1 also logs the request's field names (never values or keys).
DEBUG = os.environ.get("LLM_PROXY_DEBUG", "").lower() in {"1", "true", "yes", "on"}

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(message)s", datefmt="%H:%M:%S")
log = logging.getLogger("llm-cors-proxy")

CORS = {
    "access-control-allow-origin": "*",
    "access-control-allow-methods": "GET, POST, OPTIONS",
    "access-control-allow-headers": "*",
    "access-control-max-age": "600",
}
# Hop-by-hop or length/encoding headers must not be copied through.
DROP_REQ = {"host", "content-length", "origin", "referer", "connection", "accept-encoding"}
DROP_RESP = {"content-length", "content-encoding", "transfer-encoding", "connection"}

app = FastAPI()
client = httpx.AsyncClient(timeout=httpx.Timeout(300.0, connect=15.0))


@app.api_route("/{path:path}", methods=["GET", "POST", "OPTIONS"])
async def forward(path: str, request: Request) -> Response:
    if request.method == "OPTIONS":
        return Response(status_code=204, headers=CORS)
    t0 = time.monotonic()
    body = await request.body()
    if REASONING_EFFORT and request.method == "POST" and path.endswith("chat/completions"):
        try:
            data = json.loads(body)
        except ValueError:
            data = None
        if isinstance(data, dict):
            data["reasoning_effort"] = REASONING_EFFORT
            body = json.dumps(data).encode()
    stamp = time.strftime("%H%M%S")
    if DUMP and request.method == "POST":
        os.makedirs(DUMP, exist_ok=True)
        with open(os.path.join(DUMP, f"{stamp}.request.json"), "wb") as f:
            f.write(body)
    if DEBUG and body:
        try:
            fields = sorted(json.loads(body))
        except (ValueError, TypeError):
            fields = ["<not json>"]
        log.info("  request fields: %s", ", ".join(map(str, fields)))
    headers = {k: v for k, v in request.headers.items() if k.lower() not in DROP_REQ}
    upstream = await client.send(
        client.build_request(
            request.method,
            f"{UPSTREAM}/{path}",
            params=request.query_params,
            headers=headers,
            content=body,
        ),
        stream=True,
    )
    rid = upstream.headers.get("x-request-id", "-")
    log.info(
        "%s /%s -> %s in %.2fs request=%s", request.method, path, upstream.status_code,
        time.monotonic() - t0, rid,
    )
    if upstream.status_code >= 400:
        # Error bodies are small JSON and name the offending field; show them.
        err = await upstream.aread()
        log.warning("  upstream error body: %s", err.decode("utf-8", "replace")[:600])
        if DUMP:
            with open(os.path.join(DUMP, f"{stamp}.error.txt"), "wb") as f:
                f.write(err)
        out = {k: v for k, v in upstream.headers.items() if k.lower() not in DROP_RESP}
        await upstream.aclose()
        return Response(err, status_code=upstream.status_code, headers={**out, **CORS})
    out = {k: v for k, v in upstream.headers.items() if k.lower() not in DROP_RESP}
    async def relay():
        first, total, head = None, 0, b""
        try:
            async for chunk in upstream.aiter_bytes():
                if first is None:
                    first = time.monotonic() - t0
                total += len(chunk)
                if DUMP and len(head) < 20000:
                    head += chunk
                yield chunk
        finally:
            if DUMP and path.endswith("chat/completions"):
                os.makedirs(DUMP, exist_ok=True)
                with open(os.path.join(DUMP, f"{stamp}.response.txt"), "wb") as f:
                    f.write(head)
            log.info(
                "  stream done: first chunk %s, total %.2fs, %d bytes request=%s",
                "-" if first is None else f"{first:.2f}s", time.monotonic() - t0, total, rid,
            )

    return StreamingResponse(
        relay(),
        status_code=upstream.status_code,
        headers={**out, **CORS},
        background=BackgroundTask(upstream.aclose),
    )


if __name__ == "__main__":
    uvicorn.run(app, host=HOST, port=PORT, log_level="warning")
