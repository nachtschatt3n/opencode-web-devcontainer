#!/bin/bash
set -e

# Configure gh CLI with token
if [ -n "$GH_TOKEN" ]; then
  echo "$GH_TOKEN" | gh auth login --with-token
fi

# Clone repo into workspace only if the workspace is empty
WORKSPACE="$HOME/workspace"
if [ -n "$REPO_NAME" ] && [ -z "$(ls -A "$WORKSPACE" 2>/dev/null)" ]; then
  mkdir -p "$WORKSPACE"
  gh repo clone "$REPO_NAME" "$WORKSPACE" -- --depth=1
fi
