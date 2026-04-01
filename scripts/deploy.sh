#!/bin/bash
# Deploy ClinicOS MCP Server to Cloud Run
# Usage: ./scripts/deploy.sh
#
# Connects to TWO Cloud SQL instances across TWO GCP projects:
#   MBS data:    cloudos-consolidated (PUBLIC IP) in cloudos-478102
#   Accred data: clinicos-emr-pg16-staging (PRIVATE IP) in clinicos-emr-staging
#
# Prerequisites:
#   1. mcp_readonly role created on BOTH instances (see scripts/create-readonly-role.sql)
#   2. Secrets created: mcp-readonly-mbs-password, mcp-readonly-password
#   3. SA has roles/cloudsql.client on BOTH projects
#   4. RAG Spine deployed (see RAG_SPINE_URL below)

set -euo pipefail

PROJECT=clinicos-emr-staging
REGION=australia-southeast1
SERVICE=clinicos-mcp-server
VPC_CONNECTOR=clinicos-vpc-staging

# Get RAG Spine URL (deployed separately)
RAG_SPINE_URL="${RAG_SPINE_URL:-NOT_SET}"
if [ "${RAG_SPINE_URL}" = "NOT_SET" ]; then
  echo "WARNING: RAG_SPINE_URL not set. Tool 5 (clinical_knowledge_query) will return fallback errors."
  echo "Set RAG_SPINE_URL env var before running, or deploy RAG Spine first."
  RAG_SPINE_URL="https://clinicos-rag-spine-placeholder.run.app"
fi

echo "=== Building and deploying ${SERVICE} ==="
echo "    MBS:    cloudos-consolidated (public IP)"
echo "    Accred: clinicos-emr-pg16-staging (private IP via VPC)"
echo "    RAG:    ${RAG_SPINE_URL}"
echo ""

gcloud run deploy "${SERVICE}" \
  --project="${PROJECT}" \
  --region="${REGION}" \
  --source=. \
  --vpc-connector="${VPC_CONNECTOR}" \
  --vpc-egress=private-ranges-only \
  --set-env-vars="MBS_USE_CLOUD_SQL_CONNECTOR=true" \
  --set-env-vars="MBS_CLOUD_SQL_CONNECTION=cloudos-478102:australia-southeast1:cloudos-consolidated" \
  --set-env-vars="MBS_DATABASE_USER=mcp_readonly" \
  --set-env-vars="MBS_DATABASE_NAME=clinicos_mbs" \
  --set-env-vars="ACCRED_USE_CLOUD_SQL_CONNECTOR=true" \
  --set-env-vars="ACCRED_CLOUD_SQL_CONNECTION=clinicos-emr-staging:australia-southeast1:clinicos-emr-pg16-staging" \
  --set-env-vars="ACCRED_DATABASE_USER=mcp_readonly" \
  --set-env-vars="ACCRED_DATABASE_NAME=clinicos_accreditation" \
  --set-env-vars="RAG_SPINE_URL=${RAG_SPINE_URL}" \
  --set-env-vars="MCP_TRANSPORT=streamable-http" \
  --set-env-vars="MCP_PORT=8080" \
  --set-secrets="MBS_DATABASE_PASSWORD=mcp-readonly-mbs-password:latest" \
  --set-secrets="ACCRED_DATABASE_PASSWORD=mcp-readonly-password:latest" \
  --memory=512Mi \
  --cpu=1 \
  --min-instances=0 \
  --max-instances=5 \
  --concurrency=10 \
  --timeout=30 \
  --allow-unauthenticated \
  --port=8080

echo ""
echo "=== Deployment complete ==="
SERVICE_URL=$(gcloud run services describe "${SERVICE}" --project="${PROJECT}" --region="${REGION}" --format="value(status.url)")
echo "URL: ${SERVICE_URL}"
echo ""
echo "Verify: curl ${SERVICE_URL}/mcp"
