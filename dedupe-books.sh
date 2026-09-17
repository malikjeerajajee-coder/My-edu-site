#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Finding and removing duplicate books"
echo "════════════════════════════════════════════"
echo ""

python3 - <<'PY'
import json
import pathlib
from collections import defaultdict

BOOKS_DIR = pathlib.Path("src/content/books")
files = sorted(BOOKS_DIR.glob("*.json"))

print(f"  Total book files: {len(files)}\n")

# Build a map: (subject_lower, class, board_lower) → list of (file, data)
groups = defaultdict(list)
unreadable = []

for f in files:
    try:
        data = json.loads(f.read_text())
    except Exception as e:
        unreadable.append((f, str(e)))
        continue

    # Normalise board field: could be "board" (string) or "boards" (array)
    boards_raw = data.get("boards") or ([data["board"]] if data.get("board") else ["Unknown"])
    for board in boards_raw:
        key = (
            str(data.get("subject", "")).strip().lower(),
            str(data.get("class", "")).strip(),
            str(board).strip().lower(),
        )
        groups[key].append((f, data))

# Report duplicates
duplicates_found = 0
dupe_files_to_remove = set()

for key, items in groups.items():
    if len(items) > 1:
        duplicates_found += 1
        subject, cls, board = key
        print(f"  Duplicate: {subject.title()} Class {cls} ({board.title()})")
        for f, d in items:
            print(f"    · {f.name}  →  {d.get('title', '?')}")

        # Keep the one with the longest title (usually the newer, more descriptive one)
        # Prefer files with board suffix in the name (newer naming)
        def rank(item):
            f, d = item
            score = 0
            # Prefer longer title (more descriptive)
            score += len(d.get("title", ""))
            # Prefer newer naming with board suffix
            if any(suffix in f.name for suffix in ["-punjab", "-federal", "-kpk", "-sindh", "-balochistan", "-ajk"]):
                score += 100
            # Prefer entries with explicit boards array (newer schema)
            if "boards" in d:
                score += 50
            return score

        items_sorted = sorted(items, key=rank, reverse=True)
        keep = items_sorted[0]
        for f, d in items_sorted[1:]:
            dupe_files_to_remove.add(f)
            print(f"      ⨯ remove: {f.name}")

        print(f"      ✓ keep:   {keep[0].name}\n")

print(f"  ─────────────────────────────────────")
print(f"  Duplicate groups found: {duplicates_found}")
print(f"  Files to remove: {len(dupe_files_to_remove)}")

# Actually remove them
if dupe_files_to_remove:
    for f in dupe_files_to_remove:
        f.unlink()
        # Also remove the placeholder PDF if it exists
        pdf = pathlib.Path("public/pdfs/books") / (f.stem + ".pdf")
        if pdf.exists():
            pdf.unlink()
    print(f"\n  ✓ Removed {len(dupe_files_to_remove)} duplicate files")
else:
    print(f"\n  ✓ No duplicates found")

if unreadable:
    print(f"\n  ⚠ Unreadable files ({len(unreadable)}):")
    for f, e in unreadable:
        print(f"    · {f.name}: {e}")
PY

# ─────────────────────────────────────────────
#  Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -6

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Preview:"
echo ""
echo "    npm run dev"
echo ""
echo "  Check /board/punjab/class-9 and /board/federal/class-9"
echo "  for duplicate subject rows."
echo "════════════════════════════════════════════"