import re
from typing import Any

import asyncpg

INDICATOR_CODE_PATTERN = re.compile(r"^[A-Z]{1,2}\d+\.\d+[A-Z]?$", re.IGNORECASE)


def is_indicator_code(query: str) -> bool:
    """Check if a query string looks like a RACGP indicator code (e.g. GP1.1A)."""
    return bool(INDICATOR_CODE_PATTERN.match(query.strip()))


async def lookup_racgp_indicators(
    pool: asyncpg.Pool,
    query: str,
    module: str | None = None,
) -> list[dict[str, Any]]:
    """Look up RACGP 5th Edition indicators by code or keyword.

    If query matches an indicator code pattern, does exact lookup.
    Otherwise searches title + description with ILIKE.
    Results capped at 10.
    """
    base_sql = """
        SELECT
            i.code AS indicator_code,
            i.title AS indicator_title,
            i.description AS indicator_description,
            i.guidance,
            i.is_mandatory,
            i.evidence_requirements,
            cr.code AS criterion_code,
            s.code AS standard_code,
            s.name AS standard_name,
            m.code AS module_code,
            m.name AS module_name
        FROM racgp_indicators i
        JOIN racgp_criteria cr ON cr.id = i.criterion_id
        JOIN racgp_standards s ON s.id = cr.standard_id
        JOIN racgp_modules m ON m.id = s.module_id
    """

    conditions = []
    params: list[Any] = []
    param_idx = 1

    if is_indicator_code(query):
        conditions.append(f"i.code ILIKE ${param_idx}")
        params.append(query.strip().upper())
        param_idx += 1
    else:
        conditions.append(f"(i.title ILIKE ${param_idx} OR i.description ILIKE ${param_idx})")
        params.append(f"%{query.strip()}%")
        param_idx += 1

    if module:
        conditions.append(f"m.code = ${param_idx}")
        params.append(module.upper())
        param_idx += 1

    where_clause = " WHERE " + " AND ".join(conditions)
    full_sql = base_sql + where_clause + " ORDER BY m.sort_order, s.sort_order, cr.sort_order, i.sort_order LIMIT 10"

    rows = await pool.fetch(full_sql, *params)
    return [dict(r) for r in rows]
