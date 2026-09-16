#!/bin/bash
set -e

echo "Installing Tailwind CSS v4..."
npm install tailwindcss @tailwindcss/vite --silent

echo "Updating astro.config.mjs..."
cat > astro.config.mjs <<'CONF'
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://your-site.pages.dev',
  integrations: [sitemap()],
  vite: { plugins: [tailwindcss()] },
});
CONF

mkdir -p src/styles src/components src/layouts

# ============ GLOBAL CSS ============
cat > src/styles/global.css <<'CSS'
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Plus+Jakarta+Sans:wght@600;700;800&display=swap');
@import "tailwindcss";

@theme {
  --font-sans: "Inter", ui-sans-serif, system-ui, -apple-system, sans-serif;
  --font-display: "Plus Jakarta Sans", "Inter", ui-sans-serif, system-ui, sans-serif;
}

html {
  -webkit-text-size-adjust: 100%;
  scroll-behavior: smooth;
  overflow-x: hidden;
}
body {
  font-family: var(--font-sans);
  background-color: #f8fafc;
  color: #0f172a;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  overflow-x: hidden;
  max-width: 100vw;
}
a { color: inherit; text-decoration: none; }
button { font-family: inherit; cursor: pointer; }
input, select, textarea { font-family: inherit; }

/* Prose for markdown */
.prose { font-size: 0.975rem; line-height: 1.75; color: #334155; }
.prose h1, .prose h2, .prose h3 { color: #0f172a; font-weight: 700; letter-spacing: -0.02em; }
.prose h2 { font-size: 1.25rem; margin-top: 2rem; margin-bottom: 0.75rem; padding-bottom: 0.5rem; border-bottom: 1px solid #e2e8f0; }
.prose h3 { font-size: 1.05rem; margin-top: 1.5rem; margin-bottom: 0.5rem; }
.prose h2:first-child, .prose h3:first-child { margin-top: 0; }
.prose p { margin-bottom: 1rem; }
.prose ul, .prose ol { padding-left: 1.25rem; margin-bottom: 1rem; }
.prose li { margin-bottom: 0.375rem; }
.prose li::marker { color: #059669; }
.prose code {
  background: #ecfdf5; color: #065f46;
  padding: 0.125rem 0.375rem; border-radius: 0.375rem;
  font-size: 0.85em; font-weight: 600;
}
.prose strong { font-weight: 700; color: #0f172a; }
.prose table {
  width: 100%; border-collapse: collapse; margin: 1rem 0;
  font-size: 0.875rem; border: 1px solid #e2e8f0;
  border-radius: 0.5rem; overflow: hidden;
}
.prose th {
  background: #f8fafc; text-align: left;
  padding: 0.625rem 0.75rem; font-weight: 700;
  color: #0f172a; border-bottom: 1px solid #e2e8f0;
}
.prose td { padding: 0.625rem 0.75rem; border-top: 1px solid #e2e8f0; }
.prose a { color: #059669; text-decoration: underline; text-underline-offset: 2px; }

/* Staggered entrance */
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(12px); }
  to   { opacity: 1; transform: translateY(0); }
}
.animate-in { animation: fadeUp 0.55s cubic-bezier(0.16,1,0.3,1) both; }
CSS

# ============ ICON ============
cat > src/components/Icon.astro <<'EOF'
---
interface Props { name: string; size?: number; class?: string; strokeWidth?: number; }
const { name, size = 20, class: className = '', strokeWidth = 2 } = Astro.props;

const icons: Record<string, string> = {
  home: '<path d="M3 9.5 12 3l9 6.5V20a1 1 0 0 1-1 1h-5v-7h-6v7H4a1 1 0 0 1-1-1V9.5Z"/>',
  'book-open': '<path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>',
  'circle-help': '<circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><path d="M12 17h.01"/>',
  library: '<path d="m16 6 4 14"/><path d="M12 6v14"/><path d="M8 8v12"/><path d="M4 4v16"/>',
  newspaper: '<path d="M4 22h16a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2H8a2 2 0 0 0-2 2v16a2 2 0 0 1-4 0V5"/><path d="M18 14h-8"/><path d="M15 18h-5"/><path d="M10 6h8v4h-8V6Z"/>',
  search: '<circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/>',
  x: '<path d="M18 6 6 18"/><path d="m6 6 12 12"/>',
  menu: '<line x1="4" x2="20" y1="6" y2="6"/><line x1="4" x2="20" y1="12" y2="12"/><line x1="4" x2="20" y1="18" y2="18"/>',
  download: '<path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><path d="m7 10 5 5 5-5"/><path d="M12 15V3"/>',
  'chevron-right': '<path d="m9 18 6-6-6-6"/>',
  'arrow-left': '<path d="m12 19-7-7 7-7"/><path d="M19 12H5"/>',
  'arrow-right': '<path d="M5 12h14"/><path d="m12 5 7 7-7 7"/>',
  'arrow-up-right': '<path d="M7 7h10v10"/><path d="M7 17 17 7"/>',
  'graduation-cap': '<path d="M21.42 10.922a1 1 0 0 0-.019-1.838L12.83 5.18a2 2 0 0 0-1.66 0L2.6 9.08a1 1 0 0 0 0 1.832l8.57 3.908a2 2 0 0 0 1.66 0z"/><path d="M22 10v6"/><path d="M6 12.5V16a6 3 0 0 0 12 0v-3.5"/>',
  sparkles: '<path d="m12 3-1.9 5.8a2 2 0 0 1-1.3 1.3L3 12l5.8 1.9a2 2 0 0 1 1.3 1.3L12 21l1.9-5.8a2 2 0 0 1 1.3-1.3L21 12l-5.8-1.9a2 2 0 0 1-1.3-1.3Z"/>',
  zap: '<path d="M13 2 3 14h9l-1 8 10-12h-9l1-8z"/>',
  'file-text': '<path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"/><path d="M14 2v4a2 2 0 0 0 2 2h4"/><path d="M10 9H8"/><path d="M16 13H8"/><path d="M16 17H8"/>',
  'file-question': '<path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"/><path d="M14 2v4a2 2 0 0 0 2 2h4"/><path d="M10 12.5a2 2 0 0 1 4 .5c0 1.5-2 2-2 2"/><path d="M12 18h.01"/>',
  'book-marked': '<path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20l-8-6-8 6z"/><path d="m9 9.5 2 2 4-4"/>',
  'scroll-text': '<path d="M15 12h-5"/><path d="M15 8h-5"/><path d="M19 17V5a2 2 0 0 0-2-2H4"/><path d="M8 21h12a2 2 0 0 0 2-2v-1a1 1 0 0 0-1-1H11a1 1 0 0 0-1 1v1a2 2 0 1 1-4 0V5a2 2 0 1 0-4 0v2a1 1 0 0 0 1 1h3"/>',
  check: '<path d="M20 6 9 17l-5-5"/>',
  clock: '<circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/>',
};
---
<svg xmlns="http://www.w3.org/2000/svg" width={size} height={size} viewBox="0 0 24 24"
  fill="none" stroke="currentColor" stroke-width={strokeWidth}
  stroke-linecap="round" stroke-linejoin="round" class={className}
  set:html={icons[name] || ''} />
EOF

# ============ LAYOUT ============
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
const navItems = [
  { href: '/',         label: 'Home',     icon: 'home' },
  { href: '/notes',    label: 'Notes',    icon: 'book-open' },
  { href: '/quizzes',  label: 'Quizzes',  icon: 'circle-help' },
  { href: '/books',    label: 'Books',    icon: 'library' },
  { href: '/gazettes', label: 'Gazettes', icon: 'newspaper' },
];
const isActive = (href: string) => href === '/' ? path === '/' : path.startsWith(href);
---
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
  <meta name="theme-color" content="#047857" />
  <title>{title}</title>
  <meta name="description" content={description} />
  <meta property="og:title" content={title} />
  <meta property="og:description" content={description} />
  <meta property="og:type" content="website" />
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link rel="sitemap" href="/sitemap-index.xml" />
</head>
<body>
  <!-- Header -->
  <header class="sticky top-0 z-50 w-full border-b border-slate-200 bg-white/85 backdrop-blur-lg">
    <div class="mx-auto flex h-16 w-full max-w-7xl items-center gap-4 px-4 sm:px-6 lg:px-8">
      <a href="/" class="flex shrink-0 items-center gap-2.5">
        <span class="grid h-9 w-9 place-items-center rounded-xl bg-emerald-600 text-white">
          <Icon name="graduation-cap" size={20} strokeWidth={2.4} />
        </span>
        <span class="font-display text-lg font-extrabold tracking-tight">TaleemHub</span>
      </a>

      <nav class="ml-6 hidden items-center gap-1 md:flex">
        {navItems.map(item => (
          <a
            href={item.href}
            class:list={[
              "rounded-lg px-3 py-2 text-sm font-semibold transition-colors",
              isActive(item.href)
                ? "bg-emerald-50 text-emerald-700"
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
          class="hidden h-10 w-64 items-center gap-2 rounded-xl border border-slate-200 bg-slate-50 px-3 transition-colors focus-within:border-emerald-400 focus-within:bg-white lg:flex"
        >
          <Icon name="search" size={16} strokeWidth={2.4} class="shrink-0 text-slate-400" />
          <input
            type="search"
            name="q"
            placeholder="Search library"
            class="min-w-0 flex-1 bg-transparent text-sm text-slate-900 outline-none placeholder:text-slate-400"
          />
          <kbd class="hidden rounded border border-slate-200 bg-white px-1.5 py-0.5 font-mono text-[10px] font-semibold text-slate-500 xl:inline-block">/</kbd>
        </form>

        <a
          href="/search"
          class="grid h-10 w-10 place-items-center rounded-xl border border-slate-200 bg-slate-50 text-slate-600 transition-colors hover:bg-white hover:text-slate-900 lg:hidden"
          aria-label="Search"
        >
          <Icon name="search" size={18} strokeWidth={2.4} />
        </a>

        <a
          href="/notes"
          class="hidden items-center gap-1.5 rounded-xl bg-emerald-600 px-4 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-emerald-700 sm:inline-flex"
        >
          Start learning
          <Icon name="arrow-right" size={14} strokeWidth={2.6} />
        </a>
      </div>
    </div>
  </header>

  <main class="min-h-[60vh] pb-28 md:pb-0">
    <slot />
  </main>

  <footer class="mt-24 hidden border-t border-slate-200 bg-white md:block">
    <div class="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
      <div class="grid gap-10 sm:grid-cols-2 lg:grid-cols-4">
        <div class="sm:col-span-2">
          <div class="flex items-center gap-2.5">
            <span class="grid h-9 w-9 place-items-center rounded-xl bg-emerald-600 text-white">
              <Icon name="graduation-cap" size={20} strokeWidth={2.4} />
            </span>
            <span class="font-display text-lg font-extrabold tracking-tight">TaleemHub</span>
          </div>
          <p class="mt-4 max-w-sm text-sm leading-relaxed text-slate-500">
            Free notes, interactive quizzes, textbooks and result gazettes for students across Pakistan — all in one place.
          </p>
        </div>
        <div>
          <h4 class="text-sm font-bold text-slate-900">Library</h4>
          <ul class="mt-4 space-y-2.5 text-sm text-slate-500">
            <li><a href="/notes" class="hover:text-emerald-700">Notes</a></li>
            <li><a href="/quizzes" class="hover:text-emerald-700">Quizzes</a></li>
            <li><a href="/books" class="hover:text-emerald-700">Textbooks</a></li>
            <li><a href="/gazettes" class="hover:text-emerald-700">Gazettes</a></li>
          </ul>
        </div>
        <div>
          <h4 class="text-sm font-bold text-slate-900">Explore</h4>
          <ul class="mt-4 space-y-2.5 text-sm text-slate-500">
            <li><a href="/search" class="hover:text-emerald-700">Search</a></li>
            <li><a href="/notes" class="hover:text-emerald-700">Class 9</a></li>
            <li><a href="/notes" class="hover:text-emerald-700">Class 10</a></li>
            <li><a href="/gazettes" class="hover:text-emerald-700">Latest results</a></li>
          </ul>
        </div>
      </div>
      <div class="mt-10 flex flex-col gap-2 border-t border-slate-200 pt-6 text-xs text-slate-400 sm:flex-row sm:items-center sm:justify-between">
        <p>© {new Date().getFullYear()} TaleemHub. Built for students, forever free.</p>
        <p>Made in Pakistan</p>
      </div>
    </div>
  </footer>

  <!-- Mobile bottom nav -->
  <nav class="fixed inset-x-0 bottom-0 z-50 border-t border-slate-200 bg-white/95 backdrop-blur-lg md:hidden" style="padding-bottom: env(safe-area-inset-bottom);">
    <div class="flex items-center justify-around">
      {navItems.map(item => (
        <a
          href={item.href}
          class:list={[
            "flex min-w-[56px] flex-col items-center gap-1 px-3 py-2.5 text-[11px] font-semibold transition-colors",
            isActive(item.href) ? "text-emerald-600" : "text-slate-400",
          ]}
        >
          <Icon name={item.icon} size={20} strokeWidth={2.2} />
          <span>{item.label}</span>
        </a>
      ))}
    </div>
  </nav>

  <script is:inline>
    document.addEventListener('keydown', function (e) {
      var t = e.target;
      if (e.key === '/' && t && t.tagName !== 'INPUT' && t.tagName !== 'TEXTAREA' && !t.isContentEditable) {
        var input = document.querySelector('.header-search input') || document.querySelector('input[type="search"]');
        if (input) { e.preventDefault(); input.focus(); }
      }
    });
  </script>
</body>
</html>
EOF

# ============ SEARCH INDEX ============
cat > src/pages/search.json.ts <<'EOF'
export const prerender = true;
import { getCollection } from 'astro:content';

export async function GET() {
  const [notes, quizzes, books, gazettes] = await Promise.all([
    getCollection('notes'),
    getCollection('quizzes'),
    getCollection('books'),
    getCollection('gazettes'),
  ]);
  const index = [
    ...notes.map(n => ({ type: 'note', title: n.data.title, url: `/notes/${n.id}`, subject: n.data.subject, class: n.data.class })),
    ...quizzes.map(q => ({ type: 'quiz', title: q.data.title, url: `/quizzes/${q.id}`, subject: q.data.subject, class: q.data.class })),
    ...books.map(b => ({ type: 'book', title: b.data.title, url: `/books/${b.id}`, subject: b.data.subject, class: b.data.class })),
    ...gazettes.map(g => ({ type: 'gazette', title: g.data.title, url: `/gazettes/${g.id}`, subject: g.data.board, class: g.data.class })),
  ];
  return new Response(JSON.stringify(index), {
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
  });
}
EOF

# ============ HOME ============
cat > src/pages/index.astro <<'EOF'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { getCollection } from 'astro:content';

const notes = await getCollection('notes');
const quizzes = await getCollection('quizzes');
const books = await getCollection('books');
const gazettes = await getCollection('gazettes');

const categories = [
  { href: '/notes',    label: 'Notes',    count: notes.length,    icon: 'file-text',     tint: 'emerald', desc: 'Chapter-wise notes for every subject' },
  { href: '/quizzes',  label: 'Quizzes',  count: quizzes.length,  icon: 'file-question', tint: 'blue',    desc: 'Practice MCQs with instant answers' },
  { href: '/books',    label: 'Books',    count: books.length,    icon: 'book-marked',   tint: 'amber',   desc: 'Full textbooks from every board' },
  { href: '/gazettes', label: 'Gazettes', count: gazettes.length, icon: 'scroll-text',   tint: 'rose',    desc: 'Official results and past gazettes' },
];

const recent = [...notes].slice(0, 6);
---
<BaseLayout title="TaleemHub — Notes, Quizzes & Books for Pakistani Students">
  <!-- HERO -->
  <section class="relative overflow-hidden border-b border-slate-200 bg-gradient-to-b from-emerald-50/70 via-white to-white">
    <div class="mx-auto w-full max-w-7xl px-4 py-14 sm:px-6 sm:py-20 lg:px-8 lg:py-24">
      <div class="grid items-center gap-12 lg:grid-cols-2 lg:gap-16">
        <div class="animate-in">
          <span class="inline-flex items-center gap-1.5 rounded-full border border-emerald-200 bg-emerald-50 px-3 py-1 text-xs font-semibold text-emerald-700">
            <Icon name="sparkles" size={13} strokeWidth={2.4} />
            Free for every Pakistani student
          </span>
          <h1 class="mt-5 font-display text-4xl font-extrabold leading-[1.08] tracking-tight text-slate-900 sm:text-5xl lg:text-[3.25rem]">
            Everything you need to <span class="text-emerald-600">study smarter</span>.
          </h1>
          <p class="mt-5 max-w-lg text-base leading-relaxed text-slate-600 sm:text-lg">
            Notes, interactive quizzes, textbooks and result gazettes — all in one place, all completely free.
          </p>

          <form action="/search" method="get" role="search" class="mt-8 flex max-w-lg items-center gap-2 rounded-2xl border border-slate-200 bg-white p-1.5 pl-4 transition-colors focus-within:border-emerald-400">
            <Icon name="search" size={18} strokeWidth={2.4} class="shrink-0 text-slate-400" />
            <input
              type="search"
              name="q"
              placeholder="Search notes, books, past papers..."
              class="min-w-0 flex-1 bg-transparent py-2.5 text-sm text-slate-900 outline-none placeholder:text-slate-400"
            />
            <button type="submit" class="rounded-xl bg-emerald-600 px-4 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-emerald-700">
              Search
            </button>
          </form>

          <div class="mt-6 flex flex-wrap items-center gap-x-6 gap-y-2 text-sm text-slate-500">
            <span class="flex items-center gap-1.5"><Icon name="zap" size={14} strokeWidth={2.4} class="text-emerald-600" /> Instant answers</span>
            <span class="flex items-center gap-1.5"><Icon name="download" size={14} strokeWidth={2.4} class="text-emerald-600" /> Free PDFs</span>
            <span class="flex items-center gap-1.5"><Icon name="check" size={14} strokeWidth={2.6} class="text-emerald-600" /> All boards</span>
          </div>
        </div>

        <!-- Stat bento -->
        <div class="animate-in grid grid-cols-2 gap-4">
          {categories.map(cat => (
            <a
              href={cat.href}
              class="group rounded-2xl border border-slate-200 bg-white p-5 transition-colors hover:border-emerald-300"
            >
              <span class:list={[
                "grid h-11 w-11 place-items-center rounded-xl",
                cat.tint === 'emerald' && "bg-emerald-100 text-emerald-700",
                cat.tint === 'blue'    && "bg-blue-100 text-blue-700",
                cat.tint === 'amber'   && "bg-amber-100 text-amber-700",
                cat.tint === 'rose'    && "bg-rose-100 text-rose-700",
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
      </div>
    </div>
  </section>

  <!-- CATEGORIES -->
  <section class="mx-auto w-full max-w-7xl px-4 py-14 sm:px-6 sm:py-16 lg:px-8">
    <div class="mb-8 flex items-end justify-between gap-4">
      <div>
        <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Browse the library</h2>
        <p class="mt-1.5 text-sm text-slate-500 sm:text-base">Jump straight into what you're studying.</p>
      </div>
    </div>

    <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
      {categories.map(cat => (
        <a
          href={cat.href}
          class="group relative overflow-hidden rounded-2xl border border-slate-200 bg-white p-6 transition-colors hover:border-emerald-300"
        >
          <div class="flex items-start justify-between">
            <span class:list={[
              "grid h-12 w-12 place-items-center rounded-xl",
              cat.tint === 'emerald' && "bg-emerald-100 text-emerald-700",
              cat.tint === 'blue'    && "bg-blue-100 text-blue-700",
              cat.tint === 'amber'   && "bg-amber-100 text-amber-700",
              cat.tint === 'rose'    && "bg-rose-100 text-rose-700",
            ]}>
              <Icon name={cat.icon} size={22} strokeWidth={2.2} />
            </span>
            <Icon
              name="arrow-up-right"
              size={18}
              strokeWidth={2.4}
              class="text-slate-300 transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-emerald-600"
            />
          </div>
          <h3 class="mt-5 font-display text-lg font-bold tracking-tight text-slate-900">{cat.label}</h3>
          <p class="mt-1 text-sm text-slate-500">{cat.desc}</p>
          <p class="mt-4 text-xs font-semibold uppercase tracking-wide text-slate-400">{cat.count} {cat.count === 1 ? 'item' : 'items'}</p>
        </a>
      ))}
    </div>
  </section>

  <!-- RECENT -->
  <section class="mx-auto w-full max-w-7xl px-4 pb-20 sm:px-6 lg:px-8">
    <div class="mb-6 flex items-end justify-between gap-4">
      <div>
        <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Recent notes</h2>
        <p class="mt-1.5 text-sm text-slate-500">Freshly added study material.</p>
      </div>
      <a href="/notes" class="hidden items-center gap-1 text-sm font-semibold text-emerald-700 hover:text-emerald-800 sm:inline-flex">
        View all <Icon name="arrow-right" size={14} strokeWidth={2.6} />
      </a>
    </div>

    <div class="grid gap-3 md:grid-cols-2">
      {recent.map(n => (
        <a href={`/notes/${n.id}`} class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-4 transition-colors hover:border-emerald-300">
          <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-emerald-100 text-emerald-700">
            <Icon name="file-text" size={18} strokeWidth={2.2} />
          </span>
          <div class="min-w-0 flex-1">
            <h3 class="truncate text-[0.925rem] font-bold tracking-tight text-slate-900">{n.data.title}</h3>
            <div class="mt-1.5 flex flex-wrap gap-1.5">
              <span class="rounded-md bg-emerald-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-emerald-700">{n.data.subject}</span>
              <span class="rounded-md bg-blue-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-blue-700">Class {n.data.class}</span>
            </div>
          </div>
          <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-transform group-hover:translate-x-0.5 group-hover:text-emerald-600" />
        </a>
      ))}
    </div>
  </section>
</BaseLayout>
EOF

# ============ NOTES ============
cat > src/pages/notes/index.astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { getCollection } from 'astro:content';

const notes = (await getCollection('notes')).sort((a, b) => a.data.title.localeCompare(b.data.title));
---
<BaseLayout title="Notes — TaleemHub" description="Subject-wise notes for Pakistani students.">
  <div class="mx-auto w-full max-w-7xl px-4 pt-10 sm:px-6 sm:pt-14 lg:px-8">
    <div class="mb-8">
      <h1 class="font-display text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">Notes</h1>
      <p class="mt-2 text-slate-500">{notes.length} {notes.length === 1 ? 'note' : 'notes'} across all subjects</p>
    </div>

    <div class="grid gap-3 md:grid-cols-2">
      {notes.map(n => (
        <a href={`/notes/${n.id}`} class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-4 transition-colors hover:border-emerald-300">
          <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-emerald-100 text-emerald-700">
            <Icon name="file-text" size={18} strokeWidth={2.2} />
          </span>
          <div class="min-w-0 flex-1">
            <h3 class="truncate text-[0.925rem] font-bold tracking-tight text-slate-900">{n.data.title}</h3>
            <div class="mt-1.5 flex flex-wrap gap-1.5">
              <span class="rounded-md bg-emerald-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-emerald-700">{n.data.subject}</span>
              <span class="rounded-md bg-blue-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-blue-700">Class {n.data.class}</span>
              {n.data.board && <span class="rounded-md bg-amber-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-amber-700">{n.data.board}</span>}
            </div>
          </div>
          <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-transform group-hover:translate-x-0.5 group-hover:text-emerald-600" />
        </a>
      ))}
    </div>
  </div>
</BaseLayout>
EOF

cat > src/pages/notes/[...slug].astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { getCollection, render } from 'astro:content';

export async function getStaticPaths() {
  const notes = await getCollection('notes');
  return notes.map(note => ({ params: { slug: note.id }, props: { note } }));
}
const { note } = Astro.props;
const { Content } = await render(note);
---
<BaseLayout title={`${note.data.title} — TaleemHub`} description={`${note.data.subject} notes for Class ${note.data.class}.`}>
  <div class="mx-auto w-full max-w-4xl px-4 pt-8 sm:px-6 sm:pt-12 lg:px-8">
    <a href="/notes" class="mb-6 inline-flex items-center gap-2 text-sm font-semibold text-slate-500 transition-colors hover:text-emerald-700">
      <Icon name="arrow-left" size={16} strokeWidth={2.4} /> Back to notes
    </a>

    <div class="relative overflow-hidden rounded-3xl border border-emerald-700 bg-gradient-to-br from-emerald-900 via-emerald-800 to-emerald-600 p-7 text-white sm:p-9">
      <div class="flex flex-wrap gap-1.5">
        <span class="rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wide backdrop-blur-sm">{note.data.subject}</span>
        <span class="rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wide backdrop-blur-sm">Class {note.data.class}</span>
        {note.data.board && <span class="rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wide backdrop-blur-sm">{note.data.board}</span>}
      </div>
      <h1 class="mt-4 font-display text-2xl font-extrabold leading-tight tracking-tight sm:text-3xl">{note.data.title}</h1>
    </div>

    {note.data.pdfUrl && (
      <a href={note.data.pdfUrl} class="mt-5 flex w-full items-center justify-center gap-2 rounded-xl bg-emerald-600 px-5 py-3.5 text-sm font-semibold text-white transition-colors hover:bg-emerald-700">
        <Icon name="download" size={18} strokeWidth={2.4} /> Download PDF
      </a>
    )}

    <article class="prose mt-6 rounded-2xl border border-slate-200 bg-white p-6 sm:p-8">
      <Content />
    </article>
  </div>
</BaseLayout>
EOF

# ============ QUIZZES ============
cat > src/pages/quizzes/index.astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { getCollection } from 'astro:content';

const quizzes = await getCollection('quizzes');
---
<BaseLayout title="Quizzes — TaleemHub" description="Practice MCQs for Pakistani students.">
  <div class="mx-auto w-full max-w-7xl px-4 pt-10 sm:px-6 sm:pt-14 lg:px-8">
    <div class="mb-8">
      <h1 class="font-display text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">Quizzes</h1>
      <p class="mt-2 text-slate-500">{quizzes.length} interactive MCQ {quizzes.length === 1 ? 'quiz' : 'quizzes'}</p>
    </div>

    <div class="grid gap-3 md:grid-cols-2">
      {quizzes.map(q => (
        <a href={`/quizzes/${q.id}`} class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-4 transition-colors hover:border-blue-300">
          <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-blue-100 text-blue-700">
            <Icon name="file-question" size={18} strokeWidth={2.2} />
          </span>
          <div class="min-w-0 flex-1">
            <h3 class="truncate text-[0.925rem] font-bold tracking-tight text-slate-900">{q.data.title}</h3>
            <div class="mt-1.5 flex flex-wrap gap-1.5">
              <span class="rounded-md bg-blue-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-blue-700">{q.data.subject}</span>
              <span class="rounded-md bg-emerald-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-emerald-700">Class {q.data.class}</span>
              <span class="rounded-md bg-amber-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-amber-700">{q.data.questions.length} MCQs</span>
            </div>
          </div>
          <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-transform group-hover:translate-x-0.5 group-hover:text-blue-600" />
        </a>
      ))}
    </div>
  </div>
</BaseLayout>
EOF

cat > src/pages/quizzes/[...slug].astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { getCollection, render } from 'astro:content';

export async function getStaticPaths() {
  const quizzes = await getCollection('quizzes');
  return quizzes.map(quiz => ({ params: { slug: quiz.id }, props: { quiz } }));
}
const { quiz } = Astro.props;
const { Content } = await render(quiz);
---
<BaseLayout title={`${quiz.data.title} — TaleemHub`} description={`Practice MCQs for ${quiz.data.subject} Class ${quiz.data.class}.`}>
  <div class="mx-auto w-full max-w-4xl px-4 pt-8 sm:px-6 sm:pt-12 lg:px-8">
    <a href="/quizzes" class="mb-6 inline-flex items-center gap-2 text-sm font-semibold text-slate-500 transition-colors hover:text-blue-700">
      <Icon name="arrow-left" size={16} strokeWidth={2.4} /> Back to quizzes
    </a>

    <div class="relative overflow-hidden rounded-3xl border border-blue-700 bg-gradient-to-br from-blue-900 via-blue-800 to-blue-600 p-7 text-white sm:p-9">
      <div class="flex flex-wrap gap-1.5">
        <span class="rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wide backdrop-blur-sm">{quiz.data.subject}</span>
        <span class="rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wide backdrop-blur-sm">Class {quiz.data.class}</span>
        <span class="rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wide backdrop-blur-sm">{quiz.data.questions.length} MCQs</span>
      </div>
      <h1 class="mt-4 font-display text-2xl font-extrabold leading-tight tracking-tight sm:text-3xl">{quiz.data.title}</h1>
    </div>

    <div class="mt-6 space-y-3">
      {quiz.data.questions.map((q, i) => (
        <div class="rounded-2xl border border-slate-200 bg-white p-5 sm:p-6">
          <h4 class="flex items-start gap-3 text-[0.95rem] font-bold leading-relaxed tracking-tight text-slate-900">
            <span class="mt-0.5 grid h-6 min-w-[26px] shrink-0 place-items-center rounded-md bg-blue-100 px-1.5 text-[11px] font-extrabold text-blue-700">Q{i + 1}</span>
            <span>{q.question}</span>
          </h4>
          <div class="mt-4 space-y-2">
            {q.options.map((opt, j) => (
              <div class="flex items-center gap-3 rounded-xl border border-slate-200 bg-slate-50 px-3.5 py-3 text-[0.875rem] transition-colors hover:border-blue-300 hover:bg-blue-50">
                <span class="grid h-6 w-6 shrink-0 place-items-center rounded-md border border-slate-200 bg-white text-[11px] font-extrabold text-slate-500">{String.fromCharCode(65 + j)}</span>
                <span class="text-slate-700">{opt}</span>
              </div>
            ))}
          </div>
          <details class="group mt-3">
            <summary class="inline-flex cursor-pointer list-none items-center gap-1.5 rounded-lg px-2.5 py-1.5 text-[0.8rem] font-bold text-blue-700 transition-colors hover:bg-blue-50">
              <Icon name="chevron-right" size={13} strokeWidth={2.8} class="transition-transform group-open:rotate-90" />
              Show answer
            </summary>
            <div class="mt-2.5 flex items-center gap-2 rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm font-bold text-emerald-800 animate-in">
              <Icon name="check" size={15} strokeWidth={3} />
              {String.fromCharCode(65 + q.answer)}. {q.options[q.answer]}
            </div>
          </details>
        </div>
      ))}
    </div>

    <article class="prose mt-6 rounded-2xl border border-slate-200 bg-white p-6 sm:p-8">
      <Content />
    </article>
  </div>
</BaseLayout>
EOF

# ============ BOOKS ============
cat > src/pages/books/index.astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { getCollection } from 'astro:content';

const books = await getCollection('books');
---
<BaseLayout title="Textbooks — TaleemHub" description="Free textbooks for Pakistani students.">
  <div class="mx-auto w-full max-w-7xl px-4 pt-10 sm:px-6 sm:pt-14 lg:px-8">
    <div class="mb-8">
      <h1 class="font-display text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">Textbooks</h1>
      <p class="mt-2 text-slate-500">{books.length} {books.length === 1 ? 'textbook' : 'textbooks'} ready to download</p>
    </div>

    <div class="grid gap-3 md:grid-cols-2">
      {books.map(b => (
        <a href={`/books/${b.id}`} class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-4 transition-colors hover:border-amber-300">
          <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-amber-100 text-amber-700">
            <Icon name="book-marked" size={18} strokeWidth={2.2} />
          </span>
          <div class="min-w-0 flex-1">
            <h3 class="truncate text-[0.925rem] font-bold tracking-tight text-slate-900">{b.data.title}</h3>
            <div class="mt-1.5 flex flex-wrap gap-1.5">
              <span class="rounded-md bg-amber-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-amber-700">{b.data.subject}</span>
              <span class="rounded-md bg-emerald-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-emerald-700">Class {b.data.class}</span>
              {b.data.author && <span class="rounded-md bg-slate-100 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-slate-600">{b.data.author}</span>}
            </div>
          </div>
          <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-transform group-hover:translate-x-0.5 group-hover:text-amber-600" />
        </a>
      ))}
    </div>
  </div>
</BaseLayout>
EOF

cat > src/pages/books/[...slug].astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const books = await getCollection('books');
  return books.map(book => ({ params: { slug: book.id }, props: { book } }));
}
const { book } = Astro.props;
---
<BaseLayout title={`${book.data.title} — TaleemHub`} description={`Download ${book.data.title} PDF for Class ${book.data.class}.`}>
  <div class="mx-auto w-full max-w-4xl px-4 pt-8 sm:px-6 sm:pt-12 lg:px-8">
    <a href="/books" class="mb-6 inline-flex items-center gap-2 text-sm font-semibold text-slate-500 transition-colors hover:text-amber-700">
      <Icon name="arrow-left" size={16} strokeWidth={2.4} /> Back to textbooks
    </a>

    <div class="relative overflow-hidden rounded-3xl border border-amber-700 bg-gradient-to-br from-amber-900 via-amber-800 to-amber-600 p-7 text-white sm:p-9">
      <div class="flex flex-wrap gap-1.5">
        <span class="rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wide backdrop-blur-sm">{book.data.subject}</span>
        <span class="rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wide backdrop-blur-sm">Class {book.data.class}</span>
        {book.data.author && <span class="rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wide backdrop-blur-sm">{book.data.author}</span>}
      </div>
      <h1 class="mt-4 font-display text-2xl font-extrabold leading-tight tracking-tight sm:text-3xl">{book.data.title}</h1>
    </div>

    <a href={book.data.pdfUrl} target="_blank" rel="noopener" class="mt-5 flex w-full items-center justify-center gap-2 rounded-xl bg-amber-600 px-5 py-3.5 text-sm font-semibold text-white transition-colors hover:bg-amber-700">
      <Icon name="download" size={18} strokeWidth={2.4} /> Download PDF
    </a>
  </div>
</BaseLayout>
EOF

# ============ GAZETTES ============
cat > src/pages/gazettes/index.astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { getCollection } from 'astro:content';

const gazettes = await getCollection('gazettes');
---
<BaseLayout title="Result Gazettes — TaleemHub" description="Board result gazettes for Pakistani students.">
  <div class="mx-auto w-full max-w-7xl px-4 pt-10 sm:px-6 sm:pt-14 lg:px-8">
    <div class="mb-8">
      <h1 class="font-display text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">Result gazettes</h1>
      <p class="mt-2 text-slate-500">{gazettes.length} {gazettes.length === 1 ? 'gazette' : 'gazettes'} from Pakistani boards</p>
    </div>

    <div class="grid gap-3 md:grid-cols-2">
      {gazettes.map(g => (
        <a href={`/gazettes/${g.id}`} class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-4 transition-colors hover:border-rose-300">
          <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-rose-100 text-rose-700">
            <Icon name="scroll-text" size={18} strokeWidth={2.2} />
          </span>
          <div class="min-w-0 flex-1">
            <h3 class="truncate text-[0.925rem] font-bold tracking-tight text-slate-900">{g.data.title}</h3>
            <div class="mt-1.5 flex flex-wrap gap-1.5">
              <span class="rounded-md bg-rose-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-rose-700">{g.data.board}</span>
              <span class="rounded-md bg-emerald-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-emerald-700">Class {g.data.class}</span>
              <span class="rounded-md bg-amber-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-amber-700">{g.data.year}</span>
            </div>
          </div>
          <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-transform group-hover:translate-x-0.5 group-hover:text-rose-600" />
        </a>
      ))}
    </div>
  </div>
</BaseLayout>
EOF

cat > src/pages/gazettes/[...slug].astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const gazettes = await getCollection('gazettes');
  return gazettes.map(g => ({ params: { slug: g.id }, props: { gazette: g } }));
}
const { gazette } = Astro.props;
---
<BaseLayout title={`${gazette.data.title} — TaleemHub`} description={`${gazette.data.board} result gazette for Class ${gazette.data.class}, ${gazette.data.year}.`}>
  <div class="mx-auto w-full max-w-4xl px-4 pt-8 sm:px-6 sm:pt-12 lg:px-8">
    <a href="/gazettes" class="mb-6 inline-flex items-center gap-2 text-sm font-semibold text-slate-500 transition-colors hover:text-rose-700">
      <Icon name="arrow-left" size={16} strokeWidth={2.4} /> Back to gazettes
    </a>

    <div class="relative overflow-hidden rounded-3xl border border-rose-700 bg-gradient-to-br from-rose-900 via-rose-800 to-rose-600 p-7 text-white sm:p-9">
      <div class="flex flex-wrap gap-1.5">
        <span class="rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wide backdrop-blur-sm">{gazette.data.board}</span>
        <span class="rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wide backdrop-blur-sm">Class {gazette.data.class}</span>
        <span class="rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wide backdrop-blur-sm">{gazette.data.year}</span>
      </div>
      <h1 class="mt-4 font-display text-2xl font-extrabold leading-tight tracking-tight sm:text-3xl">{gazette.data.title}</h1>
    </div>

    <a href={gazette.data.pdfUrl} target="_blank" rel="noopener" class="mt-5 flex w-full items-center justify-center gap-2 rounded-xl bg-rose-600 px-5 py-3.5 text-sm font-semibold text-white transition-colors hover:bg-rose-700">
      <Icon name="download" size={18} strokeWidth={2.4} /> Download gazette PDF
    </a>
  </div>
</BaseLayout>
EOF

# ============ SEARCH PAGE ============
cat > src/pages/search.astro <<'EOF'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
---
<BaseLayout title="Search — TaleemHub" description="Search notes, quizzes, textbooks and gazettes.">
  <div class="mx-auto w-full max-w-4xl px-4 pt-10 sm:px-6 sm:pt-14 lg:px-8">
    <div class="mb-8">
      <h1 class="font-display text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">Search</h1>
      <p class="mt-2 text-slate-500">Find anything across the library</p>
    </div>

    <div class="rounded-2xl border border-slate-200 bg-white p-4 sm:p-5">
      <div class="flex items-center gap-3 rounded-xl border border-slate-200 bg-slate-50 px-4 py-1 transition-colors focus-within:border-emerald-400 focus-within:bg-white">
        <Icon name="search" size={20} strokeWidth={2.4} class="shrink-0 text-slate-400" />
        <input
          id="search-input"
          type="search"
          placeholder="Search notes, quizzes, books, gazettes..."
          aria-label="Search library"
          autocomplete="off"
          autofocus
          class="min-w-0 flex-1 bg-transparent py-3.5 text-base text-slate-900 outline-none placeholder:text-slate-400"
        />
        <button id="clear-btn" type="button" aria-label="Clear" class="hidden h-7 w-7 shrink-0 place-items-center rounded-md text-slate-400 transition-colors hover:bg-white hover:text-slate-700">
          <Icon name="x" size={16} strokeWidth={2.4} />
        </button>
      </div>
      <div id="search-status" class="mt-3.5 text-sm font-semibold text-slate-500">Loading library...</div>
    </div>

    <div id="search-results" class="mt-5 space-y-2.5"></div>
  </div>

  <script is:inline>
    (function () {
      var input = document.getElementById('search-input');
      var results = document.getElementById('search-results');
      var status = document.getElementById('search-status');
      var clearBtn = document.getElementById('clear-btn');
      var index = [];
      var ready = false;

      var params = new URLSearchParams(window.location.search);
      var initialQ = params.get('q') || '';
      if (initialQ) input.value = initialQ;

      function esc(s) {
        return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
          return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
        });
      }
      function typeLabel(t) {
        return { note: 'Note', quiz: 'Quiz', book: 'Book', gazette: 'Gazette' }[t] || t;
      }
      function typeCls(t) {
        return {
          note: 'bg-emerald-50 text-emerald-700 border-emerald-200',
          quiz: 'bg-blue-50 text-blue-700 border-blue-200',
          book: 'bg-amber-50 text-amber-700 border-amber-200',
          gazette: 'bg-rose-50 text-rose-700 border-rose-200',
        }[t] || 'bg-slate-100 text-slate-700 border-slate-200';
      }

      function render() {
        var q = input.value.trim().toLowerCase();
        if (clearBtn) {
          if (input.value) {
            clearBtn.classList.remove('hidden');
            clearBtn.classList.add('grid');
          } else {
            clearBtn.classList.add('hidden');
            clearBtn.classList.remove('grid');
          }
        }

        if (!ready) { status.textContent = 'Loading library...'; results.innerHTML = ''; return; }

        if (!q) {
          status.textContent = index.length + ' items in library';
          results.innerHTML = '';
          return;
        }

        var matches = index.filter(function (it) {
          var t = (it.title || '').toLowerCase();
          var s = (it.subject || '').toLowerCase();
          var c = String(it.class || '').toLowerCase();
          var ty = (it.type || '').toLowerCase();
          return t.indexOf(q) !== -1 || s.indexOf(q) !== -1 || c.indexOf(q) !== -1 || ty.indexOf(q) !== -1;
        });

        status.textContent = matches.length + ' result' + (matches.length === 1 ? '' : 's');

        if (!matches.length) {
          results.innerHTML =
            '<div class="rounded-2xl border border-dashed border-slate-300 bg-white p-12 text-center">' +
              '<div class="text-base font-bold text-slate-900">No results found</div>' +
              '<div class="mt-1 text-sm text-slate-500">Try a different keyword, class number, or subject.</div>' +
            '</div>';
          return;
        }

        results.innerHTML = matches.map(function (m) {
          var badges = '';
          if (m.subject) badges += '<span class="rounded-md bg-emerald-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-emerald-700">' + esc(m.subject) + '</span>';
          if (m.class)   badges += '<span class="rounded-md bg-blue-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-blue-700">Class ' + esc(m.class) + '</span>';
          return '<a href="' + esc(m.url) + '" class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-4 transition-colors hover:border-emerald-300">' +
            '<span class="rounded-md border px-2.5 py-1 text-[10px] font-extrabold uppercase tracking-wider ' + typeCls(m.type) + '">' + esc(typeLabel(m.type)) + '</span>' +
            '<div class="min-w-0 flex-1">' +
              '<h3 class="truncate text-[0.925rem] font-bold tracking-tight text-slate-900">' + esc(m.title) + '</h3>' +
              '<div class="mt-1.5 flex flex-wrap gap-1.5">' + badges + '</div>' +
            '</div>' +
            '<svg class="shrink-0 text-slate-300 transition-transform group-hover:translate-x-0.5 group-hover:text-emerald-600" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>' +
          '</a>';
        }).join('');
      }

      if (clearBtn) clearBtn.addEventListener('click', function () { input.value = ''; input.focus(); render(); });
      input.addEventListener('input', render);

      fetch('/search.json')
        .then(function (r) { if (!r.ok) throw new Error('bad response'); return r.json(); })
        .then(function (data) { index = data; ready = true; render(); })
        .catch(function () {
          status.textContent = 'Could not load library.';
          results.innerHTML = '<div class="rounded-2xl border border-dashed border-slate-300 bg-white p-12 text-center"><div class="text-base font-bold text-slate-900">Search unavailable</div><div class="mt-1 text-sm text-slate-500">Please refresh the page.</div></div>';
        });
    })();
  </script>
</BaseLayout>
EOF

echo ""
echo "==================================================="
echo "  Tailwind rewrite complete"
echo "==================================================="
echo ""
echo "  - Tailwind CSS v4 installed via @tailwindcss/vite"
echo "  - Horizontal overflow fixed (html + body overflow-x: hidden)"
echo "  - Responsive: header nav on md+, bottom nav on mobile"
echo "  - No box-shadows anywhere"
echo "  - Working search: /search.json + /search page"
echo "  - International-level layout (hero, bento stats, sections, footer)"
echo ""
echo "Now run:  npm run dev"