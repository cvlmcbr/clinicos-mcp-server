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
