from unittest.mock import AsyncMock
import pytest

from src.db.queries.psr import check_psr_risk


@pytest.fixture
def mock_pool():
    return AsyncMock()


@pytest.mark.asyncio
async def test_psr_risk_found(mock_pool):
    """Should return matching PSR cases for a flagged item."""
    mock_pool.fetch.return_value = [
        {
            "case_reference": "PSR-2023-045",
            "severity_level": "high",
            "issue_description": "Routine upcoding from Level B to Level C",
            "repayment_amount": "450000.00",
            "lessons_learned": ["Document time spent", "Match item to complexity"],
            "recommendations": ["Use time-based billing"],
        },
    ]
    result = await check_psr_risk(mock_pool, "36")
    assert len(result) == 1
    assert result[0]["case_reference"] == "PSR-2023-045"


@pytest.mark.asyncio
async def test_psr_risk_clean(mock_pool):
    """Should return empty list for items with no PSR history."""
    mock_pool.fetch.return_value = []
    result = await check_psr_risk(mock_pool, "3")
    assert result == []
