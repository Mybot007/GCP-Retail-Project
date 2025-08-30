# infra/docker/bronze/Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY apps/bronze/python/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY apps/bronze/python/ .
ENV PYTHONUNBUFFERED=1
# entrypoint calls your script
CMD ["python","bronze_ingest_api.py"]
