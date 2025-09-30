FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

COPY requirements.txt /app/
RUN pip install --upgrade pip && pip install -r requirements.txt

COPY . /app

# Expose port
EXPOSE 8000

# Env vars expected at runtime:
# - DATABASE_URL (postgresql://...)
# - SUPABASE_SSLMODE (optional: require/verify-full)
# - SUPABASE_CA_PATH (optional)

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]


