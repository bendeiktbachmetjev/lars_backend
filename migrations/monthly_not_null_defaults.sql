-- Make monthly structured columns NOT NULL with defaults
UPDATE monthly_entries SET avoid_travel=0 WHERE avoid_travel IS NULL;
UPDATE monthly_entries SET avoid_social=0 WHERE avoid_social IS NULL;
UPDATE monthly_entries SET embarrassed=0 WHERE embarrassed IS NULL;
UPDATE monthly_entries SET worry_notice=0 WHERE worry_notice IS NULL;
UPDATE monthly_entries SET depressed=0 WHERE depressed IS NULL;
UPDATE monthly_entries SET control=0 WHERE control IS NULL;
UPDATE monthly_entries SET satisfaction=0 WHERE satisfaction IS NULL;

ALTER TABLE monthly_entries
  ALTER COLUMN avoid_travel SET DEFAULT 0,
  ALTER COLUMN avoid_travel SET NOT NULL,
  ALTER COLUMN avoid_social SET DEFAULT 0,
  ALTER COLUMN avoid_social SET NOT NULL,
  ALTER COLUMN embarrassed SET DEFAULT 0,
  ALTER COLUMN embarrassed SET NOT NULL,
  ALTER COLUMN worry_notice SET DEFAULT 0,
  ALTER COLUMN worry_notice SET NOT NULL,
  ALTER COLUMN depressed SET DEFAULT 0,
  ALTER COLUMN depressed SET NOT NULL,
  ALTER COLUMN control SET DEFAULT 0,
  ALTER COLUMN control SET NOT NULL,
  ALTER COLUMN satisfaction SET DEFAULT 0,
  ALTER COLUMN satisfaction SET NOT NULL;


