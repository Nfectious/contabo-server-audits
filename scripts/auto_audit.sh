#!/usr/bin/env bash

set -euo pipefail

# automation wrapper: run the audit into a timestamped directory then commit
TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
DIR="${TIMESTAMP}_server_audit"

mkdir -p "$DIR"

# Run audit (summary + full)
./audit.sh --outdir "$(pwd)/$DIR"

# Add and commit
git add "$DIR" || true
if git diff --cached --quiet; then
  echo "Nothing to commit"
else
  git commit -m "Automated audit $TIMESTAMP"
  git push origin HEAD
fi
