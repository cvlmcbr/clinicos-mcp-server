from unittest.mock import AsyncMock
import pytest

from src.db.queries.racgp import lookup_racgp_indicators, is_indicator_code


@pytest.fixture
def mock_pool():
    return AsyncMock()


def test_is_indicator_code_valid():
    assert is_indicator_code("GP1.1A") is True
    assert is_indicator_code("QI2.3B") is True
    assert is_indicator_code("C1.1A") is True
    assert is_indicator_code("vaccine storage") is False
    assert is_indicator_code("GP") is False


@pytest.mark.asyncio
async def test_lookup_by_code(mock_pool):
    mock_pool.fetch.return_value = [
        {
            "indicator_code": "GP1.1A",
            "indicator_title": "Welcoming environment for Aboriginal peoples",
            "indicator_description": "The practice demonstrates...",
            "guidance": "Consider displaying...",
            "is_mandatory": False,
            "evidence_requirements": ["Policy document", "Photos"],
            "criterion_code": "GP1.1",
            "standard_code": "GP1",
            "standard_name": "Communication and the GP-patient relationship",
            "module_code": "GP",
            "module_name": "GP Standards",
        },
    ]
    result = await lookup_racgp_indicators(mock_pool, "GP1.1A")
    assert len(result) == 1
    assert result[0]["indicator_code"] == "GP1.1A"


@pytest.mark.asyncio
async def test_lookup_by_keyword(mock_pool):
    mock_pool.fetch.return_value = [
        {
            "indicator_code": "GP6.1A",
            "indicator_title": "Vaccine cold chain management",
            "indicator_description": "...",
            "guidance": "...",
            "is_mandatory": True,
            "evidence_requirements": ["Temperature logs"],
            "criterion_code": "GP6.1",
            "standard_code": "GP6",
            "standard_name": "Vaccine Storage and Immunisation",
            "module_code": "GP",
            "module_name": "GP Standards",
        },
    ]
    result = await lookup_racgp_indicators(mock_pool, "vaccine storage")
    assert len(result) >= 1


@pytest.mark.asyncio
async def test_lookup_with_module_filter(mock_pool):
    mock_pool.fetch.return_value = []
    await lookup_racgp_indicators(mock_pool, "clinical governance", module="QI")
    call_args = mock_pool.fetch.call_args
    sql = call_args[0][0]
    assert "m.code = $2" in sql
