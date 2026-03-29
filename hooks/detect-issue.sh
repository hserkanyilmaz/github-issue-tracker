#!/usr/bin/env bash
# UserPromptSubmit hook: detects GitHub issue/PR URLs in user prompts,
# fetches the title via gh CLI, and persists to a state file.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
STATE_DIR=".claude"
STATE_FILE="$STATE_DIR/github-issue.local.md"

# Read hook input from stdin
INPUT=$(cat)

# Extract user prompt
PROMPT=$(echo "$INPUT" | jq -r '.user_prompt // empty')

if [ -z "$PROMPT" ]; then
  echo '{"continue": true}'
  exit 0
fi

# Match GitHub issue/PR URLs:
#   https://github.com/owner/repo/issues/123
#   https://github.com/owner/repo/pull/123
GITHUB_URL=$(echo "$PROMPT" | grep -oE 'https://github\.com/[A-Za-z0-9._-]+/[A-Za-z0-9._-]+/(issues|pull)/[0-9]+' | head -1 || true)

if [ -z "$GITHUB_URL" ]; then
  # No URL found — pass through silently, keep existing state
  if [ -f "$STATE_FILE" ]; then
    # Remind Claude of the active issue from state file
    EXISTING=$(sed -n 's/^title: //p' "$STATE_FILE" 2>/dev/null || true)
    EXISTING_NUM=$(sed -n 's/^number: //p' "$STATE_FILE" 2>/dev/null || true)
    EXISTING_REPO=$(sed -n 's/^repo: //p' "$STATE_FILE" 2>/dev/null || true)
    if [ -n "$EXISTING" ]; then
      echo "{\"continue\": true, \"systemMessage\": \"Active GitHub issue: ${EXISTING_REPO}#${EXISTING_NUM} — ${EXISTING}\"}"
      exit 0
    fi
  fi
  echo '{"continue": true}'
  exit 0
fi

# Parse the URL
OWNER_REPO=$(echo "$GITHUB_URL" | sed -E 's|https://github\.com/([^/]+/[^/]+)/.*|\1|')
TYPE_PATH=$(echo "$GITHUB_URL" | sed -E 's|.*/([^/]+)/[0-9]+$|\1|')
NUMBER=$(echo "$GITHUB_URL" | sed -E 's|.*/([0-9]+)$|\1|')

if [ "$TYPE_PATH" = "pull" ]; then
  TYPE="pr"
else
  TYPE="issue"
fi

# Fetch issue/PR details
RESULT=$(bash "$PLUGIN_ROOT/scripts/fetch-issue.sh" "$OWNER_REPO" "$NUMBER" "$TYPE" 2>/dev/null || true)

if [ -z "$RESULT" ]; then
  echo "{\"continue\": true, \"systemMessage\": \"Could not fetch GitHub $TYPE $OWNER_REPO#$NUMBER. Ensure gh CLI is authenticated.\"}"
  exit 0
fi

ISSUE_NUMBER=$(echo "$RESULT" | cut -f1)
ISSUE_TITLE=$(echo "$RESULT" | cut -f2)
ISSUE_STATE=$(echo "$RESULT" | cut -f3)

# Persist to state file
mkdir -p "$STATE_DIR"
cat > "$STATE_FILE" << EOF
---
repo: ${OWNER_REPO}
number: ${ISSUE_NUMBER}
title: ${ISSUE_TITLE}
state: ${ISSUE_STATE}
type: ${TYPE}
url: ${GITHUB_URL}
updated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
---

# Active GitHub Issue

**${OWNER_REPO}#${ISSUE_NUMBER}**: ${ISSUE_TITLE} (${ISSUE_STATE})

URL: ${GITHUB_URL}
EOF

# Return system message so Claude knows the active issue
echo "{\"continue\": true, \"systemMessage\": \"Active GitHub ${TYPE}: ${OWNER_REPO}#${ISSUE_NUMBER} — ${ISSUE_TITLE} (${ISSUE_STATE})\"}"
