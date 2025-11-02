import os
import json
import traceback
import logging
from typing import Optional
from urllib.parse import urlsplit

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

from fastapi import FastAPI, Header, HTTPException, Query
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


app = FastAPI(
    title="LARS Backend API",
    description="Backend API for LARS questionnaire application",
    version="1.0.0"
)

# Log startup info
logger.info("FastAPI app created")


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
            logger.info("Switched from Transaction Pooler (6543) to Session Pooler (5432) for prepared statements support")
        elif ".pooler.supabase.com" in DATABASE_URL and ":5432" not in DATABASE_URL:
            # Если pooler, но порт не указан явно - добавляем 5432
            DATABASE_URL = DATABASE_URL.replace(".pooler.supabase.com", ".pooler.supabase.com:5432")
            logger.info("Added Session Pooler port (5432) for prepared statements support")
        
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
        logger.info("Database engine initialized successfully")
        db_url_display = DATABASE_URL[:50] + "..." if len(DATABASE_URL) > 50 else DATABASE_URL
        logger.info(f"Database URL configured: {db_url_display}")
    except Exception as e:
        logger.warning(f"Failed to initialize database engine: {e}")
        logger.warning(traceback.format_exc())
        # Continue without database - endpoints will return 503

logger.info("App module initialization complete")


@app.get("/healthz")
async def healthcheck():
    """Health check endpoint for Railway deployment"""
    db_status = "ok" if engine else "not_configured"
    return {
        "status": "ok",
        "database": db_status,
        "app": "running"
    }


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
        logger.error(f"Error in sendWeekly: {error_type}: {error_msg}")
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
        logger.error(f"Error in sendDaily: {error_type}: {error_msg}")
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
        logger.error(f"Error in sendMonthly: {error_type}: {error_msg}")
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
                            pain_discomfort, anxiety_depression
                        ) VALUES (
                            :patient_id,
                            COALESCE(CAST(:entry_date AS DATE), CURRENT_DATE),
                            :mobility, :self_care, :usual_activities,
                            :pain_discomfort, :anxiety_depression
                        )
                        ON CONFLICT (patient_id, entry_date) DO UPDATE SET
                            mobility = EXCLUDED.mobility,
                            self_care = EXCLUDED.self_care,
                            usual_activities = EXCLUDED.usual_activities,
                            pain_discomfort = EXCLUDED.pain_discomfort,
                            anxiety_depression = EXCLUDED.anxiety_depression
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
                    )
                )
                row2 = res2.first()
        return {"status": "ok", "id": str(row2[0])}
    except Exception as e:
        error_msg = str(e)
        error_type = type(e).__name__
        logger.error(f"Error in sendEq5d5l: {error_type}: {error_msg}")
        traceback.print_exc()
        return JSONResponse(
            status_code=500, 
            content={"status": "error", "detail": error_msg, "error_type": error_type}
        )


@app.get("/getNextQuestionnaire")
async def get_next_questionnaire(
    x_patient_code: Optional[str] = Header(None)
):
    """
    Determine which questionnaire should be filled today for a patient.
    Returns:
    - "daily" if daily questionnaire should be filled
    - "weekly" if weekly questionnaire should be filled (instead of daily, once per week)
    - "monthly" if monthly questionnaire should be filled (instead of daily/weekly, once per month)
    - "none" if today's questionnaire is already filled
    
    Priority: monthly > weekly > daily
    """
    if not x_patient_code:
        raise HTTPException(status_code=400, detail="Missing X-Patient-Code header")
    patient_code = x_patient_code.strip().upper()
    if not patient_code or len(patient_code) < 4 or len(patient_code) > 64:
        raise HTTPException(status_code=400, detail="Invalid patient code format")

    if not async_session:
        raise HTTPException(status_code=503, detail="Database not configured")
    
    try:
        async with async_session() as session:
            # Get patient_id - ensure patient exists
            patient_res = await session.execute(
                text("SELECT id FROM patients WHERE patient_code = :code").bindparams(code=patient_code)
            )
            patient_row = patient_res.first()
            if not patient_row:
                # New patient - start with daily
                logger.info(f"getNextQuestionnaire: Patient with code {patient_code} not found, returning 'daily'")
                return {"status": "ok", "type": "daily"}
            
            patient_id = patient_row[0]
            logger.info(f"getNextQuestionnaire: Found patient_id={patient_id} for code={patient_code}")
            
            # Check if any questionnaire for today already exists
            # (daily, weekly, or monthly - any of them means today is filled)
            daily_check = await session.execute(
                text("""
                    SELECT id FROM daily_entries 
                    WHERE patient_id = :patient_id AND entry_date = CURRENT_DATE
                    LIMIT 1
                """).bindparams(patient_id=patient_id)
            )
            weekly_check = await session.execute(
                text("""
                    SELECT id FROM weekly_entries 
                    WHERE patient_id = :patient_id AND entry_date = CURRENT_DATE
                    LIMIT 1
                """).bindparams(patient_id=patient_id)
            )
            monthly_today_check = await session.execute(
                text("""
                    SELECT id FROM monthly_entries 
                    WHERE patient_id = :patient_id AND entry_date = CURRENT_DATE
                    LIMIT 1
                """).bindparams(patient_id=patient_id)
            )
            
            has_daily = daily_check.first() is not None
            has_weekly = weekly_check.first() is not None
            has_monthly = monthly_today_check.first() is not None
            has_any_today = has_daily or has_weekly or has_monthly
            
            logger.info(f"getNextQuestionnaire: Today's entries - daily={has_daily}, weekly={has_weekly}, monthly={has_monthly}")
            
            if has_any_today:
                # Today's questionnaire is already filled
                logger.info(f"getNextQuestionnaire: Today's questionnaire already filled, returning 'none'")
                return {"status": "ok", "type": "none"}
            
            # Check if monthly questionnaire is needed (once per month)
            # Get last monthly entry date
            monthly_last_check = await session.execute(
                text("""
                    SELECT entry_date FROM monthly_entries 
                    WHERE patient_id = :patient_id 
                    ORDER BY entry_date DESC 
                    LIMIT 1
                """).bindparams(patient_id=patient_id)
            )
            monthly_row = monthly_last_check.first()
            
            needs_monthly = False
            if monthly_row is None:
                # Never filled monthly - need it
                needs_monthly = True
            else:
                last_monthly_date = monthly_row[0]
                # Check if last monthly entry was more than 30 days ago
                # Direct date subtraction returns days as integer
                days_check = await session.execute(
                    text("""
                        SELECT (CURRENT_DATE - :last_date)::INTEGER as days_diff
                    """).bindparams(last_date=last_monthly_date)
                )
                days_diff = days_check.first()[0]
                if days_diff >= 30:
                    needs_monthly = True
            
            if needs_monthly:
                logger.info(f"getNextQuestionnaire: Monthly questionnaire needed, returning 'monthly'")
                return {"status": "ok", "type": "monthly"}
            
            # Check if weekly questionnaire is needed (once per week)
            # Get last weekly entry date
            weekly_last_check = await session.execute(
                text("""
                    SELECT entry_date FROM weekly_entries 
                    WHERE patient_id = :patient_id 
                    ORDER BY entry_date DESC 
                    LIMIT 1
                """).bindparams(patient_id=patient_id)
            )
            weekly_row = weekly_last_check.first()
            
            needs_weekly = False
            if weekly_row is None:
                # Never filled weekly - need it
                needs_weekly = True
            else:
                last_weekly_date = weekly_row[0]
                # Check if last weekly entry was more than 7 days ago
                # Direct date subtraction returns days as integer
                days_check = await session.execute(
                    text("""
                        SELECT (CURRENT_DATE - :last_date)::INTEGER as days_diff
                    """).bindparams(last_date=last_weekly_date)
                )
                days_diff = days_check.first()[0]
                if days_diff >= 7:
                    needs_weekly = True
            
            if needs_weekly:
                logger.info(f"getNextQuestionnaire: Weekly questionnaire needed, returning 'weekly'")
                return {"status": "ok", "type": "weekly"}
            
            # Default: daily questionnaire
            logger.info(f"getNextQuestionnaire: Default to daily questionnaire")
            return {"status": "ok", "type": "daily"}
            
    except HTTPException:
        # Re-raise HTTP exceptions (400, 503, etc.)
        raise
    except Exception as e:
        error_msg = str(e)
        error_type = type(e).__name__
        logger.error(f"Error in getNextQuestionnaire: {error_type}: {error_msg}")
        traceback.print_exc()
        # Return 500 instead of raising to avoid 502 from gateway
        return JSONResponse(
            status_code=500,
            content={"status": "error", "detail": error_msg, "error_type": error_type}
        )


@app.get("/getLarsData")
async def get_lars_data(
    period: str = Query(..., description="Time period: weekly, monthly, or yearly"),
    x_patient_code: Optional[str] = Header(None, alias="X-Patient-Code")
):
    """
    Get LARS score data for a patient grouped by time period.
    Returns data points with entry_date and total_score for the specified period.
    """
    if not x_patient_code:
        raise HTTPException(status_code=400, detail="Missing X-Patient-Code header")
    patient_code = x_patient_code.strip().upper()
    if not patient_code or len(patient_code) < 4 or len(patient_code) > 64:
        raise HTTPException(status_code=400, detail="Invalid patient code format")

    if not async_session:
        raise HTTPException(status_code=503, detail="Database not configured")
    
    # Validate period
    if period not in ["weekly", "monthly", "yearly"]:
        raise HTTPException(status_code=400, detail="Invalid period. Must be 'weekly', 'monthly', or 'yearly'")
    
    try:
        async with async_session() as session:
            # Get patient_id - ensure patient exists
            patient_res = await session.execute(
                text("SELECT id FROM patients WHERE patient_code = :code").bindparams(code=patient_code)
            )
            patient_row = patient_res.first()
            if not patient_row:
                logger.info(f"getLarsData: Patient with code {patient_code} not found, returning empty data")
                return {"status": "ok", "data": []}
            
            patient_id = patient_row[0]
            logger.info(f"getLarsData: Found patient_id={patient_id} for code={patient_code}, period={period}")
            
            # Build SQL query based on period
            # For weekly: group by week
            # For monthly: group by month
            # For yearly: group by year
            if period == "weekly":
                # Get last 5 weeks of data, grouped by week
                # Show all data if there's less than 5 weeks worth
                query = text("""
                    SELECT 
                        DATE_TRUNC('week', entry_date) as period_start,
                        AVG(total_score)::INTEGER as avg_score,
                        MIN(entry_date) as first_entry_date
                    FROM weekly_entries
                    WHERE patient_id = :patient_id 
                        AND total_score IS NOT NULL
                    GROUP BY DATE_TRUNC('week', entry_date)
                    ORDER BY period_start DESC
                    LIMIT 5
                """)
            elif period == "monthly":
                # Get last 6 months of data, grouped by month
                query = text("""
                    SELECT 
                        DATE_TRUNC('month', entry_date) as period_start,
                        AVG(total_score)::INTEGER as avg_score,
                        MIN(entry_date) as first_entry_date
                    FROM weekly_entries
                    WHERE patient_id = :patient_id 
                        AND total_score IS NOT NULL
                        AND entry_date >= CURRENT_DATE - INTERVAL '6 months'
                    GROUP BY DATE_TRUNC('month', entry_date)
                    ORDER BY period_start ASC
                """)
            else:  # yearly
                # Get last 5 years of data, grouped by year
                query = text("""
                    SELECT 
                        DATE_TRUNC('year', entry_date) as period_start,
                        AVG(total_score)::INTEGER as avg_score,
                        MIN(entry_date) as first_entry_date
                    FROM weekly_entries
                    WHERE patient_id = :patient_id 
                        AND total_score IS NOT NULL
                        AND entry_date >= CURRENT_DATE - INTERVAL '5 years'
                    GROUP BY DATE_TRUNC('year', entry_date)
                    ORDER BY period_start ASC
                """)
            
            result = await session.execute(query.bindparams(patient_id=patient_id))
            rows = result.fetchall()
            
            # Reverse if ordered DESC to get chronological order
            if period == "weekly" and rows:
                rows = list(reversed(rows))
            
            data = []
            for idx, row in enumerate(rows, start=1):
                data.append({
                    "index": idx,
                    "date": row[2].isoformat() if row[2] else None,  # first_entry_date
                    "score": row[1] if row[1] is not None else None  # avg_score
                })
            
            logger.info(f"getLarsData: Returning {len(data)} data points")
            return {"status": "ok", "data": data}
    except HTTPException:
        # Re-raise HTTP exceptions (400, 503, etc.)
        raise
    except Exception as e:
        error_msg = str(e)
        error_type = type(e).__name__
        logger.error(f"Error in getLarsData: {error_type}: {error_msg}")
        traceback.print_exc()
        # Return 500 instead of raising to avoid 502 from gateway
        return JSONResponse(
            status_code=500,
            content={"status": "error", "detail": error_msg, "error_type": error_type}
        )
