#!/bin/bash
# Restore the site to its pre-redesign state
set -e
echo "Restoring from backup-pre-redesign..."
git fetch origin backup-pre-redesign
git checkout backup-pre-redesign
git branch -D main || true
git checkout -b main
git push -f origin main
echo ""
echo "✓ Restored. Site will redeploy in ~90 seconds."
