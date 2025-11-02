-- Migration: Add surgery_date field to patients table
-- This field stores the date of surgery/operation for EQ5D5L questionnaire scheduling

ALTER TABLE patients 
ADD COLUMN IF NOT EXISTS surgery_date DATE;

-- Add index for faster queries on surgery_date
CREATE INDEX IF NOT EXISTS idx_patients_surgery_date ON patients (surgery_date) WHERE surgery_date IS NOT NULL;

-- Add comment for documentation
COMMENT ON COLUMN patients.surgery_date IS 'Date of surgery/operation. Used for scheduling EQ5D5L questionnaires at specific intervals: pre-op, 2 weeks, 1 month, 3 months, 6 months, 12 months post-op';

