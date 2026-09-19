#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Reverting books pages to card layout"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  1. Delete the BookCover component
# ─────────────────────────────────────────────
rm -f src/components/BookCover.astro
echo "  ✓ Removed BookCover.astro"

# ─────────────────────────────────────────────
#  2. Restore /books index — row cards
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

echo "  ✓ /books — row cards restored"

# ─────────────────────────────────────────────
#  3. Restore /books/[slug] detail page — remove cover
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re

p = pathlib.Path('src/pages/books/[...slug].astro')
if not p.exists():
    print('  · books detail page not found')
    raise SystemExit(0)

s = p.read_text()

# Remove BookCover import
s = re.sub(r"^import BookCover[^\n]*\n", "", s, flags=re.MULTILINE)

# Remove the cover block that was inserted
cover_block_pattern = re.compile(
    r'\n\s*<!-- Book cover -->\s*<div class="mb-8 grid[\s\S]*?</div>\s*<div class="min-w-0">',
    re.DOTALL
)
s = cover_block_pattern.sub('\n', s)

# Remove the two extra closing divs we added
# Find "      </div>\n    </div>" that came right before final content close
s = s.replace('\n      </div>\n    </div>\n  </div>', '\n  </div>')

# Remove the book-cover-detail CSS block
css_pattern = re.compile(
    r'\n\s*<style is:global>\s*\.book-cover-detail[\s\S]*?</style>',
    re.DOTALL
)
s = css_pattern.sub('', s)

p.write_text(s)
print('  ✓ /books/[slug] — cover removed')
PY

# ─────────────────────────────────────────────
#  4. Also remove the restore.sh script (no longer needed)
# ─────────────────────────────────────────────
rm -f restore.sh
echo "  ✓ Cleaned up restore.sh"

# ─────────────────────────────────────────────
#  5. Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -6

echo ""
echo "════════════════════════════════════════════"
echo "  Done."
echo ""
echo "  Preview:"
echo "    pkill -f 'astro dev' || true"
echo "    npm run dev"
echo ""
echo "  Test:"
echo "    /books                    → row cards, one per book"
echo "    /books/physics-9-punjab   → detail page (no cover)"
echo ""
echo "  What's back:"
echo "    · Books in 1 or 2 column row cards"
echo "    · .tile icon + subject + board badge + arrow"
echo "    · Search + filter bar still active"
echo "    · BookCover.astro deleted"
echo "    · All cover CSS removed"
echo "════════════════════════════════════════════"