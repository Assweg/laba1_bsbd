# База данных студии дубляжа · роли и доступ

![Стек](https://img.shields.io/badge/PostgreSQL%20%C2%B7%20PL%2FpgSQL%20%C2%B7%20Docker-334155?style=flat-square) ![Семестр](https://img.shields.io/badge/семестр-5-0f766e?style=flat-square) ![Статус](https://img.shields.io/badge/статус-%D0%A3%D1%87%D0%B5%D0%B1%D0%BD%D1%8B%D0%B9%20%D0%BF%D1%80%D0%BE%D0%B5%D0%BA%D1%82-64748b?style=flat-square)

Учебная работа по безопасности PostgreSQL на примере студии дубляжа.

## Предметная область

Актёры, проекты, контракты, сессии записи и аудиоархив. Схемы `app`, `ref`, `audit`, `stg` отделяют бизнес-данные, справочники, аудит и служебные объекты.

## Темы лабораторной

- Роли и распределение привилегий.
- Политики Row Level Security.
- Аудит входов и изменений данных.
- Демонстрационные данные и сценарии проверки ролей.

## Запуск

Нужны Docker, Compose и Bash. Скрипт `run_docker.sh` использует команду `docker-compose`; если установлен только Compose v2, используйте прямой запуск:

```bash
docker compose up --build -d
```

Скрипт управления также поддерживает команды:

```bash
bash run_docker.sh start
bash run_docker.sh connect
bash run_docker.sh test-roles
bash run_docker.sh stop
```

## Карта файлов

- [00_init_all.sql](00_init_all.sql) — общий вход в инициализацию базы.
- [script1.sql](script1.sql) … [script11.sql](script11.sql) — базовые этапы схемы, ролей и политик.
- [role_testing_scenarios.sql](role_testing_scenarios.sql) — сценарии работы от разных ролей.
- [test.sql](test.sql) — проверки БД.
- [docker-compose.yml](docker-compose.yml), [Dockerfile](Dockerfile) — окружение.

## Примечания к стенду

Роли, пароли и данные в SQL/Compose являются частью учебного стенда. Запуск и тесты БД при публикации не выполнялись. Учётные данные и настройки для внешней среды нужно задать отдельно.

## Продолжение курса

[Первый семестр курса](https://github.com/Assweg/nstu/tree/main/5sem/%D0%91%D0%A1%D0%91%D0%94) · [Продолжение в шестом семестре](https://github.com/Assweg/nstu/tree/main/6sem/%D0%91%D0%A1%D0%91%D0%94).

---

[Все учебные работы](https://github.com/Assweg/nstu) · [Профиль Assweg](https://github.com/Assweg)
