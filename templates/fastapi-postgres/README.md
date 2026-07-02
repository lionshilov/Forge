# FastAPI + Postgres Template

An async FastAPI + SQLAlchemy 2.0 + Postgres starter. Typed settings, health checks, tests, Docker — ready for a backend agent to build on.

## What's included
- FastAPI with an app factory (`create_app`) — testable, no import-time side effects beyond config
- SQLAlchemy 2.0 async engine + `Base` for ORM models + `get_session` dependency
- `pydantic-settings` typed config from `.env` (never hardcode)
- Postgres 16 via `docker-compose.yml` (with healthcheck)
- `Dockerfile` for the API itself
- pytest + httpx test setup with a passing example test
- ruff configured (lint + import sorting)

## Setup

```bash
# 1. Start Postgres
docker compose up -d db

# 2. Install (uv recommended)
uv sync --extra dev
# or: python -m venv .venv && .venv/bin/pip install -e ".[dev]"

# 3. Copy env
cp .env.example .env

# 4. Run
uv run uvicorn app.main:app --reload

# 5. Test
uv run pytest
```

Open http://localhost:8000/docs for the interactive API docs.
`GET /health` is liveness; `GET /health/db` also pings Postgres.

## Deploy

- **Any container host** (Fly.io, Railway, Render, ECS…): build the `Dockerfile`, set `DATABASE_URL` to your managed Postgres.
- Add migrations before your first real model — Alembic drops in cleanly next to `app/db.py` (`Base.metadata` is the target).

## File tree
```
.
├── app/
│   ├── main.py               # App factory + router registration
│   ├── config.py             # Typed settings from .env (pydantic-settings)
│   ├── db.py                 # Async engine, Base, get_session dependency
│   └── routers/
│       └── health.py         # /health (liveness) + /health/db (Postgres ping)
├── tests/
│   └── test_health.py        # Example test — no DB required
├── .env.example
├── docker-compose.yml        # Postgres 16 with healthcheck
├── Dockerfile
└── pyproject.toml            # deps + ruff + pytest config
```

## Conventions (override via project_context/CONVENTIONS.md)
- One router file per resource under `app/routers/`, registered in `create_app`.
- All I/O is async; use the `get_session` dependency, never create ad-hoc engines.
- Config only via `Settings` — no `os.environ` reads scattered through code.
- Every endpoint validates input with Pydantic models; no raw dict payloads.
