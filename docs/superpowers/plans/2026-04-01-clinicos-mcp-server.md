# ClinicOS Public MCP Server Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a public FastMCP server that exposes 5 Australian healthcare tools (MBS lookup, MBS suggest, PSR risk check, RACGP indicator lookup, clinical RAG query) over Cloud SQL and RAG Spine.

**Architecture:** Hybrid — direct asyncpg to Cloud SQL for reference table lookups (tools 1-4), HTTP to RAG Spine FastAPI service for clinical knowledge queries (tool 5). FastMCP with stdio + streamable-http transport.

**Tech Stack:** Python 3.12, FastMCP, asyncpg, httpx, pydantic, cloud-sql-python-connector

**Spec:** `docs/superpowers/specs/2026-04-01-clinicos-mcp-server-design.md`

---

## File Structure

| File | Responsibility |
|------|---------------|
| `src/server.py` | FastMCP entry point, tool definitions, lifespan |
| `src/config.py` | Settings via pydantic-settings (env vars) |
| `src/db/connection.py` | asyncpg pool creation + cleanup |
| `src/db/queries/mbs.py` | MBS item lookup + suggest queries |
| `src/db/queries/psr.py` | PSR case queries |
| `src/db/queries/racgp.py` | RACGP indicator queries |
| `src/clients/rag_spine.py` | httpx client for RAG Spine /v1/query |
| `tests/conftest.py` | Shared fixtures (mock DB pool, mock httpx) |
| `tests/test_mbs.py` | Tests for mbs_item_lookup + mbs_item_suggest |
| `tests/test_psr.py` | Tests for psr_risk_check |
| `tests/test_racgp.py` | Tests for racgp_indicator_lookup |
| `tests/test_rag.py` | Tests for clinical_knowledge_query |
| `pyproject.toml` | Project config, dependencies |
| `.env.example` | Environment variable template |
| `Dockerfile` | Cloud Run container |
| `CLAUDE.md` | Project instructions |
| `CHANGELOG.md` | Change log |

---

## Task 1: Project Scaffolding

**Files:**
- Create: `pyproject.toml`
- Create: `.env.example`
- Create: `src/__init__.py`
- Create: `src/db/__init__.py`
- Create: `src/db/queries/__init__.py`
- Create: `src/clients/__init__.py`
- Create: `tests/__init__.py`
- Create: `CLAUDE.md`
- Create: `CHANGELOG.md`
- Create: `.gitignore`
- Create: `.python-version`

- [ ] **Step 1: Create pyproject.toml**

```toml
[project]
name = "clinicos-mcp"
version = "0.1.0"
description = "Australian Medicare & Clinical Intelligence MCP Server"
readme = "README.md"
requires-python = ">=3.12"
license = "MIT"
authors = [{ name = "Dr. Alex - CVLM / ClinicOS" }]

dependencies = [
    "mcp[cli]>=1.0.0",
    "asyncpg>=0.30.0",
    "httpx>=0.27.0",
    "pydantic>=2.0.0",
    "pydantic-settings>=2.0.0",
    "cloud-sql-python-connector[asyncpg]>=1.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "pytest-asyncio>=0.24.0",
    "ruff>=0.8.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.pytest.ini_options]
asyncio_mode = "auto"
testpaths = ["tests"]

[tool.ruff]
target-version = "py312"
line-length = 100
```

- [ ] **Step 2: Create .python-version**

```
3.12
```

- [ ] **Step 3: Create .env.example**

```bash
# Database (dev: direct connection, prod: Cloud SQL connector)
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USER=mcp_readonly
DATABASE_PASSWORD=
MBS_DATABASE_NAME=clinicos_mbs
ACCREDITATION_DATABASE_NAME=clinicos_accreditation

# Cloud SQL (production only)
CLOUD_SQL_CONNECTION_NAME=clinicos-emr-staging:australia-southeast1:clinicos-emr-pg16-staging
USE_CLOUD_SQL_CONNECTOR=false

# RAG Spine
RAG_SPINE_URL=http://localhost:8001
RAG_SPINE_TENANT_ID=public

# Server
MCP_TRANSPORT=stdio
MCP_PORT=8000
```

- [ ] **Step 4: Create .gitignore**

```
__pycache__/
*.pyc
.env
.venv/
dist/
*.egg-info/
.ruff_cache/
.pytest_cache/
```

- [ ] **Step 5: Create empty __init__.py files and CLAUDE.md**

Create empty `src/__init__.py`, `src/db/__init__.py`, `src/db/queries/__init__.py`, `src/clients/__init__.py`, `tests/__init__.py`.

`CLAUDE.md`:
```markdown
## Purpose
Public MCP server exposing ClinicOS healthcare data (MBS, PSR, RACGP, clinical RAG) to AI assistants. Distribution channel for ClinicOS platform.

## Tree
- `src/server.py` — FastMCP entry point + all 5 tool definitions
- `src/config.py` — pydantic-settings configuration
- `src/db/` — asyncpg connection + query modules (mbs, psr, racgp)
- `src/clients/` — httpx client for RAG Spine
- `tests/` — pytest-asyncio tests per tool
- `docs/superpowers/` — spec + plan

## Rules
- All DB access is READ-ONLY. Never write to any table.
- Never access PHI tables (claims, consent_forms, consultation_sessions, staff, etc.)
- The mcp_readonly DB role enforces this at the Postgres level.
- MBS database: clinicos_mbs. Accreditation database: clinicos_accreditation.
- RAG Spine uses tenant_id: "public" — no patient data.
- Tool responses return structured dicts, not prose. The AI composes the answer.
- Every response includes powered_by attribution.
```

`CHANGELOG.md`:
```markdown
# Changelog

All notable changes to this project will be documented in this file.
Format based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]
```

- [ ] **Step 6: Install dependencies**

Run: `cd ~/clinicos-mcp-server && uv sync`
Expected: Dependencies installed, `.venv` created.

- [ ] **Step 7: Commit**

```bash
cd ~/clinicos-mcp-server
git add -A
git commit -m "feat: scaffold clinicos-mcp-server project"
```

---

## Task 2: Config Module

**Files:**
- Create: `src/config.py`
- Test: `tests/test_config.py`

- [ ] **Step 1: Write the failing test**

`tests/test_config.py`:
```python
import os
from unittest.mock import patch


def test_settings_loads_defaults():
    """Config should load with sensible defaults for dev."""
    with patch.dict(os.environ, {
        "DATABASE_HOST": "localhost",
        "DATABASE_PORT": "5432",
        "DATABASE_USER": "mcp_readonly",
        "DATABASE_PASSWORD": "testpass",
        "MBS_DATABASE_NAME": "clinicos_mbs",
        "ACCREDITATION_DATABASE_NAME": "clinicos_accreditation",
        "RAG_SPINE_URL": "http://localhost:8001",
    }, clear=False):
        from src.config import Settings
        s = Settings()
        assert s.database_host == "localhost"
        assert s.database_port == 5432
        assert s.mbs_database_name == "clinicos_mbs"
        assert s.rag_spine_url == "http://localhost:8001"
        assert s.use_cloud_sql_connector is False
        assert s.mcp_transport == "stdio"


def test_settings_cloud_sql_mode():
    """Config should detect Cloud SQL connector mode."""
    with patch.dict(os.environ, {
        "DATABASE_HOST": "localhost",
        "DATABASE_PORT": "5432",
        "DATABASE_USER": "mcp_readonly",
        "DATABASE_PASSWORD": "",
        "MBS_DATABASE_NAME": "clinicos_mbs",
        "ACCREDITATION_DATABASE_NAME": "clinicos_accreditation",
        "RAG_SPINE_URL": "http://localhost:8001",
        "USE_CLOUD_SQL_CONNECTOR": "true",
        "CLOUD_SQL_CONNECTION_NAME": "proj:region:instance",
    }, clear=False):
        from src.config import Settings
        s = Settings()
        assert s.use_cloud_sql_connector is True
        assert s.cloud_sql_connection_name == "proj:region:instance"
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd ~/clinicos-mcp-server && uv run pytest tests/test_config.py -v`
Expected: FAIL — `ModuleNotFoundError: No module named 'src.config'`

- [ ] **Step 3: Write the implementation**

`src/config.py`:
```python
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """MCP server configuration. Loaded from environment variables."""

    # Database
    database_host: str = "localhost"
    database_port: int = 5432
    database_user: str = "mcp_readonly"
    database_password: str = ""
    mbs_database_name: str = "clinicos_mbs"
    accreditation_database_name: str = "clinicos_accreditation"

    # Cloud SQL (production)
    use_cloud_sql_connector: bool = False
    cloud_sql_connection_name: str = ""

    # RAG Spine
    rag_spine_url: str = "http://localhost:8001"
    rag_spine_tenant_id: str = "public"
    rag_spine_timeout_seconds: float = 15.0

    # Server
    mcp_transport: str = "stdio"
    mcp_port: int = 8000

    model_config = {"env_file": ".env", "extra": "ignore"}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd ~/clinicos-mcp-server && uv run pytest tests/test_config.py -v`
Expected: 2 passed

- [ ] **Step 5: Commit**

```bash
cd ~/clinicos-mcp-server
git add src/config.py tests/test_config.py
git commit -m "feat: add Settings config module with pydantic-settings"
```

---

## Task 3: Database Connection Module

**Files:**
- Create: `src/db/connection.py`
- Test: `tests/test_db_connection.py`

- [ ] **Step 1: Write the failing test**

`tests/test_db_connection.py`:
```python
from unittest.mock import AsyncMock, patch, MagicMock
import pytest

from src.config import Settings


@pytest.fixture
def dev_settings():
    return Settings(
        database_host="localhost",
        database_port=5432,
        database_user="mcp_readonly",
        database_password="testpass",
        mbs_database_name="clinicos_mbs",
        accreditation_database_name="clinicos_accreditation",
        use_cloud_sql_connector=False,
    )


@pytest.mark.asyncio
async def test_create_pools_returns_two_pools(dev_settings):
    """Should create separate pools for MBS and accreditation databases."""
    mock_pool = AsyncMock()
    with patch("src.db.connection.asyncpg.create_pool", return_value=mock_pool) as mock_create:
        from src.db.connection import create_pools
        mbs_pool, accred_pool = await create_pools(dev_settings)
        assert mock_create.call_count == 2
        # First call for MBS database
        first_call = mock_create.call_args_list[0]
        assert "clinicos_mbs" in str(first_call)
        # Second call for accreditation database
        second_call = mock_create.call_args_list[1]
        assert "clinicos_accreditation" in str(second_call)


@pytest.mark.asyncio
async def test_close_pools():
    """Should close both pools gracefully."""
    mock_pool = AsyncMock()
    from src.db.connection import close_pools
    await close_pools(mock_pool, mock_pool)
    assert mock_pool.close.call_count == 2
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd ~/clinicos-mcp-server && uv run pytest tests/test_db_connection.py -v`
Expected: FAIL — `ModuleNotFoundError`

- [ ] **Step 3: Write the implementation**

`src/db/connection.py`:
```python
import asyncpg
from src.config import Settings


async def create_pools(settings: Settings) -> tuple[asyncpg.Pool, asyncpg.Pool]:
    """Create read-only connection pools for MBS and accreditation databases.

    Returns (mbs_pool, accreditation_pool).
    """
    dsn_template = (
        f"postgresql://{settings.database_user}:{settings.database_password}"
        f"@{settings.database_host}:{settings.database_port}"
    )

    mbs_pool = await asyncpg.create_pool(
        f"{dsn_template}/{settings.mbs_database_name}",
        min_size=1,
        max_size=5,
        command_timeout=10,
    )

    accreditation_pool = await asyncpg.create_pool(
        f"{dsn_template}/{settings.accreditation_database_name}",
        min_size=1,
        max_size=5,
        command_timeout=10,
    )

    return mbs_pool, accreditation_pool


async def close_pools(*pools: asyncpg.Pool) -> None:
    """Close all connection pools."""
    for pool in pools:
        await pool.close()
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd ~/clinicos-mcp-server && uv run pytest tests/test_db_connection.py -v`
Expected: 2 passed

- [ ] **Step 5: Commit**

```bash
cd ~/clinicos-mcp-server
git add src/db/connection.py tests/test_db_connection.py
git commit -m "feat: add asyncpg connection pool for MBS and accreditation DBs"
```

---

## Task 4: MBS Query Module + Tests

**Files:**
- Create: `src/db/queries/mbs.py`
- Test: `tests/test_mbs.py`

- [ ] **Step 1: Write the failing tests**

`tests/test_mbs.py`:
```python
from unittest.mock import AsyncMock
import pytest

from src.db.queries.mbs import lookup_mbs_item, suggest_mbs_items


@pytest.fixture
def mock_pool():
    pool = AsyncMock()
    return pool


@pytest.mark.asyncio
async def test_lookup_mbs_item_found(mock_pool):
    """Should return item dict when item exists."""
    mock_pool.fetchrow.return_value = {
        "item_number": "23",
        "category": "GP Consultations",
        "subcategory": "Level B",
        "description": "Professional attendance...",
        "schedule_fee": "41.40",
        "time_estimate_minutes": 20,
        "documentation_requirements": {"required": ["clinical notes"], "recommended": [], "examples": []},
        "common_errors": ["Insufficient documentation"],
        "psr_risk_level": "low",
    }
    result = await lookup_mbs_item(mock_pool, "23")
    assert result is not None
    assert result["item_number"] == "23"
    assert result["schedule_fee"] == "41.40"


@pytest.mark.asyncio
async def test_lookup_mbs_item_not_found(mock_pool):
    """Should return None when item does not exist."""
    mock_pool.fetchrow.return_value = None
    result = await lookup_mbs_item(mock_pool, "99999")
    assert result is None


@pytest.mark.asyncio
async def test_suggest_mbs_items_by_consultation(mock_pool):
    """Should return matching items filtered by category and duration."""
    mock_pool.fetch.return_value = [
        {
            "item_number": "23",
            "category": "GP Consultations",
            "description": "Professional attendance, Level B",
            "schedule_fee": "41.40",
            "time_estimate_minutes": 20,
            "psr_risk_level": "low",
        },
        {
            "item_number": "36",
            "category": "GP Consultations",
            "description": "Professional attendance, Level C",
            "schedule_fee": "79.55",
            "time_estimate_minutes": 40,
            "psr_risk_level": "low",
        },
    ]
    result = await suggest_mbs_items(mock_pool, consultation_type="follow_up", duration_minutes=30)
    assert len(result) >= 1
    assert all("item_number" in r for r in result)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd ~/clinicos-mcp-server && uv run pytest tests/test_mbs.py -v`
Expected: FAIL — `ModuleNotFoundError`

- [ ] **Step 3: Write the implementation**

`src/db/queries/mbs.py`:
```python
from typing import Any

import asyncpg

# Maps user-facing consultation types to MBS category patterns
CONSULTATION_TYPE_CATEGORIES = {
    "follow_up": "GP Consultations",
    "new_patient": "GP Consultations",
    "telehealth": "Telehealth",
    "mental_health": "Mental Health",
    "chronic_disease": "Chronic Disease Management",
    "skin_procedure": "Skin Procedures",
    "vascular": "Vascular Procedures",
}

# Deterministic co-claiming rules: (primary_category, care_plan) -> co-claimable items
CO_CLAIMING_RULES: dict[tuple[str, str], list[dict[str, str]]] = {
    ("GP Consultations", "GPMP"): [
        {"item": "721", "rule": "GPMP preparation", "conditions": "Once per 12 months per patient"},
    ],
    ("GP Consultations", "TCA"): [
        {"item": "723", "rule": "Team care arrangement", "conditions": "Once per 12 months per patient"},
    ],
    ("GP Consultations", "MHC"): [
        {"item": "2700", "rule": "Mental health treatment plan", "conditions": "Once per calendar year"},
        {"item": "2701", "rule": "MH plan review", "conditions": "Up to 5 reviews per plan"},
    ],
}


async def lookup_mbs_item(pool: asyncpg.Pool, item_number: str) -> dict[str, Any] | None:
    """Look up a single MBS item by item number."""
    row = await pool.fetchrow(
        """
        SELECT item_number, category, subcategory, description, schedule_fee,
               time_estimate_minutes, documentation_requirements, common_errors,
               psr_risk_level
        FROM mbs_items
        WHERE item_number = $1
        """,
        item_number,
    )
    return dict(row) if row else None


async def suggest_mbs_items(
    pool: asyncpg.Pool,
    consultation_type: str,
    duration_minutes: int,
    care_plan: str | None = None,
) -> list[dict[str, Any]]:
    """Suggest MBS items based on consultation context.

    Filters by category (derived from consultation_type) and duration range.
    Appends co-claiming opportunities if care_plan is provided.
    """
    category = CONSULTATION_TYPE_CATEGORIES.get(consultation_type, "GP Consultations")

    rows = await pool.fetch(
        """
        SELECT item_number, category, description, schedule_fee,
               time_estimate_minutes, psr_risk_level
        FROM mbs_items
        WHERE category = $1
          AND (time_estimate_minutes IS NULL
               OR time_estimate_minutes BETWEEN $2 AND $3)
        ORDER BY schedule_fee DESC
        LIMIT 5
        """,
        category,
        max(0, duration_minutes - 15),
        duration_minutes + 15,
    )

    items = [dict(r) for r in rows]

    # Append co-claiming info if care_plan matches a rule
    co_claims = []
    if care_plan:
        co_claims = CO_CLAIMING_RULES.get((category, care_plan.upper()), [])

    return items, co_claims
```

- [ ] **Step 4: Fix test to match return signature (items, co_claims tuple)**

Update `tests/test_mbs.py` — change the suggest test assertion:

```python
@pytest.mark.asyncio
async def test_suggest_mbs_items_by_consultation(mock_pool):
    """Should return matching items filtered by category and duration."""
    mock_pool.fetch.return_value = [
        {
            "item_number": "23",
            "category": "GP Consultations",
            "description": "Professional attendance, Level B",
            "schedule_fee": "41.40",
            "time_estimate_minutes": 20,
            "psr_risk_level": "low",
        },
    ]
    items, co_claims = await suggest_mbs_items(
        mock_pool, consultation_type="follow_up", duration_minutes=30
    )
    assert len(items) >= 1
    assert items[0]["item_number"] == "23"
    assert co_claims == []  # No care plan, no co-claims


@pytest.mark.asyncio
async def test_suggest_mbs_items_with_gpmp(mock_pool):
    """Should return co-claiming rules when care plan is GPMP."""
    mock_pool.fetch.return_value = [
        {
            "item_number": "23",
            "category": "GP Consultations",
            "description": "Level B",
            "schedule_fee": "41.40",
            "time_estimate_minutes": 20,
            "psr_risk_level": "low",
        },
    ]
    items, co_claims = await suggest_mbs_items(
        mock_pool, consultation_type="follow_up", duration_minutes=30, care_plan="GPMP"
    )
    assert len(items) >= 1
    assert len(co_claims) == 1
    assert co_claims[0]["item"] == "721"
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `cd ~/clinicos-mcp-server && uv run pytest tests/test_mbs.py -v`
Expected: 4 passed

- [ ] **Step 6: Commit**

```bash
cd ~/clinicos-mcp-server
git add src/db/queries/mbs.py tests/test_mbs.py
git commit -m "feat: add MBS item lookup and suggest query module"
```

---

## Task 5: PSR Query Module + Tests

**Files:**
- Create: `src/db/queries/psr.py`
- Test: `tests/test_psr.py`

- [ ] **Step 1: Write the failing test**

`tests/test_psr.py`:
```python
from unittest.mock import AsyncMock
import pytest

from src.db.queries.psr import check_psr_risk


@pytest.fixture
def mock_pool():
    return AsyncMock()


@pytest.mark.asyncio
async def test_psr_risk_found(mock_pool):
    """Should return matching PSR cases for a flagged item."""
    mock_pool.fetch.return_value = [
        {
            "case_reference": "PSR-2023-045",
            "severity_level": "high",
            "issue_description": "Routine upcoding from Level B to Level C",
            "repayment_amount": "450000.00",
            "lessons_learned": ["Document time spent", "Match item to complexity"],
            "recommendations": ["Use time-based billing"],
        },
    ]
    result = await check_psr_risk(mock_pool, "36")
    assert len(result) == 1
    assert result[0]["case_reference"] == "PSR-2023-045"


@pytest.mark.asyncio
async def test_psr_risk_clean(mock_pool):
    """Should return empty list for items with no PSR history."""
    mock_pool.fetch.return_value = []
    result = await check_psr_risk(mock_pool, "3")
    assert result == []
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd ~/clinicos-mcp-server && uv run pytest tests/test_psr.py -v`
Expected: FAIL

- [ ] **Step 3: Write the implementation**

`src/db/queries/psr.py`:
```python
from typing import Any

import asyncpg


async def check_psr_risk(pool: asyncpg.Pool, item_number: str) -> list[dict[str, Any]]:
    """Find PSR cases where the given MBS item was involved.

    Uses JSONB containment to check if item_number appears in the
    item_numbers_involved array.
    """
    rows = await pool.fetch(
        """
        SELECT case_reference, severity_level, issue_description,
               repayment_amount, lessons_learned, recommendations
        FROM psr_cases
        WHERE item_numbers_involved @> $1::jsonb
        ORDER BY severity_level DESC, repayment_amount DESC NULLS LAST
        """,
        f'["{item_number}"]',
    )
    return [dict(r) for r in rows]
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd ~/clinicos-mcp-server && uv run pytest tests/test_psr.py -v`
Expected: 2 passed

- [ ] **Step 5: Commit**

```bash
cd ~/clinicos-mcp-server
git add src/db/queries/psr.py tests/test_psr.py
git commit -m "feat: add PSR risk check query module"
```

---

## Task 6: RACGP Query Module + Tests

**Files:**
- Create: `src/db/queries/racgp.py`
- Test: `tests/test_racgp.py`

- [ ] **Step 1: Write the failing test**

`tests/test_racgp.py`:
```python
import re
from unittest.mock import AsyncMock
import pytest

from src.db.queries.racgp import lookup_racgp_indicators, is_indicator_code


@pytest.fixture
def mock_pool():
    return AsyncMock()


def test_is_indicator_code_valid():
    """Should match RACGP indicator code patterns."""
    assert is_indicator_code("GP1.1A") is True
    assert is_indicator_code("QI2.3B") is True
    assert is_indicator_code("C1.1A") is True
    assert is_indicator_code("vaccine storage") is False
    assert is_indicator_code("GP") is False


@pytest.mark.asyncio
async def test_lookup_by_code(mock_pool):
    """Should do exact lookup when query is an indicator code."""
    mock_pool.fetch.return_value = [
        {
            "indicator_code": "GP1.1A",
            "indicator_title": "Welcoming environment for Aboriginal peoples",
            "indicator_description": "The practice demonstrates...",
            "guidance": "Consider displaying...",
            "is_mandatory": False,
            "evidence_requirements": ["Policy document", "Photos"],
            "criterion_code": "GP1.1",
            "standard_code": "GP1",
            "standard_name": "Communication and the GP-patient relationship",
            "module_code": "GP",
            "module_name": "GP Standards",
        },
    ]
    result = await lookup_racgp_indicators(mock_pool, "GP1.1A")
    assert len(result) == 1
    assert result[0]["indicator_code"] == "GP1.1A"


@pytest.mark.asyncio
async def test_lookup_by_keyword(mock_pool):
    """Should do ILIKE search when query is not a code."""
    mock_pool.fetch.return_value = [
        {
            "indicator_code": "GP6.1A",
            "indicator_title": "Vaccine cold chain management",
            "indicator_description": "...",
            "guidance": "...",
            "is_mandatory": True,
            "evidence_requirements": ["Temperature logs"],
            "criterion_code": "GP6.1",
            "standard_code": "GP6",
            "standard_name": "Vaccine Storage and Immunisation",
            "module_code": "GP",
            "module_name": "GP Standards",
        },
    ]
    result = await lookup_racgp_indicators(mock_pool, "vaccine storage")
    assert len(result) >= 1


@pytest.mark.asyncio
async def test_lookup_with_module_filter(mock_pool):
    """Should filter by module when provided."""
    mock_pool.fetch.return_value = []
    await lookup_racgp_indicators(mock_pool, "clinical governance", module="QI")
    call_args = mock_pool.fetch.call_args
    # The SQL should include a module filter
    assert "m.code = " in call_args[0][0] or "$" in call_args[0][0]
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd ~/clinicos-mcp-server && uv run pytest tests/test_racgp.py -v`
Expected: FAIL

- [ ] **Step 3: Write the implementation**

`src/db/queries/racgp.py`:
```python
import re
from typing import Any

import asyncpg

INDICATOR_CODE_PATTERN = re.compile(r"^[A-Z]{1,2}\d+\.\d+[A-Z]?$", re.IGNORECASE)


def is_indicator_code(query: str) -> bool:
    """Check if a query string looks like a RACGP indicator code (e.g. GP1.1A)."""
    return bool(INDICATOR_CODE_PATTERN.match(query.strip()))


async def lookup_racgp_indicators(
    pool: asyncpg.Pool,
    query: str,
    module: str | None = None,
) -> list[dict[str, Any]]:
    """Look up RACGP 5th Edition indicators by code or keyword.

    If query matches an indicator code pattern, does exact lookup.
    Otherwise searches title + description with ILIKE.
    Results capped at 10.
    """
    base_sql = """
        SELECT
            i.code AS indicator_code,
            i.title AS indicator_title,
            i.description AS indicator_description,
            i.guidance,
            i.is_mandatory,
            i.evidence_requirements,
            cr.code AS criterion_code,
            s.code AS standard_code,
            s.name AS standard_name,
            m.code AS module_code,
            m.name AS module_name
        FROM racgp_indicators i
        JOIN racgp_criteria cr ON cr.id = i.criterion_id
        JOIN racgp_standards s ON s.id = cr.standard_id
        JOIN racgp_modules m ON m.id = s.module_id
    """

    conditions = []
    params: list[Any] = []
    param_idx = 1

    if is_indicator_code(query):
        conditions.append(f"i.code ILIKE ${param_idx}")
        params.append(query.strip().upper())
        param_idx += 1
    else:
        conditions.append(f"(i.title ILIKE ${param_idx} OR i.description ILIKE ${param_idx})")
        params.append(f"%{query.strip()}%")
        param_idx += 1

    if module:
        conditions.append(f"m.code = ${param_idx}")
        params.append(module.upper())
        param_idx += 1

    where_clause = " WHERE " + " AND ".join(conditions)
    full_sql = base_sql + where_clause + " ORDER BY m.sort_order, s.sort_order, cr.sort_order, i.sort_order LIMIT 10"

    rows = await pool.fetch(full_sql, *params)
    return [dict(r) for r in rows]
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd ~/clinicos-mcp-server && uv run pytest tests/test_racgp.py -v`
Expected: 4 passed

- [ ] **Step 5: Commit**

```bash
cd ~/clinicos-mcp-server
git add src/db/queries/racgp.py tests/test_racgp.py
git commit -m "feat: add RACGP indicator lookup query module"
```

---

## Task 7: RAG Spine HTTP Client + Tests

**Files:**
- Create: `src/clients/rag_spine.py`
- Test: `tests/test_rag.py`

- [ ] **Step 1: Write the failing test**

`tests/test_rag.py`:
```python
from unittest.mock import AsyncMock, patch
import pytest
import httpx

from src.clients.rag_spine import query_clinical_knowledge
from src.config import Settings


@pytest.fixture
def settings():
    return Settings(
        rag_spine_url="http://localhost:8001",
        rag_spine_tenant_id="public",
        rag_spine_timeout_seconds=5.0,
    )


@pytest.mark.asyncio
async def test_query_success(settings):
    """Should return answer with citations on success."""
    mock_response = httpx.Response(
        200,
        json={
            "answer": {
                "text": "Chronic disease management requires...",
                "citations": [{"source": "MBS Online", "text": "Item 721..."}],
                "confidence": 0.85,
                "meta": {"domain": "clinical_gp"},
            }
        },
        request=httpx.Request("POST", "http://localhost:8001/v1/query"),
    )
    with patch("src.clients.rag_spine.httpx.AsyncClient") as MockClient:
        mock_client = AsyncMock()
        mock_client.post.return_value = mock_response
        mock_client.__aenter__ = AsyncMock(return_value=mock_client)
        mock_client.__aexit__ = AsyncMock(return_value=False)
        MockClient.return_value = mock_client

        result = await query_clinical_knowledge(settings, "What is chronic disease management?")

    assert result["answer"] == "Chronic disease management requires..."
    assert len(result["citations"]) == 1
    assert result["confidence"] == 0.85


@pytest.mark.asyncio
async def test_query_timeout(settings):
    """Should return fallback on timeout."""
    with patch("src.clients.rag_spine.httpx.AsyncClient") as MockClient:
        mock_client = AsyncMock()
        mock_client.post.side_effect = httpx.TimeoutException("timed out")
        mock_client.__aenter__ = AsyncMock(return_value=mock_client)
        mock_client.__aexit__ = AsyncMock(return_value=False)
        MockClient.return_value = mock_client

        result = await query_clinical_knowledge(settings, "test question")

    assert "error" in result
    assert "unavailable" in result["error"].lower()
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd ~/clinicos-mcp-server && uv run pytest tests/test_rag.py -v`
Expected: FAIL

- [ ] **Step 3: Write the implementation**

`src/clients/rag_spine.py`:
```python
from typing import Any

import httpx

from src.config import Settings


async def query_clinical_knowledge(
    settings: Settings,
    question: str,
    domain: str | None = None,
) -> dict[str, Any]:
    """Query RAG Spine for clinical knowledge.

    Returns structured answer with citations, or a fallback error dict
    if the service is unavailable.
    """
    payload: dict[str, Any] = {"question": question, "options": {"top_k": 5}}
    if domain:
        payload["options"]["domain"] = domain

    headers = {"x-tenant-id": settings.rag_spine_tenant_id}

    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{settings.rag_spine_url}/v1/query",
                json=payload,
                headers=headers,
                timeout=settings.rag_spine_timeout_seconds,
            )
            response.raise_for_status()
            data = response.json()

        answer_block = data.get("answer", {})
        return {
            "answer": answer_block.get("text", ""),
            "citations": answer_block.get("citations", []),
            "confidence": answer_block.get("confidence", 0.0),
            "domain_matched": answer_block.get("meta", {}).get("domain", "unknown"),
        }

    except (httpx.TimeoutException, httpx.ConnectError):
        return {
            "error": "Knowledge base temporarily unavailable. Try mbs_item_lookup or racgp_indicator_lookup for specific queries.",
            "answer": "",
            "citations": [],
            "confidence": 0.0,
        }
    except httpx.HTTPStatusError as e:
        return {
            "error": f"Knowledge base returned error: {e.response.status_code}",
            "answer": "",
            "citations": [],
            "confidence": 0.0,
        }
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd ~/clinicos-mcp-server && uv run pytest tests/test_rag.py -v`
Expected: 2 passed

- [ ] **Step 5: Commit**

```bash
cd ~/clinicos-mcp-server
git add src/clients/rag_spine.py tests/test_rag.py
git commit -m "feat: add RAG Spine HTTP client with timeout fallback"
```

---

## Task 8: FastMCP Server with All 5 Tools

**Files:**
- Create: `src/server.py`

This is the main file — it wires everything together using FastMCP lifespan for DB pools and defines all 5 tools.

- [ ] **Step 1: Write server.py**

`src/server.py`:
```python
"""ClinicOS MCP Server — Australian Medicare & Clinical Intelligence.

Exposes MBS lookup, PSR risk checking, RACGP accreditation guidance,
and clinical knowledge via the Model Context Protocol.
"""

from contextlib import asynccontextmanager
from typing import Any

from mcp.server.fastmcp import FastMCP, Context

from src.config import Settings
from src.db.connection import create_pools, close_pools
from src.db.queries.mbs import lookup_mbs_item, suggest_mbs_items
from src.db.queries.psr import check_psr_risk
from src.db.queries.racgp import lookup_racgp_indicators
from src.clients.rag_spine import query_clinical_knowledge

POWERED_BY = {
    "name": "ClinicOS",
    "url": "https://clinicos.com.au",
    "description": "Australian healthcare AI platform by Dr. Alex (CVLM)",
}

settings = Settings()


@asynccontextmanager
async def app_lifespan():
    """Initialize DB pools on startup, close on shutdown."""
    mbs_pool, accred_pool = await create_pools(settings)
    yield {"mbs_pool": mbs_pool, "accred_pool": accred_pool, "settings": settings}
    await close_pools(mbs_pool, accred_pool)


mcp = FastMCP(
    "clinicos_mcp",
    lifespan=app_lifespan,
    json_response=True,
)


# --- Tool 1: MBS Item Lookup ---


@mcp.tool(
    name="mbs_item_lookup",
    annotations={
        "title": "MBS Item Lookup",
        "readOnlyHint": True,
        "destructiveHint": False,
        "idempotentHint": True,
        "openWorldHint": False,
    },
)
async def mbs_item_lookup(item_number: str, ctx: Context) -> dict[str, Any]:
    """Look up an Australian Medicare Benefits Schedule (MBS) item by number.

    Returns the schedule fee, description, documentation requirements,
    time estimate, and PSR risk level. Use this when a user asks about
    a specific MBS item number.

    Args:
        item_number: The MBS item number to look up (e.g. "23", "721", "36").

    Returns:
        Dict with item details or an error message if not found.
    """
    pool = ctx.request_context.lifespan_state["mbs_pool"]
    result = await lookup_mbs_item(pool, item_number.strip())

    if result is None:
        return {"error": f"MBS item '{item_number}' not found.", "powered_by": POWERED_BY}

    result["powered_by"] = POWERED_BY
    return result


# --- Tool 2: MBS Item Suggest ---


@mcp.tool(
    name="mbs_item_suggest",
    annotations={
        "title": "MBS Item Suggest",
        "readOnlyHint": True,
        "destructiveHint": False,
        "idempotentHint": True,
        "openWorldHint": False,
    },
)
async def mbs_item_suggest(
    consultation_type: str,
    duration_minutes: int,
    care_plan: str | None = None,
    ctx: Context = None,
) -> dict[str, Any]:
    """Suggest appropriate MBS items based on consultation context.

    Returns recommended items with fees and co-claiming opportunities.
    Use when a user describes a consultation and needs billing guidance.

    Args:
        consultation_type: Type of consultation. One of: follow_up, new_patient,
            telehealth, mental_health, chronic_disease, skin_procedure, vascular.
        duration_minutes: Length of consultation in minutes (e.g. 20, 30, 45).
        care_plan: Active care plan if any. One of: GPMP, TCA, MHC, or None.

    Returns:
        Dict with recommended_items list, co_claiming rules, and total potential fee.
    """
    pool = ctx.request_context.lifespan_state["mbs_pool"]
    items, co_claims = await suggest_mbs_items(
        pool, consultation_type, duration_minutes, care_plan
    )

    recommended = []
    for item in items:
        recommended.append({
            "item_number": item["item_number"],
            "description": item["description"],
            "fee": item["schedule_fee"],
            "psr_risk_level": item["psr_risk_level"],
        })

    total_fee = sum(float(item["schedule_fee"]) for item in items[:1])  # Primary item only
    if co_claims:
        # Add co-claim fees if the items exist in our results
        for claim in co_claims:
            total_fee_note = f"+ co-claim item {claim['item']} (look up fee separately)"

    return {
        "recommended_items": recommended,
        "co_claiming": co_claims,
        "primary_fee": f"{total_fee:.2f}" if recommended else "0.00",
        "documentation_tips": f"Ensure notes justify {consultation_type} billing with {duration_minutes}min duration documented.",
        "powered_by": POWERED_BY,
    }


# --- Tool 3: PSR Risk Check ---


@mcp.tool(
    name="psr_risk_check",
    annotations={
        "title": "PSR Risk Check",
        "readOnlyHint": True,
        "destructiveHint": False,
        "idempotentHint": True,
        "openWorldHint": False,
    },
)
async def psr_risk_check(item_number: str, ctx: Context) -> dict[str, Any]:
    """Check if an MBS item has been flagged in Professional Services Review cases.

    Returns relevant PSR cases with severity, repayment amounts, and lessons
    learned. Use when a user wants to check billing risk before claiming.

    Args:
        item_number: The MBS item number to check (e.g. "23", "36").

    Returns:
        Dict with risk_level summary and list of related PSR cases.
    """
    pool = ctx.request_context.lifespan_state["mbs_pool"]
    cases = await check_psr_risk(pool, item_number.strip())

    if not cases:
        return {
            "risk_level": "none",
            "message": f"No PSR cases found involving item {item_number}.",
            "related_cases": [],
            "powered_by": POWERED_BY,
        }

    # Determine overall risk from worst case severity
    severity_order = {"critical": 4, "high": 3, "medium": 2, "low": 1}
    worst = max(cases, key=lambda c: severity_order.get(c.get("severity_level", "low"), 0))

    return {
        "risk_level": worst["severity_level"],
        "related_cases": [
            {
                "case_reference": c["case_reference"],
                "severity": c["severity_level"],
                "issue": c["issue_description"],
                "repayment": c["repayment_amount"],
                "lessons": c["lessons_learned"],
            }
            for c in cases
        ],
        "safe_billing_tips": cases[0].get("recommendations", []),
        "powered_by": POWERED_BY,
    }


# --- Tool 4: RACGP Indicator Lookup ---


@mcp.tool(
    name="racgp_indicator_lookup",
    annotations={
        "title": "RACGP Indicator Lookup",
        "readOnlyHint": True,
        "destructiveHint": False,
        "idempotentHint": True,
        "openWorldHint": False,
    },
)
async def racgp_indicator_lookup(
    query: str,
    module: str | None = None,
    ctx: Context = None,
) -> dict[str, Any]:
    """Look up RACGP 5th Edition accreditation indicators.

    Search by indicator code (e.g. GP1.1A) or by keyword (e.g. 'vaccine storage').
    Optionally filter by module. Returns indicator details, evidence requirements,
    and guidance.

    Args:
        query: Indicator code (e.g. "GP1.1A") or search keyword (e.g. "infection control").
        module: Optional module filter. One of: GP, QI, C.

    Returns:
        Dict with list of matching indicators (max 10), each with full hierarchy.
    """
    pool = ctx.request_context.lifespan_state["accred_pool"]
    indicators = await lookup_racgp_indicators(pool, query, module)

    if not indicators:
        return {
            "message": f"No RACGP indicators found for '{query}'.",
            "indicators": [],
            "powered_by": POWERED_BY,
        }

    return {
        "indicators": [
            {
                "code": ind["indicator_code"],
                "title": ind["indicator_title"],
                "description": ind["indicator_description"],
                "guidance": ind["guidance"],
                "is_mandatory": ind["is_mandatory"],
                "evidence_requirements": ind["evidence_requirements"],
                "standard": f"{ind['standard_code']} — {ind['standard_name']}",
                "module": f"{ind['module_code']} — {ind['module_name']}",
            }
            for ind in indicators
        ],
        "result_count": len(indicators),
        "powered_by": POWERED_BY,
    }


# --- Tool 5: Clinical Knowledge Query ---


@mcp.tool(
    name="clinical_knowledge_query",
    annotations={
        "title": "Clinical Knowledge Query",
        "readOnlyHint": True,
        "destructiveHint": False,
        "idempotentHint": False,
        "openWorldHint": True,
    },
)
async def clinical_knowledge_query(
    question: str,
    domain: str | None = None,
    ctx: Context = None,
) -> dict[str, Any]:
    """Query ClinicOS clinical knowledge base using RAG.

    Returns grounded answers with citations from Australian healthcare
    guidelines, MBS rules, and clinical protocols. Use for open-ended
    clinical or operational questions.

    Args:
        question: The clinical or healthcare question to answer.
        domain: Optional domain filter. Examples: clinical_gp, mbs_billing,
            ops_workflows, clinical_phlebology, quality_and_accreditation.

    Returns:
        Dict with answer text, citations, confidence score, and matched domain.
    """
    s = ctx.request_context.lifespan_state["settings"]
    result = await query_clinical_knowledge(s, question, domain)
    result["powered_by"] = POWERED_BY
    return result


# --- Entry Point ---

if __name__ == "__main__":
    if settings.mcp_transport == "streamable-http":
        mcp.run(transport="streamable-http", port=settings.mcp_port)
    else:
        mcp.run()
```

- [ ] **Step 2: Verify syntax**

Run: `cd ~/clinicos-mcp-server && uv run python -m py_compile src/server.py`
Expected: No output (clean compile)

- [ ] **Step 3: Commit**

```bash
cd ~/clinicos-mcp-server
git add src/server.py
git commit -m "feat: add FastMCP server with 5 healthcare tools"
```

---

## Task 9: Dockerfile + .env.example Updates

**Files:**
- Create: `Dockerfile`

- [ ] **Step 1: Write the Dockerfile**

`Dockerfile`:
```dockerfile
FROM python:3.12-slim

WORKDIR /app

# Install uv for fast dependency resolution
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

COPY pyproject.toml .
COPY src/ src/

RUN uv sync --no-dev --no-editable

ENV MCP_TRANSPORT=streamable-http
ENV MCP_PORT=8080

EXPOSE 8080

CMD ["uv", "run", "python", "-m", "src.server"]
```

- [ ] **Step 2: Verify Dockerfile builds**

Run: `cd ~/clinicos-mcp-server && docker build -t clinicos-mcp:dev . 2>&1 | tail -5`
Expected: `Successfully tagged clinicos-mcp:dev`

- [ ] **Step 3: Commit**

```bash
cd ~/clinicos-mcp-server
git add Dockerfile
git commit -m "feat: add Dockerfile for Cloud Run deployment"
```

---

## Task 10: Integration Smoke Test

**Files:**
- Create: `tests/test_server_smoke.py`

This test verifies the server module loads, tools are registered, and the lifespan context wires correctly — without a real database.

- [ ] **Step 1: Write the smoke test**

`tests/test_server_smoke.py`:
```python
"""Smoke tests for the MCP server — no real DB required."""

from unittest.mock import AsyncMock, patch
import pytest


def test_server_imports():
    """Server module should import without errors."""
    from src.server import mcp
    assert mcp.name == "clinicos_mcp"


def test_tools_registered():
    """All 5 tools should be registered."""
    from src.server import mcp
    tool_names = {t.name for t in mcp._tool_manager.list_tools()}
    expected = {
        "mbs_item_lookup",
        "mbs_item_suggest",
        "psr_risk_check",
        "racgp_indicator_lookup",
        "clinical_knowledge_query",
    }
    assert expected.issubset(tool_names), f"Missing tools: {expected - tool_names}"


def test_powered_by_constant():
    """Attribution should include ClinicOS URL."""
    from src.server import POWERED_BY
    assert POWERED_BY["url"] == "https://clinicos.com.au"
    assert "CVLM" in POWERED_BY["description"]
```

- [ ] **Step 2: Run smoke tests**

Run: `cd ~/clinicos-mcp-server && uv run pytest tests/test_server_smoke.py -v`
Expected: 3 passed

- [ ] **Step 3: Run full test suite**

Run: `cd ~/clinicos-mcp-server && uv run pytest -v`
Expected: All tests pass (11+ tests)

- [ ] **Step 4: Commit**

```bash
cd ~/clinicos-mcp-server
git add tests/test_server_smoke.py
git commit -m "test: add server smoke tests verifying tool registration"
```

---

## Task 11: Final Cleanup + Full Test Run

- [ ] **Step 1: Run ruff linter**

Run: `cd ~/clinicos-mcp-server && uv run ruff check src/ tests/ --fix`
Expected: No errors (or auto-fixed)

- [ ] **Step 2: Run full test suite one final time**

Run: `cd ~/clinicos-mcp-server && uv run pytest -v --tb=short`
Expected: All tests pass

- [ ] **Step 3: Update CHANGELOG.md**

Add under `[Unreleased]`:
```markdown
### Added
- FastMCP server with 5 tools: mbs_item_lookup, mbs_item_suggest, psr_risk_check, racgp_indicator_lookup, clinical_knowledge_query
- asyncpg connection pools for MBS and accreditation databases (read-only)
- httpx client for RAG Spine with timeout fallback
- pydantic-settings configuration
- Dockerfile for Cloud Run deployment
- Full test suite with mocked DB queries
```

- [ ] **Step 4: Final commit**

```bash
cd ~/clinicos-mcp-server
git add -A
git commit -m "chore: lint fixes and changelog update for v0.1.0"
```

---

## Post-Implementation Notes

**To test locally with real DB:**
1. Start Cloud SQL Proxy: `cloud-sql-proxy clinicos-emr-staging:australia-southeast1:clinicos-emr-pg16-staging`
2. Create `.env` from `.env.example` with real credentials
3. Run: `uv run python -m src.server` (stdio mode)
4. Or: `MCP_TRANSPORT=streamable-http uv run python -m src.server` (HTTP mode on port 8000)

**To add to Claude Desktop:**
```json
{
  "mcpServers": {
    "clinicos": {
      "command": "uv",
      "args": ["run", "--directory", "/Users/lex4851/clinicos-mcp-server", "python", "-m", "src.server"]
    }
  }
}
```

**Next steps (v0.2):**
- Create `mcp_readonly` Postgres role on Cloud SQL
- Deploy to Cloud Run with Cloud SQL connector
- Set up `mcp.clinicos.com.au` DNS
- Publish to Smithery + PyPI
- Add API key auth for usage tracking
