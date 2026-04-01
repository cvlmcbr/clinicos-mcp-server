# Long-Acting Agent Workflow

> **Purpose**: Enable consistent, multi-session AI-assisted development with full context preservation.
> This workflow ensures continuity between sessions by storing all context in files, not agent memory.

---

## Session Start Protocol

### Step 1: Get Your Bearings

Before touching any code, understand where the project stands:

```bash
# 1. Check project structure
pwd && ls -la

# 2. Read development history (last 5 sessions)
tail -100 docs/DEV_MEMORY/claude_dev_log.md

# 3. Check recent git activity
git log --oneline -20

# 4. Review feature status
cat docs/DEV_MEMORY/feature_checklist.json
```

**Questions to answer:**
- What was completed in the last session?
- What was attempted but failed?
- What should this session focus on?
- Are there any blockers or known issues?

---

### Step 2: Start Development Environment

```bash
# Run the project-specific init script
./scripts/init_dev.sh
```

**Wait for health checks to pass.** The script will:
- Install dependencies if needed
- Start development servers
- Run smoke tests
- Report any issues

**If environment fails to start:**
1. Read the error messages carefully
2. Fix the issue FIRST before continuing
3. Document the fix in the dev log
4. Re-run init_dev.sh

---

### Step 3: Choose ONE Feature to Work On

**Critical Rule: Work on exactly ONE feature per session.**

Select from `docs/DEV_MEMORY/feature_checklist.json`:
1. Find the highest priority item with status `pending` or `in-progress`
2. Priority order: `critical` > `high` > `medium` > `low`
3. If a feature is `blocked`, check if the blocker has been resolved

**Announce your choice:**
```
Working on: feature-XXX (description)
Priority: high
Current status: in-progress
```

---

### Step 4: Read Relevant Documentation

Before implementing, understand the context:

```bash
# Read feature-specific docs if they exist
cat docs/features/feature-XXX.md 2>/dev/null || echo "No feature doc"

# Check for known issues
grep -i "feature-XXX" docs/DEV_MEMORY/claude_dev_log.md | tail -20
```

**Understand:**
- What exactly needs to be built?
- Are there acceptance criteria?
- What has been tried before?
- Any known pitfalls?

---

### Step 5: Implement the Feature (TDD Approach)

**Test-Driven Development:**

1. **Write tests first**
   ```bash
   # Create/update test file for the feature
   # Tests should fail initially
   ```

2. **Run tests to confirm they fail**
   ```bash
   npm test          # JavaScript/TypeScript
   python -m pytest  # Python
   ```

3. **Implement minimal code to pass tests**

4. **Run tests again to confirm they pass**

5. **Refactor if needed, keeping tests green**

**Best Practices:**
- Make small, incremental changes
- Commit working code frequently
- Don't break existing functionality
- Follow project coding standards

---

### Step 6: Test End-to-End

After unit tests pass, verify the feature works in practice:

**API Testing (if applicable):**
```bash
# Test the endpoint directly
curl -X GET http://localhost:3000/api/your-endpoint
curl -X POST http://localhost:3000/api/your-endpoint -d '{"test": "data"}'
```

**Database Verification (if applicable):**
```bash
# Check data was persisted correctly
# Use project-specific database CLI
```

**Manual UI Testing (if applicable):**
- Open the app in browser
- Test the user flow
- Check for visual regressions
- Verify error handling

---

### Step 7: Update Feature Checklist

Update `docs/DEV_MEMORY/feature_checklist.json`:

```json
{
  "id": "feature-XXX",
  "status": "passing",  // or "failing" if tests fail
  "passes": true,       // or false
  "last_updated": "2026-01-16",
  "notes": "Implemented login validation"
}
```

**Update statistics:**
```json
"statistics": {
  "total_features": N,
  "passing": X,
  "failing": Y,
  "completion_percentage": Z
}
```

---

### Step 8: Commit Your Work

**Commit with a structured message:**

```bash
git add .
git commit -m "feat(feature-XXX): Brief description

- What was implemented
- What was tested
- Any known limitations

Fixes: feature-XXX"
```

**Commit message format:**
- `feat(scope): description` - New feature
- `fix(scope): description` - Bug fix
- `refactor(scope): description` - Code restructuring
- `docs(scope): description` - Documentation only
- `test(scope): description` - Test only changes

---

### Step 9: Update Development Log

Add a session entry to `docs/DEV_MEMORY/claude_dev_log.md`:

```markdown
### Session N - YYYY-MM-DD HH:MM

**Feature worked on:** feature-XXX (description)
**Status:** completed | in-progress | blocked

**What was done:**
- Bullet point of accomplishment 1
- Bullet point of accomplishment 2

**Bugs encountered:**
- Bug description and how it was resolved

**Lessons learned:**
- Pattern or insight discovered

**Next session should:**
- Specific guidance for continuation

**Git commit:** `abc1234`
**Tests:** passing | failing (X/Y)
```

---

### Step 10: Session End Checklist

Before ending the session, verify:

**Code Quality:**
- [ ] Code compiles/runs without errors
- [ ] No linting errors
- [ ] No hardcoded secrets or credentials
- [ ] No TODO comments left unaddressed

**Testing:**
- [ ] All existing tests pass
- [ ] New tests written for new functionality
- [ ] Manual testing completed

**Documentation:**
- [ ] Development log updated
- [ ] Feature checklist updated
- [ ] Next steps clearly documented

**Environment:**
- [ ] No broken database migrations
- [ ] Development server can restart cleanly
- [ ] All temporary files cleaned up

**Git:**
- [ ] All changes committed
- [ ] Commit message follows format
- [ ] No sensitive data in commit

---

## Emergency Procedures

### If Tests Are Failing

```bash
# Run tests with verbose output
npm test -- --verbose
python -m pytest -v

# Check for recent changes that broke tests
git diff HEAD~3

# If stuck, document in dev log and mark feature as blocked
```

### If Environment Won't Start

```bash
# Clean and reinstall
rm -rf node_modules && npm install  # JavaScript
rm -rf venv && python -m venv venv && pip install -r requirements.txt  # Python

# Check for port conflicts
lsof -i :3000
lsof -i :8000

# Kill stray processes
./scripts/stop_dev.sh
```

### If You're Stuck

1. Document exactly what you tried
2. Document the error messages
3. Mark the feature as `blocked`
4. Provide clear guidance for the next session
5. End the session cleanly

**Remember: It's better to end a session with good documentation than to push broken code.**

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `docs/DEV_MEMORY/claude_dev_log.md` | Session history and context |
| `docs/DEV_MEMORY/feature_checklist.json` | Feature status tracking |
| `scripts/init_dev.sh` | Start development environment |
| `scripts/stop_dev.sh` | Stop development environment |
| `.cliniccode/session_end_checklist.md` | Quality verification checklist |

---

## Philosophy

**Stateless Continuity**: Each session starts fresh, but context is preserved in files.

**One Feature Per Session**: Focused work prevents scope creep and enables clean commits.

**Documentation First**: Write what you'll do, do it, write what you did.

**Quality Gates**: Don't end a session without verifying the checklist.

**No Tribal Knowledge**: Everything that matters is written down and searchable.
