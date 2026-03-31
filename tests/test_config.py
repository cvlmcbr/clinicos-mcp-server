import os
from unittest.mock import patch


def test_settings_loads_defaults():
    """Config should load with sensible defaults for dev."""
    with patch.dict(os.environ, {
        "DATABASE_HOST": "localhost",
        "DATABASE_PORT": "5432",
        "DATABASE_USER": "mcp_readonly",
        "DATABASE_PASSWORD": "testpass",
        "MBS_DATABASE_NAME": "clinicos_mbs",
        "ACCREDITATION_DATABASE_NAME": "clinicos_accreditation",
        "RAG_SPINE_URL": "http://localhost:8001",
    }, clear=False):
        from src.config import Settings
        s = Settings()
        assert s.database_host == "localhost"
        assert s.database_port == 5432
        assert s.mbs_database_name == "clinicos_mbs"
        assert s.rag_spine_url == "http://localhost:8001"
        assert s.use_cloud_sql_connector is False
        assert s.mcp_transport == "stdio"


def test_settings_cloud_sql_mode():
    """Config should detect Cloud SQL connector mode."""
    with patch.dict(os.environ, {
        "DATABASE_HOST": "localhost",
        "DATABASE_PORT": "5432",
        "DATABASE_USER": "mcp_readonly",
        "DATABASE_PASSWORD": "",
        "MBS_DATABASE_NAME": "clinicos_mbs",
        "ACCREDITATION_DATABASE_NAME": "clinicos_accreditation",
        "RAG_SPINE_URL": "http://localhost:8001",
        "USE_CLOUD_SQL_CONNECTOR": "true",
        "CLOUD_SQL_CONNECTION_NAME": "proj:region:instance",
    }, clear=False):
        from src.config import Settings
        s = Settings()
        assert s.use_cloud_sql_connector is True
        assert s.cloud_sql_connection_name == "proj:region:instance"
