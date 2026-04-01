# clinicos-mcp-server - Development Harness

This project has been configured with a **Long-Acting Agent Harness** for AI-assisted development.

## Quick Start

```bash
./start.sh
```

This opens VS Code. Then:
1. Open Claude Code (or paste workflow into Claude chat)
2. Copy-paste `.claude-harness/coding_agent_workflow.md` as the initial prompt
3. Claude will read context and begin working

## Project Type

**Detected**: python

## Key Files

| File | Purpose |
|------|---------|
| `.claude-harness/coding_agent_workflow.md` | Main session workflow |
| `.claude-harness/session_end_checklist.md` | Quality verification |
| `docs/DEV_MEMORY/claude_dev_log.md` | Session history |
| `docs/DEV_MEMORY/feature_checklist.json` | Feature tracking |
| `scripts/init_dev.sh` | Start dev environment |
| `scripts/stop_dev.sh` | Stop dev environment |

## How It Works

1. **Session Start**: Claude reads dev log and feature checklist for context
2. **Work**: Claude picks ONE feature and implements it
3. **Session End**: Claude updates logs and verifies checklist
4. **Repeat**: Next session starts fresh but has full context from files

## Manual Commands

```bash
# Start development environment
./scripts/init_dev.sh

# Stop development environment
./scripts/stop_dev.sh

# View session history
tail -100 docs/DEV_MEMORY/claude_dev_log.md

# View feature status
cat docs/DEV_MEMORY/feature_checklist.json
```
