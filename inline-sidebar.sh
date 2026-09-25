#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "════════════════════════════════════════════"
echo "  Inlining sidebar into BaseLayout"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  Show current state for diagnosis
# ─────────────────────────────────────────────
echo "▸ Current state:"
echo "  Sidebar.astro exists:   $([ -f src/components/Sidebar.astro ] && echo YES || echo NO)"
echo "  Import in BaseLayout:   $(grep -c "import Sidebar" src/layouts/BaseLayout.astro 2>/dev/null || echo 0)"
echo "  Usages in BaseLayout:   $(grep -c "<Sidebar" src/layouts/BaseLayout.astro 2>/dev/null || echo 0)"
echo ""

# ─────────────────────────────────────────────
#  Rewrite BaseLayout with inline sidebar (no component)
# ─────────────────────────────────────────────
cat > src/layouts/BaseLayout.astro <<'ASTRO'
---
import '../styles/global.css';
import Icon from '../components/Icon.astro';
import { url } from '../lib/url';

interface Props {
  title: string;
  description?: string;
  jsonLd?: any;
  noindex?: boolean;
}

const {
  title,
  description = 'Free notes, past papers, guess papers, textbooks and result gazettes for Pakistani students — organised by board, class and subject.',
  jsonLd,
  noindex = false,
} = Astro.props;

const SITE = 'https://parhayi.pages.dev';

let pathname = Astro.url.pathname;
let canonical = SITE + pathname;
if (!canonical.endsWith('/') && !canonical.match(/\.[a-z0-9]+$/i)) canonical += '/';

const schemas: object[] = [];
if (jsonLd) {
  if (Array.isArray(jsonLd)) schemas.push(...jsonLd);
  else schemas.push(jsonLd);
}

// Nav data
const navSections = [
  {
    label: 'Main',
    items: [
      { href: '/',        icon: 'home',           label: 'Home' },
      { href: '/boards',  icon: 'graduation-cap', label: 'Boards' },
    ],
  },
  {
    label: 'Study Material',
    items: [
      { href: '/notes',   icon: 'file-text',   label: 'Notes' },
      { href: '/quizzes', icon: 'circle-help', label: 'Quizzes' },
      { href: '/books',   icon: 'book-marked', label: 'Textbooks' },
    ],
  },
  {
    label: 'Exam Prep',
    items: [
      { href: '/past-papers',     icon: 'scroll-text', label: 'Past Papers' },
      { href: '/guess-papers',    icon: 'sparkles',    label: 'Guess Papers' },
      { href: '/pairing-schemes', icon: 'list',        label: 'Pairing Schemes' },
      { href: '/gazettes',        icon: 'newspaper',   label: 'Result Gazettes' },
    ],
  },
];

const isActive = (href: string) => {
  if (href === '/') return pathname === '/' || pathname === '';
  return pathname.startsWith(href);
};

// Shared sidebar markup as a function returning template pieces
const renderNav = () => navSections;
---
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
  <meta name="theme-color" content="#1d4ed8" />
  <title>{title}</title>
  <meta name="description" content={description} />
  <link rel="canonical" href={canonical} />
  <meta name="robots" content={noindex ? 'noindex, follow' : 'index, follow, max-image-preview:large, max-snippet:-1'} />
  <meta property="og:type" content="website" />
  <meta property="og:url" content={canonical} />
  <meta property="og:title" content={title} />
  <meta property="og:description" content={description} />
  <meta property="og:site_name" content="Parhayi" />
  <meta property="og:locale" content="en_PK" />
  <link rel="icon" type="image/png" href={url('/favicon.png')} />
  <link rel="sitemap" type="application/xml" href={url('/sitemap-index.xml')} />
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link rel="preload" as="style" href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" />
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" />
  {schemas.map(s => (
    <script type="application/ld+json" set:html={JSON.stringify(s)} />
  ))}
</head>
<body class="min-h-screen bg-white">

  <!-- ═══════ DESKTOP SIDEBAR ═══════ -->
  <aside class="fixed top-0 bottom-0 left-0 z-40 hidden w-[260px] flex-col border-r border-slate-200 bg-white lg:flex">
    <!-- Brand -->
    <div class="flex h-[68px] shrink-0 items-center gap-2.5 border-b border-slate-200 px-5">
      <a href={url('/')} class="flex min-w-0 flex-1 items-center gap-2.5">
        <img src={url('/logo-icon-64.png')} alt="Parhayi" width="32" height="32" style="border-radius: 8px; display: block; flex-shrink: 0;" />
        <span class="truncate font-display text-[17px] font-extrabold tracking-tight text-slate-900">Parhayi</span>
      </a>
    </div>

    <!-- Nav -->
    <nav class="flex-1 overflow-y-auto px-3 py-4">
      {navSections.map(sec => (
        <div class="mb-6">
          <div class="mb-1.5 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-slate-400">
            {sec.label}
          </div>
          <ul class="space-y-px">
            {sec.items.map(item => (
              <li>
                <a
                  href={url(item.href)}
                  class:list={[
                    "group flex items-center gap-3 rounded-lg px-3 py-2 text-[13.5px] font-semibold transition-colors",
                    isActive(item.href)
                      ? "bg-[#eff4ff] text-[#1d4ed8]"
                      : "text-slate-600 hover:bg-slate-100 hover:text-slate-900",
                  ]}
                >
                  <Icon name={item.icon} size={17} strokeWidth={isActive(item.href) ? 2.4 : 2.1} class="shrink-0" />
                  <span class="truncate">{item.label}</span>
                  {isActive(item.href) && (
                    <span class="ml-auto h-1.5 w-1.5 shrink-0 rounded-full bg-[#1d4ed8]"></span>
                  )}
                </a>
              </li>
            ))}
          </ul>
        </div>
      ))}
    </nav>

    <!-- Search -->
    <div class="border-t border-slate-200 p-3">
      <form action={url('/search')} method="get" role="search" class="flex items-center gap-2 rounded-lg border border-slate-200 bg-slate-50 px-3 py-2.5 transition-colors focus-within:border-[#1d4ed8] focus-within:bg-white">
        <Icon name="search" size={14} strokeWidth={2.3} class="shrink-0 text-slate-400" />
        <input type="search" name="q" placeholder="Search library…" class="min-w-0 flex-1 bg-transparent text-[13px] font-medium text-slate-900 outline-none placeholder:text-slate-400" />
      </form>
    </div>
  </aside>

  <!-- ═══════ MOBILE HEADER ═══════ -->
  <header class="sticky top-0 z-30 flex h-14 w-full items-center gap-3 border-b border-slate-200 bg-white px-4 lg:hidden">
    <button
      type="button"
      id="open-sidebar"
      aria-label="Open menu"
      class="grid h-10 w-10 place-items-center rounded-lg text-slate-700 transition-colors hover:bg-slate-100 active:bg-slate-200"
    >
      <Icon name="menu" size={20} strokeWidth={2.4} />
    </button>
    <a href={url('/')} class="flex items-center gap-2">
      <img src={url('/logo-icon-64.png')} alt="Parhayi" width="28" height="28" style="border-radius: 7px; display: block;" />
      <span class="font-display text-[15px] font-extrabold tracking-tight text-slate-900">Parhayi</span>
    </a>
    <a
      href={url('/search')}
      class="ml-auto grid h-10 w-10 place-items-center rounded-lg text-slate-700 transition-colors hover:bg-slate-100 active:bg-slate-200"
      aria-label="Search"
    >
      <Icon name="search" size={19} strokeWidth={2.4} />
    </a>
  </header>

  <!-- ═══════ MOBILE DRAWER ═══════ -->
  <div id="mobile-drawer" class="fixed inset-0 z-50 hidden lg:hidden">
    <div id="mobile-drawer-backdrop" class="absolute inset-0 bg-slate-900/50 opacity-0 transition-opacity duration-300"></div>

    <aside
      id="mobile-drawer-panel"
      class="absolute top-0 bottom-0 left-0 flex w-[280px] flex-col border-r border-slate-200 bg-white"
      style="transform: translateX(-100%); transition: transform .3s cubic-bezier(0.16, 1, 0.3, 1);"
    >
      <!-- Brand -->
      <div class="flex h-[68px] shrink-0 items-center gap-2.5 border-b border-slate-200 px-5">
        <a href={url('/')} class="flex min-w-0 flex-1 items-center gap-2.5">
          <img src={url('/logo-icon-64.png')} alt="Parhayi" width="32" height="32" style="border-radius: 8px; display: block; flex-shrink: 0;" />
          <span class="truncate font-display text-[17px] font-extrabold tracking-tight text-slate-900">Parhayi</span>
        </a>
        <button
          type="button"
          id="close-sidebar"
          aria-label="Close menu"
          class="grid h-8 w-8 shrink-0 place-items-center rounded-md text-slate-500 transition-colors hover:bg-slate-100"
        >
          <Icon name="x" size={16} strokeWidth={2.4} />
        </button>
      </div>

      <!-- Nav -->
      <nav class="flex-1 overflow-y-auto px-3 py-4">
        {navSections.map(sec => (
          <div class="mb-6">
            <div class="mb-1.5 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-slate-400">
              {sec.label}
            </div>
            <ul class="space-y-px">
              {sec.items.map(item => (
                <li>
                  <a
                    href={url(item.href)}
                    class:list={[
                      "group flex items-center gap-3 rounded-lg px-3 py-2 text-[13.5px] font-semibold transition-colors",
                      isActive(item.href)
                        ? "bg-[#eff4ff] text-[#1d4ed8]"
                        : "text-slate-600 hover:bg-slate-100 hover:text-slate-900",
                    ]}
                  >
                    <Icon name={item.icon} size={17} strokeWidth={isActive(item.href) ? 2.4 : 2.1} class="shrink-0" />
                    <span class="truncate">{item.label}</span>
                    {isActive(item.href) && (
                      <span class="ml-auto h-1.5 w-1.5 shrink-0 rounded-full bg-[#1d4ed8]"></span>
                    )}
                  </a>
                </li>
              ))}
            </ul>
          </div>
        ))}
      </nav>

      <!-- Search -->
      <div class="border-t border-slate-200 p-3">
        <form action={url('/search')} method="get" role="search" class="flex items-center gap-2 rounded-lg border border-slate-200 bg-slate-50 px-3 py-2.5">
          <Icon name="search" size={14} strokeWidth={2.3} class="shrink-0 text-slate-400" />
          <input type="search" name="q" placeholder="Search library…" class="min-w-0 flex-1 bg-transparent text-[13px] font-medium text-slate-900 outline-none placeholder:text-slate-400" />
        </form>
      </div>
    </aside>
  </div>

  <!-- ═══════ CONTENT ═══════ -->
  <div class="lg:pl-[260px]">
    <main class="min-h-[60vh]">
      <slot />
    </main>

    <footer class="mt-20 border-t border-slate-200 bg-slate-50">
      <div class="mx-auto max-w-[1200px] px-5 py-12 lg:px-10">
        <div class="grid grid-cols-1 gap-10 sm:grid-cols-2 lg:grid-cols-4">
          <div class="sm:col-span-2">
            <div class="flex items-center gap-2.5">
              <img src={url('/logo-icon-64.png')} alt="Parhayi" width="32" height="32" style="border-radius: 8px; display: block;" />
              <span class="font-display text-[17px] font-extrabold tracking-tight text-slate-900">Parhayi</span>
            </div>
            <p class="mt-4 max-w-sm text-sm leading-relaxed text-slate-500">
              Free notes, past papers, guess papers, textbooks and result gazettes for Pakistani students — organised by board, class and subject.
            </p>
          </div>
          <div>
            <h4 class="text-[13px] font-extrabold text-slate-900">Study</h4>
            <ul class="mt-3.5 space-y-2 text-sm text-slate-500">
              <li><a href={url('/boards')} class="hover:text-[#1d4ed8]">Boards</a></li>
              <li><a href={url('/notes')} class="hover:text-[#1d4ed8]">Notes</a></li>
              <li><a href={url('/quizzes')} class="hover:text-[#1d4ed8]">Quizzes</a></li>
              <li><a href={url('/books')} class="hover:text-[#1d4ed8]">Textbooks</a></li>
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
        <div class="mt-10 flex flex-col gap-3 border-t border-slate-200 pt-6 text-xs text-slate-400 sm:flex-row sm:items-center sm:justify-between">
          <p>© {new Date().getFullYear()} Parhayi. Built for students, forever free.</p>
          <nav class="flex flex-wrap gap-4">
            <a href={url('/about')} class="hover:text-[#1d4ed8]">About</a>
            <a href={url('/contact')} class="hover:text-[#1d4ed8]">Contact</a>
            <a href={url('/search')} class="hover:text-[#1d4ed8]">Search</a>
          </nav>
        </div>
      </div>
    </footer>
  </div>

  <!-- ═══════ DRAWER SCRIPT ═══════ -->
  <script is:inline>
    (function () {
      var drawer = document.getElementById('mobile-drawer');
      var backdrop = document.getElementById('mobile-drawer-backdrop');
      var panel = document.getElementById('mobile-drawer-panel');
      var openBtn = document.getElementById('open-sidebar');
      var closeBtn = document.getElementById('close-sidebar');

      if (!drawer || !panel || !backdrop) return;

      var isOpen = false;

      function open() {
        if (isOpen) return;
        isOpen = true;
        drawer.classList.remove('hidden');
        document.body.style.overflow = 'hidden';
        requestAnimationFrame(function () {
          panel.style.transform = 'translateX(0)';
          backdrop.classList.remove('opacity-0');
          backdrop.classList.add('opacity-100');
        });
      }

      function close() {
        if (!isOpen) return;
        isOpen = false;
        panel.style.transform = 'translateX(-100%)';
        backdrop.classList.add('opacity-0');
        backdrop.classList.remove('opacity-100');
        setTimeout(function () {
          drawer.classList.add('hidden');
          document.body.style.overflow = '';
        }, 300);
      }

      if (openBtn) openBtn.addEventListener('click', function (e) { e.preventDefault(); open(); });
      if (closeBtn) closeBtn.addEventListener('click', function (e) { e.preventDefault(); close(); });
      if (backdrop) backdrop.addEventListener('click', close);
      document.addEventListener('keydown', function (e) { if (e.key === 'Escape') close(); });
    })();
  </script>

</body>
</html>
ASTRO
echo "  ✓ BaseLayout.astro rewritten with inline sidebar"

# ─────────────────────────────────────────────
#  Remove the Sidebar component (no longer needed)
# ─────────────────────────────────────────────
rm -f src/components/Sidebar.astro
echo "  ✓ Removed src/components/Sidebar.astro"

# ─────────────────────────────────────────────
#  Verify no orphan references
# ─────────────────────────────────────────────
echo ""
echo "▸ Checking for orphan references:"
echo "  Sidebar in BaseLayout: $(grep -c "Sidebar" src/layouts/BaseLayout.astro || echo 0)"
echo "  Sidebar in src/:       $(grep -rl "import Sidebar\|<Sidebar" src/ 2>/dev/null | wc -l)"

# ─────────────────────────────────────────────
#  Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding..."
rm -rf dist .astro node_modules/.vite
npm run build 2>&1 | tail -10

echo ""
echo "════════════════════════════════════════════"
echo "  DONE"
echo ""
if [ -d "dist" ]; then
  echo "  ✓ Build succeeded ($(find dist -name '*.html' | wc -l) pages)"
  echo ""
  echo "  Preview: bash preview.sh"
  echo "  Or dev:  npm run dev"
else
  echo "  ✗ Build failed — paste the error"
fi
echo ""
echo "  Push when happy:"
echo "    git add . && git commit -m 'Inline sidebar in BaseLayout' && git push"
echo "════════════════════════════════════════════"