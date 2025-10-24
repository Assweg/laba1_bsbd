-- 04_roles.sql
-- Создание системы ролей с разделением обязанностей

-- Базовые роли доступа (с проверкой существования)

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_reader') THEN
        CREATE ROLE app_reader WITH NOLOGIN NOINHERIT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_writer') THEN
        CREATE ROLE app_writer WITH NOLOGIN NOINHERIT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'auditor') THEN
        CREATE ROLE auditor WITH NOLOGIN NOINHERIT;
    END IF;
END $$;

-- Роли разделения обязанностей (с проверкой существования)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ddl_admin') THEN
        CREATE ROLE ddl_admin WITH NOLOGIN NOINHERIT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'dml_admin') THEN
        CREATE ROLE dml_admin WITH NOLOGIN NOINHERIT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'security_admin') THEN
        CREATE ROLE security_admin WITH NOLOGIN NOINHERIT;
    END IF;
END $$;

-- Логин-роли (пользователи)
DO $$ 
BEGIN
    -- Удаляем существующих пользователей если нужно пересоздать
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'studio_manager') THEN
        RAISE NOTICE 'Роль studio_manager уже существует, переиспользуем';
    ELSE
        CREATE ROLE studio_manager WITH LOGIN PASSWORD 'manager_pass123' NOINHERIT;
    END IF;
    
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'voice_actor') THEN
        RAISE NOTICE 'Роль voice_actor уже существует, переиспользуем';
    ELSE
        CREATE ROLE voice_actor WITH LOGIN PASSWORD 'actor_pass123' NOINHERIT;
    END IF;
    
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'security_auditor') THEN
        RAISE NOTICE 'Роль security_auditor уже существует, переиспользуем';
    ELSE
        CREATE ROLE security_auditor WITH LOGIN PASSWORD 'auditor_pass123' NOINHERIT;
    END IF;
    
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'db_developer') THEN
        RAISE NOTICE 'Роль db_developer уже существует, переиспользуем';
    ELSE
        CREATE ROLE db_developer WITH LOGIN PASSWORD 'dev_pass123' NOINHERIT;
    END IF;
END $$;

-- Комментарии к ролям (обновляем если изменились)
COMMENT ON ROLE app_owner IS 'Владелец приложения: полный доступ к бизнес-данным';
COMMENT ON ROLE app_reader IS 'Чтение бизнес-данных: просмотр проектов, контрактов';
COMMENT ON ROLE app_writer IS 'Запись бизнес-данных: добавление/изменение контрактов, сессий';
COMMENT ON ROLE auditor IS 'Аудитор: доступ к логам безопасности только на чтение';
COMMENT ON ROLE ddl_admin IS 'Администратор DDL: создание/изменение таблиц, индексов';
COMMENT ON ROLE dml_admin IS 'Администратор DML: массовые операции INSERT/UPDATE/DELETE';
COMMENT ON ROLE security_admin IS 'Администратор безопасности: RLS, политики, шифрование';
COMMENT ON ROLE studio_manager IS 'Менеджер студии: работает с контрактами и расписаниями';
COMMENT ON ROLE voice_actor IS 'Актёр: просматривает свои сессии и роли';
COMMENT ON ROLE security_auditor IS 'Аудитор безопасности: проверяет логи доступа';
COMMENT ON ROLE db_developer IS 'Разработчик БД: изменяет структуру базы данных';

-- Назначаем роли пользователям
GRANT app_writer TO studio_manager;
GRANT app_reader TO voice_actor;
GRANT auditor TO security_auditor;
GRANT ddl_admin TO db_developer;

-- Отзываем все привилегии у PUBLIC
REVOKE ALL ON DATABASE postgres FROM PUBLIC;

-- Уведомление о завершении
DO $$ 
BEGIN
    RAISE NOTICE 'Роли успешно созданы/обновлены';
    RAISE NOTICE 'Логин-роли: studio_manager, voice_actor, security_auditor, db_developer';
    RAISE NOTICE 'Пароли: manager_pass123, actor_pass123, auditor_pass123, dev_pass123';
END $$;