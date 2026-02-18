#!/bin/bash
set -e

# Configure gh CLI with token
if [ -n "$GH_TOKEN" ]; then
  echo "$GH_TOKEN" | gh auth login --with-token
fi

# Run the command passed as arguments
exec "$@"
