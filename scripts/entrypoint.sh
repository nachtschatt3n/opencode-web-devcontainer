#!/bin/bash
set -e

# GH_TOKEN env var is used automatically by gh CLI — no explicit login needed.

# Run the command passed as arguments
exec "$@"
