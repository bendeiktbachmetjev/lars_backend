import os
from typing import Optional
from urllib.parse import urlsplit, urlunsplit, parse_qsl, urlencode
import pathlib

from fastapi import FastAPI, Header, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncEngine, create_async_engine, AsyncSession
from sqlalchemy import text
from sqlalchemy.orm import sessionmaker
import json


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


def _build_async_url(sync_url: str) -> str:
    # Convert postgres/postgresql scheme to psycopg3 async dialect and ensure sslmode=require
    if not sync_url:
        return sync_url
    parts = urlsplit(sync_url)
    scheme = parts.scheme
    if scheme.startswith("postgres"):
        # Rebuild query: enforce sslmode=require, drop driver-specific leftovers
        query_pairs = dict(parse_qsl(parts.query, keep_blank_values=True))
        query_pairs.pop("options", None)
        query_pairs.setdefault("sslmode", "require")
        new_query = urlencode(query_pairs)
        # swap scheme to psycopg3 driver
        new_scheme = "postgresql+psycopg"
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
    try:
        async with engine.connect() as conn:
            await conn.execute(text("SELECT 1"))
        return {"status": "ok"}
    except Exception as e:
        # Expose error details for local debugging
        return JSONResponse(status_code=500, content={"status": "error", "detail": repr(e), "hint": _ssl_hint()})


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


