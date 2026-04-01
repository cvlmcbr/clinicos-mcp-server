-- Run against cloudos-consolidated in project cloudos-478102
-- Connect: gcloud sql connect cloudos-consolidated --user=postgres --project=cloudos-478102 --database=clinicos_mbs

-- 1. Create the read-only role
DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'mcp_readonly') THEN
    CREATE ROLE mcp_readonly WITH LOGIN PASSWORD 'clinicos-mcp-r0-2026!';
  END IF;
END $$;

-- 2. Grant read-only access to MBS tables
GRANT CONNECT ON DATABASE clinicos_mbs TO mcp_readonly;
GRANT USAGE ON SCHEMA public TO mcp_readonly;
GRANT SELECT ON mbs_items TO mcp_readonly;
GRANT SELECT ON psr_cases TO mcp_readonly;

-- 3. Revoke write access
REVOKE CREATE ON SCHEMA public FROM mcp_readonly;
