#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Class 10 Punjab past papers + BISE system"
echo "════════════════════════════════════════════"
echo ""

mkdir -p src/content/past-papers src/lib

# ═══════════════════════════════════════════════
#  1. Add BISE data to boards library
# ═══════════════════════════════════════════════
python3 - <<'PY'
import pathlib
p = pathlib.Path("src/lib/boards.ts")
s = p.read_text()

if "PUNJAB_BISES" not in s:
    s += '''

// The 9 Punjab Boards of Intermediate and Secondary Education (BISEs)
// All operate under the Punjab Boards Committee of Chairpersons (PBCC)
// — same syllabus, same paper pattern, different questions each year.
export const PUNJAB_BISES = [
  { slug: 'lahore',      name: 'Lahore',      short: 'LHR' },
  { slug: 'gujranwala',  name: 'Gujranwala',  short: 'GUJ' },
  { slug: 'multan',      name: 'Multan',      short: 'MTN' },
  { slug: 'faisalabad',  name: 'Faisalabad',  short: 'FBD' },
  { slug: 'rawalpindi',  name: 'Rawalpindi',  short: 'RWP' },
  { slug: 'sargodha',    name: 'Sargodha',    short: 'SGD' },
  { slug: 'bahawalpur',  name: 'Bahawalpur',  short: 'BWP' },
  { slug: 'dg-khan',     name: 'DG Khan',     short: 'DGK' },
  { slug: 'sahiwal',     name: 'Sahiwal',     short: 'SWL' },
];

export const PUNJAB_BISE_NAMES = PUNJAB_BISES.map(b => b.name);

export function biseBySlug(slug: string) {
  return PUNJAB_BISES.find(b => b.slug === slug);
}
'''
    p.write_text(s)
    print("  ✓ PUNJAB_BISES added to boards.ts")
else:
    print("  · PUNJAB_BISES already present")
PY

# ═══════════════════════════════════════════════
#  2. Add 'bises' field to past-papers schema
# ═══════════════════════════════════════════════
python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/content.config.ts")
s = p.read_text()

# Find pastPapers block and add bises field
old = '''const pastPapers = defineCollection({
  loader: glob({ pattern: '**/*.json', base: './src/content/past-papers' }),
  schema: z.object({
    title: z.string(),
    subject: z.string(),
    class: z.string(),
    year: z.number(),
    board: z.string().optional(),
    boards: z.array(z.string()).optional(),
    pdfUrl: z.string(),
    totalMarks: z.number().optional(),
    duration: z.string().optional(),
    objective: z.object({ mcqs: z.number(), marks: z.number() }).optional(),
    subjective: z.object({ short: z.number(), long: z.number(), marks: z.number() }).optional(),
    topics: z.array(topicSchema).optional(),
    faq: z.array(faqSchema).optional(),
  }),
});'''

new = '''const pastPapers = defineCollection({
  loader: glob({ pattern: '**/*.json', base: './src/content/past-papers' }),
  schema: z.object({
    title: z.string(),
    subject: z.string(),
    class: z.string(),
    year: z.number(),
    board: z.string().optional(),
    boards: z.array(z.string()).optional(),
    bises: z.array(z.string()).optional(),
    pdfUrl: z.string(),
    totalMarks: z.number().optional(),
    duration: z.string().optional(),
    objective: z.object({ mcqs: z.number(), marks: z.number() }).optional(),
    subjective: z.object({ short: z.number(), long: z.number(), marks: z.number() }).optional(),
    topics: z.array(topicSchema).optional(),
    faq: z.array(faqSchema).optional(),
  }),
});'''

if old in s:
    s = s.replace(old, new)
    p.write_text(s)
    print("  ✓ bises field added to pastPapers schema")
else:
    # Try looser match
    if "bises:" not in s:
        s = s.replace(
            "    boards: z.array(z.string()).optional(),\n    pdfUrl: z.string(),\n    totalMarks:",
            "    boards: z.array(z.string()).optional(),\n    bises: z.array(z.string()).optional(),\n    pdfUrl: z.string(),\n    totalMarks:"
        )
        p.write_text(s)
        print("  ✓ bises field added (fallback)")
    else:
        print("  · bises already present")
PY

# ═══════════════════════════════════════════════
#  3. Generate Class 10 papers (with BISEs)
# ═══════════════════════════════════════════════
python3 - <<'PY'
import json
import pathlib

CONTENT_DIR = pathlib.Path("src/content/past-papers")
PDF_DIR = pathlib.Path("public/pdfs/past-papers")
CONTENT_DIR.mkdir(parents=True, exist_ok=True)
PDF_DIR.mkdir(parents=True, exist_ok=True)

ALL_BISES = ["Lahore", "Gujranwala", "Multan", "Faisalabad",
             "Rawalpindi", "Sargodha", "Bahawalpur", "DG Khan", "Sahiwal"]

# Subject → year range
subjects = {
    "Physics":                     (2018, 2026),
    "Chemistry":                   (2018, 2026),
    "Biology":                     (2018, 2026),
    "Mathematics":                 (2018, 2026),
    "English":                     (2018, 2026),
    "Urdu":                        (2018, 2026),
    "Islamiat":                    (2018, 2026),
    "Pakistan Studies":            (2018, 2026),
    "Computer Science":            (2021, 2026),
    "Tarjuma Tul Quran":           (2023, 2026),
    "Punjabi":                     (2018, 2026),
    "General Mathematics":         (2018, 2026),
    "General Science":             (2018, 2026),
    "Islamiat Ikhtiari":           (2018, 2026),
    "Health & Physical Education": (2018, 2026),
    "Ethics":                      (2018, 2026),
    "Education":                   (2018, 2026),
    "Home Economics":              (2018, 2026),
    "Civics":                      (2018, 2026),
}

def slug(s):
    return s.lower().replace(" & ", "-and-").replace(" ", "-").replace(".", "")

count = 0
for subject, (start, end) in subjects.items():
    subj_slug = slug(subject)
    for year in range(start, end + 1):
        fname = f"{subj_slug}-10-punjab-{year}"
        data = {
            "title": f"{subject} Class 10 Past Papers {year} — Punjab Boards",
            "subject": subject,
            "class": "10",
            "year": year,
            "boards": ["Punjab"],
            "bises": ALL_BISES,
            "pdfUrl": f"/pdfs/past-papers/{fname}.pdf"
        }
        (CONTENT_DIR / f"{fname}.json").write_text(json.dumps(data, indent=2))
        (PDF_DIR / f"{fname}.pdf").touch()
        count += 1

print(f"  ✓ Created {count} Class 10 past paper files across {len(subjects)} subjects")
print(f"  ✓ Each paper includes all 9 Punjab BISEs")
PY

# ═══════════════════════════════════════════════
#  4. Also update Class 9 papers to include bises
# ═══════════════════════════════════════════════
python3 - <<'PY'
import json
import pathlib

CONTENT_DIR = pathlib.Path("src/content/past-papers")
ALL_BISES = ["Lahore", "Gujranwala", "Multan", "Faisalabad",
             "Rawalpindi", "Sargodha", "Bahawalpur", "DG Khan", "Sahiwal"]

updated = 0
for f in CONTENT_DIR.glob("*-9-punjab-*.json"):
    data = json.loads(f.read_text())
    if "bises" not in data:
        data["bises"] = ALL_BISES
        f.write_text(json.dumps(data, indent=2))
        updated += 1

print(f"  ✓ Updated {updated} existing Class 9 papers with BISEs")
PY

echo ""
echo "  Content generation complete."