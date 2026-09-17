#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Wiping all books, regenerating fresh"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  Show current state
# ─────────────────────────────────────────────
echo "▸ Current books folder:"
ls src/content/books/ 2>/dev/null | head -30
echo ""
TOTAL=$(ls src/content/books/*.json 2>/dev/null | wc -l)
echo "  Total: $TOTAL files"
echo ""

# ─────────────────────────────────────────────
#  Wipe ALL books
# ─────────────────────────────────────────────
rm -f src/content/books/*.json
rm -f public/pdfs/books/*.pdf
echo "  ✓ Wiped all books + placeholder PDFs"
echo ""

# ─────────────────────────────────────────────
#  Regenerate Punjab (PTB) + Federal (FBISE)
# ─────────────────────────────────────────────
python3 - <<'PY'
import json
import pathlib

BOOKS_DIR = pathlib.Path("src/content/books")
PDF_DIR = pathlib.Path("public/pdfs/books")
BOOKS_DIR.mkdir(parents=True, exist_ok=True)
PDF_DIR.mkdir(parents=True, exist_ok=True)

# ── Punjab Textbook Board (PTB) ──
PTB_SUBJECTS = {
    "1":  ["English", "Urdu", "Mathematics", "General Knowledge", "Islamiat", "Nazra Quran"],
    "2":  ["English", "Urdu", "Mathematics", "General Science", "Social Studies", "Islamiat", "Nazra Quran"],
    "3":  ["English", "Urdu", "Mathematics", "General Science", "Social Studies", "Islamiat"],
    "4":  ["English", "Urdu", "Mathematics", "General Science", "Social Studies", "Islamiat"],
    "5":  ["English", "Urdu", "Mathematics", "General Science", "Social Studies", "Islamiat"],
    "6":  ["English", "Urdu", "Mathematics", "General Science", "Social Studies", "Islamiat", "Computer Science"],
    "7":  ["English", "Urdu", "Mathematics", "General Science", "Social Studies", "Islamiat", "Computer Science"],
    "8":  ["English", "Urdu", "Mathematics", "General Science", "Social Studies", "Islamiat", "Computer Science"],
    "9":  ["English", "Urdu", "Islamiat", "Pakistan Studies", "Tarjuma Tul Quran",
           "Mathematics", "Physics", "Chemistry", "Biology", "Computer Science",
           "General Mathematics", "General Science"],
    "10": ["English", "Urdu", "Islamiat", "Pakistan Studies", "Tarjuma Tul Quran",
           "Mathematics", "Physics", "Chemistry", "Biology", "Computer Science",
           "General Mathematics", "General Science"],
    "11": ["English", "Urdu", "Islamic Studies", "Pakistan Studies",
           "Mathematics", "Physics", "Chemistry", "Biology",
           "Computer Science", "Statistics"],
    "12": ["English", "Urdu", "Islamic Studies", "Pakistan Studies",
           "Mathematics", "Physics", "Chemistry", "Biology",
           "Computer Science", "Statistics"],
}

# ── Federal Board (FBISE) — uses FBISE-published books ──
FBISE_SUBJECTS = {
    "1":  ["English", "Urdu", "Mathematics", "General Knowledge", "Islamiat", "Nazra Quran"],
    "2":  ["English", "Urdu", "Mathematics", "General Science", "Social Studies", "Islamiat", "Nazra Quran"],
    "3":  ["English", "Urdu", "Mathematics", "General Science", "Social Studies", "Islamiat"],
    "4":  ["English", "Urdu", "Mathematics", "General Science", "Social Studies", "Islamiat"],
    "5":  ["English", "Urdu", "Mathematics", "General Science", "Social Studies", "Islamiat"],
    "6":  ["English", "Urdu", "Mathematics", "General Science", "Social Studies", "Islamiat", "Computer Science"],
    "7":  ["English", "Urdu", "Mathematics", "General Science", "Social Studies", "Islamiat", "Computer Science"],
    "8":  ["English", "Urdu", "Mathematics", "General Science", "Social Studies", "Islamiat", "Computer Science"],
    "9":  ["English", "Urdu", "Islamiat", "Pakistan Studies",
           "Mathematics", "Physics", "Chemistry", "Biology", "Computer Science"],
    "10": ["English", "Urdu", "Islamiat", "Pakistan Studies",
           "Mathematics", "Physics", "Chemistry", "Biology", "Computer Science"],
    "11": ["English", "Urdu", "Islamic Studies", "Pakistan Studies",
           "Mathematics", "Physics", "Chemistry", "Biology", "Computer Science"],
    "12": ["English", "Urdu", "Islamic Studies", "Pakistan Studies",
           "Mathematics", "Physics", "Chemistry", "Biology", "Computer Science"],
}

def slug(s):
    return s.lower().replace(" & ", "-and-").replace(" ", "-").replace(".", "").replace(",", "")

created = 0
for board_name, subjects_map, author in [
    ("Punjab", PTB_SUBJECTS, "Punjab Curriculum and Textbook Board (PCTB)"),
    ("Federal", FBISE_SUBJECTS, "Federal Board of Intermediate and Secondary Education (FBISE)"),
]:
    board_slug = board_name.lower()
    for cls, subjects in subjects_map.items():
        for subject in subjects:
            subj_slug = slug(subject)
            fname = f"{subj_slug}-{cls}-{board_slug}"
            data = {
                "title": f"{subject} — Class {cls} ({board_name} Board)",
                "author": author,
                "class": cls,
                "subject": subject,
                "boards": [board_name],
                "pdfUrl": f"/pdfs/books/{fname}.pdf"
            }
            (BOOKS_DIR / f"{fname}.json").write_text(json.dumps(data, indent=2))
            (PDF_DIR / f"{fname}.pdf").touch()
            created += 1

print(f"  ✓ Created {created} books total")
print()
print(f"  Punjab books:  {sum(len(v) for v in PTB_SUBJECTS.values())}")
print(f"  Federal books: {sum(len(v) for v in FBISE_SUBJECTS.values())}")
PY

# ─────────────────────────────────────────────
#  Verify
# ─────────────────────────────────────────────
echo ""
echo "▸ New books folder:"
ls src/content/books/ | head -20
echo "  ..."
echo "  Total: $(ls src/content/books/*.json 2>/dev/null | wc -l) files"
echo ""

# ─────────────────────────────────────────────
#  Rebuild
# ─────────────────────────────────────────────
echo "Rebuilding..."
npm run build 2>&1 | tail -6

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Preview:"
echo ""
echo "    npm run dev"
echo ""
echo "  Check these — no duplicates expected:"
echo "    /board/punjab/class-9"
echo "    /board/punjab/class-10"
echo "    /board/federal/class-9"
echo "    /books"
echo "════════════════════════════════════════════"