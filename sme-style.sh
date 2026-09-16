#!/bin/bash
set -e

echo "Rebuilding in Save My Exams style..."

# ============ 1. GLOBAL CSS — new fonts + palette ============
cat > src/styles/global.css <<'CSS'
@import "tailwindcss";

@theme {
  --font-sans: "Plus Jakarta Sans", ui-sans-serif, system-ui, -apple-system, sans-serif;
}

html { -webkit-text-size-adjust: 100%; scroll-behavior: smooth; }
body {
  font-family: var(--font-sans);
  background: #ffffff;
  color: #323232;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  overflow-x: hidden;
}
a { color: inherit; text-decoration: none; }
button { font-family: inherit; cursor: pointer; }
input, select, textarea { font-family: inherit; }

/* Prose */
.prose { font-size: 1rem; line-height: 1.75; color: #4b4b4b; }
.prose h1, .prose h2, .prose h3 { color: #1a1a1a; font-weight: 700; letter-spacing: -0.02em; }
.prose h2 { font-size: 1.25rem; margin: 2rem 0 0.75rem; padding-bottom: 0.5rem; border-bottom: 1px solid #e5e5e5; }
.prose h3 { font-size: 1.05rem; margin: 1.5rem 0 0.5rem; }
.prose h2:first-child, .prose h3:first-child { margin-top: 0; }
.prose p { margin-bottom: 1rem; }
.prose ul, .prose ol { padding-left: 1.25rem; margin-bottom: 1rem; }
.prose li { margin-bottom: 0.375rem; }
.prose li::marker { color: #0620ed; }
.prose code { background: #eef2fe; color: #110176; padding: 0.125rem 0.375rem; border-radius: 0.375rem; font-size: 0.85em; font-weight: 600; }
.prose strong { font-weight: 700; color: #1a1a1a; }
.prose table { width: 100%; border-collapse: collapse; margin: 1rem 0; font-size: 0.875rem; border: 1px solid #e5e5e5; border-radius: 0.5rem; overflow: hidden; }
.prose th { background: #fbfafa; text-align: left; padding: 0.625rem 0.75rem; font-weight: 700; color: #1a1a1a; border-bottom: 1px solid #e5e5e5; }
.prose td { padding: 0.625rem 0.75rem; border-top: 1px solid #e5e5e5; }
.prose a { color: #0620ed; text-decoration: underline; text-underline-offset: 2px; }

@keyframes fadeUp {
  from { opacity: 0; transform: translateY(12px); }
  to   { opacity: 1; transform: translateY(0); }
}
.animate-in { animation: fadeUp 0.5s cubic-bezier(0.16,1,0.3,1) both; }
CSS

# ============ 2. BASE LAYOUT — desktop-first, no bottom nav ============
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

const isActive = (href: string) => href === '/' ? path === '/' : path.startsWith(href);
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
  <link rel="sitemap" href="/sitemap-index.xml" />
</head>
<body class="min-h-screen bg-white">

  <!-- ═══ SITE HEADER ═══ -->
  <header class="sticky top-0 z-50 w-full border-b border-neutral-200 bg-white">
    <div class="mx-auto flex h-[74px] w-full max-w-[1320px] items-center gap-6 px-4 lg:px-8">
      <a href="/" class="flex shrink-0 items-center gap-2.5">
        <span class="grid h-9 w-9 place-items-center rounded-lg bg-[#0620ed] text-white">
          <Icon name="graduation-cap" size={20} strokeWidth={2.4} />
        </span>
        <span class="text-lg font-extrabold tracking-tight text-neutral-900">TaleemHub</span>
      </a>

      <nav class="hidden items-center gap-1 lg:flex">
        {navMain.map(item => (
          <a href={item.href} class:list={[
            "rounded-lg px-3 py-2 text-sm font-semibold transition-colors",
            isActive(item.href) ? "text-[#0620ed]" : "text-neutral-600 hover:text-neutral-900",
          ]}>{item.label}</a>
        ))}
        <span class="mx-1 h-5 w-px bg-neutral-200"></span>
        {navLibrary.map(item => (
          <a href={item.href} class:list={[
            "rounded-lg px-3 py-2 text-sm font-semibold transition-colors",
            isActive(item.href) ? "text-[#0620ed]" : "text-neutral-600 hover:text-neutral-900",
          ]}>{item.label}</a>
        ))}
      </nav>

      <div class="ml-auto flex items-center gap-3">
        <form action="/search" method="get" role="search" class="hidden h-10 w-56 items-center gap-2 rounded-xl border border-neutral-200 bg-neutral-50 px-3 transition-colors focus-within:border-[#0620ed] focus-within:bg-white md:flex">
          <Icon name="search" size={16} strokeWidth={2.4} class="shrink-0 text-neutral-400" />
          <input type="search" name="q" placeholder="Search" class="min-w-0 flex-1 bg-transparent text-sm text-neutral-900 outline-none placeholder:text-neutral-400" />
        </form>
        <a href="/search" class="grid h-10 w-10 place-items-center rounded-xl border border-neutral-200 bg-neutral-50 text-neutral-600 hover:bg-white md:hidden" aria-label="Search">
          <Icon name="search" size={18} strokeWidth={2.4} />
        </a>
        <a href="/classes" class="hidden items-center gap-1.5 rounded-xl bg-[#0620ed] px-4 py-2.5 text-sm font-bold text-white transition-colors hover:bg-[#110176] sm:inline-flex">
          Get started
          <Icon name="arrow-right" size={14} strokeWidth={2.6} />
        </a>
      </div>
    </div>

    <!-- Mobile nav row (below header, scrollable) -->
    <div class="border-t border-neutral-100 lg:hidden">
      <div class="flex gap-1 overflow-x-auto px-4 py-2">
        {[...navMain, ...navLibrary].map(item => (
          <a href={item.href} class:list={[
            "shrink-0 rounded-lg px-3 py-1.5 text-[13px] font-semibold transition-colors",
            isActive(item.href) ? "bg-[#eef2fe] text-[#0620ed]" : "text-neutral-600",
          ]}>{item.label}</a>
        ))}
      </div>
    </div>
  </header>

  <!-- ═══ CONTENT ═══ -->
  <main class="min-h-[60vh]">
    <slot />
  </main>

  <!-- ═══ FOOTER ═══ -->
  <footer class="mt-20 border-t border-neutral-200 bg-neutral-50">
    <div class="mx-auto max-w-[1320px] px-4 py-12 lg:px-8">
      <div class="grid grid-cols-1 gap-10 sm:grid-cols-2 lg:grid-cols-4">
        <div class="sm:col-span-2">
          <div class="flex items-center gap-2.5">
            <span class="grid h-9 w-9 place-items-center rounded-lg bg-[#0620ed] text-white">
              <Icon name="graduation-cap" size={20} strokeWidth={2.4} />
            </span>
            <span class="text-lg font-extrabold tracking-tight text-neutral-900">TaleemHub</span>
          </div>
          <p class="mt-4 max-w-sm text-sm leading-relaxed text-neutral-500">
            Free notes, interactive quizzes, textbooks and result gazettes for students across Pakistan — all in one place.
          </p>
        </div>
        <div>
          <h4 class="text-sm font-bold text-neutral-900">Library</h4>
          <ul class="mt-4 space-y-2.5 text-sm text-neutral-500">
            <li><a href="/classes" class="hover:text-[#0620ed]">Classes</a></li>
            <li><a href="/subjects" class="hover:text-[#0620ed]">Subjects</a></li>
            <li><a href="/notes" class="hover:text-[#0620ed]">Notes</a></li>
            <li><a href="/quizzes" class="hover:text-[#0620ed]">Quizzes</a></li>
          </ul>
        </div>
        <div>
          <h4 class="text-sm font-bold text-neutral-900">Explore</h4>
          <ul class="mt-4 space-y-2.5 text-sm text-neutral-500">
            <li><a href="/books" class="hover:text-[#0620ed]">Textbooks</a></li>
            <li><a href="/gazettes" class="hover:text-[#0620ed]">Gazettes</a></li>
            <li><a href="/search" class="hover:text-[#0620ed]">Search</a></li>
          </ul>
        </div>
      </div>
      <div class="mt-10 border-t border-neutral-200 pt-6 text-xs text-neutral-400">
        <p>© {new Date().getFullYear()} TaleemHub. Built for students, forever free.</p>
      </div>
    </div>
  </footer>
</body>
</html>
EOF

# ============ 3. HOME PAGE ============
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
  { href: '/notes',    label: 'Notes',    count: notes.length,    icon: 'file-text',     desc: 'Chapter-wise notes for every subject' },
  { href: '/quizzes',  label: 'Quizzes',  count: quizzes.length,  icon: 'file-question', desc: 'Practice MCQs with instant answers' },
  { href: '/books',    label: 'Books',    count: books.length,    icon: 'book-marked',   desc: 'Full textbooks from every board' },
  { href: '/gazettes', label: 'Gazettes', count: gazettes.length, icon: 'scroll-text',   desc: 'Official results and past gazettes' },
];

const recent = [...notes].slice(0, 6);
---
<BaseLayout title="TaleemHub — Exam-specific revision for Pakistani students">
  <!-- HERO -->
  <section class="border-b border-neutral-200 bg-neutral-50">
    <div class="mx-auto max-w-[1320px] px-4 py-16 lg:px-8 lg:py-24">
      <div class="max-w-3xl">
        <div class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-[#0620ed]">
          <span class="h-1.5 w-1.5 rounded-full bg-[#0620ed]"></span>
          Trusted by students across Pakistan
        </div>
        <h1 class="mt-5 text-[2.5rem] font-extrabold leading-[1.08] tracking-[-0.035em] text-neutral-900 sm:text-6xl">
          Exam-specific revision,<br />
          made simple.
        </h1>
        <p class="mt-6 max-w-xl text-base leading-relaxed text-neutral-500 sm:text-lg">
          Notes, interactive quizzes, textbooks and result gazettes — organised by class and subject, all completely free.
        </p>

        <form action="/search" method="get" role="search" class="mt-8 flex max-w-lg items-center gap-2 rounded-2xl border border-neutral-200 bg-white p-1.5 pl-4 focus-within:border-[#0620ed]">
          <Icon name="search" size={18} strokeWidth={2.4} class="shrink-0 text-neutral-400" />
          <input type="search" name="q" placeholder="Search notes, books, past papers..." class="min-w-0 flex-1 bg-transparent py-2.5 text-sm text-neutral-900 outline-none placeholder:text-neutral-400" />
          <button type="submit" class="rounded-xl bg-[#0620ed] px-4 py-2.5 text-sm font-bold text-white transition-colors hover:bg-[#110176]">Search</button>
        </form>

        <div class="mt-6 flex flex-wrap items-center gap-x-5 gap-y-2 text-sm font-medium text-neutral-500">
          <span class="flex items-center gap-1.5"><Icon name="zap" size={14} strokeWidth={2.4} class="text-[#0620ed]" /> Instant answers</span>
          <span class="h-1 w-1 rounded-full bg-neutral-300"></span>
          <span class="flex items-center gap-1.5"><Icon name="download" size={14} strokeWidth={2.4} class="text-[#0620ed]" /> Free PDFs</span>
          <span class="h-1 w-1 rounded-full bg-neutral-300"></span>
          <span class="flex items-center gap-1.5"><Icon name="check" size={14} strokeWidth={2.6} class="text-[#0620ed]" /> All boards</span>
        </div>
      </div>
    </div>
  </section>

  <!-- STATS -->
  <section class="mx-auto max-w-[1320px] px-4 py-14 lg:px-8">
    <div class="grid grid-cols-2 gap-4 lg:grid-cols-4">
      {categories.map(cat => (
        <a href={cat.href} class="group rounded-2xl border border-neutral-200 bg-white p-5 transition-colors hover:border-neutral-400">
          <span class="grid h-11 w-11 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
            <Icon name={cat.icon} size={20} strokeWidth={2.2} />
          </span>
          <div class="mt-4 text-3xl font-extrabold tracking-tight text-neutral-900">{cat.count}</div>
          <div class="mt-0.5 flex items-center gap-1 text-sm font-semibold text-neutral-500">
            {cat.label}
            <Icon name="arrow-up-right" size={13} strokeWidth={2.4} class="opacity-0 transition-opacity group-hover:opacity-100" />
          </div>
        </a>
      ))}
    </div>
  </section>

  <!-- BROWSE BY CLASS -->
  {classes.length > 0 && (
    <section class="mx-auto max-w-[1320px] px-4 py-10 lg:px-8">
      <div class="mb-6 flex items-end justify-between gap-4">
        <div>
          <h2 class="text-2xl font-extrabold tracking-tight text-neutral-900 sm:text-3xl">Browse by class</h2>
          <p class="mt-1.5 text-sm text-neutral-500">Everything for your class in one place.</p>
        </div>
        <a href="/classes" class="hidden items-center gap-1 text-sm font-bold text-[#0620ed] hover:text-[#110176] sm:inline-flex">
          All classes <Icon name="arrow-right" size={14} strokeWidth={2.6} />
        </a>
      </div>
      <div class="grid grid-cols-2 gap-3 lg:grid-cols-4">
        {classes.map(c => (
          <a href={`/classes/${c.class}`} class="group flex items-center gap-3.5 rounded-2xl border border-neutral-200 bg-white p-4 transition-colors hover:border-[#0620ed] sm:p-5">
            <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
              <Icon name="graduation-cap" size={20} strokeWidth={2.2} />
            </span>
            <div class="min-w-0">
              <div class="text-base font-extrabold tracking-tight text-neutral-900">Class {c.class}</div>
              <div class="truncate text-xs font-semibold text-neutral-500">{c.total} {c.total === 1 ? 'item' : 'items'}</div>
            </div>
          </a>
        ))}
      </div>
    </section>
  )}

  <!-- BROWSE BY SUBJECT -->
  {subjects.length > 0 && (
    <section class="mx-auto max-w-[1320px] px-4 pb-6 lg:px-8">
      <div class="mb-6 flex items-end justify-between gap-4">
        <div>
          <h2 class="text-2xl font-extrabold tracking-tight text-neutral-900 sm:text-3xl">Browse by subject</h2>
          <p class="mt-1.5 text-sm text-neutral-500">Pick your subject, then your class.</p>
        </div>
        <a href="/subjects" class="hidden items-center gap-1 text-sm font-bold text-[#0620ed] hover:text-[#110176] sm:inline-flex">
          All subjects <Icon name="arrow-right" size={14} strokeWidth={2.6} />
        </a>
      </div>
      <div class="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
        {subjects.map(s => (
          <a href={`/subjects/${slugify(s.subject)}`} class="group flex items-center gap-4 rounded-2xl border border-neutral-200 bg-white p-5 transition-colors hover:border-[#0620ed]">
            <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
              <Icon name="library" size={20} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <div class="text-base font-extrabold tracking-tight text-neutral-900">{s.subject}</div>
              <div class="truncate text-xs font-semibold text-neutral-500">{s.total} {s.total === 1 ? 'item' : 'items'} · Class {s.classes.join(', ')}</div>
            </div>
            <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-neutral-300 transition-transform group-hover:translate-x-0.5 group-hover:text-[#0620ed]" />
          </a>
        ))}
      </div>
    </section>
  )}

  <!-- BROWSE THE LIBRARY -->
  <section class="mx-auto max-w-[1320px] px-4 py-14 lg:px-8">
    <div class="mb-6">
      <h2 class="text-2xl font-extrabold tracking-tight text-neutral-900 sm:text-3xl">Browse the library</h2>
      <p class="mt-1.5 text-sm text-neutral-500">Jump straight into what you're studying.</p>
    </div>
    <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
      {categories.map(cat => (
        <a href={cat.href} class="group rounded-2xl border border-neutral-200 bg-white p-6 transition-colors hover:border-neutral-400">
          <div class="flex items-start justify-between">
            <span class="grid h-11 w-11 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
              <Icon name={cat.icon} size={20} strokeWidth={2.2} />
            </span>
            <Icon name="arrow-up-right" size={17} strokeWidth={2.3} class="text-neutral-300 transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-[#0620ed]" />
          </div>
          <h3 class="mt-5 text-base font-extrabold tracking-tight text-neutral-900">{cat.label}</h3>
          <p class="mt-1.5 text-sm leading-relaxed text-neutral-500">{cat.desc}</p>
          <p class="mt-5 text-[11px] font-bold uppercase tracking-wider text-neutral-400">{cat.count} {cat.count === 1 ? 'item' : 'items'}</p>
        </a>
      ))}
    </div>
  </section>

  <!-- RECENT -->
  {recent.length > 0 && (
    <section class="mx-auto max-w-[1320px] px-4 pb-20 lg:px-8">
      <div class="mb-6 flex items-end justify-between gap-4">
        <div>
          <h2 class="text-2xl font-extrabold tracking-tight text-neutral-900 sm:text-3xl">Recent notes</h2>
          <p class="mt-1.5 text-sm text-neutral-500">Freshly added study material.</p>
        </div>
        <a href="/notes" class="hidden items-center gap-1 text-sm font-bold text-[#0620ed] hover:text-[#110176] sm:inline-flex">
          View all <Icon name="arrow-right" size={14} strokeWidth={2.6} />
        </a>
      </div>
      <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
        {recent.map(n => (
          <a href={`/notes/${n.id}`} class="group flex items-center gap-4 rounded-2xl border border-neutral-200 bg-white p-4 transition-colors hover:border-[#0620ed]">
            <span class="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
              <Icon name="file-text" size={17} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <h3 class="truncate text-sm font-bold text-neutral-900">{n.data.title}</h3>
              <div class="mt-1.5 flex flex-wrap gap-1.5">
                <span class="rounded-md bg-neutral-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-neutral-600">{n.data.subject}</span>
                <span class="rounded-md bg-[#eef2fe] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#0620ed]">Class {n.data.class}</span>
              </div>
            </div>
            <Icon name="chevron-right" size={15} strokeWidth={2.4} class="shrink-0 text-neutral-300 transition-transform group-hover:translate-x-0.5 group-hover:text-[#0620ed]" />
          </a>
        ))}
      </div>
    </section>
  )}
</BaseLayout>
EOF

# ============ 4. SWAP INDIGO/STONE IN ALL OTHER PAGES ============
find src/pages src/components -name "*.astro" -type f ! -name "index.astro" -exec sed -i \
  -e 's/indigo-50\b/[#eef2fe]/g' \
  -e 's/indigo-100\b/[#eef2fe]/g' \
  -e 's/indigo-200\b/[#93adfb]/g' \
  -e 's/indigo-300\b/[#5c84f8]/g' \
  -e 's/indigo-400\b/[#265bf6]/g' \
  -e 's/indigo-500\b/[#265bf6]/g' \
  -e 's/indigo-600\b/[#0620ed]/g' \
  -e 's/indigo-700\b/[#110176]/g' \
  -e 's/indigo-800\b/[#110176]/g' \
  -e 's/indigo-900\b/[#06002e]/g' \
  -e 's/stone-50\b/neutral-50/g' \
  -e 's/stone-100\b/neutral-100/g' \
  -e 's/stone-200\b/neutral-200/g' \
  -e 's/stone-300\b/neutral-300/g' \
  -e 's/stone-400\b/neutral-400/g' \
  -e 's/stone-500\b/neutral-500/g' \
  -e 's/stone-600\b/neutral-600/g' \
  -e 's/stone-700\b/neutral-700/g' \
  -e 's/stone-800\b/neutral-800/g' \
  -e 's/stone-900\b/neutral-900/g' \
  {} \;

# Fix any double-slash artifacts from the sed
find src -name "*.astro" -exec sed -i 's/bg-\[#eef2fe\]-100/bg-[#eef2fe]/g; s/text-\[#eef2fe\]-700/text-[#0620ed]/g' {} \;

# ============ 5. CLEAR CACHES ============
rm -rf .astro node_modules/.vite node_modules/.astro dist

echo ""
echo "════════════════════════════════════════════"
echo "  Save My Exams style applied"
echo "════════════════════════════════════════════"
echo ""
echo "  Font    → Plus Jakarta Sans (same as SME)"
echo "  Primary → Bright royal blue #0620ed"
echo "  Neutral → clean grays (neutral-*)"
echo ""
echo "  Layout:"
echo "    - Full site header (sticky, 74px)"
echo "    - Horizontal nav with divider"
echo "    - Search box + 'Get started' CTA"
echo "    - Mobile: scrollable nav row below header"
echo "    - NO bottom navigation anywhere"
echo "    - Real footer with 4 columns"
echo ""
echo "  Run:  npm run dev"