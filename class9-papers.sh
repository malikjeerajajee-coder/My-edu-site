#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Class 9 Punjab Board Past Papers"
echo "════════════════════════════════════════════"
echo ""

mkdir -p src/content/past-papers
mkdir -p public/pdfs/past-papers

# ═══════════════════════════════════════════════
#  Generate all Class 9 Punjab past papers
# ═══════════════════════════════════════════════
python3 - <<'PY'
import json
import pathlib

CONTENT_DIR = pathlib.Path("src/content/past-papers")
PDF_DIR = pathlib.Path("public/pdfs/past-papers")
CONTENT_DIR.mkdir(parents=True, exist_ok=True)
PDF_DIR.mkdir(parents=True, exist_ok=True)

# Subjects with the years each has papers for
subjects = {
    "Physics":            (2018, 2026),
    "Chemistry":          (2018, 2026),
    "Biology":            (2018, 2026),
    "Mathematics":        (2018, 2026),
    "English":            (2018, 2026),
    "Urdu":               (2018, 2026),
    "Islamiat":           (2018, 2026),
    "Pakistan Studies":   (2018, 2026),
    "Computer Science":   (2021, 2026),
    "Tarjuma Tul Quran":  (2023, 2026),
    "Punjabi":            (2018, 2026),
    "General Mathematics":(2018, 2026),
    "General Science":    (2018, 2026),
    "Islamiat Ikhtiari":  (2018, 2026),
    "Health & Physical Education": (2018, 2026),
    "Ethics":             (2018, 2026),
    "Education":          (2018, 2026),
    "Home Economics":     (2018, 2026),
    "Civics":             (2018, 2026),
}

# slug helper
def slug(s):
    return s.lower().replace(" & ", "-and-").replace(" ", "-").replace(".", "")

count = 0
for subject, (start, end) in subjects.items():
    subj_slug = slug(subject)
    for year in range(start, end + 1):
        # Year-specific filename
        fname = f"{subj_slug}-9-punjab-{year}"
        data = {
            "title": f"{subject} Class 9 Past Paper {year} (Punjab Boards)",
            "subject": subject,
            "class": "9",
            "year": year,
            "boards": ["Punjab"],
            "pdfUrl": f"/pdfs/past-papers/{fname}.pdf"
        }
        (CONTENT_DIR / f"{fname}.json").write_text(json.dumps(data, indent=2))
        (PDF_DIR / f"{fname}.pdf").touch()
        count += 1

print(f"  Created {count} past paper files")
print(f"  Across {len(subjects)} subjects")
PY

# ═══════════════════════════════════════════════
#  Rebuild
# ═══════════════════════════════════════════════
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -15

echo ""
echo "════════════════════════════════════════════"
echo "  Done."
echo ""
echo "  Push:"
echo "    git add ."
echo "    git commit -m 'Add Class 9 Punjab past papers'"
echo "    git push"
echo ""
echo "  Test:"
echo "    /board/punjab/class-9"
echo "    /board/punjab/class-9/physics"
echo "    /board/punjab/class-9/chemistry"
echo "    /board/punjab/class-9/biology"
echo "════════════════════════════════════════════"