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
    # Liveness-only; do not depend on DB for platform healthcheck
    return {"status": "ok"}


@app.get("/readyz")
async def readyz():
    try:
        async with engine.connect() as conn:
            await conn.execute(text("SELECT 1"))
        return {"status": "ok"}
    except Exception as e:
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
                            stool_count, pads_used, urgency, night_stools,
                            leakage, incomplete_evac, bloating, impact_score, activity_interfere,
                            food_vegetables_all, food_root_vegetables, food_whole_grains, food_whole_grain_bread,
                            food_nuts_and_seeds, food_legumes, food_fruits_with_skin, food_berries,
                            food_soft_fruits_no_skin, food_muesli_and_bran,
                            drink_water, drink_coffee, drink_tea, drink_alcohol,
                            drink_carbonated, drink_juices, drink_dairy, drink_energy
                        ) VALUES (
                            :patient_id,
                            COALESCE(CAST(:entry_date AS DATE), CURRENT_DATE),
                            :bristol_scale,
                            :stool_count, :pads_used, :urgency, :night_stools,
                            :leakage, :incomplete_evac, :bloating, :impact_score, :activity_interfere,
                            :food_vegetables_all, :food_root_vegetables, :food_whole_grains, :food_whole_grain_bread,
                            :food_nuts_and_seeds, :food_legumes, :food_fruits_with_skin, :food_berries,
                            :food_soft_fruits_no_skin, :food_muesli_and_bran,
                            :drink_water, :drink_coffee, :drink_tea, :drink_alcohol,
                            :drink_carbonated, :drink_juices, :drink_dairy, :drink_energy
                        )
                        ON CONFLICT (patient_id, entry_date) DO UPDATE SET
                            bristol_scale = EXCLUDED.bristol_scale,
                            stool_count = EXCLUDED.stool_count,
                            pads_used = EXCLUDED.pads_used,
                            urgency = EXCLUDED.urgency,
                            night_stools = EXCLUDED.night_stools,
                            leakage = EXCLUDED.leakage,
                            incomplete_evac = EXCLUDED.incomplete_evac,
                            bloating = EXCLUDED.bloating,
                            impact_score = EXCLUDED.impact_score,
                            activity_interfere = EXCLUDED.activity_interfere,
                            food_vegetables_all = EXCLUDED.food_vegetables_all,
                            food_root_vegetables = EXCLUDED.food_root_vegetables,
                            food_whole_grains = EXCLUDED.food_whole_grains,
                            food_whole_grain_bread = EXCLUDED.food_whole_grain_bread,
                            food_nuts_and_seeds = EXCLUDED.food_nuts_and_seeds,
                            food_legumes = EXCLUDED.food_legumes,
                            food_fruits_with_skin = EXCLUDED.food_fruits_with_skin,
                            food_berries = EXCLUDED.food_berries,
                            food_soft_fruits_no_skin = EXCLUDED.food_soft_fruits_no_skin,
                            food_muesli_and_bran = EXCLUDED.food_muesli_and_bran,
                            drink_water = EXCLUDED.drink_water,
                            drink_coffee = EXCLUDED.drink_coffee,
                            drink_tea = EXCLUDED.drink_tea,
                            drink_alcohol = EXCLUDED.drink_alcohol,
                            drink_carbonated = EXCLUDED.drink_carbonated,
                            drink_juices = EXCLUDED.drink_juices,
                            drink_dairy = EXCLUDED.drink_dairy,
                            drink_energy = EXCLUDED.drink_energy
                        RETURNING id
                    """)
                    .bindparams(
                        patient_id=patient_id,
                        entry_date=payload.entry_date,
                        bristol_scale=payload.bristol_scale,
                        stool_count=(payload.raw_data or {}).get('stool_count', 0),
                        pads_used=(payload.raw_data or {}).get('pads_used', 0),
                        urgency=((payload.raw_data or {}).get('urgency') == 'Yes'),
                        night_stools=((payload.raw_data or {}).get('night_stools') == 'Yes'),
                        leakage=(payload.raw_data or {}).get('leakage', 'None'),
                        incomplete_evac=((payload.raw_data or {}).get('incomplete_evac') == 'Yes'),
                        bloating=int((payload.raw_data or {}).get('bloating', 0)) if (payload.raw_data or {}).get('bloating') is not None else 0,
                        impact_score=int((payload.raw_data or {}).get('impact_score', 0)) if (payload.raw_data or {}).get('impact_score') is not None else 0,
                        activity_interfere=int((payload.raw_data or {}).get('activity_interfere', 0)) if (payload.raw_data or {}).get('activity_interfere') is not None else 0,
                        food_vegetables_all=(payload.food_consumption or {}).get('Vegetables (all types)', 0),
                        food_root_vegetables=(payload.food_consumption or {}).get('Root vegetables', 0),
                        food_whole_grains=(payload.food_consumption or {}).get('Whole grains', 0),
                        food_whole_grain_bread=(payload.food_consumption or {}).get('Whole grain bread', 0),
                        food_nuts_and_seeds=(payload.food_consumption or {}).get('Nuts and seeds', 0),
                        food_legumes=(payload.food_consumption or {}).get('Legumes', 0),
                        food_fruits_with_skin=(payload.food_consumption or {}).get('Fruits with skin', 0),
                        food_berries=(payload.food_consumption or {}).get('Berries (any)', 0),
                        food_soft_fruits_no_skin=(payload.food_consumption or {}).get('Soft fruits without skin', 0),
                        food_muesli_and_bran=(payload.food_consumption or {}).get('Muesli and bran cereals', 0),
                        drink_water=(payload.drink_consumption or {}).get('Water', 0),
                        drink_coffee=(payload.drink_consumption or {}).get('Coffee', 0),
                        drink_tea=(payload.drink_consumption or {}).get('Tea', 0),
                        drink_alcohol=(payload.drink_consumption or {}).get('Alcohol', 0),
                        drink_carbonated=(payload.drink_consumption or {}).get('Carbonated drinks', 0),
                        drink_juices=(payload.drink_consumption or {}).get('Juices', 0),
                        drink_dairy=(payload.drink_consumption or {}).get('Dairy drinks', 0),
                        drink_energy=(payload.drink_consumption or {}).get('Energy drinks', 0),
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


