import asyncpg
from src.config import Settings


async def _create_pool_direct(
    host: str, port: int, user: str, password: str, database: str,
) -> asyncpg.Pool:
    """Create pool via direct TCP connection (dev/local)."""
    dsn = f"postgresql://{user}:{password}@{host}:{port}/{database}"
    return await asyncpg.create_pool(dsn, min_size=1, max_size=5, command_timeout=10)


async def _create_pool_cloud_sql(
    connection_name: str, user: str, password: str, database: str, ip_type: str,
) -> asyncpg.Pool:
    """Create pool via Cloud SQL Python Connector (production on Cloud Run)."""
    from google.cloud.sql.connector import Connector

    connector = Connector()

    async def getconn():
        return await connector.connect_async(
            connection_name, "asyncpg",
            user=user, password=password, db=database, ip_type=ip_type,
        )

    return await asyncpg.create_pool(
        connect=getconn, min_size=1, max_size=5, command_timeout=10,
    )


async def create_pools(settings: Settings) -> tuple[asyncpg.Pool, asyncpg.Pool]:
    """Create read-only connection pools for MBS and accreditation databases.

    MBS: cloudos-consolidated (public IP) in project cloudos-478102
    Accreditation: clinicos-emr-pg16-staging (private IP) in project clinicos-emr-staging

    Returns (mbs_pool, accreditation_pool).
    """
    if settings.mbs_use_cloud_sql_connector:
        mbs_pool = await _create_pool_cloud_sql(
            settings.mbs_cloud_sql_connection,
            settings.mbs_database_user, settings.mbs_database_password,
            settings.mbs_database_name, ip_type="public",
        )
    else:
        mbs_pool = await _create_pool_direct(
            settings.mbs_database_host, settings.mbs_database_port,
            settings.mbs_database_user, settings.mbs_database_password,
            settings.mbs_database_name,
        )

    if settings.accred_use_cloud_sql_connector:
        accred_pool = await _create_pool_cloud_sql(
            settings.accred_cloud_sql_connection,
            settings.accred_database_user, settings.accred_database_password,
            settings.accred_database_name, ip_type="private",
        )
    else:
        accred_pool = await _create_pool_direct(
            settings.accred_database_host, settings.accred_database_port,
            settings.accred_database_user, settings.accred_database_password,
            settings.accred_database_name,
        )

    return mbs_pool, accred_pool


async def close_pools(*pools: asyncpg.Pool) -> None:
    """Close all connection pools."""
    for pool in pools:
        await pool.close()
