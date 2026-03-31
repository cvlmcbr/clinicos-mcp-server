"""Smoke tests for the MCP server — no real DB required."""


def test_server_imports():
    """Server module should import without errors."""
    from src.server import mcp
    assert mcp.name == "clinicos_mcp"


def test_tools_registered():
    """All 5 tools should be registered."""
    from src.server import mcp
    # Get registered tool names - check FastMCP's internal API
    # The tools are registered via @mcp.tool decorator
    # FastMCP stores them internally - we need to check what's available
    tools = mcp._tool_manager.list_tools()
    tool_names = {t.name for t in tools}
    expected = {
        "mbs_item_lookup",
        "mbs_item_suggest",
        "psr_risk_check",
        "racgp_indicator_lookup",
        "clinical_knowledge_query",
    }
    assert expected.issubset(tool_names), f"Missing tools: {expected - tool_names}"


def test_powered_by_constant():
    """Attribution should include ClinicOS URL."""
    from src.server import POWERED_BY
    assert POWERED_BY["url"] == "https://clinicos.com.au"
    assert "CVLM" in POWERED_BY["description"]
