-- Migration: Add missing food_consumption and drink_consumption columns to daily_entries
-- Run this in Supabase SQL Editor

-- Add food_consumption column (JSONB)
ALTER TABLE daily_entries 
ADD COLUMN IF NOT EXISTS food_consumption JSONB NOT NULL DEFAULT '{}'::jsonb;

-- Add drink_consumption column (JSONB)
ALTER TABLE daily_entries 
ADD COLUMN IF NOT EXISTS drink_consumption JSONB NOT NULL DEFAULT '{}'::jsonb;

-- Verify the columns were added
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
    AND table_name = 'daily_entries'
    AND column_name IN ('food_consumption', 'drink_consumption')
ORDER BY column_name;

