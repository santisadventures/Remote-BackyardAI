#!/bin/sh
set -eu

# Restart the stack. This is meant to be called by launchd (macOS).
# Adjust the path to match where you cloned the repo.

REPO_DIR="${REPO_DIR:-$HOME/santisplayground_repo}"
cd "$REPO_DIR"

docker compose down
docker compose up -d --build

