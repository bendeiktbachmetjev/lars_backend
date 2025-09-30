-- Core relational schema for LARS App
-- This script creates minimal tables for patients and form entries
-- Comments are in English as requested.

-- Extensions
CREATE EXTENSION IF NOT EXISTS pgcrypto; -- for gen_random_uuid()

-- Patients table: stores only the patient code (no PII)
CREATE TABLE IF NOT EXISTS patients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_code TEXT NOT NULL UNIQUE CHECK (length(patient_code) BETWEEN 4 AND 64),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Weekly entries (LARS)
-- We store raw selections (0-based indices) and compute total_score as a generated column
CREATE TABLE IF NOT EXISTS weekly_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  entry_date DATE NOT NULL DEFAULT CURRENT_DATE,

  -- Raw answers as indices from UI (0-based)
  flatus_control SMALLINT NOT NULL CHECK (flatus_control BETWEEN 0 AND 2),
  liquid_stool_leakage SMALLINT NOT NULL CHECK (liquid_stool_leakage BETWEEN 0 AND 2),
  bowel_frequency SMALLINT NOT NULL CHECK (bowel_frequency BETWEEN 0 AND 3),
  repeat_bowel_opening SMALLINT NOT NULL CHECK (repeat_bowel_opening BETWEEN 0 AND 2),
  urgency_to_toilet SMALLINT NOT NULL CHECK (urgency_to_toilet BETWEEN 0 AND 2),

  -- Computed LARS score based on standard scoring table
  total_score SMALLINT GENERATED ALWAYS AS (
    CASE flatus_control WHEN 0 THEN 0 WHEN 1 THEN 4 ELSE 7 END +
    CASE liquid_stool_leakage WHEN 0 THEN 0 WHEN 1 THEN 3 ELSE 3 END +
    CASE bowel_frequency WHEN 0 THEN 4 WHEN 1 THEN 2 WHEN 2 THEN 0 ELSE 5 END +
    CASE repeat_bowel_opening WHEN 0 THEN 0 WHEN 1 THEN 9 ELSE 11 END +
    CASE urgency_to_toilet WHEN 0 THEN 0 WHEN 1 THEN 11 ELSE 16 END
  ) STORED,

  raw_data JSONB NOT NULL DEFAULT '{}'::jsonb, -- future-proofing, keep raw payload
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE (patient_id, entry_date)
);

-- Daily entries (flexible JSON with a few common fields)
CREATE TABLE IF NOT EXISTS daily_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  entry_date DATE NOT NULL DEFAULT CURRENT_DATE,

  -- Optional structured fields commonly analyzed
  bristol_scale SMALLINT CHECK (bristol_scale BETWEEN 1 AND 7),

  -- Flexible payloads for future additions
  food_consumption JSONB NOT NULL DEFAULT '{}'::jsonb,
  drink_consumption JSONB NOT NULL DEFAULT '{}'::jsonb,
  raw_data JSONB NOT NULL DEFAULT '{}'::jsonb,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE (patient_id, entry_date)
);

-- Monthly entries (QoL or other long-form questionnaires)
CREATE TABLE IF NOT EXISTS monthly_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  entry_date DATE NOT NULL DEFAULT CURRENT_DATE,

  -- Optional overall score if computed client/server-side
  qol_score SMALLINT,
  raw_data JSONB NOT NULL DEFAULT '{}'::jsonb,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE (patient_id, entry_date)
);

-- Indexes for analytics and fast lookups
CREATE INDEX IF NOT EXISTS idx_patients_code ON patients (patient_code);

CREATE INDEX IF NOT EXISTS idx_weekly_patient_date ON weekly_entries (patient_id, entry_date DESC);
CREATE INDEX IF NOT EXISTS idx_daily_patient_date ON daily_entries (patient_id, entry_date DESC);
CREATE INDEX IF NOT EXISTS idx_monthly_patient_date ON monthly_entries (patient_id, entry_date DESC);

-- JSONB indexes for exploratory analytics
CREATE INDEX IF NOT EXISTS idx_daily_raw_data ON daily_entries USING GIN (raw_data jsonb_path_ops);
CREATE INDEX IF NOT EXISTS idx_monthly_raw_data ON monthly_entries USING GIN (raw_data jsonb_path_ops);

-- Basic sanity: prevent future dates if desired (optional, commented)
-- ALTER TABLE weekly_entries ADD CONSTRAINT weekly_no_future CHECK (entry_date <= CURRENT_DATE);
-- ALTER TABLE daily_entries ADD CONSTRAINT daily_no_future CHECK (entry_date <= CURRENT_DATE);
-- ALTER TABLE monthly_entries ADD CONSTRAINT monthly_no_future CHECK (entry_date <= CURRENT_DATE);



