#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Wiring filters into list pages"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  1. Rebuild [type].astro with filter bar
# ─────────────────────────────────────────────
cat > 'src/pages/board/[board]/[bise]/[class]/[type].astro' <<'ASTRO'
---
import BaseLayout from '../../../../../layouts/BaseLayout.astro';
import Icon from '../../../../../components/Icon.astro';
import PageFilter from '../../../../../components/PageFilter.astro';
import { url } from '../../../../../lib/url';
import { BOARDS, boardBySlug } from '../../../../../lib/boards';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const paths: any[] = [];
  for (const board of BOARDS) {
    if (!board.biseAware) continue;
    for (const bise of board.bises) {
      for (const cls of ['9', '10']) {
        for (const t of ['past-papers', 'gazettes']) {
          paths.push({
            params: { board: board.slug, bise: bise.slug, class: `class-${cls}`, type: t },
          });
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
const valid = !!(board && bise && (typeSlug === 'past-papers' || typeSlug === 'gazettes'));

const isGazette = typeSlug === 'gazettes';
const typeLabel = isGazette ? 'Result Gazettes' : 'Past Papers';
const iconName = isGazette ? 'newspaper' : 'scroll-text';
const basePath = isGazette ? 'gazettes' : 'past-papers';

let items: any[] = [];
if (valid) {
  const collection = isGazette ? await getCollection('gazettes') : await getCollection('pastPapers');
  items = collection
    .filter((i: any) =>
      i.data.bise === bise!.name &&
      i.data.class === cls &&
      (i.data.boards || []).includes(board!.name)
    )
    .sort((a: any, b: any) => (b.data.year || 0) - (a.data.year || 0));
}

// Build filter option lists from data
const years = [...new Set(items.map((i: any) => String(i.data.year || '')))]
  .filter(Boolean)
  .sort((a, b) => Number(b) - Number(a));
const subjects = [...new Set(items.map((i: any) => i.data.subject).filter(Boolean))].sort();

const filterDefs = isGazette
  ? [{ label: 'Year', key: 'year', options: years }]
  : [
      { label: 'Subject', key: 'subject', options: subjects },
      { label: 'Year', key: 'year', options: years },
    ];
---
{valid ? (
<BaseLayout
  title={`${bise!.name} Board Class ${cls} ${typeLabel} — 2018 to 2026 | Parhayi`}
  description={`All Class ${cls} ${typeLabel.toLowerCase()} for ${bise!.name} Board (${board!.full}). Filter by subject and year. Free PDF downloads.`}
>
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/boards')} class="hover:text-[#1d4ed8]">Boards</a>
        <span>/</span>
        <a href={url(`/board/${board!.slug}`)} class="hover:text-[#1d4ed8]">{board!.name}</a>
        <span>/</span>
        <a href={url(`/board/${board!.slug}/${bise!.slug}`)} class="hover:text-[#1d4ed8]">{bise!.name}</a>
        <span>/</span>
        <a href={url(`/board/${board!.slug}/${bise!.slug}/class-${cls}`)} class="hover:text-[#1d4ed8]">Class {cls}</a>
        <span>/</span>
        <span class="text-slate-500">{typeLabel}</span>
      </nav>
      <div class="max-w-2xl">
        <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">Class {cls} {typeLabel}</h1>
        <p class="mt-3 text-base text-slate-600">
          {bise!.name} Board · {items.length} {items.length === 1 ? 'item' : 'items'}
        </p>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[1200px] px-5 py-10 sm:px-7 lg:px-10 lg:py-12">
    {items.length === 0 ? (
      <div class="rounded-xl border border-dashed border-slate-300 bg-white p-12 text-center">
        <p class="text-sm font-bold text-slate-900">Nothing here yet</p>
        <p class="mt-1 text-xs text-slate-500">{typeLabel} for {bise!.name} Class {cls} are coming soon.</p>
        <a href={url(`/board/${board!.slug}/${bise!.slug}/class-${cls}`)} class="mt-5 inline-flex items-center gap-1.5 rounded-lg bg-[#1d4ed8] px-4 py-2.5 text-sm font-bold text-white hover:bg-[#1e3a8a]">
          Back to Class {cls}
        </a>
      </div>
    ) : (
      <>
        <PageFilter
          placeholder={`Search ${typeLabel.toLowerCase()} — type subject, year or keyword…`}
          filters={filterDefs}
        />

        <div class="grid grid-cols-1 gap-2.5 sm:grid-cols-2">
          {items.map((item: any) => (
            <a
              href={url(`/${basePath}/${item.id}`)}
              class="row group"
              data-filterable
              data-search={`${item.data.title} ${item.data.subject || ''} ${item.data.year || ''} ${bise!.name}`}
              data-year={item.data.year}
              data-subject={item.data.subject || ''}
            >
              <span class="tile">
                <Icon name={iconName} size={18} strokeWidth={2.2} />
              </span>
              <div class="min-w-0 flex-1">
                <div class="row-title">{item.data.title}</div>
                <div class="mt-1 flex flex-wrap gap-1.5">
                  {item.data.subject && (
                    <span class="inline-flex items-center rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate-600">{item.data.subject}</span>
                  )}
                  {item.data.year && (
                    <span class="inline-flex items-center rounded bg-[#eff4ff] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#1d4ed8]">{item.data.year}</span>
                  )}
                </div>
              </div>
              <Icon name="arrow-right" size={15} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
            </a>
          ))}
        </div>
      </>
    )}

    <div class="mt-10">
      <a href={url(`/board/${board!.slug}/${bise!.slug}/class-${cls}`)} class="inline-flex items-center gap-2 text-sm font-semibold text-slate-500 hover:text-[#1d4ed8]">
        <Icon name="arrow-left" size={16} strokeWidth={2.4} /> Back to Class {cls}
      </a>
    </div>
  </div>
</BaseLayout>
) : (
<BaseLayout title="Not found — Parhayi">
  <div class="mx-auto max-w-3xl px-5 py-20 text-center">
    <h1 class="text-3xl font-extrabold text-slate-900">Page not found</h1>
    <p class="mt-3 text-sm text-slate-500">This board or exam body doesn't exist on Parhayi.</p>
    <a href={url('/boards')} class="mt-6 inline-flex items-center gap-1.5 rounded-lg bg-[#1d4ed8] px-4 py-2.5 text-sm font-bold text-white hover:bg-[#1e3a8a]">
      Browse all boards
    </a>
  </div>
</BaseLayout>
)}
ASTRO

echo "  ✓ [type].astro — filter bar wired"

# ─────────────────────────────────────────────
#  2. Add filter to subject hub pages (past-papers list within a subject)
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re

p = pathlib.Path('src/pages/board/[board]/[class]/[subject].astro')
s = p.read_text()

# Add PageFilter import
if 'PageFilter' not in s:
    s = s.replace(
        "import Icon from '../../../../components/Icon.astro';",
        "import Icon from '../../../../components/Icon.astro';\nimport PageFilter from '../../../../components/PageFilter.astro';"
    )

# Add data attributes on past-paper rows so they're filterable
# Find the pattern that renders group.items (papers)
s = s.replace(
    '<a href={url(`${typeData.base}/${item.id}`)} class="row group">',
    '<a href={url(`${typeData.base}/${item.id}`)} class="row group" data-filterable data-search={`${item.data.title} ${item.data.year || ""}`} data-year={item.data.year}>'
)

p.write_text(s)
print('  ✓ [subject].astro — filterable rows')
PY

# ─────────────────────────────────────────────
#  3. Add filter to /notes, /quizzes, /books
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re

# Notes
p = pathlib.Path('src/pages/notes/index.astro')
if p.exists():
    s = p.read_text()
    if 'PageFilter' not in s:
        s = s.replace(
            "import Icon from '../../components/Icon.astro';",
            "import Icon from '../../components/Icon.astro';\nimport PageFilter from '../../components/PageFilter.astro';"
        )
        # Add filter bar after the header div, before the class sections
        s = s.replace(
            '<div id="note-list" class="space-y-10">',
            '''<PageFilter placeholder="Search notes — subject, chapter or class…" filters={[{ label: 'Class', key: 'class', options: sortedClasses }]} />

    <div id="note-list" class="space-y-10">'''
        )
        # Mark rows filterable
        s = s.replace(
            '<a href={url(`/notes/${n.id}`)} class="row group">',
            '<a href={url(`/notes/${n.id}`)} class="row group" data-filterable data-search={`${n.data.title} ${n.data.subject} ${cls}`} data-class={cls}>'
        )
        # Mark sections
        s = s.replace(
            '<section data-class={cls}>',
            '<section data-class={cls} data-filter-section>'
        )
        p.write_text(s)
        print('  ✓ /notes — filter bar')

# Quizzes
p = pathlib.Path('src/pages/quizzes/index.astro')
if p.exists():
    s = p.read_text()
    if 'PageFilter' not in s:
        s = s.replace(
            "import Icon from '../../components/Icon.astro';",
            "import Icon from '../../components/Icon.astro';\nimport PageFilter from '../../components/PageFilter.astro';"
        )
        s = s.replace(
            '<div id="quiz-list" class="space-y-10">',
            '''<PageFilter placeholder="Search quizzes — subject, class or keyword…" filters={[{ label: 'Class', key: 'class', options: sortedClasses }]} />

    <div id="quiz-list" class="space-y-10">'''
        )
        s = s.replace(
            '<a href={url(`/quizzes/${q.id}`)} class="row group">',
            '<a href={url(`/quizzes/${q.id}`)} class="row group" data-filterable data-search={`${q.data.title} ${q.data.subject} ${cls}`} data-class={cls}>'
        )
        s = s.replace(
            '<section data-class={cls}>',
            '<section data-class={cls} data-filter-section>'
        )
        p.write_text(s)
        print('  ✓ /quizzes — filter bar')

# Books
p = pathlib.Path('src/pages/books/index.astro')
if p.exists():
    s = p.read_text()
    if 'PageFilter' not in s:
        s = s.replace(
            "import Icon from '../../components/Icon.astro';",
            "import Icon from '../../components/Icon.astro';\nimport PageFilter from '../../components/PageFilter.astro';"
        )
        s = s.replace(
            '<div id="book-list" class="space-y-10">',
            '''<PageFilter placeholder="Search textbooks — subject, class or board…" filters={[{ label: 'Class', key: 'class', options: sortedClasses }, { label: 'Board', key: 'board', options: boards }]} />

    <div id="book-list" class="space-y-10">'''
        )
        s = s.replace(
            '<a href={url(`/books/${b.id}`)} class="row group"\n                   data-board={(b.data.boards || []).join(\'|\')}>',
            '<a href={url(`/books/${b.id}`)} class="row group" data-filterable data-search={`${b.data.title} ${b.data.subject} ${b.data.boards?.join(" ")}`} data-class={cls} data-board={(b.data.boards || [])[0]}>'
        )
        s = s.replace(
            '<section data-class={cls}>',
            '<section data-class={cls} data-filter-section>'
        )
        p.write_text(s)
        print('  ✓ /books — filter bar')
PY

# ─────────────────────────────────────────────
#  4. Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -6

echo ""
echo "════════════════════════════════════════════"
echo "  Done."
echo ""
echo "  Restart dev:"
echo "    pkill -f 'astro dev' || true"
echo "    npm run dev"
echo ""
echo "  Test these URLs:"
echo "    /board/punjab/faisalabad/class-10/past-papers"
echo "    → filter by subject, year, or search keyword"
echo ""
echo "    /board/punjab/lahore/class-10/gazettes"
echo "    → filter by year"
echo ""
echo "    /notes"
echo "    → search + class filter"
echo ""
echo "    /books"
echo "    → search + class + board filter"
echo ""
echo "  Features:"
echo "    · Instant on-page search (50ms debounce)"
echo "    · Multi-facet filters (subject + year + class etc.)"
echo "    · URL sync — share filtered views (/?q=physics&year=2024)"
echo "    · Live result count"
echo "    · Empty state when no matches"
echo "    · Section headers hide when all their rows are filtered out"
echo "════════════════════════════════════════════"