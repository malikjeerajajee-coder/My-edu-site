#!/bin/bash

echo "==================================================="
echo "  CONTENT DIAGNOSTICS"
echo "==================================================="
echo ""

echo "1. Folder structure:"
echo "   src/content/ contents:"
ls -la src/content/ 2>/dev/null | head -20
echo ""

echo "2. Files in each collection:"
for dir in notes quizzes books gazettes; do
  echo "   src/content/$dir/:"
  ls src/content/$dir/ 2>/dev/null | head -10 | sed 's/^/     /'
  count=$(ls src/content/$dir/ 2>/dev/null | wc -l)
  echo "     ($count files)"
done
echo ""

echo "3. Content config location:"
if [ -f "src/content.config.ts" ]; then
  echo "   ✓ src/content.config.ts EXISTS"
  echo "   Content:"
  cat src/content.config.ts | head -30 | sed 's/^/     /'
elif [ -f "src/content/config.ts" ]; then
  echo "   ✗ Wrong location: src/content/config.ts (needs to move)"
else
  echo "   ✗ NO content config found"
fi
echo ""

echo "4. First note content (if exists):"
if [ -f "src/content/notes/math-10-ch1.md" ]; then
  head -15 src/content/notes/math-10-ch1.md | sed 's/^/     /'
else
  echo "     File missing!"
  echo "     Files actually present:"
  ls src/content/notes/ 2>/dev/null | sed 's/^/       /'
fi
echo ""

echo "5. Astro version:"
node -e "console.log('   ' + require('./node_modules/astro/package.json').version)" 2>/dev/null
echo ""

# ============ REGENERATE EVERYTHING ============
echo "==================================================="
echo "  REGENERATING CONTENT FROM SCRATCH"
echo "==================================================="
echo ""

# Wipe and recreate
rm -rf src/content
mkdir -p src/content/notes src/content/quizzes src/content/books src/content/gazettes

# ---- CONTENT CONFIG ----
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
    pdfUrl: z.string(),
  }),
});

const gazettes = defineCollection({
  loader: glob({ pattern: '**/*.json', base: './src/content/gazettes' }),
  schema: z.object({
    title: z.string(),
    year: z.number(),
    board: z.string(),
    class: z.string(),
    pdfUrl: z.string(),
  }),
});

export const collections = { notes, quizzes, books, gazettes };
EOF

# ---- NOTES ----
cat > src/content/notes/math-10-ch1.md <<'EOF'
---
title: "Math — Chapter 1: Quadratic Equations"
subject: "Mathematics"
class: "10"
board: "Punjab"
pdfUrl: "/pdfs/math-10-ch1.pdf"
date: 2026-01-15
---

## Introduction

A **quadratic equation** is a second-degree polynomial equation in a single variable, written in the standard form:

**ax² + bx + c = 0**, where a ≠ 0.

## Methods of Solving

- **Factorization** — quick when roots are integers.
- **Completing the Square** — useful for deriving the quadratic formula.
- **Quadratic Formula** — works for all equations: x = (-b ± √(b² - 4ac)) / 2a

## Discriminant

D = b² - 4ac

- D > 0 → two distinct real roots
- D = 0 → two equal real roots
- D < 0 → no real roots
EOF

cat > src/content/notes/physics-9-ch1.md <<'EOF'
---
title: "Physics — Chapter 1: Physical Quantities & Measurement"
subject: "Physics"
class: "9"
board: "Federal"
pdfUrl: "/pdfs/physics-9-ch1.pdf"
date: 2026-01-15
---

## Physical Quantities

A **physical quantity** is anything that can be measured.

## Base vs Derived

| Type | Example | Unit |
|------|---------|------|
| Base | Length | metre |
| Base | Mass | kilogram |
| Derived | Speed | m/s |
| Derived | Force | newton |

## Prefixes

- **kilo (k)** = 10³
- **mega (M)** = 10⁶
- **milli (m)** = 10⁻³
EOF

cat > src/content/notes/chemistry-10-ch1.md <<'EOF'
---
title: "Chemistry — Chapter 1: Chemical Equilibrium"
subject: "Chemistry"
class: "10"
board: "Punjab"
pdfUrl: "/pdfs/chemistry-10-ch1.pdf"
date: 2026-01-15
---

## Reversible Reactions

A **reversible reaction** can proceed in both directions and reaches **dynamic equilibrium** when forward and reverse rates are equal.

## Le Chatelier's Principle

If a system at equilibrium is disturbed, the system shifts to counteract the disturbance.

- Increase pressure → shifts to side with fewer gas moles
- Increase temperature → shifts endothermically
EOF

cat > src/content/notes/biology-11-ch1.md <<'EOF'
---
title: "Biology — Chapter 1: Cell Biology"
subject: "Biology"
class: "11"
board: "Federal"
pdfUrl: "/pdfs/biology-11-ch1.pdf"
date: 2026-01-15
---

## The Cell

The **cell** is the smallest structural and functional unit of living organisms.

## Cell Theory

1. All living things are made of cells.
2. The cell is the basic unit of life.
3. All cells come from pre-existing cells.

## Key Organelles

- **Mitochondria** — ATP production
- **Ribosomes** — protein synthesis
- **Chloroplast** — photosynthesis (plants only)
EOF

cat > src/content/notes/english-9-essays.md <<'EOF'
---
title: "English — Important Essays for Class 9"
subject: "English"
class: "9"
board: "All Boards"
pdfUrl: "/pdfs/english-9-essays.pdf"
date: 2026-01-15
---

## My Country Pakistan

Pakistan came into being on 14 August 1947 after the untiring efforts of Quaid-e-Azam Muhammad Ali Jinnah.

## Role of Students in Nation Building

Students are the future of any nation. They must focus on education and develop good character.

## Importance of Education

Education is the key to success. It enlightens minds and empowers people.
EOF

# ---- QUIZZES ----
cat > src/content/quizzes/math-10-ch1-quiz.md <<'EOF'
---
title: "Math Class 10 — Chapter 1 Quiz"
subject: "Mathematics"
class: "10"
questions:
  - question: "What is the standard form of a quadratic equation?"
    options: ["ax + b = 0", "ax² + bx + c = 0", "ax³ + bx² + c = 0", "a/x + b = 0"]
    answer: 1
  - question: "The discriminant is given by:"
    options: ["b² + 4ac", "b² - 4ac", "4ac - b²", "2a + b"]
    answer: 1
  - question: "If D = 0, the roots are:"
    options: ["Distinct real", "Equal real", "Imaginary", "Undefined"]
    answer: 1
---

Practice these MCQs to master quadratic equations.
EOF

cat > src/content/quizzes/physics-9-ch1-quiz.md <<'EOF'
---
title: "Physics Class 9 — Chapter 1 Quiz"
subject: "Physics"
class: "9"
questions:
  - question: "Which is a base quantity?"
    options: ["Speed", "Force", "Length", "Pressure"]
    answer: 2
  - question: "Least count of Vernier Callipers is:"
    options: ["0.1 cm", "0.01 cm", "0.001 cm", "1 cm"]
    answer: 1
  - question: "1 kilometre equals:"
    options: ["10 m", "100 m", "1000 m", "10000 m"]
    answer: 2
---

Test your understanding of measurement.
EOF

cat > src/content/quizzes/chemistry-10-ch1-quiz.md <<'EOF'
---
title: "Chemistry Class 10 — Chemical Equilibrium Quiz"
subject: "Chemistry"
class: "10"
questions:
  - question: "At equilibrium, forward rate is:"
    options: ["Greater than reverse", "Less than reverse", "Equal to reverse", "Zero"]
    answer: 2
  - question: "Le Chatelier's Principle applies to:"
    options: ["Irreversible reactions", "Systems at equilibrium", "Gas reactions only", "Nuclear reactions"]
    answer: 1
---

Master dynamic equilibrium.
EOF

# ---- BOOKS ----
cat > src/content/books/physics-9.json <<'EOF'
{"title": "Physics Textbook for Class 9", "author": "Punjab Textbook Board", "class": "9", "subject": "Physics", "pdfUrl": "/pdfs/physics-9-textbook.pdf"}
EOF

cat > src/content/books/math-10.json <<'EOF'
{"title": "Mathematics Textbook for Class 10", "author": "Punjab Textbook Board", "class": "10", "subject": "Mathematics", "pdfUrl": "/pdfs/math-10-textbook.pdf"}
EOF

cat > src/content/books/chemistry-10.json <<'EOF'
{"title": "Chemistry Textbook for Class 10", "author": "Federal Board", "class": "10", "subject": "Chemistry", "pdfUrl": "/pdfs/chemistry-10-textbook.pdf"}
EOF

cat > src/content/books/biology-11.json <<'EOF'
{"title": "Biology Textbook for Class 11", "author": "KPK Textbook Board", "class": "11", "subject": "Biology", "pdfUrl": "/pdfs/biology-11-textbook.pdf"}
EOF

# ---- GAZETTES ----
cat > src/content/gazettes/bise-lahore-10-2025.json <<'EOF'
{"title": "BISE Lahore Class 10 Result Gazette 2025", "year": 2025, "board": "BISE Lahore", "class": "10", "pdfUrl": "/pdfs/bise-lahore-10-2025.pdf"}
EOF

cat > src/content/gazettes/bise-karachi-9-2024.json <<'EOF'
{"title": "BISE Karachi Class 9 Result Gazette 2024", "year": 2024, "board": "BISE Karachi", "class": "9", "pdfUrl": "/pdfs/bise-karachi-9-2024.pdf"}
EOF

cat > src/content/gazettes/bise-rawalpindi-10-2024.json <<'EOF'
{"title": "BISE Rawalpindi Class 10 Result Gazette 2024", "year": 2024, "board": "BISE Rawalpindi", "class": "10", "pdfUrl": "/pdfs/bise-rawalpindi-10-2024.pdf"}
EOF

# ---- PDFs ----
mkdir -p public/pdfs
touch public/pdfs/math-10-ch1.pdf \
      public/pdfs/physics-9-ch1.pdf \
      public/pdfs/chemistry-10-ch1.pdf \
      public/pdfs/biology-11-ch1.pdf \
      public/pdfs/english-9-essays.pdf \
      public/pdfs/physics-9-textbook.pdf \
      public/pdfs/math-10-textbook.pdf \
      public/pdfs/chemistry-10-textbook.pdf \
      public/pdfs/biology-11-textbook.pdf \
      public/pdfs/bise-lahore-10-2025.pdf \
      public/pdfs/bise-karachi-9-2024.pdf \
      public/pdfs/bise-rawalpindi-10-2024.pdf

# ---- DEBUG PAGE ----
cat > src/pages/debug.astro <<'EOF'
---
import { getCollection } from 'astro:content';
const notes = await getCollection('notes');
const quizzes = await getCollection('quizzes');
const books = await getCollection('books');
const gazettes = await getCollection('gazettes');
---
<!DOCTYPE html>
<html>
<head><title>Debug</title></head>
<body style="font-family: monospace; padding: 20px; font-size: 14px;">
  <h1>Content Debug</h1>
  <ul>
    <li>notes: {notes.length}</li>
    <li>quizzes: {quizzes.length}</li>
    <li>books: {books.length}</li>
    <li>gazettes: {gazettes.length}</li>
  </ul>
  <h2>First note raw:</h2>
  <pre>{JSON.stringify(notes[0] ?? null, null, 2)}</pre>
</body>
</html>
EOF

# ---- CLEAR CACHES ----
rm -rf .astro node_modules/.vite node_modules/.astro dist

echo ""
echo "==================================================="
echo "  DONE"
echo "==================================================="
echo ""
echo "Files created:"
find src/content -type f | sort | sed 's/^/  /'
echo ""
echo "Next:"
echo "  1. Stop dev server (Ctrl+C)"
echo "  2. Run:  npm run dev"
echo "  3. Open:  http://localhost:4321/debug"
echo ""
echo "Paste me the debug page output if still broken."