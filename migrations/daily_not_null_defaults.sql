-- Make daily structured columns NOT NULL with sane defaults
-- Step 1: backfill NULLs
UPDATE daily_entries SET stool_count = 0 WHERE stool_count IS NULL;
UPDATE daily_entries SET pads_used = 0 WHERE pads_used IS NULL;
UPDATE daily_entries SET urgency = FALSE WHERE urgency IS NULL;
UPDATE daily_entries SET night_stools = FALSE WHERE night_stools IS NULL;
UPDATE daily_entries SET leakage = 'None' WHERE leakage IS NULL OR leakage = '';
UPDATE daily_entries SET incomplete_evac = FALSE WHERE incomplete_evac IS NULL;
UPDATE daily_entries SET bloating = 0 WHERE bloating IS NULL;
UPDATE daily_entries SET impact_score = 0 WHERE impact_score IS NULL;
UPDATE daily_entries SET activity_interfere = 0 WHERE activity_interfere IS NULL;

-- Food
UPDATE daily_entries SET food_vegetables_all = 0           WHERE food_vegetables_all IS NULL;
UPDATE daily_entries SET food_root_vegetables = 0          WHERE food_root_vegetables IS NULL;
UPDATE daily_entries SET food_whole_grains = 0             WHERE food_whole_grains IS NULL;
UPDATE daily_entries SET food_whole_grain_bread = 0        WHERE food_whole_grain_bread IS NULL;
UPDATE daily_entries SET food_nuts_and_seeds = 0           WHERE food_nuts_and_seeds IS NULL;
UPDATE daily_entries SET food_legumes = 0                  WHERE food_legumes IS NULL;
UPDATE daily_entries SET food_fruits_with_skin = 0         WHERE food_fruits_with_skin IS NULL;
UPDATE daily_entries SET food_berries = 0                  WHERE food_berries IS NULL;
UPDATE daily_entries SET food_soft_fruits_no_skin = 0      WHERE food_soft_fruits_no_skin IS NULL;
UPDATE daily_entries SET food_muesli_and_bran = 0          WHERE food_muesli_and_bran IS NULL;

-- Drinks
UPDATE daily_entries SET drink_water = 0        WHERE drink_water IS NULL;
UPDATE daily_entries SET drink_coffee = 0       WHERE drink_coffee IS NULL;
UPDATE daily_entries SET drink_tea = 0          WHERE drink_tea IS NULL;
UPDATE daily_entries SET drink_alcohol = 0      WHERE drink_alcohol IS NULL;
UPDATE daily_entries SET drink_carbonated = 0   WHERE drink_carbonated IS NULL;
UPDATE daily_entries SET drink_juices = 0       WHERE drink_juices IS NULL;
UPDATE daily_entries SET drink_dairy = 0        WHERE drink_dairy IS NULL;
UPDATE daily_entries SET drink_energy = 0       WHERE drink_energy IS NULL;

-- Step 2: set defaults and not-null constraints
ALTER TABLE daily_entries
  ALTER COLUMN stool_count SET DEFAULT 0,
  ALTER COLUMN stool_count SET NOT NULL,
  ALTER COLUMN pads_used SET DEFAULT 0,
  ALTER COLUMN pads_used SET NOT NULL,
  ALTER COLUMN urgency SET DEFAULT FALSE,
  ALTER COLUMN urgency SET NOT NULL,
  ALTER COLUMN night_stools SET DEFAULT FALSE,
  ALTER COLUMN night_stools SET NOT NULL,
  ALTER COLUMN leakage SET DEFAULT 'None',
  ALTER COLUMN leakage SET NOT NULL,
  ALTER COLUMN incomplete_evac SET DEFAULT FALSE,
  ALTER COLUMN incomplete_evac SET NOT NULL,
  ALTER COLUMN bloating SET DEFAULT 0,
  ALTER COLUMN bloating SET NOT NULL,
  ALTER COLUMN impact_score SET DEFAULT 0,
  ALTER COLUMN impact_score SET NOT NULL,
  ALTER COLUMN activity_interfere SET DEFAULT 0,
  ALTER COLUMN activity_interfere SET NOT NULL,
  ALTER COLUMN food_vegetables_all SET DEFAULT 0,
  ALTER COLUMN food_vegetables_all SET NOT NULL,
  ALTER COLUMN food_root_vegetables SET DEFAULT 0,
  ALTER COLUMN food_root_vegetables SET NOT NULL,
  ALTER COLUMN food_whole_grains SET DEFAULT 0,
  ALTER COLUMN food_whole_grains SET NOT NULL,
  ALTER COLUMN food_whole_grain_bread SET DEFAULT 0,
  ALTER COLUMN food_whole_grain_bread SET NOT NULL,
  ALTER COLUMN food_nuts_and_seeds SET DEFAULT 0,
  ALTER COLUMN food_nuts_and_seeds SET NOT NULL,
  ALTER COLUMN food_legumes SET DEFAULT 0,
  ALTER COLUMN food_legumes SET NOT NULL,
  ALTER COLUMN food_fruits_with_skin SET DEFAULT 0,
  ALTER COLUMN food_fruits_with_skin SET NOT NULL,
  ALTER COLUMN food_berries SET DEFAULT 0,
  ALTER COLUMN food_berries SET NOT NULL,
  ALTER COLUMN food_soft_fruits_no_skin SET DEFAULT 0,
  ALTER COLUMN food_soft_fruits_no_skin SET NOT NULL,
  ALTER COLUMN food_muesli_and_bran SET DEFAULT 0,
  ALTER COLUMN food_muesli_and_bran SET NOT NULL,
  ALTER COLUMN drink_water SET DEFAULT 0,
  ALTER COLUMN drink_water SET NOT NULL,
  ALTER COLUMN drink_coffee SET DEFAULT 0,
  ALTER COLUMN drink_coffee SET NOT NULL,
  ALTER COLUMN drink_tea SET DEFAULT 0,
  ALTER COLUMN drink_tea SET NOT NULL,
  ALTER COLUMN drink_alcohol SET DEFAULT 0,
  ALTER COLUMN drink_alcohol SET NOT NULL,
  ALTER COLUMN drink_carbonated SET DEFAULT 0,
  ALTER COLUMN drink_carbonated SET NOT NULL,
  ALTER COLUMN drink_juices SET DEFAULT 0,
  ALTER COLUMN drink_juices SET NOT NULL,
  ALTER COLUMN drink_dairy SET DEFAULT 0,
  ALTER COLUMN drink_dairy SET NOT NULL,
  ALTER COLUMN drink_energy SET DEFAULT 0,
  ALTER COLUMN drink_energy SET NOT NULL;


