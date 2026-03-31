from unittest.mock import AsyncMock, MagicMock, patch
import pytest

from src.config import Settings


@pytest.fixture
def dev_settings():
    return Settings(
        database_host="localhost",
        database_port=5432,
        database_user="mcp_readonly",
        database_password="testpass",
        mbs_database_name="clinicos_mbs",
        accreditation_database_name="clinicos_accreditation",
        use_cloud_sql_connector=False,
    )


@pytest.mark.asyncio
async def test_create_pools_returns_two_pools(dev_settings):
    """Should create separate pools for MBS and accreditation databases."""
    mock_pool = MagicMock()
    mock_create_pool = AsyncMock(return_value=mock_pool)
    with patch("src.db.connection.asyncpg.create_pool", mock_create_pool) as mock_create:
        from src.db.connection import create_pools
        mbs_pool, accred_pool = await create_pools(dev_settings)
        assert mock_create.call_count == 2
        first_call = mock_create.call_args_list[0]
        assert "clinicos_mbs" in str(first_call)
        second_call = mock_create.call_args_list[1]
        assert "clinicos_accreditation" in str(second_call)


@pytest.mark.asyncio
async def test_close_pools():
    """Should close both pools gracefully."""
    mock_pool = AsyncMock()
    from src.db.connection import close_pools
    await close_pools(mock_pool, mock_pool)
    assert mock_pool.close.call_count == 2
