from typing import Any

import asyncpg


async def check_psr_risk(pool: asyncpg.Pool, item_number: str) -> list[dict[str, Any]]:
    """Find PSR cases where the given MBS item was involved."""
    rows = await pool.fetch(
        """
        SELECT case_reference, severity_level, issue_description,
               repayment_amount, lessons_learned, recommendations
        FROM psr_cases
        WHERE item_numbers_involved @> $1::jsonb
        ORDER BY severity_level DESC, repayment_amount DESC NULLS LAST
        """,
        f'["{item_number}"]',
    )
    return [dict(r) for r in rows]
