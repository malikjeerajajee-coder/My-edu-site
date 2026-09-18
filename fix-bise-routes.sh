#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Fixing BISE routes (all provinces)"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  1. Remove old Punjab-only BISE routes
# ─────────────────────────────────────────────
rm -rf src/pages/board/punjab
echo "  ✓ Removed old Punjab-only BISE tree"

# ─────────────────────────────────────────────
#  2. Create province-agnostic BISE route tree
# ─────────────────────────────────────────────
mkdir -p 'src/pages/board/[board]/[bise]/[class]'

# ── BISE hub ──
cat > 'src/pages/board/[board]/[bise]/index.astro' <<'ASTRO'
---
import BaseLayout from '../../../../layouts/BaseLayout.astro';
import Icon from '../../../../components/Icon.astro';
import { url } from '../../../../lib/url';
import { BOARDS, boardBySlug } from '../../../../lib/boards';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const paths: any[] = [];
  for (const board of BOARDS) {
    if (!board.biseAware) continue;
    for (const bise of board.bises) {
      paths.push({ params: { board: board.slug, bise: bise.slug } });
    }
  }
  return paths;
}

const { board: boardSlug, bise: biseSlug } = Astro.params;
const board = boardBySlug(boardSlug!);
const bise = board?.bises.find(b => b.slug === biseSlug);
if (!board || !bise) return Astro.redirect('/boards');

const allPapers = await getCollection('pastPapers');
const allGazettes = await getCollection('gazettes');

const papers = allPapers.filter((p: any) => p.data.bise === bise.name && (p.data.boards || []).includes(board.name));
const gazettes = allGazettes.filter((g: any) => g.data.bise === bise.name && (g.data.boards || []).includes(board.name));

// Classes with content
const classSet = new Set<string>();
[...papers, ...gazettes].forEach((i: any) => classSet.add(i.data.class));
const classes = [...classSet].sort((a, b) => Number(a) - Number(b));

// Fallback: if no content yet, still offer Class 9 & 10
const displayClasses = classes.length > 0 ? classes : ['9', '10'];

// Count per class
const countFor = (c: string) =>
  papers.filter((p: any) => p.data.class === c).length +
  gazettes.filter((g: any) => g.data.class === c).length;
---
<BaseLayout
  title={`${bise.name} Board — Class 9 & 10 Past Papers & Gazettes | Parhayi`}
  description={`Download past papers and result gazettes for ${bise.name} Board (${board.full}). Class 9 and Class 10, 2018 to 2026. Free PDFs.`}
>
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/boards')} class="hover:text-[#1d4ed8]">Boards</a>
        <span>/</span>
        <a href={url(`/board/${board.slug}`)} class="hover:text-[#1d4ed8]">{board.name}</a>
        <span>/</span>
        <span class="text-slate-500">{bise.name}</span>
      </nav>
      <div class="max-w-2xl">
        <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">{bise.name} Board</h1>
        <p class="mt-3 text-base text-slate-600">
          {board.name} · {papers.length} past papers · {gazettes.length} gazettes
        </p>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
    <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Pick your class</h2>
    <p class="mt-2 text-sm text-slate-500">Past papers and result gazettes for {bise.name} Board.</p>

    <div class="mt-6 grid grid-cols-1 gap-2.5 sm:grid-cols-2 lg:grid-cols-3">
      {displayClasses.map(c => (
        <a href={url(`/board/${board.slug}/${bise.slug}/class-${c}`)} class="row group">
          <span class="tile">
            <Icon name="graduation-cap" size={19} strokeWidth={2.2} />
          </span>
          <div class="min-w-0 flex-1">
            <div class="row-title">Class {c}</div>
          </div>
          <Icon name="arrow-right" size={15} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
        </a>
      ))}
    </div>

    <div class="mt-12 rounded-xl border border-slate-200 bg-white p-6">
      <p class="text-sm leading-relaxed text-slate-600">
        <strong class="text-slate-900">Note:</strong> Textbooks and syllabus are identical across all {board.name} BISEs. Only past papers and result gazettes are board-specific. <a href={url(`/board/${board.slug}`)} class="font-bold text-[#1d4ed8] hover:underline">Browse shared {board.name} resources →</a>
      </p>
    </div>
  </div>
</BaseLayout>
ASTRO

# ── Class hub under BISE ──
cat > 'src/pages/board/[board]/[bise]/[class]/index.astro' <<'ASTRO'
---
import BaseLayout from '../../../../../layouts/BaseLayout.astro';
import Icon from '../../../../../components/Icon.astro';
import { url } from '../../../../../lib/url';
import { BOARDS, boardBySlug } from '../../../../../lib/boards';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const paths: any[] = [];
  for (const board of BOARDS) {
    if (!board.biseAware) continue;
    for (const bise of board.bises) {
      for (const cls of ['9', '10']) {
        paths.push({ params: { board: board.slug, bise: bise.slug, class: `class-${cls}` } });
      }
    }
  }
  return paths;
}

const { board: boardSlug, bise: biseSlug, class: classParam } = Astro.params;
const cls = String(classParam).replace(/^class-/, '');
const board = boardBySlug(boardSlug!);
const bise = board?.bises.find(b => b.slug === biseSlug);
if (!board || !bise) return Astro.redirect('/boards');

const allPapers = await getCollection('pastPapers');
const allGazettes = await getCollection('gazettes');

const papers = allPapers.filter((p: any) =>
  p.data.bise === bise.name && p.data.class === cls && (p.data.boards || []).includes(board.name)
);
const gazettes = allGazettes.filter((g: any) =>
  g.data.bise === bise.name && g.data.class === cls && (g.data.boards || []).includes(board.name)
);

// Subjects available
const subjectSet = new Set<string>();
papers.forEach((p: any) => subjectSet.add(p.data.subject));
const subjects = [...subjectSet].sort();

const section = [
  { slug: 'past-papers', label: 'Past Papers', icon: 'scroll-text', count: papers.length },
  { slug: 'gazettes',    label: 'Result Gazettes', icon: 'newspaper', count: gazettes.length },
].filter(s => s.count > 0);
---
<BaseLayout
  title={`${bise.name} Board Class ${cls} — Past Papers & Result Gazettes | Parhayi`}
  description={`All Class ${cls} past papers and result gazettes for ${bise.name} Board (${board.full}). Download free PDFs, 2018 to 2026.`}
>
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/boards')} class="hover:text-[#1d4ed8]">Boards</a>
        <span>/</span>
        <a href={url(`/board/${board.slug}`)} class="hover:text-[#1d4ed8]">{board.name}</a>
        <span>/</span>
        <a href={url(`/board/${board.slug}/${bise.slug}`)} class="hover:text-[#1d4ed8]">{bise.name}</a>
        <span>/</span>
        <span class="text-slate-500">Class {cls}</span>
      </nav>
      <div class="max-w-2xl">
        <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">Class {cls} · {bise.name}</h1>
        <p class="mt-3 text-base text-slate-600">
          {papers.length} past papers · {gazettes.length} gazettes
        </p>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
    <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Board-specific resources</h2>
    <p class="mt-2 text-sm text-slate-500">Unique to {bise.name} Board.</p>
    <div class="mt-6 grid grid-cols-1 gap-2.5 sm:grid-cols-2 lg:grid-cols-3">
      {section.map(s => (
        <a href={url(`/board/${board.slug}/${bise.slug}/class-${cls}/${s.slug}`)} class="row group">
          <span class="tile">
            <Icon name={s.icon} size={18} strokeWidth={2.2} />
          </span>
          <div class="min-w-0 flex-1">
            <div class="row-title">{s.label}</div>
          </div>
          <Icon name="arrow-right" size={15} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
        </a>
      ))}
    </div>

    {subjects.length > 0 && (
      <>
        <h2 class="mt-12 text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Past papers by subject</h2>
        <div class="mt-6 grid grid-cols-1 gap-2.5 sm:grid-cols-2 lg:grid-cols-3">
          {subjects.map(s => {
            const sSlug = s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
            return (
              <a href={url(`/board/${board.slug}/${bise.slug}/class-${cls}/past-papers`)} class="row group">
                <span class="tile"><Icon name="scroll-text" size={18} strokeWidth={2.2} /></span>
                <div class="min-w-0 flex-1">
                  <div class="row-title">{s}</div>
                </div>
                <Icon name="arrow-right" size={15} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
              </a>
            );
          })}
        </div>
      </>
    )}

    <div class="mt-12 rounded-xl border border-slate-200 bg-white p-6">
      <h3 class="text-sm font-extrabold text-slate-900">Shared resources</h3>
      <p class="mt-2 text-sm text-slate-600">
        Notes, textbooks, quizzes and guess papers are identical across all {board.name} boards. These are available at the province level.
      </p>
      <div class="mt-4 flex flex-wrap gap-2">
        <a href={url(`/board/${board.slug}/class-${cls}/notes`)} class="btn btn-outline text-xs">Notes</a>
        <a href={url(`/board/${board.slug}/class-${cls}/books`)} class="btn btn-outline text-xs">Books</a>
        <a href={url(`/board/${board.slug}/class-${cls}/quizzes`)} class="btn btn-outline text-xs">Quizzes</a>
        <a href={url(`/board/${board.slug}/class-${cls}/guess-papers`)} class="btn btn-outline text-xs">Guess Papers</a>
      </div>
    </div>

    <div class="mt-10">
      <a href={url(`/board/${board.slug}/${bise.slug}`)} class="inline-flex items-center gap-2 text-sm font-semibold text-slate-500 hover:text-[#1d4ed8]">
        <Icon name="arrow-left" size={16} strokeWidth={2.4} /> Back to {bise.name}
      </a>
    </div>
  </div>
</BaseLayout>
ASTRO

# ── Type list under BISE (past-papers, gazettes) ──
cat > 'src/pages/board/[board]/[bise]/[class]/[type].astro' <<'ASTRO'
---
import BaseLayout from '../../../../../../layouts/BaseLayout.astro';
import Icon from '../../../../../../components/Icon.astro';
import { url } from '../../../../../../lib/url';
import { BOARDS, boardBySlug } from '../../../../../../lib/boards';
import { getCollection } from 'astro:content';

const TYPES = ['past-papers', 'gazettes'];

export async function getStaticPaths() {
  const paths: any[] = [];
  for (const board of BOARDS) {
    if (!board.biseAware) continue;
    for (const bise of board.bises) {
      for (const cls of ['9', '10']) {
        for (const t of TYPES) {
          paths.push({ params: { board: board.slug, bise: bise.slug, class: `class-${cls}`, type: t } });
        }
      }
    }
  }
  return paths;
}

const { board: boardSlug, bise: biseSlug, class: classParam, type: typeSlug } = Astro.params;
const cls = String(classParam).replace(/^class-/, '');
const board = boardBySlug(boardSlug!);
const bise = board?.bises.find(b => b.slug === biseSlug);
if (!board || !bise || !TYPES.includes(typeSlug!)) return Astro.redirect('/boards');

const isGazette = typeSlug === 'gazettes';
const collection = isGazette ? await getCollection('gazettes') : await getCollection('pastPapers');
const typeLabel = isGazette ? 'Result Gazettes' : 'Past Papers';
const iconName = isGazette ? 'newspaper' : 'scroll-text';
const basePath = isGazette ? 'gazettes' : 'past-papers';

const items = collection
  .filter((i: any) =>
    i.data.bise === bise.name &&
    i.data.class === cls &&
    (i.data.boards || []).includes(board.name)
  )
  .sort((a: any, b: any) => {
    if (isGazette) return (b.data.year || 0) - (a.data.year || 0);
    if (a.data.subject !== b.data.subject) return a.data.subject.localeCompare(b.data.subject);
    return (b.data.year || 0) - (a.data.year || 0);
  });

// Group by subject for papers, flat for gazettes
const bySubject = new Map<string, any[]>();
if (!isGazette) {
  items.forEach((i: any) => {
    const k = i.data.subject;
    if (!bySubject.has(k)) bySubject.set(k, []);
    bySubject.get(k)!.push(i);
  });
}
const subjects = [...bySubject.keys()].sort();
---
<BaseLayout
  title={`${bise.name} Board Class ${cls} ${typeLabel} — 2018 to 2026 | Parhayi`}
  description={`All Class ${cls} ${typeLabel.toLowerCase()} for ${bise.name} Board (${board.full}). Free downloads, from 2018 to 2026.`}
>
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/boards')} class="hover:text-[#1d4ed8]">Boards</a>
        <span>/</span>
        <a href={url(`/board/${board.slug}`)} class="hover:text-[#1d4ed8]">{board.name}</a>
        <span>/</span>
        <a href={url(`/board/${board.slug}/${bise.slug}`)} class="hover:text-[#1d4ed8]">{bise.name}</a>
        <span>/</span>
        <a href={url(`/board/${board.slug}/${bise.slug}/class-${cls}`)} class="hover:text-[#1d4ed8]">Class {cls}</a>
        <span>/</span>
        <span class="text-slate-500">{typeLabel}</span>
      </nav>
      <div class="max-w-2xl">
        <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">Class {cls} {typeLabel}</h1>
        <p class="mt-3 text-base text-slate-600">
          {bise.name} Board · {items.length} {items.length === 1 ? 'item' : 'items'}
        </p>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
    {items.length === 0 ? (
      <div class="rounded-xl border border-dashed border-slate-300 bg-white p-12 text-center">
        <p class="text-sm font-bold text-slate-900">Nothing here yet</p>
        <p class="mt-1 text-xs text-slate-500">{typeLabel} for {bise.name} Class {cls} are coming soon.</p>
        <a href={url(`/board/${board.slug}/${bise.slug}/class-${cls}`)} class="mt-5 inline-flex items-center gap-1.5 rounded-lg bg-[#1d4ed8] px-4 py-2.5 text-sm font-bold text-white hover:bg-[#1e3a8a]">Back to Class {cls}</a>
      </div>
    ) : isGazette ? (
      <div class="grid grid-cols-1 gap-2.5 sm:grid-cols-2">
        {items.map((item: any) => (
          <a href={url(`/${basePath}/${item.id}`)} class="row group">
            <span class="tile"><Icon name={iconName} size={18} strokeWidth={2.2} /></span>
            <div class="min-w-0 flex-1">
              <div class="row-title">{item.data.title}</div>
              <div class="mt-1 flex flex-wrap gap-1.5">
                {item.data.year && <span class="inline-flex items-center rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate-600">{item.data.year}</span>}
              </div>
            </div>
            <Icon name="arrow-right" size={15} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
          </a>
        ))}
      </div>
    ) : (
      <>
        {subjects.map(subject => (
          <section class="mb-12">
            <div class="mb-4 flex items-end justify-between gap-4">
              <h2 class="text-lg font-extrabold tracking-tight text-slate-900 sm:text-xl">{subject}</h2>
              <span class="text-xs font-semibold uppercase tracking-wider text-slate-400">
                {bySubject.get(subject)!.length} {bySubject.get(subject)!.length === 1 ? 'paper' : 'papers'}
              </span>
            </div>
            <div class="grid grid-cols-1 gap-2.5 sm:grid-cols-2">
              {bySubject.get(subject)!.map((item: any) => (
                <a href={url(`/${basePath}/${item.id}`)} class="row group">
                  <span class="tile"><Icon name={iconName} size={18} strokeWidth={2.2} /></span>
                  <div class="min-w-0 flex-1">
                    <div class="row-title">{subject} — {item.data.year}</div>
                  </div>
                  <Icon name="arrow-right" size={15} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
                </a>
              ))}
            </div>
          </section>
        ))}
      </>
    )}

    <div class="mt-10">
      <a href={url(`/board/${board.slug}/${bise.slug}/class-${cls}`)} class="inline-flex items-center gap-2 text-sm font-semibold text-slate-500 hover:text-[#1d4ed8]">
        <Icon name="arrow-left" size={16} strokeWidth={2.4} /> Back to Class {cls}
      </a>
    </div>
  </div>
</BaseLayout>
ASTRO

echo "  ✓ BISE route tree rebuilt (all provinces)"

# ─────────────────────────────────────────────
#  3. Ensure /board/[board]/[class]/[subject].astro handles BISE-aware boards correctly
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re
p = pathlib.Path('src/pages/board/[board]/[class]/[subject].astro')
s = p.read_text()

# Replace PUNJAB_BISES with getBISEsForProvince
s = s.replace('PUNJAB_BISES', 'getBISEsForProvince(String(boardSlug))')
s = s.replace("boardSlug === 'punjab'", "hasBISEs(String(boardSlug))")

# Ensure imports
if 'getBISEsForProvince' not in s:
    s = re.sub(
        r"^import .*from '\.\./\.\./\.\./\.\./lib/boards';",
        "import { getBISEsForProvince, hasBISEs } from '../../../../lib/boards';",
        s, count=1, flags=re.MULTILINE
    )

p.write_text(s)
print('  ✓ [subject].astro updated for all provinces')
PY

# ─────────────────────────────────────────────
#  4. Also fix the province page BISE links
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re
p = pathlib.Path('src/pages/board/[board]/index.astro')
s = p.read_text()

# Make sure BISE links use current slug, not hardcoded 'punjab'
s = s.replace("url(`/board/punjab/${bise.slug}`)", "url(`/board/${slug}/${bise.slug}`)")
s = s.replace("url('/board/punjab')", "url(`/board/${slug}`)")

p.write_text(s)
print('  ✓ province page links fixed')
PY

# ─────────────────────────────────────────────
#  5. Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding (2200+ pages, may take 2-3 min)..."
npm run build 2>&1 | tail -8

echo ""
echo "════════════════════════════════════════════"
echo "  Done."
echo ""
echo "  Preview:"
echo "    pkill -f 'astro dev' || true"
echo "    npm run dev"
echo ""
echo "  Test these URLs — all should work without redirects:"
echo "    /board/punjab/rawalpindi/class-9"
echo "    /board/punjab/rawalpindi/class-9/past-papers"
echo "    /board/punjab/rawalpindi/class-10/gazettes"
echo "    /board/sindh/karachi/class-10"
echo "    /board/sindh/karachi/class-10/past-papers"
echo "    /board/kpk/peshawar/class-9/past-papers"
echo "    /board/balochistan/quetta/class-10/gazettes"
echo "    /board/ajk/mirpur/class-9/past-papers"
echo ""
echo "  What was fixed:"
echo "    · biseBySlug() called with wrong signature — fixed"
echo "    · BISE route tree now works for ALL provinces"
echo "    · Sindh/KPK/Balochistan/AJK BISE cards now resolve"
echo "    · No more redirect chains"
echo "    · Dedicated type pages for past-papers and gazettes per BISE"
echo "════════════════════════════════════════════"