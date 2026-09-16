#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Stage 1 — Data foundation"
echo "════════════════════════════════════════════"
echo ""

mkdir -p src/lib
mkdir -p src/content/past-papers
mkdir -p src/content/guess-papers
mkdir -p src/content/pairing-schemes

# ═══════════════════════════════════════════════
#  1. Boards library
# ═══════════════════════════════════════════════
cat > src/lib/boards.ts <<'EOF'
export const BOARDS = [
  { slug: 'punjab',      name: 'Punjab',      full: 'Punjab Boards',           short: 'Punjab' },
  { slug: 'federal',     name: 'Federal',     full: 'Federal Board (FBISE)',   short: 'Federal' },
  { slug: 'kpk',         name: 'KPK',         full: 'Khyber Pakhtunkhwa Boards', short: 'KPK' },
  { slug: 'sindh',       name: 'Sindh',       full: 'Sindh Boards',            short: 'Sindh' },
  { slug: 'balochistan', name: 'Balochistan', full: 'Balochistan Boards',      short: 'Balochistan' },
  { slug: 'ajk',         name: 'AJK',         full: 'AJK Boards',              short: 'AJK' },
];

export function boardBySlug(slug: string) {
  return BOARDS.find(b => b.slug === slug);
}

export function boardByName(name: string) {
  return BOARDS.find(b => b.name === name);
}

// Given a content item, work out which boards it belongs to.
// Priority: `boards` array → `board` string → all boards.
export function itemBoards(data: any): string[] {
  if (Array.isArray(data?.boards) && data.boards.length) return data.boards;
  if (typeof data?.board === 'string' && data.board) {
    if (data.board === 'All Boards' || data.board === 'All') return BOARDS.map(b => b.name);
    return [data.board];
  }
  return BOARDS.map(b => b.name);
}

export function matchesBoard(data: any, boardName: string): boolean {
  return itemBoards(data).includes(boardName);
}

export const SUBJECTS = [
  'Mathematics', 'Physics', 'Chemistry', 'Biology',
  'English', 'Urdu', 'Islamiat', 'Pakistan Studies',
  'Computer Science',
];

export const CLASSES = ['9', '10', '11', '12'];
export const BOOK_CLASSES = ['1','2','3','4','5','6','7','8','9','10','11','12'];

export const CONTENT_TYPES = [
  { slug: 'notes',            label: 'Notes',            icon: 'file-text',     plural: 'notes' },
  { slug: 'quizzes',          label: 'Quizzes',          icon: 'circle-help',   plural: 'quizzes' },
  { slug: 'books',            label: 'Books',            icon: 'book-marked',   plural: 'books' },
  { slug: 'past-papers',      label: 'Past Papers',      icon: 'scroll-text',   plural: 'past papers' },
  { slug: 'guess-papers',     label: 'Guess Papers',     icon: 'sparkles',      plural: 'guess papers' },
  { slug: 'pairing-schemes',  label: 'Pairing Schemes',  icon: 'list',          plural: 'pairing schemes' },
  { slug: 'gazettes',         label: 'Result Gazettes',  icon: 'newspaper',     plural: 'gazettes' },
];
EOF
echo "  created src/lib/boards.ts"

# ═══════════════════════════════════════════════
#  2. Content config — add boards array + 3 new collections
# ═══════════════════════════════════════════════
cat > src/content.config.ts <<'EOF'
import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const notes = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/notes' }),
  schema: z.object({
    title: z.string(),
    subject: z.string(),
    class: z.string(),
    board: z.string().optional(),
    boards: z.array(z.string()).optional(),
    pdfUrl: z.string().optional(),
    date: z.date().optional(),
  }),
});

const quizzes = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/quizzes' }),
  schema: z.object({
    title: z.string(),
    subject: z.string(),
    class: z.string(),
    board: z.string().optional(),
    boards: z.array(z.string()).optional(),
    questions: z.array(z.object({
      question: z.string(),
      options: z.array(z.string()),
      answer: z.number(),
    })),
  }),
});

const books = defineCollection({
  loader: glob({ pattern: '**/*.json', base: './src/content/books' }),
  schema: z.object({
    title: z.string(),
    author: z.string().optional(),
    class: z.string(),
    subject: z.string(),
    board: z.string().optional(),
    boards: z.array(z.string()).optional(),
    pdfUrl: z.string(),
  }),
});

const gazettes = defineCollection({
  loader: glob({ pattern: '**/*.json', base: './src/content/gazettes' }),
  schema: z.object({
    title: z.string(),
    year: z.number(),
    board: z.string(),
    boards: z.array(z.string()).optional(),
    class: z.string(),
    pdfUrl: z.string(),
  }),
});

const pastPapers = defineCollection({
  loader: glob({ pattern: '**/*.json', base: './src/content/past-papers' }),
  schema: z.object({
    title: z.string(),
    subject: z.string(),
    class: z.string(),
    year: z.number(),
    board: z.string().optional(),
    boards: z.array(z.string()).optional(),
    pdfUrl: z.string(),
  }),
});

const guessPapers = defineCollection({
  loader: glob({ pattern: '**/*.json', base: './src/content/guess-papers' }),
  schema: z.object({
    title: z.string(),
    subject: z.string(),
    class: z.string(),
    year: z.number(),
    board: z.string().optional(),
    boards: z.array(z.string()).optional(),
    pdfUrl: z.string(),
  }),
});

const pairingSchemes = defineCollection({
  loader: glob({ pattern: '**/*.json', base: './src/content/pairing-schemes' }),
  schema: z.object({
    title: z.string(),
    class: z.string(),
    year: z.number(),
    board: z.string().optional(),
    boards: z.array(z.string()).optional(),
    pdfUrl: z.string(),
  }),
});

export const collections = {
  notes, quizzes, books, gazettes,
  pastPapers, guessPapers, pairingSchemes,
};
EOF
echo "  updated src/content.config.ts"

# ═══════════════════════════════════════════════
#  3. Sample content — past papers
# ═══════════════════════════════════════════════
cat > src/content/past-papers/physics-10-punjab-2024.json <<'EOF'
{
  "title": "Physics Class 10 Past Paper 2024",
  "subject": "Physics",
  "class": "10",
  "year": 2024,
  "boards": ["Punjab"],
  "pdfUrl": "/pdfs/past-papers/physics-10-punjab-2024.pdf"
}
EOF

cat > src/content/past-papers/physics-10-punjab-2023.json <<'EOF'
{
  "title": "Physics Class 10 Past Paper 2023",
  "subject": "Physics",
  "class": "10",
  "year": 2023,
  "boards": ["Punjab"],
  "pdfUrl": "/pdfs/past-papers/physics-10-punjab-2023.pdf"
}
EOF

cat > src/content/past-papers/math-10-federal-2024.json <<'EOF'
{
  "title": "Mathematics Class 10 Past Paper 2024",
  "subject": "Mathematics",
  "class": "10",
  "year": 2024,
  "boards": ["Federal"],
  "pdfUrl": "/pdfs/past-papers/math-10-federal-2024.pdf"
}
EOF

cat > src/content/past-papers/chemistry-9-punjab-2024.json <<'EOF'
{
  "title": "Chemistry Class 9 Past Paper 2024",
  "subject": "Chemistry",
  "class": "9",
  "year": 2024,
  "boards": ["Punjab"],
  "pdfUrl": "/pdfs/past-papers/chemistry-9-punjab-2024.pdf"
}
EOF

cat > src/content/past-papers/biology-11-federal-2023.json <<'EOF'
{
  "title": "Biology Class 11 Past Paper 2023",
  "subject": "Biology",
  "class": "11",
  "year": 2023,
  "boards": ["Federal"],
  "pdfUrl": "/pdfs/past-papers/biology-11-federal-2023.pdf"
}
EOF

cat > src/content/past-papers/physics-12-kpk-2024.json <<'EOF'
{
  "title": "Physics Class 12 Past Paper 2024",
  "subject": "Physics",
  "class": "12",
  "year": 2024,
  "boards": ["KPK"],
  "pdfUrl": "/pdfs/past-papers/physics-12-kpk-2024.pdf"
}
EOF
echo "  added 6 past papers"

# ═══════════════════════════════════════════════
#  4. Sample content — guess papers
# ═══════════════════════════════════════════════
cat > src/content/guess-papers/physics-10-punjab-2025.json <<'EOF'
{
  "title": "Physics Class 10 Guess Paper 2025",
  "subject": "Physics",
  "class": "10",
  "year": 2025,
  "boards": ["Punjab"],
  "pdfUrl": "/pdfs/guess-papers/physics-10-punjab-2025.pdf"
}
EOF

cat > src/content/guess-papers/math-10-punjab-2025.json <<'EOF'
{
  "title": "Mathematics Class 10 Guess Paper 2025",
  "subject": "Mathematics",
  "class": "10",
  "year": 2025,
  "boards": ["Punjab"],
  "pdfUrl": "/pdfs/guess-papers/math-10-punjab-2025.pdf"
}
EOF

cat > src/content/guess-papers/chemistry-10-federal-2025.json <<'EOF'
{
  "title": "Chemistry Class 10 Guess Paper 2025",
  "subject": "Chemistry",
  "class": "10",
  "year": 2025,
  "boards": ["Federal"],
  "pdfUrl": "/pdfs/guess-papers/chemistry-10-federal-2025.pdf"
}
EOF

cat > src/content/guess-papers/biology-9-punjab-2025.json <<'EOF'
{
  "title": "Biology Class 9 Guess Paper 2025",
  "subject": "Biology",
  "class": "9",
  "year": 2025,
  "boards": ["Punjab"],
  "pdfUrl": "/pdfs/guess-papers/biology-9-punjab-2025.pdf"
}
EOF
echo "  added 4 guess papers"

# ═══════════════════════════════════════════════
#  5. Sample content — pairing schemes
# ═══════════════════════════════════════════════
cat > src/content/pairing-schemes/punjab-10-2025.json <<'EOF'
{
  "title": "Punjab Board Class 10 Pairing Scheme 2025",
  "class": "10",
  "year": 2025,
  "boards": ["Punjab"],
  "pdfUrl": "/pdfs/pairing-schemes/punjab-10-2025.pdf"
}
EOF

cat > src/content/pairing-schemes/punjab-9-2025.json <<'EOF'
{
  "title": "Punjab Board Class 9 Pairing Scheme 2025",
  "class": "9",
  "year": 2025,
  "boards": ["Punjab"],
  "pdfUrl": "/pdfs/pairing-schemes/punjab-9-2025.pdf"
}
EOF

cat > src/content/pairing-schemes/federal-10-2025.json <<'EOF'
{
  "title": "Federal Board Class 10 Pairing Scheme 2025",
  "class": "10",
  "year": 2025,
  "boards": ["Federal"],
  "pdfUrl": "/pdfs/pairing-schemes/federal-10-2025.pdf"
}
EOF

cat > src/content/pairing-schemes/kpk-12-2025.json <<'EOF'
{
  "title": "KPK Board Class 12 Pairing Scheme 2025",
  "class": "12",
  "year": 2025,
  "boards": ["KPK"],
  "pdfUrl": "/pdfs/pairing-schemes/kpk-12-2025.pdf"
}
EOF
echo "  added 4 pairing schemes"

# ═══════════════════════════════════════════════
#  6. Placeholder PDF folders
# ═══════════════════════════════════════════════
mkdir -p public/pdfs/past-papers public/pdfs/guess-papers public/pdfs/pairing-schemes

touch public/pdfs/past-papers/physics-10-punjab-2024.pdf
touch public/pdfs/past-papers/physics-10-punjab-2023.pdf
touch public/pdfs/past-papers/math-10-federal-2024.pdf
touch public/pdfs/past-papers/chemistry-9-punjab-2024.pdf
touch public/pdfs/past-papers/biology-11-federal-2023.pdf
touch public/pdfs/past-papers/physics-12-kpk-2024.pdf

touch public/pdfs/guess-papers/physics-10-punjab-2025.pdf
touch public/pdfs/guess-papers/math-10-punjab-2025.pdf
touch public/pdfs/guess-papers/chemistry-10-federal-2025.pdf
touch public/pdfs/guess-papers/biology-9-punjab-2025.pdf

touch public/pdfs/pairing-schemes/punjab-10-2025.pdf
touch public/pdfs/pairing-schemes/punjab-9-2025.pdf
touch public/pdfs/pairing-schemes/federal-10-2025.pdf
touch public/pdfs/pairing-schemes/kpk-12-2025.pdf

echo "  added placeholder PDFs"

# ═══════════════════════════════════════════════
#  7. Rebuild to verify
# ═══════════════════════════════════════════════
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -20

echo ""
echo "════════════════════════════════════════════"
echo "  Stage 1 complete."
echo ""
echo "  Added:"
echo "    src/lib/boards.ts                 6 boards + helpers"
echo "    src/content.config.ts             + 3 new collections"
echo "    src/content/past-papers/          6 sample papers"
echo "    src/content/guess-papers/         4 sample papers"
echo "    src/content/pairing-schemes/      4 sample schemes"
echo ""
echo "  No UI changes yet. Existing pages untouched."
echo ""
echo "  If the build succeeds, push:"
echo "    git add ."
echo "    git commit -m 'Stage 1: board-first data foundation'"
echo "    git push"
echo ""
echo "  Then say 'go' and I'll write Stage 2 (the UI)."
echo "════════════════════════════════════════════"