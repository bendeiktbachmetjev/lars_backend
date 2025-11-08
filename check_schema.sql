-- Schema diagnostic queries for LARS database
-- Run these in Supabase SQL Editor to check current database state

-- 1. Check if all required tables exist
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_name IN ('patients', 'weekly_entries', 'daily_entries', 'monthly_entries', 'eq5d5l_entries')
ORDER BY table_name;

-- 2. Check columns in daily_entries table (the one causing issues)
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
    AND table_name = 'daily_entries'
ORDER BY ordinal_position;

-- 3. Check columns in all questionnaire tables
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
    AND table_name IN ('weekly_entries', 'daily_entries', 'monthly_entries', 'eq5d5l_entries')
ORDER BY table_name, ordinal_position;

-- 4. Check constraints on daily_entries
SELECT 
    constraint_name,
    constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'public' 
    AND table_name = 'daily_entries';

-- 5. Check indexes
SELECT 
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public' 
    AND tablename IN ('patients', 'weekly_entries', 'daily_entries', 'monthly_entries', 'eq5d5l_entries')
ORDER BY tablename, indexname;

-- 6. Quick check: try to describe daily_entries structure
SELECT 
    'daily_entries' as table_name,
    column_name,
    data_type,
    character_maximum_length,
    numeric_precision,
    numeric_scale,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
    AND table_name = 'daily_entries'
ORDER BY ordinal_position;

-- 7. Check if extensions are installed
SELECT extname, extversion 
FROM pg_extension 
WHERE extname IN ('pgcrypto', 'uuid-ossp');

