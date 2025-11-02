import os
import json
import traceback
from typing import Optional
from urllib.parse import urlsplit

from fastapi import FastAPI, Header, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncEngine, create_async_engine, AsyncSession
from sqlalchemy import text
from sqlalchemy.orm import sessionmaker


# Pydantic модели - точно как отправляет frontend
class WeeklyPayload(BaseModel):
    flatus_control: int
    liquid_stool_leakage: int
    bowel_frequency: int
    repeat_bowel_opening: int
    urgency_to_toilet: int
    entry_date: Optional[str] = None
    raw_data: Optional[dict] = None

class DailyPayload(BaseModel):
    entry_date: Optional[str] = None
    bristol_scale: Optional[int] = None
    food_consumption: Optional[dict] = None  # Map<String, int> - будет распарсено в отдельные колонки
    drink_consumption: Optional[dict] = None  # Map<String, int> - будет распарсено в отдельные колонки
    raw_data: Optional[dict] = None  # Содержит: stool_count, pads_used, urgency, night_stools, leakage, incomplete_evacuation, bloating, impact_score, activity_interfere

class MonthlyPayload(BaseModel):
    entry_date: Optional[str] = None
    qol_score: Optional[int] = None
    raw_data: Optional[dict] = None  # Содержит: avoid_travel, avoid_social, embarrassed, worry_notice, depressed, control, satisfaction

class Eq5d5lPayload(BaseModel):
    mobility: int
    self_care: int
    usual_activities: int
    pain_discomfort: int
    anxiety_depression: int
    entry_date: Optional[str] = None
    raw_data: Optional[dict] = None


app = FastAPI()


def _build_async_url(sync_url: str) -> str:
    """Конвертирует postgres:// в postgresql+asyncpg:// и убирает sslmode из URL"""
    if not sync_url:
        return sync_url
    parts = urlsplit(sync_url)
    scheme = parts.scheme
    
    if "+" in scheme:
        base_scheme = scheme.split("+")[0]
    else:
        base_scheme = scheme
    
    if base_scheme.startswith("postgres"):
        # Убираем sslmode из query параметров (asyncpg не поддерживает в URL)
        from urllib.parse import parse_qsl, urlencode
        query_pairs = dict(parse_qsl(parts.query, keep_blank_values=True))
        query_pairs.pop("sslmode", None)
        new_query = urlencode(query_pairs) if query_pairs else ""
        
        new_scheme = "postgresql+asyncpg"
        new_parts = (new_scheme, parts.netloc, parts.path, new_query, parts.fragment)
        from urllib.parse import urlunsplit
        return urlunsplit(new_parts)
    return sync_url


# Инициализация базы данных
DATABASE_URL = os.getenv("DATABASE_URL", "")
engine: AsyncEngine = None
async_session = None

if DATABASE_URL:
    try:
        # ПРОСТОЕ РЕШЕНИЕ: автоматически переключаемся на Session Pooler (порт 5432)
        # Transaction Pooler (порт 6543) не поддерживает prepared statements
        # Заменяем :6543 на :5432 если используется pooler
        if ":6543" in DATABASE_URL:
            DATABASE_URL = DATABASE_URL.replace(":6543", ":5432")
            print("Switched from Transaction Pooler (6543) to Session Pooler (5432) for prepared statements support")
        elif ".pooler.supabase.com" in DATABASE_URL and ":5432" not in DATABASE_URL:
            # Если pooler, но порт не указан явно - добавляем 5432
            DATABASE_URL = DATABASE_URL.replace(".pooler.supabase.com", ".pooler.supabase.com:5432")
            print("Added Session Pooler port (5432) for prepared statements support")
        
        ASYNC_DATABASE_URL = _build_async_url(DATABASE_URL)
        ssl_required = "sslmode=require" in DATABASE_URL.lower() or os.getenv("SUPABASE_SSLMODE") == "require"
        
        connect_args = {
            "server_settings": {"application_name": "lars_backend"},
        }
        if ssl_required:
            connect_args["ssl"] = True
        
        engine = create_async_engine(
            ASYNC_DATABASE_URL,
            pool_pre_ping=True,
            pool_size=5,
            max_overflow=10,
            pool_recycle=300,
            echo=False,
            connect_args=connect_args,
        )
        
        async_session = sessionmaker(bind=engine, expire_on_commit=False, class_=AsyncSession)
        print("Database engine initialized successfully")
    except Exception as e:
        print(f"Warning: Failed to initialize database engine: {e}")
        traceback.print_exc()


@app.get("/healthz")
async def healthcheck():
    db_status = "ok" if engine else "not_configured"
    return {"status": "ok", "database": db_status}


@app.post("/sendWeekly")
async def send_weekly(payload: WeeklyPayload, x_patient_code: Optional[str] = Header(None)):
    if not x_patient_code:
        raise HTTPException(status_code=400, detail="Missing X-Patient-Code header")
    patient_code = x_patient_code.strip().upper()
    if not patient_code or len(patient_code) < 4 or len(patient_code) > 64:
        raise HTTPException(status_code=400, detail="Invalid patient code format")

    if not async_session:
        raise HTTPException(status_code=503, detail="Database not configured")
    
    try:
        async with async_session() as session:
            async with session.begin():
                # Создать или получить patient_id
                res = await session.execute(
                    text("""
                        INSERT INTO patients (patient_code)
                        VALUES (:code)
                        ON CONFLICT (patient_code) DO UPDATE SET patient_code = EXCLUDED.patient_code
                        RETURNING id
                    """).bindparams(code=patient_code)
                )
                patient_id = res.first()[0]

                # Сохранить weekly entry
                # Вычисляем total_score из raw_data если есть
                total_score = None
                if payload.raw_data and "total_score" in payload.raw_data:
                    total_score = payload.raw_data["total_score"]
                
                res2 = await session.execute(
                    text("""
                        INSERT INTO weekly_entries (
                            patient_id, entry_date,
                            flatus_control, liquid_stool_leakage, bowel_frequency,
                            repeat_bowel_opening, urgency_to_toilet, total_score
                        ) VALUES (
                            :patient_id,
                            COALESCE(CAST(:entry_date AS DATE), CURRENT_DATE),
                            :flatus_control, :liquid_stool_leakage, :bowel_frequency,
                            :repeat_bowel_opening, :urgency_to_toilet, :total_score
                        )
                        ON CONFLICT (patient_id, entry_date) DO UPDATE SET
                            flatus_control = EXCLUDED.flatus_control,
                            liquid_stool_leakage = EXCLUDED.liquid_stool_leakage,
                            bowel_frequency = EXCLUDED.bowel_frequency,
                            repeat_bowel_opening = EXCLUDED.repeat_bowel_opening,
                            urgency_to_toilet = EXCLUDED.urgency_to_toilet,
                            total_score = EXCLUDED.total_score
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
                        total_score=total_score,
                    )
                )
                row2 = res2.first()
        return {"status": "ok", "id": str(row2[0])}
    except Exception as e:
        error_msg = str(e)
        error_type = type(e).__name__
        print(f"Error in sendWeekly: {error_type}: {error_msg}")
        traceback.print_exc()
        return JSONResponse(
            status_code=500, 
            content={"status": "error", "detail": error_msg, "error_type": error_type}
        )


@app.post("/sendDaily")
async def send_daily(payload: DailyPayload, x_patient_code: Optional[str] = Header(None)):
    if not x_patient_code:
        raise HTTPException(status_code=400, detail="Missing X-Patient-Code header")
    patient_code = x_patient_code.strip().upper()
    if not patient_code or len(patient_code) < 4 or len(patient_code) > 64:
        raise HTTPException(status_code=400, detail="Invalid patient code format")

    if not async_session:
        raise HTTPException(status_code=503, detail="Database not configured")
    
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

                # Парсим raw_data в отдельные поля
                raw = payload.raw_data or {}
                stool_count = raw.get("stool_count", 0)
                pads_used = raw.get("pads_used", 0)
                urgency = raw.get("urgency", "No")
                night_stools = raw.get("night_stools", "No")
                leakage = raw.get("leakage", "None")
                incomplete_evacuation = raw.get("incomplete_evacuation", "No")
                bloating = raw.get("bloating", 0.0)
                impact_score = raw.get("impact_score", 0.0)
                activity_interfere = raw.get("activity_interfere", 0.0)
                
                # Парсим food_consumption Map в отдельные колонки
                food = payload.food_consumption or {}
                food_vegetables_all = food.get("Vegetables (all types)", 0)
                food_root_vegetables = food.get("Root vegetables", 0)
                food_whole_grains = food.get("Whole grains", 0)
                food_whole_grain_bread = food.get("Whole grain bread", 0)
                food_nuts_and_seeds = food.get("Nuts and seeds", 0)
                food_legumes = food.get("Legumes", 0)
                food_fruits_with_skin = food.get("Fruits with skin", 0)
                food_berries = food.get("Berries (any)", 0)
                food_soft_fruits_no_skin = food.get("Soft fruits without skin", 0)
                food_muesli_and_bran = food.get("Muesli and bran cereals", 0)
                
                # Парсим drink_consumption Map в отдельные колонки
                drink = payload.drink_consumption or {}
                drink_water = drink.get("Water", 0)
                drink_coffee = drink.get("Coffee", 0)
                drink_tea = drink.get("Tea", 0)
                drink_alcohol = drink.get("Alcohol", 0)
                drink_carbonated = drink.get("Carbonated drinks", 0)
                drink_juices = drink.get("Juices", 0)
                drink_dairy = drink.get("Dairy drinks", 0)
                drink_energy = drink.get("Energy drinks", 0)
                
                res2 = await session.execute(
                    text("""
                        INSERT INTO daily_entries (
                            patient_id, entry_date, bristol_scale,
                            stool_count, pads_used, urgency, night_stools, leakage,
                            incomplete_evacuation, bloating, impact_score, activity_interfere,
                            food_vegetables_all, food_root_vegetables, food_whole_grains,
                            food_whole_grain_bread, food_nuts_and_seeds, food_legumes,
                            food_fruits_with_skin, food_berries, food_soft_fruits_no_skin,
                            food_muesli_and_bran,
                            drink_water, drink_coffee, drink_tea, drink_alcohol,
                            drink_carbonated, drink_juices, drink_dairy, drink_energy
                        ) VALUES (
                            :patient_id,
                            COALESCE(CAST(:entry_date AS DATE), CURRENT_DATE),
                            :bristol_scale,
                            :stool_count, :pads_used, :urgency, :night_stools, :leakage,
                            :incomplete_evacuation, :bloating, :impact_score, :activity_interfere,
                            :food_vegetables_all, :food_root_vegetables, :food_whole_grains,
                            :food_whole_grain_bread, :food_nuts_and_seeds, :food_legumes,
                            :food_fruits_with_skin, :food_berries, :food_soft_fruits_no_skin,
                            :food_muesli_and_bran,
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
                            incomplete_evacuation = EXCLUDED.incomplete_evacuation,
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
                        stool_count=stool_count,
                        pads_used=pads_used,
                        urgency=urgency,
                        night_stools=night_stools,
                        leakage=leakage,
                        incomplete_evacuation=incomplete_evacuation,
                        bloating=bloating,
                        impact_score=impact_score,
                        activity_interfere=activity_interfere,
                        food_vegetables_all=food_vegetables_all,
                        food_root_vegetables=food_root_vegetables,
                        food_whole_grains=food_whole_grains,
                        food_whole_grain_bread=food_whole_grain_bread,
                        food_nuts_and_seeds=food_nuts_and_seeds,
                        food_legumes=food_legumes,
                        food_fruits_with_skin=food_fruits_with_skin,
                        food_berries=food_berries,
                        food_soft_fruits_no_skin=food_soft_fruits_no_skin,
                        food_muesli_and_bran=food_muesli_and_bran,
                        drink_water=drink_water,
                        drink_coffee=drink_coffee,
                        drink_tea=drink_tea,
                        drink_alcohol=drink_alcohol,
                        drink_carbonated=drink_carbonated,
                        drink_juices=drink_juices,
                        drink_dairy=drink_dairy,
                        drink_energy=drink_energy,
                    )
                )
                row2 = res2.first()
        return {"status": "ok", "id": str(row2[0])}
    except Exception as e:
        error_msg = str(e)
        error_type = type(e).__name__
        print(f"Error in sendDaily: {error_type}: {error_msg}")
        traceback.print_exc()
        return JSONResponse(
            status_code=500, 
            content={"status": "error", "detail": error_msg, "error_type": error_type}
        )


@app.post("/sendMonthly")
async def send_monthly(payload: MonthlyPayload, x_patient_code: Optional[str] = Header(None)):
    if not x_patient_code:
        raise HTTPException(status_code=400, detail="Missing X-Patient-Code header")
    patient_code = x_patient_code.strip().upper()
    if not patient_code or len(patient_code) < 4 or len(patient_code) > 64:
        raise HTTPException(status_code=400, detail="Invalid patient code format")

    if not async_session:
        raise HTTPException(status_code=503, detail="Database not configured")
    
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

                # Парсим raw_data в отдельные поля
                raw = payload.raw_data or {}
                avoid_travel = raw.get("avoid_travel", 1.0)
                avoid_social = raw.get("avoid_social", 1.0)
                embarrassed = raw.get("embarrassed", 1.0)
                worry_notice = raw.get("worry_notice", 1.0)
                depressed = raw.get("depressed", 1.0)
                control = raw.get("control", 0.0)
                satisfaction = raw.get("satisfaction", 0.0)
                
                res2 = await session.execute(
                    text("""
                        INSERT INTO monthly_entries (
                            patient_id, entry_date, qol_score,
                            avoid_travel, avoid_social, embarrassed, worry_notice,
                            depressed, control, satisfaction
                        ) VALUES (
                            :patient_id,
                            COALESCE(CAST(:entry_date AS DATE), CURRENT_DATE),
                            :qol_score,
                            :avoid_travel, :avoid_social, :embarrassed, :worry_notice,
                            :depressed, :control, :satisfaction
                        )
                        ON CONFLICT (patient_id, entry_date) DO UPDATE SET
                            qol_score = EXCLUDED.qol_score,
                            avoid_travel = EXCLUDED.avoid_travel,
                            avoid_social = EXCLUDED.avoid_social,
                            embarrassed = EXCLUDED.embarrassed,
                            worry_notice = EXCLUDED.worry_notice,
                            depressed = EXCLUDED.depressed,
                            control = EXCLUDED.control,
                            satisfaction = EXCLUDED.satisfaction
                        RETURNING id
                    """)
                    .bindparams(
                        patient_id=patient_id,
                        entry_date=payload.entry_date,
                        qol_score=payload.qol_score,
                        avoid_travel=avoid_travel,
                        avoid_social=avoid_social,
                        embarrassed=embarrassed,
                        worry_notice=worry_notice,
                        depressed=depressed,
                        control=control,
                        satisfaction=satisfaction,
                    )
                )
                row2 = res2.first()
        return {"status": "ok", "id": str(row2[0])}
    except Exception as e:
        error_msg = str(e)
        error_type = type(e).__name__
        print(f"Error in sendMonthly: {error_type}: {error_msg}")
        traceback.print_exc()
        return JSONResponse(
            status_code=500, 
            content={"status": "error", "detail": error_msg, "error_type": error_type}
        )


@app.post("/sendEq5d5l")
async def send_eq5d5l(payload: Eq5d5lPayload, x_patient_code: Optional[str] = Header(None)):
    if not x_patient_code:
        raise HTTPException(status_code=400, detail="Missing X-Patient-Code header")
    patient_code = x_patient_code.strip().upper()
    if not patient_code or len(patient_code) < 4 or len(patient_code) > 64:
        raise HTTPException(status_code=400, detail="Invalid patient code format")

    if not async_session:
        raise HTTPException(status_code=503, detail="Database not configured")
    
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
        error_msg = str(e)
        error_type = type(e).__name__
        print(f"Error in sendEq5d5l: {error_type}: {error_msg}")
        traceback.print_exc()
        return JSONResponse(
            status_code=500, 
            content={"status": "error", "detail": error_msg, "error_type": error_type}
        )
