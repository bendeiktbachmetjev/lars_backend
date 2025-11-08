-- Migration to fix all constraints and data to match frontend values
-- Frontend is the source of truth - backend must accept what frontend sends

-- ==========================================
-- 1. Fix leakage constraint in daily_entries
-- Frontend sends: 'None', 'Liquid', 'Solid'
-- Old constraint: 'None', 'Small', 'Large'
-- ==========================================

-- Drop the old constraint
ALTER TABLE daily_entries DROP CONSTRAINT IF EXISTS daily_entries_leakage_check;

-- Add new constraint that matches frontend values
ALTER TABLE daily_entries 
  ADD CONSTRAINT daily_entries_leakage_check 
  CHECK (leakage IN ('None', 'Liquid', 'Solid'));

-- Update existing data if any (convert 'Small' -> 'Liquid', 'Large' -> 'Solid')
UPDATE daily_entries SET leakage = 'Liquid' WHERE leakage = 'Small';
UPDATE daily_entries SET leakage = 'Solid' WHERE leakage = 'Large';


