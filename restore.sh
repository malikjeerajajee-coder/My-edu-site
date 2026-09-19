#!/bin/bash
set -e
echo "Restoring from backup-pre-covers-v2..."
git fetch origin backup-pre-covers-v2
git checkout backup-pre-covers-v2
git branch -D main || true
git checkout -b main
git push -f origin main
echo ""
echo "✓ Restored. Site redeploys in 5-8 min."
