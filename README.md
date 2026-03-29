# GitHub Issue Tracker for Claude Code

A Claude Code plugin that tracks which GitHub issue or PR you're working on. It auto-detects GitHub URLs from your prompts and injects the active issue context into every Claude response.

## Features

- **Auto-detection**: Paste a GitHub issue or PR URL anywhere in your prompt and it's automatically set as the active issue
- **Persistent state**: The active issue persists across prompts via `.claude/github-issue.local.md`
- **Context injection**: Claude always knows which issue you're working on via system messages
- **Slash commands**: Manual control with `/set-issue`, `/clear-issue`, and `/current-issue`

## Prerequisites

- [GitHub CLI (`gh`)](https://cli.github.com/) installed and authenticated (`gh auth login`)

## Installation

### From GitHub (custom marketplace)

Add to your `~/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "github-issue-tracker": {
      "source": {
        "source": "github",
        "repo": "hserkanyilmaz/github-issue-tracker"
      }
    }
  },
  "enabledPlugins": {
    "github-issue-tracker@github-issue-tracker": true
  }
}
```

### Local development

```bash
claude --plugin-dir /path/to/github-issue-tracker
```

## Usage

### Automatic (just paste a URL)

Include a GitHub issue or PR URL in any prompt:

```
Let's work on https://github.com/myorg/myrepo/issues/42
```

The plugin detects the URL, fetches the title, and sets it as the active issue. Claude will see a system message like:

> Active GitHub issue: myorg/myrepo#42 — Fix login timeout on mobile (OPEN)

### Slash commands

| Command | Description |
|---------|-------------|
| `/set-issue <url>` | Manually set the active issue by URL |
| `/clear-issue` | Remove the active issue |
| `/current-issue` | Display the currently tracked issue |

## How It Works

1. A `UserPromptSubmit` hook runs on every prompt
2. It scans the prompt text for GitHub issue/PR URLs (`github.com/owner/repo/issues/N` or `github.com/owner/repo/pull/N`)
3. When found, it calls `gh issue view` or `gh pr view` to fetch the title and state
4. The result is saved to `.claude/github-issue.local.md` (gitignored by default with `.local.` convention)
5. A `systemMessage` is returned so Claude knows the active issue context
6. On subsequent prompts without a new URL, the existing state is read and re-injected

## State File

The plugin stores state in `.claude/github-issue.local.md` with YAML frontmatter:

```yaml
---
repo: owner/repo
number: 42
title: Fix login timeout on mobile
state: OPEN
type: issue
url: https://github.com/owner/repo/issues/42
updated: 2025-01-15T10:30:00Z
---
```

## License

MIT
