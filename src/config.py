from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """MCP server configuration. Loaded from environment variables."""

    # Database
    database_host: str = "localhost"
    database_port: int = 5432
    database_user: str = "mcp_readonly"
    database_password: str = ""
    mbs_database_name: str = "clinicos_mbs"
    accreditation_database_name: str = "clinicos_accreditation"

    # Cloud SQL (production)
    use_cloud_sql_connector: bool = False
    cloud_sql_connection_name: str = ""

    # RAG Spine
    rag_spine_url: str = "http://localhost:8001"
    rag_spine_tenant_id: str = "public"
    rag_spine_timeout_seconds: float = 15.0

    # Server
    mcp_transport: str = "stdio"
    mcp_port: int = 8000

    model_config = {"env_file": ".env", "extra": "ignore"}
