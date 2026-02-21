#!/bin/bash
set -e

# GH_TOKEN env var is used automatically by gh CLI — no explicit login needed.

WORKSPACE="$HOME/workspace"
# Check if workspace is empty, ignoring lost+found (created by ext4 on fresh PVCs)
workspace_empty() {
  [ -z "$(ls -A "$WORKSPACE" 2>/dev/null | grep -v '^lost+found$')" ]
}
if [ -n "$REPO_NAME" ] && workspace_empty; then
  rm -rf "$WORKSPACE/lost+found" 2>/dev/null || true
  mkdir -p "$WORKSPACE"
  gh repo clone "$REPO_NAME" "$WORKSPACE" -- --depth=1
fi
