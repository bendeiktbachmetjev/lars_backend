-- Простая схема для LARS App
-- Создает таблицы точно так, как ожидает backend на основе frontend

-- Расширения
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Таблица пациентов
CREATE TABLE patients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_code TEXT NOT NULL UNIQUE CHECK (length(patient_code) BETWEEN 4 AND 64),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Weekly (LARS) опросник
CREATE TABLE weekly_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
  
  flatus_control SMALLINT NOT NULL CHECK (flatus_control BETWEEN 0 AND 2),
  liquid_stool_leakage SMALLINT NOT NULL CHECK (liquid_stool_leakage BETWEEN 0 AND 2),
  bowel_frequency SMALLINT NOT NULL CHECK (bowel_frequency BETWEEN 0 AND 3),
  repeat_bowel_opening SMALLINT NOT NULL CHECK (repeat_bowel_opening BETWEEN 0 AND 2),
  urgency_to_toilet SMALLINT NOT NULL CHECK (urgency_to_toilet BETWEEN 0 AND 2),
  
  raw_data JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  
  UNIQUE (patient_id, entry_date)
);

-- Daily опросник
CREATE TABLE daily_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
  
  bristol_scale SMALLINT CHECK (bristol_scale BETWEEN 1 AND 7),
  food_consumption JSONB NOT NULL DEFAULT '{}'::jsonb,
  drink_consumption JSONB NOT NULL DEFAULT '{}'::jsonb,
  raw_data JSONB NOT NULL DEFAULT '{}'::jsonb,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  
  UNIQUE (patient_id, entry_date)
);

-- Monthly опросник
CREATE TABLE monthly_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
  
  qol_score SMALLINT,
  raw_data JSONB NOT NULL DEFAULT '{}'::jsonb,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  
  UNIQUE (patient_id, entry_date)
);

-- EQ-5D-5L опросник
CREATE TABLE eq5d5l_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
  
  mobility SMALLINT NOT NULL CHECK (mobility BETWEEN 0 AND 4),
  self_care SMALLINT NOT NULL CHECK (self_care BETWEEN 0 AND 4),
  usual_activities SMALLINT NOT NULL CHECK (usual_activities BETWEEN 0 AND 4),
  pain_discomfort SMALLINT NOT NULL CHECK (pain_discomfort BETWEEN 0 AND 4),
  anxiety_depression SMALLINT NOT NULL CHECK (anxiety_depression BETWEEN 0 AND 4),
  
  raw_data JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  
  UNIQUE (patient_id, entry_date)
);

-- Индексы для быстрого поиска
CREATE INDEX idx_patients_code ON patients (patient_code);
CREATE INDEX idx_weekly_patient_date ON weekly_entries (patient_id, entry_date DESC);
CREATE INDEX idx_daily_patient_date ON daily_entries (patient_id, entry_date DESC);
CREATE INDEX idx_monthly_patient_date ON monthly_entries (patient_id, entry_date DESC);
CREATE INDEX idx_eq5d5l_patient_date ON eq5d5l_entries (patient_id, entry_date DESC);
