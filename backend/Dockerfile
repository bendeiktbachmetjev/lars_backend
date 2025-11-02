FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

COPY requirements.txt /app/
RUN pip install --upgrade pip && pip install -r requirements.txt

COPY . /app

# Expose port (Railway will set PORT env var)
EXPOSE 8000

# Env vars expected at runtime:
# - PORT (set by Railway, defaults to 8000)
# - DATABASE_URL (postgresql://...)
# - SUPABASE_SSLMODE (optional: require/verify-full)
# - SUPABASE_CA_PATH (optional)

# Use startup script that reads PORT from environment
# Use python3 explicitly to ensure compatibility
CMD ["python3", "startup.py"]


