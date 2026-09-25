#!/bin/sh
# Parhayi — Textbook Navigation Fix (Alpine Linux / Node.js)
set -e

G='\033[0;32m'; Y='\033[1;33m'; B='\033[0;34m'; R='\033[0;31m'; N='\033[0m'

echo ""
echo "══════════════════════════════════════════════════"
echo "  Parhayi — Textbook Navigation Fix"
echo "══════════════════════════════════════════════════"
echo ""

BOOKS_DIR="src/content/books"

if [ ! -d "$BOOKS_DIR" ]; then
  printf "${R}✗ Books directory not found: $BOOKS_DIR${N}\n"; exit 1
fi

# ══════════════════════════════════════════════
# STEP 1: Audit + Fix all book JSON files using Node
# ══════════════════════════════════════════════
printf "${B}→ 1/4  Auditing & fixing book JSON files…${N}\n"

node -e "
const fs = require('fs');
const path = require('path');

const dir = '$BOOKS_DIR';
const files = fs.readdirSync(dir).filter(f => f.endsWith('.json'));
let errors = 0, fixed = 0;

const VALID_BOARDS = ['Punjab','Federal','Sindh','KPK','Balochistan','AJK'];
const BOARD_MAP = {
  'Punjab Board':'Punjab','PTB':'Punjab','PCTB':'Punjab',
  'Federal Board':'Federal','FBISE':'Federal',
  'Sindh Board':'Sindh','STBB':'Sindh',
  'KPK Board':'KPK','KPTBB':'KPK',
  'Balochistan Board':'Balochistan','BTBB':'Balochistan',
  'AJK Board':'AJK','AJKTB':'AJK',
};

for (const file of files) {
  const fp = path.join(dir, file);
  let d;
  try { d = JSON.parse(fs.readFileSync(fp, 'utf8')); }
  catch(e) { console.log('  ${R}✗ ' + file + ': invalid JSON${N}'); errors++; continue; }

  let changed = false;

  // Fix class: number → string
  if (typeof d.class === 'number') {
    d.class = String(d.class);
    changed = true;
    console.log('  ${Y}⚠ ' + file + ': class → string${N}');
  }

  // Fix boards array
  if (!d.boards || !Array.isArray(d.boards) || d.boards.length === 0) {
    if (d.board) {
      d.boards = [BOARD_MAP[d.board] || d.board];
      changed = true;
      console.log('  ${Y}⚠ ' + file + ': created boards array from board field${N}');
    } else {
      console.log('  ${R}✗ ' + file + ': no boards info${N}');
      errors++;
    }
  }

  // Fix board names in boards array
  if (d.boards) {
    const newBoards = d.boards.map(b => BOARD_MAP[b] || b);
    if (JSON.stringify(newBoards) !== JSON.stringify(d.boards)) {
      d.boards = newBoards;
      changed = true;
      console.log('  ${Y}⚠ ' + file + ': board names normalized${N}');
    }
    // Validate
    for (const b of d.boards) {
      if (!VALID_BOARDS.includes(b)) {
        console.log('  ${R}✗ ' + file + ': unknown board \"' + b + '\"${N}');
        errors++;
      }
    }
  }

  // Check required fields
  for (const field of ['title','class','subject','pdfUrl']) {
    if (!d[field]) {
      console.log('  ${R}✗ ' + file + ': missing ' + field + '${N}');
      errors++;
    }
  }

  if (changed) {
    fs.writeFileSync(fp, JSON.stringify(d, null, 2) + '\n');
    fixed++;
  }
}

console.log('');
console.log('  Files: ' + files.length + ' | Fixed: ' + fixed + ' | Errors: ' + errors);
if (errors > 0) { console.log('  ${R}Fix errors before continuing!${N}'); process.exit(1); }
"

# ══════════════════════════════════════════════
# STEP 2: Fix TYPE_MAP books base path
# ══════════════════════════════════════════════
printf "\n${B}→ 2/4  Fixing TYPE_MAP books base path…${N}\n"

if grep -q "base: '/books'" src/lib/boardContent.ts 2>/dev/null; then
  sed -i "s|'books':            { label: 'Books',           icon: 'book-marked',   collection: 'books',           base: '/books' },|'books':            { label: 'Books',           icon: 'book-marked',   collection: 'books',           base: '/textbook' },|" src/lib/boardContent.ts
  printf "  ${G}✓ TYPE_MAP books base → /textbook${N}\n"
else
  printf "  ${G}✓ Already correct or pattern not found${N}\n"
fi

# ══════════════════════════════════════════════
# STEP 3: Verify class/[type] page uses /textbook
# ══════════════════════════════════════════════
printf "\n${B}→ 3/4  Verifying class type page…${N}\n"

if grep -q "detailBase: '/textbook'" "src/pages/class/[class]/[type].astro" 2>/dev/null; then
  printf "  ${G}✓ class/[type] already uses /textbook${N}\n"
else
  printf "  ${Y}⚠ Check class/[type].astro manually${N}\n"
fi

# ══════════════════════════════════════════════
# STEP 4: Rebuild
# ══════════════════════════════════════════════
printf "\n${B}→ 4/4  Rebuilding site…${N}\n"
printf "  ${Y}⚠ Running: npm run build${N}\n\n"

npm run build

echo ""
echo "══════════════════════════════════════════════════"
echo "  ${G}✓  Done!${N}"
echo "══════════════════════════════════════════════════"
echo ""
echo "  Test these URLs after build:"
echo "    /books/punjab               ← resource-wise"
echo "    /board/punjab/class-9/books ← board-wise"
echo "    /class/9/books              ← class-wise"
echo ""