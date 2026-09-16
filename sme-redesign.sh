#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  SME-style redesign — full pass"
echo "════════════════════════════════════════════"
echo ""

mkdir -p src/layouts src/components src/pages

# ═══════════════════════════════════════════════
#  1. Global CSS — typography + reusable card patterns
# ═══════════════════════════════════════════════
cat > src/styles/global.css <<'CSS'
@import "tailwindcss";

@theme {
  --font-sans: "Plus Jakarta Sans", ui-sans-serif, system-ui, -apple-system, sans-serif;
}

html {
  -webkit-text-size-adjust: 100%;
  scroll-behavior: smooth;
}
body {
  font-family: var(--font-sans);
  background: #ffffff;
  color: #1a1a1a;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  overflow-x: hidden;
  font-feature-settings: "ss01", "cv11";
}
a { color: inherit; text-decoration: none; }
button { font-family: inherit; cursor: pointer; }
input, select, textarea { font-family: inherit; }

/* ── Tighten heading letter spacing site-wide ── */
h1, h2, h3, h4 { letter-spacing: -0.028em; }

/* ── Card pattern: 1px border, hover to brand blue ── */
.card-link {
  display: flex; align-items: center; gap: 1rem;
  padding: 1rem 1.25rem;
  border: 1px solid #e5e7eb;
  border-radius: 0.75rem;
  background: #ffffff;
  transition: border-color .15s ease, background-color .15s ease;
}
.card-link:hover {
  border-color: #0620ed;
  background: #fafbff;
}

/* ── Tint tile (icon container) ── */
.icon-tile {
  display: grid; place-items: center;
  width: 2.75rem; height: 2.75rem;
  border-radius: 0.75rem;
  background: #eef2fe;
  color: #0620ed;
  flex-shrink: 0;
}

/* ── Button base ── */
.btn-primary {
  display: inline-flex; align-items: center; justify-content: center;
  gap: 0.5rem;
  padding: 0.75rem 1.25rem;
  border-radius: 0.75rem;
  background: #0620ed;
  color: #ffffff !important;
  font-weight: 700;
  font-size: 0.875rem;
  transition: background-color .15s ease;
}
.btn-primary:hover { background: #110176; }

/* ── Force white text on all colored buttons ── */
a[class*="bg-[#0620ed]"],
a[class*="bg-[#110176]"],
a[class*="bg-[#265bf6]"],
a[class*="bg-rose-600"],
a[class*="bg-slate-900"],
button[class*="bg-[#0620ed]"],
button[class*="bg-[#110176]"] {
  color: #ffffff !important;
}
a[class*="bg-[#0620ed]"] svg,
a[class*="bg-rose-600"] svg,
a[class*="bg-slate-900"] svg {
  color: #ffffff !important;
  stroke: #ffffff !important;
}

/* ── Prose ── */
.prose { font-size: 1rem; line-height: 1.75; color: #374151; }
.prose h1, .prose h2, .prose h3 { color: #111827; font-weight: 700; letter-spacing: -0.02em; }
.prose h2 { font-size: 1.25rem; margin: 2rem 0 0.75rem; padding-bottom: 0.5rem; border-bottom: 1px solid #e5e7eb; }
.prose h3 { font-size: 1.05rem; margin: 1.5rem 0 0.5rem; }
.prose h2:first-child, .prose h3:first-child { margin-top: 0; }
.prose p { margin-bottom: 1rem; }
.prose ul, .prose ol { padding-left: 1.25rem; margin-bottom: 1rem; }
.prose li { margin-bottom: 0.375rem; }
.prose li::marker { color: #0620ed; }
.prose code { background: #eef2fe; color: #110176; padding: 0.125rem 0.375rem; border-radius: 0.375rem; font-size: 0.85em; font-weight: 600; }
.prose strong { font-weight: 700; color: #111827; }
.prose table { width: 100%; border-collapse: collapse; margin: 1rem 0; font-size: 0.875rem; border: 1px solid #e5e7eb; border-radius: 0.5rem; overflow: hidden; }
.prose th { background: #f9fafb; text-align: left; padding: 0.625rem 0.75rem; font-weight: 700; color: #111827; border-bottom: 1px solid #e5e7eb; }
.prose td { padding: 0.625rem 0.75rem; border-top: 1px solid #e5e7eb; }
.prose a { color: #0620ed; text-decoration: underline; text-underline-offset: 2px; }

@keyframes fadeUp {
  from { opacity: 0; transform: translateY(10px); }
  to   { opacity: 1; transform: translateY(0); }
}
.animate-in { animation: fadeUp 0.45s cubic-bezier(0.16, 1, 0.3, 1) both; }
CSS

echo "  global.css — SME-style design system"

# ═══════════════════════════════════════════════
#  2. BaseLayout — cleaner SME-style header
# ═══════════════════════════════════════════════
cat > src/layouts/BaseLayout.astro <<'ASTRO'
---
import '../styles/global.css';
import Icon from '../components/Icon.astro';
import { url } from '../lib/url';

interface Props { title: string; description?: string; }
const {
  title,
  description = 'Free notes, past papers, guess papers, pairing schemes, quizzes and result gazettes for Pakistani students.',
} = Astro.props;

const path = Astro.url.pathname;

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
  <link rel="preload" as="style" href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" />
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" />
  <link rel="sitemap" href={url('/sitemap-index.xml')} />
</head>
<body class="min-h-screen bg-white">

  <!-- ═══ DESKTOP SIDEBAR ═══ -->
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
        <li>
          <a href={url('/')} class:list={[
            "flex items-center gap-3 rounded-lg px-3 py-2.5 text-[13.5px] font-semibold transition-colors",
            isActive('/') ? "bg-[#eef2fe] text-[#0620ed]" : "text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900",
          ]}>
            <Icon name="home" size={18} strokeWidth={2.1} class="shrink-0" />
            <span>Home</span>
          </a>
        </li>
        <li>
          <a href={url('/boards')} class:list={[
            "flex items-center gap-3 rounded-lg px-3 py-2.5 text-[13.5px] font-semibold transition-colors",
            isActive('/boards') ? "bg-[#eef2fe] text-[#0620ed]" : "text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900",
          ]}>
            <Icon name="graduation-cap" size={18} strokeWidth={2.1} class="shrink-0" />
            <span>Boards</span>
          </a>
        </li>
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

  <!-- ═══ MOBILE TOP BAR ═══ -->
  <header class="sticky top-0 z-30 flex h-16 w-full items-center gap-3 border-b border-neutral-200 bg-white px-4 lg:hidden">
    <button id="open-drawer" type="button" aria-label="Open menu" class="grid h-10 w-10 place-items-center rounded-lg text-neutral-700 active:bg-neutral-100">
      <Icon name="menu" size={22} strokeWidth={2.4} />
    </button>
    <a href={url('/')} class="flex items-center gap-2">
      <span class="grid h-8 w-8 place-items-center rounded-lg bg-[#0620ed] text-white">
        <Icon name="graduation-cap" size={17} strokeWidth={2.4} />
      </span>
      <span class="text-base font-extrabold tracking-tight text-neutral-900">TaleemHub</span>
    </a>
    <a href={url('/search')} class="ml-auto grid h-10 w-10 place-items-center rounded-lg text-neutral-700 active:bg-neutral-100" aria-label="Search">
      <Icon name="search" size={20} strokeWidth={2.4} />
    </a>
  </header>

  <!-- ═══ MOBILE DRAWER ═══ -->
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
          <li><a href={url('/')} class:list={["flex items-center gap-3 rounded-lg px-3 py-2.5 text-[13.5px] font-semibold transition-colors", isActive('/') ? "bg-[#eef2fe] text-[#0620ed]" : "text-neutral-600 hover:bg-neutral-100"]}><Icon name="home" size={18} strokeWidth={2.1} /><span>Home</span></a></li>
          <li><a href={url('/boards')} class:list={["flex items-center gap-3 rounded-lg px-3 py-2.5 text-[13.5px] font-semibold transition-colors", isActive('/boards') ? "bg-[#eef2fe] text-[#0620ed]" : "text-neutral-600 hover:bg-neutral-100"]}><Icon name="graduation-cap" size={18} strokeWidth={2.1} /><span>Boards</span></a></li>
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

  <!-- ═══ CONTENT ═══ -->
  <div class="lg:pl-[260px]">
    <main class="min-h-[60vh]"><slot /></main>

    <footer class="mt-20 border-t border-neutral-200 bg-neutral-50">
      <div class="mx-auto max-w-[1320px] px-4 py-14 lg:px-8">
        <div class="grid grid-cols-1 gap-10 sm:grid-cols-2 lg:grid-cols-4">
          <div class="sm:col-span-2">
            <div class="flex items-center gap-2.5">
              <span class="grid h-9 w-9 place-items-center rounded-lg bg-[#0620ed] text-white">
                <Icon name="graduation-cap" size={19} strokeWidth={2.4} />
              </span>
              <span class="text-lg font-extrabold tracking-tight text-neutral-900">TaleemHub</span>
            </div>
            <p class="mt-4 max-w-sm text-sm leading-relaxed text-neutral-500">
              Free notes, past papers, guess papers, and result gazettes for Pakistani students — organised by board and class.
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
        <div class="mt-12 border-t border-neutral-200 pt-6 text-xs text-neutral-400">
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
ASTRO

echo "  BaseLayout.astro — SME-style shell"

# ═══════════════════════════════════════════════
#  3. Home page — SME-style large tiles
# ═══════════════════════════════════════════════
cat > src/pages/index.astro <<'ASTRO'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { url } from '../lib/url';
import { BOARDS } from '../lib/boards';
import { getBoardCounts } from '../lib/boardContent';

const counts = await getBoardCounts();

const resources = [
  { href: '/notes',           icon: 'file-text',     label: 'Notes',           desc: 'Chapter-wise revision' },
  { href: '/past-papers',     icon: 'scroll-text',   label: 'Past Papers',     desc: 'Previous years solved' },
  { href: '/guess-papers',    icon: 'sparkles',      label: 'Guess Papers',    desc: 'Expected questions' },
  { href: '/pairing-schemes', icon: 'list',          label: 'Pairing Schemes', desc: 'Paper structure' },
  { href: '/quizzes',         icon: 'circle-help',   label: 'Quizzes',         desc: 'Practice MCQs' },
  { href: '/books',           icon: 'book-marked',   label: 'Books',           desc: 'Full textbooks' },
  { href: '/gazettes',        icon: 'newspaper',     label: 'Result Gazettes', desc: 'Board results' },
  { href: '/boards',          icon: 'graduation-cap',label: 'All Boards',      desc: 'Browse everything' },
];
---
<BaseLayout title="TaleemHub — Free Notes, Past Papers & Books for Pakistani Students">
  <!-- ═══ HERO ═══ -->
  <section class="border-b border-neutral-200">
    <div class="mx-auto max-w-[1320px] px-4 pt-14 pb-12 sm:px-6 sm:pt-20 sm:pb-16 lg:px-10 lg:pt-24 lg:pb-20">
      <div class="max-w-3xl">
        <div class="inline-flex items-center gap-2 rounded-full border border-neutral-200 bg-white px-3 py-1 text-xs font-bold uppercase tracking-wider text-neutral-600">
          <span class="h-1.5 w-1.5 rounded-full bg-[#0620ed]"></span>
          Free for every Pakistani student
        </div>
        <h1 class="mt-6 text-[2.5rem] font-extrabold leading-[1.05] tracking-[-0.035em] text-neutral-900 sm:text-6xl lg:text-[4rem]">
          Your complete<br />
          <span class="text-[#0620ed]">exam prep library.</span>
        </h1>
        <p class="mt-6 max-w-xl text-base leading-relaxed text-neutral-600 sm:text-lg">
          Notes, past papers, guess papers, pairing schemes and result gazettes — organised by board and class for Class 9 through 12.
        </p>

        <form action={url('/search')} method="get" role="search" class="mt-9 flex max-w-xl items-center gap-2 rounded-xl border border-neutral-300 bg-white p-1.5 pl-4 transition-colors focus-within:border-[#0620ed]">
          <Icon name="search" size={18} strokeWidth={2.4} class="shrink-0 text-neutral-400" />
          <input type="search" name="q" placeholder="Search notes, past papers, books..." class="min-w-0 flex-1 bg-transparent py-3 text-sm text-neutral-900 outline-none placeholder:text-neutral-400" />
          <button type="submit" class="rounded-lg bg-[#0620ed] px-5 py-3 text-sm font-bold text-white transition-colors hover:bg-[#110176]">
            Search
          </button>
        </form>
      </div>
    </div>
  </section>

  <!-- ═══ CHOOSE YOUR BOARD ═══ -->
  <section class="mx-auto max-w-[1320px] px-4 py-14 sm:px-6 lg:px-10 lg:py-20">
    <div class="mb-8">
      <h2 class="text-2xl font-extrabold tracking-tight text-neutral-900 sm:text-3xl">Choose your board</h2>
      <p class="mt-2 text-sm text-neutral-500">Every resource is organised for your specific board.</p>
    </div>

    <div class="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
      {BOARDS.map(b => (
        <a href={url(`/board/${b.slug}`)} class="card-link group">
          <span class="icon-tile">
            <Icon name="graduation-cap" size={22} strokeWidth={2.2} />
          </span>
          <div class="min-w-0 flex-1">
            <div class="text-base font-extrabold tracking-tight text-neutral-900">{b.name}</div>
            <div class="text-sm text-neutral-500">{counts[b.slug] || 0} {counts[b.slug] === 1 ? 'resource' : 'resources'}</div>
          </div>
          <Icon name="arrow-right" size={18} strokeWidth={2.4} class="shrink-0 text-neutral-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#0620ed]" />
        </a>
      ))}
    </div>
  </section>

  <!-- ═══ BROWSE BY RESOURCE ═══ -->
  <section class="border-t border-neutral-200 bg-neutral-50">
    <div class="mx-auto max-w-[1320px] px-4 py-14 sm:px-6 lg:px-10 lg:py-20">
      <div class="mb-8">
        <h2 class="text-2xl font-extrabold tracking-tight text-neutral-900 sm:text-3xl">Browse by resource</h2>
        <p class="mt-2 text-sm text-neutral-500">Eight content types, all free, all board-specific.</p>
      </div>

      <div class="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
        {resources.map(r => (
          <a href={url(r.href)} class="group flex flex-col rounded-xl border border-neutral-200 bg-white p-5 transition-colors hover:border-[#0620ed]">
            <span class="icon-tile">
              <Icon name={r.icon} size={20} strokeWidth={2.2} />
            </span>
            <div class="mt-4 text-sm font-extrabold tracking-tight text-neutral-900">{r.label}</div>
            <div class="mt-1 text-xs leading-snug text-neutral-500">{r.desc}</div>
          </a>
        ))}
      </div>
    </div>
  </section>

  <!-- ═══ TRUST STRIP ═══ -->
  <section class="border-t border-neutral-200">
    <div class="mx-auto max-w-[1320px] px-4 py-12 sm:px-6 lg:px-10">
      <div class="grid grid-cols-2 gap-6 sm:grid-cols-4">
        {[
          { label: 'Boards covered', value: '6' },
          { label: 'Classes', value: '9–12' },
          { label: 'Resource types', value: '7' },
          { label: 'Cost', value: 'Free' },
        ].map(s => (
          <div class="text-center">
            <div class="text-2xl font-extrabold tracking-tight text-neutral-900 sm:text-3xl">{s.value}</div>
            <div class="mt-1 text-xs font-semibold uppercase tracking-wider text-neutral-500">{s.label}</div>
          </div>
        ))}
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO

echo "  index.astro — SME-style home"

# ═══════════════════════════════════════════════
#  4. /boards hub page
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
  <div class="mx-auto max-w-[1320px] px-4 pt-12 pb-16 sm:px-6 lg:px-10 lg:pt-16">
    <nav class="mb-8 flex items-center gap-1.5 text-xs font-semibold text-neutral-400">
      <a href={url('/')} class="hover:text-[#0620ed]">Home</a>
      <span>/</span>
      <span class="text-neutral-500">Boards</span>
    </nav>

    <div class="max-w-2xl">
      <h1 class="text-4xl font-extrabold tracking-tight text-neutral-900 sm:text-5xl">All boards</h1>
      <p class="mt-4 text-base leading-relaxed text-neutral-600 sm:text-lg">
        Pick your board to find every note, past paper, guess paper and result gazette tailored to your syllabus.
      </p>
    </div>

    <div class="mt-10 grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
      {BOARDS.map(b => (
        <a href={url(`/board/${b.slug}`)} class="card-link group">
          <span class="icon-tile">
            <Icon name="graduation-cap" size={22} strokeWidth={2.2} />
          </span>
          <div class="min-w-0 flex-1">
            <div class="text-base font-extrabold tracking-tight text-neutral-900">{b.name}</div>
            <div class="text-sm text-neutral-500">{counts[b.slug] || 0} {counts[b.slug] === 1 ? 'resource' : 'resources'}</div>
          </div>
          <Icon name="arrow-right" size={18} strokeWidth={2.4} class="shrink-0 text-neutral-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#0620ed]" />
        </a>
      ))}
    </div>
  </div>
</BaseLayout>
ASTRO

echo "  boards.astro"

# ═══════════════════════════════════════════════
#  5. Verify — no dark gradients remain
# ═══════════════════════════════════════════════
echo ""
echo "Sweeping remaining dark gradients..."

python3 - <<'PY'
import pathlib, re

# Any class with a dark gradient goes → replace whole class attribute with a clean section
gradient_re = re.compile(r'class="([^"]*?bg-gradient-to-[^"]*?)"')

def is_dark(cls):
    if 'from-[#110176]' in cls or 'from-[#0620ed]' in cls or 'via-[#0620ed]' in cls:
        return True
    if re.search(r'from-\w+-9(00)?\b', cls): return True
    if re.search(r'from-(?:rose|blue|indigo|emerald|slate|neutral)-900', cls): return True
    return False

count = 0
for astro in pathlib.Path('src/pages').rglob('*.astro'):
    s = astro.read_text()
    orig = s

    def fix(m):
        global count
        cls = m.group(1)
        if is_dark(cls):
            count += 1
            return 'class="border-b border-neutral-200 pb-8 text-neutral-900"'
        return m.group(0)

    s = gradient_re.sub(fix, s)

    # Strip leftover dark-only text colors on white backgrounds
    s = s.replace('text-blue-100', 'text-neutral-500')
    s = s.replace('text-slate-300', 'text-neutral-600')

    if s != orig:
        astro.write_text(s)
        print(f'  cleaned: {astro.relative_to("src")}')

print(f'  {count} gradient heroes neutralized')
PY

# ═══════════════════════════════════════════════
#  6. Rebuild
# ═══════════════════════════════════════════════
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -10

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Push:"
echo ""
echo "    git add ."
echo "    git commit -m 'SME-style redesign: cleaner shell, tile navigation'"
echo "    git push"
echo ""
echo "  Then CLEAR CACHE and check:"
echo "    /"
echo "    /boards"
echo "    /board/punjab"
echo "    /notes"
echo "════════════════════════════════════════════"