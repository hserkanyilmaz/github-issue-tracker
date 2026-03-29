---
description: Clear the active GitHub issue
allowed-tools: Bash(rm:*)
---

# Clear Active GitHub Issue

Remove the active GitHub issue tracking state.

Steps:
1. Check if `.claude/github-issue.local.md` exists
2. If it exists, delete it with `rm .claude/github-issue.local.md`
3. Confirm to the user that the active issue has been cleared

If no active issue is set, inform the user that there is nothing to clear.
