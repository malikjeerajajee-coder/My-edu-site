#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  BACKUP FIRST — creating restore point"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  STEP 1: Create backup branch on GitHub
# ─────────────────────────────────────────────
CURRENT=$(git rev-parse --abbrev-ref HEAD)
echo "▸ Current branch: $CURRENT"

git branch -f backup-pre-redesign
git push -u origin backup-pre-redesign 2>&1 | tail -3 || {
  echo ""
  echo "  ⚠ Could not push backup branch automatically."
  echo "  Run this manually after the script:"
  echo "    git push -u origin backup-pre-redesign"
  echo ""
}
echo "▸ Backup branch 'backup-pre-redesign' created"
echo ""

# ─────────────────────────────────────────────
#  STEP 2: Write a restore script for easy revert
# ─────────────────────────────────────────────
cat > restore.sh <<'RESTORE'
#!/bin/bash
# Restore the site to its pre-redesign state
set -e
echo "Restoring from backup-pre-redesign..."
git fetch origin backup-pre-redesign
git checkout backup-pre-redesign
git branch -D main || true
git checkout -b main
git push -f origin main
echo ""
echo "✓ Restored. Site will redeploy in ~90 seconds."
RESTORE
chmod +x restore.sh
echo "▸ restore.sh written — run it anytime to revert"
echo ""

# ─────────────────────────────────────────────
#  STEP 3: Global CSS — design system
# ─────────────────────────────────────────────
cat > src/styles/global.css <<'CSS'
@import "tailwindcss";

@theme {
  --font-sans: "Plus Jakarta Sans", ui-sans-serif, system-ui, -apple-system, sans-serif;
}

:root {
  /* ── Primary ── */
  --brand: #1d4ed8;
  --brand-deep: #1e3a8a;
  --brand-tint: #eff4ff;
  --brand-line: #c7d7fe;

  /* ── Neutrals ── */
  --ink: #0b1220;
  --body: #334155;
  --muted: #64748b;
  --subtle: #94a3b8;

  --surface: #ffffff;
  --surface-2: #f8fafc;
  --bg: #ffffff;

  --line: #e5e9f0;
  --line-2: #cbd5e1;

  /* ── Resource accents (7 colors) ── */
  --c-notes: #1d4ed8;      --c-notes-tint: #eff4ff;      --c-notes-line: #c7d7fe;      --c-notes-deep: #1e3a8a;
  --c-papers: #7c3aed;     --c-papers-tint: #f5f3ff;     --c-papers-line: #ddd6fe;     --c-papers-deep: #5b21b6;
  --c-guess: #c026d3;      --c-guess-tint: #fdf4ff;      --c-guess-line: #f5d0fe;      --c-guess-deep: #86198f;
  --c-pairing: #059669;    --c-pairing-tint: #ecfdf5;    --c-pairing-line: #a7f3d0;    --c-pairing-deep: #065f46;
  --c-quizzes: #0284c7;    --c-quizzes-tint: #f0f9ff;    --c-quizzes-line: #bae6fd;    --c-quizzes-deep: #075985;
  --c-books: #d97706;      --c-books-tint: #fffbeb;      --c-books-line: #fde68a;      --c-books-deep: #92400e;
  --c-gazettes: #e11d48;   --c-gazettes-tint: #fff1f2;   --c-gazettes-line: #fecdd3;   --c-gazettes-deep: #9f1239;
}

html {
  -webkit-text-size-adjust: 100%;
  scroll-behavior: smooth;
  -webkit-tap-highlight-color: transparent;
}

body {
  font-family: var(--font-sans);
  background: var(--bg);
  color: var(--body);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  overflow-x: hidden;
  font-feature-settings: "ss01", "cv11";
  font-size: 16px;
}

* { -webkit-tap-highlight-color: transparent; }
a { color: inherit; text-decoration: none; }
button { font-family: inherit; cursor: pointer; }
input, select, textarea { font-family: inherit; }

h1, h2, h3, h4 {
  color: var(--ink);
  letter-spacing: -0.035em;
  font-weight: 800;
  line-height: 1.1;
}

/* ── Zero shadows ── */
*, *::before, *::after { box-shadow: none !important; }

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

/* ═══ Pill badge (hero eyebrow) ═══ */
.pill {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.4rem 0.85rem;
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

/* ═══ Row card — horizontal list item ═══ */
.row {
  display: flex;
  align-items: center;
  gap: 0.875rem;
  padding: 0.875rem 1rem;
  background: var(--surface);
  border: 1px solid var(--line);
  border-radius: 14px;
  transition: border-color .15s ease;
  min-width: 0;
}
@media (hover: hover) {
  .row:hover { border-color: var(--brand); }
}

.row > * { min-width: 0; }
.row .row-title {
  font-size: 0.9375rem;
  font-weight: 800;
  letter-spacing: -0.02em;
  color: var(--ink);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  line-height: 1.25;
}
.row .row-sub {
  font-size: 0.75rem;
  color: var(--muted);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* ═══ Tile — icon container inside row cards ═══ */
.tile {
  display: grid;
  place-items: center;
  width: 2.75rem;
  height: 2.75rem;
  border-radius: 11px;
  background: var(--brand-tint);
  color: var(--brand);
  flex-shrink: 0;
  transition: background-color .15s ease, color .15s ease;
}
@media (hover: hover) {
  .row:hover .tile {
    background: var(--brand);
    color: #ffffff;
  }
}

/* ═══ Resource tile — compact grid card ═══ */
.rtile {
  display: flex;
  align-items: center;
  gap: 0.875rem;
  padding: 1rem;
  background: var(--surface);
  border: 1px solid var(--line);
  border-radius: 14px;
  min-height: 4.5rem;
  transition: border-color .15s ease, background-color .15s ease;
  min-width: 0;
}
@media (hover: hover) {
  .rtile:hover { border-color: var(--tile-color, var(--brand)); }
}

.rtile-icon {
  display: grid;
  place-items: center;
  width: 2.75rem;
  height: 2.75rem;
  border-radius: 11px;
  background: var(--tile-tint, var(--brand-tint));
  color: var(--tile-color, var(--brand));
  flex-shrink: 0;
  transition: background-color .15s ease, color .15s ease;
}
@media (hover: hover) {
  .rtile:hover .rtile-icon {
    background: var(--tile-color, var(--brand));
    color: #ffffff;
  }
}

.rtile-label {
  font-size: 0.9375rem;
  font-weight: 800;
  letter-spacing: -0.02em;
  color: var(--ink);
  line-height: 1.2;
}

/* ═══ Buttons ═══ */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.75rem 1.25rem;
  border-radius: 10px;
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
  background: var(--brand-deep);
  border-color: var(--brand-deep);
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

/* Force white text on colored buttons */
a[class*="bg-[#1d4ed8]"],
button[class*="bg-[#1d4ed8]"] { color: #ffffff !important; }
a[class*="bg-[#1d4ed8]"] svg,
button[class*="bg-[#1d4ed8]"] svg { color: #ffffff !important; stroke: #ffffff !important; }

/* ═══ Numbered step ═══ */
.step-num {
  display: inline-grid;
  place-items: center;
  width: 2.25rem;
  height: 2.25rem;
  border-radius: 50%;
  background: var(--brand);
  color: #ffffff;
  font-weight: 800;
  font-size: 0.875rem;
  flex-shrink: 0;
}

/* ═══ Focus ═══ */
button:focus-visible, a:focus-visible {
  outline: 2px solid var(--brand);
  outline-offset: 2px;
}
input, input:focus, input:focus-visible { outline: none; box-shadow: none; }

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
.prose code { background: var(--brand-tint); color: var(--brand-deep); padding: 0.125rem 0.375rem; border-radius: 6px; font-size: 0.85em; font-weight: 600; }
.prose strong { font-weight: 700; color: var(--ink); }
.prose table { width: 100%; border-collapse: collapse; margin: 1rem 0; font-size: 0.875rem; border: 1px solid var(--line); border-radius: 10px; overflow: hidden; }
.prose th { background: var(--surface-2); text-align: left; padding: 0.625rem 0.75rem; font-weight: 700; color: var(--ink); border-bottom: 1px solid var(--line); }
.prose td { padding: 0.625rem 0.75rem; border-top: 1px solid var(--line); }
.prose a { color: var(--brand); text-decoration: underline; text-underline-offset: 2px; }

/* ═══ Animations ═══ */
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(6px); }
  to   { opacity: 1; transform: translateY(0); }
}
.animate-in { animation: fadeUp .4s cubic-bezier(.16, 1, .3, 1) both; }

@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: .01ms !important;
    transition-duration: .01ms !important;
  }
}

/* ═══ Touch safety ═══ */
@media (hover: none) {
  .row:hover, .rtile:hover { border-color: var(--line) !important; background: inherit !important; }
  .row:hover .tile { background: var(--brand-tint) !important; color: var(--brand) !important; }
  .rtile:hover .rtile-icon { background: var(--tile-tint, var(--brand-tint)) !important; color: var(--tile-color, var(--brand)) !important; }
}
CSS

echo "▸ global.css — full design system written"

# ─────────────────────────────────────────────
#  STEP 4: BaseLayout — refined sidebar shell
# ─────────────────────────────────────────────
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

const navBrowse = [
  { href: '/',       label: 'Home',    icon: 'home' },
  { href: '/boards', label: 'Boards',  icon: 'graduation-cap' },
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
      <span class="grid h-8 w-8 place-items-center rounded-lg bg-[#1d4ed8] text-white">
        <Icon name="graduation-cap" size={17} strokeWidth={2.4} />
      </span>
      <span class="text-[15px] font-extrabold tracking-tight text-slate-900">TaleemHub</span>
    </a>

    <nav class="flex-1 overflow-y-auto px-3 py-5">
      <div class="mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-slate-400">Browse</div>
      <ul class="space-y-0.5">
        {navBrowse.map(item => (
          <li>
            <a href={url(item.href)} class:list={[
              "flex items-center gap-3 rounded-lg px-3 py-2 text-[13.5px] font-bold transition-colors",
              isActive(item.href) ? "bg-[#eff4ff] text-[#1d4ed8]" : "text-slate-600 hover:bg-slate-100 hover:text-slate-900",
            ]}>
              <Icon name={item.icon} size={17} strokeWidth={2.2} class="shrink-0" />
              <span>{item.label}</span>
            </a>
          </li>
        ))}
      </ul>

      <div class="mt-6 mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-slate-400">Study Material</div>
      <ul class="space-y-0.5">
        {navStudy.map(item => (
          <li>
            <a href={url(item.href)} class:list={[
              "flex items-center gap-3 rounded-lg px-3 py-2 text-[13.5px] font-bold transition-colors",
              isActive(item.href) ? "bg-[#eff4ff] text-[#1d4ed8]" : "text-slate-600 hover:bg-slate-100 hover:text-slate-900",
            ]}>
              <Icon name={item.icon} size={17} strokeWidth={2.2} class="shrink-0" />
              <span>{item.label}</span>
            </a>
          </li>
        ))}
      </ul>

      <div class="mt-6 mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-slate-400">Exams</div>
      <ul class="space-y-0.5">
        {navExam.map(item => (
          <li>
            <a href={url(item.href)} class:list={[
              "flex items-center gap-3 rounded-lg px-3 py-2 text-[13.5px] font-bold transition-colors",
              isActive(item.href) ? "bg-[#eff4ff] text-[#1d4ed8]" : "text-slate-600 hover:bg-slate-100 hover:text-slate-900",
            ]}>
              <Icon name={item.icon} size={17} strokeWidth={2.2} class="shrink-0" />
              <span>{item.label}</span>
            </a>
          </li>
        ))}
      </ul>
    </nav>

    <div class="border-t border-slate-200 p-3">
      <form action={url('/search')} method="get" role="search" class="flex items-center gap-2 rounded-lg border border-slate-200 bg-slate-50 px-3 py-2 transition-colors focus-within:border-[#1d4ed8] focus-within:bg-white">
        <Icon name="search" size={14} strokeWidth={2.3} class="shrink-0 text-slate-400" />
        <input type="search" name="q" placeholder="Search library" class="min-w-0 flex-1 bg-transparent text-[13px] font-semibold text-slate-900 outline-none placeholder:text-slate-400" />
      </form>
    </div>
  </aside>

  <!-- ═══ MOBILE TOP BAR ═══ -->
  <header class="sticky top-0 z-30 flex h-14 w-full items-center gap-3 border-b border-slate-200 bg-white/95 px-4 backdrop-blur-lg lg:hidden">
    <button id="open-drawer" type="button" aria-label="Open menu" class="grid h-9 w-9 place-items-center rounded-lg text-slate-700 active:bg-slate-100">
      <Icon name="menu" size={20} strokeWidth={2.4} />
    </button>
    <a href={url('/')} class="flex items-center gap-2">
      <span class="grid h-7 w-7 place-items-center rounded-md bg-[#1d4ed8] text-white">
        <Icon name="graduation-cap" size={15} strokeWidth={2.4} />
      </span>
      <span class="text-[15px] font-extrabold tracking-tight text-slate-900">TaleemHub</span>
    </a>
    <a href={url('/search')} class="ml-auto grid h-9 w-9 place-items-center rounded-lg text-slate-700 active:bg-slate-100" aria-label="Search">
      <Icon name="search" size={19} strokeWidth={2.4} />
    </a>
  </header>

  <!-- ═══ MOBILE DRAWER ═══ -->
  <div id="drawer" class="fixed inset-0 z-50 hidden lg:hidden">
    <div id="drawer-backdrop" class="absolute inset-0 bg-slate-900/40 opacity-0 transition-opacity duration-300"></div>
    <aside id="drawer-panel" class="absolute inset-y-0 left-0 flex w-[270px] -translate-x-full flex-col border-r border-slate-200 bg-white transition-transform duration-300 ease-out">
      <div class="flex h-16 shrink-0 items-center justify-between border-b border-slate-200 px-4">
        <a href={url('/')} class="flex items-center gap-2.5">
          <span class="grid h-8 w-8 place-items-center rounded-lg bg-[#1d4ed8] text-white">
            <Icon name="graduation-cap" size={17} strokeWidth={2.4} />
          </span>
          <span class="text-[15px] font-extrabold tracking-tight text-slate-900">TaleemHub</span>
        </a>
        <button id="close-drawer" type="button" aria-label="Close" class="grid h-8 w-8 place-items-center rounded-lg text-slate-500 active:bg-slate-100">
          <Icon name="x" size={17} strokeWidth={2.4} />
        </button>
      </div>
      <nav class="flex-1 overflow-y-auto px-3 py-5">
        <div class="mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-slate-400">Browse</div>
        <ul class="space-y-0.5">
          {navBrowse.map(item => (
            <li><a href={url(item.href)} class:list={["flex items-center gap-3 rounded-lg px-3 py-2 text-[13.5px] font-bold transition-colors", isActive(item.href) ? "bg-[#eff4ff] text-[#1d4ed8]" : "text-slate-600 hover:bg-slate-100"]}><Icon name={item.icon} size={17} strokeWidth={2.2} /><span>{item.label}</span></a></li>
          ))}
        </ul>
        <div class="mt-6 mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-slate-400">Study Material</div>
        <ul class="space-y-0.5">
          {navStudy.map(item => (
            <li><a href={url(item.href)} class:list={["flex items-center gap-3 rounded-lg px-3 py-2 text-[13.5px] font-bold transition-colors", isActive(item.href) ? "bg-[#eff4ff] text-[#1d4ed8]" : "text-slate-600 hover:bg-slate-100"]}><Icon name={item.icon} size={17} strokeWidth={2.2} /><span>{item.label}</span></a></li>
          ))}
        </ul>
        <div class="mt-6 mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-slate-400">Exams</div>
        <ul class="space-y-0.5">
          {navExam.map(item => (
            <li><a href={url(item.href)} class:list={["flex items-center gap-3 rounded-lg px-3 py-2 text-[13.5px] font-bold transition-colors", isActive(item.href) ? "bg-[#eff4ff] text-[#1d4ed8]" : "text-slate-600 hover:bg-slate-100"]}><Icon name={item.icon} size={17} strokeWidth={2.2} /><span>{item.label}</span></a></li>
          ))}
        </ul>
      </nav>
      <div class="border-t border-slate-200 p-3">
        <form action={url('/search')} method="get" role="search" class="flex items-center gap-2 rounded-lg border border-slate-200 bg-slate-50 px-3 py-2">
          <Icon name="search" size={14} strokeWidth={2.3} class="shrink-0 text-slate-400" />
          <input type="search" name="q" placeholder="Search library" class="min-w-0 flex-1 bg-transparent text-[13px] font-semibold text-slate-900 outline-none placeholder:text-slate-400" />
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
              <span class="grid h-8 w-8 place-items-center rounded-lg bg-[#1d4ed8] text-white">
                <Icon name="graduation-cap" size={17} strokeWidth={2.4} />
              </span>
              <span class="text-[15px] font-extrabold tracking-tight text-slate-900">TaleemHub</span>
            </div>
            <p class="mt-4 max-w-sm text-sm leading-relaxed text-slate-500">
              Free notes, past papers, guess papers, and result gazettes for Pakistani students — organised by board and class.
            </p>
          </div>
          <div>
            <h4 class="text-[13px] font-extrabold text-slate-900">Study</h4>
            <ul class="mt-3.5 space-y-2 text-sm text-slate-500">
              <li><a href={url('/boards')} class="hover:text-[#1d4ed8]">Boards</a></li>
              <li><a href={url('/notes')} class="hover:text-[#1d4ed8]">Notes</a></li>
              <li><a href={url('/quizzes')} class="hover:text-[#1d4ed8]">Quizzes</a></li>
              <li><a href={url('/books')} class="hover:text-[#1d4ed8]">Books</a></li>
            </ul>
          </div>
          <div>
            <h4 class="text-[13px] font-extrabold text-slate-900">Exams</h4>
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

echo "▸ BaseLayout.astro — refined sidebar shell"

# ─────────────────────────────────────────────
#  STEP 5: Homepage — the centerpiece
# ─────────────────────────────────────────────
cat > src/pages/index.astro <<'ASTRO'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { url } from '../lib/url';
import { BOARDS } from '../lib/boards';

const resources = [
  { href: '/notes',           icon: 'file-text',      label: 'Notes',           color: 'notes' },
  { href: '/past-papers',     icon: 'scroll-text',    label: 'Past Papers',     color: 'papers' },
  { href: '/guess-papers',    icon: 'sparkles',       label: 'Guess Papers',    color: 'guess' },
  { href: '/pairing-schemes', icon: 'list',           label: 'Pairing Schemes', color: 'pairing' },
  { href: '/quizzes',         icon: 'circle-help',    label: 'Quizzes',         color: 'quizzes' },
  { href: '/books',           icon: 'book-marked',    label: 'Books',           color: 'books' },
  { href: '/gazettes',        icon: 'newspaper',      label: 'Result Gazettes', color: 'gazettes' },
  { href: '/boards',          icon: 'graduation-cap', label: 'All Boards',      color: 'brand' },
];

const faqs = [
  {
    q: 'Which boards are covered?',
    a: 'All six major Pakistani boards: Punjab (all 9 BISEs), Federal (FBISE), Khyber Pakhtunkhwa, Sindh, Balochistan, and Azad Jammu & Kashmir. Every resource is tailored to your specific board syllabus.'
  },
  {
    q: 'Is everything really free?',
    a: 'Yes. No sign-up, no ads, no paywalls. Every note, past paper, guess paper, pairing scheme and quiz is free to download and use — forever.'
  },
  {
    q: 'Which classes are supported?',
    a: 'Class 9, 10, 11 and 12 (Matric and Intermediate). Resources are organised by class first, so you only see content that applies to you.'
  },
  {
    q: 'How are past papers organised?',
    a: 'Each paper is tagged by board, class, subject and year. Browse by board to see only the papers relevant to your exam — from 2018 up to today.'
  },
  {
    q: 'Can I use this on my phone?',
    a: 'Yes. The site is designed mobile-first. Everything works on any phone, tablet or computer — no app required.'
  },
];
---
<BaseLayout title="TaleemHub — Exam-specific revision for Pakistani students">
  <!-- ═══ HERO ═══ -->
  <section class="border-b border-slate-200">
    <div class="mx-auto max-w-[1200px] px-5 pt-16 pb-12 sm:px-7 sm:pt-20 sm:pb-16 lg:px-10 lg:pt-24 lg:pb-20">
      <div class="mx-auto max-w-3xl text-center">
        <div class="pill mx-auto">
          <span class="pill-dot"></span>
          Trusted by students across Pakistan
        </div>
        <h1 class="mt-6 text-[2.25rem] font-extrabold leading-[1.05] tracking-[-0.04em] text-slate-900 sm:text-[3rem] lg:text-[3.5rem]">
          Exam-specific revision,<br />
          made by trusted educators
        </h1>
        <p class="mx-auto mt-6 max-w-xl text-base leading-relaxed text-slate-600">
          Real expertise. Real results. Every note, past paper and guess paper — organised for your exact board and class.
        </p>

        <form action={url('/search')} method="get" role="search" class="mx-auto mt-9 flex max-w-xl items-stretch overflow-hidden rounded-xl border border-slate-300 bg-white transition-colors focus-within:border-[#1d4ed8]">
          <span class="grid w-12 shrink-0 place-items-center text-slate-400">
            <Icon name="search" size={18} strokeWidth={2.4} />
          </span>
          <input type="search" name="q" placeholder="Search notes, past papers, books..." class="min-w-0 flex-1 bg-transparent py-3.5 pr-3 text-sm text-slate-900 outline-none placeholder:text-slate-400" />
          <button type="submit" class="m-1.5 rounded-lg bg-[#1d4ed8] px-5 text-sm font-bold text-white transition-colors hover:bg-[#1e3a8a]">Search</button>
        </form>

        <div class="mt-8 flex flex-wrap items-center justify-center gap-x-6 gap-y-3 text-sm text-slate-500">
          <span class="flex items-center gap-1.5">
            <Icon name="check" size={14} strokeWidth={3} class="text-[#1d4ed8]" /> 6 boards covered
          </span>
          <span class="flex items-center gap-1.5">
            <Icon name="check" size={14} strokeWidth={3} class="text-[#1d4ed8]" /> Class 9–12
          </span>
          <span class="flex items-center gap-1.5">
            <Icon name="check" size={14} strokeWidth={3} class="text-[#1d4ed8]" /> 100% free
          </span>
        </div>
      </div>
    </div>
  </section>

  <!-- ═══ CHOOSE YOUR BOARD ═══ -->
  <section class="section">
    <div class="section-inner">
      <div class="mb-8 flex flex-wrap items-end justify-between gap-4">
        <div>
          <h2 class="text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Choose your board</h2>
          <p class="mt-2 text-sm text-slate-500">Everything is organised for your specific board.</p>
        </div>
        <a href={url('/boards')} class="hidden items-center gap-1 text-sm font-bold text-[#1d4ed8] hover:text-[#1e3a8a] sm:inline-flex">
          All boards <Icon name="arrow-right" size={14} strokeWidth={2.6} />
        </a>
      </div>

      <div class="grid grid-cols-1 gap-2.5 sm:grid-cols-2 lg:grid-cols-3">
        {BOARDS.map(b => (
          <a href={url(`/board/${b.slug}`)} class="row group">
            <span class="tile">
              <Icon name="graduation-cap" size={19} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <div class="row-title">{b.name}</div>
            </div>
            <Icon name="arrow-right" size={15} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
          </a>
        ))}
      </div>
    </div>
  </section>

  <!-- ═══ BROWSE BY RESOURCE ═══ -->
  <section class="border-t border-slate-200 bg-slate-50 section">
    <div class="section-inner">
      <div class="mb-8">
        <h2 class="text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Browse by resource</h2>
        <p class="mt-2 text-sm text-slate-500">Seven content types — all free, all board-specific.</p>
      </div>

      <div class="grid grid-cols-2 gap-2.5 sm:grid-cols-3 lg:grid-cols-4">
        {resources.map(r => (
          <a href={url(r.href)} class="rtile group"
             style={`--tile-color: var(--c-${r.color}); --tile-tint: var(--c-${r.color}-tint);`}>
            <span class="rtile-icon">
              <Icon name={r.icon} size={19} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <div class="rtile-label">{r.label}</div>
            </div>
          </a>
        ))}
      </div>
    </div>
  </section>

  <!-- ═══ HOW IT WORKS ═══ -->
  <section class="section">
    <div class="section-inner">
      <div class="mx-auto max-w-2xl text-center">
        <h2 class="text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">How it works</h2>
        <p class="mt-3 text-base text-slate-600">Three steps to focused exam preparation.</p>
      </div>

      <div class="mx-auto mt-12 grid max-w-4xl grid-cols-1 gap-10 sm:grid-cols-3 sm:gap-8">
        <div class="flex flex-col items-start gap-4 sm:items-center sm:text-center">
          <span class="step-num">1</span>
          <h3 class="text-base font-extrabold tracking-tight text-slate-900">Pick your board</h3>
          <p class="text-sm leading-relaxed text-slate-600">
            Six boards, each with its own syllabus. You only see what's on your paper — nothing else.
          </p>
        </div>
        <div class="flex flex-col items-start gap-4 sm:items-center sm:text-center">
          <span class="step-num">2</span>
          <h3 class="text-base font-extrabold tracking-tight text-slate-900">Choose your class and subject</h3>
          <p class="text-sm leading-relaxed text-slate-600">
            Drill down to your exact class and subject. Notes, papers, quizzes and textbooks — all in one place.
          </p>
        </div>
        <div class="flex flex-col items-start gap-4 sm:items-center sm:text-center">
          <span class="step-num">3</span>
          <h3 class="text-base font-extrabold tracking-tight text-slate-900">Revise and test yourself</h3>
          <p class="text-sm leading-relaxed text-slate-600">
            Study from notes, practice with past papers, test yourself with quizzes — walk into the exam prepared.
          </p>
        </div>
      </div>
    </div>
  </section>

  <!-- ═══ FAQ ═══ -->
  <section class="border-t border-slate-200 bg-slate-50 section">
    <div class="section-inner">
      <div class="mx-auto max-w-3xl">
        <div class="text-center">
          <h2 class="text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Frequently asked questions</h2>
          <p class="mt-3 text-base text-slate-600">Everything you need to know about TaleemHub.</p>
        </div>

        <div class="mt-10 space-y-2">
          {faqs.map((f, i) => (
            <details class="group rounded-xl border border-slate-200 bg-white" open={i === 0}>
              <summary class="flex cursor-pointer list-none items-center justify-between gap-4 px-5 py-4 text-[15px] font-extrabold text-slate-900">
                <span>{f.q}</span>
                <Icon name="chevron-right" size={17} strokeWidth={2.4} class="shrink-0 text-slate-400 transition-transform group-open:rotate-90" />
              </summary>
              <div class="border-t border-slate-200 px-5 py-4 text-sm leading-relaxed text-slate-600">{f.a}</div>
            </details>
          ))}
        </div>
      </div>
    </div>
  </section>

  <!-- ═══ CTA ═══ -->
  <section class="section">
    <div class="section-inner">
      <div class="mx-auto max-w-3xl rounded-2xl border border-slate-200 bg-white p-10 text-center sm:p-14">
        <h2 class="text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Ready to start revising?</h2>
        <p class="mx-auto mt-4 max-w-xl text-base text-slate-600">
          Everything free, everything board-specific. Pick your board and get straight into it.
        </p>
        <div class="mt-8 flex flex-wrap items-center justify-center gap-3">
          <a href={url('/boards')} class="btn btn-primary">
            Browse boards <Icon name="arrow-right" size={14} strokeWidth={2.6} />
          </a>
          <a href={url('/notes')} class="btn btn-outline">Browse notes</a>
        </div>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO

echo "▸ index.astro — new homepage"

# ─────────────────────────────────────────────
#  STEP 6: Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -8

echo ""
echo "════════════════════════════════════════════════════════"
echo "  REDESIGN COMPLETE"
echo "════════════════════════════════════════════════════════"
echo ""
echo "  ── To push the redesign ──"
echo "    git add ."
echo "    git commit -m 'Full redesign: accent system, refreshed homepage'"
echo "    git push origin main"
echo ""
echo "  ── If you DON'T like it, revert with ──"
echo "    bash restore.sh"
echo ""
echo "  That's it — restore.sh resets main to the backup branch"
echo "  and force-pushes to GitHub. Site redeploys in ~90 seconds."
echo ""
echo "  ── What changed ──"
echo "    · Homepage restructured:"
echo "        Hero + trust bar → Board picker → Resource grid"
echo "        → How it works → FAQ → CTA"
echo "    · 7-color accent system for resource types:"
echo "        Notes       blue"
echo "        Past Papers violet"
echo "        Guess Papers fuchsia"
echo "        Pairing Schemes emerald"
echo "        Quizzes     sky"
echo "        Books       amber"
echo "        Gazettes    rose"
echo "    · Row cards: 44px icon tiles, tighter padding"
echo "    · Resource tiles: compact, colored icon by type"
echo "    · FAQ section for SEO rich results"
echo "    · Zero shadows, zero gradients"
echo "    · Tap-highlight fully disabled"
echo "    · Hover states only on hover-capable devices"
echo "════════════════════════════════════════════════════════"