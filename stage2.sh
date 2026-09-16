#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Stage 2 — Board-first UI"
echo "════════════════════════════════════════════"
echo ""

mkdir -p src/lib src/pages/board

# ═══════════════════════════════════════════════
#  1. url() helper (safe to recreate)
# ═══════════════════════════════════════════════
cat > src/lib/url.ts <<'EOF'
const RAW_BASE = import.meta.env.BASE_URL || '/';
const BASE = RAW_BASE.endsWith('/') ? RAW_BASE.slice(0, -1) : RAW_BASE;

export function url(path: string): string {
  if (!path) return BASE || '/';
  if (/^https?:\/\//i.test(path)) return path;
  if (path.startsWith('#')) return path;
  if (path.startsWith('mailto:') || path.startsWith('tel:')) return path;
  if (path === '/') return BASE ? BASE + '/' : '/';
  const clean = path.startsWith('/') ? path : '/' + path;
  return BASE + clean;
}
EOF
echo "  url.ts"

# ═══════════════════════════════════════════════
#  2. Board content helper
# ═══════════════════════════════════════════════
cat > src/lib/boardContent.ts <<'EOF'
import { getCollection } from 'astro:content';
import { BOARDS, itemBoards, boardBySlug, CLASSES, CONTENT_TYPES, SUBJECTS } from './boards';

export function slugify(s: string) {
  return s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

async function loadAll() {
  const [notes, quizzes, books, gazettes, pastPapers, guessPapers, pairingSchemes] = await Promise.all([
    getCollection('notes'),
    getCollection('quizzes'),
    getCollection('books'),
    getCollection('gazettes'),
    getCollection('pastPapers'),
    getCollection('guessPapers'),
    getCollection('pairingSchemes'),
  ]);
  return { notes, quizzes, books, gazettes, pastPapers, guessPapers, pairingSchemes };
}

export async function getBoardCounts() {
  const all = await loadAll();
  const counts: Record<string, number> = {};
  for (const b of BOARDS) {
    let n = 0;
    for (const coll of Object.values(all)) {
      n += coll.filter((i: any) => itemBoards(i.data).includes(b.name)).length;
    }
    counts[b.slug] = n;
  }
  return counts;
}

export async function getBoardContent(boardSlug: string) {
  const board = boardBySlug(boardSlug);
  if (!board) return null;
  const all = await loadAll();

  const filter = (items: any[]) => items.filter((i: any) => itemBoards(i.data).includes(board.name));

  const notes = filter(all.notes);
  const quizzes = filter(all.quizzes);
  const books = filter(all.books);
  const gazettes = filter(all.gazettes);
  const pastPapers = filter(all.pastPapers);
  const guessPapers = filter(all.guessPapers);
  const pairingSchemes = filter(all.pairingSchemes);

  // All classes that have any content under this board
  const classSet = new Set<string>();
  [...notes, ...quizzes, ...books, ...gazettes, ...pastPapers, ...guessPapers, ...pairingSchemes]
    .forEach((i: any) => classSet.add(i.data.class));
  const classes = [...classSet].sort((a, b) => Number(a) - Number(b));

  return {
    board,
    notes, quizzes, books, gazettes,
    pastPapers, guessPapers, pairingSchemes,
    classes,
    total: notes.length + quizzes.length + books.length + gazettes.length + pastPapers.length + guessPapers.length + pairingSchemes.length,
  };
}

export async function getClassContent(boardSlug: string, cls: string) {
  const board = boardBySlug(boardSlug);
  if (!board) return null;
  const all = await loadAll();
  const match = (i: any) => itemBoards(i.data).includes(board.name) && i.data.class === cls;

  const notes = all.notes.filter(match);
  const quizzes = all.quizzes.filter(match);
  const books = all.books.filter(match);
  const gazettes = all.gazettes.filter(match);
  const pastPapers = all.pastPapers.filter(match);
  const guessPapers = all.guessPapers.filter(match);
  const pairingSchemes = all.pairingSchemes.filter(match);

  // Subject set for this class
  const subjectSet = new Set<string>();
  [...notes, ...quizzes, ...books, ...pastPapers, ...guessPapers]
    .forEach((i: any) => subjectSet.add(i.data.subject));
  const subjects = [...subjectSet].sort();

  return {
    board, class: cls,
    notes, quizzes, books, gazettes,
    pastPapers, guessPapers, pairingSchemes,
    subjects,
    total: notes.length + quizzes.length + books.length + gazettes.length + pastPapers.length + guessPapers.length + pairingSchemes.length,
  };
}

export async function getSubjectContent(boardSlug: string, cls: string, subjectSlug: string) {
  const board = boardBySlug(boardSlug);
  if (!board) return null;
  const all = await loadAll();
  const match = (i: any) =>
    itemBoards(i.data).includes(board.name) &&
    i.data.class === cls &&
    i.data.subject &&
    slugify(i.data.subject) === subjectSlug;

  const notes = all.notes.filter(match);
  const quizzes = all.quizzes.filter(match);
  const books = all.books.filter(match);
  const pastPapers = all.pastPapers.filter(match);
  const guessPapers = all.guessPapers.filter(match);

  const displayName = (notes[0] || quizzes[0] || books[0] || pastPapers[0] || guessPapers[0])?.data?.subject || subjectSlug;

  return { board, class: cls, subject: displayName, subjectSlug, notes, quizzes, books, pastPapers, guessPapers };
}

export async function getAllBoardPaths() {
  const paths: { board: string }[] = BOARDS.map(b => ({ board: b.slug }));
  return paths;
}

export async function getAllClassPaths() {
  const all = await loadAll();
  const seen = new Set<string>();
  const paths: { board: string; class: string }[] = [];
  for (const b of BOARDS) {
    for (const coll of Object.values(all)) {
      for (const i of coll as any[]) {
        if (itemBoards(i.data).includes(b.name)) {
          const key = b.slug + '/' + i.data.class;
          if (!seen.has(key)) { seen.add(key); paths.push({ board: b.slug, class: i.data.class }); }
        }
      }
    }
  }
  return paths;
}

export async function getAllSubjectPaths() {
  const all = await loadAll();
  const seen = new Set<string>();
  const paths: { board: string; class: string; subject: string }[] = [];
  for (const b of BOARDS) {
    for (const coll of Object.values(all)) {
      for (const i of coll as any[]) {
        if (i.data.subject && itemBoards(i.data).includes(b.name)) {
          const subj = slugify(i.data.subject);
          const key = b.slug + '/' + i.data.class + '/' + subj;
          if (!seen.has(key)) { seen.add(key); paths.push({ board: b.slug, class: i.data.class, subject: subj }); }
        }
      }
    }
  }
  return paths;
}

export { CLASSES, SUBJECTS, CONTENT_TYPES, BOARDS };
EOF
echo "  boardContent.ts"

# ═══════════════════════════════════════════════
#  3. New BaseLayout with board-aware sidebar
# ═══════════════════════════════════════════════
cat > src/layouts/BaseLayout.astro <<'EOF'
---
import '../styles/global.css';
import Icon from '../components/Icon.astro';
import { url } from '../lib/url';

interface Props { title: string; description?: string; }
const {
  title,
  description = 'Free notes, interactive quizzes, textbooks and result gazettes for Pakistani students.',
} = Astro.props;

const path = Astro.url.pathname;
const BASE = import.meta.env.BASE_URL.replace(/\/$/, '');

const navMain = [
  { href: '/',       label: 'Home',   icon: 'home' },
  { href: '/boards', label: 'Boards', icon: 'graduation-cap' },
];
const navStudy = [
  { href: '/notes',   label: 'Notes',   icon: 'file-text' },
  { href: '/quizzes', label: 'Quizzes', icon: 'circle-help' },
  { href: '/books',   label: 'Books',   icon: 'book-marked' },
];
const navExam = [
  { href: '/past-papers',     label: 'Past Papers',     icon: 'scroll-text' },
  { href: '/guess-papers',    label: 'Guess Papers',    icon: 'sparkles' },
  { href: '/pairing-schemes', label: 'Pairing Schemes', icon: 'list' },
  { href: '/gazettes',        label: 'Result Gazettes', icon: 'newspaper' },
];

const isActive = (href: string) => {
  const target = url(href);
  if (href === '/') return path === target || path === target + '/';
  return path.startsWith(target);
};
---
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta name="theme-color" content="#0620ed" />
  <title>{title}</title>
  <meta name="description" content={description} />
  <meta property="og:title" content={title} />
  <meta property="og:description" content={description} />
  <meta property="og:type" content="website" />
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" />
  <link rel="sitemap" href={url('/sitemap-index.xml')} />
</head>
<body class="min-h-screen bg-white">

  <!-- DESKTOP SIDEBAR -->
  <aside class="fixed inset-y-0 left-0 z-40 hidden w-[260px] flex-col border-r border-neutral-200 bg-white lg:flex">
    <a href={url('/')} class="flex h-[68px] shrink-0 items-center gap-2.5 border-b border-neutral-200 px-5">
      <span class="grid h-9 w-9 place-items-center rounded-lg bg-[#0620ed] text-white">
        <Icon name="graduation-cap" size={19} strokeWidth={2.4} />
      </span>
      <span class="text-lg font-extrabold tracking-tight text-neutral-900">TaleemHub</span>
    </a>

    <nav class="flex-1 overflow-y-auto px-3 py-5">
      <div class="mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-neutral-400">Main</div>
      <ul class="space-y-0.5">
        {navMain.map(item => (
          <li>
            <a href={url(item.href)} class:list={[
              "flex items-center gap-3 rounded-lg px-3 py-2.5 text-[13.5px] font-semibold transition-colors",
              isActive(item.href) ? "bg-[#eef2fe] text-[#0620ed]" : "text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900",
            ]}>
              <Icon name={item.icon} size={18} strokeWidth={2.1} class="shrink-0" />
              <span>{item.label}</span>
            </a>
          </li>
        ))}
      </ul>

      <div class="mt-6 mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-neutral-400">Study Material</div>
      <ul class="space-y-0.5">
        {navStudy.map(item => (
          <li>
            <a href={url(item.href)} class:list={[
              "flex items-center gap-3 rounded-lg px-3 py-2.5 text-[13.5px] font-semibold transition-colors",
              isActive(item.href) ? "bg-[#eef2fe] text-[#0620ed]" : "text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900",
            ]}>
              <Icon name={item.icon} size={18} strokeWidth={2.1} class="shrink-0" />
              <span>{item.label}</span>
            </a>
          </li>
        ))}
      </ul>

      <div class="mt-6 mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-neutral-400">Exams</div>
      <ul class="space-y-0.5">
        {navExam.map(item => (
          <li>
            <a href={url(item.href)} class:list={[
              "flex items-center gap-3 rounded-lg px-3 py-2.5 text-[13.5px] font-semibold transition-colors",
              isActive(item.href) ? "bg-[#eef2fe] text-[#0620ed]" : "text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900",
            ]}>
              <Icon name={item.icon} size={18} strokeWidth={2.1} class="shrink-0" />
              <span>{item.label}</span>
            </a>
          </li>
        ))}
      </ul>
    </nav>

    <div class="border-t border-neutral-200 p-3">
      <form action={url('/search')} method="get" role="search" class="flex items-center gap-2 rounded-lg border border-neutral-200 bg-neutral-50 px-3 py-2.5 focus-within:border-[#0620ed] focus-within:bg-white">
        <Icon name="search" size={15} strokeWidth={2.3} class="shrink-0 text-neutral-400" />
        <input type="search" name="q" placeholder="Search library" class="min-w-0 flex-1 bg-transparent text-[13px] font-medium text-neutral-900 outline-none placeholder:text-neutral-400" />
      </form>
    </div>
  </aside>

  <!-- MOBILE TOP BAR -->
  <header class="sticky top-0 z-30 flex h-16 w-full items-center gap-3 border-b border-neutral-200 bg-white/95 px-4 backdrop-blur-xl lg:hidden">
    <button id="open-drawer" type="button" aria-label="Open menu" class="grid h-10 w-10 place-items-center rounded-lg border border-neutral-200 bg-white text-neutral-700 active:bg-neutral-100">
      <Icon name="menu" size={20} strokeWidth={2.4} />
    </button>
    <a href={url('/')} class="flex items-center gap-2">
      <span class="grid h-8 w-8 place-items-center rounded-lg bg-[#0620ed] text-white">
        <Icon name="graduation-cap" size={17} strokeWidth={2.4} />
      </span>
      <span class="text-base font-extrabold tracking-tight text-neutral-900">TaleemHub</span>
    </a>
    <a href={url('/search')} class="ml-auto grid h-10 w-10 place-items-center rounded-lg border border-neutral-200 bg-white text-neutral-700 active:bg-neutral-100" aria-label="Search">
      <Icon name="search" size={18} strokeWidth={2.4} />
    </a>
  </header>

  <!-- MOBILE DRAWER -->
  <div id="drawer" class="fixed inset-0 z-50 hidden lg:hidden">
    <div id="drawer-backdrop" class="absolute inset-0 bg-neutral-900/40 opacity-0 transition-opacity duration-300"></div>
    <aside id="drawer-panel" class="absolute inset-y-0 left-0 flex w-[280px] -translate-x-full flex-col border-r border-neutral-200 bg-white transition-transform duration-300 ease-out">
      <div class="flex h-[68px] shrink-0 items-center justify-between border-b border-neutral-200 px-4">
        <a href={url('/')} class="flex items-center gap-2.5">
          <span class="grid h-9 w-9 place-items-center rounded-lg bg-[#0620ed] text-white">
            <Icon name="graduation-cap" size={19} strokeWidth={2.4} />
          </span>
          <span class="text-lg font-extrabold tracking-tight text-neutral-900">TaleemHub</span>
        </a>
        <button id="close-drawer" type="button" aria-label="Close" class="grid h-9 w-9 place-items-center rounded-lg text-neutral-500 active:bg-neutral-100">
          <Icon name="x" size={18} strokeWidth={2.4} />
        </button>
      </div>
      <nav class="flex-1 overflow-y-auto px-3 py-5">
        <div class="mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-neutral-400">Main</div>
        <ul class="space-y-0.5">
          {navMain.map(item => (
            <li><a href={url(item.href)} class:list={["flex items-center gap-3 rounded-lg px-3 py-2.5 text-[13.5px] font-semibold transition-colors", isActive(item.href) ? "bg-[#eef2fe] text-[#0620ed]" : "text-neutral-600 hover:bg-neutral-100"]}><Icon name={item.icon} size={18} strokeWidth={2.1} /><span>{item.label}</span></a></li>
          ))}
        </ul>
        <div class="mt-6 mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-neutral-400">Study Material</div>
        <ul class="space-y-0.5">
          {navStudy.map(item => (
            <li><a href={url(item.href)} class:list={["flex items-center gap-3 rounded-lg px-3 py-2.5 text-[13.5px] font-semibold transition-colors", isActive(item.href) ? "bg-[#eef2fe] text-[#0620ed]" : "text-neutral-600 hover:bg-neutral-100"]}><Icon name={item.icon} size={18} strokeWidth={2.1} /><span>{item.label}</span></a></li>
          ))}
        </ul>
        <div class="mt-6 mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-neutral-400">Exams</div>
        <ul class="space-y-0.5">
          {navExam.map(item => (
            <li><a href={url(item.href)} class:list={["flex items-center gap-3 rounded-lg px-3 py-2.5 text-[13.5px] font-semibold transition-colors", isActive(item.href) ? "bg-[#eef2fe] text-[#0620ed]" : "text-neutral-600 hover:bg-neutral-100"]}><Icon name={item.icon} size={18} strokeWidth={2.1} /><span>{item.label}</span></a></li>
          ))}
        </ul>
      </nav>
      <div class="border-t border-neutral-200 p-3">
        <form action={url('/search')} method="get" role="search" class="flex items-center gap-2 rounded-lg border border-neutral-200 bg-neutral-50 px-3 py-2.5">
          <Icon name="search" size={15} strokeWidth={2.3} class="shrink-0 text-neutral-400" />
          <input type="search" name="q" placeholder="Search library" class="min-w-0 flex-1 bg-transparent text-[13px] font-medium text-neutral-900 outline-none placeholder:text-neutral-400" />
        </form>
      </div>
    </aside>
  </div>

  <!-- CONTENT -->
  <div class="lg:pl-[260px]">
    <main class="min-h-[60vh]">
      <slot />
    </main>

    <footer class="mt-20 border-t border-neutral-200 bg-neutral-50">
      <div class="mx-auto max-w-[1320px] px-4 py-12 lg:px-8">
        <div class="grid grid-cols-1 gap-10 sm:grid-cols-2 lg:grid-cols-4">
          <div class="sm:col-span-2">
            <div class="flex items-center gap-2.5">
              <span class="grid h-9 w-9 place-items-center rounded-lg bg-[#0620ed] text-white">
                <Icon name="graduation-cap" size={19} strokeWidth={2.4} />
              </span>
              <span class="text-lg font-extrabold tracking-tight text-neutral-900">TaleemHub</span>
            </div>
            <p class="mt-4 max-w-sm text-sm leading-relaxed text-neutral-500">
              Free notes, quizzes, textbooks, past papers and result gazettes for Pakistani students — organised by board and class.
            </p>
          </div>
          <div>
            <h4 class="text-sm font-bold text-neutral-900">Study</h4>
            <ul class="mt-4 space-y-2.5 text-sm text-neutral-500">
              <li><a href={url('/boards')} class="hover:text-[#0620ed]">Boards</a></li>
              <li><a href={url('/notes')} class="hover:text-[#0620ed]">Notes</a></li>
              <li><a href={url('/quizzes')} class="hover:text-[#0620ed]">Quizzes</a></li>
              <li><a href={url('/books')} class="hover:text-[#0620ed]">Books</a></li>
            </ul>
          </div>
          <div>
            <h4 class="text-sm font-bold text-neutral-900">Exams</h4>
            <ul class="mt-4 space-y-2.5 text-sm text-neutral-500">
              <li><a href={url('/past-papers')} class="hover:text-[#0620ed]">Past Papers</a></li>
              <li><a href={url('/guess-papers')} class="hover:text-[#0620ed]">Guess Papers</a></li>
              <li><a href={url('/pairing-schemes')} class="hover:text-[#0620ed]">Pairing Schemes</a></li>
              <li><a href={url('/gazettes')} class="hover:text-[#0620ed]">Result Gazettes</a></li>
            </ul>
          </div>
        </div>
        <div class="mt-10 border-t border-neutral-200 pt-6 text-xs text-neutral-400">
          <p>© {new Date().getFullYear()} TaleemHub. Built for students, forever free.</p>
        </div>
      </div>
    </footer>
  </div>

  <script is:inline>
    (function () {
      var drawer = document.getElementById('drawer');
      var panel = document.getElementById('drawer-panel');
      var backdrop = document.getElementById('drawer-backdrop');
      var openBtn = document.getElementById('open-drawer');
      var closeBtn = document.getElementById('close-drawer');
      if (!drawer || !panel || !backdrop) return;
      var isOpen = false;
      function open() { if (isOpen) return; isOpen = true; drawer.classList.remove('hidden'); document.body.style.overflow = 'hidden'; requestAnimationFrame(function () { panel.classList.remove('-translate-x-full'); backdrop.classList.remove('opacity-0'); backdrop.classList.add('opacity-100'); }); }
      function close() { if (!isOpen) return; isOpen = false; panel.classList.add('-translate-x-full'); backdrop.classList.add('opacity-0'); backdrop.classList.remove('opacity-100'); setTimeout(function () { drawer.classList.add('hidden'); document.body.style.overflow = ''; }, 280); }
      if (openBtn) openBtn.addEventListener('click', function (e) { e.preventDefault(); open(); });
      if (closeBtn) closeBtn.addEventListener('click', function (e) { e.preventDefault(); close(); });
      if (backdrop) backdrop.addEventListener('click', close);
      document.addEventListener('keydown', function (e) { if (e.key === 'Escape') close(); });
    })();
  </script>
</body>
</html>
EOF
echo "  BaseLayout.astro"

# ═══════════════════════════════════════════════
#  4. Boards hub page
# ═══════════════════════════════════════════════
cat > src/pages/boards.astro <<'EOF'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { url } from '../lib/url';
import { BOARDS } from '../lib/boards';
import { getBoardCounts } from '../lib/boardContent';

const counts = await getBoardCounts();
---
<BaseLayout title="Boards — TaleemHub" description="Choose your board: Punjab, Federal, KPK, Sindh, Balochistan or AJK.">
  <div class="mx-auto max-w-[1320px] px-4 pt-10 sm:px-6 sm:pt-14 lg:px-8">
    <div class="mb-10">
      <h1 class="text-3xl font-extrabold tracking-tight text-neutral-900 sm:text-4xl">Choose your board</h1>
      <p class="mt-2 text-neutral-500">Notes, past papers, guess papers and more — tailored to your board.</p>
    </div>

    <div class="grid grid-cols-2 gap-4 lg:grid-cols-3">
      {BOARDS.map(b => (
        <a href={url(`/board/${b.slug}`)} class="group rounded-2xl border border-neutral-200 bg-white p-6 transition-colors hover:border-[#0620ed]">
          <div class="flex items-start justify-between">
            <span class="grid h-12 w-12 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
              <Icon name="graduation-cap" size={22} strokeWidth={2.2} />
            </span>
            <Icon name="arrow-up-right" size={18} strokeWidth={2.4} class="text-neutral-300 transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-[#0620ed]" />
          </div>
          <h3 class="mt-5 text-xl font-extrabold tracking-tight text-neutral-900">{b.name}</h3>
          <p class="mt-1 text-sm text-neutral-500">{counts[b.slug] || 0} {counts[b.slug] === 1 ? 'item' : 'items'}</p>
        </a>
      ))}
    </div>
  </div>
</BaseLayout>
EOF
echo "  /boards"

# ═══════════════════════════════════════════════
#  5. Board hub
# ═══════════════════════════════════════════════
cat > src/pages/board/[board]/index.astro <<'EOF'
---
import BaseLayout from '../../../layouts/BaseLayout.astro';
import Icon from '../../../components/Icon.astro';
import { url } from '../../../lib/url';
import { BOARDS } from '../../../lib/boards';
import { getBoardContent } from '../../../lib/boardContent';

export async function getStaticPaths() {
  return BOARDS.map(b => ({ params: { board: b.slug } }));
}

const { board: slug } = Astro.params;
const data = await getBoardContent(slug!);
if (!data) return Astro.redirect('/boards');
const { board, classes, notes, quizzes, books, gazettes, pastPapers, guessPapers, pairingSchemes, total } = data;
---
<BaseLayout title={`${board.name} Board — Notes, Past Papers & More | TaleemHub`} description={`All study material for ${board.full}: notes, quizzes, past papers, guess papers, pairing schemes and result gazettes.`}>
  <div class="mx-auto max-w-[1320px] px-4 pt-10 sm:px-6 sm:pt-14 lg:px-8">
    <a href={url('/boards')} class="mb-6 inline-flex items-center gap-2 text-sm font-semibold text-neutral-500 hover:text-[#0620ed]">
      <Icon name="arrow-left" size={16} strokeWidth={2.4} /> All boards
    </a>

    <div class="rounded-3xl border border-[#0620ed] bg-gradient-to-br from-[#110176] via-[#0620ed] to-[#265bf6] p-8 text-white sm:p-10">
      <span class="inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider">
        <Icon name="graduation-cap" size={13} strokeWidth={2.4} /> Board
      </span>
      <h1 class="mt-4 text-4xl font-extrabold leading-tight tracking-tight sm:text-5xl">{board.full}</h1>
      <p class="mt-2 text-blue-100">{classes.length} {classes.length === 1 ? 'class' : 'classes'} · {total} {total === 1 ? 'item' : 'items'}</p>
    </div>

    <div class="mt-10">
      <h2 class="mb-5 text-2xl font-extrabold tracking-tight text-neutral-900">Pick your class</h2>
      {classes.length === 0 ? (
        <div class="rounded-2xl border border-dashed border-neutral-300 bg-white p-12 text-center">
          <p class="text-base font-bold text-neutral-900">No content yet for {board.name}</p>
          <p class="mt-1 text-sm text-neutral-500">Check back soon.</p>
        </div>
      ) : (
        <div class="grid grid-cols-2 gap-4 lg:grid-cols-4">
          {classes.map(c => {
            const total = notes.filter((i: any) => i.data.class === c).length
              + quizzes.filter((i: any) => i.data.class === c).length
              + books.filter((i: any) => i.data.class === c).length
              + pastPapers.filter((i: any) => i.data.class === c).length
              + guessPapers.filter((i: any) => i.data.class === c).length
              + pairingSchemes.filter((i: any) => i.data.class === c).length
              + gazettes.filter((i: any) => i.data.class === c).length;
            return (
              <a href={url(`/board/${slug}/class-${c}`)} class="group rounded-2xl border border-neutral-200 bg-white p-6 transition-colors hover:border-[#0620ed]">
                <span class="grid h-12 w-12 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
                  <Icon name="graduation-cap" size={22} strokeWidth={2.2} />
                </span>
                <h3 class="mt-5 text-2xl font-extrabold tracking-tight text-neutral-900">Class {c}</h3>
                <p class="mt-1 text-sm text-neutral-500">{total} {total === 1 ? 'item' : 'items'}</p>
              </a>
            );
          })}
        </div>
      )}
    </div>
  </div>
</BaseLayout>
EOF
echo "  /board/[board]"

# ═══════════════════════════════════════════════
#  6. Class hub
# ═══════════════════════════════════════════════
cat > src/pages/board/[board]/[class]/index.astro <<'EOF'
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
  <div class="mx-auto max-w-[1320px] px-4 pt-10 sm:px-6 sm:pt-14 lg:px-8">
    <nav class="mb-6 flex items-center gap-1.5 text-xs font-semibold text-neutral-400">
      <a href={url('/boards')} class="hover:text-[#0620ed]">Boards</a>
      <span>/</span>
      <a href={url(`/board/${boardSlug}`)} class="hover:text-[#0620ed]">{board.name}</a>
      <span>/</span>
      <span class="text-neutral-500">Class {cls}</span>
    </nav>

    <div class="rounded-3xl border border-[#0620ed] bg-gradient-to-br from-[#110176] via-[#0620ed] to-[#265bf6] p-8 text-white sm:p-10">
      <div class="flex flex-wrap gap-1.5">
        <span class="inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider">
          <Icon name="graduation-cap" size={13} strokeWidth={2.4} /> {board.name}
        </span>
      </div>
      <h1 class="mt-4 text-4xl font-extrabold leading-tight tracking-tight sm:text-5xl">Class {cls}</h1>
      <p class="mt-2 text-blue-100">{subjects.length} {subjects.length === 1 ? 'subject' : 'subjects'} · {data.total} items</p>
    </div>

    {sections.length > 0 && (
      <section class="mt-10">
        <h2 class="mb-5 text-xl font-extrabold tracking-tight text-neutral-900">Browse by type</h2>
        <div class="grid grid-cols-2 gap-3 lg:grid-cols-4">
          {sections.map(s => (
            <a href={url(`/board/${boardSlug}/class-${cls}/${s.slug}`)} class="group flex items-center gap-3.5 rounded-2xl border border-neutral-200 bg-white p-4 transition-colors hover:border-[#0620ed]">
              <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
                <Icon name={s.icon} size={19} strokeWidth={2.2} />
              </span>
              <div class="min-w-0">
                <div class="text-sm font-extrabold tracking-tight text-neutral-900">{s.label}</div>
                <div class="text-xs font-semibold text-neutral-500">{s.count} {s.count === 1 ? 'item' : 'items'}</div>
              </div>
            </a>
          ))}
        </div>
      </section>
    )}

    {subjects.length > 0 && (
      <section class="mt-12 pb-16">
        <h2 class="mb-5 text-xl font-extrabold tracking-tight text-neutral-900">Browse by subject</h2>
        <div class="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {subjects.map(s => (
            <a href={url(`/board/${boardSlug}/class-${cls}/${slugify(s)}`)} class="group flex items-center gap-4 rounded-2xl border border-neutral-200 bg-white p-5 transition-colors hover:border-[#0620ed]">
              <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
                <Icon name="library" size={19} strokeWidth={2.2} />
              </span>
              <div class="min-w-0 flex-1">
                <div class="text-base font-extrabold tracking-tight text-neutral-900">{s}</div>
              </div>
              <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-neutral-300 transition-transform group-hover:translate-x-0.5 group-hover:text-[#0620ed]" />
            </a>
          ))}
        </div>
      </section>
    )}
  </div>
</BaseLayout>
EOF
echo "  /board/[board]/[class]"

# ═══════════════════════════════════════════════
#  7. Subject hub
# ═══════════════════════════════════════════════
cat > src/pages/board/[board]/[class]/[subject].astro <<'EOF'
---
import BaseLayout from '../../../../../layouts/BaseLayout.astro';
import Icon from '../../../../../components/Icon.astro';
import { url } from '../../../../../lib/url';
import { BOARDS } from '../../../../../lib/boards';
import { getSubjectContent, getAllSubjectPaths } from '../../../../../lib/boardContent';

export async function getStaticPaths() {
  const paths = await getAllSubjectPaths();
  return paths.map(p => ({ params: { board: p.board, class: `class-${p.class}`, subject: p.subject } }));
}

const { board: boardSlug, class: classParam, subject: subjectSlug } = Astro.params;
const cls = String(classParam).replace(/^class-/, '');
const data = await getSubjectContent(boardSlug!, cls, subjectSlug!);
if (!data) return Astro.redirect('/boards');
const { board, subject, notes, quizzes, books, pastPapers, guessPapers } = data;

const sections = [
  { label: 'Notes',        icon: 'file-text',   items: notes,       base: '/notes' },
  { label: 'Past Papers',  icon: 'scroll-text', items: pastPapers,  base: '/past-papers' },
  { label: 'Guess Papers', icon: 'sparkles',    items: guessPapers, base: '/guess-papers' },
  { label: 'Quizzes',      icon: 'circle-help', items: quizzes,     base: '/quizzes' },
  { label: 'Books',        icon: 'book-marked', items: books,       base: '/books' },
].filter(s => s.items.length > 0);
---
<BaseLayout title={`${board.name} Class ${cls} ${subject} | TaleemHub`} description={`All ${subject} material for ${board.full} Class ${cls}: notes, past papers, guess papers, quizzes and books.`}>
  <div class="mx-auto max-w-[1320px] px-4 pt-10 sm:px-6 sm:pt-14 lg:px-8">
    <nav class="mb-6 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-neutral-400">
      <a href={url('/boards')} class="hover:text-[#0620ed]">Boards</a>
      <span>/</span>
      <a href={url(`/board/${boardSlug}`)} class="hover:text-[#0620ed]">{board.name}</a>
      <span>/</span>
      <a href={url(`/board/${boardSlug}/class-${cls}`)} class="hover:text-[#0620ed]">Class {cls}</a>
      <span>/</span>
      <span class="text-neutral-500">{subject}</span>
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
      <h1 class="mt-4 text-4xl font-extrabold leading-tight tracking-tight sm:text-5xl">{subject}</h1>
    </div>

    {sections.map(sec => (
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
                  {item.data.class && <span class="rounded-md bg-[#eef2fe] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#0620ed]">Class {item.data.class}</span>}
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
EOF
echo "  /board/[board]/[class]/[subject]"

# ═══════════════════════════════════════════════
#  8. Home page — board picker
# ═══════════════════════════════════════════════
cat > src/pages/index.astro <<'EOF'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { url } from '../lib/url';
import { BOARDS } from '../lib/boards';
import { getBoardCounts } from '../lib/boardContent';

const counts = await getBoardCounts();
---
<BaseLayout title="TaleemHub — Board & Class-Specific Study Material for Pakistani Students">
  <section class="border-b border-neutral-200 bg-neutral-50">
    <div class="mx-auto max-w-[1320px] px-4 py-16 lg:px-8 lg:py-20">
      <div class="max-w-3xl">
        <div class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-[#0620ed]">
          <span class="h-1.5 w-1.5 rounded-full bg-[#0620ed]"></span>
          Trusted by students across Pakistan
        </div>
        <h1 class="mt-5 text-[2.5rem] font-extrabold leading-[1.08] tracking-[-0.035em] text-neutral-900 sm:text-6xl">
          Your board. Your class.<br />
          Your syllabus.
        </h1>
        <p class="mt-6 max-w-xl text-base leading-relaxed text-neutral-500 sm:text-lg">
          Notes, past papers, guess papers, pairing schemes, quizzes and result gazettes — organised for your exact board and class.
        </p>

        <form action={url('/search')} method="get" role="search" class="mt-8 flex max-w-lg items-center gap-2 rounded-2xl border border-neutral-200 bg-white p-1.5 pl-4 focus-within:border-[#0620ed]">
          <Icon name="search" size={18} strokeWidth={2.4} class="shrink-0 text-neutral-400" />
          <input type="search" name="q" placeholder="Search notes, papers, books..." class="min-w-0 flex-1 bg-transparent py-2.5 text-sm text-neutral-900 outline-none placeholder:text-neutral-400" />
          <button type="submit" class="rounded-xl bg-[#0620ed] px-4 py-2.5 text-sm font-bold text-white transition-colors hover:bg-[#110176]">Search</button>
        </form>
      </div>
    </div>
  </section>

  <section class="mx-auto max-w-[1320px] px-4 py-14 lg:px-8">
    <div class="mb-8">
      <h2 class="text-2xl font-extrabold tracking-tight text-neutral-900 sm:text-3xl">Choose your board</h2>
      <p class="mt-2 text-sm text-neutral-500">Everything is organised for your specific board.</p>
    </div>

    <div class="grid grid-cols-2 gap-4 lg:grid-cols-3">
      {BOARDS.map(b => (
        <a href={url(`/board/${b.slug}`)} class="group rounded-2xl border border-neutral-200 bg-white p-6 transition-colors hover:border-[#0620ed]">
          <div class="flex items-start justify-between">
            <span class="grid h-12 w-12 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
              <Icon name="graduation-cap" size={22} strokeWidth={2.2} />
            </span>
            <Icon name="arrow-up-right" size={18} strokeWidth={2.4} class="text-neutral-300 transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-[#0620ed]" />
          </div>
          <h3 class="mt-5 text-xl font-extrabold tracking-tight text-neutral-900">{b.name}</h3>
          <p class="mt-1 text-sm text-neutral-500">{counts[b.slug] || 0} {counts[b.slug] === 1 ? 'item' : 'items'}</p>
        </a>
      ))}
    </div>
  </section>

  <section class="border-t border-neutral-200 bg-neutral-50">
    <div class="mx-auto max-w-[1320px] px-4 py-14 lg:px-8">
      <div class="mb-8">
        <h2 class="text-2xl font-extrabold tracking-tight text-neutral-900 sm:text-3xl">What you'll find</h2>
        <p class="mt-2 text-sm text-neutral-500">Seven content types, always organised by board and class.</p>
      </div>
      <div class="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
        {[
          { href: '/notes',           label: 'Notes',           icon: 'file-text',   desc: 'Chapter-wise notes' },
          { href: '/past-papers',     label: 'Past Papers',     icon: 'scroll-text', desc: 'Previous years' },
          { href: '/guess-papers',    label: 'Guess Papers',    icon: 'sparkles',    desc: 'Expected questions' },
          { href: '/pairing-schemes', label: 'Pairing Schemes', icon: 'list',        desc: 'Paper structure' },
          { href: '/quizzes',         label: 'Quizzes',         icon: 'circle-help', desc: 'Practice MCQs' },
          { href: '/books',           label: 'Books',           icon: 'book-marked', desc: 'Full textbooks' },
          { href: '/gazettes',        label: 'Result Gazettes', icon: 'newspaper',   desc: 'Board results' },
          { href: '/boards',          label: 'All Boards',      icon: 'graduation-cap', desc: 'Browse by board' },
        ].map(c => (
          <a href={url(c.href)} class="group rounded-2xl border border-neutral-200 bg-white p-5 transition-colors hover:border-[#0620ed]">
            <span class="grid h-11 w-11 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
              <Icon name={c.icon} size={19} strokeWidth={2.2} />
            </span>
            <div class="mt-4 text-sm font-extrabold tracking-tight text-neutral-900">{c.label}</div>
            <div class="mt-0.5 text-xs text-neutral-500">{c.desc}</div>
          </a>
        ))}
      </div>
    </div>
  </section>
</BaseLayout>
EOF
echo "  /"

# ═══════════════════════════════════════════════
#  9. Rebuild
# ═══════════════════════════════════════════════
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -25

echo ""
echo "════════════════════════════════════════════"
echo "  Stage 2 complete."
echo ""
echo "  New pages:"
echo "    /                            board picker home"
echo "    /boards                      all boards hub"
echo "    /board/punjab                board hub"
echo "    /board/punjab/class-10       class hub (subjects grid)"
echo "    /board/punjab/class-10/physics  subject hub (all types)"
echo ""
echo "  Sidebar updated with Main / Study Material / Exams"
echo ""
echo "  If the build succeeds, push:"
echo "    git add ."
echo "    git commit -m 'Stage 2: board-first UI'"
echo "    git push"
echo ""
echo "  Then open the site and check. Some /notes, /past-papers etc."
echo "  top-level pages still show the old design — I'll update them"
echo "  in Stage 3."
echo "════════════════════════════════════════════"