from typing import Any

import asyncpg

CONSULTATION_TYPE_CATEGORIES = {
    "follow_up": "General Practice",
    "new_patient": "General Practice",
    "telehealth": "Telehealth",
    "mental_health": "Mental Health",
    "chronic_disease": "Chronic Disease Management",
    "skin_procedure": "Surgical Procedures",
    "vascular": "Surgical Procedures",
}

CO_CLAIMING_RULES: dict[tuple[str, str], list[dict[str, str]]] = {
    ("General Practice", "GPMP"): [
        {"item": "721", "rule": "GPMP preparation", "conditions": "Once per 12 months per patient"},
    ],
    ("General Practice", "TCA"): [
        {"item": "723", "rule": "Team care arrangement", "conditions": "Once per 12 months per patient"},
    ],
    ("General Practice", "MHC"): [
        {"item": "2700", "rule": "Mental health treatment plan", "conditions": "Once per calendar year"},
        {"item": "2701", "rule": "MH plan review", "conditions": "Up to 5 reviews per plan"},
    ],
}


async def lookup_mbs_item(pool: asyncpg.Pool, item_number: str) -> dict[str, Any] | None:
    """Look up a single MBS item by item number."""
    row = await pool.fetchrow(
        """
        SELECT item_number, category, subcategory, description, schedule_fee,
               time_estimate_minutes, documentation_requirements, common_errors,
               psr_risk_level
        FROM mbs_items
        WHERE item_number = $1
        """,
        item_number,
    )
    return dict(row) if row else None


async def suggest_mbs_items(
    pool: asyncpg.Pool,
    consultation_type: str,
    duration_minutes: int,
    care_plan: str | None = None,
) -> tuple[list[dict[str, Any]], list[dict[str, str]]]:
    """Suggest MBS items based on consultation context.

    Returns (items, co_claims).
    """
    category = CONSULTATION_TYPE_CATEGORIES.get(consultation_type, "GP Consultations")

    rows = await pool.fetch(
        """
        SELECT item_number, category, description, schedule_fee,
               time_estimate_minutes, psr_risk_level
        FROM mbs_items
        WHERE category = $1
          AND (time_estimate_minutes IS NULL
               OR time_estimate_minutes BETWEEN $2 AND $3)
        ORDER BY schedule_fee DESC
        LIMIT 5
        """,
        category,
        max(0, duration_minutes - 15),
        duration_minutes + 15,
    )

    items = [dict(r) for r in rows]
    co_claims = []
    if care_plan:
        co_claims = CO_CLAIMING_RULES.get((category, care_plan.upper()), [])

    return items, co_claims
