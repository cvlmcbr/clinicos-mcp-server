# ClinicOS MCP Server — Production Deployment Plan

> Created: 2026-04-01 after root cause analysis of failed deployment.
> This plan addresses all 5 issues identified in the RCA.

## Prerequisites

- [ ] Docker Desktop running locally
- [ ] `gcloud auth login` + `gcloud auth application-default login` valid
- [ ] Cloud Shell access (for private-IP database operations)

---

## Phase 1: Fix Connection Architecture (2 instances, 2 projects)

**Problem**: MBS data is on `cloudos-consolidated` (public IP), accreditation is on `clinicos-emr-pg16-staging` (private IP). Current code assumes one instance.

### 1.1 Update config.py — separate connection settings per database

```python
# Current: single instance config
# New: separate configs for MBS and accreditation instances

class Settings(BaseSettings):
    # MBS instance (cloudos-consolidated, PUBLIC IP, project cloudos-478102)
    mbs_database_host: str = "localhost"
    mbs_database_port: int = 5432
    mbs_database_user: str = "mcp_readonly"
    mbs_database_password: str = ""
    mbs_database_name: str = "clinicos_mbs"
    mbs_cloud_sql_connection: str = "cloudos-478102:australia-southeast1:cloudos-consolidated"
    mbs_use_cloud_sql_connector: bool = False

    # Accreditation instance (clinicos-emr-pg16-staging, PRIVATE IP, project clinicos-emr-staging)
    accred_database_host: str = "localhost"
    accred_database_port: int = 5432
    accred_database_user: str = "mcp_readonly"
    accred_database_password: str = ""
    accred_database_name: str = "clinicos_accreditation"
    accred_cloud_sql_connection: str = "clinicos-emr-staging:australia-southeast1:clinicos-emr-pg16-staging"
    accred_use_cloud_sql_connector: bool = False

    # RAG Spine
    rag_spine_url: str = "http://localhost:8001"
    rag_spine_tenant_id: str = "public"
    rag_spine_timeout_seconds: float = 15.0

    # Server
    mcp_transport: str = "stdio"
    mcp_port: int = 8000
```

### 1.2 Update connection.py — two independent pool creators

```python
async def create_pools(settings: Settings) -> tuple[asyncpg.Pool, asyncpg.Pool]:
    mbs_pool = await _create_pool(
        settings.mbs_database_host, settings.mbs_database_port,
        settings.mbs_database_user, settings.mbs_database_password,
        settings.mbs_database_name,
        settings.mbs_use_cloud_sql_connector, settings.mbs_cloud_sql_connection,
        ip_type="public",  # cloudos-consolidated has public IP
    )
    accred_pool = await _create_pool(
        settings.accred_database_host, settings.accred_database_port,
        settings.accred_database_user, settings.accred_database_password,
        settings.accred_database_name,
        settings.accred_use_cloud_sql_connector, settings.accred_cloud_sql_connection,
        ip_type="private",  # clinicos-emr-pg16-staging is private only
    )
    return mbs_pool, accred_pool
```

### 1.3 Update .env.example and .env

### 1.4 Update tests — adjust fixtures for new Settings fields

### 1.5 Run tests, verify 19/19 pass

---

## Phase 2: Deploy RAG Spine to Cloud Run

**Problem**: Tool 5 needs RAG Spine running. Currently on a GCE VM.

### 2.1 Assess RAG Spine Dockerfile

RAG Spine Dockerfile is at `~/ClinicOS/apps/clinicos-rag-spine/Dockerfile`. It uses:
- Python 3.11 + FastAPI + uvicorn
- Port 8080
- Needs DATABASE_URL pointing to pgvector

### 2.2 Deploy RAG Spine to Cloud Run

Deploy in `cloudos-478102` project (same project as the pgvector VM):

```bash
cd ~/ClinicOS/apps/clinicos-rag-spine

gcloud run deploy clinicos-rag-spine \
  --project=cloudos-478102 \
  --region=australia-southeast1 \
  --source=. \
  --set-env-vars="DATABASE_URL=postgresql+psycopg://postgres:[password]@34.151.142.98:5432/clinicos_rag?sslmode=require" \
  --set-env-vars="AUTH_PROVIDER=header" \
  --memory=512Mi \
  --cpu=1 \
  --min-instances=0 \
  --max-instances=3 \
  --concurrency=10 \
  --timeout=30 \
  --allow-unauthenticated \
  --port=8080
```

**Note**: The RAG Spine connects to the GCE VM's PostgreSQL on its public IP.
The VM firewall must allow port 5432 from Cloud Run egress IPs (or use VPC connector).

### 2.3 Verify RAG Spine is working

```bash
RAG_URL=$(gcloud run services describe clinicos-rag-spine --project=cloudos-478102 --region=australia-southeast1 --format="value(status.url)")
curl -X POST "${RAG_URL}/v1/query" \
  -H "Content-Type: application/json" \
  -H "x-tenant-id: public" \
  -d '{"question": "What is chronic disease management?", "options": {"top_k": 3}}'
```

### 2.4 Record the RAG Spine Cloud Run URL

Update MCP server config with the actual URL.

---

## Phase 3: Create mcp_readonly Role on BOTH Instances

**Problem**: Private-IP instance can't be reached from local. Use Cloud Shell.

### 3.1 Create role on cloudos-consolidated (MBS data)

Open Cloud Shell (console.cloud.google.com):

```bash
gcloud sql connect cloudos-consolidated --user=postgres --project=cloudos-478102 --database=clinicos_mbs
```

```sql
DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'mcp_readonly') THEN
    CREATE ROLE mcp_readonly WITH LOGIN PASSWORD 'clinicos-mcp-r0-2026!';
  END IF;
END $$;
GRANT CONNECT ON DATABASE clinicos_mbs TO mcp_readonly;
GRANT USAGE ON SCHEMA public TO mcp_readonly;
GRANT SELECT ON mbs_items, psr_cases TO mcp_readonly;
REVOKE CREATE ON SCHEMA public FROM mcp_readonly;
\q
```

### 3.2 Create role on clinicos-emr-pg16-staging (accreditation data)

```bash
gcloud sql connect clinicos-emr-pg16-staging --user=postgres --project=clinicos-emr-staging --database=clinicos_accreditation
```

```sql
DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'mcp_readonly') THEN
    CREATE ROLE mcp_readonly WITH LOGIN PASSWORD 'clinicos-mcp-r0-2026!';
  END IF;
END $$;
GRANT CONNECT ON DATABASE clinicos_accreditation TO mcp_readonly;
GRANT USAGE ON SCHEMA public TO mcp_readonly;
GRANT SELECT ON racgp_modules, racgp_standards, racgp_criteria, racgp_indicators TO mcp_readonly;
REVOKE CREATE ON SCHEMA public FROM mcp_readonly;
\q
```

### 3.3 Store passwords in Secret Manager

```bash
# MBS instance password (in cloudos-478102 project or clinicos-emr-staging)
echo -n 'clinicos-mcp-r0-2026!' | gcloud secrets create mcp-readonly-mbs-password \
  --project=clinicos-emr-staging \
  --replication-policy=user-managed \
  --locations=australia-southeast1 \
  --data-file=-

# Accreditation instance password (already created as mcp-readonly-password)
# Verify: gcloud secrets versions access latest --secret=mcp-readonly-password --project=clinicos-emr-staging
```

### 3.4 Grant Cloud Run SA access to secrets and Cloud SQL

```bash
SA="1025596487196-compute@developer.gserviceaccount.com"

# Secret access
gcloud secrets add-iam-policy-binding mcp-readonly-mbs-password \
  --project=clinicos-emr-staging \
  --member="serviceAccount:${SA}" \
  --role="roles/secretmanager.secretAccessor"

# Cloud SQL client on BOTH projects
gcloud projects add-iam-policy-binding cloudos-478102 \
  --member="serviceAccount:${SA}" \
  --role="roles/cloudsql.client"

gcloud projects add-iam-policy-binding clinicos-emr-staging \
  --member="serviceAccount:${SA}" \
  --role="roles/cloudsql.client"
```

---

## Phase 4: Test Docker Build Locally

### 4.1 Start Docker Desktop

### 4.2 Build and run locally

```bash
cd ~/clinicos-mcp-server
docker build -t clinicos-mcp:test .

# Test with local DB (stdio mode)
docker run --rm \
  -e DATABASE_HOST=host.docker.internal \
  -e DATABASE_PORT=5432 \
  -e MBS_DATABASE_USER=mcp_readonly \
  -e MBS_DATABASE_PASSWORD=mcp_dev_pass \
  -e MBS_DATABASE_NAME=clinicos_mbs \
  -e ACCRED_DATABASE_USER=mcp_readonly \
  -e ACCRED_DATABASE_PASSWORD=mcp_dev_pass \
  -e ACCRED_DATABASE_NAME=clinicos_accreditation \
  -e MCP_TRANSPORT=streamable-http \
  -e MCP_PORT=8080 \
  -p 8080:8080 \
  clinicos-mcp:test
```

### 4.3 Verify health endpoint responds

```bash
curl http://localhost:8080/health
```

---

## Phase 5: Deploy MCP Server to Cloud Run

### 5.1 Update deploy.sh with correct dual-instance config

Key env vars:
```
MBS_USE_CLOUD_SQL_CONNECTOR=true
MBS_CLOUD_SQL_CONNECTION=cloudos-478102:australia-southeast1:cloudos-consolidated
MBS_DATABASE_USER=mcp_readonly
MBS_DATABASE_NAME=clinicos_mbs

ACCRED_USE_CLOUD_SQL_CONNECTOR=true
ACCRED_CLOUD_SQL_CONNECTION=clinicos-emr-staging:australia-southeast1:clinicos-emr-pg16-staging
ACCRED_DATABASE_USER=mcp_readonly
ACCRED_DATABASE_NAME=clinicos_accreditation

RAG_SPINE_URL=[Cloud Run URL from Phase 2]
```

Secrets:
```
MBS_DATABASE_PASSWORD=mcp-readonly-mbs-password:latest
ACCRED_DATABASE_PASSWORD=mcp-readonly-password:latest
```

### 5.2 Deploy

```bash
cd ~/clinicos-mcp-server && bash scripts/deploy.sh
```

### 5.3 Verify deployment

```bash
SERVICE_URL=$(gcloud run services describe clinicos-mcp-server \
  --project=clinicos-emr-staging --region=australia-southeast1 \
  --format="value(status.url)")

# Health check
curl "${SERVICE_URL}/health"

# MCP tools list (via streamable-http)
curl -X POST "${SERVICE_URL}/mcp" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc": "2.0", "method": "tools/list", "id": 1}'
```

---

## Phase 6: DNS — mcp.clinicos.com.au

### 6.1 Create Cloud Run domain mapping

```bash
gcloud beta run domain-mappings create \
  --service=clinicos-mcp-server \
  --domain=mcp.clinicos.com.au \
  --project=clinicos-emr-staging \
  --region=australia-southeast1
```

### 6.2 Add DNS records on VentraIP

The domain mapping command will output the required DNS records. Typically:
- CNAME `mcp.clinicos.com.au` → `ghs.googlehosted.com.`

Log into VentraIP DNS management for clinicos.com.au and add the record.

### 6.3 Verify DNS propagation

```bash
dig mcp.clinicos.com.au CNAME
curl https://mcp.clinicos.com.au/health
```

---

## Phase 7: Publish to Smithery + PyPI

### 7.1 Smithery

Smithery reads from the GitHub repo. The `smithery.yaml` is already committed.

Go to https://smithery.ai and:
1. Sign in with GitHub (cvlmcbr)
2. Click "Add Server"
3. Select `cvlmcbr/clinicos-mcp-server`
4. Smithery reads smithery.yaml automatically
5. Publish

### 7.2 PyPI

```bash
cd ~/clinicos-mcp-server
uv build
uv publish --token $PYPI_TOKEN
```

Note: Need a PyPI account and API token. Create at pypi.org if not existing.

---

## Verification Checklist (Run After All Phases)

- [ ] `curl https://mcp.clinicos.com.au/health` returns 200
- [ ] MCP tools/list returns 5 tools via streamable-http
- [ ] mbs_item_lookup("23") returns real MBS data from cloudos-consolidated
- [ ] psr_risk_check("36") returns PSR cases from cloudos-consolidated
- [ ] racgp_indicator_lookup("GP1.1A") returns indicator from clinicos-emr-pg16-staging
- [ ] clinical_knowledge_query("chronic disease management") returns RAG answer
- [ ] Claude Desktop can use the tools via stdio transport locally
- [ ] Smithery listing is live and installable
- [ ] No secrets in plaintext (all via Secret Manager)
- [ ] mcp_readonly role exists on both instances with SELECT-only grants
