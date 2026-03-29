---
description: Show the currently active GitHub issue
allowed-tools: Read
---

# Show Active GitHub Issue

Display the currently tracked GitHub issue or PR.

Steps:
1. Check if `.claude/github-issue.local.md` exists
2. If it exists, read it and display the issue details in a concise format:
   - Repository
   - Issue/PR number and title
   - State (open/closed/merged)
   - URL
3. If no active issue is set, inform the user and suggest using `/set-issue <url>` or pasting a GitHub URL in a prompt.
