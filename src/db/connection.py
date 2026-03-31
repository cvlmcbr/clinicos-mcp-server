import asyncpg
from src.config import Settings


async def create_pools(settings: Settings) -> tuple[asyncpg.Pool, asyncpg.Pool]:
    """Create read-only connection pools for MBS and accreditation databases.

    Returns (mbs_pool, accreditation_pool).
    """
    dsn_template = (
        f"postgresql://{settings.database_user}:{settings.database_password}"
        f"@{settings.database_host}:{settings.database_port}"
    )

    mbs_pool = await asyncpg.create_pool(
        f"{dsn_template}/{settings.mbs_database_name}",
        min_size=1,
        max_size=5,
        command_timeout=10,
    )

    accreditation_pool = await asyncpg.create_pool(
        f"{dsn_template}/{settings.accreditation_database_name}",
        min_size=1,
        max_size=5,
        command_timeout=10,
    )

    return mbs_pool, accreditation_pool


async def close_pools(*pools: asyncpg.Pool) -> None:
    """Close all connection pools."""
    for pool in pools:
        await pool.close()
