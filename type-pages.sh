#!/bin/bash
set -e

echo "Adding type-list pages..."

# ═══════════════════════════════════════════════
#  1. Add getClassTypeContent to boardContent.ts
# ═══════════════════════════════════════════════
python3 - <<'PY'
import pathlib
p = pathlib.Path("src/lib/boardContent.ts")
s = p.read_text()

if "getClassTypeContent" in s:
    print("  getClassTypeContent already present")
    raise SystemExit(0)

addition = '''

const TYPE_MAP: Record<string, { label: string; icon: string; collection: string; base: string }> = {
  'notes':            { label: 'Notes',           icon: 'file-text',     collection: 'notes',           base: '/notes' },
  'quizzes':          { label: 'Quizzes',         icon: 'circle-help',   collection: 'quizzes',         base: '/quizzes' },
  'books':            { label: 'Books',           icon: 'book-marked',   collection: 'books',           base: '/books' },
  'past-papers':      { label: 'Past Papers',     icon: 'scroll-text',   collection: 'pastPapers',      base: '/past-papers' },
  'guess-papers':     { label: 'Guess Papers',    icon: 'sparkles',      collection: 'guessPapers',     base: '/guess-papers' },
  'pairing-schemes':  { label: 'Pairing Schemes', icon: 'list',          collection: 'pairingSchemes',  base: '/pairing-schemes' },
  'gazettes':         { label: 'Result Gazettes', icon: 'newspaper',     collection: 'gazettes',        base: '/gazettes' },
};

export const TYPE_SLUGS = Object.keys(TYPE_MAP);

export async function getClassTypeContent(boardSlug: string, cls: string, typeSlug: string) {
  const board = boardBySlug(boardSlug);
  const cfg = TYPE_MAP[typeSlug];
  if (!board || !cfg) return null;

  const all = await loadAll();
  const collection = (all as any)[cfg.collection] as any[];
  const items = collection.filter(
    (i: any) => itemBoards(i.data).includes(board.name) && i.data.class === cls
  );

  // Group by subject when possible (past-papers, notes, quizzes, books, guess-papers)
  const subjectMap = new Map<string, any[]>();
  let hasSubjects = false;
  for (const i of items) {
    if (i.data.subject) {
      hasSubjects = true;
      const key = i.data.subject;
      if (!subjectMap.has(key)) subjectMap.set(key, []);
      subjectMap.get(key)!.push(i);
    }
  }
  const groups = hasSubjects
    ? [...subjectMap.entries()].map(([subject, items]) => ({ subject, items })).sort((a, b) => a.subject.localeCompare(b.subject))
    : null;

  // For year-based types, sort descending
  if (!hasSubjects) {
    items.sort((a: any, b: any) => (b.data.year || 0) - (a.data.year || 0));
  }

  return { board, class: cls, type: typeSlug, ...cfg, items, groups };
}
'''

p.write_text(s + addition)
print("  boardContent.ts updated")
PY

# ═══════════════════════════════════════════════
#  2. Rewrite [subject].astro to handle both
#     content types and subject hubs
# ═══════════════════════════════════════════════
cat > 'src/pages/board/[board]/[class]/[subject].astro' <<'ASTRO'
---
import BaseLayout from '../../../../layouts/BaseLayout.astro';
import Icon from '../../../../components/Icon.astro';
import { url } from '../../../../lib/url';
import {
  getSubjectContent,
  getClassTypeContent,
  getAllSubjectPaths,
  getAllClassPaths,
  TYPE_SLUGS,
} from '../../../../lib/boardContent';

export async function getStaticPaths() {
  const subjectPaths = await getAllSubjectPaths();
  const classPaths = await getAllClassPaths();
  const paths: any[] = [];
  for (const p of subjectPaths) {
    paths.push({ params: { board: p.board, class: `class-${p.class}`, subject: p.subject } });
  }
  for (const c of classPaths) {
    for (const t of TYPE_SLUGS) {
      paths.push({ params: { board: c.board, class: `class-${c.class}`, subject: t } });
    }
  }
  return paths;
}

const { board: boardSlug, class: classParam, subject: subjectSlug } = Astro.params;
const cls = String(classParam).replace(/^class-/, '');
const isType = TYPE_SLUGS.includes(subjectSlug!);

const typeData = isType ? await getClassTypeContent(boardSlug!, cls, subjectSlug!) : null;
const subjectData = !isType ? await getSubjectContent(boardSlug!, cls, subjectSlug!) : null;

const board = (typeData?.board) || (subjectData?.board);
const totalItems = (typeData?.items?.length) || 0;
---
{board && typeData ? (
<BaseLayout
  title={`${board.name} Class ${cls} ${typeData.label} | TaleemHub`}
  description={`All ${typeData.label.toLowerCase()} for ${board.full} Class ${cls}. Free downloads, organized by subject and year.`}
>
  <div class="mx-auto max-w-[1320px] px-4 pt-10 sm:px-6 sm:pt-14 lg:px-8">
    <nav class="mb-6 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-neutral-400">
      <a href={url('/boards')} class="hover:text-[#0620ed]">Boards</a>
      <span>/</span>
      <a href={url(`/board/${boardSlug}`)} class="hover:text-[#0620ed]">{board.name}</a>
      <span>/</span>
      <a href={url(`/board/${boardSlug}/class-${cls}`)} class="hover:text-[#0620ed]">Class {cls}</a>
      <span>/</span>
      <span class="text-neutral-500">{typeData.label}</span>
    </nav>

    <div class="rounded-3xl border border-[#0620ed] bg-gradient-to-br from-[#110176] via-[#0620ed] to-[#265bf6] p-8 text-white sm:p-10">
      <div class="flex flex-wrap gap-1.5">
        <span class="inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider">
          <Icon name="graduation-cap" size={13} strokeWidth={2.4} /> {board.name}
        </span>
        <span class="inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider">
          Class {cls}
        </span>
      </div>
      <h1 class="mt-4 text-4xl font-extrabold leading-tight tracking-tight sm:text-5xl">{typeData.label}</h1>
      <p class="mt-2 text-blue-100">{totalItems} {totalItems === 1 ? 'item' : 'items'}</p>
    </div>

    {totalItems === 0 ? (
      <div class="mt-12 rounded-2xl border border-dashed border-neutral-300 bg-white p-12 text-center">
        <p class="text-base font-bold text-neutral-900">Nothing here yet</p>
        <p class="mt-1 text-sm text-neutral-500">{typeData.label} for Class {cls} {board.name} are coming soon.</p>
        <a href={url(`/board/${boardSlug}/class-${cls}`)} class="mt-5 inline-flex items-center gap-1.5 rounded-xl bg-[#0620ed] px-4 py-2.5 text-sm font-bold text-white hover:bg-[#110176]">
          Back to Class {cls}
        </a>
      </div>
    ) : typeData.groups ? (
      <>
        {typeData.groups.map(group => (
          <section class="mt-12">
            <div class="mb-5 flex items-center gap-3">
              <span class="grid h-10 w-10 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
                <Icon name={typeData.icon} size={19} strokeWidth={2.2} />
              </span>
              <div>
                <h2 class="text-xl font-extrabold tracking-tight text-neutral-900">{group.subject}</h2>
                <p class="text-sm text-neutral-500">{group.items.length} {group.items.length === 1 ? 'item' : 'items'}</p>
              </div>
            </div>
            <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
              {group.items.map((item: any) => (
                <a href={url(`${typeData.base}/${item.id}`)} class="group flex items-center gap-4 rounded-2xl border border-neutral-200 bg-white p-4 transition-colors hover:border-[#0620ed]">
                  <span class="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
                    <Icon name={typeData.icon} size={17} strokeWidth={2.2} />
                  </span>
                  <div class="min-w-0 flex-1">
                    <h3 class="truncate text-sm font-bold text-neutral-900">{item.data.title}</h3>
                    <div class="mt-1.5 flex flex-wrap gap-1.5">
                      {item.data.year && <span class="rounded-md bg-neutral-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-neutral-600">{item.data.year}</span>}
                      <span class="rounded-md bg-[#eef2fe] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#0620ed]">Class {cls}</span>
                    </div>
                  </div>
                  <Icon name="chevron-right" size={15} strokeWidth={2.4} class="shrink-0 text-neutral-300 transition-transform group-hover:translate-x-0.5 group-hover:text-[#0620ed]" />
                </a>
              ))}
            </div>
          </section>
        ))}
      </>
    ) : (
      <section class="mt-12 pb-16">
        <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
          {typeData.items.map((item: any) => (
            <a href={url(`${typeData.base}/${item.id}`)} class="group flex items-center gap-4 rounded-2xl border border-neutral-200 bg-white p-4 transition-colors hover:border-[#0620ed]">
              <span class="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
                <Icon name={typeData.icon} size={17} strokeWidth={2.2} />
              </span>
              <div class="min-w-0 flex-1">
                <h3 class="truncate text-sm font-bold text-neutral-900">{item.data.title}</h3>
                <div class="mt-1.5 flex flex-wrap gap-1.5">
                  {item.data.year && <span class="rounded-md bg-neutral-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-neutral-600">{item.data.year}</span>}
                </div>
              </div>
              <Icon name="chevron-right" size={15} strokeWidth={2.4} class="shrink-0 text-neutral-300 transition-transform group-hover:translate-x-0.5 group-hover:text-[#0620ed]" />
            </a>
          ))}
        </div>
      </section>
    )}

    <div class="mt-4 pb-20">
      <a href={url(`/board/${boardSlug}/class-${cls}`)} class="inline-flex items-center gap-2 text-sm font-semibold text-neutral-500 hover:text-[#0620ed]">
        <Icon name="arrow-left" size={16} strokeWidth={2.4} /> Back to Class {cls}
      </a>
    </div>
  </div>
</BaseLayout>
) : subjectData && subjectData.subject ? (
<BaseLayout
  title={`${subjectData.board.name} Class ${cls} ${subjectData.subject} | TaleemHub`}
  description={`All ${subjectData.subject} material for ${subjectData.board.full} Class ${cls}: notes, past papers, guess papers, quizzes and books.`}
>
  <div class="mx-auto max-w-[1320px] px-4 pt-10 sm:px-6 sm:pt-14 lg:px-8">
    <nav class="mb-6 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-neutral-400">
      <a href={url('/boards')} class="hover:text-[#0620ed]">Boards</a>
      <span>/</span>
      <a href={url(`/board/${boardSlug}`)} class="hover:text-[#0620ed]">{subjectData.board.name}</a>
      <span>/</span>
      <a href={url(`/board/${boardSlug}/class-${cls}`)} class="hover:text-[#0620ed]">Class {cls}</a>
      <span>/</span>
      <span class="text-neutral-500">{subjectData.subject}</span>
    </nav>

    <div class="rounded-3xl border border-[#0620ed] bg-gradient-to-br from-[#110176] via-[#0620ed] to-[#265bf6] p-8 text-white sm:p-10">
      <div class="flex flex-wrap gap-1.5">
        <span class="inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider">
          <Icon name="graduation-cap" size={13} strokeWidth={2.4} /> {subjectData.board.name}
        </span>
        <span class="inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider">
          Class {cls}
        </span>
      </div>
      <h1 class="mt-4 text-4xl font-extrabold leading-tight tracking-tight sm:text-5xl">{subjectData.subject}</h1>
    </div>

    {[
      { label: 'Notes',        icon: 'file-text',   items: subjectData.notes,       base: '/notes' },
      { label: 'Past Papers',  icon: 'scroll-text', items: subjectData.pastPapers,  base: '/past-papers' },
      { label: 'Guess Papers', icon: 'sparkles',    items: subjectData.guessPapers, base: '/guess-papers' },
      { label: 'Quizzes',      icon: 'circle-help', items: subjectData.quizzes,     base: '/quizzes' },
      { label: 'Books',        icon: 'book-marked', items: subjectData.books,       base: '/books' },
    ].filter(s => s.items.length > 0).map(sec => (
      <section class="mt-12">
        <div class="mb-5 flex items-center gap-3">
          <span class="grid h-10 w-10 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
            <Icon name={sec.icon} size={19} strokeWidth={2.2} />
          </span>
          <div>
            <h2 class="text-xl font-extrabold tracking-tight text-neutral-900">{sec.label}</h2>
            <p class="text-sm text-neutral-500">{sec.items.length} {sec.items.length === 1 ? 'item' : 'items'}</p>
          </div>
        </div>
        <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
          {sec.items.map((item: any) => (
            <a href={url(`${sec.base}/${item.id}`)} class="group flex items-center gap-4 rounded-2xl border border-neutral-200 bg-white p-4 transition-colors hover:border-[#0620ed]">
              <span class="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
                <Icon name={sec.icon} size={17} strokeWidth={2.2} />
              </span>
              <div class="min-w-0 flex-1">
                <h3 class="truncate text-sm font-bold text-neutral-900">{item.data.title}</h3>
                <div class="mt-1.5 flex flex-wrap gap-1.5">
                  {item.data.year && <span class="rounded-md bg-neutral-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-neutral-600">{item.data.year}</span>}
                </div>
              </div>
              <Icon name="chevron-right" size={15} strokeWidth={2.4} class="shrink-0 text-neutral-300 transition-transform group-hover:translate-x-0.5 group-hover:text-[#0620ed]" />
            </a>
          ))}
        </div>
      </section>
    ))}

    <div class="mt-12 pb-20">
      <a href={url(`/board/${boardSlug}/class-${cls}`)} class="inline-flex items-center gap-2 text-sm font-semibold text-neutral-500 hover:text-[#0620ed]">
        <Icon name="arrow-left" size={16} strokeWidth={2.4} /> Back to Class {cls}
      </a>
    </div>
  </div>
</BaseLayout>
) : (
<BaseLayout title="Not found — TaleemHub">
  <div class="mx-auto max-w-3xl px-4 pt-20 pb-20 text-center">
    <h1 class="text-2xl font-extrabold text-neutral-900">Not found</h1>
    <p class="mt-2 text-sm text-neutral-500">This page doesn't exist or has no content yet.</p>
    <a href={url('/boards')} class="mt-6 inline-flex items-center gap-1.5 rounded-xl bg-[#0620ed] px-4 py-2.5 text-sm font-bold text-white hover:bg-[#110176]">
      Browse all boards
    </a>
  </div>
</BaseLayout>
)}
ASTRO

echo "  [subject].astro rewritten"

# ═══════════════════════════════════════════════
#  3. Rebuild
# ═══════════════════════════════════════════════
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -15

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Push:"
echo ""
echo "    git add ."
echo "    git commit -m 'Add type-list pages for class content'"
echo "    git push"
echo ""
echo "  Then test:"
echo "    /board/punjab/class-9/past-papers"
echo "    /board/punjab/class-9/notes"
echo "    /board/punjab/class-9/quizzes"
echo "════════════════════════════════════════════"