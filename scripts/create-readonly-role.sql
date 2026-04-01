-- Run this in Cloud Shell against clinicos-emr-pg16-staging
-- Connect with: gcloud sql connect clinicos-emr-pg16-staging --user=postgres --project=clinicos-emr-staging

-- 1. Create the read-only role
DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'mcp_readonly') THEN
    CREATE ROLE mcp_readonly WITH LOGIN PASSWORD 'clinicos-mcp-r0-2026!';
  END IF;
END $$;

-- 2. Grant on clinicos_mbs database (run while connected to clinicos_mbs)
-- Switch to: \c clinicos_mbs
GRANT CONNECT ON DATABASE clinicos_mbs TO mcp_readonly;
GRANT USAGE ON SCHEMA public TO mcp_readonly;
GRANT SELECT ON mbs_items TO mcp_readonly;
GRANT SELECT ON psr_cases TO mcp_readonly;

-- 3. Grant on clinicos_accreditation database (run while connected to clinicos_accreditation)
-- Switch to: \c clinicos_accreditation
GRANT CONNECT ON DATABASE clinicos_accreditation TO mcp_readonly;
GRANT USAGE ON SCHEMA public TO mcp_readonly;
GRANT SELECT ON racgp_modules TO mcp_readonly;
GRANT SELECT ON racgp_standards TO mcp_readonly;
GRANT SELECT ON racgp_criteria TO mcp_readonly;
GRANT SELECT ON racgp_indicators TO mcp_readonly;

-- 4. Revoke everything else explicitly
REVOKE CREATE ON SCHEMA public FROM mcp_readonly;
