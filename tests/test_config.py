import os
from unittest.mock import patch


def test_settings_loads_defaults():
    """Config should load with sensible defaults for dev."""
    with patch.dict(os.environ, {
        "MBS_DATABASE_HOST": "localhost",
        "MBS_DATABASE_PORT": "5432",
        "MBS_DATABASE_USER": "mcp_readonly",
        "MBS_DATABASE_PASSWORD": "testpass",
        "MBS_DATABASE_NAME": "clinicos_mbs",
        "ACCRED_DATABASE_HOST": "localhost",
        "ACCRED_DATABASE_PORT": "5432",
        "ACCRED_DATABASE_USER": "mcp_readonly",
        "ACCRED_DATABASE_PASSWORD": "testpass",
        "ACCRED_DATABASE_NAME": "clinicos_accreditation",
        "RAG_SPINE_URL": "http://localhost:8001",
    }, clear=False):
        from src.config import Settings
        s = Settings()
        assert s.mbs_database_host == "localhost"
        assert s.mbs_database_port == 5432
        assert s.mbs_database_name == "clinicos_mbs"
        assert s.accred_database_name == "clinicos_accreditation"
        assert s.rag_spine_url == "http://localhost:8001"
        assert s.mbs_use_cloud_sql_connector is False
        assert s.accred_use_cloud_sql_connector is False
        assert s.mcp_transport == "stdio"


def test_settings_cloud_sql_mode():
    """Config should detect dual Cloud SQL connector mode."""
    with patch.dict(os.environ, {
        "MBS_DATABASE_USER": "mcp_readonly",
        "MBS_DATABASE_PASSWORD": "pass1",
        "MBS_DATABASE_NAME": "clinicos_mbs",
        "MBS_USE_CLOUD_SQL_CONNECTOR": "true",
        "MBS_CLOUD_SQL_CONNECTION": "cloudos-478102:australia-southeast1:cloudos-consolidated",
        "ACCRED_DATABASE_USER": "mcp_readonly",
        "ACCRED_DATABASE_PASSWORD": "pass2",
        "ACCRED_DATABASE_NAME": "clinicos_accreditation",
        "ACCRED_USE_CLOUD_SQL_CONNECTOR": "true",
        "ACCRED_CLOUD_SQL_CONNECTION": "clinicos-emr-staging:australia-southeast1:clinicos-emr-pg16-staging",
        "RAG_SPINE_URL": "http://localhost:8001",
    }, clear=False):
        from src.config import Settings
        s = Settings()
        assert s.mbs_use_cloud_sql_connector is True
        assert s.mbs_cloud_sql_connection == "cloudos-478102:australia-southeast1:cloudos-consolidated"
        assert s.accred_use_cloud_sql_connector is True
        assert s.accred_cloud_sql_connection == "clinicos-emr-staging:australia-southeast1:clinicos-emr-pg16-staging"
