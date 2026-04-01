# Session End Checklist

> **Before ending any session, verify ALL items below.**
> This prevents broken builds, lost context, and wasted time in future sessions.

---

## 1. Code Quality

- [ ] **Compiles/Runs**: Code executes without syntax errors
- [ ] **No Linting Errors**: `npm run lint` or equivalent passes
- [ ] **No Hardcoded Values**: Secrets, API keys, and credentials use environment variables
- [ ] **No Debug Code**: Remove console.logs, print statements, and test data
- [ ] **Code Follows Standards**: Matches project's existing style and patterns

**Quick Check:**
```bash
# JavaScript/TypeScript
npm run lint
npm run build

# Python
python -m flake8 .
python -m mypy .
```

---

## 2. Testing

- [ ] **Existing Tests Pass**: All pre-existing tests still work
- [ ] **New Tests Written**: New functionality has test coverage
- [ ] **Edge Cases Covered**: Error handling and boundary conditions tested
- [ ] **Integration Tested**: Feature works with the rest of the system

**Quick Check:**
```bash
# JavaScript/TypeScript
npm test

# Python
python -m pytest
```

---

## 3. Feature Status

- [ ] **Feature Checklist Updated**: `docs/DEV_MEMORY/feature_checklist.json` reflects current state
- [ ] **Status Accurate**: Feature marked as `passing`, `failing`, `in-progress`, or `blocked`
- [ ] **Statistics Updated**: Total/passing/failing counts are correct
- [ ] **Notes Added**: Any relevant context for future sessions

**Verify:**
```bash
cat docs/DEV_MEMORY/feature_checklist.json | jq '.statistics'
```

---

## 4. Documentation

- [ ] **Dev Log Updated**: Session entry added to `docs/DEV_MEMORY/claude_dev_log.md`
- [ ] **What Was Done**: Clear bullet points of accomplishments
- [ ] **Bugs Documented**: Any issues encountered and resolutions
- [ ] **Next Steps Clear**: Specific guidance for continuing the work
- [ ] **Lessons Learned**: Patterns or insights worth remembering

**Session Entry Template:**
```markdown
### Session N - YYYY-MM-DD HH:MM

**Feature worked on:** feature-XXX (description)
**Status:** completed | in-progress | blocked

**What was done:**
-

**Bugs encountered:**
-

**Lessons learned:**
-

**Next session should:**
-

**Git commit:** `hash`
**Tests:** passing | failing
```

---

## 5. Environment State

- [ ] **Clean State**: No broken database migrations or corrupted data
- [ ] **Restartable**: `./scripts/init_dev.sh` would work for next session
- [ ] **No Port Conflicts**: All servers can restart on expected ports
- [ ] **Temp Files Cleaned**: No leftover test files, logs, or artifacts

**Verify:**
```bash
# Stop environment
./scripts/stop_dev.sh

# Verify clean restart would work
./scripts/init_dev.sh && ./scripts/stop_dev.sh
```

---

## 6. Git Status

- [ ] **All Changes Committed**: `git status` shows clean working tree
- [ ] **Commit Message Format**: Follows `type(scope): description` format
- [ ] **Feature Reference**: Commit includes `Fixes: feature-XXX` or similar
- [ ] **No Sensitive Data**: No secrets, credentials, or personal data in commit
- [ ] **No Large Files**: No binaries or generated files committed

**Verify:**
```bash
git status
git log -1 --format='%s%n%n%b'
```

---

## 7. Next Session Guidance

- [ ] **Clear Starting Point**: Next session knows exactly where to begin
- [ ] **Blockers Documented**: Any issues that need resolution are noted
- [ ] **Dependencies Listed**: External requirements or waiting items
- [ ] **Priority Clear**: What's most important to work on next

**Good Example:**
```markdown
**Next session should:**
- Continue implementing user authentication (login endpoint done, need logout)
- Fix the failing test in user.test.ts (see bug note above)
- Review and merge PR #42 if approved
- Priority: Complete auth before moving to dashboard
```

**Bad Example:**
```markdown
**Next session should:**
- Keep working on stuff
```

---

## Final Verification

Before closing:

1. **Re-read your dev log entry** - Would a fresh agent understand it?
2. **Check feature_checklist.json** - Is the status accurate?
3. **Run `git status`** - Is everything committed?
4. **Stop the environment** - `./scripts/stop_dev.sh`

---

## If You Can't Complete the Checklist

**If tests are failing:**
- Document exactly which tests fail and why
- Mark feature as `failing` in checklist
- Commit with message noting failing tests
- Provide fix guidance for next session

**If environment is broken:**
- Document the error messages
- List troubleshooting steps attempted
- Mark relevant feature as `blocked`
- Provide recovery guidance

**If you ran out of time:**
- Commit whatever is working
- Clearly mark incomplete work
- Document exact stopping point
- List remaining steps

---

## Quick Reference

| Check | Command |
|-------|---------|
| Tests pass | `npm test` / `pytest` |
| Lint passes | `npm run lint` / `flake8` |
| Git clean | `git status` |
| Feature status | `cat docs/DEV_MEMORY/feature_checklist.json` |
| Dev log exists | `tail -50 docs/DEV_MEMORY/claude_dev_log.md` |
| Stop environment | `./scripts/stop_dev.sh` |
