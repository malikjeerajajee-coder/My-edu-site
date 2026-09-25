#!/bin/bash
# audit-theme.sh — find and fix design system mismatches site-wide
set -e
cd ~/my-edu-site

echo "════════════════════════════════════════════"
echo "  Theme audit — find pages using old design"
echo "════════════════════════════════════════════"
echo ""

git branch -f backup-pre-theme-audit 2>/dev/null || true
echo "  ✓ Backup branch: backup-pre-theme-audit"
echo ""

# ─── 1. Scan every page ───
echo "▸ 1. Scanning src/pages/ for design signatures"
echo ""

OLD_PATTERNS=(
  'rounded-3xl border border-\[#0620ed\]'
  'bg-gradient-to-br from-\[#110176\]'
  'from-\[#110176\] via-\[#0620ed\]'
  'border border-\[#0620ed\] bg-gradient'
)

NEW_PATTERNS=(
  'border-b border-slate-200 bg-slate-50'
  'seamed-grid'
  'class="row group"'
)

echo "  ──────────────────────────────────────────"
echo "  OLD design pages (need fixing):"
echo "  ──────────────────────────────────────────"
grep -rlE 'rounded-3xl border border-\[#0620ed\]|from-\[#110176\] via-\[#0620ed\]|border-\[#0620ed\] bg-gradient' src/pages/ 2>/dev/null || echo "    (none)"
echo ""

echo "  ──────────────────────────────────────────"
echo "  NEW design pages:"
echo "  ──────────────────────────────────────────"
grep -rlE 'border-b border-slate-200 bg-slate-50' src/pages/ 2>/dev/null | head -20
echo ""

echo "  ──────────────────────────────────────────"
echo "  Pages with rounded-3xl anywhere:"
echo "  ──────────────────────────────────────────"
grep -rln 'rounded-3xl' src/pages/ 2>/dev/null || echo "    (none)"
echo ""

echo "  ──────────────────────────────────────────"
echo "  Pages still using blue-100 / blue-200 (old hero text):"
echo "  ──────────────────────────────────────────"
grep -rln 'text-blue-100\|text-blue-200' src/pages/ 2>/dev/null || echo "    (none)"
echo ""

# ─── 2. Report count ───
OLD_COUNT=$(grep -rlE 'rounded-3xl border border-\[#0620ed\]|from-\[#110176\] via-\[#0620ed\]|border-\[#0620ed\] bg-gradient' src/pages/ 2>/dev/null | wc -l)
echo "════════════════════════════════════════════"
echo "  Summary: $OLD_COUNT file(s) use the OLD hero pattern"
echo "════════════════════════════════════════════"
echo ""
echo "  Run the next script to fix them all at once."
echo ""
echo "  First, save this as fix-theme.sh and run it."
echo ""