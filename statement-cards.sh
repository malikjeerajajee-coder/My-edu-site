#!/bin/bash
# statement-cards.sh — convert internal hub pages to homepage statement cards
set -e
cd ~/my-edu-site

git branch -f backup-pre-statement-cards 2>/dev/null || true
echo "  ✓ Backup: backup-pre-statement-cards"
echo ""

# ═══ 1. Add statement-card CSS ═══
python3 <<'PY'
import pathlib
p = pathlib.Path('src/styles/global.css')
s = p.read_text()

if '.statement-card' not in s:
    s = s.rstrip() + '''

/* ═══ Statement card — matches homepage board/class cards ═══ */
.statement-card {
  position: relative;
  display: flex;
  flex-direction: column;
  background: #ffffff;
  padding: 1.5rem;
  transition: background-color .15s ease;
}
.statement-card:hover {
  background: #f8fafc;
}
.statement-card-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 1rem;
}
.statement-card-title {
  font-family: var(--font-display);
  font-size: 1.25rem;
  font-weight: 800;
  letter-spacing: -0.025em;
  color: var(--ink);
  line-height: 1.15;
}
.statement-card-desc {
  margin-top: 0.5rem;
  font-size: 0.8125rem;
  line-height: 1.5;
  color: var(--muted);
}
.statement-card-count {
  margin-top: 1.5rem;
  font-size: 0.6875rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--subtle);
}
.statement-card-arrow {
  flex-shrink: 0;
  margin-top: 0.375rem;
  color: #cbd5e1;
  transition: color .15s ease, transform .15s ease;
}
.statement-card:hover .statement-card-arrow {
  color: var(--brand);
  transform: translate(0.125rem, -0.125rem);
}

/* ═══ Number-forward card — matches homepage class cards ═══ */
.num-card {
  position: relative;
  display: flex;
  flex-direction: column;
  background: #ffffff;
  padding: 1.5rem;
  transition: background-color .15s ease;
}
.num-card:hover {
  background: #f8fafc;
}
.num-card-num {
  font-family: var(--font-display);
  font-size: 2rem;
  font-weight: 800;
  line-height: 1;
  letter-spacing: -0.035em;
  color: var(--ink);
  font-variant-numeric: tabular-nums;
}
.num-card-label {
  margin-top: 1.25rem;
  font-size: 0.8125rem;
  font-weight: 700;
  color: var(--ink);
}
.num-card-sub {
  margin-top: 0.125rem;
  font-size: 0.6875rem;
  color: var(--muted);
}
.num-card-open {
  margin-top: 1rem;
  display: flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.625rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--subtle);
  transition: color .15s ease;
}
.num-card:hover .num-card-open {
  color: var(--brand);
}

/* ═══ Neutralize icon tiles on statement cards ═══ */
.tile {
  background: #f1f5f9 !important;
  color: #475569 !important;
}
'''
    p.write_text(s)
    print('  ✓ CSS added')
else:
    print('  · CSS already present')
PY

# ═══ 2. Rewrite hub pages ═══
echo ""
echo "▸ Rewriting hub pages…"

mkdir -p 'src/pages/board/[board]/[class]'
mkdir -p 'src/pages/board/[board]/[bise]/[class]'

# ── /boards.astro ──
cat > src/pages/boards.astro <<'ASTRO'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { url } from '../lib/url';
import { BOARDS } from '../lib/boards';
import { getBoardCounts } from '../lib/boardContent';

const counts = await getBoardCounts();
---
<BaseLayout title="All Boards — Parhayi" description="Browse notes, past papers, guess papers and result gazettes for all Pakistani boards: Punjab, Federal, KPK, Sindh, Balochistan, AJK.">
  <div class="border-b border-slate-200">
    <div class="mx-auto max-w-[1200px] px-5 pt-14 pb-16 sm:px-7 lg:px-10 lg:pt-20 lg:pb-24">
      <nav class="mb-6 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">Boards</span>
      </nav>
      <div class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-[#1d4ed8]">
        <span class="h-1.5 w-1.5 rounded-full bg-[#1d4ed8]"></span>
        Boards
      </div>
      <h1 class="mt-6 max-w-4xl font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl lg:text-6xl">
        All boards.
      </h1>
      <p class="mt-6 max-w-2xl text-base leading-relaxed text-slate-600 sm:text-lg">
        Six provincial and federal boards. Every board publishes its own textbooks, past papers and result gazettes.
      </p>
    </div>
  </div>

  <section class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
    <div class="mb-8">
      <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Choose your board</h2>
      <p class="mt-1.5 text-sm text-slate-500">Each board publishes its own material — pick the one that matches your school.</p>
    </div>

    <div class="seamed-grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3">
      {BOARDS.map(b => (
        <a href={url(`/board/${b.slug}`)} class="statement-card">
          <div class="statement-card-head">
            <h3 class="statement-card-title">{b.name}</h3>
            <Icon name="arrow-up-right" size={16} strokeWidth={2.4} class="statement-card-arrow" />
          </div>
          <p class="statement-card-desc">{b.full}</p>
          <div class="statement-card-count">
            {(counts[b.slug] || 0).toLocaleString()} {(counts[b.slug] || 0) === 1 ? 'resource' : 'resources'}
          </div>
        </a>
      ))}
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ /boards.astro"

# ── /board/[board]/index.astro ──
cat > 'src/pages/board/[board]/index.astro' <<'ASTRO'
---
import BaseLayout from '../../../layouts/BaseLayout.astro';
import Icon from '../../../components/Icon.astro';
import { url } from '../../../lib/url';
import { BOARDS, getBISEsForProvince, hasBISEs } from '../../../lib/boards';
import { getBoardContent } from '../../../lib/boardContent';
import { getBoardInfo } from '../../../lib/boardInfo';

export async function getStaticPaths() {
  return BOARDS.map(b => ({ params: { board: b.slug } }));
}

const { board: slug } = Astro.params;
const data = await getBoardContent(slug!);
if (!data) return Astro.redirect('/boards');
const { board, classes, notes, quizzes, books, gazettes, pastPapers, guessPapers, pairingSchemes, total } = data;
const info = getBoardInfo(slug!);
const bises = getBISEsForProvince(slug!);
const showBISEs = hasBISEs(slug!);
---
<BaseLayout
  title={`${board.full} — Class 9 to 12 Notes, Past Papers & Gazettes | Parhayi`}
  description={`Everything for ${board.full}: notes, past papers, guess papers, pairing schemes, quizzes and result gazettes for Class 9, 10, 11 and 12.`}
>
  <div class="border-b border-slate-200">
    <div class="mx-auto max-w-[1200px] px-5 pt-14 pb-16 sm:px-7 lg:px-10 lg:pt-20 lg:pb-24">
      <nav class="mb-6 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <a href={url('/boards')} class="hover:text-[#1d4ed8]">Boards</a>
        <span>/</span>
        <span class="text-slate-500">{board.name}</span>
      </nav>
      <div class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-[#1d4ed8]">
        <span class="h-1.5 w-1.5 rounded-full bg-[#1d4ed8]"></span>
        Board
      </div>
      <h1 class="mt-6 max-w-4xl font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl lg:text-6xl">
        {board.full}
      </h1>
      <p class="mt-6 max-w-2xl text-base leading-relaxed text-slate-600 sm:text-lg">
        {info?.overview ? info.overview.split('. ')[0] + '.' : `All study material for ${board.full}, organised by class.`}
      </p>
      <dl class="mt-10 flex flex-wrap gap-x-12 gap-y-4">
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Classes</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{classes.length}</dd>
        </div>
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Resources</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{total}</dd>
        </div>
        {showBISEs && (
          <div>
            <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">BISEs</dt>
            <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{bises.length}</dd>
          </div>
        )}
      </dl>
    </div>
  </div>

  <!-- Pick your class -->
  <section class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
    <div class="mb-8">
      <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Pick your class</h2>
      <p class="mt-1.5 text-sm text-slate-500">Every class has its own notes, textbooks, past papers and quizzes.</p>
    </div>
    {classes.length === 0 ? (
      <div class="rounded-2xl border border-dashed border-slate-300 bg-white p-12 text-center">
        <p class="text-sm font-bold text-slate-900">No content yet for {board.name}</p>
      </div>
    ) : (
      <div class="seamed-grid grid-cols-2 sm:grid-cols-4">
        {classes.map(c => {
          const count = notes.filter((i: any) => i.data.class === c).length
            + quizzes.filter((i: any) => i.data.class === c).length
            + books.filter((i: any) => i.data.class === c).length
            + pastPapers.filter((i: any) => i.data.class === c).length
            + guessPapers.filter((i: any) => i.data.class === c).length
            + pairingSchemes.filter((i: any) => i.data.class === c).length
            + gazettes.filter((i: any) => i.data.class === c).length;
          return (
            <a href={url(`/board/${slug}/class-${c}`)} class="num-card">
              <span class="num-card-num">{c.padStart(2, '0')}</span>
              <div class="num-card-label">Class {c}</div>
              <div class="num-card-sub">{count.toLocaleString()} {count === 1 ? 'item' : 'items'}</div>
              <div class="num-card-open">
                Open <Icon name="arrow-right" size={10} strokeWidth={2.8} />
              </div>
            </a>
          );
        })}
      </div>
    )}
  </section>

  <!-- BISE picker -->
  {showBISEs && (
    <section class="border-t border-slate-200">
      <div class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
        <div class="mb-8">
          <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Pick your specific board</h2>
          <p class="mt-1.5 text-sm text-slate-500">
            {board.name} has {bises.length} separate Boards of Intermediate and Secondary Education (BISEs). Past papers and result gazettes are unique to each board.
          </p>
        </div>
        <div class="seamed-grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3">
          {bises.map(bise => (
            <a href={url(`/board/${slug}/${bise.slug}`)} class="statement-card">
              <div class="statement-card-head">
                <h3 class="statement-card-title">BISE {bise.name}</h3>
                <Icon name="arrow-up-right" size={16} strokeWidth={2.4} class="statement-card-arrow" />
              </div>
              <p class="statement-card-desc">Past papers · Result gazettes</p>
            </a>
          ))}
        </div>
      </div>
    </section>
  )}

  {info && (
    <>
      <section class="border-t border-slate-200">
        <div class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
          <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Boards covered</h2>
          <p class="mt-4 max-w-3xl text-sm leading-relaxed text-slate-600">{info.overview}</p>
          <div class="mt-6 flex flex-wrap gap-2">
            {info.boardsServed.map(b => (
              <span class="inline-flex items-center rounded-md border border-slate-200 bg-white px-2.5 py-1 text-xs font-bold text-slate-700">{b}</span>
            ))}
          </div>
        </div>
      </section>

      <section class="border-t border-slate-200 bg-slate-50">
        <div class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
          <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Exam overview</h2>
          <p class="mt-3 text-sm leading-relaxed text-slate-600">Everything you need to know about the SSC Part-I (Class 9) examination under {board.full}.</p>
          <div class="mt-8 grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
            {[
              { label: 'Total marks',    value: String(info.totalMarks),    sub: 'Across all subjects' },
              { label: 'Passing marks',  value: String(info.passingMarks),  sub: `33% of ${info.totalMarks}` },
              { label: 'Subjects',       value: '8',                        sub: '4 compulsory + 4 elective' },
              { label: 'Exam months',    value: 'Mar–May',                  sub: 'Annual session' },
            ].map(s => (
              <div class="border-t border-slate-300 pt-5">
                <div class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">{s.label}</div>
                <div class="mt-2 font-display text-3xl font-extrabold tracking-tight text-slate-900">{s.value}</div>
                <div class="mt-1 text-xs text-slate-500">{s.sub}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section class="border-t border-slate-200">
        <div class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
          <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Subjects and marks</h2>
          <p class="mt-3 text-sm text-slate-600">How the {info.totalMarks} marks are split across the 8 subjects in the Science group.</p>
          <div class="mt-8 overflow-hidden rounded-2xl border border-slate-200 bg-white">
            <table class="w-full text-left text-sm">
              <thead class="bg-slate-50 text-[10px] font-bold uppercase tracking-wider text-slate-500">
                <tr>
                  <th class="px-5 py-3.5">Subject</th>
                  <th class="px-5 py-3.5">Type</th>
                  <th class="px-5 py-3.5 text-right">Marks</th>
                </tr>
              </thead>
              <tbody>
                {info.subjects.map(s => (
                  <tr class="border-t border-slate-200">
                    <td class="px-5 py-3.5 font-semibold text-slate-900">{s.name}</td>
                    <td class="px-5 py-3.5 text-xs font-semibold uppercase tracking-wider text-slate-500">{s.type}</td>
                    <td class="px-5 py-3.5 text-right font-extrabold text-slate-900">{s.marks}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </section>

      {info.faq.length > 0 && (
        <section class="border-t border-slate-200 bg-slate-50">
          <div class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
            <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Frequently asked questions</h2>
            <div class="mt-8 space-y-2">
              {info.faq.map((f, i) => (
                <details class="group rounded-xl border border-slate-200 bg-white" open={i === 0}>
                  <summary class="flex cursor-pointer list-none items-center justify-between gap-4 px-5 py-4 text-sm font-bold text-slate-900">
                    <span>{f.q}</span>
                    <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-400 transition-transform group-open:rotate-90" />
                  </summary>
                  <div class="border-t border-slate-200 px-5 py-4 text-sm leading-relaxed text-slate-600">{f.a}</div>
                </details>
              ))}
            </div>
          </div>
        </section>
      )}
    </>
  )}
</BaseLayout>
ASTRO
echo "  ✓ /board/[board]/index.astro"

# ── /board/[board]/[class]/index.astro ──
cat > 'src/pages/board/[board]/[class]/index.astro' <<'ASTRO'
---
import BaseLayout from '../../../../layouts/BaseLayout.astro';
import Icon from '../../../../components/Icon.astro';
import { url } from '../../../../lib/url';
import { getClassContent, getAllClassPaths, slugify } from '../../../../lib/boardContent';

export async function getStaticPaths() {
  const paths = await getAllClassPaths();
  return paths.map(p => ({ params: { board: p.board, class: `class-${p.class}` } }));
}

const { board: boardSlug, class: classParam } = Astro.params;
const cls = String(classParam).replace(/^class-/, '');
const data = await getClassContent(boardSlug!, cls);
if (!data) return Astro.redirect('/boards');
const { board, subjects, notes, quizzes, books, gazettes, pastPapers, guessPapers, pairingSchemes } = data;

const sections = [
  { slug: 'notes',           label: 'Notes',           desc: 'Chapter-wise revision',      count: notes.length },
  { slug: 'past-papers',     label: 'Past Papers',     desc: 'Official board exam papers', count: pastPapers.length },
  { slug: 'guess-papers',    label: 'Guess Papers',    desc: 'Expected exam questions',    count: guessPapers.length },
  { slug: 'pairing-schemes', label: 'Pairing Schemes', desc: 'Paper structure & marks',    count: pairingSchemes.length },
  { slug: 'quizzes',         label: 'Quizzes',         desc: 'Interactive MCQs',           count: quizzes.length },
  { slug: 'books',           label: 'Textbooks',       desc: 'Official board textbooks',   count: books.length },
  { slug: 'gazettes',        label: 'Result Gazettes', desc: 'Board result documents',     count: gazettes.length },
].filter(s => s.count > 0);
---
<BaseLayout title={`${board.name} Class ${cls} — All Subjects | Parhayi`} description={`All Class ${cls} study material for ${board.full}: notes, past papers, guess papers, quizzes and more.`}>
  <div class="border-b border-slate-200">
    <div class="mx-auto max-w-[1200px] px-5 pt-14 pb-16 sm:px-7 lg:px-10 lg:pt-20 lg:pb-24">
      <nav class="mb-6 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/boards')} class="hover:text-[#1d4ed8]">Boards</a>
        <span>/</span>
        <a href={url(`/board/${boardSlug}`)} class="hover:text-[#1d4ed8]">{board.name}</a>
        <span>/</span>
        <span class="text-slate-500">Class {cls}</span>
      </nav>
      <div class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-[#1d4ed8]">
        <span class="h-1.5 w-1.5 rounded-full bg-[#1d4ed8]"></span>
        {board.name} · Class {cls}
      </div>
      <h1 class="mt-6 max-w-4xl font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl lg:text-6xl">
        Class {cls}.
      </h1>
      <p class="mt-6 max-w-2xl text-base leading-relaxed text-slate-600 sm:text-lg">
        {data.total.toLocaleString()} resources across {subjects.length} subjects under {board.full}.
      </p>
    </div>
  </div>

  {sections.length > 0 && (
    <section class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
      <div class="mb-8">
        <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Browse by resource</h2>
      </div>
      <div class="seamed-grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3">
        {sections.map(s => (
          <a href={url(`/board/${boardSlug}/class-${cls}/${s.slug}`)} class="statement-card">
            <div class="statement-card-head">
              <h3 class="statement-card-title">{s.label}</h3>
              <Icon name="arrow-up-right" size={16} strokeWidth={2.4} class="statement-card-arrow" />
            </div>
            <p class="statement-card-desc">{s.desc}</p>
            <div class="statement-card-count">
              {s.count.toLocaleString()} {s.count === 1 ? 'item' : 'items'}
            </div>
          </a>
        ))}
      </div>
    </section>
  )}

  {subjects.length > 0 && (
    <section class="border-t border-slate-200 bg-slate-50">
      <div class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
        <div class="mb-8">
          <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Browse by subject</h2>
        </div>
        <div class="seamed-grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3">
          {subjects.map(s => (
            <a href={url(`/board/${boardSlug}/class-${cls}/${slugify(s)}`)} class="statement-card">
              <div class="statement-card-head">
                <h3 class="statement-card-title">{s}</h3>
                <Icon name="arrow-up-right" size={16} strokeWidth={2.4} class="statement-card-arrow" />
              </div>
              <p class="statement-card-desc">All {s} resources for Class {cls}</p>
            </a>
          ))}
        </div>
      </div>
    </section>
  )}
</BaseLayout>
ASTRO
echo "  ✓ /board/[board]/[class]/index.astro"

# ── /books/index.astro ──
cat > src/pages/books/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { getCollection } from 'astro:content';

const books = await getCollection('books');
const counts = new Map<string, number>();
books.forEach((b: any) => {
  const board = (b.data.boards || [])[0];
  if (board) counts.set(board, (counts.get(board) || 0) + 1);
});

const ORDER = ['Punjab', 'Federal', 'Sindh', 'KPK', 'Balochistan', 'AJK'];
const boards = [...counts.keys()].sort((a, b) => {
  const ai = ORDER.indexOf(a), bi = ORDER.indexOf(b);
  if (ai === -1 && bi === -1) return a.localeCompare(b);
  if (ai === -1) return 1;
  if (bi === -1) return -1;
  return ai - bi;
});

const DESC: Record<string, string> = {
  'Punjab':      'Punjab Curriculum and Textbook Board',
  'Federal':     'Federal Board of Intermediate and Secondary Education',
  'Sindh':       'Sindh Textbook Board',
  'KPK':         'Khyber Pakhtunkhwa Textbook Board',
  'Balochistan': 'Balochistan Textbook Board',
  'AJK':         'Azad Jammu and Kashmir Textbook Board',
};
---
<BaseLayout title="Textbooks — Class 1 to 12 | Parhayi" description={`Download official Pakistani textbooks free. ${books.length} books across Punjab, Federal, Sindh and other boards.`}>
  <div class="border-b border-slate-200">
    <div class="mx-auto max-w-[1200px] px-5 pt-14 pb-16 sm:px-7 lg:px-10 lg:pt-20 lg:pb-24">
      <nav class="mb-6 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">Textbooks</span>
      </nav>
      <div class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-[#1d4ed8]">
        <span class="h-1.5 w-1.5 rounded-full bg-[#1d4ed8]"></span>
        Textbooks
      </div>
      <h1 class="mt-6 max-w-4xl font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl lg:text-6xl">
        Pakistan's complete textbook library.
      </h1>
      <p class="mt-6 max-w-2xl text-base leading-relaxed text-slate-600 sm:text-lg">
        {books.length} official textbooks from every major Pakistani board. Free PDFs, no sign-up.
      </p>
    </div>
  </div>

  <section class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
    <div class="mb-8">
      <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Choose your board</h2>
      <p class="mt-1.5 text-sm text-slate-500">Every board publishes its own textbooks.</p>
    </div>
    <div class="seamed-grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3">
      {boards.map(b => {
        const count = counts.get(b) || 0;
        return (
          <a href={url(`/books/${b.toLowerCase()}`)} class="statement-card">
            <div class="statement-card-head">
              <h3 class="statement-card-title">{b}</h3>
              <Icon name="arrow-up-right" size={16} strokeWidth={2.4} class="statement-card-arrow" />
            </div>
            <p class="statement-card-desc">{DESC[b] || `${b} Textbook Board`}</p>
            <div class="statement-card-count">
              {count} {count === 1 ? 'book' : 'books'}
            </div>
          </a>
        );
      })}
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ /books/index.astro"

# ── /books/[board]/index.astro ──
cat > 'src/pages/books/[board]/index.astro' <<'ASTRO'
---
import BaseLayout from '../../../layouts/BaseLayout.astro';
import Icon from '../../../components/Icon.astro';
import { url } from '../../../lib/url';
import { boardMeta, bookSubjectName } from '../../../lib/bookSeo';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const books = await getCollection('books');
  const boards = new Set<string>();
  books.forEach((b: any) => (b.data.boards || []).forEach((x: string) => boards.add(x)));
  return [...boards].map(b => ({ params: { board: b.toLowerCase() } }));
}

const { board: boardSlug } = Astro.params;
const allBooks = await getCollection('books');
const boardName = [...new Set(allBooks.flatMap((b: any) => b.data.boards || []))]
  .find(n => n.toLowerCase() === boardSlug);
if (!boardName) return Astro.redirect('/books');

const meta = boardMeta(boardName);
const books = allBooks.filter((b: any) => (b.data.boards || []).includes(boardName));

const classMap = new Map<string, { books: number; subjects: Set<string> }>();
books.forEach((b: any) => {
  const c = String(b.data.class);
  if (!classMap.has(c)) classMap.set(c, { books: 0, subjects: new Set() });
  const m = classMap.get(c)!;
  m.books++;
  m.subjects.add(bookSubjectName(b.data.subject));
});
const classes = [...classMap.entries()]
  .map(([cls, v]) => ({ cls, books: v.books, subjects: v.subjects.size }))
  .sort((a, b) => Number(a.cls) - Number(b.cls));

const totalSubjects = new Set(books.map((b: any) => bookSubjectName(b.data.subject))).size;
---
<BaseLayout title={`${boardName} Textbooks — Class 1 to 12 | Parhayi`} description={`Download all ${boardName} textbooks free. ${books.length} books across ${classes.length} classes and ${totalSubjects} subjects.`}>
  <div class="border-b border-slate-200">
    <div class="mx-auto max-w-[1200px] px-5 pt-14 pb-16 sm:px-7 lg:px-10 lg:pt-20 lg:pb-24">
      <nav class="mb-6 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <a href={url('/books')} class="hover:text-[#1d4ed8]">Textbooks</a>
        <span>/</span>
        <span class="text-slate-500">{boardName}</span>
      </nav>
      <div class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-[#1d4ed8]">
        <span class="h-1.5 w-1.5 rounded-full bg-[#1d4ed8]"></span>
        {meta.abbreviation}
      </div>
      <h1 class="mt-6 max-w-4xl font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl lg:text-6xl">
        {boardName} Textbooks.
      </h1>
      <p class="mt-6 max-w-2xl text-base leading-relaxed text-slate-600 sm:text-lg">
        Every {boardName} textbook from Class 1 to Class 12. {books.length} books across {totalSubjects} subjects.
      </p>
    </div>
  </div>

  <section class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
    <div class="mb-8">
      <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Choose your class</h2>
      <p class="mt-1.5 text-sm text-slate-500">Every class has its own set of textbooks.</p>
    </div>
    <div class="seamed-grid grid-cols-2 sm:grid-cols-4">
      {classes.map(c => (
        <a href={url(`/books/${boardSlug}/class-${c.cls}`)} class="num-card">
          <span class="num-card-num">{c.cls.padStart(2, '0')}</span>
          <div class="num-card-label">Class {c.cls}</div>
          <div class="num-card-sub">{c.subjects} {c.subjects === 1 ? 'subject' : 'subjects'}</div>
          <div class="num-card-open">
            Open <Icon name="arrow-right" size={10} strokeWidth={2.8} />
          </div>
        </a>
      ))}
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ /books/[board]/index.astro"

# ── /books/[board]/[class].astro ──
cat > 'src/pages/books/[board]/[class].astro' <<'ASTRO'
---
import BaseLayout from '../../../layouts/BaseLayout.astro';
import Icon from '../../../components/Icon.astro';
import { url } from '../../../lib/url';
import { boardMeta, bookSubjectName } from '../../../lib/bookSeo';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const books = await getCollection('books');
  const paths: any[] = [];
  const seen = new Set<string>();
  books.forEach((b: any) => {
    const board = (b.data.boards || [])[0];
    if (!board) return;
    const key = `${board.toLowerCase()}/class-${b.data.class}`;
    if (!seen.has(key)) {
      seen.add(key);
      paths.push({ params: { board: board.toLowerCase(), class: `class-${b.data.class}` } });
    }
  });
  return paths;
}

const { board: boardSlug, class: classParam } = Astro.params;
const cls = String(classParam).replace(/^class-/, '');
const allBooks = await getCollection('books');
const boardName = [...new Set(allBooks.flatMap((b: any) => b.data.boards || []))]
  .find(n => n.toLowerCase() === boardSlug);
if (!boardName) return Astro.redirect('/books');

const meta = boardMeta(boardName);
const books = allBooks
  .filter((b: any) => (b.data.boards || []).includes(boardName) && String(b.data.class) === cls);

books.sort((a: any, b: any) => {
  const score = (x: any) => x.data.scheme === 'new' ? 3 : x.data.scheme === 'snc' ? 2 : 1;
  if (score(a) !== score(b)) return score(b) - score(a);
  const ay = a.data.year || '', by = b.data.year || '';
  if (ay !== by) return by.localeCompare(ay);
  return a.data.subject.localeCompare(b.data.subject);
});

// Group by subject
const bySubject = new Map<string, any[]>();
books.forEach((b: any) => {
  const subj = bookSubjectName(b.data.subject);
  if (!bySubject.has(subj)) bySubject.set(subj, []);
  bySubject.get(subj)!.push(b);
});
const subjects = [...bySubject.keys()].sort();
---
<BaseLayout title={`Class ${cls} ${boardName} Textbooks — All Subjects | Parhayi`} description={`Download all Class ${cls} ${boardName} textbook PDFs. ${subjects.length} subjects. Free, no sign-up.`}>
  <div class="border-b border-slate-200">
    <div class="mx-auto max-w-[1200px] px-5 pt-14 pb-16 sm:px-7 lg:px-10 lg:pt-20 lg:pb-24">
      <nav class="mb-6 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <a href={url('/books')} class="hover:text-[#1d4ed8]">Textbooks</a>
        <span>/</span>
        <a href={url(`/books/${boardSlug}`)} class="hover:text-[#1d4ed8]">{boardName}</a>
        <span>/</span>
        <span class="text-slate-500">Class {cls}</span>
      </nav>
      <div class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-[#1d4ed8]">
        <span class="h-1.5 w-1.5 rounded-full bg-[#1d4ed8]"></span>
        {meta.abbreviation} · Class {cls}
      </div>
      <h1 class="mt-6 max-w-4xl font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl lg:text-6xl">
        Class {cls} Textbooks.
      </h1>
      <p class="mt-6 max-w-2xl text-base leading-relaxed text-slate-600 sm:text-lg">
        {books.length} {boardName} textbooks across {subjects.length} subjects. All free PDFs.
      </p>
    </div>
  </div>

  <section class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
    <div class="space-y-10">
      {subjects.map(subj => (
        <div>
          <div class="mb-5 flex items-baseline justify-between gap-4 border-b border-slate-200 pb-3">
            <h2 class="font-display text-lg font-extrabold tracking-tight text-slate-900">{subj}</h2>
            <span class="text-[10px] font-bold uppercase tracking-[0.1em] text-slate-400">
              {bySubject.get(subj)!.length} {bySubject.get(subj)!.length === 1 ? 'item' : 'items'}
            </span>
          </div>
          <div class="seamed-grid grid-cols-1 sm:grid-cols-2">
            {bySubject.get(subj)!.map((b: any) => {
              const schemeLabel = b.data.scheme === 'new' ? 'New' : b.data.scheme === 'snc' ? 'SNC' : b.data.scheme === 'previous' ? 'Previous' : '';
              const mediumLabel = b.data.medium === 'english' ? 'English' : b.data.medium === 'urdu' ? 'Urdu' : b.data.medium === 'sindhi' ? 'Sindhi' : '';
              const meta = [mediumLabel, schemeLabel, b.data.year].filter(Boolean).join(' · ');
              return (
                <a href={url(`/textbook/${b.id}`)} class="statement-card">
                  <div class="statement-card-head">
                    <h3 class="statement-card-title">{subj}</h3>
                    <Icon name="arrow-up-right" size={16} strokeWidth={2.4} class="statement-card-arrow" />
                  </div>
                  {meta && <p class="statement-card-desc">{meta}</p>}
                </a>
              );
            })}
          </div>
        </div>
      ))}
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ /books/[board]/[class].astro"

# ═══ 3. Neutralize .tile icon tiles globally ═══
echo ""
echo "▸ Neutralizing old blue icon tiles on remaining pages…"

python3 <<'PY'
import pathlib
count = 0
for astro in pathlib.Path('src/pages').rglob('*.astro'):
    s = astro.read_text()
    orig = s
    # icon-tile class uses blue; statement-card contexts don't, so this just
    # softens the residual blue in remaining row-based pages.
    s = s.replace('bg-[#eef2fe] text-[#0620ed]', 'bg-slate-100 text-slate-600')
    s = s.replace('bg-[#eff4ff] text-[#1d4ed8]', 'bg-slate-100 text-slate-600')
    if s != orig:
        astro.write_text(s)
        count += 1
        print(f'  {astro.relative_to("src")}')
print(f'  {count} files')
PY

# ═══ 4. Rebuild ═══
echo ""
echo "▸ Rebuilding…"
rm -rf .astro dist
npm run build 2>&1 | tail -8

echo ""
echo "════════════════════════════════════════════"
echo "  DONE"
echo ""
echo "  Preview:  bash preview.sh"
echo ""
echo "  Then open in Incognito:"
echo "    http://localhost:4321/My-edu-site/"
echo "    http://localhost:4321/My-edu-site/boards/"
echo "    http://localhost:4321/My-edu-site/board/punjab/"
echo "    http://localhost:4321/My-edu-site/board/punjab/class-10/"
echo "    http://localhost:4321/My-edu-site/books/"
echo "    http://localhost:4321/My-edu-site/books/punjab/"
echo "    http://localhost:4321/My-edu-site/books/punjab/class-11/"
echo ""
echo "  Every hub page now uses:"
echo "    · Statement cards (big bold title, description, count, arrow)"
echo "    · Number-forward cards for class pickers (01, 02, 03 …)"
echo "    · Neutral gray icon tiles (no more blue tint)"
echo "    · Same typography scale as homepage"
echo ""
echo "  Push when happy:"
echo "    git add ."
echo "    git commit -m 'Convert all hub pages to homepage statement cards'"
echo "    git push"
echo ""
echo "  Revert:"
echo "    git checkout backup-pre-statement-cards"
echo "════════════════════════════════════════════"