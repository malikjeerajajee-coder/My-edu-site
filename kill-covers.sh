#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Force removing book covers everywhere"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  1. Kill dev server
# ─────────────────────────────────────────────
pkill -f 'astro dev' || true
sleep 1
echo "  ✓ Dev server stopped"

# ─────────────────────────────────────────────
#  2. Verify BookCover state
# ─────────────────────────────────────────────
echo ""
echo "▸ BookCover references in src/:"
grep -rn "BookCover" src/ 2>/dev/null || echo "  (none found — good)"

echo ""
echo "▸ book-cover CSS classes in src/:"
grep -rn "book-cover\|book-card\|book-cover-detail" src/ 2>/dev/null || echo "  (none found — good)"

# ─────────────────────────────────────────────
#  3. Hard delete BookCover component
# ─────────────────────────────────────────────
rm -f src/components/BookCover.astro
echo ""
echo "  ✓ BookCover.astro deleted (if it existed)"

# ─────────────────────────────────────────────
#  4. Rewrite /books index — guaranteed clean
# ─────────────────────────────────────────────
cat > src/pages/books/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import PageFilter from '../../components/PageFilter.astro';
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

    <div id="book-list" class="space-y-10">
      {sortedClasses.map(cls => {
        const items = byClass.get(cls)!;
        return (
          <section data-class={cls} data-filter-section>
            <div class="mb-4 flex items-end justify-between gap-4">
              <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Class {cls}</h2>
              <span class="text-xs font-semibold uppercase tracking-wider text-slate-400">
                {items.length} {items.length === 1 ? 'book' : 'books'}
              </span>
            </div>
            <div class="grid grid-cols-1 gap-2.5 sm:grid-cols-2">
              {items.map((b: any) => (
                <a
                  href={url(`/books/${b.id}`)}
                  class="row group"
                  data-filterable
                  data-search={`${b.data.title} ${b.data.subject} ${(b.data.boards || []).join(' ')} ${cls}`}
                  data-class={cls}
                  data-board={(b.data.boards || [])[0]}
                >
                  <span class="tile">
                    <Icon name="book-marked" size={18} strokeWidth={2.2} />
                  </span>
                  <div class="min-w-0 flex-1">
                    <div class="row-title">{b.data.title}</div>
                    <div class="mt-1 flex flex-wrap gap-1.5">
                      <span class="inline-flex items-center rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate-600">{b.data.subject}</span>
                      <span class="inline-flex items-center rounded bg-[#eff4ff] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#1d4ed8]">{b.data.boards?.[0] || 'Punjab'}</span>
                    </div>
                  </div>
                  <Icon name="arrow-right" size={15} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
                </a>
              ))}
            </div>
          </section>
        );
      })}
    </div>
  </div>
</BaseLayout>
ASTRO

echo "  ✓ /books — rewritten without covers"

# ─────────────────────────────────────────────
#  5. Rewrite /books/[slug] — guaranteed clean
# ─────────────────────────────────────────────
mkdir -p 'src/pages/books'
cat > 'src/pages/books/[...slug].astro' <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const books = await getCollection('books');
  return books.map((book: any) => ({ params: { slug: book.id }, props: { book } }));
}

const { book } = Astro.props;
const d = book.data;
---
<BaseLayout
  title={`${d.title} | Parhayi`}
  description={`Download ${d.title} — free PDF textbook for Pakistani students.`}
>
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[900px] px-5 pt-8 pb-8 sm:px-7 lg:px-10 lg:pt-10 lg:pb-10">
      <nav class="mb-5 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <a href={url('/books')} class="hover:text-[#1d4ed8]">Textbooks</a>
        <span>/</span>
        <span class="text-slate-500">Class {d.class} · {d.subject}</span>
      </nav>

      <div class="flex flex-wrap gap-1.5 mb-4">
        <span class="badge-soft">{d.subject}</span>
        <span class="badge-soft">Class {d.class}</span>
        {(d.boards || []).map((b: string) => (
          <span class="badge-soft">{b}</span>
        ))}
      </div>

      <h1 class="text-3xl font-extrabold leading-tight tracking-tight text-slate-900 sm:text-4xl">
        {d.title}
      </h1>

      {d.author && (
        <p class="mt-3 text-sm text-slate-600">Published by {d.author}</p>
      )}

      <a href={url(d.pdfUrl)} target="_blank" rel="noopener"
         class="mt-7 inline-flex items-center gap-2 rounded-lg bg-[#1d4ed8] px-6 py-3.5 text-sm font-bold text-white transition-colors hover:bg-[#1e3a8a]">
        <Icon name="download" size={17} strokeWidth={2.4} /> Download PDF
      </a>
    </div>
  </div>
</BaseLayout>
ASTRO

echo "  ✓ /books/[slug] — rewritten without covers"

# ─────────────────────────────────────────────
#  6. Force-clear every cache
# ─────────────────────────────────────────────
echo ""
echo "  Clearing all caches..."
rm -rf .astro
rm -rf node_modules/.vite
rm -rf node_modules/.astro
rm -rf dist
echo "  ✓ Cleared .astro, .vite, .astro cache, dist"

# ─────────────────────────────────────────────
#  7. Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding (2-3 min)..."
npm run build 2>&1 | tail -6

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Preview:"
echo ""
echo "    npm run dev"
echo ""
echo "  Then CLEAR YOUR BROWSER CACHE:"
echo "    Chrome Android: ⋮ → History → Clear browsing data"
echo "                    → Cached images and files → Clear"
echo ""
echo "  OR open in Incognito to skip cache entirely."
echo ""
echo "  Verify:"
echo "    /books                 → row cards, no covers"
echo "    /books/physics-9-punjab → detail page, no cover"
echo "════════════════════════════════════════════"