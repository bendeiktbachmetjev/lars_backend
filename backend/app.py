import os
import json
import traceback
from typing import Optional
from urllib.parse import urlsplit, urlunsplit, parse_qsl, urlencode
import pathlib

from fastapi import FastAPI, Header, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncEngine, create_async_engine, AsyncSession
from sqlalchemy import text
from sqlalchemy.orm import sessionmaker


class WeeklyPayload(BaseModel):
    # Raw indices as in the Flutter UI
    flatus_control: int
    liquid_stool_leakage: int
    bowel_frequency: int
    repeat_bowel_opening: int
    urgency_to_toilet: int
    entry_date: Optional[str] = None  # YYYY-MM-DD, optional; defaults to today on server
    raw_data: Optional[dict] = None

class DailyPayload(BaseModel):
    entry_date: Optional[str] = None
    bristol_scale: Optional[int] = None
    food_consumption: Optional[dict] = None
    drink_consumption: Optional[dict] = None
    raw_data: Optional[dict] = None

class MonthlyPayload(BaseModel):
    entry_date: Optional[str] = None
    qol_score: Optional[int] = None
    raw_data: Optional[dict] = None

class Eq5d5lPayload(BaseModel):
    mobility: int
    self_care: int
    usual_activities: int
    pain_discomfort: int
    anxiety_depression: int
    entry_date: Optional[str] = None
    raw_data: Optional[dict] = None


def _build_async_url(sync_url: str) -> str:
    # Convert postgres/postgresql scheme to asyncpg async dialect for SQLAlchemy
    # Use asyncpg as it's more efficient for async operations
    if not sync_url:
        return sync_url
    parts = urlsplit(sync_url)
    scheme = parts.scheme
    
    # Remove any existing driver prefix (postgresql+psycopg, postgresql+asyncpg, etc.)
    if "+" in scheme:
        base_scheme = scheme.split("+")[0]
    else:
        base_scheme = scheme
    
    if base_scheme.startswith("postgres"):
        # Rebuild query: enforce sslmode=require, drop driver-specific leftovers
        query_pairs = dict(parse_qsl(parts.query, keep_blank_values=True))
        query_pairs.pop("options", None)
        # Don't force sslmode for Railway - let it use what's in the URL
        # Some providers already have sslmode configured
        if "sslmode" not in query_pairs:
            query_pairs["sslmode"] = "require"
        new_query = urlencode(query_pairs)
        # Use asyncpg driver for async operations
        new_scheme = "postgresql+asyncpg"
        new_parts = (new_scheme, parts.netloc, parts.path, new_query, parts.fragment)
        return urlunsplit(new_parts)
    return sync_url


DATABASE_URL = os.getenv("DATABASE_URL", "")
if not DATABASE_URL:
    raise RuntimeError("DATABASE_URL env var is required")

ASYNC_DATABASE_URL = _build_async_url(DATABASE_URL)

def _ssl_hint() -> str:
    ca_path_env = os.getenv("SUPABASE_CA_PATH") or str((pathlib.Path(__file__).resolve().parent / "certs" / "supabase-ca.pem"))
    return (
        "If TLS fails: download Supabase CA (Database → Settings → SSL → Download certificate) "
        f"and set sslrootcert in DATABASE_URL or SUPABASE_CA_PATH at {ca_path_env}."
    )

engine: AsyncEngine = create_async_engine(
    ASYNC_DATABASE_URL,
    pool_pre_ping=True,
    connect_args={
        # psycopg3: disable server-side prepares to work with PgBouncer transaction/statement mode
        "prepare_threshold": 0,
    },
)
async_session = sessionmaker(bind=engine, expire_on_commit=False, class_=AsyncSession)

app = FastAPI(title="LARS Backend")


@app.get("/healthz")
async def healthz():
    # Always return 200 for Railway healthcheck, but include DB status
    db_status = "ok"
    db_error = None
    db_error_type = None
    
    try:
        # Check if DATABASE_URL is set
        if not DATABASE_URL:
            db_status = "error"
            db_error = "DATABASE_URL environment variable is not set"
            db_error_type = "config_error"
        else:
            # Try to connect and execute a simple query
            async with engine.connect() as conn:
                await conn.execute(text("SELECT 1"))
            db_status = "ok"
    except Exception as e:
        db_status = "error"
        db_error = str(e)
        db_error_type = type(e).__name__
        # Full error trace available for logging (not exposed in response for security)
    
    # Return 200 so Railway doesn't fail deployment, but indicate DB status
    response = {
        "status": "ok",
        "app": "running",
        "database": db_status,
    }
    
    if db_error:
        response["error"] = db_error
        response["error_type"] = db_error_type
    
    return response


@app.post("/sendWeekly")
async def send_weekly(payload: WeeklyPayload, x_patient_code: Optional[str] = Header(None)):
    if not x_patient_code:
        raise HTTPException(status_code=400, detail="Missing X-Patient-Code header")

    patient_code = x_patient_code.strip().upper()
    if not patient_code or len(patient_code) < 4 or len(patient_code) > 64:
        raise HTTPException(status_code=400, detail="Invalid patient code format")

    try:
        async with async_session() as session:
            async with session.begin():
                # Upsert patient by code
                res = await session.execute(
                    text("""
                        INSERT INTO patients (patient_code)
                        VALUES (:code)
                        ON CONFLICT (patient_code) DO UPDATE SET patient_code = EXCLUDED.patient_code
                        RETURNING id
                    """).bindparams(code=patient_code)
                )
                row = res.first()
                patient_id = row[0]

                # Insert weekly entry
                res2 = await session.execute(
                    text("""
                        INSERT INTO weekly_entries (
                            patient_id, entry_date,
                            flatus_control, liquid_stool_leakage, bowel_frequency,
                            repeat_bowel_opening, urgency_to_toilet, raw_data
                        ) VALUES (
                            :patient_id,
                            COALESCE(CAST(:entry_date AS DATE), CURRENT_DATE),
                            :flatus_control, :liquid_stool_leakage, :bowel_frequency,
                            :repeat_bowel_opening, :urgency_to_toilet,
                            COALESCE(CAST(:raw_data AS JSONB), '{}'::jsonb)
                        )
                        ON CONFLICT (patient_id, entry_date) DO UPDATE SET
                            flatus_control = EXCLUDED.flatus_control,
                            liquid_stool_leakage = EXCLUDED.liquid_stool_leakage,
                            bowel_frequency = EXCLUDED.bowel_frequency,
                            repeat_bowel_opening = EXCLUDED.repeat_bowel_opening,
                            urgency_to_toilet = EXCLUDED.urgency_to_toilet,
                            raw_data = EXCLUDED.raw_data
                        RETURNING id
                    """)
                    .bindparams(
                        patient_id=patient_id,
                        entry_date=payload.entry_date,
                        flatus_control=payload.flatus_control,
                        liquid_stool_leakage=payload.liquid_stool_leakage,
                        bowel_frequency=payload.bowel_frequency,
                        repeat_bowel_opening=payload.repeat_bowel_opening,
                        urgency_to_toilet=payload.urgency_to_toilet,
                        raw_data=json.dumps(payload.raw_data or {}),
                    )
                )
                inserted = res2.first()
        return {"status": "ok", "id": str(inserted[0])}
    except Exception as e:
        return JSONResponse(status_code=500, content={"status": "error", "detail": repr(e)})


@app.post("/sendDaily")
async def send_daily(payload: DailyPayload, x_patient_code: Optional[str] = Header(None)):
    if not x_patient_code:
        raise HTTPException(status_code=400, detail="Missing X-Patient-Code header")
    patient_code = x_patient_code.strip().upper()
    if not patient_code or len(patient_code) < 4 or len(patient_code) > 64:
        raise HTTPException(status_code=400, detail="Invalid patient code format")

    try:
        async with async_session() as session:
            async with session.begin():
                res = await session.execute(
                    text("""
                        INSERT INTO patients (patient_code)
                        VALUES (:code)
                        ON CONFLICT (patient_code) DO UPDATE SET patient_code = EXCLUDED.patient_code
                        RETURNING id
                    """).bindparams(code=patient_code)
                )
                patient_id = res.first()[0]

                res2 = await session.execute(
                    text("""
                        INSERT INTO daily_entries (
                            patient_id, entry_date, bristol_scale,
                            food_consumption, drink_consumption, raw_data
                        ) VALUES (
                            :patient_id,
                            COALESCE(CAST(:entry_date AS DATE), CURRENT_DATE),
                            :bristol_scale,
                            COALESCE(CAST(:food_consumption AS JSONB), '{}'::jsonb),
                            COALESCE(CAST(:drink_consumption AS JSONB), '{}'::jsonb),
                            COALESCE(CAST(:raw_data AS JSONB), '{}'::jsonb)
                        )
                        ON CONFLICT (patient_id, entry_date) DO UPDATE SET
                            bristol_scale = EXCLUDED.bristol_scale,
                            food_consumption = EXCLUDED.food_consumption,
                            drink_consumption = EXCLUDED.drink_consumption,
                            raw_data = EXCLUDED.raw_data
                        RETURNING id
                    """)
                    .bindparams(
                        patient_id=patient_id,
                        entry_date=payload.entry_date,
                        bristol_scale=payload.bristol_scale,
                        food_consumption=json.dumps(payload.food_consumption or {}),
                        drink_consumption=json.dumps(payload.drink_consumption or {}),
                        raw_data=json.dumps(payload.raw_data or {}),
                    )
                )
                row2 = res2.first()
        return {"status": "ok", "id": str(row2[0])}
    except Exception as e:
        return JSONResponse(status_code=500, content={"status": "error", "detail": repr(e)})


@app.post("/sendMonthly")
async def send_monthly(payload: MonthlyPayload, x_patient_code: Optional[str] = Header(None)):
    if not x_patient_code:
        raise HTTPException(status_code=400, detail="Missing X-Patient-Code header")
    patient_code = x_patient_code.strip().upper()
    if not patient_code or len(patient_code) < 4 or len(patient_code) > 64:
        raise HTTPException(status_code=400, detail="Invalid patient code format")

    try:
        async with async_session() as session:
            async with session.begin():
                res = await session.execute(
                    text("""
                        INSERT INTO patients (patient_code)
                        VALUES (:code)
                        ON CONFLICT (patient_code) DO UPDATE SET patient_code = EXCLUDED.patient_code
                        RETURNING id
                    """).bindparams(code=patient_code)
                )
                patient_id = res.first()[0]

                res2 = await session.execute(
                    text("""
                        INSERT INTO monthly_entries (
                            patient_id, entry_date, qol_score, raw_data
                        ) VALUES (
                            :patient_id,
                            COALESCE(CAST(:entry_date AS DATE), CURRENT_DATE),
                            :qol_score,
                            COALESCE(CAST(:raw_data AS JSONB), '{}'::jsonb)
                        )
                        ON CONFLICT (patient_id, entry_date) DO UPDATE SET
                            qol_score = EXCLUDED.qol_score,
                            raw_data = EXCLUDED.raw_data
                        RETURNING id
                    """)
                    .bindparams(
                        patient_id=patient_id,
                        entry_date=payload.entry_date,
                        qol_score=payload.qol_score,
                        raw_data=json.dumps(payload.raw_data or {}),
                    )
                )
                row2 = res2.first()
        return {"status": "ok", "id": str(row2[0])}
    except Exception as e:
        return JSONResponse(status_code=500, content={"status": "error", "detail": repr(e)})


@app.post("/sendEq5d5l")
async def send_eq5d5l(payload: Eq5d5lPayload, x_patient_code: Optional[str] = Header(None)):
    if not x_patient_code:
        raise HTTPException(status_code=400, detail="Missing X-Patient-Code header")
    patient_code = x_patient_code.strip().upper()
    if not patient_code or len(patient_code) < 4 or len(patient_code) > 64:
        raise HTTPException(status_code=400, detail="Invalid patient code format")

    try:
        async with async_session() as session:
            async with session.begin():
                res = await session.execute(
                    text("""
                        INSERT INTO patients (patient_code)
                        VALUES (:code)
                        ON CONFLICT (patient_code) DO UPDATE SET patient_code = EXCLUDED.patient_code
                        RETURNING id
                    """).bindparams(code=patient_code)
                )
                patient_id = res.first()[0]

                res2 = await session.execute(
                    text("""
                        INSERT INTO eq5d5l_entries (
                            patient_id, entry_date,
                            mobility, self_care, usual_activities,
                            pain_discomfort, anxiety_depression, raw_data
                        ) VALUES (
                            :patient_id,
                            COALESCE(CAST(:entry_date AS DATE), CURRENT_DATE),
                            :mobility, :self_care, :usual_activities,
                            :pain_discomfort, :anxiety_depression,
                            COALESCE(CAST(:raw_data AS JSONB), '{}'::jsonb)
                        )
                        ON CONFLICT (patient_id, entry_date) DO UPDATE SET
                            mobility = EXCLUDED.mobility,
                            self_care = EXCLUDED.self_care,
                            usual_activities = EXCLUDED.usual_activities,
                            pain_discomfort = EXCLUDED.pain_discomfort,
                            anxiety_depression = EXCLUDED.anxiety_depression,
                            raw_data = EXCLUDED.raw_data
                        RETURNING id
                    """)
                    .bindparams(
                        patient_id=patient_id,
                        entry_date=payload.entry_date,
                        mobility=payload.mobility,
                        self_care=payload.self_care,
                        usual_activities=payload.usual_activities,
                        pain_discomfort=payload.pain_discomfort,
                        anxiety_depression=payload.anxiety_depression,
                        raw_data=json.dumps(payload.raw_data or {}),
                    )
                )
                row2 = res2.first()
        return {"status": "ok", "id": str(row2[0])}
    except Exception as e:
        return JSONResponse(status_code=500, content={"status": "error", "detail": repr(e)})


