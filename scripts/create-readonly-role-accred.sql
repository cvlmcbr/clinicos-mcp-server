-- Run against clinicos-emr-pg16-staging in project clinicos-emr-staging
-- Connect: gcloud sql connect clinicos-emr-pg16-staging --user=postgres --project=clinicos-emr-staging --database=clinicos_accreditation

-- 1. Create the read-only role
DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'mcp_readonly') THEN
    CREATE ROLE mcp_readonly WITH LOGIN PASSWORD 'clinicos-mcp-r0-2026!';
  END IF;
END $$;

-- 2. Grant read-only access to RACGP tables
GRANT CONNECT ON DATABASE clinicos_accreditation TO mcp_readonly;
GRANT USAGE ON SCHEMA public TO mcp_readonly;
GRANT SELECT ON racgp_modules TO mcp_readonly;
GRANT SELECT ON racgp_standards TO mcp_readonly;
GRANT SELECT ON racgp_criteria TO mcp_readonly;
GRANT SELECT ON racgp_indicators TO mcp_readonly;

-- 3. Revoke write access
REVOKE CREATE ON SCHEMA public FROM mcp_readonly;
