#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Flat design + search overhaul"
echo "════════════════════════════════════════════"
echo ""

# ───────────────────────────────────────────────
#  1. GLOBAL CSS — flat, no shadows
# ───────────────────────────────────────────────
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
  --bg: #fbfcfe;

  --line: #e5e9f0;
  --line-2: #cbd5e1;

  --r-xs: 6px;
  --r-sm: 8px;
  --r: 12px;
  --r-lg: 16px;
}

/* ── Global resets ── */
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
  letter-spacing: -0.028em;
  font-weight: 800;
}

/* ═══ FLAT DESIGN — kill every shadow site-wide ═══ */
*, *::before, *::after { box-shadow: none !important; }

/* ── Card row (list pattern) — flat, border-only ── */
.card-link {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.125rem 1.25rem;
  background: var(--surface);
  border: 1px solid var(--line);
  border-radius: var(--r-lg);
  transition: border-color .15s ease, background-color .15s ease;
}
.card-link:hover {
  border-color: var(--brand);
  background: var(--brand-tint);
}

/* ── Card block ── */
.card {
  background: var(--surface);
  border: 1px solid var(--line);
  border-radius: var(--r-lg);
  transition: border-color .15s ease, background-color .15s ease;
}
.card:hover {
  border-color: var(--brand);
  background: var(--brand-tint);
}

/* ── Icon tile — pastel blue square ── */
.icon-tile {
  display: grid;
  place-items: center;
  width: 2.75rem;
  height: 2.75rem;
  border-radius: var(--r);
  background: var(--brand-tint);
  color: var(--brand);
  flex-shrink: 0;
  border: 1px solid var(--brand-line);
  transition: background-color .15s ease, color .15s ease;
}
.card-link:hover .icon-tile,
.card:hover .icon-tile {
  background: var(--brand);
  color: #ffffff;
  border-color: var(--brand);
}

/* ── Buttons ── */
.btn-primary {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.8rem 1.35rem;
  border-radius: var(--r);
  background: var(--brand);
  color: #ffffff !important;
  font-weight: 700;
  font-size: 0.875rem;
  letter-spacing: -0.005em;
  border: 1px solid var(--brand);
  transition: background-color .15s ease, border-color .15s ease;
}
.btn-primary:hover {
  background: var(--brand-dark);
  border-color: var(--brand-dark);
}

.btn-outline {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.8rem 1.35rem;
  border-radius: var(--r);
  background: var(--surface);
  color: var(--ink);
  font-weight: 700;
  font-size: 0.875rem;
  border: 1px solid var(--line-2);
  transition: border-color .15s, color .15s;
}
.btn-outline:hover {
  border-color: var(--brand);
  color: var(--brand);
}

/* ── Badges ── */
.badge {
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
  padding: 0.2rem 0.6rem;
  border-radius: var(--r-xs);
  font-size: 0.6875rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  background: var(--brand-tint);
  color: var(--brand-deep);
  border: 1px solid var(--brand-line);
}
.badge-muted {
  background: var(--surface-3);
  color: var(--muted);
  border-color: var(--line);
}

/* ── Force white text on colored buttons ── */
a[class*="bg-[#1d4ed8]"],
a[class*="bg-[#1e3a8a]"],
a[class*="bg-[#172554]"],
button[class*="bg-[#1d4ed8]"] {
  color: #ffffff !important;
}
a[class*="bg-[#1d4ed8]"] svg,
a[class*="bg-[#1e3a8a]"] svg,
button[class*="bg-[#1d4ed8]"] svg {
  color: #ffffff !important;
  stroke: #ffffff !important;
}

/* ── Section rhythm ── */
.section { padding: 3.5rem 0; }
@media (min-width: 768px) { .section { padding: 5rem 0; } }

.section-inner {
  max-width: 1320px;
  margin: 0 auto;
  padding: 0 1rem;
}
@media (min-width: 640px) { .section-inner { padding: 0 1.5rem; } }
@media (min-width: 1024px) { .section-inner { padding: 0 2.5rem; } }

/* ── Focus rings ── */
input:focus-visible, button:focus-visible, a:focus-visible, [tabindex]:focus-visible {
  outline: 2px solid var(--brand);
  outline-offset: 2px;
}

/* ── Prose ── */
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

/* ── Animations ── */
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(8px); }
  to   { opacity: 1; transform: translateY(0); }
}
@keyframes fadeIn {
  from { opacity: 0; }
  to   { opacity: 1; }
}
.animate-in { animation: fadeUp .45s cubic-bezier(.16, 1, .3, 1) both; }
.animate-fade { animation: fadeIn .3s ease both; }

/* Respect reduced motion */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: .01ms !important;
    transition-duration: .01ms !important;
  }
}

/* ── Search page styles (scoped by body class) ── */
.search-page .chip {
  display: inline-flex;
  align-items: center;
  gap: .4rem;
  padding: .45rem .85rem;
  border-radius: 999px;
  border: 1px solid var(--line);
  background: var(--surface);
  color: var(--body);
  font-size: .8125rem;
  font-weight: 600;
  cursor: pointer;
  transition: border-color .15s, background-color .15s, color .15s;
}
.search-page .chip:hover { border-color: var(--brand); color: var(--brand); }
.search-page .chip[data-active="true"] {
  background: var(--brand);
  border-color: var(--brand);
  color: #ffffff !important;
}
.search-page .chip[data-active="true"] .chip-count {
  background: rgba(255,255,255,.25);
  color: #ffffff;
}
.search-page .chip-count {
  display: inline-block;
  padding: 0 .4rem;
  border-radius: 999px;
  background: var(--surface-3);
  color: var(--muted);
  font-size: .6875rem;
  font-weight: 700;
  min-width: 1.5rem;
  text-align: center;
}

.search-page .result {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem 1.25rem;
  background: var(--surface);
  border: 1px solid var(--line);
  border-radius: var(--r-lg);
  transition: border-color .15s, background-color .15s;
  animation: fadeUp .35s cubic-bezier(.16,1,.3,1) both;
}
.search-page .result:hover {
  border-color: var(--brand);
  background: var(--brand-tint);
}
.search-page .result.selected {
  border-color: var(--brand);
  background: var(--brand-tint);
}

.search-page .type-tag {
  display: inline-flex;
  align-items: center;
  gap: .3rem;
  padding: .25rem .6rem;
  border-radius: var(--r-xs);
  font-size: .625rem;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: .05em;
  background: var(--surface-3);
  color: var(--muted);
  flex-shrink: 0;
  border: 1px solid var(--line);
}
.search-page .type-note     { background: #eff4ff; color: #1e3a8a; border-color: #c7d7fe; }
.search-page .type-quiz     { background: #f0f9ff; color: #0369a1; border-color: #bae6fd; }
.search-page .type-book     { background: #fffbeb; color: #b45309; border-color: #fde68a; }
.search-page .type-paper    { background: #f5f3ff; color: #6d28d9; border-color: #ddd6fe; }
.search-page .type-guess    { background: #fdf4ff; color: #a21caf; border-color: #f5d0fe; }
.search-page .type-scheme   { background: #ecfdf5; color: #047857; border-color: #a7f3d0; }
.search-page .type-gazette  { background: #fff1f2; color: #be123c; border-color: #fecdd3; }

.search-page mark {
  background: var(--brand-tint);
  color: var(--brand-deep);
  padding: 0 .15em;
  border-radius: .25em;
  font-weight: 700;
}

.search-page .empty {
  padding: 3.5rem 1.5rem;
  text-align: center;
  border: 1px dashed var(--line-2);
  border-radius: var(--r-lg);
  background: var(--surface);
}
CSS

echo "  global.css — flat design system, zero shadows"

# ───────────────────────────────────────────────
#  2. Strip any leftover shadow classes from astro files
# ───────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re

pattern = re.compile(r'\b(shadow-sm|shadow-md|shadow-lg|shadow-xl|shadow-2xl|shadow-inner|shadow-none)\b')

count = 0
for astro in pathlib.Path('src').rglob('*.astro'):
    s = astro.read_text()
    orig = s
    # Remove shadow classes from class strings
    s = pattern.sub('', s)
    s = re.sub(r'\s+', ' ', s) if s != orig else s
    # Also remove common transition shadow references
    s = s.replace(' hover:shadow-md', '').replace(' hover:shadow-lg', '').replace(' hover:shadow-sm', '')
    s = s.replace('transition-shadow', 'transition-colors')
    if s != orig:
        astro.write_text(s)
        count += 1
print(f'  {count} files — shadow classes stripped')
PY

# ───────────────────────────────────────────────
#  3. Home page — no shadows, tighter
# ───────────────────────────────────────────────
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
  <!-- HERO -->
  <section class="border-b border-slate-200">
    <div class="mx-auto max-w-[1320px] px-4 pt-16 pb-14 sm:px-6 sm:pt-24 sm:pb-20 lg:px-10 lg:pt-28 lg:pb-24">
      <div class="max-w-3xl">
        <div class="inline-flex items-center gap-2 border border-slate-200 bg-white px-3 py-1 text-xs font-bold uppercase tracking-wider text-slate-600 rounded-full">
          <span class="h-1.5 w-1.5 rounded-full bg-[#1d4ed8]"></span>
          Free for every Pakistani student
        </div>
        <h1 class="mt-6 text-[2.75rem] font-extrabold leading-[1.02] tracking-[-0.04em] text-slate-900 sm:text-6xl lg:text-[4.25rem]">
          Study smarter,<br />
          <span class="text-[#1d4ed8]">score higher.</span>
        </h1>
        <p class="mt-6 max-w-xl text-base leading-relaxed text-slate-600 sm:text-lg">
          Notes, past papers, guess papers, pairing schemes and result gazettes — organised for your board and class from 9 to 12.
        </p>

        <form action={url('/search')} method="get" role="search" class="mt-9 flex max-w-xl items-center gap-2 rounded-xl border border-slate-300 bg-white p-1.5 pl-4 transition-colors focus-within:border-[#1d4ed8]">
          <Icon name="search" size={18} strokeWidth={2.4} class="shrink-0 text-slate-400" />
          <input type="search" name="q" placeholder="Search notes, past papers, books..." class="min-w-0 flex-1 bg-transparent py-3 text-sm text-slate-900 outline-none placeholder:text-slate-400" />
          <button type="submit" class="btn-primary">Search</button>
        </form>

        <div class="mt-6 flex flex-wrap items-center gap-x-5 gap-y-2 text-sm font-medium text-slate-500">
          <span class="flex items-center gap-1.5"><Icon name="zap" size={14} strokeWidth={2.4} class="text-[#1d4ed8]" /> Instant access</span>
          <span class="h-1 w-1 rounded-full bg-slate-300"></span>
          <span class="flex items-center gap-1.5"><Icon name="download" size={14} strokeWidth={2.4} class="text-[#1d4ed8]" /> Free PDFs</span>
          <span class="h-1 w-1 rounded-full bg-slate-300"></span>
          <span class="flex items-center gap-1.5"><Icon name="check" size={14} strokeWidth={2.6} class="text-[#1d4ed8]" /> All boards</span>
        </div>
      </div>
    </div>
  </section>

  <!-- CHOOSE YOUR BOARD -->
  <section class="section">
    <div class="section-inner">
      <div class="mb-8 flex items-end justify-between gap-4">
        <div>
          <h2 class="text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Choose your board</h2>
          <p class="mt-2 text-sm text-slate-500">Every resource is organised for your specific board.</p>
        </div>
        <a href={url('/boards')} class="hidden items-center gap-1 text-sm font-bold text-[#1d4ed8] hover:text-[#1e3a8a] sm:inline-flex">
          All boards <Icon name="arrow-right" size={14} strokeWidth={2.6} />
        </a>
      </div>

      <div class="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
        {BOARDS.map(b => (
          <a href={url(`/board/${b.slug}`)} class="card-link group">
            <span class="icon-tile">
              <Icon name="graduation-cap" size={22} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <div class="text-base font-extrabold tracking-tight text-slate-900">{b.name}</div>
              <div class="text-sm text-slate-500">{counts[b.slug] || 0} {counts[b.slug] === 1 ? 'resource' : 'resources'}</div>
            </div>
            <Icon name="arrow-right" size={18} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
          </a>
        ))}
      </div>
    </div>
  </section>

  <!-- BROWSE BY RESOURCE -->
  <section class="border-y border-slate-200 bg-white">
    <div class="section-inner">
      <div class="mb-8">
        <h2 class="text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Browse by resource</h2>
        <p class="mt-2 text-sm text-slate-500">Seven content types, all free, all board-specific.</p>
      </div>

      <div class="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
        {resources.map(r => (
          <a href={url(r.href)} class="card group flex flex-col p-5">
            <span class="icon-tile">
              <Icon name={r.icon} size={20} strokeWidth={2.2} />
            </span>
            <div class="mt-4 text-sm font-extrabold tracking-tight text-slate-900">{r.label}</div>
            <div class="mt-1 text-xs leading-snug text-slate-500">{r.desc}</div>
          </a>
        ))}
      </div>
    </div>
  </section>

  <!-- TRUST STRIP -->
  <section class="section">
    <div class="section-inner">
      <div class="grid grid-cols-2 gap-6 rounded-2xl border border-slate-200 bg-white p-8 sm:grid-cols-4 sm:p-10">
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

echo "  index.astro — shadow-free"

# ───────────────────────────────────────────────
#  4. Search page — full rebuild
# ───────────────────────────────────────────────
cat > src/pages/search.astro <<'ASTRO'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
---
<BaseLayout title="Search — TaleemHub" description="Search notes, past papers, guess papers, quizzes, books and result gazettes across all Pakistani boards.">
  <body class="search-page"></body>
  <div class="mx-auto max-w-5xl px-4 pt-10 sm:px-6 sm:pt-14 lg:px-8">
    <!-- HEADER -->
    <div class="mb-8 max-w-2xl">
      <div class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-[#1d4ed8]">
        <span class="h-1.5 w-1.5 rounded-full bg-[#1d4ed8]"></span>
        Search
      </div>
      <h1 class="mt-4 text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">
        Find anything in the library
      </h1>
      <p class="mt-3 text-base text-slate-500">
        Notes, past papers, guess papers, quizzes, books and gazettes — all in one place.
      </p>
    </div>

    <!-- SEARCH BAR -->
    <div class="relative">
      <div class="flex items-center gap-3 rounded-2xl border border-slate-300 bg-white px-4 py-2 transition-colors focus-within:border-[#1d4ed8]">
        <Icon name="search" size={20} strokeWidth={2.4} class="shrink-0 text-slate-400" />
        <input
          id="q"
          type="search"
          placeholder="Search by subject, class, board or keyword…"
          aria-label="Search library"
          autocomplete="off"
          autocapitalize="off"
          spellcheck="false"
          class="min-w-0 flex-1 bg-transparent py-3 text-base text-slate-900 outline-none placeholder:text-slate-400"
        />
        <kbd class="hidden rounded-md border border-slate-200 bg-slate-50 px-2 py-1 font-mono text-[11px] font-semibold text-slate-500 sm:inline-block">/</kbd>
        <button
          id="clear"
          type="button"
          aria-label="Clear search"
          class="hidden h-8 w-8 items-center justify-center rounded-lg text-slate-400 transition-colors hover:bg-slate-100 hover:text-slate-700"
        >
          <Icon name="x" size={16} strokeWidth={2.4} />
        </button>
      </div>

      <!-- FILTER CHIPS -->
      <div id="chips" class="mt-5 flex flex-wrap gap-2">
        <!-- populated by JS -->
      </div>

      <!-- STATUS -->
      <div id="status" class="mt-5 text-sm font-semibold text-slate-500">
        Loading library…
      </div>
    </div>

    <!-- RESULTS -->
    <div id="results" class="mt-6 space-y-2.5 pb-20"></div>
  </div>

  <script is:inline>
    (function () {
      var INDEX = [];
      var READY = false;
      var ACTIVE_TYPE = 'all';

      var input     = document.getElementById('q');
      var clearBtn  = document.getElementById('clear');
      var chipsEl   = document.getElementById('chips');
      var statusEl  = document.getElementById('status');
      var resultsEl = document.getElementById('results');

      var TYPE_ORDER = ['all','note','quiz','book','past-paper','guess-paper','pairing-scheme','gazette'];
      var TYPE_LABELS = {
        all: 'All',
        note: 'Notes',
        quiz: 'Quizzes',
        book: 'Books',
        'past-paper': 'Past Papers',
        'guess-paper': 'Guess Papers',
        'pairing-scheme': 'Pairing Schemes',
        gazette: 'Result Gazettes'
      };
      var TYPE_CSS = {
        note: 'type-note',
        quiz: 'type-quiz',
        book: 'type-book',
        'past-paper': 'type-paper',
        'guess-paper': 'type-guess',
        'pairing-scheme': 'type-scheme',
        gazette: 'type-gazette'
      };
      var TYPE_SHORT = {
        note: 'Note',
        quiz: 'Quiz',
        book: 'Book',
        'past-paper': 'Past Paper',
        'guess-paper': 'Guess Paper',
        'pairing-scheme': 'Pairing Scheme',
        gazette: 'Gazette'
      };

      // Load index
      function loadIndex() {
        var url = (window.__BASE__ || '') + '/search.json';
        return fetch(url)
          .then(function (r) { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
          .then(function (data) {
            INDEX = (data || []).map(function (x) {
              // Normalize type: convert camelCase → kebab-case to match chips
              var t = (x.type || 'note').toLowerCase();
              if (t === 'pastpapers' || t === 'past-paper' || t === 'pastpapers') t = 'past-paper';
              if (t === 'guesspapers' || t === 'guess-papers' || t === 'guesspapers') t = 'guess-paper';
              if (t === 'pairingschemes' || t === 'pairing-schemes') t = 'pairing-scheme';
              return Object.assign({}, x, { type: t });
            });
            READY = true;
          });
      }

      function esc(s) {
        return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
          return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
        });
      }

      function highlight(text, terms) {
        if (!terms.length || !text) return esc(text);
        var safe = esc(text);
        terms.forEach(function (t) {
          if (!t) return;
          var re = new RegExp('(' + t.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + ')', 'gi');
          safe = safe.replace(re, '<mark>$1</mark>');
        });
        return safe;
      }

      function countByType() {
        var counts = { all: INDEX.length };
        INDEX.forEach(function (it) {
          counts[it.type] = (counts[it.type] || 0) + 1;
        });
        return counts;
      }

      function renderChips() {
        var counts = countByType();
        var html = TYPE_ORDER.map(function (t) {
          var n = counts[t] || 0;
          if (t !== 'all' && n === 0) return '';
          return '<button type="button" class="chip" data-type="' + t + '" data-active="' + (t === ACTIVE_TYPE) + '">' +
            esc(TYPE_LABELS[t]) +
            (n ? ' <span class="chip-count">' + n + '</span>' : '') +
          '</button>';
        }).join('');
        chipsEl.innerHTML = html;
        Array.prototype.forEach.call(chipsEl.querySelectorAll('.chip'), function (btn) {
          btn.addEventListener('click', function () {
            ACTIVE_TYPE = btn.getAttribute('data-type');
            render();
          });
        });
      }

      function filterAndScore(query) {
        var q = query.trim().toLowerCase();
        var terms = q ? q.split(/\s+/).filter(Boolean) : [];
        var pool = ACTIVE_TYPE === 'all'
          ? INDEX
          : INDEX.filter(function (it) { return it.type === ACTIVE_TYPE; });

        if (!terms.length) return pool.slice(0, 60);

        var scored = [];
        pool.forEach(function (it) {
          var t = (it.title   || '').toLowerCase();
          var s = (it.subject || '').toLowerCase();
          var c = String(it.class || '').toLowerCase();
          var ty = (it.type   || '').toLowerCase();
          var score = 0;
          var allMatch = true;
          terms.forEach(function (term) {
            var m = 0;
            if (t.indexOf(term) === 0) m += 20;
            else if (t.indexOf(term) !== -1) m += 12;
            if (s.indexOf(term) !== -1) m += 6;
            if (c === term) m += 8;
            else if (c.indexOf(term) !== -1) m += 4;
            if (ty.indexOf(term) !== -1) m += 3;
            if (!m) { allMatch = false; }
            score += m;
          });
          if (allMatch) scored.push({ score: score, item: it });
        });
        scored.sort(function (a, b) { return b.score - a.score; });
        return scored.map(function (x) { return x.item; }).slice(0, 60);
      }

      var lastSelected = -1;
      var lastResults = [];

      function render() {
        var query = input.value;

        // Clear button visibility
        if (query) {
          clearBtn.classList.remove('hidden');
          clearBtn.classList.add('grid');
        } else {
          clearBtn.classList.add('hidden');
          clearBtn.classList.remove('grid');
        }

        if (!READY) {
          statusEl.textContent = 'Loading library…';
          resultsEl.innerHTML = '';
          return;
        }

        var list = filterAndScore(query);
        lastResults = list;
        lastSelected = -1;

        var label = ACTIVE_TYPE === 'all'
          ? (query ? (list.length + ' result' + (list.length === 1 ? '' : 's') + ' for "' + query + '"') : (INDEX.length + ' items in library'))
          : (list.length + ' ' + TYPE_LABELS[ACTIVE_TYPE].toLowerCase() + (query ? ' matching "' + query + '"' : ''));
        statusEl.textContent = label;

        if (!list.length) {
          resultsEl.innerHTML =
            '<div class="empty">' +
              '<div class="text-base font-bold text-slate-900">No results found</div>' +
              '<div class="mt-2 text-sm text-slate-500">Try a shorter keyword, check the spelling, or browse by board and class.</div>' +
              '<div class="mt-5 flex flex-wrap justify-center gap-2">' +
                '<a href="' + (window.__BASE__ || '') + '/boards" class="btn-outline text-xs">Browse boards</a>' +
                '<a href="' + (window.__BASE__ || '') + '/notes" class="btn-outline text-xs">All notes</a>' +
                '<a href="' + (window.__BASE__ || '') + '/past-papers" class="btn-outline text-xs">Past papers</a>' +
              '</div>' +
            '</div>';
          return;
        }

        var terms = query.trim().toLowerCase().split(/\s+/).filter(Boolean);
        resultsEl.innerHTML = list.map(function (it, i) {
          var typeTag = TYPE_SHORT[it.type] || it.type;
          var typeCls = TYPE_CSS[it.type] || '';
          var badges = [];
          if (it.subject) badges.push('<span class="badge badge-muted">' + esc(it.subject) + '</span>');
          if (it.class) badges.push('<span class="badge">Class ' + esc(it.class) + '</span>');
          return '<a href="' + esc(it.url) + '" class="result" data-index="' + i + '" style="animation-delay:' + Math.min(i * 15, 220) + 'ms">' +
            '<span class="type-tag ' + typeCls + '">' + esc(typeTag) + '</span>' +
            '<div class="min-w-0 flex-1">' +
              '<h3 class="truncate text-sm font-bold tracking-tight text-slate-900">' + highlight(it.title, terms) + '</h3>' +
              (badges.length ? '<div class="mt-1.5 flex flex-wrap gap-1.5">' + badges.join('') + '</div>' : '') +
            '</div>' +
            '<svg class="shrink-0 text-slate-300" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>' +
          '</a>';
        }).join('');
      }

      function moveSelection(dir) {
        if (!lastResults.length) return;
        lastSelected = Math.max(0, Math.min(lastResults.length - 1, lastSelected + dir));
        var nodes = resultsEl.querySelectorAll('.result');
        Array.prototype.forEach.call(nodes, function (n, i) {
          n.classList.toggle('selected', i === lastSelected);
        });
        var sel = nodes[lastSelected];
        if (sel) sel.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
      }

      // Keyboard
      input.addEventListener('keydown', function (e) {
        if (e.key === 'ArrowDown') { e.preventDefault(); moveSelection(1); }
        else if (e.key === 'ArrowUp') { e.preventDefault(); moveSelection(-1); }
        else if (e.key === 'Enter' && lastSelected >= 0 && lastResults[lastSelected]) {
          window.location.href = lastResults[lastSelected].url;
        } else if (e.key === 'Escape') {
          if (input.value) { input.value = ''; render(); }
        }
      });

      // Shortcut
      document.addEventListener('keydown', function (e) {
        if (e.key === '/' && document.activeElement !== input && !/INPUT|TEXTAREA/.test(document.activeElement.tagName)) {
          e.preventDefault(); input.focus(); input.select();
        }
      });

      clearBtn.addEventListener('click', function () {
        input.value = ''; input.focus(); render();
      });

      var t;
      input.addEventListener('input', function () {
        clearTimeout(t);
        t = setTimeout(render, 60);
      });

      // URL param
      var params = new URLSearchParams(window.location.search);
      var initial = params.get('q') || '';
      if (initial) input.value = initial;

      // Load then render
      loadIndex().then(function () {
        renderChips();
        render();
      }).catch(function (err) {
        console.error('Search index failed:', err);
        statusEl.textContent = 'Could not load library.';
        resultsEl.innerHTML = '<div class="empty"><div class="text-base font-bold text-slate-900">Search unavailable</div><div class="mt-2 text-sm text-slate-500">Please refresh the page.</div></div>';
      });
    })();
  </script>

  <script is:inline>
    window.__BASE__ = (function () {
      var base = document.querySelector('link[rel="sitemap"]');
      if (base) {
        var href = base.getAttribute('href') || '';
        var idx = href.indexOf('/sitemap-index.xml');
        if (idx > 0) return href.slice(0, idx);
      }
      var path = window.location.pathname;
      var parts = path.split('/').filter(Boolean);
      return parts.length ? '/' + parts[0] : '';
    })();
  </script>
</BaseLayout>
ASTRO

echo "  search.astro — full rebuild with chips, keyboard nav, highlighting"

# ───────────────────────────────────────────────
#  5. Rebuild
# ───────────────────────────────────────────────
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -10

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Push:"
echo ""
echo "    git add ."
echo "    git commit -m 'Flat design + search overhaul'"
echo "    git push"
echo ""
echo "  Then clear browser cache and check:"
echo "    /                  — flat home, no shadows"
echo "    /search            — new search UI with chips"
echo "    /search?q=physics  — pre-filled search"
echo ""
echo "  Search features:"
echo "    · Filter chips with live counts"
echo "    · Instant results (60ms debounce)"
echo "    · Highlighted matches in titles"
echo "    · Arrow keys to navigate, Enter to open"
echo "    · '/' keyboard shortcut to focus"
echo "    · Colour-coded type tags per resource"
echo "    · Empty state with suggestions"
echo "════════════════════════════════════════════"