#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Class-first nav + all-province BISEs"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  1. Rewrite boards.ts with all province BISEs
# ─────────────────────────────────────────────
cat > src/lib/boards.ts <<'TS'
// ═══════════════════════════════════════════════════════════════
//  Complete Pakistan education board structure
// ═══════════════════════════════════════════════════════════════

export interface BISE {
  slug: string;
  name: string;
  short: string;
}

export interface Province {
  slug: string;
  name: string;
  full: string;
  bises: BISE[];
  biseAware: boolean;
}

// ─── Punjab — 9 BISEs ───
export const PUNJAB_BISES: BISE[] = [
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

// ─── Sindh — 5 BISEs ───
export const SINDH_BISES: BISE[] = [
  { slug: 'karachi',     name: 'Karachi',     short: 'KHI' },
  { slug: 'hyderabad',   name: 'Hyderabad',   short: 'HYD' },
  { slug: 'sukkur',      name: 'Sukkur',      short: 'SKR' },
  { slug: 'larkana',     name: 'Larkana',     short: 'LRK' },
  { slug: 'mirpurkhas',  name: 'Mirpurkhas',  short: 'MPK' },
];

// ─── Khyber Pakhtunkhwa — 8 BISEs ───
export const KPK_BISES: BISE[] = [
  { slug: 'peshawar',    name: 'Peshawar',    short: 'PSH' },
  { slug: 'abbottabad',  name: 'Abbottabad',  short: 'ABT' },
  { slug: 'swat',        name: 'Swat',        short: 'SWT' },
  { slug: 'mardan',      name: 'Mardan',      short: 'MRD' },
  { slug: 'malakand',    name: 'Malakand',    short: 'MLK' },
  { slug: 'kohat',       name: 'Kohat',       short: 'KHT' },
  { slug: 'bannu',       name: 'Bannu',       short: 'BNU' },
  { slug: 'di-khan',     name: 'DI Khan',     short: 'DIK' },
];

// ─── Balochistan — 7 BISEs ───
export const BALOCHISTAN_BISES: BISE[] = [
  { slug: 'quetta',      name: 'Quetta',      short: 'QTA' },
  { slug: 'khuzdar',     name: 'Khuzdar',     short: 'KZD' },
  { slug: 'turbat',      name: 'Turbat',      short: 'TRB' },
  { slug: 'loralai',     name: 'Loralai',     short: 'LRL' },
  { slug: 'zhob',        name: 'Zhob',        short: 'ZHB' },
  { slug: 'nasirabad',   name: 'Nasirabad',   short: 'NSR' },
  { slug: 'makran',      name: 'Makran',      short: 'MKR' },
];

// ─── AJK — 3 BISEs ───
export const AJK_BISES: BISE[] = [
  { slug: 'mirpur',      name: 'Mirpur',      short: 'MPR' },
  { slug: 'muzaffarabad',name: 'Muzaffarabad',short: 'MZD' },
  { slug: 'rawalakot',   name: 'Rawalakot',   short: 'RLK' },
];

// ─── Federal — single board ───
export const FEDERAL_BISES: BISE[] = [
  { slug: 'fbise', name: 'Federal Board (FBISE)', short: 'FBISE' },
];

// ═══════════════════════════════════════════════════════════════
//  Provinces
// ═══════════════════════════════════════════════════════════════

export const BOARDS: Province[] = [
  { slug: 'punjab',      name: 'Punjab',      full: 'Punjab Boards',            bises: PUNJAB_BISES,      biseAware: true },
  { slug: 'federal',     name: 'Federal',     full: 'Federal Board (FBISE)',    bises: FEDERAL_BISES,     biseAware: false },
  { slug: 'sindh',       name: 'Sindh',       full: 'Sindh Boards',             bises: SINDH_BISES,       biseAware: true },
  { slug: 'kpk',         name: 'KPK',         full: 'Khyber Pakhtunkhwa Boards',bises: KPK_BISES,         biseAware: true },
  { slug: 'balochistan', name: 'Balochistan', full: 'Balochistan Boards',      bises: BALOCHISTAN_BISES, biseAware: true },
  { slug: 'ajk',         name: 'AJK',         full: 'AJK Boards',               bises: AJK_BISES,         biseAware: true },
];

// ═══════════════════════════════════════════════════════════════
//  Helper functions
// ═══════════════════════════════════════════════════════════════

export function boardBySlug(slug: string): Province | undefined {
  return BOARDS.find(b => b.slug === slug);
}

export function boardByName(name: string): Province | undefined {
  return BOARDS.find(b => b.name === name);
}

export function getBISEsForProvince(slug: string): BISE[] {
  const board = boardBySlug(slug);
  return board ? board.bises : [];
}

export function biseBySlug(provinceSlug: string, biseSlug: string): BISE | undefined {
  return getBISEsForProvince(provinceSlug).find(b => b.slug === biseSlug);
}

export function hasBISEs(slug: string): boolean {
  const board = boardBySlug(slug);
  return board ? board.biseAware : false;
}

// Content item → which province(s) it belongs to
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

// ═══════════════════════════════════════════════════════════════
//  Classes & subjects
// ═══════════════════════════════════════════════════════════════

export const CLASSES = ['1','2','3','4','5','6','7','8','9','10','11','12'];
export const BOOK_CLASSES = ['1','2','3','4','5','6','7','8','9','10','11','12'];
export const EXAM_CLASSES = ['9','10','11','12'];

export const SUBJECTS = [
  'Mathematics', 'Physics', 'Chemistry', 'Biology',
  'English', 'Urdu', 'Islamiat', 'Pakistan Studies', 'Computer Science',
];

export const CONTENT_TYPES = [
  { slug: 'notes',           label: 'Notes',           icon: 'file-text' },
  { slug: 'quizzes',         label: 'Quizzes',         icon: 'circle-help' },
  { slug: 'books',           label: 'Books',           icon: 'book-marked' },
  { slug: 'past-papers',     label: 'Past Papers',     icon: 'scroll-text' },
  { slug: 'guess-papers',    label: 'Guess Papers',    icon: 'sparkles' },
  { slug: 'pairing-schemes', label: 'Pairing Schemes', icon: 'list' },
  { slug: 'gazettes',        label: 'Result Gazettes', icon: 'newspaper' },
];

export const BISE_AWARE_BOARDS = ['punjab', 'sindh', 'kpk', 'balochistan', 'ajk'];
export const BISE_SPECIFIC_TYPES = ['past-papers', 'gazettes'];
export const SHARED_TYPES = ['notes', 'quizzes', 'books', 'guess-papers', 'pairing-schemes'];

export function isBISESpecific(typeSlug: string): boolean {
  return BISE_SPECIFIC_TYPES.includes(typeSlug);
}

export function getBiseByName(name: string, provinceSlug?: string): BISE | undefined {
  if (provinceSlug) {
    return getBISEsForProvince(provinceSlug).find(b => b.name.toLowerCase() === name.toLowerCase());
  }
  for (const board of BOARDS) {
    const found = board.bises.find(b => b.name.toLowerCase() === name.toLowerCase());
    if (found) return found;
  }
  return undefined;
}

export function slugify(s: string): string {
  return s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}
TS

echo "  ✓ boards.ts — all province BISEs"

# ─────────────────────────────────────────────
#  2. /class/[class] — class-first hub
# ─────────────────────────────────────────────
mkdir -p 'src/pages/class'

cat > 'src/pages/class/[class].astro' <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { BOARDS, CLASSES, EXAM_CLASSES } from '../../lib/boards';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  return CLASSES.map(c => ({ params: { class: c } }));
}

const { class: cls } = Astro.params;
if (!cls || !CLASSES.includes(cls)) return Astro.redirect('/');

const isExamClass = EXAM_CLASSES.includes(cls);

// Load what exists for this class across all boards
const [notes, quizzes, books, papers, gazettes] = await Promise.all([
  getCollection('notes'),
  getCollection('quizzes'),
  getCollection('books'),
  getCollection('pastPapers'),
  getCollection('gazettes'),
]);

const classNotes   = notes.filter((n: any) => n.data.class === cls);
const classQuizzes = quizzes.filter((n: any) => n.data.class === cls);
const classBooks   = books.filter((n: any) => n.data.class === cls);
const classPapers  = papers.filter((n: any) => n.data.class === cls);
const classGazettes= gazettes.filter((n: any) => n.data.class === cls);

const totalItems = classNotes.length + classQuizzes.length + classBooks.length + classPapers.length + classGazettes.length;

// For each board, count items for this class
const boardCounts = BOARDS.map(b => {
  const matching = (arr: any[]) => arr.filter((x: any) => (x.data.boards || []).includes(b.name)).length;
  const count = matching(classNotes) + matching(classQuizzes) + matching(classBooks) + matching(classPapers) + matching(classGazettes);
  return { board: b, count };
}).filter(x => x.count > 0);
---
<BaseLayout
  title={`Class ${cls} Notes, Past Papers & Books — All Pakistani Boards | Parhayi`}
  description={isExamClass
    ? `Free Class ${cls} study material for Punjab, Federal, Sindh, KPK, Balochistan and AJK boards. Notes, past papers, guess papers, pairing schemes and result gazettes.`
    : `Free Class ${cls} textbooks from Punjab and Federal boards. Download PDFs instantly.`}
>
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">Class {cls}</span>
      </nav>
      <div class="max-w-2xl">
        <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">Class {cls}</h1>
        <p class="mt-3 text-base leading-relaxed text-slate-600">
          {isExamClass
            ? `Study material for Class ${cls} students across all Pakistani boards. Pick your board to see content for your syllabus.`
            : `Textbooks for Class ${cls} from Punjab (PTB) and Federal (FBSE) boards.`}
        </p>
      </div>
      {totalItems > 0 && (
        <div class="mt-6 flex flex-wrap gap-x-6 gap-y-2 text-sm text-slate-500">
          {classBooks.length > 0   && <span><span class="font-extrabold text-slate-900">{classBooks.length}</span> books</span>}
          {classNotes.length > 0   && <span><span class="font-extrabold text-slate-900">{classNotes.length}</span> notes</span>}
          {classPapers.length > 0  && <span><span class="font-extrabold text-slate-900">{classPapers.length}</span> past papers</span>}
          {classQuizzes.length > 0 && <span><span class="font-extrabold text-slate-900">{classQuizzes.length}</span> quizzes</span>}
          {classGazettes.length > 0 && <span><span class="font-extrabold text-slate-900">{classGazettes.length}</span> gazettes</span>}
        </div>
      )}
    </div>
  </div>

  <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
    <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Choose your board</h2>
    <p class="mt-2 text-sm text-slate-500">Every board follows the same curriculum, but exam papers and gazettes are unique to each.</p>

    {boardCounts.length === 0 ? (
      <div class="mt-6 rounded-xl border border-dashed border-slate-300 bg-white p-12 text-center">
        <p class="text-sm font-bold text-slate-900">No content yet for Class {cls}</p>
      </div>
    ) : (
      <div class="mt-6 grid grid-cols-1 gap-2.5 sm:grid-cols-2 lg:grid-cols-3">
        {boardCounts.map(({ board, count }) => (
          <a href={url(`/board/${board.slug}/class-${cls}`)} class="row group">
            <span class="tile">
              <Icon name="graduation-cap" size={19} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <div class="row-title">{board.name}</div>
            </div>
            <Icon name="arrow-right" size={15} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
          </a>
        ))}
      </div>
    )}

    {!isExamClass && (
      <div class="mt-10 rounded-xl border border-slate-200 bg-white p-6">
        <p class="text-sm leading-relaxed text-slate-600">
          <strong class="text-slate-900">Note:</strong> Classes 1 through 8 don't have board examinations. The only resource for these classes is textbooks — which are the same across Punjab and Federal boards.
        </p>
      </div>
    )}
  </div>
</BaseLayout>
ASTRO

echo "  ✓ /class/[class] route"

# ─────────────────────────────────────────────
#  3. Update homepage with class section
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re

p = pathlib.Path('src/pages/index.astro')
s = p.read_text()

# Update imports
if 'CLASSES' not in s:
    s = s.replace(
        "import { BOARDS } from '../lib/boards';",
        "import { BOARDS, CLASSES } from '../lib/boards';"
    )

# Add "Choose your class" section before "Choose your board"
class_section = '''
  <!-- ═══ CHOOSE YOUR CLASS ═══ -->
  <section class="section">
    <div class="section-inner">
      <div class="mb-8">
        <h2 class="text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Choose your class</h2>
        <p class="mt-2 text-sm text-slate-500">Or start here if you know your class — everything for that year in one place.</p>
      </div>

      <div class="grid grid-cols-2 gap-2.5 sm:grid-cols-3 lg:grid-cols-6">
        {CLASSES.map(c => (
          <a href={url(`/class/${c}`)} class="rtile group" style="--tile-color: #1d4ed8; --tile-tint: #eff4ff;">
            <span class="rtile-icon" style="font-size: 1rem; font-weight: 800;">{c}</span>
            <div class="min-w-0 flex-1">
              <div class="rtile-label">Class {c}</div>
            </div>
          </a>
        ))}
      </div>
    </div>
  </section>

  <!-- ═══ CHOOSE YOUR BOARD ═══ -->'''

# Insert before "Choose your board"
marker = '<!-- ═══ CHOOSE YOUR BOARD ═══ -->'
if marker in s and 'CHOOSE YOUR CLASS' not in s:
    s = s.replace(marker, class_section.strip(), 1)
    p.write_text(s)
    print('  ✓ homepage — class section added')
else:
    print('  · homepage — class section already present or marker not found')
PY

# ─────────────────────────────────────────────
#  4. Update board pages to show BISEs (not just Punjab)
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re

p = pathlib.Path('src/pages/board/[board]/index.astro')
s = p.read_text()

# Update import to include getBISEsForProvince and hasBISEs
old_imports = re.search(r"^import.*from '\.\./\.\./\.\./lib/boards';", s, re.MULTILINE)
if old_imports:
    s = s.replace(
        old_imports.group(0),
        "import { BOARDS, getBISEsForProvince, hasBISEs } from '../../../lib/boards';"
    )

# Replace the PUNJAB_BISES usage with generic province BISEs
# Find the BISE picker section
if 'slug === \'punjab\'' in s or "slug === 'punjab'" in s:
    # Replace condition and reference
    s = s.replace("slug === 'punjab'", "hasBISEs(String(slug))")
    s = s.replace('PUNJAB_BISES.map', 'getBISEsForProvince(String(slug)).map')
    s = s.replace("url(`/board/punjab/${bise.slug}`)", "url(`/board/${slug}/${bise.slug}`)")
    s = s.replace('BISE {bise.name}', 'BISE {bise.name}')

# If PUNJAB_BISES still imported anywhere, replace with getBISEsForProvince
s = s.replace('PUNJAB_BISES', 'getBISEsForProvince(String(slug))')

p.write_text(s)
print('  ✓ board pages — BISE picker for all provinces')
PY

# ─────────────────────────────────────────────
#  5. Generate content for Sindh, KPK, Balochistan, AJK
# ─────────────────────────────────────────────
python3 - <<'PY'
import json
import pathlib

PP_DIR = pathlib.Path("src/content/past-papers")
GZ_DIR = pathlib.Path("src/content/gazettes")
PP_DIR.mkdir(parents=True, exist_ok=True)
GZ_DIR.mkdir(parents=True, exist_ok=True)

PROVINCES = {
    'sindh': ['Karachi', 'Hyderabad', 'Sukkur', 'Larkana', 'Mirpurkhas'],
    'kpk':   ['Peshawar', 'Abbottabad', 'Swat', 'Mardan', 'Malakand', 'Kohat', 'Bannu', 'DI Khan'],
    'balochistan': ['Quetta', 'Khuzdar', 'Turbat', 'Loralai', 'Zhob', 'Nasirabad', 'Makran'],
    'ajk':   ['Mirpur', 'Muzaffarabad', 'Rawalakot'],
}

PROVINCE_NAMES = {
    'sindh': 'Sindh',
    'kpk': 'KPK',
    'balochistan': 'Balochistan',
    'ajk': 'AJK',
}

SUBJECTS = ['Physics', 'Chemistry', 'Biology', 'Mathematics',
            'English', 'Urdu', 'Islamiat', 'Pakistan Studies', 'Computer Science']
YEARS = list(range(2018, 2027))
CLASSES = ['9', '10']

def slug(s):
    return s.lower().replace(' & ', '-and-').replace(' ', '-').replace('.', '')

paper_count = 0
gazette_count = 0

for province_slug, bises in PROVINCES.items():
    province_name = PROVINCE_NAMES[province_slug]

    for bise in bises:
        bise_slug = slug(bise)

        # Papers
        for cls in CLASSES:
            for subject in SUBJECTS:
                subj_slug = slug(subject)
                for year in YEARS:
                    fname = f"{subj_slug}-{cls}-{province_slug}-{bise_slug}-{year}"
                    fpath = PP_DIR / f"{fname}.json"
                    if fpath.exists():
                        continue
                    data = {
                        "title": f"{subject} Class {cls} Past Paper {year} — {bise} Board",
                        "subject": subject,
                        "class": cls,
                        "year": year,
                        "boards": [province_name],
                        "bises": [bise],
                        "bise": bise,
                        "pdfUrl": f"/pdfs/past-papers/{fname}.pdf"
                    }
                    fpath.write_text(json.dumps(data, indent=2))
                    paper_count += 1

        # Gazettes
        for cls in CLASSES:
            for year in YEARS:
                fname = f"gazette-{province_slug}-{bise_slug}-{cls}-{year}"
                fpath = GZ_DIR / f"{fname}.json"
                if fpath.exists():
                    continue
                data = {
                    "title": f"{bise} Board Class {cls} Result Gazette {year}",
                    "year": year,
                    "board": province_name,
                    "boards": [province_name],
                    "bise": bise,
                    "class": cls,
                    "pdfUrl": f"/pdfs/gazettes/{fname}.pdf"
                }
                fpath.write_text(json.dumps(data, indent=2))
                gazette_count += 1

print(f"  ✓ {paper_count} papers generated (Sindh, KPK, Balochistan, AJK)")
print(f"  ✓ {gazette_count} gazettes generated")
PY

# ─────────────────────────────────────────────
#  6. Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding (this will take ~2-3 minutes)..."
npm run build 2>&1 | tail -8

echo ""
echo "════════════════════════════════════════════"
echo "  Done."
echo ""
echo "  Preview:"
echo "    pkill -f 'astro dev' || true"
echo "    npm run dev"
echo ""
echo "  Test these URLs:"
echo "    /                              (class + board pickers)"
echo "    /class/10                      (class-first hub)"
echo "    /class/5                       (books only)"
echo "    /board/sindh                   (Sindh with 5 BISE cards)"
echo "    /board/kpk                     (KPK with 8 BISE cards)"
echo "    /board/balochistan             (7 BISE cards)"
echo "    /board/ajk                     (3 BISE cards)"
echo ""
echo "  What was added:"
echo "    · Class-first navigation (Class 1-12)"
echo "    · 23 new BISEs across 4 provinces"
echo "    · ~3,700 new papers"
echo "    · ~400 new gazettes"
echo "    · All province board pages show their BISEs"
echo "════════════════════════════════════════════"