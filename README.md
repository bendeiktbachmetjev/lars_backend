# LARS Backend (FastAPI)

Minimal FastAPI backend for LARS app with PostgreSQL (Supabase) storage.

## Run locally
```
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
export DATABASE_URL="postgresql://postgres.<project_ref>:<PASSWORD>@aws-1-<region>.pooler.supabase.com:6543/postgres?sslmode=require"
uvicorn app:app --host 0.0.0.0 --port 8000 --reload
```
Check: `GET /healthz`

## Deploy to Railway (from GitHub)
1. Create an empty GitHub repo (e.g. `lars_backend`)
2. Push this folder as the repo root
3. In Railway: New Project → Deploy from GitHub → select repo
4. Variables:
   - `DATABASE_URL` = Supabase pooler URI with `sslmode=require`
   - (optional) `SUPABASE_SSLMODE=require`
5. Health check: `/healthz`

## API
- `POST /sendWeekly`
- `POST /sendDaily`
- `POST /sendMonthly`
- `GET /healthz`


