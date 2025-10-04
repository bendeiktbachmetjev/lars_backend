-- Add structured columns for Monthly (QoL) while keeping JSON for backfill

ALTER TABLE monthly_entries
  ADD COLUMN IF NOT EXISTS avoid_travel SMALLINT,
  ADD COLUMN IF NOT EXISTS avoid_social SMALLINT,
  ADD COLUMN IF NOT EXISTS embarrassed SMALLINT,
  ADD COLUMN IF NOT EXISTS worry_notice SMALLINT,
  ADD COLUMN IF NOT EXISTS depressed SMALLINT,
  ADD COLUMN IF NOT EXISTS control SMALLINT,
  ADD COLUMN IF NOT EXISTS satisfaction SMALLINT;

-- Backfill from raw_data JSON if present
UPDATE monthly_entries SET
  avoid_travel = COALESCE((raw_data->>'avoid_travel')::int, avoid_travel),
  avoid_social = COALESCE((raw_data->>'avoid_social')::int, avoid_social),
  embarrassed = COALESCE((raw_data->>'embarrassed')::int, embarrassed),
  worry_notice = COALESCE((raw_data->>'worry_notice')::int, worry_notice),
  depressed = COALESCE((raw_data->>'depressed')::int, depressed),
  control = COALESCE((raw_data->>'control')::int, control),
  satisfaction = COALESCE((raw_data->>'satisfaction')::int, satisfaction);


