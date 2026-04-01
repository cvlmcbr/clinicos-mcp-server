#!/bin/bash
# Deploy ClinicOS MCP Server to Cloud Run
# Usage: ./scripts/deploy.sh

set -euo pipefail

PROJECT=clinicos-emr-staging
REGION=australia-southeast1
SERVICE=clinicos-mcp-server
IMAGE="${REGION}-docker.pkg.dev/${PROJECT}/cloud-run-source-deploy/${SERVICE}"
VPC_CONNECTOR=clinicos-vpc-staging
CLOUD_SQL_CONNECTION=clinicos-emr-staging:australia-southeast1:clinicos-emr-pg16-staging

echo "=== Building and deploying ${SERVICE} ==="

# Build with Cloud Build and deploy to Cloud Run in one step
gcloud run deploy "${SERVICE}" \
  --project="${PROJECT}" \
  --region="${REGION}" \
  --source=. \
  --vpc-connector="${VPC_CONNECTOR}" \
  --vpc-egress=private-ranges-only \
  --set-env-vars="USE_CLOUD_SQL_CONNECTOR=true" \
  --set-env-vars="CLOUD_SQL_CONNECTION_NAME=${CLOUD_SQL_CONNECTION}" \
  --set-env-vars="DATABASE_USER=mcp_readonly" \
  --set-secrets="DATABASE_PASSWORD=mcp-readonly-password:latest" \
  --set-env-vars="MBS_DATABASE_NAME=clinicos_mbs" \
  --set-env-vars="ACCREDITATION_DATABASE_NAME=clinicos_accreditation" \
  --set-env-vars="RAG_SPINE_URL=https://clinicos-rag-spine-sjbwpijelq-ts.a.run.app" \
  --set-env-vars="MCP_TRANSPORT=streamable-http" \
  --set-env-vars="MCP_PORT=8080" \
  --memory=256Mi \
  --cpu=1 \
  --min-instances=0 \
  --max-instances=5 \
  --concurrency=10 \
  --timeout=30 \
  --allow-unauthenticated \
  --port=8080

echo ""
echo "=== Deployment complete ==="
gcloud run services describe "${SERVICE}" --project="${PROJECT}" --region="${REGION}" --format="value(status.url)"
