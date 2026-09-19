#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  BACKUP FIRST"
echo "════════════════════════════════════════════"
echo ""

git branch -f backup-pre-covers-v2
git push -u origin backup-pre-covers-v2 2>&1 | tail -3 || echo "  (push failed — do manually later)"
echo "  ✓ Branch 'backup-pre-covers-v2' created"
echo ""

cat > restore.sh <<'RESTORE'
#!/bin/bash
set -e
echo "Restoring from backup-pre-covers-v2..."
git fetch origin backup-pre-covers-v2
git checkout backup-pre-covers-v2
git branch -D main || true
git checkout -b main
git push -f origin main
echo ""
echo "✓ Restored. Site redeploys in 5-8 min."
RESTORE
chmod +x restore.sh
echo "  ✓ restore.sh written"
echo ""

# ─────────────────────────────────────────────
#  BookCover component — light theme
# ─────────────────────────────────────────────
cat > src/components/BookCover.astro <<'ASTRO'
---
interface Props {
  subject: string;
  classNumber: string;
  board: string;
  publisher?: string;
}

const { subject, classNumber, board, publisher = '' } = Astro.props;

// ─── Subject accent color (mirrors site tile palette) ───
const ACCENTS: Record<string, string> = {
  'Physics':              '#1e3a8a',
  'Chemistry':            '#047857',
  'Biology':              '#15803d',
  'Mathematics':          '#6d28d9',
  'English':              '#b91c1c',
  'Urdu':                 '#0f766e',
  'Islamiat':             '#15803d',
  'Islamic Studies':      '#15803d',
  'Pakistan Studies':     '#065f46',
  'Computer Science':     '#0369a1',
  'Statistics':           '#4338ca',
  'General Mathematics':  '#7c3aed',
  'General Science':      '#0284c7',
  'Social Studies':       '#b45309',
  'Nazra Quran':          '#059669',
  'General Knowledge':    '#0891b2',
};
const accent = ACCENTS[subject] || '#1d4ed8';

// ─── Wrap subject into up to 3 lines ───
function wrap(text: string, maxLen: number): string[] {
  const words = text.split(' ');
  const out: string[] = [];
  let cur = '';
  for (const w of words) {
    if ((cur + ' ' + w).trim().length <= maxLen) cur = (cur + ' ' + w).trim();
    else { if (cur) out.push(cur); cur = w; }
  }
  if (cur) out.push(cur);
  return out;
}

// Scale for length
let lines = wrap(subject, 12);
if (lines.length > 3) {
  lines = wrap(subject, 8);
}
const count = lines.length;
const fs = count === 1 ? 30 : count === 2 ? 24 : 18;
const lh = fs * 1.2;
const baseY = 200 - ((count - 1) * lh) / 2;

const boardLabel = board === 'Federal' ? 'FBISE' : board === 'Punjab' ? 'PTB' : board.toUpperCase();
const pubShort = publisher.includes('Punjab') ? 'Punjab Textbook Board'
              : publisher.includes('Federal') ? 'Federal Board (FBISE)'
              : 'Parhayi';

const uid = Math.random().toString(36).slice(2, 8);
---
<svg viewBox="0 0 300 420"
     xmlns="http://www.w3.org/2000/svg"
     role="img"
     aria-label={`${subject} — Class ${classNumber} textbook`}
     style="display: block; width: 100%; height: 100%;">

  <!-- Cover background — light, matches site -->
  <rect width="300" height="420" fill="#ffffff"/>

  <!-- Spine — solid accent color -->
  <rect x="0" y="0" width="8" height="420" fill={accent}/>

  <!-- Top rule + board label -->
  <line x1="28" y1="40" x2="60" y2="40" stroke={accent} stroke-width="2"/>
  <text x="28" y="68"
        font-family="'Plus Jakarta Sans', system-ui, sans-serif"
        font-size="10"
        font-weight="800"
        letter-spacing="2.2"
        fill="#94a3b8">{boardLabel}</text>

  <!-- Subject title -->
  {lines.map((line, i) => (
    <text x="28" y={baseY + i * lh}
          font-family="'Plus Jakarta Sans', system-ui, sans-serif"
          font-size={fs}
          font-weight="800"
          letter-spacing="-0.6"
          fill="#0b1220">{line}</text>
  ))}

  <!-- Class pill -->
  <g transform={`translate(28, ${baseY + (count - 1) * lh + 22})`}>
    <rect x="0" y="0"
          width="70" height="22"
          rx="11"
          fill="#eff4ff"/>
    <text x="35" y="15"
          text-anchor="middle"
          font-family="'Plus Jakarta Sans', system-ui, sans-serif"
          font-size="10.5"
          font-weight="800"
          letter-spacing="0.8"
          fill="#1d4ed8">CLASS {classNumber}</text>
  </g>

  <!-- Publisher (bottom) -->
  <text x="28" y="388"
        font-family="'Plus Jakarta Sans', system-ui, sans-serif"
        font-size="8.5"
        font-weight="700"
        letter-spacing="0.6"
        fill="#94a3b8">{pubShort}</text>

  <!-- Bottom accent rule -->
  <line x1="28" y1="398" x2="76" y2="398" stroke={accent} stroke-width="2"/>

  <!-- Subtle top-right mark — a minimal book glyph -->
  <g transform="translate(232, 40)" opacity="0.1">
    <rect x="0" y="0" width="40" height="46" rx="4"
          fill="none" stroke={accent} stroke-width="2"/>
    <line x1="0" y1="12" x2="40" y2="12"
          stroke={accent} stroke-width="2"/>
  </g>

  <!-- Very subtle inner border for definition -->
  <rect x="0.5" y="0.5" width="299" height="419"
        fill="none" stroke="#e5e9f0" stroke-width="1"/>
</svg>
ASTRO

echo "  ✓ BookCover.astro — light theme"

# ─────────────────────────────────────────────
#  /books grid layout
# ─────────────────────────────────────────────
cat > src/pages/books/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import PageFilter from '../../components/PageFilter.astro';
import BookCover from '../../components/BookCover.astro';
import { url } from '../../lib/url';
import { getCollection } from 'astro:content';

const books = await getCollection('books');
const CLASS_ORDER = ['1','2','3','4','5','6','7','8','9','10','11','12'];

const byClass = new Map<string, any[]>();
books.forEach((b: any) => {
  const cls = b.data.class;
  if (!byClass.has(cls)) byClass.set(cls, []);
  byClass.get(cls)!.push(b);
});

const sortedClasses = [...byClass.keys()].sort((a, b) => {
  const ai = CLASS_ORDER.indexOf(a), bi = CLASS_ORDER.indexOf(b);
  if (ai === -1 && bi === -1) return Number(a) - Number(b);
  if (ai === -1) return 1;
  if (bi === -1) return -1;
  return ai - bi;
});
sortedClasses.forEach(cls => {
  byClass.get(cls)!.sort((a: any, b: any) => a.data.subject.localeCompare(b.data.subject));
});

const allBoards = new Set<string>();
books.forEach((b: any) => (b.data.boards || []).forEach((x: string) => allBoards.add(x)));
const boards = [...allBoards].sort();
---
<BaseLayout title="Textbooks — Class 1 to 12 | Punjab & Federal Board | Parhayi" description="Free Pakistani board textbooks for Class 1 to 12. Punjab (PTB) and Federal (FBISE). Download PDFs instantly.">
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">Textbooks</span>
      </nav>
      <div class="max-w-2xl">
        <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">Textbooks</h1>
        <p class="mt-3 text-base leading-relaxed text-slate-600">
          {books.length} textbooks from Punjab (PTB) and Federal (FBISE) boards — Class 1 to Class 12.
        </p>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[1200px] px-5 py-8 sm:px-7 lg:px-10 lg:py-10">
    <PageFilter
      placeholder="Search textbooks — subject, class or board…"
      filters={[
        { label: 'Class', key: 'class', options: sortedClasses },
        { label: 'Board', key: 'board', options: boards },
      ]}
    />

    <div id="book-list" class="space-y-14">
      {sortedClasses.map(cls => {
        const items = byClass.get(cls)!;
        return (
          <section data-class={cls} data-filter-section>
            <div class="mb-6 flex items-end justify-between gap-4">
              <div>
                <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Class {cls}</h2>
                <p class="mt-1 text-xs font-semibold uppercase tracking-wider text-slate-400">
                  {items.length} {items.length === 1 ? 'book' : 'books'}
                </p>
              </div>
            </div>

            <div class="grid grid-cols-2 gap-x-4 gap-y-7 sm:grid-cols-3 sm:gap-x-6 lg:grid-cols-4 xl:grid-cols-5">
              {items.map((b: any) => (
                <a
                  href={url(`/books/${b.id}`)}
                  class="book-card group"
                  data-filterable
                  data-search={`${b.data.title} ${b.data.subject} ${(b.data.boards || []).join(' ')} ${cls}`}
                  data-class={cls}
                  data-board={(b.data.boards || [])[0]}
                >
                  <div class="book-cover">
                    <BookCover
                      subject={b.data.subject}
                      classNumber={b.data.class}
                      board={(b.data.boards || [])[0] || 'Punjab'}
                      publisher={b.data.author || ''}
                    />
                  </div>
                  <div class="book-meta">
                    <div class="book-title">{b.data.subject}</div>
                    <div class="book-sub">{(b.data.boards || [])[0] || 'Punjab'}</div>
                  </div>
                </a>
              ))}
            </div>
          </section>
        );
      })}
    </div>
  </div>

  <style is:global>
    .book-card {
      display: flex;
      flex-direction: column;
      gap: 0.75rem;
      text-decoration: none;
    }
    .book-cover {
      position: relative;
      width: 100%;
      aspect-ratio: 5 / 7;
      border-radius: 8px;
      overflow: hidden;
      background: #ffffff;
      border: 1px solid #e5e9f0;
      transition: border-color .15s ease, transform .2s cubic-bezier(.16,1,.3,1);
    }
    @media (hover: hover) {
      .book-card:hover .book-cover {
        border-color: #1d4ed8;
        transform: translateY(-2px);
      }
    }
    .book-meta {
      padding: 0 0.125rem;
      min-width: 0;
    }
    .book-title {
      font-size: 0.875rem;
      font-weight: 800;
      letter-spacing: -0.015em;
      color: #0b1220;
      line-height: 1.25;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }
    .book-sub {
      margin-top: 0.1875rem;
      font-size: 0.6875rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.04em;
      color: #94a3b8;
    }
  </style>
</BaseLayout>
ASTRO

echo "  ✓ /books — grid with light covers"

# ─────────────────────────────────────────────
#  /books/[slug] detail page — cover on the side
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re

p = pathlib.Path('src/pages/books/[...slug].astro')
if not p.exists():
    print('  · books detail page not found, skipping')
    raise SystemExit(0)

s = p.read_text()

# Add BookCover import
if 'BookCover' not in s:
    s = s.replace(
        "import Icon from '../../components/Icon.astro';",
        "import Icon from '../../components/Icon.astro';\nimport BookCover from '../../components/BookCover.astro';",
        1
    )

# Insert cover above the existing detail-header (or at top of content)
# Find the existing content wrapper div
marker_candidates = [
    '<div class="mx-auto max-w-4xl',
    '<div class="mx-auto max-w-3xl',
]

inserted = False
for marker in marker_candidates:
    idx = s.find(marker)
    if idx == -1:
        continue
    # Find the end of the opening tag (the > that closes it)
    tag_end = s.find('>', idx)
    if tag_end == -1:
        continue

    cover_block = '''

    <!-- Book cover -->
    <div class="mb-8 grid grid-cols-1 gap-8 sm:grid-cols-[200px_1fr] lg:grid-cols-[220px_1fr]">
      <div class="mx-auto w-full max-w-[200px] sm:mx-0 sm:max-w-none">
        <div class="book-cover-detail">
          <BookCover
            subject={book.data.subject}
            classNumber={book.data.class}
            board={(book.data.boards || [])[0] || 'Punjab'}
            publisher={book.data.author || ''}
          />
        </div>
      </div>
      <div class="min-w-0">'''
    s = s[:tag_end + 1] + cover_block + s[tag_end + 1:]
    inserted = True
    break

if inserted:
    # Now we need to close the two extra divs. Find the last </div> before </BaseLayout>
    close_idx = s.rfind('</div>', 0, s.rfind('</BaseLayout>'))
    if close_idx > 0:
        s = s[:close_idx + 6] + '\n      </div>\n    </div>' + s[close_idx + 6:]

    # Add CSS
    if '.book-cover-detail' not in s:
        style = '''
  <style is:global>
    .book-cover-detail {
      width: 100%;
      aspect-ratio: 5 / 7;
      border-radius: 10px;
      overflow: hidden;
      background: #ffffff;
      border: 1px solid #e5e9f0;
    }
  </style>
</BaseLayout>'''
        s = s.replace('</BaseLayout>', style, 1)

    p.write_text(s)
    print('  ✓ /books/[slug] — cover wired')
else:
    print('  · could not find content wrapper in books detail page')
PY

# ─────────────────────────────────────────────
#  Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -6

echo ""
echo "════════════════════════════════════════════════════"
echo "  DONE"
echo "════════════════════════════════════════════════════"
echo ""
echo "  Preview locally:"
echo "    pkill -f 'astro dev' || true"
echo "    npm run dev"
echo ""
echo "  Test:"
echo "    /books                    → grid of 184 covers"
echo "    /books/physics-9-punjab   → detail page with cover"
echo ""
echo "  ── If you don't like it ──"
echo "    bash restore.sh"
echo ""
echo "  ── If you like it ──"
echo "    git add ."
echo "    git commit -m 'Add light-theme book covers'"
echo "    git push"
echo ""
echo "  Design matches Parhayi:"
echo "    · White covers, NOT dark"
echo "    · Single accent color per subject (spine + rules)"
echo "    · Dark ink typography — same as site headings"
echo "    · Class pill uses site's #eff4ff / #1d4ed8"
echo "    · No gradients, no glow, no shadows"
echo "    · Same 1px border color as row cards"
echo "    · Subject color matches the site's icon tiles"
echo "════════════════════════════════════════════════════"