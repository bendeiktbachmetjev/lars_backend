-- Add health_vas (0..100) column to EQ-5D-5L entries
ALTER TABLE eq5d5l_entries
  ADD COLUMN IF NOT EXISTS health_vas SMALLINT CHECK (health_vas BETWEEN 0 AND 100);











