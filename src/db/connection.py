import asyncpg
from src.config import Settings


async def _create_pool_direct(settings: Settings, database: str) -> asyncpg.Pool:
    """Create pool via direct TCP connection (dev/local)."""
    dsn = (
        f"postgresql://{settings.database_user}:{settings.database_password}"
        f"@{settings.database_host}:{settings.database_port}/{database}"
    )
    return await asyncpg.create_pool(dsn, min_size=1, max_size=5, command_timeout=10)


async def _create_pool_cloud_sql(settings: Settings, database: str) -> asyncpg.Pool:
    """Create pool via Cloud SQL Python Connector (production on Cloud Run)."""
    from google.cloud.sql.connector import Connector

    connector = Connector()

    async def getconn():
        return await connector.connect_async(
            settings.cloud_sql_connection_name,
            "asyncpg",
            user=settings.database_user,
            password=settings.database_password,
            db=database,
            ip_type="private",
        )

    return await asyncpg.create_pool(
        connect=getconn, min_size=1, max_size=5, command_timeout=10
    )


async def create_pools(settings: Settings) -> tuple[asyncpg.Pool, asyncpg.Pool]:
    """Create read-only connection pools for MBS and accreditation databases.

    Uses Cloud SQL Python Connector in production, direct TCP in dev.
    Returns (mbs_pool, accreditation_pool).
    """
    create = _create_pool_cloud_sql if settings.use_cloud_sql_connector else _create_pool_direct

    mbs_pool = await create(settings, settings.mbs_database_name)
    accreditation_pool = await create(settings, settings.accreditation_database_name)

    return mbs_pool, accreditation_pool


async def close_pools(*pools: asyncpg.Pool) -> None:
    """Close all connection pools."""
    for pool in pools:
        await pool.close()
