#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "════════════════════════════════════════════"
echo "  Adding STBB books (Sindh Textbook Board)"
echo "════════════════════════════════════════════"
echo ""

# Detect which content folder is active
if [ -d "src/content-full" ]; then
  echo "  Fast mode detected — writing to src/content-full/books/"
  BOOKS_DIR="src/content-full/books"
else
  BOOKS_DIR="src/content/books"
fi
mkdir -p "$BOOKS_DIR"
echo "  Target: $BOOKS_DIR"
echo ""

# ─────────────────────────────────────────────
#  Update schema — add 'sindhi' medium
# ─────────────────────────────────────────────
echo "▸ Updating schema to allow Sindhi medium..."

python3 <<'PY'
import pathlib, re
p = pathlib.Path('src/content.config.ts')
s = p.read_text()

old = "medium: z.enum(['english', 'urdu']).optional(),"
new = "medium: z.enum(['english', 'urdu', 'sindhi']).optional(),"

if old in s:
    s = s.replace(old, new)
    p.write_text(s)
    print('  ✓ Sindhi medium added to schema')
elif "'sindhi'" in s:
    print('  · Sindhi already in schema')
else:
    print('  ! Could not find medium enum')
PY

# ─────────────────────────────────────────────
#  Generate STBB book files
# ─────────────────────────────────────────────
echo ""
echo "▸ Generating STBB books..."

python3 <<'PYEOF'
import json, pathlib, re, os

BOOKS_DIR = pathlib.Path(os.environ.get('BOOKS_DIR', 'src/content/books'))
BOOKS_DIR.mkdir(parents=True, exist_ok=True)

# (book_id, filename, url, metadata)
raw = [
    (10, 'Asan Urdu V.pdf', 'Urdu', 'Asan Urdu', 5, '2025-26'),
    (101, 'Science IV.pdf', 'Urdu', 'Science', 4, '2020-21'),
    (102, 'Science V.pdf', 'Urdu', 'Science', 5, '2020-21'),
    (103, 'Science IV.pdf', 'Sindhi', 'Science', 4, '2025-26'),
    (104, 'General Knowledge II.pdf', 'English', 'General Knowledge', 2, '2020-21'),
    (105, 'General Knowledge III.pdf', 'Sindhi', 'General Knowledge', 3, '2026'),
    (107, 'Smajhi Abhiyas IV.pdf', 'Sindhi', 'Samaji Abhiyas', 4, '2020-21'),
    (108, 'Smajhi Abhiyas V.pdf', 'Sindhi', 'Samaji Abhiyas', 5, '2020-21'),
    (11, 'Asan Urdu VI.pdf', 'Urdu', 'Asan Urdu', 6, '2020-21'),
    (112, 'General Knowledge III.pdf', 'Urdu', 'General Knowledge', 3, '2020-21'),
    (113, 'General Knowledge III.pdf', 'English', 'General Knowledge', 3, '2020-21'),
    (115, 'Science VI.pdf', 'Urdu', 'Science', 6, '2020-21'),
    (117, 'Biology IX.pdf', 'English', 'Biology', 9, '2020-21'),
    (118, 'Biology IX.pdf', 'Urdu', 'Biology', 9, '2020-21'),
    (119, 'Biology IX.pdf', 'Sindhi', 'Biology', 9, '2020-21'),
    (12, 'Asan Urdu VII.pdf', 'Urdu', 'Asan Urdu', 7, '2020-21'),
    (120, 'Science V.pdf', 'Sindhi', 'Science', 5, '2020-21'),
    (121, 'Computer Science IX.pdf', 'English', 'Computer Science', 9, '2020-21'),
    (123, 'Science VIII.pdf', 'English', 'Science', 8, '2020-21'),
    (124, 'Social Studies IV.pdf', 'English', 'Social Studies', 4, '2020-21'),
    (126, 'Science VIII.pdf', 'Sindhi', 'Science', 8, '2020-21'),
    (128, 'Muasharti Uloom IV.pdf', 'Urdu', 'Muasharti Uloom', 4, '2020-21'),
    (129, 'Muasharti Uloom V.pdf', 'Urdu', 'Muasharti Uloom', 5, '2020-21'),
    (130, 'Muasharti Uloom VII.pdf', 'Urdu', 'Muasharti Uloom', 7, '2020-21'),
    (131, 'Muasharti Uloom VI.pdf', 'Urdu', 'Muasharti Uloom', 6, '2020-21'),
    (135, 'General Knowledge II.pdf', 'Urdu', 'General Knowledge', 2, '2020-21'),
    (136, 'Islamiyat VII.pdf', 'Urdu', 'Islamiyat', 7, '2020-21'),
    (137, 'Islamiyat VII.pdf', 'Sindhi', 'Islamiyat', 7, '2020-21'),
    (138, 'Islamiyat VIII.pdf', 'Sindhi', 'Islamiyat', 8, '2020-21'),
    (139, 'English Book I.pdf', 'English', 'English', 1, '2026'),
    (14, 'Urdu Qaida.pdf', 'Urdu', 'Urdu Qaida', None, '2024-25'),  # ECCE/KACHI
    (140, 'My English II.pdf', 'English', 'My English', 2, '2026'),
    (141, 'My English III.pdf', 'English', 'My English', 3, '2026'),
    (142, 'My English IV.pdf', 'English', 'My English', 4, '2025-26'),
    (143, 'My English VI.pdf', 'English', 'My English', 6, '2020-21'),
    (144, 'My English V.pdf', 'English', 'My English', 5, '2020-21'),
    (145, 'My English VII.pdf', 'English', 'My English', 7, '2020-21'),
    (146, 'My English VIII.pdf', 'English', 'My English', 8, '2026'),
    (147, 'My English IX.pdf', 'English', 'My English', 9, '2026'),
    (15, 'Urdu Reader I.pdf', 'Urdu', 'Urdu Reader', 1, '2020-21'),
    (16, 'Urdu Reader II.pdf', 'Urdu', 'Urdu Reader', 2, '2020-21'),
    (17, 'Urdu Reader III.pdf', 'Urdu', 'Urdu Reader', 3, '2021-22'),
    (174, 'Physics IX.pdf', 'English', 'Physics', 9, '2026'),
    (18, 'Urdu Reader IV.pdf', 'Urdu', 'Urdu Reader', 4, '2021-22'),
    (180, 'Math IX.pdf', 'English', 'Mathematics', 9, '2024-25'),
    (183, 'Pakistan Studies IX.pdf', 'Urdu', 'Pakistan Studies', 9, '2020-21'),
    (184, 'Computer Science IX.pdf', 'Sindhi', 'Computer Science', 9, '2020-21'),
    (186, 'Biology X.pdf', 'Sindhi', 'Biology', 10, '2021-22'),
    (188, 'Biology X.pdf', 'English', 'Biology', 10, '2021-22'),
    (19, 'Urdu Reader V.pdf', 'Urdu', 'Urdu Reader', 5, '2022-23'),
    (192, 'Riazi III.pdf', 'Sindhi', 'Riazi', 3, '2024-25'),
    (195, 'Chemistry IX.pdf', 'English', 'Chemistry', 9, '2022-23'),
    (196, 'Chemistry IX.pdf', 'Sindhi', 'Chemistry', 9, '2022-23'),
    (197, 'Chemistry IX.pdf', 'Urdu', 'Chemistry', 9, '2026'),
    (198, 'Chemistry X.pdf', 'English', 'Chemistry', 10, '2022-23'),
    (199, 'Chemistry X.pdf', 'Sindhi', 'Chemistry', 10, '2022-23'),
    (200, 'Chemistry X.pdf', 'Urdu', 'Chemistry', 10, '2026'),
    (201, 'Secondary Stage English X.pdf', 'English', 'English', 10, '2026'),
    (202, 'Physics X.pdf', 'English', 'Physics', 10, '2026'),
    (203, 'English XI.pdf', 'English', 'English', 11, '2022-23'),
    (204, 'Computer Science X.pdf', 'English', 'Computer Science', 10, '2025-26'),
    (205, 'Math X.pdf', 'English', 'Mathematics', 10, '2024-25'),
    (206, 'Chemistry XI.pdf', 'English', 'Chemistry', 11, '2022-23'),
    (207, 'Math XI.pdf', 'English', 'Mathematics', 11, '2024-25'),
    (208, 'Riazi I.pdf', 'Urdu', 'Riazi', 1, '2026'),
    (209, 'Riazi III.pdf', 'Urdu', 'Riazi', 3, '2024-25'),
    (210, 'Riazi V.pdf', 'Urdu', 'Riazi', 5, '2024-25'),
    (212, 'Asaan Sindhi I-X.pdf', 'Urdu', 'Asaan Sindhi', 1, '2026'),
    (213, 'Sindhi Primer.pdf', 'Sindhi', 'Sindhi Primer', None, '2025'),
    (214, 'Gulzar-E-Urdu XI.pdf', 'Urdu', 'Gulzar-e-Urdu', 11, '2023-24'),
    (215, 'Physics XII.pdf', 'English', 'Physics', 12, '2025-26'),
    (216, 'Gulzar-E-Urdu XII.pdf', 'Urdu', 'Gulzar-e-Urdu', 12, '2023-24'),
    (218, 'Chemistry XII.pdf', 'English', 'Chemistry', 12, '2023-24'),
    (219, 'Biology XI.pdf', 'English', 'Biology', 11, '2023-24'),
    (221, 'Physics XI.pdf', 'English', 'Physics', 11, '2025-26'),
    (223, 'Physics X.pdf', 'Sindhi', 'Physics', 10, '2023-24'),
    (225, 'Math XII.pdf', 'English', 'Mathematics', 12, '2024-25'),
    (227, 'Mutala E Pakistan X.pdf', 'Urdu', 'Mutala-e-Pakistan', 10, '2022-23'),
    (228, 'Biology XII.pdf', 'English', 'Biology', 12, '2023-24'),
    (229, 'Arabic VI.pdf', 'Sindhi', 'Arabic', 6, '2022-23'),
    (232, 'Arabic VII.pdf', 'Sindhi', 'Arabic', 7, '2025'),
    (233, 'Arabic VIII.pdf', 'Sindhi', 'Arabic', 8, '2024'),
    (235, 'Pak Studies X.pdf', 'English', 'Pakistan Studies', 10, '2023-24'),
    (236, 'Asan Urdu III.pdf', 'Urdu', 'Asan Urdu', 3, '2022-23'),
    (237, 'Asan Urdu IV.pdf', 'Urdu', 'Asan Urdu', 4, '2026-27'),
    (238, 'Mazhabi Taleemat VI.pdf', 'Sindhi', 'Mazhabi Ta\'leemat', 6, '2022-23'),
    (239, 'Mazhabi Taleemat VII.pdf', 'Sindhi', 'Mazhabi Ta\'leemat', 7, '2022-23'),
    (24, 'Asan Urdu VIII.pdf', 'Urdu', 'Asan Urdu', 8, '2020-21'),
    (240, 'Mazhabi Taleemat VIII.pdf', 'Sindhi', 'Mazhabi Ta\'leemat', 8, '2022-23'),
    (241, 'Mazhabi Taleemat III.pdf', 'Sindhi', 'Mazhabi Ta\'leemat', 3, '2021-22'),
    (242, 'Mazhabi Taleemat IV.pdf', 'Urdu', 'Mazhabi Ta\'leemat', 4, '2020-21'),
    (243, 'Mazhabi Taleemat V.pdf', 'Urdu', 'Mazhabi Ta\'leemat', 5, '2021-22'),
    (244, 'Mazhabi Taleemat III.pdf', 'Urdu', 'Mazhabi Ta\'leemat', 3, '2020-21'),
    (245, 'Mazhabi Taleemat V.pdf', 'Sindhi', 'Mazhabi Ta\'leemat', 5, '2020-21'),
    (246, 'Mazhabi Taleemat IV.pdf', 'Sindhi', 'Mazhabi Ta\'leemat', 4, '2020-21'),
    (247, 'Religious Studies IX-X.pdf', 'English', 'Religious Studies', 9, '2020-21'),
    (248, 'Mazhabi Taleemat VIII.pdf', 'Urdu', 'Mazhabi Ta\'leemat', 8, '2020-21'),
    (249, 'Mazhabi Taleemat VI.pdf', 'Urdu', 'Mazhabi Ta\'leemat', 6, '2021-22'),
    (25, 'Islamiyat VI.pdf', 'Sindhi', 'Islamiyat', 6, '2020-21'),
    (251, 'Mazhabi Taleemat VII.pdf', 'Urdu', 'Mazhabi Ta\'leemat', 7, '2021-22'),
    (252, 'Mazhabi Taleemat IX-X.pdf', 'Sindhi', 'Mazhabi Ta\'leemat', 9, '2021-22'),
    (256, 'Islamiyat III.pdf', 'English', 'Islamiyat', 3, '2025-26'),
    (257, 'Islamiyat III.pdf', 'Urdu', 'Islamiyat', 3, '2023-24'),
    (258, 'Islamiyat IV.pdf', 'English', 'Islamiyat', 4, '2026'),
    (259, 'Islamiyat V.pdf', 'English', 'Islamiyat', 5, '2025-26'),
    (260, 'Islamiyat VI.pdf', 'English', 'Islamiyat', 6, '2023-24'),
    (261, 'Islamiyat VII.pdf', 'English', 'Islamiyat', 7, '2022-23'),
    (262, 'Islamiyat VIII.pdf', 'English', 'Islamiyat', 8, '2021-22'),
    (264, 'Islamiyat IX-X.pdf', 'Sindhi', 'Islamiyat', 9, '2022-23'),
    (265, 'Islamiyat IX-X.pdf', 'Urdu', 'Islamiyat', 9, '2023-24'),
    (266, 'Islamiyat XI-XII.pdf', 'Sindhi', 'Islamiyat', 11, '2023-24'),
    (267, 'Islamiyat IX-X.pdf', 'English', 'Islamiyat', 9, '2022-23'),
    (268, 'Riazi V.pdf', 'Sindhi', 'Riazi', 5, '2024-25'),
    (269, 'Riazi Urdu IV.pdf', 'Urdu', 'Riazi', 4, '2024-25'),
    (270, 'Riazi Sindhi VI.pdf', 'Sindhi', 'Riazi', 6, '2024-25'),
    (271, 'Riazi Sindhi I.pdf', 'Sindhi', 'Riazi', 1, '2026'),
    (272, 'Riazi VIII.pdf', 'Sindhi', 'Riazi', 8, '2024-25'),
    (275, 'Riazi IX.pdf', 'Sindhi', 'Riazi', 9, '2024-25'),
    (277, 'Riazi Urdu X.pdf', 'Urdu', 'Riazi', 10, '2024-25'),
    (278, 'Riazi Sindhi IV.pdf', 'Sindhi', 'Riazi', 4, '2024-25'),
    (279, 'Riazi Urdu VII.pdf', 'Urdu', 'Riazi', 7, '2024-25'),
    (280, 'Riazi II Sindhi.pdf', 'Sindhi', 'Riazi', 2, '2025-26'),
    (281, 'Riazi II Urdu.pdf', 'Urdu', 'Riazi', 2, '2024-25'),
    (282, 'Riazi Sindhi VII.pdf', 'Sindhi', 'Riazi', 7, '2024-25'),
    (283, 'Math VIII.pdf', 'English', 'Mathematics', 8, '2024-25'),
    (284, 'Riazi Urdu VIII.pdf', 'Urdu', 'Riazi', 8, '2024-25'),
    (285, 'Riazi X.pdf', 'Sindhi', 'Riazi', 10, '2024-25'),
    (286, 'Sindhi Lazmi XI-XII.pdf', 'Sindhi', 'Sindhi Lazmi', 11, '2025-26'),
    (287, 'Computer Education VI.pdf', 'English', 'Computer Education', 6, '2025-26'),
    (288, 'Computer Ki Taleem VI.pdf', 'Urdu', 'Computer Ki Taleem', 6, '2025-26'),
    (289, 'Computer Ji Taleem VI.pdf', 'Sindhi', 'Computer Ji Taleem', 6, '2025-26'),
    (29, 'Islamiyat VI.pdf', 'Urdu', 'Islamiyat', 6, '2020-21'),
    (291, 'Computer Science IX.pdf', 'Urdu', 'Computer Science', 9, '2025-26'),
    (292, 'Computer Taleem VIII.pdf', 'Urdu', 'Computer Ki Taleem', 8, '2025'),
    (300, 'Asan Sindhi III.pdf', 'Urdu', 'Asan Sindhi', 3, '2026'),
    (312, 'Asan Sindhi IV.pdf', 'Urdu', 'Asan Sindhi', 4, '2026'),
    (314, 'Asan Sindhi VI.pdf', 'Urdu', 'Asan Sindhi', 6, '2026'),
    (315, 'Asan Sindhi VII.pdf', 'Urdu', 'Asan Sindhi', 7, '2026'),
    (316, 'Asan Sindhi IX-X.pdf', 'Urdu', 'Asan Sindhi', 9, '2026'),
    (317, 'Computer Education VII.pdf', 'English', 'Computer Education', 7, '2026'),
    (319, 'Computer Ji Taleem VII.pdf', 'Sindhi', 'Computer Ji Taleem', 7, '2026'),
    (32, 'Islamiyat VIII.pdf', 'Urdu', 'Islamiyat', 8, '2026'),
    (320, 'Computer Ki Taleem VII.pdf', 'Urdu', 'Computer Ki Taleem', 7, '2026'),
    (322, 'Computer Education VIII.pdf', 'English', 'Computer Education', 8, '2026'),
    (323, 'Salees Urdu XI.pdf', 'Sindhi', 'Salees Urdu', 11, '2026'),
    (324, 'Computer Science XI.pdf', 'English', 'Computer Science', 11, '2026-27'),
    (39, 'General Knowledge I.pdf', 'English', 'General Knowledge', 1, '2020-21'),
    (40, 'Math I.pdf', 'English', 'Mathematics', 1, '2026'),
    (41, 'Arabic VI.pdf', 'Sindhi', 'Arabic', 6, '2020-21'),
    (42, 'Sindhi Reader I.pdf', 'Sindhi', 'Sindhi Reader', 1, '2020-21'),
    (43, 'Arabic VI.pdf', 'Urdu', 'Arabic', 6, '2020-21'),
    (46, 'Arabic VI.pdf', 'English', 'Arabic', 6, '2020-21'),
    (47, 'General Knowledge I.pdf', 'Sindhi', 'General Knowledge', 1, '2020-21'),
    (48, 'General Knowledge I.pdf', 'Urdu', 'General Knowledge', 1, '2026'),
    (51, 'Arabic VII.pdf', 'Sindhi', 'Arabic', 7, '2020-21'),
    (52, 'Arabic VII.pdf', 'Urdu', 'Arabic', 7, '2020-21'),
    (53, 'Arabic VII.pdf', 'English', 'Arabic', 7, '2020-21'),
    (54, 'Arabic VIII.pdf', 'Sindhi', 'Arabic', 8, '2020-21'),
    (55, 'Arabic VIII.pdf', 'Urdu', 'Arabic', 8, '2020-21'),
    (65, 'Asaan Sindhi V.pdf', 'Sindhi', 'Asan Sindhi', 5, '2026'),
    (66, 'Asaan Sindhi VI.pdf', 'Sindhi', 'Asan Sindhi', 6, '2020-21'),
    (67, 'Asaan Sindhi VII.pdf', 'Sindhi', 'Asan Sindhi', 7, '2020-21'),
    (69, 'Asaan Sindhi VIII.pdf', 'Sindhi', 'Asan Sindhi', 8, '2026'),
    (79, 'General Knowledge II.pdf', 'Sindhi', 'General Knowledge', 2, '2020-21'),
    (80, 'Social Studies V.pdf', 'English', 'Social Studies', 5, '2020-21'),
    (83, 'Science V.pdf', 'English', 'Science', 5, '2020-21'),
    (84, 'Science IV.pdf', 'English', 'Science', 4, '2025-26'),
    (85, 'Math III.pdf', 'English', 'Mathematics', 3, '2024-25'),
    (86, 'Math II.pdf', 'English', 'Mathematics', 2, '2026'),
    (87, 'Math IV.pdf', 'English', 'Mathematics', 4, '2024-25'),
    (88, 'Sindhi Reader II.pdf', 'Sindhi', 'Sindhi Reader', 2, '2026'),
    (89, 'Sindhi Reader III.pdf', 'Sindhi', 'Sindhi Reader', 3, '2026'),
    (90, 'Sindhi Reader IV.pdf', 'Sindhi', 'Sindhi Reader', 4, '2026'),
    (91, 'Sindhi Reader V.pdf', 'Sindhi', 'Sindhi Reader', 5, '2026'),
    (94, 'Sindhi Reader VIII.pdf', 'Sindhi', 'Sindhi Reader', 8, '2026'),
    (95, 'Math V.pdf', 'English', 'Mathematics', 5, '2024-25'),
    (96, 'Math VI.pdf', 'English', 'Mathematics', 6, '2020-21'),
    (97, 'Math VII.pdf', 'English', 'Mathematics', 7, '2020-21'),
    (98, 'Science VIII.pdf', 'Urdu', 'Science', 8, '2020-21'),
]

def slugify(s):
    return re.sub(r'^-|-$', '', re.sub(r'[^a-z0-9]+', '-', s.lower()))

def classify_scheme(year):
    if not year: return None
    if year in ('2026-27', '2025-26'): return 'new'
    if year in ('2023-24', '2024-25'): return 'snc'
    return 'previous'

def medium_initial(m):
    return {'english': 'e', 'urdu': 'u', 'sindhi': 's'}.get(m.lower(), 'x')

# Deduplicate on (class, subject, medium, year)
seen = set()
created = 0
skipped = 0

for book_id, filename, medium, subject, cls, year in raw:
    # Skip pre-primary (no class number)
    if cls is None:
        skipped += 1
        continue

    cls_str = str(cls)
    medium_lc = medium.lower()

    key = (cls_str, subject.lower(), medium_lc, year or '')
    if key in seen:
        skipped += 1
        continue
    seen.add(key)

    # Title
    title = subject
    if medium_lc == 'english':
        title += ' (English Medium)'
    elif medium_lc == 'urdu':
        title += ' (Urdu Medium)'
    elif medium_lc == 'sindhi':
        title += ' (Sindhi Medium)'
    title += f' — Class {cls_str}'
    if year:
        title += f' ({year})'

    # Filename
    slug = slugify(subject)
    parts = [cls_str, 'stbb', slug, medium_initial(medium)]
    if year:
        parts.append(year.replace('-', '_').replace('/', '_'))
    fname = '-'.join(parts) + '.json'

    # Collision handling
    target = BOOKS_DIR / fname
    if target.exists():
        i = 2
        while (BOOKS_DIR / f'{fname[:-5]}-{i}.json').exists():
            i += 1
        target = BOOKS_DIR / f'{fname[:-5]}-{i}.json'

    url = f'https://portal.stbb.edu.pk/ebooks/pdf_proxy.php?id={book_id}&download=1'

    data = {
        'title': title,
        'author': 'Sindh Textbook Board (STBB)',
        'class': cls_str,
        'subject': subject,
        'boards': ['Sindh'],
        'medium': medium_lc,
        'pdfUrl': url,
    }
    scheme = classify_scheme(year)
    if scheme: data['scheme'] = scheme
    if year: data['year'] = year

    target.write_text(json.dumps(data, indent=2, ensure_ascii=False))
    created += 1

print(f'  ✓ Created {created} STBB book files')
print(f'  · Skipped {skipped} (pre-primary or duplicates)')
print()

# Stats
by_class = {}
by_medium = {}
for f in BOOKS_DIR.glob('*stbb*.json'):
    d = json.loads(f.read_text())
    by_class[d['class']] = by_class.get(d['class'], 0) + 1
    by_medium[d.get('medium', '?')] = by_medium.get(d.get('medium', '?'), 0) + 1

print('  By class:')
for c in sorted(by_class.keys(), key=int):
    print(f'    Class {c}: {by_class[c]}')
print()
print('  By medium:')
for m, n in sorted(by_medium.items()):
    print(f'    {m}: {n}')
PYEOF

echo ""
echo "════════════════════════════════════════════"
echo "  DONE — STBB books added"
echo ""
if [ -d "src/content-full" ]; then
  echo "  Fast mode active — books are in src/content-full/books/"
  echo "  To preview: Ctrl+C, then run: bash devfull.sh"
  echo "               bash start-server.sh"
else
  echo "  Full mode — rebuild + preview:"
  echo "    npm run build"
  echo "    bash start-server.sh"
fi
echo ""
echo "  Push (GitHub builds in 5-8 min):"
echo "    git add ."
echo "    git commit -m 'Add STBB books (Sindh Textbook Board)'"
echo "    git push"
echo ""
echo "  Check after live:"
echo "    /board/sindh/class-9/books/"
echo "    /board/sindh/class-10/books/"
echo "    /books?board=Sindh"
echo "════════════════════════════════════════════"