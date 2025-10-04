-- Drop JSON columns from daily_entries safely
-- 1) Drop GIN index depending on raw_data
DROP INDEX IF EXISTS idx_daily_raw_data;

-- 2) Drop JSON columns (idempotent)
ALTER TABLE daily_entries
  DROP COLUMN IF EXISTS food_consumption,
  DROP COLUMN IF EXISTS drink_consumption,
  DROP COLUMN IF EXISTS raw_data;


