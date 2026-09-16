#!/bin/bash
set -e

echo "Applying new font + color system..."

# ============ 1. SWAP ALL EMERALD CLASSES → INDIGO ============
find src -name "*.astro" -type f -exec sed -i \
  -e 's/emerald-50\b/indigo-50/g' \
  -e 's/emerald-100\b/indigo-100/g' \
  -e 's/emerald-200\b/indigo-200/g' \
  -e 's/emerald-300\b/indigo-300/g' \
  -e 's/emerald-400\b/indigo-400/g' \
  -e 's/emerald-500\b/indigo-500/g' \
  -e 's/emerald-600\b/indigo-600/g' \
  -e 's/emerald-700\b/indigo-700/g' \
  -e 's/emerald-800\b/indigo-800/g' \
  -e 's/emerald-900\b/indigo-900/g' \
  {} \;

echo "  Colors swapped: emerald → indigo"

# ============ 2. UPDATE GLOBAL.CSS FONTS ============
cat > src/styles/global.css <<'CSS'
@import "tailwindcss";

@theme {
  --font-sans: "Manrope", ui-sans-serif, system-ui, -apple-system, sans-serif;
  --font-display: "Sora", "Manrope", ui-sans-serif, system-ui, sans-serif;
}

html {
  -webkit-text-size-adjust: 100%;
  scroll-behavior: smooth;
}
body {
  font-family: var(--font-sans);
  background-color: #f8fafc;
  color: #0f172a;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  overflow-x: hidden;
}
a { color: inherit; text-decoration: none; }
button { font-family: inherit; cursor: pointer; }
input, select, textarea { font-family: inherit; }

.font-display { letter-spacing: -0.025em; }

/* Prose */
.prose { font-size: 0.975rem; line-height: 1.75; color: #334155; }
.prose h1, .prose h2, .prose h3 { color: #0f172a; font-weight: 700; letter-spacing: -0.02em; font-family: var(--font-display); }
.prose h2 { font-size: 1.25rem; margin-top: 2rem; margin-bottom: 0.75rem; padding-bottom: 0.5rem; border-bottom: 1px solid #e2e8f0; }
.prose h3 { font-size: 1.05rem; margin-top: 1.5rem; margin-bottom: 0.5rem; }
.prose h2:first-child, .prose h3:first-child { margin-top: 0; }
.prose p { margin-bottom: 1rem; }
.prose ul, .prose ol { padding-left: 1.25rem; margin-bottom: 1rem; }
.prose li { margin-bottom: 0.375rem; }
.prose li::marker { color: #4f46e5; }
.prose code { background: #eef2ff; color: #4338ca; padding: 0.125rem 0.375rem; border-radius: 0.375rem; font-size: 0.85em; font-weight: 600; }
.prose strong { font-weight: 700; color: #0f172a; }
.prose table { width: 100%; border-collapse: collapse; margin: 1rem 0; font-size: 0.875rem; border: 1px solid #e2e8f0; border-radius: 0.5rem; overflow: hidden; }
.prose th { background: #f8fafc; text-align: left; padding: 0.625rem 0.75rem; font-weight: 700; color: #0f172a; border-bottom: 1px solid #e2e8f0; }
.prose td { padding: 0.625rem 0.75rem; border-top: 1px solid #e2e8f0; }
.prose a { color: #4f46e5; text-decoration: underline; text-underline-offset: 2px; }

@keyframes fadeUp {
  from { opacity: 0; transform: translateY(12px); }
  to   { opacity: 1; transform: translateY(0); }
}
.animate-in { animation: fadeUp 0.55s cubic-bezier(0.16,1,0.3,1) both; }
CSS

# ============ 3. REWRITE LAYOUT (new fonts + refined header) ============
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

const desktopNav = [
  { href: '/',         label: 'Home' },
  { href: '/classes',  label: 'Classes' },
  { href: '/subjects', label: 'Subjects' },
  { href: '/notes',    label: 'Notes' },
  { href: '/quizzes',  label: 'Quizzes' },
  { href: '/books',    label: 'Books' },
  { href: '/gazettes', label: 'Gazettes' },
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
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&family=Sora:wght@500;600;700;800&display=swap" />
  <link rel="sitemap" href="/sitemap-index.xml" />
</head>
<body class="min-h-screen">
  <header class="sticky top-0 z-50 w-full border-b border-slate-200 bg-white/85 backdrop-blur-xl">
    <div class="mx-auto flex h-16 w-full max-w-7xl items-center gap-4 px-4 sm:px-6 lg:px-8">
      <a href="/" class="flex shrink-0 items-center gap-2.5">
        <span class="grid h-9 w-9 place-items-center rounded-xl bg-gradient-to-br from-indigo-600 to-violet-600 text-white">
          <Icon name="graduation-cap" size={20} strokeWidth={2.4} />
        </span>
        <span class="font-display text-lg font-extrabold tracking-tight">TaleemHub</span>
      </a>

      <nav class="ml-4 hidden items-center gap-0.5 lg:flex">
        {desktopNav.map(item => (
          <a
            href={item.href}
            class:list={[
              "rounded-lg px-3 py-2 text-sm font-semibold transition-colors",
              isActive(item.href)
                ? "bg-indigo-50 text-indigo-700"
                : "text-slate-600 hover:bg-slate-100 hover:text-slate-900",
            ]}
          >
            {item.label}
          </a>
        ))}
      </nav>

      <div class="ml-auto flex items-center gap-2">
        <form
          action="/search"
          method="get"
          role="search"
          class="hidden h-10 w-56 items-center gap-2 rounded-xl border border-slate-200 bg-slate-50 px-3 transition-colors focus-within:border-indigo-400 focus-within:bg-white lg:flex"
        >
          <Icon name="search" size={16} strokeWidth={2.4} class="shrink-0 text-slate-400" />
          <input
            type="search"
            name="q"
            placeholder="Search library"
            class="min-w-0 flex-1 bg-transparent text-sm text-slate-900 outline-none placeholder:text-slate-400"
          />
        </form>

        <a
          href="/search"
          class="grid h-10 w-10 place-items-center rounded-xl border border-slate-200 bg-slate-50 text-slate-600 transition-colors hover:bg-white hover:text-slate-900 lg:hidden"
          aria-label="Search"
        >
          <Icon name="search" size={18} strokeWidth={2.4} />
        </a>
      </div>
    </div>
  </header>

  <main class="min-h-[60vh] pb-32 md:pb-0">
    <slot />
  </main>

  <footer class="mt-24 hidden border-t border-slate-200 bg-white md:block">
    <div class="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
      <div class="grid grid-cols-1 gap-10 sm:grid-cols-2 lg:grid-cols-4">
        <div class="sm:col-span-2">
          <div class="flex items-center gap-2.5">
            <span class="grid h-9 w-9 place-items-center rounded-xl bg-gradient-to-br from-indigo-600 to-violet-600 text-white">
              <Icon name="graduation-cap" size={20} strokeWidth={2.4} />
            </span>
            <span class="font-display text-lg font-extrabold tracking-tight">TaleemHub</span>
          </div>
          <p class="mt-4 max-w-sm text-sm leading-relaxed text-slate-500">
            Free notes, interactive quizzes, textbooks and result gazettes for students across Pakistan — all in one place.
          </p>
        </div>
        <div>
          <h4 class="font-display text-sm font-bold text-slate-900">Library</h4>
          <ul class="mt-4 space-y-2.5 text-sm text-slate-500">
            <li><a href="/classes" class="hover:text-indigo-700">Classes</a></li>
            <li><a href="/subjects" class="hover:text-indigo-700">Subjects</a></li>
            <li><a href="/notes" class="hover:text-indigo-700">Notes</a></li>
            <li><a href="/quizzes" class="hover:text-indigo-700">Quizzes</a></li>
          </ul>
        </div>
        <div>
          <h4 class="font-display text-sm font-bold text-slate-900">Explore</h4>
          <ul class="mt-4 space-y-2.5 text-sm text-slate-500">
            <li><a href="/books" class="hover:text-indigo-700">Textbooks</a></li>
            <li><a href="/gazettes" class="hover:text-indigo-700">Gazettes</a></li>
            <li><a href="/search" class="hover:text-indigo-700">Search</a></li>
          </ul>
        </div>
      </div>
      <div class="mt-10 flex flex-col gap-2 border-t border-slate-200 pt-6 text-xs text-slate-400 sm:flex-row sm:items-center sm:justify-between">
        <p>© {new Date().getFullYear()} TaleemHub. Built for students, forever free.</p>
        <p>Made in Pakistan</p>
      </div>
    </div>
  </footer>

  <nav class="fixed inset-x-0 bottom-0 z-50 border-t border-slate-200 bg-white md:hidden">
    <div class="flex items-stretch px-1 pt-2.5" style="padding-bottom: calc(env(safe-area-inset-bottom, 0px) + 26px);">
      {mobileNav.map(item => (
        <a
          href={item.href}
          class:list={[
            "flex min-w-0 flex-1 flex-col items-center gap-1 px-1 text-[11px] font-semibold leading-none transition-colors",
            isActive(item.href) ? "text-indigo-600" : "text-slate-400",
          ]}
        >
          <Icon name={item.icon} size={20} strokeWidth={2.2} />
          <span class="truncate">{item.label}</span>
        </a>
      ))}
    </div>
  </nav>
</body>
</html>
EOF

# ============ 4. REWRITE HOME (new hero with gradient text + blobs) ============
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
  <!-- HERO -->
  <section class="relative overflow-hidden border-b border-slate-200">
    <div class="absolute inset-0 -z-10 bg-gradient-to-b from-indigo-50/80 via-white to-white"></div>
    <div class="absolute -left-32 -top-20 -z-10 h-[500px] w-[500px] rounded-full bg-indigo-200/40 blur-3xl"></div>
    <div class="absolute -right-32 top-40 -z-10 h-[500px] w-[500px] rounded-full bg-violet-200/40 blur-3xl"></div>
    <div class="absolute left-1/2 top-0 -z-10 h-[400px] w-[400px] -translate-x-1/2 rounded-full bg-amber-100/50 blur-3xl"></div>

    <div class="relative mx-auto w-full max-w-7xl px-4 py-20 sm:px-6 sm:py-28 lg:px-8 lg:py-32">
      <div class="max-w-3xl">
        <span class="inline-flex items-center gap-1.5 rounded-full border border-indigo-200 bg-white/80 px-3 py-1 text-xs font-bold uppercase tracking-wider text-indigo-700 backdrop-blur-sm">
          <Icon name="sparkles" size={13} strokeWidth={2.4} />
          Free for every Pakistani student
        </span>
        <h1 class="mt-6 font-display text-[2.75rem] font-extrabold leading-[1.02] tracking-[-0.04em] text-slate-900 sm:text-6xl lg:text-[4.5rem]">
          Learn anything.<br />
          <span class="bg-gradient-to-r from-indigo-600 via-violet-600 to-fuchsia-600 bg-clip-text text-transparent">
            From Class 9 to 12.
          </span>
        </h1>
        <p class="mt-6 max-w-xl text-base leading-relaxed text-slate-600 sm:text-lg">
          Notes, interactive quizzes, textbooks and result gazettes — organised by class and subject, all completely free.
        </p>

        <form action="/search" method="get" role="search" class="mt-8 flex max-w-lg items-center gap-2 rounded-2xl border border-slate-200 bg-white p-1.5 pl-4 shadow-sm transition-colors focus-within:border-indigo-400">
          <Icon name="search" size={18} strokeWidth={2.4} class="shrink-0 text-slate-400" />
          <input
            type="search"
            name="q"
            placeholder="Search notes, books, past papers..."
            class="min-w-0 flex-1 bg-transparent py-2.5 text-sm text-slate-900 outline-none placeholder:text-slate-400"
          />
          <button type="submit" class="rounded-xl bg-indigo-600 px-4 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-indigo-700">
            Search
          </button>
        </form>

        <div class="mt-6 flex flex-wrap items-center gap-x-6 gap-y-2 text-sm text-slate-500">
          <span class="flex items-center gap-1.5"><Icon name="zap" size={14} strokeWidth={2.4} class="text-indigo-600" /> Instant answers</span>
          <span class="flex items-center gap-1.5"><Icon name="download" size={14} strokeWidth={2.4} class="text-indigo-600" /> Free PDFs</span>
          <span class="flex items-center gap-1.5"><Icon name="check" size={14} strokeWidth={2.6} class="text-indigo-600" /> All boards</span>
        </div>
      </div>
    </div>
  </section>

  <!-- STATS -->
  <section class="mx-auto w-full max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
    <div class="grid grid-cols-2 gap-4 lg:grid-cols-4">
      {categories.map(cat => (
        <a href={cat.href} class="group rounded-2xl border border-slate-200 bg-white p-5 transition-colors hover:border-indigo-300">
          <span class:list={[
            "grid h-11 w-11 place-items-center rounded-xl",
            cat.tint === 'indigo' && "bg-indigo-100 text-indigo-700",
            cat.tint === 'blue'   && "bg-blue-100 text-blue-700",
            cat.tint === 'amber'  && "bg-amber-100 text-amber-700",
            cat.tint === 'rose'   && "bg-rose-100 text-rose-700",
          ]}>
            <Icon name={cat.icon} size={20} strokeWidth={2.2} />
          </span>
          <div class="mt-4 font-display text-3xl font-extrabold tracking-tight text-slate-900">{cat.count}</div>
          <div class="mt-0.5 flex items-center gap-1 text-sm font-semibold text-slate-500">
            {cat.label}
            <Icon name="arrow-up-right" size={13} strokeWidth={2.4} class="opacity-0 transition-opacity group-hover:opacity-100" />
          </div>
        </a>
      ))}
    </div>
  </section>

  <!-- BROWSE BY CLASS -->
  {classes.length > 0 && (
    <section class="mx-auto w-full max-w-7xl px-4 py-14 sm:px-6 lg:px-8">
      <div class="mb-6 flex items-end justify-between gap-4">
        <div>
          <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Browse by class</h2>
          <p class="mt-1.5 text-sm text-slate-500">Everything for your class in one place.</p>
        </div>
        <a href="/classes" class="hidden items-center gap-1 text-sm font-semibold text-indigo-700 hover:text-indigo-800 sm:inline-flex">
          All classes <Icon name="arrow-right" size={14} strokeWidth={2.6} />
        </a>
      </div>
      <div class="grid grid-cols-2 gap-3 lg:grid-cols-4">
        {classes.map(c => (
          <a href={`/classes/${c.class}`} class="group flex items-center gap-3 rounded-2xl border border-slate-200 bg-white p-4 transition-colors hover:border-indigo-300 sm:gap-4 sm:p-5">
            <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-indigo-100 text-indigo-700 sm:h-12 sm:w-12">
              <Icon name="graduation-cap" size={20} strokeWidth={2.2} />
            </span>
            <div class="min-w-0">
              <div class="font-display text-base font-extrabold tracking-tight text-slate-900 sm:text-lg">Class {c.class}</div>
              <div class="truncate text-xs font-semibold text-slate-500">{c.total} {c.total === 1 ? 'item' : 'items'}</div>
            </div>
          </a>
        ))}
      </div>
    </section>
  )}

  <!-- BROWSE BY SUBJECT -->
  {subjects.length > 0 && (
    <section class="mx-auto w-full max-w-7xl px-4 pb-4 sm:px-6 lg:px-8">
      <div class="mb-6 flex items-end justify-between gap-4">
        <div>
          <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Browse by subject</h2>
          <p class="mt-1.5 text-sm text-slate-500">Pick your subject, then your class.</p>
        </div>
        <a href="/subjects" class="hidden items-center gap-1 text-sm font-semibold text-indigo-700 hover:text-indigo-800 sm:inline-flex">
          All subjects <Icon name="arrow-right" size={14} strokeWidth={2.6} />
        </a>
      </div>
      <div class="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
        {subjects.map(s => (
          <a href={`/subjects/${slugify(s.subject)}`} class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-5 transition-colors hover:border-indigo-300">
            <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-indigo-100 text-indigo-700">
              <Icon name="library" size={20} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <div class="font-display text-base font-extrabold tracking-tight text-slate-900">{s.subject}</div>
              <div class="truncate text-xs font-semibold text-slate-500">{s.total} {s.total === 1 ? 'item' : 'items'} · Class {s.classes.join(', ')}</div>
            </div>
            <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-transform group-hover:translate-x-0.5 group-hover:text-indigo-600" />
          </a>
        ))}
      </div>
    </section>
  )}

  <!-- BROWSE THE LIBRARY -->
  <section class="mx-auto w-full max-w-7xl px-4 py-14 sm:px-6 lg:px-8">
    <div class="mb-6">
      <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Browse the library</h2>
      <p class="mt-1.5 text-sm text-slate-500">Jump straight into what you're studying.</p>
    </div>
    <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
      {categories.map(cat => (
        <a href={cat.href} class="group relative overflow-hidden rounded-2xl border border-slate-200 bg-white p-6 transition-colors hover:border-indigo-300">
          <div class="flex items-start justify-between">
            <span class:list={[
              "grid h-12 w-12 place-items-center rounded-xl",
              cat.tint === 'indigo' && "bg-indigo-100 text-indigo-700",
              cat.tint === 'blue'   && "bg-blue-100 text-blue-700",
              cat.tint === 'amber'  && "bg-amber-100 text-amber-700",
              cat.tint === 'rose'   && "bg-rose-100 text-rose-700",
            ]}>
              <Icon name={cat.icon} size={22} strokeWidth={2.2} />
            </span>
            <Icon name="arrow-up-right" size={18} strokeWidth={2.4} class="text-slate-300 transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-indigo-600" />
          </div>
          <h3 class="mt-5 font-display text-lg font-bold tracking-tight text-slate-900">{cat.label}</h3>
          <p class="mt-1 text-sm text-slate-500">{cat.desc}</p>
          <p class="mt-4 text-xs font-semibold uppercase tracking-wide text-slate-400">{cat.count} {cat.count === 1 ? 'item' : 'items'}</p>
        </a>
      ))}
    </div>
  </section>

  <!-- RECENT -->
  {recent.length > 0 && (
    <section class="mx-auto w-full max-w-7xl px-4 pb-20 sm:px-6 lg:px-8">
      <div class="mb-6 flex items-end justify-between gap-4">
        <div>
          <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Recent notes</h2>
          <p class="mt-1.5 text-sm text-slate-500">Freshly added study material.</p>
        </div>
        <a href="/notes" class="hidden items-center gap-1 text-sm font-semibold text-indigo-700 hover:text-indigo-800 sm:inline-flex">
          View all <Icon name="arrow-right" size={14} strokeWidth={2.6} />
        </a>
      </div>
      <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
        {recent.map(n => (
          <a href={`/notes/${n.id}`} class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-4 transition-colors hover:border-indigo-300">
            <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-indigo-100 text-indigo-700">
              <Icon name="file-text" size={18} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <h3 class="truncate text-[0.925rem] font-bold tracking-tight text-slate-900">{n.data.title}</h3>
              <div class="mt-1.5 flex flex-wrap gap-1.5">
                <span class="rounded-md bg-indigo-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-indigo-700">{n.data.subject}</span>
                <span class="rounded-md bg-blue-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-blue-700">Class {n.data.class}</span>
              </div>
            </div>
            <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-transform group-hover:translate-x-0.5 group-hover:text-indigo-600" />
          </a>
        ))}
      </div>
    </section>
  )}
</BaseLayout>
EOF

# ============ CLEAR CACHES ============
rm -rf .astro node_modules/.vite node_modules/.astro dist

echo ""
echo "==================================================="
echo "  Redesign applied"
echo "==================================================="
echo ""
echo "  Fonts:"
echo "    Body    → Manrope"
echo "    Display → Sora"
echo ""
echo "  Colors:"
echo "    Primary → Indigo (#4F46E5)  [was emerald green]"
echo "    Quizzes → Blue (unchanged)"
echo "    Books   → Amber (unchanged)"
echo "    Gazettes→ Rose (unchanged)"
echo ""
echo "  Design updates:"
echo "    - Gradient text hero ('From Class 9 to 12')"
echo "    - Soft blurred color blobs behind hero"
echo "    - Refined header with gradient brand mark"
echo "    - Sora used on every heading"
echo ""
echo "Run:  npm run dev"
echo "Then hard-refresh the browser."