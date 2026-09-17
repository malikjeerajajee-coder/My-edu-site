#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Organizing Notes, Quizzes, Books by class"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  1. Add chip styles to global.css
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib
p = pathlib.Path('src/styles/global.css')
s = p.read_text()

if '.chip {' not in s:
    s = s.rstrip() + '''

/* ═══ Filter chips ═══ */
.chip-row {
  display: flex;
  gap: 0.5rem;
  overflow-x: auto;
  padding-bottom: 0.5rem;
  scrollbar-width: none;
  -webkit-overflow-scrolling: touch;
}
.chip-row::-webkit-scrollbar { display: none; }

.chip {
  display: inline-flex;
  align-items: center;
  gap: 0.375rem;
  padding: 0.5rem 0.875rem;
  border-radius: 999px;
  border: 1px solid #e5e9f0;
  background: #ffffff;
  color: #334155;
  font-size: 0.8125rem;
  font-weight: 700;
  white-space: nowrap;
  cursor: pointer;
  transition: all .15s ease;
}
.chip:hover { border-color: #1d4ed8; color: #1d4ed8; }
.chip.active {
  background: #1d4ed8;
  border-color: #1d4ed8;
  color: #ffffff !important;
}
.chip-count {
  display: inline-block;
  padding: 0 0.4rem;
  border-radius: 999px;
  background: #f1f5f9;
  color: #64748b;
  font-size: 0.6875rem;
  font-weight: 800;
  min-width: 20px;
  text-align: center;
}
.chip.active .chip-count {
  background: rgba(255,255,255,0.25);
  color: #ffffff;
}
'''
    p.write_text(s)
    print('  ✓ chip styles added')
else:
    print('  · chip styles already present')
PY

# ─────────────────────────────────────────────
#  2. Rewrite /books — grouped by class + board filter
# ─────────────────────────────────────────────
cat > src/pages/books/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
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

// Sort
const sortedClasses = [...byClass.keys()].sort((a, b) => {
  const ai = CLASS_ORDER.indexOf(a), bi = CLASS_ORDER.indexOf(b);
  if (ai === -1 && bi === -1) return Number(a) - Number(b);
  if (ai === -1) return 1;
  if (bi === -1) return -1;
  return ai - bi;
});
sortedClasses.forEach(cls => {
  byClass.get(cls)!.sort((a: any, b: any) => a.data.title.localeCompare(b.data.title));
});

// Available boards
const allBoards = new Set<string>();
books.forEach((b: any) => (b.data.boards || []).forEach((x: string) => allBoards.add(x)));
const boards = [...allBoards].sort();

const totalBooks = books.length;
---
<BaseLayout title="Textbooks — TaleemHub" description="Free Pakistani board textbooks for Class 1 to 12. Punjab (PTB) and Federal (FBISE). Download PDFs instantly.">
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
          {totalBooks} textbooks from Punjab (PTB) and Federal (FBISE) boards — Class 1 to Class 12.
        </p>
      </div>
    </div>
  </div>

  <!-- Filters + list -->
  <div class="mx-auto max-w-[1200px] px-5 py-8 sm:px-7 lg:px-10 lg:py-10">
    <!-- Board filter -->
    <div class="mb-3">
      <div class="text-[10px] font-bold uppercase tracking-wider text-slate-400 mb-2">Board</div>
      <div class="chip-row" id="board-chips">
        <button type="button" class="chip active" data-board="all">All boards</button>
        {boards.map(b => (
          <button type="button" class="chip" data-board={b}>{b}</button>
        ))}
      </div>
    </div>

    <!-- Class filter -->
    <div class="mb-6">
      <div class="text-[10px] font-bold uppercase tracking-wider text-slate-400 mb-2">Class</div>
      <div class="chip-row" id="class-chips">
        <button type="button" class="chip active" data-class="all">All classes</button>
        {sortedClasses.map(c => (
          <button type="button" class="chip" data-class={c}>Class {c}</button>
        ))}
      </div>
    </div>

    <!-- Book list grouped by class -->
    <div id="book-list" class="space-y-10">
      {sortedClasses.map(cls => {
        const items = byClass.get(cls)!;
        return (
          <section data-class={cls}>
            <div class="mb-4 flex items-end justify-between gap-4">
              <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">
                Class {cls}
              </h2>
              <span class="text-xs font-semibold uppercase tracking-wider text-slate-400">
                {items.length} {items.length === 1 ? 'book' : 'books'}
              </span>
            </div>
            <div class="grid grid-cols-1 gap-2.5 sm:grid-cols-2">
              {items.map((b: any) => (
                <a href={url(`/books/${b.id}`)} class="row group"
                   data-board={(b.data.boards || []).join('|')}>
                  <span class="tile">
                    <Icon name="book-marked" size={18} strokeWidth={2.2} />
                  </span>
                  <div class="min-w-0 flex-1">
                    <div class="row-title">{b.data.subject}</div>
                    <div class="mt-1 flex flex-wrap gap-1.5">
                      {(b.data.boards || []).map((bd: string) => (
                        <span class="inline-flex items-center rounded bg-[#eff4ff] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#1d4ed8]">{bd}</span>
                      ))}
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

  <script is:inline>
    (function () {
      var activeBoard = 'all';
      var activeClass = 'all';

      var boardChips = document.querySelectorAll('#board-chips .chip');
      var classChips = document.querySelectorAll('#class-chips .chip');
      var sections   = document.querySelectorAll('#book-list section');

      function apply() {
        sections.forEach(function (sec) {
          var secClass = sec.getAttribute('data-class');
          var rows = sec.querySelectorAll('.row');
          var visibleRows = 0;

          rows.forEach(function (row) {
            var rowBoards = (row.getAttribute('data-board') || '').split('|');
            var matchesBoard = (activeBoard === 'all') || rowBoards.indexOf(activeBoard) !== -1;
            row.style.display = matchesBoard ? '' : 'none';
            if (matchesBoard) visibleRows++;
          });

          var matchesClass = (activeClass === 'all') || secClass === activeClass;
          sec.style.display = (matchesClass && visibleRows > 0) ? '' : 'none';
        });
      }

      boardChips.forEach(function (c) {
        c.addEventListener('click', function () {
          boardChips.forEach(function (x) { x.classList.remove('active'); });
          c.classList.add('active');
          activeBoard = c.getAttribute('data-board');
          apply();
        });
      });

      classChips.forEach(function (c) {
        c.addEventListener('click', function () {
          classChips.forEach(function (x) { x.classList.remove('active'); });
          c.classList.add('active');
          activeClass = c.getAttribute('data-class');
          apply();
        });
      });
    })();
  </script>
</BaseLayout>
ASTRO

echo "  ✓ /books — grouped by class + board filter"

# ─────────────────────────────────────────────
#  3. Rewrite /notes — grouped by class
# ─────────────────────────────────────────────
cat > src/pages/notes/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { getCollection } from 'astro:content';

const notes = await getCollection('notes');
const CLASS_ORDER = ['9','10','11','12'];

const byClass = new Map<string, any[]>();
notes.forEach((n: any) => {
  const cls = n.data.class;
  if (!byClass.has(cls)) byClass.set(cls, []);
  byClass.get(cls)!.push(n);
});

const sortedClasses = [...byClass.keys()].sort((a, b) => {
  const ai = CLASS_ORDER.indexOf(a), bi = CLASS_ORDER.indexOf(b);
  if (ai === -1 && bi === -1) return Number(a) - Number(b);
  if (ai === -1) return 1;
  if (bi === -1) return -1;
  return ai - bi;
});
sortedClasses.forEach(cls => {
  byClass.get(cls)!.sort((a: any, b: any) => a.data.title.localeCompare(b.data.title));
});
---
<BaseLayout title="Notes — TaleemHub" description="Chapter-wise notes for Pakistani students across all boards. Free download, Class 9 to 12.">
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">Notes</span>
      </nav>
      <div class="max-w-2xl">
        <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">Notes</h1>
        <p class="mt-3 text-base leading-relaxed text-slate-600">
          {notes.length} chapter-wise notes across Class 9 to 12.
        </p>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[1200px] px-5 py-8 sm:px-7 lg:px-10 lg:py-10">
    <div class="mb-6">
      <div class="text-[10px] font-bold uppercase tracking-wider text-slate-400 mb-2">Class</div>
      <div class="chip-row" id="class-chips">
        <button type="button" class="chip active" data-class="all">All classes</button>
        {sortedClasses.map(c => (
          <button type="button" class="chip" data-class={c}>Class {c}</button>
        ))}
      </div>
    </div>

    <div id="note-list" class="space-y-10">
      {sortedClasses.map(cls => {
        const items = byClass.get(cls)!;
        return (
          <section data-class={cls}>
            <div class="mb-4 flex items-end justify-between gap-4">
              <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Class {cls}</h2>
              <span class="text-xs font-semibold uppercase tracking-wider text-slate-400">
                {items.length} {items.length === 1 ? 'note' : 'notes'}
              </span>
            </div>
            <div class="grid grid-cols-1 gap-2.5 sm:grid-cols-2">
              {items.map((n: any) => (
                <a href={url(`/notes/${n.id}`)} class="row group">
                  <span class="tile">
                    <Icon name="file-text" size={18} strokeWidth={2.2} />
                  </span>
                  <div class="min-w-0 flex-1">
                    <div class="row-title">{n.data.subject} — Chapter</div>
                    <div class="mt-1 flex flex-wrap gap-1.5">
                      <span class="inline-flex items-center rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate-600">{n.data.subject}</span>
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

  <script is:inline>
    (function () {
      var chips = document.querySelectorAll('#class-chips .chip');
      var sections = document.querySelectorAll('#note-list section');
      chips.forEach(function (c) {
        c.addEventListener('click', function () {
          chips.forEach(function (x) { x.classList.remove('active'); });
          c.classList.add('active');
          var target = c.getAttribute('data-class');
          sections.forEach(function (sec) {
            sec.style.display = (target === 'all' || sec.getAttribute('data-class') === target) ? '' : 'none';
          });
        });
      });
    })();
  </script>
</BaseLayout>
ASTRO

echo "  ✓ /notes — grouped by class"

# ─────────────────────────────────────────────
#  4. Rewrite /quizzes — grouped by class
# ─────────────────────────────────────────────
cat > src/pages/quizzes/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { getCollection } from 'astro:content';

const quizzes = await getCollection('quizzes');
const CLASS_ORDER = ['9','10','11','12'];

const byClass = new Map<string, any[]>();
quizzes.forEach((q: any) => {
  const cls = q.data.class;
  if (!byClass.has(cls)) byClass.set(cls, []);
  byClass.get(cls)!.push(q);
});

const sortedClasses = [...byClass.keys()].sort((a, b) => {
  const ai = CLASS_ORDER.indexOf(a), bi = CLASS_ORDER.indexOf(b);
  if (ai === -1 && bi === -1) return Number(a) - Number(b);
  if (ai === -1) return 1;
  if (bi === -1) return -1;
  return ai - bi;
});
sortedClasses.forEach(cls => {
  byClass.get(cls)!.sort((a: any, b: any) => a.data.title.localeCompare(b.data.title));
});
---
<BaseLayout title="Quizzes — TaleemHub" description="Interactive MCQ quizzes for Pakistani students. Instant feedback, free, Class 9 to 12.">
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">Quizzes</span>
      </nav>
      <div class="max-w-2xl">
        <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">Quizzes</h1>
        <p class="mt-3 text-base leading-relaxed text-slate-600">
          {quizzes.length} interactive MCQ {quizzes.length === 1 ? 'quiz' : 'quizzes'} with instant feedback.
        </p>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[1200px] px-5 py-8 sm:px-7 lg:px-10 lg:py-10">
    <div class="mb-6">
      <div class="text-[10px] font-bold uppercase tracking-wider text-slate-400 mb-2">Class</div>
      <div class="chip-row" id="class-chips">
        <button type="button" class="chip active" data-class="all">All classes</button>
        {sortedClasses.map(c => (
          <button type="button" class="chip" data-class={c}>Class {c}</button>
        ))}
      </div>
    </div>

    <div id="quiz-list" class="space-y-10">
      {sortedClasses.map(cls => {
        const items = byClass.get(cls)!;
        return (
          <section data-class={cls}>
            <div class="mb-4 flex items-end justify-between gap-4">
              <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Class {cls}</h2>
              <span class="text-xs font-semibold uppercase tracking-wider text-slate-400">
                {items.length} {items.length === 1 ? 'quiz' : 'quizzes'}
              </span>
            </div>
            <div class="grid grid-cols-1 gap-2.5 sm:grid-cols-2">
              {items.map((q: any) => (
                <a href={url(`/quizzes/${q.id}`)} class="row group">
                  <span class="tile">
                    <Icon name="circle-help" size={18} strokeWidth={2.2} />
                  </span>
                  <div class="min-w-0 flex-1">
                    <div class="row-title">{q.data.title}</div>
                    <div class="mt-1 flex flex-wrap gap-1.5">
                      <span class="inline-flex items-center rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate-600">{q.data.subject}</span>
                      <span class="inline-flex items-center rounded bg-[#eff4ff] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#1d4ed8]">{q.data.questions.length} questions</span>
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

  <script is:inline>
    (function () {
      var chips = document.querySelectorAll('#class-chips .chip');
      var sections = document.querySelectorAll('#quiz-list section');
      chips.forEach(function (c) {
        c.addEventListener('click', function () {
          chips.forEach(function (x) { x.classList.remove('active'); });
          c.classList.add('active');
          var target = c.getAttribute('data-class');
          sections.forEach(function (sec) {
            sec.style.display = (target === 'all' || sec.getAttribute('data-class') === target) ? '' : 'none';
          });
        });
      });
    })();
  </script>
</BaseLayout>
ASTRO

echo "  ✓ /quizzes — grouped by class"

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
echo "  Preview (restart dev server if running):"
echo ""
echo "    pkill -f 'astro dev' || true"
echo "    npm run dev"
echo ""
echo "  What changed:"
echo ""
echo "  /books:"
echo "    · Grouped by class — Class 1, 2, 3... 12 sections"
echo "    · Board filter chips: All / Punjab / Federal"
echo "    · Class filter chips: All / 1 / 2 / ... / 12"
echo "    · Each book shows subject + board badge"
echo ""
echo "  /notes:"
echo "    · Grouped by class — Class 9, 10, 11"
echo "    · Class filter chips"
echo ""
echo "  /quizzes:"
echo "    · Grouped by class — Class 9, 10"
echo "    · Class filter chips"
echo "    · Each shows subject + question count"
echo ""
echo "  Filtering is instant — no page reload."
echo "════════════════════════════════════════════"