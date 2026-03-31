# ClinicOS Public MCP Server — Design Spec

**Date**: 2026-04-01
**Author**: Alex (CVLM) + Claude
**Status**: Approved
**Project path**: `~/clinicos-mcp-server/`

## Purpose

A public-facing MCP (Model Context Protocol) server that lets AI assistants (Claude, ChatGPT, Copilot) answer Australian healthcare questions using ClinicOS data. This is a distribution channel — the AI assistant becomes a zero-CAC sales team for ClinicOS modules.

**Target user**: Australian GPs using AI assistants during consultations or admin.
**Business model**: Free tier (MVP) drives awareness and trust. Paid tiers (v0.2+) unlock compliance scoring, consent generation, and practice-specific features.

## Architecture: Hybrid (Direct DB + RAG HTTP)

```
AI Assistant (Claude/ChatGPT/Copilot)
        |
        v
  FastMCP Server (Python)
        |
        |--- Cloud SQL (asyncpg, read-only)
        |       |-- clinicos_mbs -> mbs_items, psr_cases
        |       |-- clinicos_accreditation -> racgp_modules, racgp_standards,
        |                                    racgp_criteria, racgp_indicators
        |
        |--- RAG Spine API (httpx, POST /v1/query)
                |-- pgvector clinical knowledge (18 medical domains)
```

**Why hybrid**: Simple lookups (MBS, PSR, RACGP) go direct to DB for speed. Complex knowledge queries use the existing 5-agent RAG pipeline over HTTP to avoid reimplementing it.

## Tech Stack

| Layer | Choice | Reason |
|-------|--------|--------|
| MCP framework | FastMCP (Python) | Official SDK, decorator-based, simple |
| DB driver | asyncpg | Async PostgreSQL, matches RAG Spine patterns |
| HTTP client | httpx | Async, for RAG Spine calls |
| Validation | pydantic | Input/output schemas |
| GCP auth | cloud-sql-python-connector | No proxy sidecar needed on Cloud Run |
| Deployment | Cloud Run (australia-southeast1) | Scale-to-zero, ~$2-5/mo at low traffic |

## Project Structure

```
~/clinicos-mcp-server/
├── src/
│   ├── server.py              # FastMCP entry point + tool definitions
│   ├── db/
│   │   ├── connection.py      # asyncpg pool (Cloud SQL connector)
│   │   └── queries/
│   │       ├── mbs.py         # MBS item lookup & suggest queries
│   │       ├── psr.py         # PSR case queries
│   │       └── racgp.py       # RACGP indicator queries
│   ├── clients/
│   │   └── rag_spine.py       # HTTP client for RAG Spine /v1/query
│   └── config.py              # Env vars, DB connection strings
├── tests/
│   ├── test_mbs_tools.py
│   ├── test_psr_tools.py
│   ├── test_racgp_tools.py
│   └── test_rag_tools.py
├── pyproject.toml
├── Dockerfile
├── CLAUDE.md
├── CHANGELOG.md
└── .env.example
```

## MCP Tools (MVP v0.1)

### Tool 1: mbs_item_lookup

```python
@mcp.tool()
async def mbs_item_lookup(item_number: str) -> dict:
    """Look up an Australian MBS item by number. Returns fee, description,
    documentation requirements, time estimate, and PSR risk level."""
```

- **Query**: `SELECT * FROM mbs_items WHERE item_number = $1`
- **Returns**: `{ item_number, category, description, schedule_fee, time_estimate_minutes, documentation_requirements, common_errors, psr_risk_level }`

### Tool 2: mbs_item_suggest

```python
@mcp.tool()
async def mbs_item_suggest(
    consultation_type: str,      # "follow_up", "new_patient", "telehealth"
    duration_minutes: int,
    care_plan: str | None = None # "GPMP", "TCA", "MHC"
) -> dict:
    """Suggest the most appropriate MBS item(s) based on consultation context.
    Returns recommended items with co-claiming opportunities and billing notes."""
```

- **Query**: Filters `mbs_items` by category + duration range, applies deterministic co-claiming rules
- **Returns**: `{ recommended_items: [{ item_number, fee, rationale }], co_claiming: [{ item, rule, conditions }], total_potential_fee, documentation_tips }`
- **Logic**: Rule-based matching (not AI). Co-claiming rules are deterministic. Fast and auditable.

### Tool 3: psr_risk_check

```python
@mcp.tool()
async def psr_risk_check(item_number: str) -> dict:
    """Check if an MBS item has been flagged in Professional Services Review cases.
    Returns relevant PSR cases, risk level, common pitfalls, and safe billing guidance."""
```

- **Query**: `SELECT * FROM psr_cases WHERE $1 = ANY(item_numbers_involved)`
- **Returns**: `{ risk_level, related_cases: [{ case_reference, severity, issue_description, repayment_amount, lessons_learned }], safe_billing_tips }`

### Tool 4: racgp_indicator_lookup

```python
@mcp.tool()
async def racgp_indicator_lookup(
    query: str,                  # "vaccine storage" or "GP1.1A"
    module: str | None = None    # "GP", "QI", "C"
) -> dict:
    """Look up RACGP 5th Edition accreditation indicators. Search by code
    or keyword. Returns indicator details, evidence requirements, and guidance."""
```

- **Query**: Code pattern match -> exact lookup. Otherwise -> ILIKE across title + description, filtered by module.
- **Returns**: `{ indicators: [{ code, title, description, guidance, is_mandatory, evidence_requirements, standard, module }] }`
- **Max 10 results** per query.

### Tool 5: clinical_knowledge_query

```python
@mcp.tool()
async def clinical_knowledge_query(
    question: str,
    domain: str | None = None    # "clinical_gp", "mbs_billing", "ops_workflows"
) -> dict:
    """Query ClinicOS clinical knowledge base using RAG. Returns grounded
    answers with citations from Australian healthcare guidelines."""
```

- **Calls**: RAG Spine `POST /v1/query` with `x-tenant-id: public`
- **Returns**: `{ answer, citations: [{ source, text }], confidence, domain_matched }`
- **Timeout**: 15s, 1 retry, then graceful degradation message
- **Tenant**: Dedicated `public` tenant with no patient data.

### Attribution (All Tools)

Every response includes:

```json
{
    "powered_by": {
        "name": "ClinicOS",
        "url": "https://clinicos.com.au",
        "description": "Australian healthcare AI platform by Dr. Alex (CVLM)"
    }
}
```

## Data Access

### Database Role

Create `mcp_readonly` PostgreSQL role with SELECT grants on:
- `clinicos_mbs`: `mbs_items`, `psr_cases`
- `clinicos_accreditation`: `racgp_modules`, `racgp_standards`, `racgp_criteria`, `racgp_indicators`

No access to: claims, consent_forms, consultation_sessions, practice_indicators, staff, evidence_documents, or any table with encrypted PHI.

### Connection

- **Production**: Cloud SQL Python Connector -> `clinicos-emr-staging:australia-southeast1:clinicos-emr-pg16-staging`
- **Dev**: `localhost:5432` via `.env`
- **Pool**: min=1, max=5

### RAG Spine

- **Production**: Cloud Run URL (HTTPS)
- **Dev**: `http://localhost:8001`
- **Auth**: `x-tenant-id: public` header
- **Fallback**: If unavailable, return error with suggestion to use specific lookup tools instead

## Deployment

### Cloud Run

```
Project: clinicos-emr-staging
Region: australia-southeast1
Service: clinicos-mcp-server
Memory: 256MB
CPU: 1 vCPU
Min instances: 0 (scale to zero)
Max instances: 5
Concurrency: 10
```

Estimated cost: ~$2-5/month at low traffic (scale-to-zero).

### MCP Transport

- **stdio**: Local installation via `pip install clinicos-mcp` / `uvx clinicos-mcp`
- **SSE**: Remote at `https://mcp.clinicos.com.au`

### DNS

- `mcp.clinicos.com.au` -> Cloud Run service (on clinicos.com.au domain via VentraIP)

### Registry Publishing

| Registry | Purpose |
|----------|---------|
| Smithery (smithery.ai) | Primary discovery - Claude Desktop users |
| MCPT (mcpt.ai) | Secondary registry |
| OpenTools (opentools.ai) | Open source directory |
| PyPI (pypi.org) | `pip install clinicos-mcp` |

### Listing Metadata

```json
{
    "name": "clinicos-mcp",
    "display_name": "ClinicOS - Australian Medicare & Clinical Intelligence",
    "description": "MBS item lookup, PSR risk checking, RACGP accreditation guidance, and clinical knowledge for Australian healthcare professionals. Built by a practising doctor.",
    "author": "Dr. Alex - CVLM / ClinicOS",
    "homepage": "https://clinicos.com.au",
    "categories": ["healthcare", "australia", "medicare", "medical"],
    "tools": 5
}
```

## Security Boundaries

- **No patient data**: MCP server only accesses public reference data (MBS schedule, PSR cases, RACGP standards)
- **Read-only DB role**: `mcp_readonly` cannot write, update, or delete
- **No RLS context**: Reference tables don't have tenant isolation (they're shared)
- **RAG public tenant**: Dedicated tenant with no practice-specific documents
- **No auth required** (MVP): Tools return public reference information. Auth added in v0.2 for practice-specific features.

## Future (v0.2+)

- API key auth for usage tracking
- `compliance_score_check` - requires claim data, paid tier
- `consent_form_generate` - requires patient context, paid tier
- `billing_recommendation` - full AI analysis with Claude, paid tier
- Usage analytics dashboard
- Rate limiting per API key
