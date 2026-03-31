from unittest.mock import AsyncMock, patch, MagicMock
import pytest
import httpx

from src.clients.rag_spine import query_clinical_knowledge
from src.config import Settings


@pytest.fixture
def settings():
    return Settings(
        rag_spine_url="http://localhost:8001",
        rag_spine_tenant_id="public",
        rag_spine_timeout_seconds=5.0,
    )


@pytest.mark.asyncio
async def test_query_success(settings):
    """Should return answer with citations on success."""
    mock_response = httpx.Response(
        200,
        json={
            "answer": {
                "text": "Chronic disease management requires...",
                "citations": [{"source": "MBS Online", "text": "Item 721..."}],
                "confidence": 0.85,
                "meta": {"domain": "clinical_gp"},
            }
        },
        request=httpx.Request("POST", "http://localhost:8001/v1/query"),
    )
    with patch("src.clients.rag_spine.httpx.AsyncClient") as MockClient:
        mock_client = AsyncMock()
        mock_client.post.return_value = mock_response
        mock_client.__aenter__ = AsyncMock(return_value=mock_client)
        mock_client.__aexit__ = AsyncMock(return_value=False)
        MockClient.return_value = mock_client

        result = await query_clinical_knowledge(settings, "What is chronic disease management?")

    assert result["answer"] == "Chronic disease management requires..."
    assert len(result["citations"]) == 1
    assert result["confidence"] == 0.85


@pytest.mark.asyncio
async def test_query_timeout(settings):
    """Should return fallback on timeout."""
    with patch("src.clients.rag_spine.httpx.AsyncClient") as MockClient:
        mock_client = AsyncMock()
        mock_client.post.side_effect = httpx.TimeoutException("timed out")
        mock_client.__aenter__ = AsyncMock(return_value=mock_client)
        mock_client.__aexit__ = AsyncMock(return_value=False)
        MockClient.return_value = mock_client

        result = await query_clinical_knowledge(settings, "test question")

    assert "error" in result
    assert "unavailable" in result["error"].lower()
