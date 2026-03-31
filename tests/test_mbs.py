from unittest.mock import AsyncMock
import pytest

from src.db.queries.mbs import lookup_mbs_item, suggest_mbs_items


@pytest.fixture
def mock_pool():
    return AsyncMock()


@pytest.mark.asyncio
async def test_lookup_mbs_item_found(mock_pool):
    """Should return item dict when item exists."""
    mock_pool.fetchrow.return_value = {
        "item_number": "23",
        "category": "GP Consultations",
        "subcategory": "Level B",
        "description": "Professional attendance...",
        "schedule_fee": "41.40",
        "time_estimate_minutes": 20,
        "documentation_requirements": {"required": ["clinical notes"], "recommended": [], "examples": []},
        "common_errors": ["Insufficient documentation"],
        "psr_risk_level": "low",
    }
    result = await lookup_mbs_item(mock_pool, "23")
    assert result is not None
    assert result["item_number"] == "23"
    assert result["schedule_fee"] == "41.40"


@pytest.mark.asyncio
async def test_lookup_mbs_item_not_found(mock_pool):
    """Should return None when item does not exist."""
    mock_pool.fetchrow.return_value = None
    result = await lookup_mbs_item(mock_pool, "99999")
    assert result is None


@pytest.mark.asyncio
async def test_suggest_mbs_items_by_consultation(mock_pool):
    """Should return matching items filtered by category and duration."""
    mock_pool.fetch.return_value = [
        {
            "item_number": "23",
            "category": "GP Consultations",
            "description": "Professional attendance, Level B",
            "schedule_fee": "41.40",
            "time_estimate_minutes": 20,
            "psr_risk_level": "low",
        },
    ]
    items, co_claims = await suggest_mbs_items(
        mock_pool, consultation_type="follow_up", duration_minutes=30
    )
    assert len(items) >= 1
    assert items[0]["item_number"] == "23"
    assert co_claims == []


@pytest.mark.asyncio
async def test_suggest_mbs_items_with_gpmp(mock_pool):
    """Should return co-claiming rules when care plan is GPMP."""
    mock_pool.fetch.return_value = [
        {
            "item_number": "23",
            "category": "GP Consultations",
            "description": "Level B",
            "schedule_fee": "41.40",
            "time_estimate_minutes": 20,
            "psr_risk_level": "low",
        },
    ]
    items, co_claims = await suggest_mbs_items(
        mock_pool, consultation_type="follow_up", duration_minutes=30, care_plan="GPMP"
    )
    assert len(items) >= 1
    assert len(co_claims) == 1
    assert co_claims[0]["item"] == "721"
