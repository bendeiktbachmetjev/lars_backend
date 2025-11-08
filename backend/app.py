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
    health_vas: Optional[int] = None  # 0..100 Visual Analogue Scale for health today
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
                # Validate leakage value matches frontend options
                # Frontend sends: 'None', 'Liquid', 'Solid'
                if leakage not in ("None", "Liquid", "Solid"):
                    print(f"Warning: Invalid leakage value '{leakage}', defaulting to 'None'")
                    leakage = "None"
                incomplete_evacuation = raw.get("incomplete_evacuation", "No")
                bloating = raw.get("bloating", 0.0)
                impact_score = raw.get("impact_score", 0.0)
                activity_interfere = raw.get("activity_interfere", 0.0)
                
                # Парсим food_consumption Map в отдельные колонки
                # Frontend sends keys: 'vegetables_all_types', 'root_vegetables', 
                # 'whole_grains', 'whole_grain_bread', 'nuts_and_seeds', 'legumes',
                # 'fruits_with_skin', 'berries_any', 'soft_fruits_without_skin', 
                # 'muesli_and_bran_cereals'
                food = payload.food_consumption or {}
                food_vegetables_all = food.get("vegetables_all_types", 0)
                food_root_vegetables = food.get("root_vegetables", 0)
                food_whole_grains = food.get("whole_grains", 0)
                food_whole_grain_bread = food.get("whole_grain_bread", 0)
                food_nuts_and_seeds = food.get("nuts_and_seeds", 0)
                food_legumes = food.get("legumes", 0)
                food_fruits_with_skin = food.get("fruits_with_skin", 0)
                food_berries = food.get("berries_any", 0)
                food_soft_fruits_no_skin = food.get("soft_fruits_without_skin", 0)
                food_muesli_and_bran = food.get("muesli_and_bran_cereals", 0)
                
                # Парсим drink_consumption Map в отдельные колонки
                # Frontend sends keys: 'water', 'coffee', 'tea', 'alcohol',
                # 'carbonated_drinks', 'juices', 'dairy_drinks', 'energy_drinks'
                drink = payload.drink_consumption or {}
                drink_water = drink.get("water", 0)
                drink_coffee = drink.get("coffee", 0)
                drink_tea = drink.get("tea", 0)
                drink_alcohol = drink.get("alcohol", 0)
                drink_carbonated = drink.get("carbonated_drinks", 0)
                drink_juices = drink.get("juices", 0)
                drink_dairy = drink.get("dairy_drinks", 0)
                drink_energy = drink.get("energy_drinks", 0)
                
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

                # Extract health VAS from payload or raw_data if provided
                health_vas = payload.health_vas
                if health_vas is None and payload.raw_data is not None:
                    hv = payload.raw_data.get("health_vas")
                    if isinstance(hv, (int, float)):
                        try:
                            health_vas = int(hv)
                        except Exception:
                            health_vas = None

                res2 = await session.execute(
                    text("""
                        INSERT INTO eq5d5l_entries (
                            patient_id, entry_date,
                            mobility, self_care, usual_activities,
                            pain_discomfort, anxiety_depression, health_vas
                        ) VALUES (
                            :patient_id,
                            COALESCE(CAST(:entry_date AS DATE), CURRENT_DATE),
                            :mobility, :self_care, :usual_activities,
                            :pain_discomfort, :anxiety_depression, :health_vas
                        )
                        ON CONFLICT (patient_id, entry_date) DO UPDATE SET
                            mobility = EXCLUDED.mobility,
                            self_care = EXCLUDED.self_care,
                            usual_activities = EXCLUDED.usual_activities,
                            pain_discomfort = EXCLUDED.pain_discomfort,
                            anxiety_depression = EXCLUDED.anxiety_depression,
                            health_vas = EXCLUDED.health_vas
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
                        health_vas=health_vas,
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


@app.get("/getLarsData")
async def get_lars_data(
    period: str,  # "weekly", "monthly", or "yearly"
    x_patient_code: Optional[str] = Header(None)
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
            # Get patient_id
            patient_res = await session.execute(
                text("SELECT id FROM patients WHERE patient_code = :code").bindparams(code=patient_code)
            )
            patient_row = patient_res.first()
            if not patient_row:
                return {"status": "ok", "data": []}
            
            patient_id = patient_row[0]
            
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
            
            return {"status": "ok", "data": data}
    except Exception as e:
        error_msg = str(e)
        error_type = type(e).__name__
        print(f"Error in getLarsData: {error_type}: {error_msg}")
        traceback.print_exc()
        return JSONResponse(
            status_code=500,
            content={"status": "error", "detail": error_msg, "error_type": error_type}
        )

@app.get("/getNextQuestionnaire")
async def get_next_questionnaire(x_patient_code: Optional[str] = Header(None)):
    """
    Determine which questionnaire should be filled today based on:
    - EQ-5D-5L: at 2 weeks, 1 month, 3 months, 6 months, 12 months after patient registration
    - Weekly (LARS): once per week (every 7 days)
    - Monthly: once per month (~30 days), but on a different day of week than weekly
    - Daily: if no mandatory questionnaires are due
    
    Returns questionnaire type: "daily", "weekly", "monthly", "eq5d5l", or null if all done.
    """
    if not x_patient_code:
        raise HTTPException(status_code=400, detail="Missing X-Patient-Code header")
    patient_code = x_patient_code.strip().upper()
    if not patient_code or len(patient_code) < 4 or len(patient_code) > 64:
        raise HTTPException(status_code=400, detail="Invalid patient code format")

    if not async_session:
        raise HTTPException(status_code=503, detail="Database not configured")
    
    try:
        from datetime import datetime, date, timedelta
        
        async with async_session() as session:
            # Get patient_id and created_at
            patient_res = await session.execute(
                text("""
                    SELECT id, created_at::DATE as patient_created_date
                    FROM patients 
                    WHERE patient_code = :code
                """).bindparams(code=patient_code)
            )
            patient_row = patient_res.first()
            
            # If patient doesn't exist, suggest first questionnaire (weekly) - patient will be created when they submit
            if not patient_row:
                return {
                    "status": "ok",
                    "questionnaire_type": "weekly",
                    "is_today_filled": False,
                    "reason": "Welcome! Please start with your first weekly questionnaire (LARS)"
                }
            
            patient_id = patient_row[0]
            patient_created_date = patient_row[1] if patient_row[1] is not None else None
            today = date.today()
            
            # Get last completion dates for each questionnaire type
            # Handle NULL values properly - MAX returns NULL if no rows exist
            last_weekly = await session.execute(
                text("""
                    SELECT MAX(entry_date) as last_date
                    FROM weekly_entries
                    WHERE patient_id = :patient_id
                """).bindparams(patient_id=patient_id)
            )
            last_weekly_row = last_weekly.first()
            last_weekly_date = last_weekly_row[0] if last_weekly_row and last_weekly_row[0] is not None else None
            
            last_monthly = await session.execute(
                text("""
                    SELECT MAX(entry_date) as last_date
                    FROM monthly_entries
                    WHERE patient_id = :patient_id
                """).bindparams(patient_id=patient_id)
            )
            last_monthly_row = last_monthly.first()
            last_monthly_date = last_monthly_row[0] if last_monthly_row and last_monthly_row[0] is not None else None
            
            last_eq5d5l = await session.execute(
                text("""
                    SELECT MAX(entry_date) as last_date
                    FROM eq5d5l_entries
                    WHERE patient_id = :patient_id
                """).bindparams(patient_id=patient_id)
            )
            last_eq5d5l_row = last_eq5d5l.first()
            last_eq5d5l_date = last_eq5d5l_row[0] if last_eq5d5l_row and last_eq5d5l_row[0] is not None else None
            
            last_daily = await session.execute(
                text("""
                    SELECT MAX(entry_date) as last_date
                    FROM daily_entries
                    WHERE patient_id = :patient_id
                """).bindparams(patient_id=patient_id)
            )
            last_daily_row = last_daily.first()
            last_daily_date = last_daily_row[0] if last_daily_row and last_daily_row[0] is not None else None
            
            # Determine next questionnaire using priority logic
            questionnaire_type = None
            reason = None
            
            # Priority 1: EQ-5D-5L (quality of life) - scheduled milestones
            if patient_created_date:
                days_since_start = (today - patient_created_date).days
                eq5d5l_milestones = [14, 30, 90, 180, 365]  # 2 weeks, 1 month, 3 months, 6 months, 12 months
                
                # Find the next uncompleted milestone
                for milestone_days in eq5d5l_milestones:
                    milestone_date = patient_created_date + timedelta(days=milestone_days)
                    
                    # Only consider milestones that are due (within 3 days before to 7 days after)
                    if today < milestone_date - timedelta(days=3):
                        continue  # Milestone is too far in the future
                    
                    if days_since_start >= milestone_days - 3:  # Allow 3 days early
                        # Check if we've already filled EQ-5D-5L for this milestone
                        milestone_filled = False
                        window_start = milestone_date - timedelta(days=3)
                        window_end = milestone_date + timedelta(days=7)
                        
                        check_res = await session.execute(
                            text("""
                                SELECT COUNT(*) as cnt
                                FROM eq5d5l_entries
                                WHERE patient_id = :patient_id
                                    AND entry_date >= :window_start
                                    AND entry_date <= :window_end
                            """).bindparams(
                                patient_id=patient_id,
                                window_start=window_start,
                                window_end=window_end
                            )
                        )
                        check_row = check_res.first()
                        if check_row and check_row[0] > 0:
                            milestone_filled = True
                        
                        if not milestone_filled:
                            questionnaire_type = "eq5d5l"
                            reason = f"EQ-5D-5L milestone at {milestone_days} days ({'due' if days_since_start >= milestone_days else 'upcoming'})"
                            break  # Found next uncompleted milestone, stop checking
            
            # Priority 2: Weekly (LARS) - once per week
            if not questionnaire_type:
                if last_weekly_date:
                    days_since_weekly = (today - last_weekly_date).days
                    if days_since_weekly >= 7:
                        questionnaire_type = "weekly"
                        reason = "Weekly questionnaire due (7 days passed)"
                else:
                    # Never filled weekly - make it due
                    questionnaire_type = "weekly"
                    reason = "First weekly questionnaire"
            
            # Priority 3: Monthly - once per month, but avoid same day as weekly
            if not questionnaire_type:
                if last_monthly_date:
                    days_since_monthly = (today - last_monthly_date).days
                    if days_since_monthly >= 28:  # ~4 weeks, slightly less than 30 to allow flexibility
                        # Check if weekly is also due today - if so, weekly has priority
                        weekly_due_today = False
                        if last_weekly_date:
                            days_since_weekly = (today - last_weekly_date).days
                            if days_since_weekly >= 7:
                                weekly_due_today = True
                        
                        if not weekly_due_today:
                            # Weekly is not due today, so monthly can be shown
                            questionnaire_type = "monthly"
                            reason = "Monthly questionnaire due (28+ days passed)"
                        # If weekly is also due, it will take priority (already checked above)
                else:
                    # Never filled monthly - but check if we should prioritize weekly first
                    weekly_due = False
                    if last_weekly_date:
                        days_since_weekly = (today - last_weekly_date).days
                        if days_since_weekly >= 7:
                            weekly_due = True
                    
                    if not weekly_due:
                        # Weekly is not due, can show monthly
                        questionnaire_type = "monthly"
                        reason = "First monthly questionnaire"
                    # If weekly is due, it will take priority (already checked above)
            
            # Priority 4: Daily - if no mandatory questionnaires are due
            if not questionnaire_type:
                if last_daily_date:
                    if (today - last_daily_date).days >= 1:
                        questionnaire_type = "daily"
                        reason = "Daily questionnaire available"
                else:
                    questionnaire_type = "daily"
                    reason = "First daily questionnaire"
            
            # Check if today's questionnaire is already filled
            is_today_filled = False
            if questionnaire_type:
                try:
                    if questionnaire_type == "weekly":
                        check = await session.execute(
                            text("SELECT COUNT(*) FROM weekly_entries WHERE patient_id = :pid AND entry_date = :today")
                            .bindparams(pid=patient_id, today=today)
                        )
                        check_row = check.first()
                        is_today_filled = check_row[0] > 0 if check_row else False
                    elif questionnaire_type == "monthly":
                        check = await session.execute(
                            text("SELECT COUNT(*) FROM monthly_entries WHERE patient_id = :pid AND entry_date = :today")
                            .bindparams(pid=patient_id, today=today)
                        )
                        check_row = check.first()
                        is_today_filled = check_row[0] > 0 if check_row else False
                    elif questionnaire_type == "eq5d5l":
                        check = await session.execute(
                            text("SELECT COUNT(*) FROM eq5d5l_entries WHERE patient_id = :pid AND entry_date = :today")
                            .bindparams(pid=patient_id, today=today)
                        )
                        check_row = check.first()
                        is_today_filled = check_row[0] > 0 if check_row else False
                    elif questionnaire_type == "daily":
                        check = await session.execute(
                            text("SELECT COUNT(*) FROM daily_entries WHERE patient_id = :pid AND entry_date = :today")
                            .bindparams(pid=patient_id, today=today)
                        )
                        check_row = check.first()
                        is_today_filled = check_row[0] > 0 if check_row else False
                except Exception as check_error:
                    # If check fails, assume not filled
                    print(f"Warning: Failed to check if today's questionnaire is filled: {check_error}")
                    is_today_filled = False
            
            return {
                "status": "ok",
                "questionnaire_type": questionnaire_type,
                "is_today_filled": is_today_filled,
                "reason": reason
            }
    except HTTPException:
        raise
    except Exception as e:
        error_msg = str(e)
        error_type = type(e).__name__
        print(f"Error in getNextQuestionnaire: {error_type}: {error_msg}")
        traceback.print_exc()
        return JSONResponse(
            status_code=500,
            content={"status": "error", "detail": error_msg, "error_type": error_type}
        )
