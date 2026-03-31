# Changelog

All notable changes to this project will be documented in this file.
Format based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added
- FastMCP server with 5 tools: mbs_item_lookup, mbs_item_suggest, psr_risk_check, racgp_indicator_lookup, clinical_knowledge_query
- asyncpg connection pools for MBS and accreditation databases (read-only)
- httpx client for RAG Spine with timeout fallback
- pydantic-settings configuration
- Dockerfile for Cloud Run deployment
- Full test suite with mocked DB queries
