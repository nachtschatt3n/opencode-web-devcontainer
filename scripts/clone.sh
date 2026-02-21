#!/bin/bash
set -e

# GH_TOKEN env var is used automatically by gh CLI — no explicit login needed.

WORKSPACE="$HOME/workspace"
if [ -n "$REPO_NAME" ] && [ -z "$(ls -A "$WORKSPACE" 2>/dev/null)" ]; then
  mkdir -p "$WORKSPACE"
  gh repo clone "$REPO_NAME" "$WORKSPACE" -- --depth=1
fi
