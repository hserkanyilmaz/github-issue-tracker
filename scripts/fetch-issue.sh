#!/usr/bin/env bash
# Fetches GitHub issue/PR title using gh CLI.
# Usage: fetch-issue.sh <owner/repo> <number> <type>
#   type: "issue" or "pr"

set -euo pipefail

REPO="$1"
NUMBER="$2"
TYPE="${3:-issue}"

if [ "$TYPE" = "pr" ]; then
  gh pr view "$NUMBER" --repo "$REPO" --json title,number,state --jq '"\(.number)\t\(.title)\t\(.state)"'
else
  gh issue view "$NUMBER" --repo "$REPO" --json title,number,state --jq '"\(.number)\t\(.title)\t\(.state)"'
fi
