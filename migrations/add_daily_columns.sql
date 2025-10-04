-- Add structured columns for Daily entries while keeping JSON fields

ALTER TABLE daily_entries
  ADD COLUMN IF NOT EXISTS stool_count SMALLINT,
  ADD COLUMN IF NOT EXISTS pads_used SMALLINT,
  ADD COLUMN IF NOT EXISTS urgency BOOL,
  ADD COLUMN IF NOT EXISTS night_stools BOOL,
  ADD COLUMN IF NOT EXISTS leakage TEXT CHECK (leakage IN ('None','Liquid','Solid')),
  ADD COLUMN IF NOT EXISTS incomplete_evac BOOL,
  ADD COLUMN IF NOT EXISTS bloating SMALLINT,
  ADD COLUMN IF NOT EXISTS impact_score SMALLINT,
  ADD COLUMN IF NOT EXISTS activity_interfere SMALLINT,
  ADD COLUMN IF NOT EXISTS food_vegetables_all SMALLINT,
  ADD COLUMN IF NOT EXISTS food_root_vegetables SMALLINT,
  ADD COLUMN IF NOT EXISTS food_whole_grains SMALLINT,
  ADD COLUMN IF NOT EXISTS food_whole_grain_bread SMALLINT,
  ADD COLUMN IF NOT EXISTS food_nuts_and_seeds SMALLINT,
  ADD COLUMN IF NOT EXISTS food_legumes SMALLINT,
  ADD COLUMN IF NOT EXISTS food_fruits_with_skin SMALLINT,
  ADD COLUMN IF NOT EXISTS food_berries SMALLINT,
  ADD COLUMN IF NOT EXISTS food_soft_fruits_no_skin SMALLINT,
  ADD COLUMN IF NOT EXISTS food_muesli_and_bran SMALLINT,
  ADD COLUMN IF NOT EXISTS drink_water SMALLINT,
  ADD COLUMN IF NOT EXISTS drink_coffee SMALLINT,
  ADD COLUMN IF NOT EXISTS drink_tea SMALLINT,
  ADD COLUMN IF NOT EXISTS drink_alcohol SMALLINT,
  ADD COLUMN IF NOT EXISTS drink_carbonated SMALLINT,
  ADD COLUMN IF NOT EXISTS drink_juices SMALLINT,
  ADD COLUMN IF NOT EXISTS drink_dairy SMALLINT,
  ADD COLUMN IF NOT EXISTS drink_energy SMALLINT;


