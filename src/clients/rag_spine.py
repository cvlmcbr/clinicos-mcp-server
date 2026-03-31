from typing import Any

import httpx

from src.config import Settings


async def query_clinical_knowledge(
    settings: Settings,
    question: str,
    domain: str | None = None,
) -> dict[str, Any]:
    """Query RAG Spine for clinical knowledge.

    Returns structured answer with citations, or a fallback error dict
    if the service is unavailable.
    """
    payload: dict[str, Any] = {"question": question, "options": {"top_k": 5}}
    if domain:
        payload["options"]["domain"] = domain

    headers = {"x-tenant-id": settings.rag_spine_tenant_id}

    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{settings.rag_spine_url}/v1/query",
                json=payload,
                headers=headers,
                timeout=settings.rag_spine_timeout_seconds,
            )
            response.raise_for_status()
            data = response.json()

        answer_block = data.get("answer", {})
        return {
            "answer": answer_block.get("text", ""),
            "citations": answer_block.get("citations", []),
            "confidence": answer_block.get("confidence", 0.0),
            "domain_matched": answer_block.get("meta", {}).get("domain", "unknown"),
        }

    except (httpx.TimeoutException, httpx.ConnectError):
        return {
            "error": "Knowledge base temporarily unavailable. Try mbs_item_lookup or racgp_indicator_lookup for specific queries.",
            "answer": "",
            "citations": [],
            "confidence": 0.0,
        }
    except httpx.HTTPStatusError as e:
        return {
            "error": f"Knowledge base returned error: {e.response.status_code}",
            "answer": "",
            "citations": [],
            "confidence": 0.0,
        }
