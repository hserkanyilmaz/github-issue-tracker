---
description: Set the active GitHub issue or PR by URL
allowed-tools: Bash(gh:*), Write
---

# Set Active GitHub Issue

The user wants to track a GitHub issue or PR. Extract the URL from the argument: `$ARGUMENTS`

Steps:
1. Parse the GitHub URL to extract owner/repo and issue/PR number
2. Fetch the issue or PR details using `gh issue view` or `gh pr view`
3. Write the state to `.claude/github-issue.local.md` with this format:

```markdown
---
repo: <owner/repo>
number: <number>
title: <title>
state: <state>
type: <issue or pr>
url: <full url>
updated: <ISO timestamp>
---

# Active GitHub Issue

**<owner/repo>#<number>**: <title> (<state>)

URL: <full url>
```

4. Confirm to the user which issue is now active.

If no URL is provided, ask the user to provide one in the format: `https://github.com/owner/repo/issues/123`
