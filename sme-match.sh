#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Matching Save My Exams interface"
echo "════════════════════════════════════════════"
echo ""

# ═══════════════════════════════════════════════
#  1. GLOBAL CSS — SME-grade flat design system
# ═══════════════════════════════════════════════
cat > src/styles/global.css <<'CSS'
@import "tailwindcss";

@theme {
  --font-sans: "Plus Jakarta Sans", ui-sans-serif, system-ui, -apple-system, sans-serif;
}

:root {
  --brand: #1d4ed8;
  --brand-dark: #1e3a8a;
  --brand-deep: #172554;
  --brand-tint: #eff4ff;
  --brand-line: #c7d7fe;

  --ink: #0f172a;
  --body: #334155;
  --muted: #64748b;
  --subtle: #94a3b8;

  --surface: #ffffff;
  --surface-2: #f8fafc;
  --surface-3: #f1f5f9;
  --bg: #ffffff;

  --line: #e5e9f0;
  --line-2: #cbd5e1;

  --r-xs: 6px;
  --r-sm: 8px;
  --r: 10px;
  --r-lg: 14px;
}

html {
  -webkit-text-size-adjust: 100%;
  scroll-behavior: smooth;
}

body {
  font-family: var(--font-sans);
  background: var(--bg);
  color: var(--body);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  overflow-x: hidden;
  font-feature-settings: "ss01", "cv11";
}

a { color: inherit; text-decoration: none; }
button { font-family: inherit; cursor: pointer; }
input, select, textarea { font-family: inherit; }

h1, h2, h3, h4 {
  color: var(--ink);
  letter-spacing: -0.03em;
  font-weight: 800;
  line-height: 1.15;
}

/* ═══ FLAT — kill every shadow ═══ */
*, *::before, *::after { box-shadow: none !important; }

/* ═══ SME-style pill badge ═══ */
.pill {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.35rem 0.85rem;
  border-radius: 999px;
  border: 1px solid var(--line);
  background: var(--surface);
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--muted);
  letter-spacing: 0.01em;
}
.pill-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--brand);
}

/* ═══ Card row — SME-style horizontal list ═══ */
.row {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.1rem 1.25rem;
  background: var(--surface);
  border: 1px solid var(--line);
  border-radius: var(--r);
  transition: border-color .15s ease, background-color .15s ease;
}
.row:hover {
  border-color: var(--brand);
  background: var(--brand-tint);
}

/* ═══ Icon tile — simple flat square ═══ */
.tile {
  display: grid;
  place-items: center;
  width: 2.5rem;
  height: 2.5rem;
  border-radius: var(--r-sm);
  background: var(--brand-tint);
  color: var(--brand);
  flex-shrink: 0;
  transition: background-color .15s ease, color .15s ease;
}
.row:hover .tile,
.tile-hover:hover .tile {
  background: var(--brand);
  color: #ffffff;
}

/* ═══ Buttons ═══ */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.75rem 1.25rem;
  border-radius: var(--r-sm);
  font-weight: 700;
  font-size: 0.875rem;
  letter-spacing: -0.005em;
  transition: background-color .15s ease, border-color .15s ease, color .15s ease;
}
.btn-primary {
  background: var(--brand);
  color: #ffffff !important;
  border: 1px solid var(--brand);
}
.btn-primary:hover {
  background: var(--brand-dark);
  border-color: var(--brand-dark);
}
.btn-outline {
  background: var(--surface);
  color: var(--ink);
  border: 1px solid var(--line-2);
}
.btn-outline:hover {
  border-color: var(--brand);
  color: var(--brand);
}

/* ═══ Force white text on colored buttons ═══ */
a[class*="bg-[#1d4ed8]"],
a[class*="bg-[#1e3a8a]"],
button[class*="bg-[#1d4ed8]"] {
  color: #ffffff !important;
}
a[class*="bg-[#1d4ed8]"] svg,
a[class*="bg-[#1e3a8a]"] svg,
button[class*="bg-[#1d4ed8]"] svg {
  color: #ffffff !important;
  stroke: #ffffff !important;
}

/* ═══ Section rhythm ═══ */
.section { padding: 4rem 0; }
@media (min-width: 768px) { .section { padding: 5.5rem 0; } }

.section-inner {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1.25rem;
}
@media (min-width: 640px) { .section-inner { padding: 0 1.75rem; } }
@media (min-width: 1024px) { .section-inner { padding: 0 2.5rem; } }

/* ═══ Focus rings ═══ */
input:focus-visible, button:focus-visible, a:focus-visible, [tabindex]:focus-visible {
  outline: 2px solid var(--brand);
  outline-offset: 2px;
}

/* ═══ Prose ═══ */
.prose { font-size: 1rem; line-height: 1.75; color: var(--body); }
.prose h1, .prose h2, .prose h3 { color: var(--ink); font-weight: 800; letter-spacing: -0.02em; }
.prose h2 { font-size: 1.25rem; margin: 2rem 0 0.75rem; padding-bottom: 0.5rem; border-bottom: 1px solid var(--line); }
.prose h3 { font-size: 1.05rem; margin: 1.5rem 0 0.5rem; }
.prose h2:first-child, .prose h3:first-child { margin-top: 0; }
.prose p { margin-bottom: 1rem; }
.prose ul, .prose ol { padding-left: 1.25rem; margin-bottom: 1rem; }
.prose li { margin-bottom: 0.375rem; }
.prose li::marker { color: var(--brand); }
.prose code { background: var(--brand-tint); color: var(--brand-deep); padding: 0.125rem 0.375rem; border-radius: var(--r-xs); font-size: 0.85em; font-weight: 600; }
.prose strong { font-weight: 700; color: var(--ink); }
.prose table { width: 100%; border-collapse: collapse; margin: 1rem 0; font-size: 0.875rem; border: 1px solid var(--line); border-radius: var(--r); overflow: hidden; }
.prose th { background: var(--surface-2); text-align: left; padding: 0.625rem 0.75rem; font-weight: 700; color: var(--ink); border-bottom: 1px solid var(--line); }
.prose td { padding: 0.625rem 0.75rem; border-top: 1px solid var(--line); }
.prose a { color: var(--brand); text-decoration: underline; text-underline-offset: 2px; }

/* ═══ Animations ═══ */
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(6px); }
  to   { opacity: 1; transform: translateY(0); }
}
@keyframes fadeIn {
  from { opacity: 0; }
  to   { opacity: 1; }
}
.animate-in { animation: fadeUp .4s cubic-bezier(.16, 1, .3, 1) both; }
.animate-fade { animation: fadeIn .25s ease both; }

@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: .01ms !important;
    transition-duration: .01ms !important;
  }
}

/* ═══ Numbered step — SME "Why it works" style ═══ */
.step-num {
  display: inline-grid;
  place-items: center;
  width: 2rem;
  height: 2rem;
  border-radius: 50%;
  background: var(--brand);
  color: #ffffff;
  font-weight: 800;
  font-size: 0.875rem;
  flex-shrink: 0;
}
CSS

echo "  global.css — SME design system"

# ═══════════════════════════════════════════════
#  2. BaseLayout — SME-style sidebar
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
  <meta name="theme-color" content="#1d4ed8" />
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
  <aside class="fixed inset-y-0 left-0 z-40 hidden w-[250px] flex-col border-r border-slate-200 bg-white lg:flex">
    <a href={url('/')} class="flex h-16 shrink-0 items-center gap-2.5 border-b border-slate-200 px-5">
      <span class="grid h-8 w-8 place-items-center rounded-md bg-[#1d4ed8] text-white">
        <Icon name="graduation-cap" size={17} strokeWidth={2.4} />
      </span>
      <span class="text-[15px] font-extrabold tracking-tight text-slate-900">TaleemHub</span>
    </a>

    <nav class="flex-1 overflow-y-auto px-3 py-4">
      <div class="mb-1.5 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-slate-400">Browse</div>
      <ul class="space-y-px">
        <li>
          <a href={url('/')} class:list={[
            "flex items-center gap-3 rounded-md px-3 py-2 text-[13.5px] font-semibold transition-colors",
            isActive('/') ? "bg-[#eff4ff] text-[#1d4ed8]" : "text-slate-600 hover:bg-slate-100 hover:text-slate-900",
          ]}>
            <Icon name="home" size={17} strokeWidth={2.1} class="shrink-0" />
            <span>Home</span>
          </a>
        </li>
        <li>
          <a href={url('/boards')} class:list={[
            "flex items-center gap-3 rounded-md px-3 py-2 text-[13.5px] font-semibold transition-colors",
            isActive('/boards') ? "bg-[#eff4ff] text-[#1d4ed8]" : "text-slate-600 hover:bg-slate-100 hover:text-slate-900",
          ]}>
            <Icon name="graduation-cap" size={17} strokeWidth={2.1} class="shrink-0" />
            <span>Boards</span>
          </a>
        </li>
      </ul>

      <div class="mt-5 mb-1.5 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-slate-400">Study Material</div>
      <ul class="space-y-px">
        {navStudy.map(item => (
          <li>
            <a href={url(item.href)} class:list={[
              "flex items-center gap-3 rounded-md px-3 py-2 text-[13.5px] font-semibold transition-colors",
              isActive(item.href) ? "bg-[#eff4ff] text-[#1d4ed8]" : "text-slate-600 hover:bg-slate-100 hover:text-slate-900",
            ]}>
              <Icon name={item.icon} size={17} strokeWidth={2.1} class="shrink-0" />
              <span>{item.label}</span>
            </a>
          </li>
        ))}
      </ul>

      <div class="mt-5 mb-1.5 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-slate-400">Exams</div>
      <ul class="space-y-px">
        {navExam.map(item => (
          <li>
            <a href={url(item.href)} class:list={[
              "flex items-center gap-3 rounded-md px-3 py-2 text-[13.5px] font-semibold transition-colors",
              isActive(item.href) ? "bg-[#eff4ff] text-[#1d4ed8]" : "text-slate-600 hover:bg-slate-100 hover:text-slate-900",
            ]}>
              <Icon name={item.icon} size={17} strokeWidth={2.1} class="shrink-0" />
              <span>{item.label}</span>
            </a>
          </li>
        ))}
      </ul>
    </nav>

    <div class="border-t border-slate-200 p-3">
      <form action={url('/search')} method="get" role="search" class="flex items-center gap-2 rounded-md border border-slate-200 bg-slate-50 px-3 py-2 focus-within:border-[#1d4ed8] focus-within:bg-white">
        <Icon name="search" size={14} strokeWidth={2.3} class="shrink-0 text-slate-400" />
        <input type="search" name="q" placeholder="Search library" class="min-w-0 flex-1 bg-transparent text-[13px] font-medium text-slate-900 outline-none placeholder:text-slate-400" />
      </form>
    </div>
  </aside>

  <!-- ═══ MOBILE TOP BAR ═══ -->
  <header class="sticky top-0 z-30 flex h-14 w-full items-center gap-3 border-b border-slate-200 bg-white px-4 lg:hidden">
    <button id="open-drawer" type="button" aria-label="Open menu" class="grid h-9 w-9 place-items-center rounded-md text-slate-700 active:bg-slate-100">
      <Icon name="menu" size={20} strokeWidth={2.4} />
    </button>
    <a href={url('/')} class="flex items-center gap-2">
      <span class="grid h-7 w-7 place-items-center rounded-md bg-[#1d4ed8] text-white">
        <Icon name="graduation-cap" size={15} strokeWidth={2.4} />
      </span>
      <span class="text-[15px] font-extrabold tracking-tight text-slate-900">TaleemHub</span>
    </a>
    <a href={url('/search')} class="ml-auto grid h-9 w-9 place-items-center rounded-md text-slate-700 active:bg-slate-100" aria-label="Search">
      <Icon name="search" size={19} strokeWidth={2.4} />
    </a>
  </header>

  <!-- ═══ MOBILE DRAWER ═══ -->
  <div id="drawer" class="fixed inset-0 z-50 hidden lg:hidden">
    <div id="drawer-backdrop" class="absolute inset-0 bg-slate-900/40 opacity-0 transition-opacity duration-300"></div>
    <aside id="drawer-panel" class="absolute inset-y-0 left-0 flex w-[270px] -translate-x-full flex-col border-r border-slate-200 bg-white transition-transform duration-300 ease-out">
      <div class="flex h-16 shrink-0 items-center justify-between border-b border-slate-200 px-4">
        <a href={url('/')} class="flex items-center gap-2.5">
          <span class="grid h-8 w-8 place-items-center rounded-md bg-[#1d4ed8] text-white">
            <Icon name="graduation-cap" size={17} strokeWidth={2.4} />
          </span>
          <span class="text-[15px] font-extrabold tracking-tight text-slate-900">TaleemHub</span>
        </a>
        <button id="close-drawer" type="button" aria-label="Close" class="grid h-8 w-8 place-items-center rounded-md text-slate-500 active:bg-slate-100">
          <Icon name="x" size={17} strokeWidth={2.4} />
        </button>
      </div>
      <nav class="flex-1 overflow-y-auto px-3 py-4">
        <div class="mb-1.5 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-slate-400">Browse</div>
        <ul class="space-y-px">
          <li><a href={url('/')} class:list={["flex items-center gap-3 rounded-md px-3 py-2 text-[13.5px] font-semibold transition-colors", isActive('/') ? "bg-[#eff4ff] text-[#1d4ed8]" : "text-slate-600 hover:bg-slate-100"]}><Icon name="home" size={17} strokeWidth={2.1} /><span>Home</span></a></li>
          <li><a href={url('/boards')} class:list={["flex items-center gap-3 rounded-md px-3 py-2 text-[13.5px] font-semibold transition-colors", isActive('/boards') ? "bg-[#eff4ff] text-[#1d4ed8]" : "text-slate-600 hover:bg-slate-100"]}><Icon name="graduation-cap" size={17} strokeWidth={2.1} /><span>Boards</span></a></li>
        </ul>
        <div class="mt-5 mb-1.5 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-slate-400">Study Material</div>
        <ul class="space-y-px">
          {navStudy.map(item => (
            <li><a href={url(item.href)} class:list={["flex items-center gap-3 rounded-md px-3 py-2 text-[13.5px] font-semibold transition-colors", isActive(item.href) ? "bg-[#eff4ff] text-[#1d4ed8]" : "text-slate-600 hover:bg-slate-100"]}><Icon name={item.icon} size={17} strokeWidth={2.1} /><span>{item.label}</span></a></li>
          ))}
        </ul>
        <div class="mt-5 mb-1.5 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-slate-400">Exams</div>
        <ul class="space-y-px">
          {navExam.map(item => (
            <li><a href={url(item.href)} class:list={["flex items-center gap-3 rounded-md px-3 py-2 text-[13.5px] font-semibold transition-colors", isActive(item.href) ? "bg-[#eff4ff] text-[#1d4ed8]" : "text-slate-600 hover:bg-slate-100"]}><Icon name={item.icon} size={17} strokeWidth={2.1} /><span>{item.label}</span></a></li>
          ))}
        </ul>
      </nav>
      <div class="border-t border-slate-200 p-3">
        <form action={url('/search')} method="get" role="search" class="flex items-center gap-2 rounded-md border border-slate-200 bg-slate-50 px-3 py-2">
          <Icon name="search" size={14} strokeWidth={2.3} class="shrink-0 text-slate-400" />
          <input type="search" name="q" placeholder="Search library" class="min-w-0 flex-1 bg-transparent text-[13px] font-medium text-slate-900 outline-none placeholder:text-slate-400" />
        </form>
      </div>
    </aside>
  </div>

  <!-- ═══ CONTENT ═══ -->
  <div class="lg:pl-[250px]">
    <main class="min-h-[60vh]"><slot /></main>

    <footer class="mt-20 border-t border-slate-200 bg-slate-50">
      <div class="mx-auto max-w-[1200px] px-5 py-12 lg:px-10">
        <div class="grid grid-cols-1 gap-10 sm:grid-cols-2 lg:grid-cols-4">
          <div class="sm:col-span-2">
            <div class="flex items-center gap-2.5">
              <span class="grid h-8 w-8 place-items-center rounded-md bg-[#1d4ed8] text-white">
                <Icon name="graduation-cap" size={17} strokeWidth={2.4} />
              </span>
              <span class="text-[15px] font-extrabold tracking-tight text-slate-900">TaleemHub</span>
            </div>
            <p class="mt-4 max-w-sm text-sm leading-relaxed text-slate-500">
              Free notes, past papers, guess papers, and result gazettes for Pakistani students — organised by board and class.
            </p>
          </div>
          <div>
            <h4 class="text-[13px] font-bold text-slate-900">Study</h4>
            <ul class="mt-3.5 space-y-2 text-sm text-slate-500">
              <li><a href={url('/boards')} class="hover:text-[#1d4ed8]">Boards</a></li>
              <li><a href={url('/notes')} class="hover:text-[#1d4ed8]">Notes</a></li>
              <li><a href={url('/quizzes')} class="hover:text-[#1d4ed8]">Quizzes</a></li>
              <li><a href={url('/books')} class="hover:text-[#1d4ed8]">Books</a></li>
            </ul>
          </div>
          <div>
            <h4 class="text-[13px] font-bold text-slate-900">Exams</h4>
            <ul class="mt-3.5 space-y-2 text-sm text-slate-500">
              <li><a href={url('/past-papers')} class="hover:text-[#1d4ed8]">Past Papers</a></li>
              <li><a href={url('/guess-papers')} class="hover:text-[#1d4ed8]">Guess Papers</a></li>
              <li><a href={url('/pairing-schemes')} class="hover:text-[#1d4ed8]">Pairing Schemes</a></li>
              <li><a href={url('/gazettes')} class="hover:text-[#1d4ed8]">Result Gazettes</a></li>
            </ul>
          </div>
        </div>
        <div class="mt-10 border-t border-slate-200 pt-6 text-xs text-slate-400">
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

echo "  BaseLayout — SME-style shell"

# ═══════════════════════════════════════════════
#  3. Home page — SME structure
# ═══════════════════════════════════════════════
cat > src/pages/index.astro <<'ASTRO'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { url } from '../lib/url';
import { BOARDS } from '../lib/boards';
import { getBoardCounts } from '../lib/boardContent';

const counts = await getBoardCounts();
---
<BaseLayout title="TaleemHub — Free Notes, Past Papers & Books for Pakistani Students">
  <!-- ═══ HERO — centered, SME style ═══ -->
  <section class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-16 pb-14 sm:pt-24 sm:pb-20 lg:px-10 lg:pt-28 lg:pb-24">
      <div class="mx-auto max-w-3xl text-center">
        <div class="pill mx-auto">
          <span class="pill-dot"></span>
          Trusted by students across Pakistan
        </div>
        <h1 class="mt-6 text-[2.5rem] font-extrabold leading-[1.05] tracking-[-0.04em] text-slate-900 sm:text-[3.5rem] lg:text-[4rem]">
          Exam-specific revision,<br />
          made by trusted educators
        </h1>
        <p class="mx-auto mt-6 max-w-xl text-base leading-relaxed text-slate-600 sm:text-lg">
          Notes, past papers, guess papers, pairing schemes and result gazettes — organised for your board and class from 9 to 12.
        </p>

        <form action={url('/search')} method="get" role="search" class="mx-auto mt-9 flex max-w-xl items-center gap-2 rounded-lg border border-slate-300 bg-white p-1.5 pl-4 transition-colors focus-within:border-[#1d4ed8]">
          <Icon name="search" size={18} strokeWidth={2.4} class="shrink-0 text-slate-400" />
          <input type="search" name="q" placeholder="Search notes, past papers, books..." class="min-w-0 flex-1 bg-transparent py-3 text-sm text-slate-900 outline-none placeholder:text-slate-400" />
          <button type="submit" class="btn btn-primary">Search</button>
        </form>

        <div class="mt-6 flex flex-wrap items-center justify-center gap-x-5 gap-y-2 text-sm font-medium text-slate-500">
          <span class="flex items-center gap-1.5"><Icon name="check" size={14} strokeWidth={2.6} class="text-[#1d4ed8]" /> 6 boards</span>
          <span class="h-1 w-1 rounded-full bg-slate-300"></span>
          <span class="flex items-center gap-1.5"><Icon name="check" size={14} strokeWidth={2.6} class="text-[#1d4ed8]" /> Class 9–12</span>
          <span class="h-1 w-1 rounded-full bg-slate-300"></span>
          <span class="flex items-center gap-1.5"><Icon name="check" size={14} strokeWidth={2.6} class="text-[#1d4ed8]" /> 100% free</span>
        </div>
      </div>
    </div>
  </section>

  <!-- ═══ WHY IT WORKS — SME numbered steps ═══ -->
  <section class="section border-b border-slate-200">
    <div class="section-inner">
      <div class="mx-auto max-w-2xl text-center">
        <h2 class="text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Why it works</h2>
        <p class="mt-3 text-base text-slate-600">Everything is built around your exam board — nothing more, nothing less.</p>
      </div>

      <div class="mx-auto mt-12 grid max-w-3xl grid-cols-1 gap-10 sm:grid-cols-3 sm:gap-8">
        <div class="flex flex-col items-start gap-4 sm:items-center sm:text-center">
          <span class="step-num">1</span>
          <h3 class="text-base font-extrabold tracking-tight text-slate-900">Revise only what you need</h3>
          <p class="text-sm leading-relaxed text-slate-600">Every resource is written for your specific board and class, so you only revise what's on your paper.</p>
        </div>
        <div class="flex flex-col items-start gap-4 sm:items-center sm:text-center">
          <span class="step-num">2</span>
          <h3 class="text-base font-extrabold tracking-tight text-slate-900">Test yourself and check progress</h3>
          <p class="text-sm leading-relaxed text-slate-600">Practice with past papers and interactive quizzes so you walk into your exam hall with confidence.</p>
        </div>
        <div class="flex flex-col items-start gap-4 sm:items-center sm:text-center">
          <span class="step-num">3</span>
          <h3 class="text-base font-extrabold tracking-tight text-slate-900">Improve answer by answer</h3>
          <p class="text-sm leading-relaxed text-slate-600">See exactly which topics carry the most marks, from pairing schemes and examiner trends.</p>
        </div>
      </div>
    </div>
  </section>

  <!-- ═══ WHAT ARE YOU STUDYING? — SME board list ═══ -->
  <section class="section">
    <div class="section-inner">
      <div class="mx-auto max-w-2xl text-center">
        <h2 class="text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">What are you studying?</h2>
        <p class="mt-3 text-base text-slate-600">Choose your board to get started.</p>
      </div>

      <div class="mx-auto mt-10 grid max-w-3xl grid-cols-1 gap-3 sm:grid-cols-2">
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
  </section>

  <!-- ═══ RESOURCES ═══ -->
  <section class="border-t border-slate-200 bg-slate-50">
    <div class="section-inner">
      <div class="mx-auto max-w-2xl text-center">
        <h2 class="text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Everything you need, in one place</h2>
        <p class="mt-3 text-base text-slate-600">Seven content types, all free, all board-specific.</p>
      </div>

      <div class="mx-auto mt-10 grid max-w-4xl grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
        {[
          { href: '/notes',           icon: 'file-text',     label: 'Notes' },
          { href: '/past-papers',     icon: 'scroll-text',   label: 'Past Papers' },
          { href: '/guess-papers',    icon: 'sparkles',      label: 'Guess Papers' },
          { href: '/pairing-schemes', icon: 'list',          label: 'Pairing Schemes' },
          { href: '/quizzes',         icon: 'circle-help',   label: 'Quizzes' },
          { href: '/books',           icon: 'book-marked',   label: 'Books' },
          { href: '/gazettes',        icon: 'newspaper',     label: 'Result Gazettes' },
          { href: '/boards',          icon: 'graduation-cap', label: 'All Boards' },
        ].map(r => (
          <a href={url(r.href)} class="row group">
            <span class="tile">
              <Icon name={r.icon} size={18} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <div class="text-sm font-extrabold tracking-tight text-slate-900">{r.label}</div>
            </div>
          </a>
        ))}
      </div>
    </div>
  </section>

  <!-- ═══ TRUST STATS ═══ -->
  <section class="section border-t border-slate-200">
    <div class="section-inner">
      <div class="mx-auto grid max-w-3xl grid-cols-2 gap-6 sm:grid-cols-4">
        {[
          { label: 'Boards covered', value: '6' },
          { label: 'Classes', value: '9–12' },
          { label: 'Resource types', value: '7' },
          { label: 'Cost', value: 'Free' },
        ].map(s => (
          <div class="text-center">
            <div class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">{s.value}</div>
            <div class="mt-1.5 text-xs font-semibold uppercase tracking-wider text-slate-500">{s.label}</div>
          </div>
        ))}
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO

echo "  index.astro — SME structure"

# ═══════════════════════════════════════════════
#  4. Sweep any remaining gradient/shadow classes
# ═══════════════════════════════════════════════
python3 - <<'PY'
import pathlib, re

shadow_re = re.compile(r'\b(shadow-sm|shadow-md|shadow-lg|shadow-xl|shadow-2xl|shadow-inner)\b')
gradient_re = re.compile(r'class="([^"]*?bg-gradient-to-[^"]*?)"')

def is_dark(cls):
    return ('from-[#110176]' in cls or 'from-[#0620ed]' in cls or
            'from-[#1d4ed8]' in cls or
            bool(re.search(r'from-\w+-9(00)?\b', cls)))

count = 0
for astro in pathlib.Path('src/pages').rglob('*.astro'):
    s = astro.read_text()
    orig = s
    s = shadow_re.sub('', s)
    def fix(m):
        return 'class="border-b border-slate-200 pb-8 text-slate-900"' if is_dark(m.group(1)) else m.group(0)
    s = gradient_re.sub(fix, s)
    s = s.replace('text-blue-100', 'text-slate-500').replace('text-slate-300', 'text-slate-600')
    if s != orig:
        astro.write_text(s)
        count += 1
print(f'  {count} pages cleaned')
PY

# ═══════════════════════════════════════════════
#  5. Rebuild
# ═══════════════════════════════════════════════
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -8

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Push:"
echo ""
echo "    git add ."
echo "    git commit -m 'SME-style interface: centered hero, editorial sections'"
echo "    git push"
echo ""
echo "  Then CLEAR CACHE and open in Incognito:"
echo "    https://malikjeerajajee-coder.github.io/My-edu-site/"
echo "════════════════════════════════════════════"