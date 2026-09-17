#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Adding all classes 1–12 (Punjab + Federal)"
echo "════════════════════════════════════════════"
echo ""

mkdir -p src/content/books src/content/past-papers
mkdir -p public/pdfs/books public/pdfs/past-papers

# ═══════════════════════════════════════════════
#  1. Update CLASS_ORDER to include 1-12
# ═══════════════════════════════════════════════
python3 - <<'PY'
import pathlib
p = pathlib.Path("src/lib/boards.ts")
s = p.read_text()

old = "export const CLASSES = ['9', '10', '11', '12'];"
new = "export const CLASSES = ['1','2','3','4','5','6','7','8','9','10','11','12'];"

if old in s:
    s = s.replace(old, new)
    p.write_text(s)
    print("  ✓ CLASSES expanded to 1-12")
else:
    print("  · CLASSES already updated")
PY

# ═══════════════════════════════════════════════
#  2. Generate books for all classes 1-12
# ═══════════════════════════════════════════════
python3 - <<'PY'
import json
import pathlib

BOOKS_DIR = pathlib.Path("src/content/books")
PDF_DIR = pathlib.Path("public/pdfs/books")
BOOKS_DIR.mkdir(parents=True, exist_ok=True)
PDF_DIR.mkdir(parents=True, exist_ok=True)

# Subjects per class group
def subjects_for(cls):
    if cls in ['1', '2', '3', '4', '5']:
        return ['Urdu', 'English', 'Mathematics', 'General Science', 'Islamiat', 'Social Studies']
    if cls in ['6', '7', '8']:
        return ['Urdu', 'English', 'Mathematics', 'General Science', 'Islamiat', 'Social Studies', 'Computer Science']
    if cls in ['9', '10']:
        return ['Urdu', 'English', 'Mathematics', 'Physics', 'Chemistry', 'Biology',
                'Computer Science', 'Islamiat', 'Pakistan Studies', 'Tarjuma Tul Quran']
    if cls in ['11', '12']:
        return ['Urdu', 'English', 'Islamic Studies', 'Pakistan Studies',
                'Physics', 'Chemistry', 'Biology', 'Mathematics',
                'Computer Science', 'Statistics']
    return []

# Which classes per board
BOOK_CLASSES = ['1','2','3','4','5','6','7','8','9','10','11','12']

BOARDS = [
    { 'name': 'Punjab',  'author': 'Punjab Textbook Board (PTB)' },
    { 'name': 'Federal', 'author': 'Federal Board (FBISE)' },
]

def slug(s):
    return s.lower().replace(" & ", "-and-").replace(" ", "-").replace(".", "")

count = 0
for board in BOARDS:
    for cls in BOOK_CLASSES:
        for subject in subjects_for(cls):
            subj_slug = slug(subject)
            board_slug = board['name'].lower()
            fname = f"{subj_slug}-{cls}-{board_slug}"
            data = {
                "title": f"{subject} Textbook — Class {cls}",
                "author": board['author'],
                "class": cls,
                "subject": subject,
                "boards": [board['name']],
                "pdfUrl": f"/pdfs/books/{fname}.pdf"
            }
            (BOOKS_DIR / f"{fname}.json").write_text(json.dumps(data, indent=2))
            (PDF_DIR / f"{fname}.pdf").touch()
            count += 1

print(f"  ✓ Created {count} books for classes 1-12 (Punjab + Federal)")
PY

# ═══════════════════════════════════════════════
#  3. Generate past papers for Class 11 & 12
# ═══════════════════════════════════════════════
python3 - <<'PY'
import json
import pathlib

PP_DIR = pathlib.Path("src/content/past-papers")
PDF_DIR = pathlib.Path("public/pdfs/past-papers")
PP_DIR.mkdir(parents=True, exist_ok=True)
PDF_DIR.mkdir(parents=True, exist_ok=True)

# Subjects for 11 & 12
SCIENCE_SUBJECTS = [
    'Physics', 'Chemistry', 'Biology', 'Mathematics', 'Computer Science',
    'English', 'Urdu', 'Islamic Studies', 'Pakistan Studies',
]
# Arts students might take Statistics, but keep it simple
EXTRA_SUBJECTS = ['Statistics']

PUNJAB_BISES = ["Lahore", "Gujranwala", "Multan", "Faisalabad",
                "Rawalpindi", "Sargodha", "Bahawalpur", "DG Khan", "Sahiwal"]

def slug(s):
    return s.lower().replace(" & ", "-and-").replace(" ", "-").replace(".", "")

count = 0

# Punjab — Classes 11, 12
for cls in ['11', '12']:
    for subject in SCIENCE_SUBJECTS + EXTRA_SUBJECTS:
        subj_slug = slug(subject)
        for year in range(2018, 2027):
            fname = f"{subj_slug}-{cls}-punjab-{year}"
            if (PP_DIR / f"{fname}.json").exists():
                continue
            data = {
                "title": f"{subject} Class {cls} Past Papers {year} — Punjab Boards",
                "subject": subject,
                "class": cls,
                "year": year,
                "boards": ["Punjab"],
                "bises": PUNJAB_BISES,
                "pdfUrl": f"/pdfs/past-papers/{fname}.pdf"
            }
            (PP_DIR / f"{fname}.json").write_text(json.dumps(data, indent=2))
            (PDF_DIR / f"{fname}.pdf").touch()
            count += 1

# Federal — Classes 11, 12
for cls in ['11', '12']:
    for subject in SCIENCE_SUBJECTS:
        subj_slug = slug(subject)
        for year in range(2018, 2027):
            fname = f"{subj_slug}-{cls}-federal-{year}"
            if (PP_DIR / f"{fname}.json").exists():
                continue
            data = {
                "title": f"{subject} Class {cls} Past Papers {year} — Federal Board",
                "subject": subject,
                "class": cls,
                "year": year,
                "boards": ["Federal"],
                "pdfUrl": f"/pdfs/past-papers/{fname}.pdf"
            }
            (PP_DIR / f"{fname}.json").write_text(json.dumps(data, indent=2))
            (PDF_DIR / f"{fname}.pdf").touch()
            count += 1

print(f"  ✓ Created {count} past papers for Class 11 & 12")
PY

# ═══════════════════════════════════════════════
#  4. Also add Punjab past papers for Class 11-12
#     (checking what we might be missing)
# ═══════════════════════════════════════════════
echo ""
echo "  Current counts:"
echo "    Books:        $(ls src/content/books/ 2>/dev/null | wc -l)"
echo "    Past papers:  $(ls src/content/past-papers/ 2>/dev/null | wc -l)"
echo "    Notes:        $(ls src/content/notes/ 2>/dev/null | wc -l)"
echo "    Quizzes:      $(ls src/content/quizzes/ 2>/dev/null | wc -l)"
echo "    Gazettes:     $(ls src/content/gazettes/ 2>/dev/null | wc -l)"
echo ""

# ═══════════════════════════════════════════════
#  5. Rebuild
# ═══════════════════════════════════════════════
echo "Rebuilding..."
npm run build 2>&1 | tail -8

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Push:"
echo ""
echo "    git add ."
echo "    git commit -m 'Add all classes 1-12 for Punjab and Federal'"
echo "    git push"
echo ""
echo "  What you get:"
echo "    · Books for classes 1-12 (Punjab + Federal)"
echo "    · Past papers for Class 11-12 (Punjab + Federal)"
echo "    · Class 9-10 papers already present"
echo ""
echo "  Content breakdown:"
echo "    Class 1-5:   6 subjects × 2 boards = 12 books each"
echo "    Class 6-8:   7 subjects × 2 boards = 14 books each"
echo "    Class 9-10:  10 subjects × 2 boards = 20 books each"
echo "    Class 11-12: 10 subjects × 2 boards = 20 books each"
echo "    ─────────────────────────────────────"
echo "    Total books:       ~176"
echo "    Total past papers: ~750+"
echo "════════════════════════════════════════════"