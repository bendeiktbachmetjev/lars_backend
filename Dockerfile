# Root-level Dockerfile to deploy backend without monorepo settings
# Builds and runs the FastAPI backend located in ./backend

FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Install Python dependencies for backend
COPY backend/requirements.txt /app/requirements.txt
RUN pip install --upgrade pip && pip install -r /app/requirements.txt

# Copy backend sources into image root (/app)
COPY backend/ /app/

# Expose API port
EXPOSE 8000

# Expected env vars at runtime:
# - DATABASE_URL (postgresql://...)
# - SUPABASE_SSLMODE (optional)

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]


