"""Fish Audio → OpenAI TTS proxy.

Open WebUI / Kokoro-style clients POST /v1/audio/speech (OpenAI Audio API).
Fish's native API is POST https://api.fish.audio/v1/tts with the model in a
header, not the JSON body.

Docs: https://docs.fish.audio/llms.txt
      https://docs.fish.audio/api-reference/endpoint/openapi-v1/text-to-speech
      https://docs.fish.audio/developer-guide/getting-started/quickstart
"""
import os
import httpx
from fastapi import FastAPI, Request
from fastapi.responses import StreamingResponse
import uvicorn

app = FastAPI()
FISH_API_KEY = os.environ["FISH_API_KEY"]
FISH_BASE = "https://api.fish.audio"


@app.post("/v1/audio/speech")
async def speech(request: Request):
    body = await request.json()
    model = body.get("model", "s2.1-pro-free")
    speed = body.get("speed", 1)

    # Field names/defaults match Fish TTSRequest. Official latency default is
    # "normal"; "balanced" is a valid enum (low | normal | balanced).
    payload = {
        "text": body.get("input", ""),
        "reference_id": body.get("voice", "") or None,
        "format": "mp3",
        "mp3_bitrate": 128,
        "sample_rate": 44100,
        "latency": "balanced",
        "temperature": 0.7,
        "top_p": 0.7,
        "chunk_length": 300,
        "min_chunk_length": 50,
        "normalize": True,
        "prosody": {"speed": speed, "volume": 0, "normalize_loudness": True},
        "repetition_penalty": 1.2,
        "max_new_tokens": 1024,
        "condition_on_previous_chunks": True,
        "early_stop_threshold": 1,
    }
    # Remove None reference_id
    if not payload["reference_id"]:
        del payload["reference_id"]

    # Model is a request header (s1 | s2-pro | s2.1-pro | s2.1-pro-free).
    # Unrecognized/omitted falls back to s2.1-pro (paid).
    headers = {
        "Authorization": f"Bearer {FISH_API_KEY}",
        "Content-Type": "application/json",
        "model": model,
    }

    client = httpx.AsyncClient(timeout=60)

    async def stream_audio():
        async with client.stream("POST", f"{FISH_BASE}/v1/tts", json=payload, headers=headers) as r:
            async for chunk in r.aiter_bytes(4096):
                yield chunk
        await client.aclose()

    return StreamingResponse(stream_audio(), media_type="audio/mpeg")


@app.get("/v1/models")
async def models():
    return {"object": "list", "data": [
        {"id": "s2.1-pro-free", "object": "model"},
        {"id": "s2.1-pro", "object": "model"},
        {"id": "s2-pro", "object": "model"},
        {"id": "s1", "object": "model"},
    ]}


@app.get("/health")
async def health():
    return {"status": "ok"}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8849)
