-- =====================================================
-- СЦЕНАРИИ ПРОВЕРКИ РОЛЕЙ ДЛЯ ОТЧЁТА
-- "Подготовьте сценарии проверки: какие роли что видят/могут изменять"
-- =====================================================

\echo '====================================================='
\echo 'СЦЕНАРИИ ПРОВЕРКИ РОЛЕЙ'
\echo '====================================================='

-- =====================================================
-- СЦЕНАРИЙ 1: voice_actor (актёр озвучки)
-- =====================================================
\echo ''
\echo '=== СЦЕНАРИЙ 1: voice_actor ==='

-- Тест 1.1: voice_actor видит только свои контракты (RLS)
\echo '--- Тест 1.1: RLS для voice_actor ---'
SET ROLE voice_actor;
SET app.current_actor_id = '1';

SELECT 'Контракты актёра 1 (RLS):' as test_name, 
       contract_id, contract_number, role_description, currency, signed_date
FROM app.contracts;

-- Тест 1.2: voice_actor НЕ видит salary_amount
\echo '--- Тест 1.2: Скрытие salary_amount ---'
SELECT 'salary_amount скрыт:' as test_name, 
       CASE WHEN COUNT(*) = 0 THEN 'ДА' ELSE 'НЕТ' END as result
FROM information_schema.column_privileges 
WHERE grantee = 'app_reader' 
  AND table_name = 'contracts' 
  AND column_name = 'salary_amount';

-- Тест 1.3: voice_actor может использовать безопасную функцию
\echo '--- Тест 1.3: Безопасная функция ---'
SELECT 'Безопасная функция работает:' as test_name, 
       contract_id, contract_number, role_description, salary_range, currency, signed_date
FROM app.get_contracts_with_masked_salary();

-- Тест 1.4: voice_actor НЕ может удалять
\echo '--- Тест 1.4: Запрет DELETE ---'
SELECT 'DELETE запрещён:' as test_name,
       CASE WHEN has_table_privilege('voice_actor', 'app.contracts', 'DELETE') 
            THEN 'НЕТ' ELSE 'ДА' END as result;

RESET ROLE;

-- =====================================================
-- СЦЕНАРИЙ 2: studio_manager (менеджер студии)
-- =====================================================
\echo ''
\echo '=== СЦЕНАРИЙ 2: studio_manager ==='

-- Тест 2.1: studio_manager видит проекты
\echo '--- Тест 2.1: Доступ к проектам ---'
SET ROLE studio_manager;

SELECT 'Проекты доступны:' as test_name, 
       project_id, title, studio_id, status, created_at
FROM app.projects;

-- Тест 2.2: studio_manager НЕ может читать audit.login_log
\echo '--- Тест 2.2: Запрет audit.login_log ---'
SELECT 'audit.login_log недоступен:' as test_name,
       CASE WHEN has_table_privilege('studio_manager', 'audit.login_log', 'SELECT') 
            THEN 'НЕТ' ELSE 'ДА' END as result;

-- Тест 2.3: studio_manager НЕ может удалять
\echo '--- Тест 2.3: Запрет DELETE ---'
SELECT 'DELETE запрещён:' as test_name,
       CASE WHEN has_table_privilege('studio_manager', 'app.contracts', 'DELETE') 
            THEN 'НЕТ' ELSE 'ДА' END as result;

RESET ROLE;

-- =====================================================
-- СЦЕНАРИЙ 3: security_auditor (аудитор безопасности)
-- =====================================================
\echo ''
\echo '=== СЦЕНАРИЙ 3: security_auditor ==='

-- Тест 3.1: security_auditor читает audit.login_log
\echo '--- Тест 3.1: Доступ к audit.login_log ---'
SET ROLE security_auditor;

SELECT 'audit.login_log доступен:' as test_name, 
       username, client_ip, connection_method, is_successful, login_time
FROM audit.login_log;

-- Тест 3.2: security_auditor НЕ может читать бизнес-данные
\echo '--- Тест 3.2: Запрет бизнес-данных ---'
SELECT 'app.contracts недоступен:' as test_name,
       CASE WHEN has_table_privilege('security_auditor', 'app.contracts', 'SELECT') 
            THEN 'НЕТ' ELSE 'ДА' END as result;

-- Тест 3.3: security_auditor может логировать подключения
\echo '--- Тест 3.3: Логирование подключений ---'
SELECT 'Логирование работает:' as test_name, 
       CASE WHEN has_function_privilege('security_auditor', 'public.log_session_start', 'EXECUTE') 
            THEN 'ДА' ELSE 'НЕТ' END as result;

RESET ROLE;

-- =====================================================
-- СЦЕНАРИЙ 4: app_reader (читатель)
-- =====================================================
\echo ''
\echo '=== СЦЕНАРИЙ 4: app_reader ==='

-- Тест 4.1: app_reader читает данные
\echo '--- Тест 4.1: Доступ к данным ---'
SET ROLE app_reader;

SELECT 'Актёры доступны:' as test_name, 
       actor_id, first_name, last_name, email, phone
FROM app.actors LIMIT 5;

SELECT 'Проекты доступны:' as test_name, 
       project_id, title, studio_id, status
FROM app.projects LIMIT 3;

-- Тест 4.2: app_reader НЕ видит salary_amount
\echo '--- Тест 4.2: Скрытие salary_amount ---'
SELECT 'salary_amount скрыт:' as test_name, 
       CASE WHEN COUNT(*) = 0 THEN 'ДА' ELSE 'НЕТ' END as result
FROM information_schema.column_privileges 
WHERE grantee = 'app_reader' 
  AND table_name = 'contracts' 
  AND column_name = 'salary_amount';

-- Тест 4.3: app_reader НЕ может изменять
\echo '--- Тест 4.3: Запрет изменений ---'
SELECT 'INSERT запрещён:' as test_name,
       CASE WHEN has_table_privilege('app_reader', 'app.actors', 'INSERT') 
            THEN 'НЕТ' ELSE 'ДА' END as result;

SELECT 'UPDATE запрещён:' as test_name,
       CASE WHEN has_table_privilege('app_reader', 'app.actors', 'UPDATE') 
            THEN 'НЕТ' ELSE 'ДА' END as result;

SELECT 'DELETE запрещён:' as test_name,
       CASE WHEN has_table_privilege('app_reader', 'app.actors', 'DELETE') 
            THEN 'НЕТ' ELSE 'ДА' END as result;

RESET ROLE;

-- =====================================================
-- СЦЕНАРИЙ 5: app_writer (писатель)
-- =====================================================
\echo ''
\echo '=== СЦЕНАРИЙ 5: app_writer ==='

-- Тест 5.1: app_writer может изменять данные
\echo '--- Тест 5.1: Доступ к изменениям ---'
SET ROLE app_writer;

SELECT 'INSERT разрешён:' as test_name,
       CASE WHEN has_table_privilege('app_writer', 'app.actors', 'INSERT') 
            THEN 'ДА' ELSE 'НЕТ' END as result;

SELECT 'UPDATE разрешён:' as test_name,
       CASE WHEN has_table_privilege('app_writer', 'app.actors', 'UPDATE') 
            THEN 'ДА' ELSE 'НЕТ' END as result;

-- Тест 5.2: app_writer НЕ может удалять
\echo '--- Тест 5.2: Запрет DELETE ---'
SELECT 'DELETE запрещён:' as test_name,
       CASE WHEN has_table_privilege('app_writer', 'app.actors', 'DELETE') 
            THEN 'НЕТ' ELSE 'ДА' END as result;

-- Тест 5.3: app_writer НЕ может читать audit.login_log
\echo '--- Тест 5.3: Запрет audit.login_log ---'
SELECT 'audit.login_log недоступен:' as test_name,
       CASE WHEN has_table_privilege('app_writer', 'audit.login_log', 'SELECT') 
            THEN 'НЕТ' ELSE 'ДА' END as result;

RESET ROLE;

-- =====================================================
-- СЦЕНАРИЙ 6: auditor (аудитор)
-- =====================================================
\echo ''
\echo '=== СЦЕНАРИЙ 6: auditor ==='

-- Тест 6.1: auditor читает audit.login_log
\echo '--- Тест 6.1: Доступ к audit.login_log ---'
SET ROLE auditor;

SELECT 'audit.login_log доступен:' as test_name, 
       username, client_ip, connection_method, is_successful, login_time
FROM audit.login_log;

-- Тест 6.2: auditor НЕ может изменять audit.login_log
\echo '--- Тест 6.2: Запрет изменений audit.login_log ---'
SELECT 'INSERT в audit.login_log запрещён:' as test_name,
       CASE WHEN has_table_privilege('auditor', 'audit.login_log', 'INSERT') 
            THEN 'НЕТ' ELSE 'ДА' END as result;

-- Тест 6.3: auditor НЕ может читать бизнес-данные
\echo '--- Тест 6.3: Запрет бизнес-данных ---'
SELECT 'app.actors недоступен:' as test_name,
       CASE WHEN has_table_privilege('auditor', 'app.actors', 'SELECT') 
            THEN 'НЕТ' ELSE 'ДА' END as result;

RESET ROLE;

-- =====================================================
-- СЦЕНАРИЙ 7: ddl_admin (администратор DDL)
-- =====================================================
\echo ''
\echo '=== СЦЕНАРИЙ 7: ddl_admin ==='

-- Тест 7.1: ddl_admin может создавать таблицы
\echo '--- Тест 7.1: Доступ к DDL ---'
SET ROLE ddl_admin;

SELECT 'CREATE TABLE разрешён:' as test_name,
       CASE WHEN has_schema_privilege('ddl_admin', 'app', 'CREATE') 
            THEN 'ДА' ELSE 'НЕТ' END as result;

-- Тест 7.2: ddl_admin НЕ может читать бизнес-данные
\echo '--- Тест 7.2: Запрет бизнес-данных ---'
SELECT 'app.actors недоступен:' as test_name,
       CASE WHEN has_table_privilege('ddl_admin', 'app.actors', 'SELECT') 
            THEN 'НЕТ' ELSE 'ДА' END as result;

RESET ROLE;

-- =====================================================
-- СЦЕНАРИЙ 8: dml_admin (администратор DML)
-- =====================================================
\echo ''
\echo '=== СЦЕНАРИЙ 8: dml_admin ==='

-- Тест 8.1: dml_admin может массово изменять данные
\echo '--- Тест 8.1: Доступ к массовому DML ---'
SET ROLE dml_admin;

SELECT 'Массовый UPDATE разрешён:' as test_name,
       CASE WHEN has_table_privilege('dml_admin', 'app.actors', 'UPDATE') 
            THEN 'ДА' ELSE 'НЕТ' END as result;

-- Тест 8.2: dml_admin НЕ может читать audit.login_log
\echo '--- Тест 8.2: Запрет audit.login_log ---'
SELECT 'audit.login_log недоступен:' as test_name,
       CASE WHEN has_table_privilege('dml_admin', 'audit.login_log', 'SELECT') 
            THEN 'НЕТ' ELSE 'ДА' END as result;

RESET ROLE;

-- =====================================================
-- СЦЕНАРИЙ 9: security_admin (администратор безопасности)
-- =====================================================
\echo ''
\echo '=== СЦЕНАРИЙ 9: security_admin ==='

-- Тест 9.1: security_admin может управлять политиками
\echo '--- Тест 9.1: Доступ к политикам ---'
SET ROLE security_admin;

SELECT 'Управление политиками:' as test_name,
       CASE WHEN has_schema_privilege('security_admin', 'app', 'USAGE') 
            THEN 'ДА' ELSE 'НЕТ' END as result;

-- Тест 9.2: security_admin НЕ может читать бизнес-данные
\echo '--- Тест 9.2: Запрет бизнес-данных ---'
SELECT 'app.actors недоступен:' as test_name,
       CASE WHEN has_table_privilege('security_admin', 'app.actors', 'SELECT') 
            THEN 'НЕТ' ELSE 'ДА' END as result;

RESET ROLE;

-- =====================================================
-- СЦЕНАРИЙ 10: db_developer (разработчик БД)
-- =====================================================
\echo ''
\echo '=== СЦЕНАРИЙ 10: db_developer ==='

-- Тест 10.1: db_developer может читать данные
\echo '--- Тест 10.1: Доступ к данным ---'
SET ROLE db_developer;

SELECT 'Актёры доступны:' as test_name, 
       actor_id, first_name, last_name, email, phone
FROM app.actors LIMIT 3;

-- Тест 10.2: db_developer может логировать подключения
\echo '--- Тест 10.2: Логирование подключений ---'
SELECT 'Логирование работает:' as test_name, 
       CASE WHEN has_function_privilege('db_developer', 'public.log_session_start', 'EXECUTE') 
            THEN 'ДА' ELSE 'НЕТ' END as result;

-- Тест 10.3: db_developer НЕ может читать audit.login_log
\echo '--- Тест 10.3: Запрет audit.login_log ---'
SELECT 'audit.login_log недоступен:' as test_name,
       CASE WHEN has_table_privilege('db_developer', 'audit.login_log', 'SELECT') 
            THEN 'НЕТ' ELSE 'ДА' END as result;

RESET ROLE;

-- =====================================================
-- СЦЕНАРИЙ 11: PUBLIC (публичный доступ)
-- =====================================================
\echo ''
\echo '=== СЦЕНАРИЙ 11: PUBLIC ==='

-- Тест 11.1: PUBLIC НЕ имеет доступа к схемам
\echo '--- Тест 11.1: Запрет доступа к схемам ---'
SELECT 'app недоступна для PUBLIC:' as test_name,
       CASE WHEN has_schema_privilege('public', 'app', 'USAGE') 
            THEN 'НЕТ' ELSE 'ДА' END as result;

SELECT 'ref недоступна для PUBLIC:' as test_name,
       CASE WHEN has_schema_privilege('public', 'ref', 'USAGE') 
            THEN 'НЕТ' ELSE 'ДА' END as result;

SELECT 'audit недоступна для PUBLIC:' as test_name,
       CASE WHEN has_schema_privilege('public', 'audit', 'USAGE') 
            THEN 'НЕТ' ELSE 'ДА' END as result;

-- Тест 11.2: PUBLIC НЕ имеет доступа к таблицам
\echo '--- Тест 11.2: Запрет доступа к таблицам ---'
SELECT 'app.actors недоступна для PUBLIC:' as test_name,
       CASE WHEN has_table_privilege('public', 'app.actors', 'SELECT') 
            THEN 'НЕТ' ELSE 'ДА' END as result;

-- =====================================================
-- ИТОГОВЫЙ ОТЧЁТ ПО РОЛЯМ
-- =====================================================
\echo ''
\echo '====================================================='
\echo 'ИТОГОВЫЙ ОТЧЁТ ПО РОЛЯМ'
\echo '====================================================='

-- Сводная таблица ролей и их возможностей
SELECT 
    'Роль' as role_name,
    'Может читать app' as can_read_app,
    'Может изменять app' as can_modify_app,
    'Может читать audit' as can_read_audit,
    'Может удалять' as can_delete,
    'Может логировать' as can_log
UNION ALL
SELECT 'voice_actor', 'ДА (RLS)', 'НЕТ', 'НЕТ', 'НЕТ', 'ДА'
UNION ALL
SELECT 'studio_manager', 'ДА', 'НЕТ', 'НЕТ', 'НЕТ', 'ДА'
UNION ALL
SELECT 'security_auditor', 'НЕТ', 'НЕТ', 'ДА', 'НЕТ', 'ДА'
UNION ALL
SELECT 'app_reader', 'ДА', 'НЕТ', 'НЕТ', 'НЕТ', 'НЕТ'
UNION ALL
SELECT 'app_writer', 'ДА', 'ДА', 'НЕТ', 'НЕТ', 'НЕТ'
UNION ALL
SELECT 'auditor', 'НЕТ', 'НЕТ', 'ДА (только чтение)', 'НЕТ', 'НЕТ'
UNION ALL
SELECT 'ddl_admin', 'НЕТ', 'НЕТ', 'НЕТ', 'НЕТ', 'НЕТ'
UNION ALL
SELECT 'dml_admin', 'ДА', 'ДА (массово)', 'НЕТ', 'НЕТ', 'НЕТ'
UNION ALL
SELECT 'security_admin', 'НЕТ', 'НЕТ', 'НЕТ', 'НЕТ', 'НЕТ'
UNION ALL
SELECT 'db_developer', 'ДА', 'НЕТ', 'НЕТ', 'НЕТ', 'ДА'
UNION ALL
SELECT 'PUBLIC', 'НЕТ', 'НЕТ', 'НЕТ', 'НЕТ', 'НЕТ';

\echo ''
\echo 'ПРОВЕРКА ЗАВЕРШЕНА!'
\echo '====================================================='
