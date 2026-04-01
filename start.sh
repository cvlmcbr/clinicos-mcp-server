#!/bin/bash

# Quick launcher for clinicos-mcp-server
# Opens VS Code and provides instructions for starting a Claude session

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  clinicos-mcp-server - Development Session"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Open VS Code
echo "Opening VS Code..."
code .

echo ""
echo "Next steps:"
echo "  1. Open Claude Code or Claude chat"
echo "  2. Copy and paste: .claude-harness/coding_agent_workflow.md"
echo "  3. Let Claude work!"
echo ""
echo "Or run: cat .claude-harness/coding_agent_workflow.md | pbcopy"
echo "         (copies workflow to clipboard)"
echo ""
