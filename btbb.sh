#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "════════════════════════════════════════════"
echo "  Adding BTBB books (Balochistan)"
echo "════════════════════════════════════════════"
echo ""

# Detect which content folder is active
if [ -d "src/content-full" ]; then
  echo "  Fast mode detected — writing to src/content-full/books/"
  export BOOKS_DIR="src/content-full/books"
else
  export BOOKS_DIR="src/content/books"
fi
mkdir -p "$BOOKS_DIR"
echo "  Target: $BOOKS_DIR"
echo ""

python3 <<'PYEOF'
import json, pathlib, re, os

BOOKS_DIR = pathlib.Path(os.environ.get('BOOKS_DIR', 'src/content/books'))
BOOKS_DIR.mkdir(parents=True, exist_ok=True)

# (id, title, grade, subject, medium)
raw = [
    # Grade 1
    (403, 'English - Grade 1', 1, 'English', None),
    (404, 'General Knowledge - Grade 1', 1, 'General Knowledge', None),
    (405, 'Islamiat - Grade 1', 1, 'Islamiat', None),
    (406, 'Math - Grade 1', 1, 'Mathematics', None),
    (407, 'Urdu - Grade 1', 1, 'Urdu', None),

    # Grade 2
    (408, 'English - Grade 2', 2, 'English', None),
    (409, 'General Knowledge - Grade 2', 2, 'General Knowledge', None),
    (410, 'Islamiat - Grade 2', 2, 'Islamiat', None),
    (411, 'Math - Grade 2', 2, 'Mathematics', None),
    (412, 'Urdu - Grade 2', 2, 'Urdu', None),

    # Grade 3
    (413, 'English - Grade 3', 3, 'English', None),
    (414, 'General Knowledge - Grade 3', 3, 'General Knowledge', None),
    (415, 'Islamiat - Grade 3', 3, 'Islamiat', None),
    (416, 'Math - Grade 3', 3, 'Mathematics', None),

    # Grade 4 (Math and Mathematics are duplicates — keep one)
    (417, 'English - Grade 4', 4, 'English', None),
    (418, 'General Science - Grade 4', 4, 'General Science', None),
    (419, 'Mathematics - Grade 4', 4, 'Mathematics', None),

    # Grade 5
    (421, 'General Science - Grade 5', 5, 'General Science', None),
    (422, 'Muasharti Uloom - Grade 5', 5, 'Muasharti Uloom', 'urdu'),

    # Grade 6
    (423, 'Computer Science - Grade 6', 6, 'Computer Science', None),
    (424, 'English - Grade 6', 6, 'English', None),
    (425, 'General Science - Grade 6', 6, 'General Science', None),
    (426, 'Geography - Grade 6 (English Medium)', 6, 'Geography', 'english'),
    (427, 'Geography - Grade 6 (Urdu Medium)', 6, 'Geography', 'urdu'),
    (428, 'History - Grade 6 (Urdu Medium)', 6, 'History', 'urdu'),
    (429, 'Islamiat - Grade 6', 6, 'Islamiat', None),
    (430, 'Tarjuma-tul-Quran - Grade 6', 6, 'Tarjuma Tul Quran', None),
    (431, 'Urdu - Grade 6', 6, 'Urdu', None),

    # Grade 7
    (432, 'Computer Science - Grade 7', 7, 'Computer Science', None),
    (433, 'English - Grade 7', 7, 'English', None),
    (434, 'General Science - Grade 7', 7, 'General Science', None),
    (435, 'Geography - Grade 7 (Urdu Medium)', 7, 'Geography', 'urdu'),
    (436, 'Geography - Grade 7 (English Medium)', 7, 'Geography', 'english'),
    (437, 'History - Grade 7', 7, 'History', None),
    (438, 'Islamiat - Grade 7', 7, 'Islamiat', None),
    (439, 'Math - Grade 7', 7, 'Mathematics', None),
    (440, 'Tarjama-tul-Quran - Grade 7', 7, 'Tarjuma Tul Quran', None),
    (441, 'Urdu - Grade 7', 7, 'Urdu', None),

    # Grade 8
    (442, 'Geography - Grade 8 (English Medium)', 8, 'Geography', 'english'),
    (443, 'History - Grade 8 (English Medium)', 8, 'History', 'english'),
    (444, 'Computer Science - Grade 8', 8, 'Computer Science', None),
    (445, 'General Science - Grade 8', 8, 'General Science', None),
    (446, 'Geography - Grade 8 (Urdu Medium)', 8, 'Geography', 'urdu'),
    (447, 'History - Grade 8 (Urdu Medium)', 8, 'History', 'urdu'),
    (448, 'Math - Grade 8', 8, 'Mathematics', None),
    (449, 'Tarjama-tul-Quran (Ch 14-23) - Grade 8', 8, 'Tarjuma Tul Quran', None),

    # Grade 9
    (450, 'Biology - Grade 9', 9, 'Biology', None),
    (451, 'Chemistry - Grade 9', 9, 'Chemistry', None),
    (452, 'Computer Science - Grade 9', 9, 'Computer Science', None),
    (453, 'Math - Grade 9', 9, 'Mathematics', None),
    (454, 'Pak Study - Grade 9', 9, 'Pakistan Studies', None),
    (455, 'Physics - Grade 9', 9, 'Physics', None),
    (456, 'Urdu - Grade 9', 9, 'Urdu', None),

    # Grade 10
    (177, 'Chemistry - Grade 10', 10, 'Chemistry', None),
    (178, 'English - Grade 10', 10, 'English', None),
    (179, 'Islamiat - Grade 10', 10, 'Islamiat', None),
    (227, 'Pak Study - Grade 10 (English Medium)', 10, 'Pakistan Studies', 'english'),

    # Grade 11
    (457, 'Biology - Grade 11', 11, 'Biology', None),
    (458, 'English - Grade 11', 11, 'English', None),
    (459, 'Chemistry - Grade 11', 11, 'Chemistry', None),
    (460, 'Math - Grade 11', 11, 'Mathematics', None),
    (461, 'Physics - Grade 11', 11, 'Physics', None),
    (462, 'Islamiat - Grade 11', 11, 'Islamiat', None),
    (463, 'Urdu - Grade 11', 11, 'Urdu', None),

    # Grade 12
    (275, 'Biology - Grade 12', 12, 'Biology', None),
    (276, 'Chemistry - Grade 12', 12, 'Chemistry', None),
    (277, 'English - Grade 12', 12, 'English', None),
    (280, 'Physics - Grade 12', 12, 'Physics', None),
    (282, 'Urdu - Grade 12', 12, 'Urdu', None),
]

def slugify(s):
    return re.sub(r'^-|-$', '', re.sub(r'[^a-z0-9]+', '-', s.lower()))

created = 0
seen = set()

for book_id, title, grade, subject, medium in raw:
    cls_str = str(grade)

    key = (cls_str, subject.lower(), medium or '')
    if key in seen:
        continue
    seen.add(key)

    # Build display title
    display_title = subject
    if medium == 'english':
        display_title += ' (English Medium)'
    elif medium == 'urdu':
        display_title += ' (Urdu Medium)'
    display_title += f' — Class {cls_str}'

    # Filename
    slug = slugify(subject)
    parts = [cls_str, 'btbb', slug]
    if medium:
        parts.append(medium[0])
    fname = '-'.join(parts) + '.json'

    # Collision
    target = BOOKS_DIR / fname
    if target.exists():
        i = 2
        while (BOOKS_DIR / f'{fname[:-5]}-{i}.json').exists():
            i += 1
        target = BOOKS_DIR / f'{fname[:-5]}-{i}.json'

    url = f'https://btbb.com.pk/book-file.php?id={book_id}'

    data = {
        'title': display_title,
        'author': 'Balochistan Textbook Board (BTBB)',
        'class': cls_str,
        'subject': subject,
        'boards': ['Balochistan'],
        'pdfUrl': url,
    }
    if medium:
        data['medium'] = medium

    target.write_text(json.dumps(data, indent=2, ensure_ascii=False))
    created += 1

print(f'  ✓ Created {created} BTBB book files')
print()

# Stats
by_class = {}
for f in BOOKS_DIR.glob('*btbb*.json'):
    d = json.loads(f.read_text())
    by_class[d['class']] = by_class.get(d['class'], 0) + 1

print('  By class:')
for c in sorted(by_class.keys(), key=int):
    print(f'    Class {c}: {by_class[c]}')
PYEOF

echo ""
echo "════════════════════════════════════════════"
echo "  DONE"
echo ""
if [ -d "src/content-full" ]; then
  echo "  Fast mode — books in src/content-full/books/"
  echo "  To preview: Ctrl+C, then: bash devfull.sh && npm run build && bash start-server.sh"
else
  echo "  Preview:"
  echo "    npm run build"
  echo "    bash start-server.sh"
fi
echo ""
echo "  Push:"
echo "    git add . && git commit -m 'Add BTBB books (Balochistan)' && git push"
echo ""
echo "  Skipped:"
echo "    · Grade Primer (pre-primary)"
echo "    · Scheme of Studies (not a textbook)"
echo "    · Duplicate Math/Mathematics Grade 4"
echo "════════════════════════════════════════════"