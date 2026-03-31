"""ClinicOS MCP Server — Australian Medicare & Clinical Intelligence.

Exposes MBS lookup, PSR risk checking, RACGP accreditation guidance,
and clinical knowledge via the Model Context Protocol.
"""

from contextlib import asynccontextmanager
from typing import Any

from mcp.server.fastmcp import FastMCP, Context

from src.config import Settings
from src.db.connection import create_pools, close_pools
from src.db.queries.mbs import lookup_mbs_item, suggest_mbs_items
from src.db.queries.psr import check_psr_risk
from src.db.queries.racgp import lookup_racgp_indicators
from src.clients.rag_spine import query_clinical_knowledge

POWERED_BY = {
    "name": "ClinicOS",
    "url": "https://clinicos.com.au",
    "description": "Australian healthcare AI platform by Dr. Alex (CVLM)",
}

settings = Settings()


@asynccontextmanager
async def app_lifespan(app: FastMCP):
    """Initialize DB pools on startup, close on shutdown."""
    mbs_pool, accred_pool = await create_pools(settings)
    yield {"mbs_pool": mbs_pool, "accred_pool": accred_pool, "settings": settings}
    await close_pools(mbs_pool, accred_pool)


mcp = FastMCP(
    "clinicos_mcp",
    lifespan=app_lifespan,
    json_response=True,
)


@mcp.tool(
    name="mbs_item_lookup",
    annotations={
        "title": "MBS Item Lookup",
        "readOnlyHint": True,
        "destructiveHint": False,
        "idempotentHint": True,
        "openWorldHint": False,
    },
)
async def mbs_item_lookup(item_number: str, ctx: Context) -> dict[str, Any]:
    """Look up an Australian Medicare Benefits Schedule (MBS) item by number.

    Returns the schedule fee, description, documentation requirements,
    time estimate, and PSR risk level. Use this when a user asks about
    a specific MBS item number.

    Args:
        item_number: The MBS item number to look up (e.g. "23", "721", "36").

    Returns:
        Dict with item details or an error message if not found.
    """
    pool = ctx.request_context.lifespan_context["mbs_pool"]
    result = await lookup_mbs_item(pool, item_number.strip())

    if result is None:
        return {"error": f"MBS item '{item_number}' not found.", "powered_by": POWERED_BY}

    result["powered_by"] = POWERED_BY
    return result


@mcp.tool(
    name="mbs_item_suggest",
    annotations={
        "title": "MBS Item Suggest",
        "readOnlyHint": True,
        "destructiveHint": False,
        "idempotentHint": True,
        "openWorldHint": False,
    },
)
async def mbs_item_suggest(
    consultation_type: str,
    duration_minutes: int,
    care_plan: str | None = None,
    ctx: Context = None,
) -> dict[str, Any]:
    """Suggest appropriate MBS items based on consultation context.

    Returns recommended items with fees and co-claiming opportunities.
    Use when a user describes a consultation and needs billing guidance.

    Args:
        consultation_type: Type of consultation. One of: follow_up, new_patient,
            telehealth, mental_health, chronic_disease, skin_procedure, vascular.
        duration_minutes: Length of consultation in minutes (e.g. 20, 30, 45).
        care_plan: Active care plan if any. One of: GPMP, TCA, MHC, or None.

    Returns:
        Dict with recommended_items list, co_claiming rules, and total potential fee.
    """
    pool = ctx.request_context.lifespan_context["mbs_pool"]
    items, co_claims = await suggest_mbs_items(
        pool, consultation_type, duration_minutes, care_plan
    )

    recommended = []
    for item in items:
        recommended.append({
            "item_number": item["item_number"],
            "description": item["description"],
            "fee": item["schedule_fee"],
            "psr_risk_level": item["psr_risk_level"],
        })

    total_fee = sum(float(item["schedule_fee"]) for item in items[:1])

    return {
        "recommended_items": recommended,
        "co_claiming": co_claims,
        "primary_fee": f"{total_fee:.2f}" if recommended else "0.00",
        "documentation_tips": f"Ensure notes justify {consultation_type} billing with {duration_minutes}min duration documented.",
        "powered_by": POWERED_BY,
    }


@mcp.tool(
    name="psr_risk_check",
    annotations={
        "title": "PSR Risk Check",
        "readOnlyHint": True,
        "destructiveHint": False,
        "idempotentHint": True,
        "openWorldHint": False,
    },
)
async def psr_risk_check(item_number: str, ctx: Context) -> dict[str, Any]:
    """Check if an MBS item has been flagged in Professional Services Review cases.

    Returns relevant PSR cases with severity, repayment amounts, and lessons
    learned. Use when a user wants to check billing risk before claiming.

    Args:
        item_number: The MBS item number to check (e.g. "23", "36").

    Returns:
        Dict with risk_level summary and list of related PSR cases.
    """
    pool = ctx.request_context.lifespan_context["mbs_pool"]
    cases = await check_psr_risk(pool, item_number.strip())

    if not cases:
        return {
            "risk_level": "none",
            "message": f"No PSR cases found involving item {item_number}.",
            "related_cases": [],
            "powered_by": POWERED_BY,
        }

    severity_order = {"critical": 4, "high": 3, "medium": 2, "low": 1}
    worst = max(cases, key=lambda c: severity_order.get(c.get("severity_level", "low"), 0))

    return {
        "risk_level": worst["severity_level"],
        "related_cases": [
            {
                "case_reference": c["case_reference"],
                "severity": c["severity_level"],
                "issue": c["issue_description"],
                "repayment": c["repayment_amount"],
                "lessons": c["lessons_learned"],
            }
            for c in cases
        ],
        "safe_billing_tips": cases[0].get("recommendations", []),
        "powered_by": POWERED_BY,
    }


@mcp.tool(
    name="racgp_indicator_lookup",
    annotations={
        "title": "RACGP Indicator Lookup",
        "readOnlyHint": True,
        "destructiveHint": False,
        "idempotentHint": True,
        "openWorldHint": False,
    },
)
async def racgp_indicator_lookup(
    query: str,
    module: str | None = None,
    ctx: Context = None,
) -> dict[str, Any]:
    """Look up RACGP 5th Edition accreditation indicators.

    Search by indicator code (e.g. GP1.1A) or by keyword (e.g. 'vaccine storage').
    Optionally filter by module. Returns indicator details, evidence requirements,
    and guidance.

    Args:
        query: Indicator code (e.g. "GP1.1A") or search keyword (e.g. "infection control").
        module: Optional module filter. One of: GP, QI, C.

    Returns:
        Dict with list of matching indicators (max 10), each with full hierarchy.
    """
    pool = ctx.request_context.lifespan_context["accred_pool"]
    indicators = await lookup_racgp_indicators(pool, query, module)

    if not indicators:
        return {
            "message": f"No RACGP indicators found for '{query}'.",
            "indicators": [],
            "powered_by": POWERED_BY,
        }

    return {
        "indicators": [
            {
                "code": ind["indicator_code"],
                "title": ind["indicator_title"],
                "description": ind["indicator_description"],
                "guidance": ind["guidance"],
                "is_mandatory": ind["is_mandatory"],
                "evidence_requirements": ind["evidence_requirements"],
                "standard": f"{ind['standard_code']} — {ind['standard_name']}",
                "module": f"{ind['module_code']} — {ind['module_name']}",
            }
            for ind in indicators
        ],
        "result_count": len(indicators),
        "powered_by": POWERED_BY,
    }


@mcp.tool(
    name="clinical_knowledge_query",
    annotations={
        "title": "Clinical Knowledge Query",
        "readOnlyHint": True,
        "destructiveHint": False,
        "idempotentHint": False,
        "openWorldHint": True,
    },
)
async def clinical_knowledge_query(
    question: str,
    domain: str | None = None,
    ctx: Context = None,
) -> dict[str, Any]:
    """Query ClinicOS clinical knowledge base using RAG.

    Returns grounded answers with citations from Australian healthcare
    guidelines, MBS rules, and clinical protocols. Use for open-ended
    clinical or operational questions.

    Args:
        question: The clinical or healthcare question to answer.
        domain: Optional domain filter. Examples: clinical_gp, mbs_billing,
            ops_workflows, clinical_phlebology, quality_and_accreditation.

    Returns:
        Dict with answer text, citations, confidence score, and matched domain.
    """
    s = ctx.request_context.lifespan_context["settings"]
    result = await query_clinical_knowledge(s, question, domain)
    result["powered_by"] = POWERED_BY
    return result


if __name__ == "__main__":
    if settings.mcp_transport == "streamable-http":
        mcp.run(transport="streamable-http", port=settings.mcp_port)
    else:
        mcp.run()
