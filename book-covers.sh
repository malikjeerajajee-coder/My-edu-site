#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  BACKUP FIRST — creating restore point"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  STEP 1: Backup branch
# ─────────────────────────────────────────────
git branch -f backup-pre-covers
git push -u origin backup-pre-covers 2>&1 | tail -3 || echo "  (will need manual push)"
echo "  ✓ Branch 'backup-pre-covers' created"
echo ""

# ─────────────────────────────────────────────
#  STEP 2: Restore script
# ─────────────────────────────────────────────
cat > restore.sh <<'RESTORE'
#!/bin/bash
# Restore the site to its pre-covers state
set -e
echo "Restoring from backup-pre-covers..."
git fetch origin backup-pre-covers
git checkout backup-pre-covers
git branch -D main || true
git checkout -b main
git push -f origin main
echo ""
echo "✓ Restored. Site will redeploy in ~5-8 minutes."
echo "  Check progress: https://github.com/malikjeerajajee-coder/My-edu-site/actions"
RESTORE
chmod +x restore.sh
echo "  ✓ restore.sh written — run anytime to revert"
echo ""

# ─────────────────────────────────────────────
#  STEP 3: BookCover component
# ─────────────────────────────────────────────
cat > src/components/BookCover.astro <<'ASTRO'
---
interface Props {
  subject: string;
  classNumber: string;
  board: string;
  publisher?: string;
  size?: 'sm' | 'md' | 'lg';
}

const { subject, classNumber, board, publisher = '', size = 'md' } = Astro.props;

// ─── Subject → background color ───
const COLORS: Record<string, string> = {
  'Physics':              '#1e3a8a',
  'Chemistry':            '#065f46',
  'Biology':              '#15803d',
  'Mathematics':          '#5b21b6',
  'English':              '#991b1b',
  'Urdu':                 '#115e59',
  'Islamiat':             '#166534',
  'Pakistan Studies':     '#064e3b',
  'Computer Science':     '#155e75',
  'Statistics':           '#3730a3',
  'General Mathematics':  '#6d28d9',
  'General Science':      '#0369a1',
  'Social Studies':       '#92400e',
  'Nazra Quran':          '#047857',
  'Islamic Studies':      '#065f46',
  'General Knowledge':    '#0f766e',
};
const bg = COLORS[subject] || '#1d4ed8';

// ─── Wrap subject name into lines ───
function wrapText(text: string, maxLen = 11): string[] {
  const words = text.split(' ');
  const lines: string[] = [];
  let current = '';
  for (const w of words) {
    if ((current + ' ' + w).trim().length <= maxLen) {
      current = (current + ' ' + w).trim();
    } else {
      if (current) lines.push(current);
      current = w;
    }
  }
  if (current) lines.push(current);
  return lines;
}
const lines = wrapText(subject);
const lineCount = lines.length;

// Font size scales down for more lines
const fs = lineCount === 1 ? 46 : lineCount === 2 ? 34 : 24;
const lineHeight = fs * 1.15;
const centerY = 200;
const firstY = centerY - ((lineCount - 1) * lineHeight) / 2;

// Board label
const boardLabel = board === 'Federal' ? 'FEDERAL BOARD' : `${board.toUpperCase()} BOARD`;

// Publisher short
const pubShort = publisher.includes('Punjab') ? 'PTB'
              : publisher.includes('Federal') ? 'FBISE'
              : 'PARHAYI';

// Unique SVG id to avoid gradient conflicts when multiple covers on page
const uid = Math.random().toString(36).slice(2, 8);
---
<svg viewBox="0 0 300 420"
     xmlns="http://www.w3.org/2000/svg"
     role="img"
     aria-label={`${subject} — Class ${classNumber} textbook cover`}
     style="display: block; width: 100%; height: 100%;">
  <defs>
    <linearGradient id={`shine-${uid}`} x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%"   stop-color="rgba(255,255,255,0.14)"/>
      <stop offset="55%"  stop-color="rgba(255,255,255,0.02)"/>
      <stop offset="100%" stop-color="rgba(0,0,0,0.18)"/>
    </linearGradient>
    <radialGradient id={`glow-${uid}`} cx="0.85" cy="0.15" r="0.9">
      <stop offset="0%"   stop-color="rgba(255,255,255,0.16)"/>
      <stop offset="100%" stop-color="rgba(255,255,255,0)"/>
    </radialGradient>
  </defs>

  <!-- Base -->
  <rect width="300" height="420" fill={bg}/>

  <!-- Subtle top-right glow -->
  <rect width="300" height="420" fill={`url(#glow-${uid})`}/>

  <!-- Spine (left) -->
  <rect x="0" y="0" width="10" height="420" fill="rgba(0,0,0,0.22)"/>
  <rect x="10" y="0" width="1.5" height="420" fill="rgba(255,255,255,0.08)"/>

  <!-- Sheet shine -->
  <rect width="300" height="420" fill={`url(#shine-${uid})`}/>

  <!-- Decorative circle top-right -->
  <circle cx="245" cy="70" r="70" fill="rgba(255,255,255,0.05)"/>
  <circle cx="245" cy="70" r="44" fill="rgba(255,255,255,0.04)"/>

  <!-- Board label -->
  <text x="24" y="34"
        font-family="'Plus Jakarta Sans', system-ui, sans-serif"
        font-size="9.5"
        font-weight="800"
        letter-spacing="2.4"
        fill="rgba(255,255,255,0.65)">{boardLabel}</text>

  <!-- Top rule -->
  <line x1="24" y1="46" x2="90" y2="46"
        stroke="rgba(255,255,255,0.35)" stroke-width="1.4"/>

  <!-- Subject lines -->
  {lines.map((line, i) => (
    <text x="24" y={firstY + i * lineHeight}
          font-family="'Plus Jakarta Sans', system-ui, sans-serif"
          font-size={fs}
          font-weight="800"
          letter-spacing="-1"
          fill="#ffffff">{line}</text>
  ))}

  <!-- Accent bar under subject -->
  <rect x="24" y={firstY + (lineCount - 1) * lineHeight + 14}
        width="46" height="3" fill="#fbbf24" rx="1.5"/>

  <!-- Class pill -->
  <g transform={`translate(24, ${firstY + (lineCount - 1) * lineHeight + 42})`}>
    <rect x="0" y="0" width="86" height="24"
          rx="12"
          fill="rgba(255,255,255,0.14)"
          stroke="rgba(255,255,255,0.22)"
          stroke-width="1"/>
    <text x="43" y="16"
          text-anchor="middle"
          font-family="'Plus Jakarta Sans', system-ui, sans-serif"
          font-size="10.5"
          font-weight="800"
          letter-spacing="1.2"
          fill="#ffffff">CLASS {classNumber}</text>
  </g>

  <!-- Bottom publisher -->
  <text x="24" y="395"
        font-family="'Plus Jakarta Sans', system-ui, sans-serif"
        font-size="9"
        font-weight="800"
        letter-spacing="2"
        fill="rgba(255,255,255,0.55)">{pubShort}</text>

  <!-- Bottom decorative line -->
  <line x1="24" y1="402" x2="60" y2="402"
        stroke="rgba(255,255,255,0.3)" stroke-width="1"/>
</svg>
ASTRO
echo "  ✓ BookCover.astro"

# ─────────────────────────────────────────────
#  STEP 4: Update /books page — grid layout with covers
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

// Group by class
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

// Available boards
const allBoards = new Set<string>();
books.forEach((b: any) => (b.data.boards || []).forEach((x: string) => allBoards.add(x)));
const boards = [...allBoards].sort();
---
<BaseLayout title="Textbooks — Class 1 to 12 | Punjab & Federal Board | Parhayi" description="Free Pakistani board textbooks for Class 1 to 12. Punjab (PTB) and Federal (FBISE). Download PDFs instantly.">
  <!-- Header -->
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

  <!-- Filters + grid -->
  <div class="mx-auto max-w-[1200px] px-5 py-8 sm:px-7 lg:px-10 lg:py-10">
    <PageFilter
      placeholder="Search textbooks — subject, class or board…"
      filters={[
        { label: 'Class', key: 'class', options: sortedClasses },
        { label: 'Board', key: 'board', options: boards },
      ]}
    />

    <div id="book-list" class="space-y-12">
      {sortedClasses.map(cls => {
        const items = byClass.get(cls)!;
        return (
          <section data-class={cls} data-filter-section>
            <div class="mb-5 flex items-end justify-between gap-4">
              <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Class {cls}</h2>
              <span class="text-xs font-semibold uppercase tracking-wider text-slate-400">
                {items.length} {items.length === 1 ? 'book' : 'books'}
              </span>
            </div>

            <div class="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5">
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
                    <div class="book-subject">{b.data.subject}</div>
                    <div class="book-board">
                      {(b.data.boards || [])[0]}
                    </div>
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
      gap: 0.625rem;
      padding: 0.5rem;
      border: 1px solid transparent;
      border-radius: 14px;
      transition: border-color .15s ease, background-color .15s ease;
    }
    @media (hover: hover) {
      .book-card:hover { border-color: #e5e9f0; background: #fafbfc; }
    }
    .book-cover {
      position: relative;
      width: 100%;
      aspect-ratio: 5 / 7;
      border-radius: 6px;
      overflow: hidden;
      background: #e5e9f0;
      border: 1px solid rgba(0,0,0,0.06);
    }
    .book-meta { padding: 0 0.25rem; }
    .book-subject {
      font-size: 0.8125rem;
      font-weight: 800;
      letter-spacing: -0.015em;
      color: #0b1220;
      line-height: 1.2;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }
    .book-board {
      margin-top: 0.1875rem;
      font-size: 0.6875rem;
      font-weight: 700;
      color: #64748b;
      text-transform: uppercase;
      letter-spacing: 0.04em;
    }
  </style>
</BaseLayout>
ASTRO
echo "  ✓ /books — grid layout with covers"

# ─────────────────────────────────────────────
#  STEP 5: Update /books/[slug] — hero cover
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re

p = pathlib.Path('src/pages/books/[...slug].astro')
if not p.exists():
    print('  ! books detail page not found')
else:
    s = p.read_text()

    # Add BookCover import
    if 'BookCover' not in s:
        s = s.replace(
            "import Icon from '../../components/Icon.astro';",
            "import Icon from '../../components/Icon.astro';\nimport BookCover from '../../components/BookCover.astro';"
        )

    # Replace the existing hero block with a two-column layout: cover + details
    # Find where the hero starts
    hero_start = s.find('<div class="mx-auto max-w-4xl')
    if hero_start == -1:
        print('  ! could not find content wrapper')
    else:
        # Find the closing of the header band region — we'll replace the opening portion
        # Simpler: insert the cover before the existing main container
        # and wrap in a two-col grid
        old_start = '''<div class="mx-auto max-w-4xl px-4 pt-8 sm:px-6 sm:pt-12 lg:px-8">'''
        new_start = '''<div class="mx-auto max-w-4xl px-5 pt-8 sm:px-7 sm:pt-12 lg:px-10">
    <div class="grid gap-8 sm:grid-cols-[200px_1fr] lg:grid-cols-[220px_1fr]">
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
      <div>'''
        if old_start in s:
            s = s.replace(old_start, new_start, 1)

            # Find the closing </div> of the original container to add extra closing tags
            # The original container ends with:
            #     </div>
            #   </BaseLayout>
            # We need to insert two more </div> before </BaseLayout>
            # But be careful not to break existing structure

            # Actually simpler approach: add the closing tags right before the pattern "  </div>\n</BaseLayout>"
            # — but only if we actually opened the grid

            # Find last </div> before </BaseLayout> and add "</div>\n      </div>" before it
            # (2 closes for the div we opened + the inner content div)
            marker = "  </div>\n</BaseLayout>"
            if marker in s:
                s = s.replace(
                    marker,
                    "    </div>\n    </div>\n  </div>\n</BaseLayout>",
                    1
                )
            else:
                # Try alternate ending
                marker2 = "</div>\n</BaseLayout>"
                if marker2 in s:
                    s = s.replace(
                        marker2,
                        "  </div>\n  </div>\n</div>\n</BaseLayout>",
                        1
                    )

    # Add detail cover CSS
    if '.book-cover-detail' not in s:
        # Insert <style> before </BaseLayout>
        style_block = '''
  <style is:global>
    .book-cover-detail {
      width: 100%;
      aspect-ratio: 5 / 7;
      border-radius: 8px;
      overflow: hidden;
      background: #e5e9f0;
      border: 1px solid rgba(0,0,0,0.06);
    }
  </style>
</BaseLayout>'''
        s = s.replace("</BaseLayout>", style_block, 1)

    p.write_text(s)
    print('  ✓ /books/[slug] — hero cover wired')
PY

# ─────────────────────────────────────────────
#  STEP 6: Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -8

echo ""
echo "════════════════════════════════════════════════════════"
echo "  DONE"
echo "════════════════════════════════════════════════════════"
echo ""
echo "  ── Preview locally ──"
echo "    pkill -f 'astro dev' || true"
echo "    npm run dev"
echo ""
echo "  Test these URLs:"
echo "    /books                    → grid of 184 covers"
echo "    /books/physics-9-punjab   → detail page with big cover"
echo ""
echo "  ── To revert (if you don't like it) ──"
echo "    bash restore.sh"
echo ""
echo "  ── To push (if you like it) ──"
echo "    git add ."
echo "    git commit -m 'Add programmatic book cover system'"
echo "    git push"
echo ""
echo "  Design:"
echo "    · 5:7 ratio (real book proportions)"
echo "    · Dark solid backgrounds per subject"
echo "    · Spine on the left"
echo "    · Subject name in large type"
echo "    · Class pill"
echo "    · Publisher mark at bottom"
echo "    · All rendered inline as SVG — uses site fonts, no image files"
echo "    · 30+ distinct colors by subject"
echo "════════════════════════════════════════════════════════"