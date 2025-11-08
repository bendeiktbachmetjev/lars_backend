-- УДАЛЕНИЕ ВСЕХ ТАБЛИЦ - ВНИМАНИЕ: ЭТО УДАЛИТ ВСЕ ДАННЫЕ!
-- Выполнить в Supabase SQL Editor

-- Удаляем таблицы в правильном порядке (сначала дочерние, потом родительские)
DROP TABLE IF EXISTS eq5d5l_entries CASCADE;
DROP TABLE IF EXISTS monthly_entries CASCADE;
DROP TABLE IF EXISTS daily_entries CASCADE;
DROP TABLE IF EXISTS weekly_entries CASCADE;
DROP TABLE IF EXISTS patients CASCADE;

-- Проверка: таблицы должны исчезнуть
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_name IN ('patients', 'weekly_entries', 'daily_entries', 'monthly_entries', 'eq5d5l_entries');

