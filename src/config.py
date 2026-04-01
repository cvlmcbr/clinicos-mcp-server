from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """MCP server configuration. Loaded from environment variables.

    Two separate database connections are required:
    - MBS: cloudos-consolidated (public IP) in project cloudos-478102
    - Accreditation: clinicos-emr-pg16-staging (private IP) in project clinicos-emr-staging
    """

    # MBS instance (cloudos-consolidated, PUBLIC IP, project cloudos-478102)
    mbs_database_host: str = "localhost"
    mbs_database_port: int = 5432
    mbs_database_user: str = "mcp_readonly"
    mbs_database_password: str = ""
    mbs_database_name: str = "clinicos_mbs"
    mbs_use_cloud_sql_connector: bool = False
    mbs_cloud_sql_connection: str = "cloudos-478102:australia-southeast1:cloudos-consolidated"

    # Accreditation instance (clinicos-emr-pg16-staging, PRIVATE IP, project clinicos-emr-staging)
    accred_database_host: str = "localhost"
    accred_database_port: int = 5432
    accred_database_user: str = "mcp_readonly"
    accred_database_password: str = ""
    accred_database_name: str = "clinicos_accreditation"
    accred_use_cloud_sql_connector: bool = False
    accred_cloud_sql_connection: str = "clinicos-emr-staging:australia-southeast1:clinicos-emr-pg16-staging"

    # RAG Spine
    rag_spine_url: str = "http://localhost:8001"
    rag_spine_tenant_id: str = "public"
    rag_spine_timeout_seconds: float = 15.0

    # Server
    mcp_transport: str = "stdio"
    mcp_port: int = 8000

    model_config = {"env_file": ".env", "extra": "ignore"}
