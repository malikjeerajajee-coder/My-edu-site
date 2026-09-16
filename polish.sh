#!/bin/bash
set -e

echo "Applying refined typography + design system..."

# ============ 1. SWAP SLATE → STONE (warmer neutrals) ============
find src -name "*.astro" -type f -exec sed -i \
  -e 's/slate-50\b/stone-50/g' \
  -e 's/slate-100\b/stone-100/g' \
  -e 's/slate-200\b/stone-200/g' \
  -e 's/slate-300\b/stone-300/g' \
  -e 's/slate-400\b/stone-400/g' \
  -e 's/slate-500\b/stone-500/g' \
  -e 's/slate-600\b/stone-600/g' \
  -e 's/slate-700\b/stone-700/g' \
  -e 's/slate-800\b/stone-800/g' \
  -e 's/slate-900\b/stone-900/g' \
  {} \;
echo "  Neutrals swapped: slate → stone"

# ============ 2. GLOBAL CSS ============
cat > src/styles/global.css <<'CSS'
@import "tailwindcss";

@theme {
  --font-sans: "Geist", ui-sans-serif, system-ui, -apple-system, sans-serif;
  --font-display: "Instrument Serif", Georgia, "Times New Roman", serif;
}

html {
  -webkit-text-size-adjust: 100%;
  scroll-behavior: smooth;
}
body {
  font-family: var(--font-sans);
  background-color: #fafaf9;
  color: #1c1917;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  overflow-x: hidden;
  font-feature-settings: "cv11", "ss01";
}
a { color: inherit; text-decoration: none; }
button { font-family: inherit; cursor: pointer; }
input, select, textarea { font-family: inherit; }

.font-display {
  font-family: var(--font-display);
  font-weight: 400;
  letter-spacing: -0.02em;
}

/* Prose */
.prose { font-size: 1rem; line-height: 1.75; color: #44403c; }
.prose h1, .prose h2, .prose h3 {
  color: #1c1917;
  font-family: var(--font-sans);
  font-weight: 700;
  letter-spacing: -0.025em;
}
.prose h2 { font-size: 1.25rem; margin-top: 2.25rem; margin-bottom: 0.75rem; padding-bottom: 0.6rem; border-bottom: 1px solid #e7e5e4; }
.prose h3 { font-size: 1.05rem; margin-top: 1.75rem; margin-bottom: 0.5rem; }
.prose h2:first-child, .prose h3:first-child { margin-top: 0; }
.prose p { margin-bottom: 1.1rem; }
.prose ul, .prose ol { padding-left: 1.4rem; margin-bottom: 1.1rem; }
.prose li { margin-bottom: 0.4rem; }
.prose li::marker { color: #4f46e5; }
.prose code {
  background: #eef2ff; color: #4338ca;
  padding: 0.15rem 0.4rem; border-radius: 0.375rem;
  font-size: 0.85em; font-weight: 600;
  font-family: ui-monospace, "SF Mono", Menlo, monospace;
}
.prose strong { font-weight: 700; color: #1c1917; }
.prose table { width: 100%; border-collapse: collapse; margin: 1.25rem 0; font-size: 0.9rem; border: 1px solid #e7e5e4; border-radius: 0.5rem; overflow: hidden; }
.prose th { background: #fafaf9; text-align: left; padding: 0.75rem; font-weight: 700; color: #1c1917; border-bottom: 1px solid #e7e5e4; }
.prose td { padding: 0.75rem; border-top: 1px solid #e7e5e4; }
.prose a { color: #4f46e5; text-decoration: underline; text-underline-offset: 2px; }

@keyframes fadeUp {
  from { opacity: 0; transform: translateY(14px); }
  to   { opacity: 1; transform: translateY(0); }
}
@keyframes fadeIn {
  from { opacity: 0; }
  to   { opacity: 1; }
}
.animate-in { animation: fadeUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) both; }
CSS

# ============ 3. BASE LAYOUT (refined sidebar) ============
cat > src/layouts/BaseLayout.astro <<'EOF'
---
import '../styles/global.css';
import Icon from '../components/Icon.astro';

interface Props { title: string; description?: string; }
const {
  title,
  description = 'Free notes, interactive quizzes, textbooks and result gazettes for Pakistani students.',
} = Astro.props;

const path = Astro.url.pathname;

const navMain = [
  { href: '/',         label: 'Home',     icon: 'home' },
  { href: '/classes',  label: 'Classes',  icon: 'graduation-cap' },
  { href: '/subjects', label: 'Subjects', icon: 'library' },
];
const navLibrary = [
  { href: '/notes',    label: 'Notes',    icon: 'book-open' },
  { href: '/quizzes',  label: 'Quizzes',  icon: 'circle-help' },
  { href: '/books',    label: 'Books',    icon: 'book-marked' },
  { href: '/gazettes', label: 'Gazettes', icon: 'newspaper' },
];

const mobileNav = [
  { href: '/',         label: 'Home',     icon: 'home' },
  { href: '/classes',  label: 'Classes',  icon: 'graduation-cap' },
  { href: '/notes',    label: 'Notes',    icon: 'book-open' },
  { href: '/quizzes',  label: 'Quizzes',  icon: 'circle-help' },
  { href: '/books',    label: 'Books',    icon: 'library' },
];

const isActive = (href: string) => href === '/' ? path === '/' : path.startsWith(href);
---
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
  <meta name="theme-color" content="#4f46e5" />
  <title>{title}</title>
  <meta name="description" content={description} />
  <meta property="og:title" content={title} />
  <meta property="og:description" content={description} />
  <meta property="og:type" content="website" />
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Geist:wght@400;500;600;700;800&family=Instrument+Serif:ital@0;1&display=swap" />
  <link rel="sitemap" href="/sitemap-index.xml" />
</head>
<body class="min-h-screen bg-stone-50">

  <!-- ═══ DESKTOP SIDEBAR ═══ -->
  <aside class="fixed inset-y-0 left-0 z-40 hidden w-[240px] flex-col border-r border-stone-200 bg-white lg:flex">
    <a href="/" class="flex h-[68px] shrink-0 items-center gap-2.5 border-b border-stone-200 px-5">
      <span class="grid h-9 w-9 place-items-center rounded-xl bg-stone-900 text-white">
        <Icon name="graduation-cap" size={19} strokeWidth={2.2} />
      </span>
      <span class="font-display text-xl tracking-tight text-stone-900">TaleemHub</span>
    </a>

    <nav class="flex-1 overflow-y-auto px-3 py-6">
      <div class="mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.12em] text-stone-400">Main</div>
      <ul class="space-y-px">
        {navMain.map(item => (
          <li>
            <a
              href={item.href}
              class:list={[
                "group flex items-center gap-3 rounded-lg px-3 py-2 text-[13.5px] font-semibold transition-colors",
                isActive(item.href)
                  ? "bg-stone-900 text-white"
                  : "text-stone-600 hover:bg-stone-100 hover:text-stone-900",
              ]}
            >
              <Icon name={item.icon} size={17} strokeWidth={2.1} />
              <span>{item.label}</span>
            </a>
          </li>
        ))}
      </ul>

      <div class="mt-7 mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.12em] text-stone-400">Library</div>
      <ul class="space-y-px">
        {navLibrary.map(item => (
          <li>
            <a
              href={item.href}
              class:list={[
                "group flex items-center gap-3 rounded-lg px-3 py-2 text-[13.5px] font-semibold transition-colors",
                isActive(item.href)
                  ? "bg-stone-900 text-white"
                  : "text-stone-600 hover:bg-stone-100 hover:text-stone-900",
              ]}
            >
              <Icon name={item.icon} size={17} strokeWidth={2.1} />
              <span>{item.label}</span>
            </a>
          </li>
        ))}
      </ul>
    </nav>

    <div class="border-t border-stone-200 p-3">
      <a href="/search" class="flex items-center gap-2.5 rounded-lg border border-stone-200 bg-stone-50 px-3 py-2.5 text-[13px] font-medium text-stone-500 transition-colors hover:border-stone-300 hover:bg-white hover:text-stone-900">
        <Icon name="search" size={15} strokeWidth={2.2} />
        <span>Search library</span>
      </a>
    </div>
  </aside>

  <!-- ═══ MOBILE HEADER ═══ -->
  <header class="sticky top-0 z-30 flex h-16 w-full items-center gap-3 border-b border-stone-200 bg-white/90 px-4 backdrop-blur-xl lg:hidden">
    <button
      id="open-drawer"
      type="button"
      aria-label="Open menu"
      class="grid h-10 w-10 place-items-center rounded-xl border border-stone-200 bg-white text-stone-700 transition-colors active:bg-stone-100"
    >
      <Icon name="menu" size={20} strokeWidth={2.2} />
    </button>
    <a href="/" class="flex items-center gap-2">
      <span class="grid h-8 w-8 place-items-center rounded-lg bg-stone-900 text-white">
        <Icon name="graduation-cap" size={17} strokeWidth={2.2} />
      </span>
      <span class="font-display text-lg tracking-tight text-stone-900">TaleemHub</span>
    </a>
    <a
      href="/search"
      class="ml-auto grid h-10 w-10 place-items-center rounded-xl border border-stone-200 bg-white text-stone-700 transition-colors active:bg-stone-100"
      aria-label="Search"
    >
      <Icon name="search" size={18} strokeWidth={2.2} />
    </a>
  </header>

  <!-- ═══ MOBILE DRAWER ═══ -->
  <div id="drawer" class="fixed inset-0 z-50 hidden lg:hidden" aria-hidden="true">
    <div id="drawer-backdrop" class="absolute inset-0 bg-stone-900/40 backdrop-blur-sm"></div>
    <aside id="drawer-panel" class="absolute inset-y-0 left-0 flex w-[280px] flex-col border-r border-stone-200 bg-white -translate-x-full transition-transform duration-300 ease-out">
      <div class="flex h-[68px] shrink-0 items-center justify-between border-b border-stone-200 px-4">
        <a href="/" class="flex items-center gap-2.5">
          <span class="grid h-9 w-9 place-items-center rounded-xl bg-stone-900 text-white">
            <Icon name="graduation-cap" size={19} strokeWidth={2.2} />
          </span>
          <span class="font-display text-xl tracking-tight text-stone-900">TaleemHub</span>
        </a>
        <button
          id="close-drawer"
          type="button"
          aria-label="Close menu"
          class="grid h-9 w-9 place-items-center rounded-lg text-stone-500 transition-colors active:bg-stone-100"
        >
          <Icon name="x" size={18} strokeWidth={2.2} />
        </button>
      </div>

      <nav class="flex-1 overflow-y-auto px-3 py-6">
        <div class="mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.12em] text-stone-400">Main</div>
        <ul class="space-y-px">
          {navMain.map(item => (
            <li>
              <a href={item.href} class:list={[
                "flex items-center gap-3 rounded-lg px-3 py-2 text-[13.5px] font-semibold transition-colors",
                isActive(item.href) ? "bg-stone-900 text-white" : "text-stone-600 hover:bg-stone-100",
              ]}>
                <Icon name={item.icon} size={17} strokeWidth={2.1} />
                <span>{item.label}</span>
              </a>
            </li>
          ))}
        </ul>

        <div class="mt-7 mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.12em] text-stone-400">Library</div>
        <ul class="space-y-px">
          {navLibrary.map(item => (
            <li>
              <a href={item.href} class:list={[
                "flex items-center gap-3 rounded-lg px-3 py-2 text-[13.5px] font-semibold transition-colors",
                isActive(item.href) ? "bg-stone-900 text-white" : "text-stone-600 hover:bg-stone-100",
              ]}>
                <Icon name={item.icon} size={17} strokeWidth={2.1} />
                <span>{item.label}</span>
              </a>
            </li>
          ))}
        </ul>
      </nav>
    </aside>
  </div>

  <!-- ═══ CONTENT ═══ -->
  <div class="lg:pl-[240px]">
    <main class="min-h-screen pb-32 lg:pb-0">
      <slot />
    </main>

    <footer class="mt-24 hidden border-t border-stone-200 bg-white lg:block">
      <div class="mx-auto max-w-6xl px-6 py-10 lg:px-10">
        <div class="flex flex-col items-start justify-between gap-6 sm:flex-row sm:items-center">
          <div class="flex items-center gap-2.5">
            <span class="grid h-8 w-8 place-items-center rounded-lg bg-stone-900 text-white">
              <Icon name="graduation-cap" size={17} strokeWidth={2.2} />
            </span>
            <span class="font-display text-lg tracking-tight text-stone-900">TaleemHub</span>
          </div>
          <p class="text-xs text-stone-400">© {new Date().getFullYear()} TaleemHub — Made in Pakistan, forever free.</p>
        </div>
      </div>
    </footer>
  </div>

  <!-- ═══ MOBILE BOTTOM NAV ═══ -->
  <nav class="fixed inset-x-0 bottom-0 z-30 border-t border-stone-200 bg-white/95 backdrop-blur-lg lg:hidden">
    <div class="flex items-stretch px-1 pt-2.5" style="padding-bottom: calc(env(safe-area-inset-bottom, 0px) + 26px);">
      {mobileNav.map(item => (
        <a
          href={item.href}
          class:list={[
            "flex min-w-0 flex-1 flex-col items-center gap-1 px-1 text-[10.5px] font-semibold leading-none transition-colors",
            isActive(item.href) ? "text-indigo-600" : "text-stone-400",
          ]}
        >
          <Icon name={item.icon} size={19} strokeWidth={2.2} />
          <span class="truncate">{item.label}</span>
        </a>
      ))}
    </div>
  </nav>

  <script is:inline>
    (function () {
      var drawer = document.getElementById('drawer');
      var panel = document.getElementById('drawer-panel');
      var backdrop = document.getElementById('drawer-backdrop');
      var openBtn = document.getElementById('open-drawer');
      var closeBtn = document.getElementById('close-drawer');

      function open() {
        if (!drawer) return;
        drawer.classList.remove('hidden');
        drawer.setAttribute('aria-hidden', 'false');
        document.body.style.overflow = 'hidden';
        requestAnimationFrame(function () { panel.classList.remove('-translate-x-full'); });
      }
      function close() {
        if (!drawer) return;
        panel.classList.add('-translate-x-full');
        setTimeout(function () {
          drawer.classList.add('hidden');
          drawer.setAttribute('aria-hidden', 'true');
          document.body.style.overflow = '';
        }, 300);
      }

      if (openBtn) openBtn.addEventListener('click', open);
      if (closeBtn) closeBtn.addEventListener('click', close);
      if (backdrop) backdrop.addEventListener('click', close);
      document.addEventListener('keydown', function (e) { if (e.key === 'Escape') close(); });
      document.querySelectorAll('#drawer-panel a').forEach(function (a) { a.addEventListener('click', close); });
    })();
  </script>
</body>
</html>
EOF

# ============ 4. REDESIGNED HOME ============
cat > src/pages/index.astro <<'EOF'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { getCollection } from 'astro:content';
import { getTaxonomy, slugify } from '../lib/taxonomy';

const notes = await getCollection('notes');
const quizzes = await getCollection('quizzes');
const books = await getCollection('books');
const gazettes = await getCollection('gazettes');
const { classes, subjects } = await getTaxonomy();

const categories = [
  { href: '/notes',    label: 'Notes',    count: notes.length,    icon: 'file-text',     tint: 'indigo', desc: 'Chapter-wise notes for every subject' },
  { href: '/quizzes',  label: 'Quizzes',  count: quizzes.length,  icon: 'file-question', tint: 'blue',   desc: 'Practice MCQs with instant answers' },
  { href: '/books',    label: 'Books',    count: books.length,    icon: 'book-marked',   tint: 'amber',  desc: 'Full textbooks from every board' },
  { href: '/gazettes', label: 'Gazettes', count: gazettes.length, icon: 'scroll-text',   tint: 'rose',   desc: 'Official results and past gazettes' },
];

const recent = [...notes].slice(0, 6);
---
<BaseLayout title="TaleemHub — Notes, Quizzes & Books for Pakistani Students">
  <!-- ═══ HERO ═══ -->
  <section class="relative overflow-hidden border-b border-stone-200 bg-gradient-to-b from-indigo-50/40 via-white to-white">
    <div class="absolute -left-40 -top-40 h-[500px] w-[500px] rounded-full bg-indigo-100/50 blur-3xl" aria-hidden="true"></div>
    <div class="absolute -right-40 top-20 h-[400px] w-[400px] rounded-full bg-amber-100/50 blur-3xl" aria-hidden="true"></div>

    <div class="relative mx-auto w-full max-w-6xl px-6 py-20 sm:py-28 lg:px-10 lg:py-32">
      <div class="max-w-3xl">
        <div class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-indigo-700">
          <span class="grid h-1.5 w-1.5 place-items-center rounded-full bg-indigo-600"></span>
          Free for every Pakistani student
        </div>

        <h1 class="mt-6 text-[2.5rem] font-bold leading-[1.05] tracking-[-0.035em] text-stone-900 sm:text-6xl lg:text-[4.25rem]">
          Learn anything.
          <br />
          <span class="font-display italic text-indigo-600">From Class 9 to 12.</span>
        </h1>

        <p class="mt-7 max-w-xl text-[15px] leading-relaxed text-stone-500 sm:text-base">
          Notes, interactive quizzes, textbooks and result gazettes — organised by class and subject, all completely free.
        </p>

        <form action="/search" method="get" role="search" class="mt-9 flex max-w-lg items-center gap-2 rounded-2xl border border-stone-200 bg-white p-1.5 pl-4 transition-all focus-within:border-indigo-500 focus-within:ring-4 focus-within:ring-indigo-100">
          <Icon name="search" size={17} strokeWidth={2.3} class="shrink-0 text-stone-400" />
          <input
            type="search"
            name="q"
            placeholder="Search notes, books, past papers..."
            class="min-w-0 flex-1 bg-transparent py-2.5 text-sm text-stone-900 outline-none placeholder:text-stone-400"
          />
          <button type="submit" class="rounded-xl bg-stone-900 px-4 py-2.5 text-[13px] font-semibold text-white transition-colors hover:bg-stone-800">
            Search
          </button>
        </form>

        <div class="mt-7 flex flex-wrap items-center gap-x-5 gap-y-2 text-[13px] font-medium text-stone-500">
          <span class="flex items-center gap-1.5"><Icon name="zap" size={14} strokeWidth={2.4} class="text-indigo-600" /> Instant answers</span>
          <span class="h-1 w-1 rounded-full bg-stone-300"></span>
          <span class="flex items-center gap-1.5"><Icon name="download" size={14} strokeWidth={2.4} class="text-indigo-600" /> Free PDFs</span>
          <span class="h-1 w-1 rounded-full bg-stone-300"></span>
          <span class="flex items-center gap-1.5"><Icon name="check" size={14} strokeWidth={2.6} class="text-indigo-600" /> All boards</span>
        </div>
      </div>
    </div>
  </section>

  <!-- ═══ STATS ═══ -->
  <section class="mx-auto w-full max-w-6xl px-6 py-14 lg:px-10">
    <div class="grid grid-cols-2 gap-3 lg:grid-cols-4">
      {categories.map(cat => (
        <a href={cat.href} class="group rounded-2xl border border-stone-200 bg-white p-5 transition-all hover:border-stone-300 hover:bg-stone-50">
          <span class:list={[
            "grid h-10 w-10 place-items-center rounded-xl transition-colors",
            cat.tint === 'indigo' && "bg-indigo-50 text-indigo-600 group-hover:bg-indigo-100",
            cat.tint === 'blue'   && "bg-blue-50 text-blue-600 group-hover:bg-blue-100",
            cat.tint === 'amber'  && "bg-amber-50 text-amber-600 group-hover:bg-amber-100",
            cat.tint === 'rose'   && "bg-rose-50 text-rose-600 group-hover:bg-rose-100",
          ]}>
            <Icon name={cat.icon} size={19} strokeWidth={2.2} />
          </span>
          <div class="mt-4 text-3xl font-bold tracking-tight text-stone-900">{cat.count}</div>
          <div class="mt-1 flex items-center gap-1 text-[13px] font-medium text-stone-500">
            {cat.label}
            <Icon name="arrow-up-right" size={12} strokeWidth={2.6} class="opacity-0 transition-all group-hover:translate-x-0.5 group-hover:opacity-100" />
          </div>
        </a>
      ))}
    </div>
  </section>

  <!-- ═══ BROWSE BY CLASS ═══ -->
  {classes.length > 0 && (
    <section class="mx-auto w-full max-w-6xl px-6 py-12 lg:px-10">
      <div class="mb-7 flex items-end justify-between gap-4">
        <div>
          <h2 class="font-display text-3xl tracking-tight text-stone-900 sm:text-4xl">Browse by class</h2>
          <p class="mt-2 text-sm text-stone-500">Everything for your class, in one place.</p>
        </div>
        <a href="/classes" class="hidden items-center gap-1 text-[13px] font-semibold text-indigo-600 hover:text-indigo-700 sm:inline-flex">
          All classes <Icon name="arrow-right" size={13} strokeWidth={2.6} />
        </a>
      </div>
      <div class="grid grid-cols-2 gap-3 lg:grid-cols-4">
        {classes.map(c => (
          <a href={`/classes/${c.class}`} class="group flex items-center gap-3.5 rounded-2xl border border-stone-200 bg-white p-4 transition-all hover:border-indigo-200 hover:bg-indigo-50/30 sm:p-5">
            <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-stone-900 text-white transition-colors group-hover:bg-indigo-600">
              <Icon name="graduation-cap" size={19} strokeWidth={2.2} />
            </span>
            <div class="min-w-0">
              <div class="text-[15px] font-bold tracking-tight text-stone-900 sm:text-base">Class {c.class}</div>
              <div class="truncate text-xs font-medium text-stone-500">{c.total} {c.total === 1 ? 'item' : 'items'}</div>
            </div>
          </a>
        ))}
      </div>
    </section>
  )}

  <!-- ═══ BROWSE BY SUBJECT ═══ -->
  {subjects.length > 0 && (
    <section class="mx-auto w-full max-w-6xl px-6 pb-6 lg:px-10">
      <div class="mb-7 flex items-end justify-between gap-4">
        <div>
          <h2 class="font-display text-3xl tracking-tight text-stone-900 sm:text-4xl">Browse by subject</h2>
          <p class="mt-2 text-sm text-stone-500">Pick your subject, then your class.</p>
        </div>
        <a href="/subjects" class="hidden items-center gap-1 text-[13px] font-semibold text-indigo-600 hover:text-indigo-700 sm:inline-flex">
          All subjects <Icon name="arrow-right" size={13} strokeWidth={2.6} />
        </a>
      </div>
      <div class="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
        {subjects.map(s => (
          <a href={`/subjects/${slugify(s.subject)}`} class="group flex items-center gap-4 rounded-2xl border border-stone-200 bg-white p-5 transition-all hover:border-indigo-200 hover:bg-indigo-50/30">
            <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-indigo-50 text-indigo-600 transition-colors group-hover:bg-indigo-100">
              <Icon name="library" size={19} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <div class="text-[15px] font-bold tracking-tight text-stone-900">{s.subject}</div>
              <div class="truncate text-xs font-medium text-stone-500">{s.total} {s.total === 1 ? 'item' : 'items'} · Class {s.classes.join(', ')}</div>
            </div>
            <Icon name="chevron-right" size={15} strokeWidth={2.4} class="shrink-0 text-stone-300 transition-all group-hover:translate-x-0.5 group-hover:text-indigo-500" />
          </a>
        ))}
      </div>
    </section>
  )}

  <!-- ═══ BROWSE THE LIBRARY ═══ -->
  <section class="mx-auto w-full max-w-6xl px-6 py-14 lg:px-10">
    <div class="mb-7">
      <h2 class="font-display text-3xl tracking-tight text-stone-900 sm:text-4xl">Browse the library</h2>
      <p class="mt-2 text-sm text-stone-500">Jump straight into what you're studying.</p>
    </div>
    <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
      {categories.map(cat => (
        <a href={cat.href} class="group relative overflow-hidden rounded-2xl border border-stone-200 bg-white p-6 transition-all hover:border-stone-300 hover:bg-stone-50">
          <div class="flex items-start justify-between">
            <span class:list={[
              "grid h-11 w-11 place-items-center rounded-xl transition-colors",
              cat.tint === 'indigo' && "bg-indigo-50 text-indigo-600 group-hover:bg-indigo-100",
              cat.tint === 'blue'   && "bg-blue-50 text-blue-600 group-hover:bg-blue-100",
              cat.tint === 'amber'  && "bg-amber-50 text-amber-600 group-hover:bg-amber-100",
              cat.tint === 'rose'   && "bg-rose-50 text-rose-600 group-hover:bg-rose-100",
            ]}>
              <Icon name={cat.icon} size={21} strokeWidth={2.1} />
            </span>
            <Icon name="arrow-up-right" size={17} strokeWidth={2.3} class="text-stone-300 transition-all group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-indigo-500" />
          </div>
          <h3 class="mt-5 text-[15px] font-bold tracking-tight text-stone-900">{cat.label}</h3>
          <p class="mt-1.5 text-[13px] leading-relaxed text-stone-500">{cat.desc}</p>
          <p class="mt-5 text-[11px] font-bold uppercase tracking-wider text-stone-400">{cat.count} {cat.count === 1 ? 'item' : 'items'}</p>
        </a>
      ))}
    </div>
  </section>

  <!-- ═══ RECENT ═══ -->
  {recent.length > 0 && (
    <section class="mx-auto w-full max-w-6xl px-6 pb-20 lg:px-10">
      <div class="mb-7 flex items-end justify-between gap-4">
        <div>
          <h2 class="font-display text-3xl tracking-tight text-stone-900 sm:text-4xl">Recent notes</h2>
          <p class="mt-2 text-sm text-stone-500">Freshly added study material.</p>
        </div>
        <a href="/notes" class="hidden items-center gap-1 text-[13px] font-semibold text-indigo-600 hover:text-indigo-700 sm:inline-flex">
          View all <Icon name="arrow-right" size={13} strokeWidth={2.6} />
        </a>
      </div>
      <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
        {recent.map(n => (
          <a href={`/notes/${n.id}`} class="group flex items-center gap-4 rounded-2xl border border-stone-200 bg-white p-4 transition-all hover:border-stone-300 hover:bg-stone-50">
            <span class="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-indigo-50 text-indigo-600 transition-colors group-hover:bg-indigo-100">
              <Icon name="file-text" size={17} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <h3 class="truncate text-[14px] font-bold tracking-tight text-stone-900">{n.data.title}</h3>
              <div class="mt-1.5 flex flex-wrap gap-1.5">
                <span class="rounded-md bg-stone-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-stone-600">{n.data.subject}</span>
                <span class="rounded-md bg-indigo-50 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-indigo-700">Class {n.data.class}</span>
              </div>
            </div>
            <Icon name="chevron-right" size={15} strokeWidth={2.4} class="shrink-0 text-stone-300 transition-all group-hover:translate-x-0.5 group-hover:text-indigo-500" />
          </a>
        ))}
      </div>
    </section>
  )}
</BaseLayout>
EOF

# ============ 5. CLEAR CACHES ============
rm -rf .astro node_modules/.vite node_modules/.astro dist

echo ""
echo "════════════════════════════════════════════"
echo "  Polish applied"
echo "════════════════════════════════════════════"
echo ""
echo "  Fonts:"
echo "    Display → Instrument Serif (editorial serif)"
echo "    Body    → Geist (modern sans)"
echo ""
echo "  Palette:"
echo "    Neutrals → stone (warmer, editorial)"
echo "    Primary  → indigo (unchanged)"
echo ""
echo "  Design:"
echo "    - Sidebar uses solid-stone active pill"
echo "    - Hero has serif italic accent line"
echo "    - More whitespace, tighter line-heights"
echo "    - Focus rings on search inputs"
echo "    - Refined card hover states"
echo ""
echo "  Run:  npm run dev"