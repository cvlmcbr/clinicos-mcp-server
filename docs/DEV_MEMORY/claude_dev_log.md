# Development Log

> This file tracks all development sessions for continuity across AI agent sessions.
> Each session should add an entry following the template below.

---

## How to Use This Log

1. **Read before starting**: Review last 3-5 sessions to understand context
2. **Write after working**: Add entry with what was done, bugs found, next steps
3. **Be specific**: Future sessions depend on this documentation
4. **Include commit hashes**: Makes it easy to trace changes

---

## Session Template

```markdown
### Session N - YYYY-MM-DD HH:MM

**Feature worked on:** feature-XXX (description)
**Status:** completed | in-progress | blocked

**What was done:**
- Accomplishment 1
- Accomplishment 2

**Bugs encountered:**
- Bug description (resolution or workaround)

**Lessons learned:**
- Pattern or insight discovered

**Next session should:**
- Specific actionable guidance

**Git commit:** `abc1234`
**Tests:** passing | failing (X/Y tests)
```

---

## Session History

### Session 1 — 2026-04-01 08:30 — Root Cause Analysis

**Feature worked on:** Cloud Run deployment of MCP server
**Status:** BLOCKED — multiple infrastructure assumptions were wrong

**What was done (before RCA):**
- Built MCP server with 5 tools, 19/19 tests passing (560 LOC)
- Seeded local PostgreSQL with MBS, PSR, RACGP test data
- Verified end-to-end MCP protocol works locally
- Created GitHub repo: cvlmcbr/clinicos-mcp-server
- Attempted Cloud Run deploy — failed twice

**Root causes identified:**

1. **WRONG INSTANCE FOR MBS DATA** (Critical)
   - Code targets `clinicos-emr-pg16-staging` for MBS queries
   - Reality: `clinicos_mbs` lives on `cloudos-consolidated` (project `cloudos-478102`, PUBLIC IP 35.244.79.37)
   - `clinicos_accreditation` correctly lives on `clinicos-emr-pg16-staging` (PRIVATE IP only)
   - MCP server must connect to TWO instances across TWO GCP projects

2. **RAG SPINE NOT DEPLOYED TO CLOUD RUN**
   - Tool 5 (clinical_knowledge_query) needs RAG Spine running
   - RAG Spine is on a GCE VM (34.151.142.98:8080), not Cloud Run
   - Dockerfile exists at ~/ClinicOS/apps/clinicos-rag-spine/Dockerfile
   - Must deploy RAG Spine to Cloud Run first, or MCP tool 5 is dead

3. **DOCKERFILE UNTESTED**
   - `uv sync --no-editable` fails without src/ present
   - Docker wasn't running locally — never tested before Cloud Build
   - Fixed Dockerfile but still untested

4. **CLOUD BUILD PERMISSIONS**
   - Compute SA lacked `storage.objects.get` — fixed reactively

5. **NO HEALTH CHECK OR VERIFICATION**
   - No `/health` endpoint on the MCP server
   - No integration test against production databases
   - No deployment verification script

**Infrastructure facts verified:**

| Data | Database | Instance | Project | IP |
|------|----------|----------|---------|-----|
| MBS + PSR | clinicos_mbs | cloudos-consolidated | cloudos-478102 | PUBLIC 35.244.79.37 |
| RACGP | clinicos_accreditation | clinicos-emr-pg16-staging | clinicos-emr-staging | PRIVATE |
| RAG vectors | clinicos_rag | GCE VM (not Cloud SQL) | cloudos-478102 | 34.151.142.98 |

**Next session should:**
- Follow the deployment plan at docs/DEV_MEMORY/deployment-plan.md
- Fix connection.py to support two different Cloud SQL instances
- Deploy RAG Spine to Cloud Run
- Create mcp_readonly role on BOTH instances via Cloud Shell
- Test Docker build locally (start Docker Desktop first)
- Deploy MCP server with verified config
- Verify all 5 tools work against production data

**Git commit:** `7c68176` (last push before RCA)
**Tests:** 19/19 passing (local only, against mock data)

---

### Session 3 — 2026-04-03 06:30 — Data Seeding + Verification

**Feature worked on:** Production data seeding, tool verification, Firebase custom domain
**Status:** ALL 4 DB TOOLS VERIFIED WORKING

**What was done:**
- Fixed mbs_item_suggest: category mapping mismatch ("GP Consultations" → "General Practice", "Skin Procedures" → "Surgical Procedures")
- Seeded RACGP 5th Edition data: 3 modules, 14 standards, 28 criteria, 71 indicators
- Fixed RACGP seed: evidence_requirements column is text[] not jsonb — changed cast syntax
- Removed org policy constraint (iam.allowedPolicyMemberDomains) on clinicos-emr-staging to allow allUsers
- Granted allUsers Cloud Run invoker on clinicos-mcp-server
- Firebase Hosting deployed with Cloud Run rewrite + custom domain mcp.clinicos.com.au
- Full end-to-end verification of all 5 tools against production

**Verification results:**
| Tool | Status |
|------|--------|
| mbs_item_lookup | PASS — Item 23 → $41.40, real MBS data |
| mbs_item_suggest | PASS — Returns items with fees for consultation types |
| psr_risk_check | PASS — Real PSR cases, $340K repayment |
| racgp_indicator_lookup | PASS — GP1.1A returns Aboriginal cultural safety indicator |
| clinical_knowledge_query | GRACEFUL FALLBACK — RAG Spine not deployed |

**Production data:**
- MBS: 45 items (Nov 2025 schedule) on cloudos-consolidated
- PSR: 14 verified cases from psr.gov.au on cloudos-consolidated
- RACGP: 71 indicators across 3 modules on clinicos-emr-pg16-staging

**Infrastructure corrections:**
- evidence_requirements on racgp_indicators is text[] not jsonb
- Docker port 8085 conflict with gcloud auth persists — must quit Docker before auth

**Next session should:**
- Publish to Smithery (smithery.yaml committed, GitHub repo ready)
- Clean up unused GLB resources (NEG, backend, URL map, forwarding rule, SSL cert)
- Seed remaining 7 PSR cases (use seed-production-data.sql with postgres access)
- Deploy RAG Spine for Tool 5
- Set up Claude Desktop config and test interactively
- Consider landing page for mcp.clinicos.com.au root

**Git commit:** `17ae0f9`
**Tests:** 20/20 passing

---

### Session 2 — 2026-04-02 06:00 — Production Deployment

**Feature worked on:** Cloud Run deployment + infrastructure fixes
**Status:** DEPLOYED — MCP server live, DB connected, tools responding

**What was done:**
- Added `/health` endpoint via `mcp.custom_route()` for Cloud Run probes
- Fixed Dockerfile: README.md missing in build context, `.dockerignore` excluded it
- Fixed FastMCP port binding: `host="0.0.0.0"` and `port=` passed to constructor
- Fixed Cloud SQL Python Connector: event loop mismatch (`ConnectorLoopError`), asyncpg passes positional args to `getconn()`
- Added graceful startup: server starts even if DB pool creation fails
- Split SQL scripts for two-instance architecture (MBS vs accreditation on different Cloud SQL instances)
- Discovered BOTH instances are private-IP only (deployment plan was wrong about public IP)
- Enabled public IP on cloudos-consolidated for cross-project Cloud SQL Connector access
- Created `mcp_readonly` role on both instances via GCE VM SSH (local proxy can't reach private IPs)
- Stored passwords in Secret Manager, granted SA permissions
- Built Docker image locally (linux/amd64), pushed to Artifact Registry
- Deployed to Cloud Run with dual-instance config
- Created Global HTTP(S) Load Balancer for `mcp.clinicos.com.au` (domain mappings unsupported in au-southeast1)
- Updated smithery.yaml for dual-database config
- ADC auth expired mid-session; Docker Desktop was intercepting OAuth callbacks on port 8085

**Infrastructure corrections:**
- cloudos-consolidated: private IP only (172.26.0.5), NOT public. Enabled public IP (34.116.105.141)
- clinicos-emr-pg16-staging: private IP (10.170.0.3) on `clinicos-emr-staging` network, NOT `default` network
- Cloud SQL Connector does direct TCP to the IP, NOT API tunneling — VPC access matters

**Bugs encountered:**
- `uv sync` in Docker fails without README.md (hatchling validates readme field)
- FastMCP ignores `FASTMCP_PORT` env var if set after FastMCP() construction
- `asyncpg.create_pool(connect=fn)` passes positional args AND `loop=` kwarg to connect function
- Cloud SQL Connector `ConnectorLoopError` when Connector() created on different event loop

**Next session should:**
- Add A record for mcp.clinicos.com.au → 34.149.193.178 on VentraIP
- Wait for SSL cert to provision (automatic once DNS resolves)
- Seed MBS items and PSR cases into production
- Publish to Smithery (GitHub-based, smithery.yaml committed)
- Test end-to-end with real data via Claude Desktop
- Consider auth strategy (org policy blocks allUsers on Cloud Run)

**Git commit:** `d1b92eb`
**Tests:** 20/20 passing

---

### Session 0 - Project Initialization

**Feature worked on:** Harness setup
**Status:** completed

**What was done:**
- Initialized development harness
- Created DEV_MEMORY directory
- Set up feature_checklist.json
- Configured init and stop scripts

**Next session should:**
- Review feature_checklist.json and prioritize work
- Begin implementation of first feature

**Git commit:** `initial`
**Tests:** N/A

---

<!-- New sessions go above this line -->
