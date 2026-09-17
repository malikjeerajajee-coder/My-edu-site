#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Rebuilding Punjab Textbook Board books"
echo "════════════════════════════════════════════"
echo ""

# Clear old Punjab books
rm -f src/content/books/*-punjab.json
mkdir -p src/content/books public/pdfs/books

python3 - <<'PY'
import json
import pathlib

BOOKS_DIR = pathlib.Path("src/content/books")
PDF_DIR = pathlib.Path("public/pdfs/books")
BOOKS_DIR.mkdir(parents=True, exist_ok=True)
PDF_DIR.mkdir(parents=True, exist_ok=True)

# ─────────────────────────────────────────────
#  Exact PTB subject lists per class
# ─────────────────────────────────────────────
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

def slug(s):
    return s.lower().replace(" & ", "-and-").replace(" ", "-").replace(".", "")

count = 0
for cls, subjects in PTB_SUBJECTS.items():
    for subject in subjects:
        subj_slug = slug(subject)
        fname = f"{subj_slug}-{cls}-punjab"
        data = {
            "title": f"{subject} — Class {cls} (Punjab Textbook Board)",
            "author": "Punjab Curriculum and Textbook Board (PCTB)",
            "class": cls,
            "subject": subject,
            "boards": ["Punjab"],
            "pdfUrl": f"/pdfs/books/{fname}.pdf"
        }
        (BOOKS_DIR / f"{fname}.json").write_text(json.dumps(data, indent=2))
        (PDF_DIR / f"{fname}.pdf").touch()
        count += 1

print(f"  ✓ Created {count} Punjab Textbook Board books (Class 1–12)")
print()
print("  Breakdown by class:")
for cls in sorted(PTB_SUBJECTS.keys(), key=int):
    print(f"    Class {cls:>2}: {len(PTB_SUBJECTS[cls])} subjects")
PY

echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -6

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Preview locally:"
echo ""
echo "    npm run dev"
echo ""
echo "  Check these URLs:"
echo "    /board/punjab/class-1        → 6 books"
echo "    /board/punjab/class-5        → 6 books"
echo "    /board/punjab/class-8        → 7 books"
echo "    /board/punjab/class-9        → 12 books"
echo "    /board/punjab/class-11       → 10 books"
echo "    /board/punjab/class-12       → 10 books"
echo ""
echo "  Note: Federal books also remain (from previous script)."
echo "  No git push — preview first."
echo "════════════════════════════════════════════"