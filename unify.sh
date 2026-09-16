#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Unifying internal page layouts"
echo "════════════════════════════════════════════"
echo ""

mkdir -p 'src/pages/board/[board]/[class]'

# ═══════════════════════════════════════════════
#  1. /boards
# ═══════════════════════════════════════════════
cat > src/pages/boards.astro <<'ASTRO'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { url } from '../lib/url';
import { BOARDS } from '../lib/boards';
import { getBoardCounts } from '../lib/boardContent';

const counts = await getBoardCounts();
---
<BaseLayout title="All Boards — TaleemHub" description="Browse notes, past papers, guess papers and result gazettes for all Pakistani boards: Punjab, Federal, KPK, Sindh, Balochistan, AJK.">
  <!-- Page header -->
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">Boards</span>
      </nav>
      <div class="max-w-2xl">
        <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">All boards</h1>
        <p class="mt-3 text-base leading-relaxed text-slate-600">
          Pick your board to find every note, past paper, guess paper and result gazette tailored to your syllabus.
        </p>
      </div>
    </div>
  </div>

  <!-- Content -->
  <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-16">
    <div class="grid grid-cols-1 gap-3 sm:grid-cols-2">
      {BOARDS.map(b => (
        <a href={url(`/board/${b.slug}`)} class="row group">
          <span class="tile">
            <Icon name="graduation-cap" size={20} strokeWidth={2.2} />
          </span>
          <div class="min-w-0 flex-1">
            <div class="text-[15px] font-extrabold tracking-tight text-slate-900">{b.name}</div>
            <div class="text-xs text-slate-500">{counts[b.slug] || 0} {counts[b.slug] === 1 ? 'resource' : 'resources'}</div>
          </div>
          <Icon name="arrow-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
        </a>
      ))}
    </div>
  </div>
</BaseLayout>
ASTRO
echo "  /boards"

# ═══════════════════════════════════════════════
#  2. /board/[board]
# ═══════════════════════════════════════════════
cat > 'src/pages/board/[board]/index.astro' <<'ASTRO'
---
import BaseLayout from '../../../layouts/BaseLayout.astro';
import Icon from '../../../components/Icon.astro';
import { url } from '../../../lib/url';
import { BOARDS } from '../../../lib/boards';
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
---
<BaseLayout
  title={`${board.full} — Class 9 to 12 Notes, Past Papers & Gazettes | TaleemHub`}
  description={`Everything for ${board.full}: notes, past papers, guess papers, pairing schemes, quizzes and result gazettes for Class 9, 10, 11 and 12.`}
>
  <!-- Page header -->
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <a href={url('/boards')} class="hover:text-[#1d4ed8]">Boards</a>
        <span>/</span>
        <span class="text-slate-500">{board.name}</span>
      </nav>
      <div class="max-w-2xl">
        <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">{board.full}</h1>
        <p class="mt-3 text-base leading-relaxed text-slate-600">
          {info?.overview ? info.overview.split('. ')[0] + '.' : `All study material for ${board.full}, organised by class.`}
        </p>
      </div>
      <div class="mt-6 flex flex-wrap gap-x-8 gap-y-3 text-sm">
        <div><span class="font-extrabold text-slate-900 text-lg">{classes.length}</span> <span class="text-slate-500">{classes.length === 1 ? 'class' : 'classes'}</span></div>
        <div><span class="font-extrabold text-slate-900 text-lg">{total}</span> <span class="text-slate-500">items</span></div>
        {info && <div><span class="font-extrabold text-slate-900 text-lg">{info.boardsServed.length}</span> <span class="text-slate-500">BISE boards served</span></div>}
      </div>
    </div>
  </div>

  <!-- Pick your class -->
  <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
    <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Pick your class</h2>
    {classes.length === 0 ? (
      <div class="mt-6 rounded-xl border border-dashed border-slate-300 bg-white p-12 text-center">
        <p class="text-sm font-bold text-slate-900">No content yet for {board.name}</p>
        <p class="mt-1 text-xs text-slate-500">Check back soon.</p>
      </div>
    ) : (
      <div class="mt-6 grid grid-cols-2 gap-3 lg:grid-cols-4">
        {classes.map(c => {
          const count = notes.filter((i: any) => i.data.class === c).length
            + quizzes.filter((i: any) => i.data.class === c).length
            + books.filter((i: any) => i.data.class === c).length
            + pastPapers.filter((i: any) => i.data.class === c).length
            + guessPapers.filter((i: any) => i.data.class === c).length
            + pairingSchemes.filter((i: any) => i.data.class === c).length
            + gazettes.filter((i: any) => i.data.class === c).length;
          return (
            <a href={url(`/board/${slug}/class-${c}`)} class="row group">
              <span class="tile"><Icon name="graduation-cap" size={20} strokeWidth={2.2} /></span>
              <div class="min-w-0 flex-1">
                <div class="text-[15px] font-extrabold tracking-tight text-slate-900">Class {c}</div>
                <div class="text-xs text-slate-500">{count} {count === 1 ? 'item' : 'items'}</div>
              </div>
              <Icon name="arrow-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
            </a>
          );
        })}
      </div>
    )}
  </div>

  {info && (
    <>
      <!-- Boards covered -->
      <div class="border-t border-slate-200 bg-slate-50">
        <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
          <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Boards covered</h2>
          <p class="mt-3 max-w-3xl text-sm leading-relaxed text-slate-600">{info.overview}</p>
          <div class="mt-6 flex flex-wrap gap-2">
            {info.boardsServed.map(b => (
              <span class="pill">{b}</span>
            ))}
          </div>
        </div>
      </div>

      <!-- Exam overview -->
      <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
        <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Exam overview</h2>
        <p class="mt-3 text-sm leading-relaxed text-slate-600">Everything you need to know about the SSC Part-I (Class 9) examination under {board.full}.</p>
        <div class="mt-6 grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
          {[
            { label: 'Total marks',    value: String(info.totalMarks),    sub: 'Across all subjects' },
            { label: 'Passing marks',  value: String(info.passingMarks),  sub: `33% of ${info.totalMarks}` },
            { label: 'Subjects',       value: '8',                        sub: '4 compulsory + 4 elective' },
            { label: 'Exam months',    value: 'Mar–May',                  sub: 'Annual session' },
          ].map(s => (
            <div class="rounded-xl border border-slate-200 bg-white p-6">
              <div class="text-[10px] font-bold uppercase tracking-wider text-slate-400">{s.label}</div>
              <div class="mt-2 text-2xl font-extrabold tracking-tight text-slate-900">{s.value}</div>
              <div class="mt-1 text-xs text-slate-500">{s.sub}</div>
            </div>
          ))}
        </div>
      </div>

      <!-- Subjects & marks -->
      <div class="border-t border-slate-200 bg-slate-50">
        <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
          <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Subjects and marks distribution</h2>
          <p class="mt-3 text-sm text-slate-600">How the {info.totalMarks} marks are split across the 8 subjects in the Science group.</p>
          <div class="mt-6 overflow-hidden rounded-xl border border-slate-200 bg-white">
            <table class="w-full text-left text-sm">
              <thead class="bg-slate-50 text-[10px] font-bold uppercase tracking-wider text-slate-500">
                <tr>
                  <th class="px-5 py-3">Subject</th>
                  <th class="px-5 py-3">Type</th>
                  <th class="px-5 py-3 text-right">Marks</th>
                </tr>
              </thead>
              <tbody>
                {info.subjects.map(s => (
                  <tr class="border-t border-slate-200">
                    <td class="px-5 py-3 font-semibold text-slate-900">{s.name}</td>
                    <td class="px-5 py-3">
                      <span class:list={[
                        "inline-block rounded px-2 py-0.5 text-[10px] font-bold uppercase tracking-wide",
                        s.type === 'compulsory' ? "bg-[#eff4ff] text-[#1d4ed8]" : "bg-slate-100 text-slate-600"
                      ]}>{s.type}</span>
                    </td>
                    <td class="px-5 py-3 text-right font-extrabold text-slate-900">{s.marks}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Paper pattern -->
      <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
        <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Paper pattern by subject</h2>
        <p class="mt-3 text-sm text-slate-600">The exact structure of each paper.</p>
        <div class="mt-6 overflow-hidden rounded-xl border border-slate-200 bg-white">
          <table class="w-full text-left text-sm">
            <thead class="bg-slate-50 text-[10px] font-bold uppercase tracking-wider text-slate-500">
              <tr>
                <th class="px-5 py-3">Subject</th>
                <th class="px-5 py-3">Total</th>
                <th class="px-5 py-3">Objective</th>
                <th class="px-5 py-3">Subjective</th>
                <th class="px-5 py-3">Duration</th>
              </tr>
            </thead>
            <tbody>
              {info.paperPatterns.map(p => (
                <tr class="border-t border-slate-200">
                  <td class="px-5 py-3 font-bold text-slate-900">{p.subject}</td>
                  <td class="px-5 py-3 font-extrabold text-slate-900">{p.totalMarks}</td>
                  <td class="px-5 py-3 text-slate-600 text-xs">{p.objective}</td>
                  <td class="px-5 py-3 text-slate-600 text-xs">{p.subjective}</td>
                  <td class="px-5 py-3 text-slate-600 text-xs">{p.duration}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      <!-- FAQ -->
      {info.faq.length > 0 && (
        <div class="border-t border-slate-200 bg-slate-50">
          <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
            <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Frequently asked questions</h2>
            <div class="mt-6 space-y-2">
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
        </div>
      )}

      <!-- CTA -->
      <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
        <div class="rounded-xl border border-slate-200 bg-white p-8 sm:flex sm:items-center sm:gap-6">
          <span class="tile"><Icon name="newspaper" size={22} strokeWidth={2.2} /></span>
          <div class="mt-4 min-w-0 flex-1 sm:mt-0">
            <h3 class="text-lg font-extrabold tracking-tight text-slate-900">Looking for your result?</h3>
            <p class="mt-1 text-sm text-slate-500">Download the latest {board.name} result gazettes.</p>
          </div>
          <a href={url('/gazettes')} class="btn btn-primary mt-5 w-full sm:mt-0 sm:w-auto">
            View gazettes <Icon name="arrow-right" size={14} strokeWidth={2.6} />
          </a>
        </div>
      </div>
    </>
  )}
</BaseLayout>
ASTRO
echo "  /board/[board]"

# ═══════════════════════════════════════════════
#  3. /board/[board]/[class]
# ═══════════════════════════════════════════════
cat > 'src/pages/board/[board]/[class]/index.astro' <<'ASTRO'
---
import BaseLayout from '../../../../layouts/BaseLayout.astro';
import Icon from '../../../../components/Icon.astro';
import { url } from '../../../../lib/url';
import { BOARDS } from '../../../../lib/boards';
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
  { slug: 'notes',           label: 'Notes',           icon: 'file-text',   count: notes.length },
  { slug: 'past-papers',     label: 'Past Papers',     icon: 'scroll-text', count: pastPapers.length },
  { slug: 'guess-papers',    label: 'Guess Papers',    icon: 'sparkles',    count: guessPapers.length },
  { slug: 'pairing-schemes', label: 'Pairing Schemes', icon: 'list',        count: pairingSchemes.length },
  { slug: 'quizzes',         label: 'Quizzes',         icon: 'circle-help', count: quizzes.length },
  { slug: 'books',           label: 'Books',           icon: 'book-marked', count: books.length },
  { slug: 'gazettes',        label: 'Result Gazettes', icon: 'newspaper',   count: gazettes.length },
].filter(s => s.count > 0);
---
<BaseLayout title={`${board.name} Class ${cls} — All Subjects | TaleemHub`} description={`All Class ${cls} study material for ${board.full}: notes, past papers, guess papers, quizzes and more.`}>
  <!-- Page header -->
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/boards')} class="hover:text-[#1d4ed8]">Boards</a>
        <span>/</span>
        <a href={url(`/board/${boardSlug}`)} class="hover:text-[#1d4ed8]">{board.name}</a>
        <span>/</span>
        <span class="text-slate-500">Class {cls}</span>
      </nav>
      <div class="max-w-2xl">
        <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">Class {cls} · {board.name}</h1>
        <p class="mt-3 text-base text-slate-600">{subjects.length} {subjects.length === 1 ? 'subject' : 'subjects'} · {data.total} items</p>
      </div>
    </div>
  </div>

  <!-- Browse by type -->
  {sections.length > 0 && (
    <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
      <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Browse by resource type</h2>
      <div class="mt-6 grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
        {sections.map(s => (
          <a href={url(`/board/${boardSlug}/class-${cls}/${s.slug}`)} class="row group">
            <span class="tile"><Icon name={s.icon} size={18} strokeWidth={2.2} /></span>
            <div class="min-w-0 flex-1">
              <div class="text-sm font-extrabold tracking-tight text-slate-900">{s.label}</div>
              <div class="text-xs text-slate-500">{s.count} {s.count === 1 ? 'item' : 'items'}</div>
            </div>
            <Icon name="arrow-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
          </a>
        ))}
      </div>
    </div>
  )}

  <!-- Browse by subject -->
  {subjects.length > 0 && (
    <div class="border-t border-slate-200 bg-slate-50">
      <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
        <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Browse by subject</h2>
        <div class="mt-6 grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {subjects.map(s => (
            <a href={url(`/board/${boardSlug}/class-${cls}/${slugify(s)}`)} class="row group">
              <span class="tile"><Icon name="library" size={18} strokeWidth={2.2} /></span>
              <div class="min-w-0 flex-1">
                <div class="text-sm font-extrabold tracking-tight text-slate-900">{s}</div>
              </div>
              <Icon name="arrow-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
            </a>
          ))}
        </div>
      </div>
    </div>
  )}
</BaseLayout>
ASTRO
echo "  /board/[board]/[class]"

# ═══════════════════════════════════════════════
#  4. Top-level list pages — unified
# ═══════════════════════════════════════════════
# These all use the same template: header + board picker + counts

write_hub () {
  local PAGE=$1
  local TITLE=$2
  local DESC=$3
  local ICON=$4
  local HEADING=$5
  local SUBHEADING=$6

  cat > "$PAGE" <<ASTRO
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { BOARDS, itemBoards } from '../../lib/boards';
import { getCollection } from 'astro:content';

const items = await getCollection('${COLL}');
const boardCounts: Record<string, number> = {};
for (const b of BOARDS) {
  boardCounts[b.slug] = items.filter((p: any) => itemBoards(p.data).includes(b.name)).length;
}
const recent = [...items].sort((a: any, b: any) => (b.data.year || 0) - (a.data.year || 0)).slice(0, 6);
---
<BaseLayout title="${TITLE}" description="${DESC}">
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">${HEADING}</span>
      </nav>
      <div class="max-w-2xl">
        <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">${HEADING}</h1>
        <p class="mt-3 text-base leading-relaxed text-slate-600">${SUBHEADING}</p>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
    <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Choose your board</h2>
    <p class="mt-2 text-sm text-slate-500">Resources are different for each board — pick yours to continue.</p>
    <div class="mt-6 grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
      {BOARDS.map(b => {
        const count = boardCounts[b.slug];
        const disabled = count === 0;
        return (
          <a href={url(\`/board/\${b.slug}\`)} class:list={["row group", disabled && "opacity-60"]}>
            <span class="tile"><Icon name="${ICON}" size={18} strokeWidth={2.2} /></span>
            <div class="min-w-0 flex-1">
              <div class="text-sm font-extrabold tracking-tight text-slate-900">{b.name}</div>
              <div class="text-xs text-slate-500">{disabled ? 'Coming soon' : \`\${count} \${count === 1 ? 'item' : 'items'}\`}</div>
            </div>
            {!disabled && <Icon name="arrow-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />}
          </a>
        );
      })}
    </div>
  </div>

  {recent.length > 0 && (
    <div class="border-t border-slate-200 bg-slate-50">
      <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
        <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Recently added</h2>
        <div class="mt-6 grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {recent.map((p: any) => (
            <a href={url(\`/${BASE}/\${p.id}\`)} class="row group">
              <span class="tile"><Icon name="${ICON}" size={18} strokeWidth={2.2} /></span>
              <div class="min-w-0 flex-1">
                <div class="truncate text-sm font-bold text-slate-900">{p.data.title}</div>
                <div class="mt-1 flex flex-wrap gap-1.5">
                  {p.data.class && <span class="rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate-600">Class {p.data.class}</span>}
                  {p.data.year && <span class="rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate-600">{p.data.year}</span>}
                </div>
              </div>
            </a>
          ))}
        </div>
      </div>
    </div>
  )}
</BaseLayout>
ASTRO
  echo "  $PAGE"
}

COLL="pastPapers"       BASE="past-papers"      write_hub "src/pages/past-papers/index.astro"       "Past Papers — All Pakistan Boards | TaleemHub"   "Download past papers for Class 9-12 across Pakistani boards." "scroll-text"  "Past Papers"    "Pick your board, then your class and subject — find every paper you need, from 2018 to today."
COLL="guessPapers"      BASE="guess-papers"     write_hub "src/pages/guess-papers/index.astro"      "Guess Papers — All Pakistan Boards | TaleemHub"  "Latest guess papers for Pakistani students."                  "sparkles"     "Guess Papers"    "The most important questions likely to appear in your paper — chosen from years of exam patterns."
COLL="pairingSchemes"   BASE="pairing-schemes"  write_hub "src/pages/pairing-schemes/index.astro"   "Pairing Schemes — All Pakistan Boards | TaleemHub" "Official pairing schemes for Pakistani boards."              "list"         "Pairing Schemes" "Know exactly how marks are split across your paper — objective, short questions, long questions."
COLL="gazettes"         BASE="gazettes"         write_hub "src/pages/gazettes/index.astro"           "Result Gazettes — All Pakistan Boards | TaleemHub" "Board result gazettes for Pakistani students."               "newspaper"    "Result Gazettes" "Official result gazettes from Pakistani boards, Class 9 through 12."

# ═══════════════════════════════════════════════
#  5. Notes, Quizzes, Books — simpler list pages (no board-hub)
# ═══════════════════════════════════════════════
cat > src/pages/notes/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { getCollection } from 'astro:content';
const notes = (await getCollection('notes')).sort((a: any, b: any) => a.data.title.localeCompare(b.data.title));
---
<BaseLayout title="Notes — TaleemHub" description="Subject-wise chapter notes for Pakistani students across all boards.">
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">Notes</span>
      </nav>
      <div class="max-w-2xl">
        <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">Notes</h1>
        <p class="mt-3 text-base leading-relaxed text-slate-600">{notes.length} {notes.length === 1 ? 'note' : 'notes'} across all subjects and boards.</p>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
    <div class="grid grid-cols-1 gap-3 sm:grid-cols-2">
      {notes.map(n => (
        <a href={url(`/notes/${n.id}`)} class="row group">
          <span class="tile"><Icon name="file-text" size={18} strokeWidth={2.2} /></span>
          <div class="min-w-0 flex-1">
            <div class="truncate text-sm font-bold tracking-tight text-slate-900">{n.data.title}</div>
            <div class="mt-1 flex flex-wrap gap-1.5">
              <span class="rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate-600">{n.data.subject}</span>
              <span class="rounded bg-[#eff4ff] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#1d4ed8]">Class {n.data.class}</span>
            </div>
          </div>
          <Icon name="arrow-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
        </a>
      ))}
    </div>
  </div>
</BaseLayout>
ASTRO
echo "  /notes"

cat > src/pages/quizzes/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { getCollection } from 'astro:content';
const quizzes = await getCollection('quizzes');
---
<BaseLayout title="Quizzes — TaleemHub" description="Interactive MCQ quizzes for Pakistani students.">
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">Quizzes</span>
      </nav>
      <div class="max-w-2xl">
        <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">Quizzes</h1>
        <p class="mt-3 text-base leading-relaxed text-slate-600">{quizzes.length} interactive MCQ {quizzes.length === 1 ? 'quiz' : 'quizzes'} with instant feedback.</p>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
    <div class="grid grid-cols-1 gap-3 sm:grid-cols-2">
      {quizzes.map(q => (
        <a href={url(`/quizzes/${q.id}`)} class="row group">
          <span class="tile"><Icon name="circle-help" size={18} strokeWidth={2.2} /></span>
          <div class="min-w-0 flex-1">
            <div class="truncate text-sm font-bold tracking-tight text-slate-900">{q.data.title}</div>
            <div class="mt-1 flex flex-wrap gap-1.5">
              <span class="rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate-600">{q.data.subject}</span>
              <span class="rounded bg-[#eff4ff] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#1d4ed8]">Class {q.data.class}</span>
            </div>
          </div>
          <Icon name="arrow-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
        </a>
      ))}
    </div>
  </div>
</BaseLayout>
ASTRO
echo "  /quizzes"

cat > src/pages/books/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { getCollection } from 'astro:content';
const books = await getCollection('books');
---
<BaseLayout title="Books — TaleemHub" description="Free textbook PDFs for Pakistani students.">
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">Books</span>
      </nav>
      <div class="max-w-2xl">
        <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">Textbooks</h1>
        <p class="mt-3 text-base leading-relaxed text-slate-600">{books.length} {books.length === 1 ? 'textbook' : 'textbooks'} ready to download.</p>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
    <div class="grid grid-cols-1 gap-3 sm:grid-cols-2">
      {books.map(b => (
        <a href={url(`/books/${b.id}`)} class="row group">
          <span class="tile"><Icon name="book-marked" size={18} strokeWidth={2.2} /></span>
          <div class="min-w-0 flex-1">
            <div class="truncate text-sm font-bold tracking-tight text-slate-900">{b.data.title}</div>
            <div class="mt-1 flex flex-wrap gap-1.5">
              <span class="rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate-600">{b.data.subject}</span>
              <span class="rounded bg-[#eff4ff] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#1d4ed8]">Class {b.data.class}</span>
            </div>
          </div>
          <Icon name="arrow-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
        </a>
      ))}
    </div>
  </div>
</BaseLayout>
ASTRO
echo "  /books"

# ═══════════════════════════════════════════════
#  6. Rebuild
# ═══════════════════════════════════════════════
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -8

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Push:"
echo ""
echo "    git add ."
echo "    git commit -m 'Unify internal page layouts'"
echo "    git push"
echo ""
echo "  Every internal page now shares:"
echo "    · Breadcrumbs"
echo "    · Left-aligned H1 + subtitle on slate-50 header band"
echo "    · .row lists with .tile icons"
echo "    · Consistent 1200px max-width"
echo "    · Consistent section rhythm"
echo ""
echo "  Homepage remains centered (SME-style)."
echo "  All other pages use the editorial internal pattern."
echo "════════════════════════════════════════════"