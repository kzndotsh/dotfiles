FROM python:3.12-slim
RUN pip install --no-cache-dir fastapi uvicorn httpx
WORKDIR /app
COPY server.py .
EXPOSE 8849
CMD ["python", "server.py"]
