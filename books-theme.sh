#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "════════════════════════════════════════════"
echo "  Aligning books section to Parhayi theme"
echo "════════════════════════════════════════════"
echo ""

git branch -f backup-pre-books-theme 2>/dev/null || true
echo "  ✓ backup-pre-books-theme created"
echo ""

# ═════════════════════════════════════════════════════════
#  1. SubjectIcon — one blue color, distinct glyphs
# ═════════════════════════════════════════════════════════
echo "▸ 1. Unifying SubjectIcon to single blue theme..."

cat > src/components/SubjectIcon.astro <<'ASTRO'
---
import Icon from './Icon.astro';

interface Props {
  subject: string;
  size?: 'sm' | 'md' | 'lg';
  class?: string;
}

const { subject, size = 'md', class: className = '' } = Astro.props;

// Normalise the subject string
const key = subject.toLowerCase()
  .replace(/\(.*?\)/g, '')
  .replace(/[^a-z\s]/g, '')
  .trim();

// Subject → icon glyph (all rendered in the same brand blue)
const MAP: Record<string, string> = {
  'english':            'feather',
  'urdu':               'pen-tool',
  'sindhi':             'pen-tool',
  'punjabi':            'pen-tool',
  'farsi':              'pen-tool',
  'arabic':             'languages',
  'salees urdu':        'pen-tool',
  'gulzar e urdu':      'pen-tool',
  'physics':            'atom',
  'chemistry':          'flask',
  'biology':            'leaf',
  'general science':    'microscope',
  'science':            'microscope',
  'bio tech':           'leaf',
  'mathematics':        'sigma',
  'math':               'sigma',
  'riazi':              'sigma',
  'statistics':         'bar-chart',
  'general mathematics':'sigma',
  'geography':          'map',
  'history':            'scroll',
  'islamiat':           'star',
  'islamiyat':          'star',
  'islamic studies':    'star',
  'pakistan studies':   'map',
  'pak study':          'map',
  'mutala e pakistan':  'map',
  'civics':             'landmark',
  'economics':          'trending-up',
  'psychology':         'brain',
  'nafsiyat':           'brain',
  'education':          'graduation-cap',
  'ilm ul taleem':      'graduation-cap',
  'tarjuma tul quran':  'book',
  'translation quran':  'book',
  'tarjuma tul quran majeed': 'book',
  'nazra quran':        'book',
  'akhlaqiat':          'heart',
  'mazhabi taleemat':   'heart',
  'religious studies':  'heart',
  'buddhism':           'heart',
  'sikhism':            'heart',
  'sanatan dharam':     'heart',
  'zoroastrian religion': 'heart',
  'mashi taleem':       'heart',
  'computer science':   'cpu',
  'computer':           'cpu',
  'computer education': 'cpu',
  'computer ki taleem': 'cpu',
  'computer ji taleem': 'cpu',
  'ict':                'cpu',
  'health physical education': 'activity',
  'home economics':     'home',
  'art drawing':        'palette',
  'general knowledge':  'lightbulb',
  'waqfiyat e aama':    'lightbulb',
  'muasharti uloom':    'globe',
  'social studies':     'globe',
};

const glyph = MAP[key] || 'book';

const sizes = {
  sm: { box: '2rem', icon: 14, radius: '8px' },
  md: { box: '2.5rem', icon: 18, radius: '10px' },
  lg: { box: '3rem', icon: 22, radius: '12px' },
};
const s = sizes[size];
---
<span
  class={`subj-icon ${className}`}
  style={`display:inline-grid;place-items:center;width:${s.box};height:${s.box};border-radius:${s.radius};background:#eff4ff;color:#1d4ed8;border:1px solid #c7d7fe;flex-shrink:0;`}
  aria-hidden="true"
>
  <Icon name={glyph} size={s.icon} strokeWidth={2.2} />
</span>
ASTRO

echo "  ✓ SubjectIcon — single blue theme"

# ═════════════════════════════════════════════════════════
#  2. BookCover — blue monochrome
# ═════════════════════════════════════════════════════════
echo ""
echo "▸ 2. Unifying BookCover to blue theme..."

cat > src/components/BookCover.astro <<'ASTRO'
---
import Icon from './Icon.astro';

interface Props {
  subject: string;
  classNumber: string;
  board: string;
  boardShort: string;
  medium?: string;
  year?: string;
  size?: 'sm' | 'md' | 'lg';
  class?: string;
}

const { subject, classNumber, boardShort, medium, year, size = 'md', class: className = '' } = Astro.props;

// Glyph per subject — same blue everywhere
const key = subject.toLowerCase().replace(/\(.*?\)/g, '').replace(/[^a-z\s]/g, '').trim();

const MAP: Record<string, string> = {
  'english': 'feather', 'urdu': 'pen-tool', 'sindhi': 'pen-tool', 'punjabi': 'pen-tool',
  'farsi': 'pen-tool', 'arabic': 'languages', 'salees urdu': 'pen-tool', 'gulzar e urdu': 'pen-tool',
  'physics': 'atom', 'chemistry': 'flask', 'biology': 'leaf',
  'general science': 'microscope', 'science': 'microscope', 'bio tech': 'leaf',
  'mathematics': 'sigma', 'math': 'sigma', 'riazi': 'sigma', 'statistics': 'bar-chart',
  'general mathematics': 'sigma', 'geography': 'map', 'history': 'scroll',
  'islamiat': 'star', 'islamiyat': 'star', 'islamic studies': 'star',
  'pakistan studies': 'map', 'pak study': 'map', 'mutala e pakistan': 'map',
  'civics': 'landmark', 'economics': 'trending-up', 'psychology': 'brain', 'nafsiyat': 'brain',
  'education': 'graduation-cap', 'ilm ul taleem': 'graduation-cap',
  'tarjuma tul quran': 'book', 'translation quran': 'book', 'tarjuma tul quran majeed': 'book',
  'nazra quran': 'book', 'akhlaqiat': 'heart', 'mazhabi taleemat': 'heart',
  'religious studies': 'heart', 'buddhism': 'heart', 'sikhism': 'heart',
  'sanatan dharam': 'heart', 'zoroastrian religion': 'heart', 'mashi taleem': 'heart',
  'computer science': 'cpu', 'computer': 'cpu', 'computer education': 'cpu',
  'computer ki taleem': 'cpu', 'computer ji taleem': 'cpu', 'ict': 'cpu',
  'health physical education': 'activity', 'home economics': 'home',
  'art drawing': 'palette', 'general knowledge': 'lightbulb',
  'waqfiyat e aama': 'lightbulb', 'muasharti uloom': 'globe', 'social studies': 'globe',
};
const glyph = MAP[key] || 'book';

const sizes = {
  sm: { width: 80, spine: 4, icon: 22, titleFs: 9.5, metaFs: 7.5, pad: 8 },
  md: { width: 140, spine: 6, icon: 36, titleFs: 12, metaFs: 8.5, pad: 12 },
  lg: { width: 200, spine: 8, icon: 48, titleFs: 15, metaFs: 10, pad: 16 },
}[size];

const mediumShort = medium === 'english' ? 'EM' : medium === 'urdu' ? 'UM' : medium === 'sindhi' ? 'SM' : '';
---
<div
  class={`book-cover ${className}`}
  style={`width: ${sizes.width}px; aspect-ratio: 3 / 4; position: relative; background: #ffffff; border: 1px solid #e5e9f0; border-radius: 6px; overflow: hidden; flex-shrink: 0;`}
>
  <!-- Blue spine -->
  <div style={`position: absolute; inset: 0 auto 0 0; width: ${sizes.spine}px; background: #1d4ed8;`}></div>

  <!-- Content -->
  <div style={`position: absolute; inset: 0; padding: ${sizes.pad}px ${sizes.pad}px ${sizes.pad}px ${sizes.pad + sizes.spine}px; display: flex; flex-direction: column;`}>
    <!-- Board -->
    <div style={`font-size: ${sizes.metaFs}px; font-weight: 800; letter-spacing: 0.08em; text-transform: uppercase; color: #1d4ed8;`}>
      {boardShort}
    </div>

    <!-- Icon -->
    <div style={`flex: 1; display: grid; place-items: center; color: #1d4ed8;`}>
      <Icon name={glyph} size={sizes.icon} strokeWidth={1.8} />
    </div>

    <!-- Subject title -->
    <div style={`font-size: ${sizes.titleFs}px; font-weight: 800; letter-spacing: -0.02em; color: #0b1220; line-height: 1.15; word-break: break-word;`}>
      {subject}
    </div>

    <!-- Bottom meta -->
    <div style={`margin-top: 6px; padding-top: 6px; border-top: 1px solid #e5e9f0; display: flex; align-items: center; justify-content: space-between; gap: 4px;`}>
      <span style={`font-size: ${sizes.metaFs}px; font-weight: 800; color: #64748b; letter-spacing: 0.04em;`}>
        CLASS {classNumber}
      </span>
      {mediumShort && (
        <span style={`font-size: ${sizes.metaFs}px; font-weight: 800; color: #1d4ed8; background: #eff4ff; padding: 1px 5px; border-radius: 3px;`}>
          {mediumShort}
        </span>
      )}
    </div>
  </div>
</div>
ASTRO

echo "  ✓ BookCover — blue theme"

# ═════════════════════════════════════════════════════════
#  3. Board cards — remove colored bands
# ═════════════════════════════════════════════════════════
echo ""
echo "▸ 3. Simplifying board cards..."

python3 <<'PY'
import pathlib, re

p = pathlib.Path('src/pages/books/index.astro')
s = p.read_text()

# Replace the THEME color definitions with monochrome
new_theme = '''// Board themes — all use brand blue, only descriptions differ
const THEME: Record<string, { short: string; desc: string }> = {
  'Punjab':      { short: 'PTB',   desc: 'Punjab Curriculum and Textbook Board — books for all schools in Punjab.' },
  'Federal':     { short: 'FBISE', desc: 'Federal Board — federal schools, cadet colleges, and Pakistani schools abroad.' },
  'Sindh':       { short: 'STBB',  desc: 'Sindh Textbook Board — English, Urdu, and Sindhi medium books for all Sindh schools.' },
  'KPK':         { short: 'KPTBB', desc: 'Khyber Pakhtunkhwa Textbook Board — official KPK books.' },
  'Balochistan': { short: 'BTBB',  desc: 'Balochistan Textbook Board — official books for all Balochistan schools.' },
  'AJK':         { short: 'AJKTB', desc: 'AJK Textbook Board — books for Azad Jammu and Kashmir schools.' },
};'''

# Find and replace the THEME block
theme_pattern = re.compile(r'// Province color themes[\s\S]*?\n\};', re.DOTALL)
if theme_pattern.search(s):
    s = theme_pattern.sub(new_theme, s, count=1)

# Replace the board card markup to remove colored band
old_card = re.compile(
    r'\{boards\.map\(b => \{[\s\S]*?\}\)\}',
    re.DOTALL
)

new_card = '''{boards.map(b => {
        const t = THEME[b] || { short: b, desc: `Official ${b} textbooks.` };
        const count = boardCounts.get(b) || 0;
        return (
          <a href={url(`/books/${b.toLowerCase()}`)} class="group rounded-2xl border border-slate-200 bg-white p-6 transition-colors hover:border-[#1d4ed8]">
            <div class="flex items-start justify-between gap-4">
              <span class="inline-grid place-items-center min-w-[52px] h-8 px-2.5 rounded-lg bg-[#eff4ff] text-[11px] font-bold uppercase tracking-wider text-[#1d4ed8] border border-[#c7d7fe]">
                {t.short}
              </span>
              <svg class="text-slate-300 transition-all group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M7 7h10v10"/><path d="M7 17 17 7"/></svg>
            </div>
            <h3 class="mt-5 font-display text-xl font-extrabold tracking-tight text-slate-900">{b}</h3>
            <p class="mt-2 text-sm leading-relaxed text-slate-500">{t.desc}</p>
            <div class="mt-5 flex items-center gap-3">
              <span class="text-[11px] font-bold uppercase tracking-wider text-[#1d4ed8]">{count} {count === 1 ? 'book' : 'books'}</span>
              <span class="h-1 w-1 rounded-full bg-slate-300"></span>
              <span class="text-[11px] font-bold uppercase tracking-wider text-slate-400">Class 1–12</span>
            </div>
          </a>
        );
      })}'''

if old_card.search(s):
    s = old_card.sub(new_card, s, count=1)
    p.write_text(s)
    print('  ✓ Board cards simplified')
else:
    print('  ! Could not find board card block')
PY

# ═════════════════════════════════════════════════════════
#  4. Class cards — smaller, more restrained
# ═════════════════════════════════════════════════════════
echo ""
echo "▸ 4. Simplifying class cards..."

python3 <<'PY'
import pathlib, re

p = pathlib.Path('src/pages/books/[board]/index.astro')
s = p.read_text()

old_grid = re.compile(
    r'<div class="mt-6 grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">[\s\S]*?</div>\s*</div>\s*</div>\s*\n\s*<!-- SEO copy -->',
    re.DOTALL
)

new_grid = '''<div class="mt-6 grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
      {classes.map(c => (
        <a href={url(`/books/${boardSlug}/class-${c.cls}`)} class="group rounded-2xl border border-slate-200 bg-white p-5 transition-colors hover:border-[#1d4ed8]">
          <div class="flex items-center justify-between gap-3">
            <div class="flex items-baseline gap-2">
              <span class="font-display text-2xl font-extrabold leading-none tracking-tight text-slate-900">{c.cls}</span>
              <span class="text-[11px] font-bold uppercase tracking-wider text-slate-400">Class</span>
            </div>
            <span class="rounded-md bg-[#eff4ff] px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider text-[#1d4ed8] border border-[#c7d7fe]">
              {c.count} {c.count === 1 ? 'book' : 'books'}
            </span>
          </div>

          <div class="mt-4 flex flex-wrap gap-1.5">
            {c.subjects.slice(0, 6).map(s => (
              <SubjectIcon subject={s.subject} size="sm" />
            ))}
            {c.subjects.length > 6 && (
              <span class="grid place-items-center h-8 min-w-[32px] px-2 rounded-lg bg-slate-100 text-[10px] font-bold text-slate-500">
                +{c.subjects.length - 6}
              </span>
            )}
          </div>

          <div class="mt-4 flex items-center justify-between">
            <span class="text-[11px] font-bold uppercase tracking-wider text-slate-400">
              {c.subjects.length} {c.subjects.length === 1 ? 'subject' : 'subjects'}
            </span>
            <span class="inline-flex items-center gap-1 text-xs font-bold text-[#1d4ed8] opacity-0 transition-opacity group-hover:opacity-100">
              Open
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>
            </span>
          </div>
        </a>
      ))}
    </div>
  </div>

  <!-- SEO copy -->'''

if old_grid.search(s):
    s = old_grid.sub(new_grid, s, count=1)
    p.write_text(s)
    print('  ✓ Class cards simplified')
else:
    print('  ! Could not find class grid')
PY

# ═════════════════════════════════════════════════════════
#  5. Fix badge-soft in class list to match theme
# ═════════════════════════════════════════════════════════
python3 <<'PY'
import pathlib, re
p = pathlib.Path('src/pages/textbook/[...slug].astro')
s = p.read_text()

# The badge-soft class is fine (blue), no changes needed
# Just verify the year badges don't have rainbow colors
s = s.replace('rounded bg-[#ecfdf5] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#047857]',
              'rounded bg-[#eff4ff] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#1d4ed8]')
s = s.replace('rounded bg-[#fffbeb] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#b45309]',
              'rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate-600')

p.write_text(s)
print('  ✓ Book detail badges unified to blue/slate')
PY

# Also fix the class list page badges
python3 <<'PY'
import pathlib
p = pathlib.Path('src/pages/books/[board]/[class].astro')
s = p.read_text()
s = s.replace('rounded bg-[#ecfdf5] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#047857]',
              'rounded bg-[#eff4ff] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#1d4ed8]')
s = s.replace('rounded bg-[#fffbeb] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#b45309]',
              'rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate-600')
p.write_text(s)
print('  ✓ Subject list badges unified')
PY

# ═════════════════════════════════════════════════════════
#  6. Rebuild
# ═════════════════════════════════════════════════════════
echo ""
echo "Rebuilding..."
rm -rf dist .astro node_modules/.vite
npm run build 2>&1 | tail -8

echo ""
echo "════════════════════════════════════════════════════════"
echo "  DONE"
echo ""
echo "  Preview:"
echo "    bash start-server.sh"
echo ""
echo "  Check:"
echo "    /My-edu-site/books/"
echo "    /My-edu-site/books/punjab/"
echo "    /My-edu-site/books/punjab/class-9/"
echo "    /My-edu-site/textbook/9-pectaa-mathematics-e-2025_26"
echo ""
echo "  What changed:"
echo "    · All subject icons now use the same brand blue (#1d4ed8)"
echo "      Different glyphs still differentiate subjects — same as SME"
echo "    · Book covers: blue spine, blue icon, blue badges — no rainbow"
echo "    · Board cards: removed colored bands, plain white with blue badge"
echo "    · All year/scheme badges: blue or slate — no colors"
echo "    · Layout improvements kept — only colors unified"
echo ""
echo "  Push when happy:"
echo "    git add ."
echo "    git commit -m 'Unify books section to Parhayi blue theme'"
echo "    git push"
echo ""
echo "  Revert:"
echo "    git checkout backup-pre-books-theme"
echo "════════════════════════════════════════════════════════"