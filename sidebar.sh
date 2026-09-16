#!/bin/bash
set -e

cat > src/layouts/BaseLayout.astro <<'EOF'
---
import '../styles/global.css';
import Icon from '../components/Icon.astro';
import { ClientRouter } from 'astro:transitions';

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
  <ClientRouter />
</head>
<body class="min-h-screen bg-white">

  <!-- ═══════════════ DESKTOP SIDEBAR ═══════════════ -->
  <aside
    transition:persist
    class="sidebar fixed inset-y-0 left-0 z-40 hidden w-[260px] flex-col border-r border-neutral-200 bg-white lg:flex"
  >
    <a href="/" class="flex h-[68px] shrink-0 items-center gap-2.5 border-b border-neutral-200 px-5">
      <span class="grid h-9 w-9 place-items-center rounded-lg bg-[#0620ed] text-white">
        <Icon name="graduation-cap" size={19} strokeWidth={2.4} />
      </span>
      <span class="text-lg font-extrabold tracking-tight text-neutral-900">TaleemHub</span>
    </a>

    <nav class="flex-1 overflow-y-auto px-3 py-6">
      <div class="mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-neutral-400">Main</div>
      <ul class="space-y-0.5">
        {navMain.map(item => (
          <li>
            <a
              href={item.href}
              class:list={[
                "nav-link group flex items-center gap-3 rounded-lg px-3 py-2.5 text-[13.5px] font-semibold transition-all duration-200",
                isActive(item.href)
                  ? "bg-[#eef2fe] text-[#0620ed]"
                  : "text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900",
              ]}
            >
              <Icon name={item.icon} size={18} strokeWidth={2.1} class="shrink-0 transition-transform duration-200 group-hover:scale-110" />
              <span>{item.label}</span>
              {isActive(item.href) && (
                <span class="ml-auto h-1.5 w-1.5 rounded-full bg-[#0620ed]"></span>
              )}
            </a>
          </li>
        ))}
      </ul>

      <div class="mt-7 mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-neutral-400">Library</div>
      <ul class="space-y-0.5">
        {navLibrary.map(item => (
          <li>
            <a
              href={item.href}
              class:list={[
                "nav-link group flex items-center gap-3 rounded-lg px-3 py-2.5 text-[13.5px] font-semibold transition-all duration-200",
                isActive(item.href)
                  ? "bg-[#eef2fe] text-[#0620ed]"
                  : "text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900",
              ]}
            >
              <Icon name={item.icon} size={18} strokeWidth={2.1} class="shrink-0 transition-transform duration-200 group-hover:scale-110" />
              <span>{item.label}</span>
              {isActive(item.href) && (
                <span class="ml-auto h-1.5 w-1.5 rounded-full bg-[#0620ed]"></span>
              )}
            </a>
          </li>
        ))}
      </ul>
    </nav>

    <div class="border-t border-neutral-200 p-3">
      <form action="/search" method="get" role="search" class="flex items-center gap-2 rounded-lg border border-neutral-200 bg-neutral-50 px-3 py-2.5 transition-colors focus-within:border-[#0620ed] focus-within:bg-white">
        <Icon name="search" size={15} strokeWidth={2.3} class="shrink-0 text-neutral-400" />
        <input
          type="search"
          name="q"
          placeholder="Search library"
          class="min-w-0 flex-1 bg-transparent text-[13px] font-medium text-neutral-900 outline-none placeholder:text-neutral-400"
        />
      </form>
    </div>
  </aside>

  <!-- ═══════════════ MOBILE TOP BAR ═══════════════ -->
  <header
    transition:persist
    class="mobile-bar sticky top-0 z-30 flex h-16 w-full items-center gap-3 border-b border-neutral-200 bg-white/95 px-4 backdrop-blur-xl lg:hidden"
  >
    <button
      id="open-drawer"
      type="button"
      aria-label="Open menu"
      class="grid h-10 w-10 place-items-center rounded-lg border border-neutral-200 bg-white text-neutral-700 transition-all duration-200 active:scale-95 active:bg-neutral-100"
    >
      <Icon name="menu" size={20} strokeWidth={2.4} />
    </button>
    <a href="/" class="flex items-center gap-2">
      <span class="grid h-8 w-8 place-items-center rounded-lg bg-[#0620ed] text-white">
        <Icon name="graduation-cap" size={17} strokeWidth={2.4} />
      </span>
      <span class="text-base font-extrabold tracking-tight text-neutral-900">TaleemHub</span>
    </a>
    <a
      href="/search"
      class="ml-auto grid h-10 w-10 place-items-center rounded-lg border border-neutral-200 bg-white text-neutral-700 transition-all duration-200 active:scale-95 active:bg-neutral-100"
      aria-label="Search"
    >
      <Icon name="search" size={18} strokeWidth={2.4} />
    </a>
  </header>

  <!-- ═══════════════ MOBILE DRAWER ═══════════════ -->
  <div id="drawer" class="fixed inset-0 z-50 hidden lg:hidden" aria-hidden="true">
    <div id="drawer-backdrop" class="absolute inset-0 bg-neutral-900/40 opacity-0 backdrop-blur-sm transition-opacity duration-300"></div>
    <aside id="drawer-panel" class="absolute inset-y-0 left-0 flex w-[280px] -translate-x-full flex-col border-r border-neutral-200 bg-white transition-transform duration-300" style="transition-timing-function: cubic-bezier(0.16, 1, 0.3, 1);">
      <div class="flex h-[68px] shrink-0 items-center justify-between border-b border-neutral-200 px-4">
        <a href="/" class="flex items-center gap-2.5">
          <span class="grid h-9 w-9 place-items-center rounded-lg bg-[#0620ed] text-white">
            <Icon name="graduation-cap" size={19} strokeWidth={2.4} />
          </span>
          <span class="text-lg font-extrabold tracking-tight text-neutral-900">TaleemHub</span>
        </a>
        <button
          id="close-drawer"
          type="button"
          aria-label="Close menu"
          class="grid h-9 w-9 place-items-center rounded-lg text-neutral-500 transition-colors active:bg-neutral-100"
        >
          <Icon name="x" size={18} strokeWidth={2.4} />
        </button>
      </div>

      <nav class="flex-1 overflow-y-auto px-3 py-6">
        <div class="mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-neutral-400">Main</div>
        <ul class="space-y-0.5">
          {navMain.map(item => (
            <li>
              <a href={item.href} class:list={[
                "flex items-center gap-3 rounded-lg px-3 py-2.5 text-[13.5px] font-semibold transition-colors",
                isActive(item.href) ? "bg-[#eef2fe] text-[#0620ed]" : "text-neutral-600 hover:bg-neutral-100",
              ]}>
                <Icon name={item.icon} size={18} strokeWidth={2.1} />
                <span>{item.label}</span>
              </a>
            </li>
          ))}
        </ul>

        <div class="mt-7 mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-neutral-400">Library</div>
        <ul class="space-y-0.5">
          {navLibrary.map(item => (
            <li>
              <a href={item.href} class:list={[
                "flex items-center gap-3 rounded-lg px-3 py-2.5 text-[13.5px] font-semibold transition-colors",
                isActive(item.href) ? "bg-[#eef2fe] text-[#0620ed]" : "text-neutral-600 hover:bg-neutral-100",
              ]}>
                <Icon name={item.icon} size={18} strokeWidth={2.1} />
                <span>{item.label}</span>
              </a>
            </li>
          ))}
        </ul>
      </nav>

      <div class="border-t border-neutral-200 p-3">
        <form action="/search" method="get" role="search" class="flex items-center gap-2 rounded-lg border border-neutral-200 bg-neutral-50 px-3 py-2.5">
          <Icon name="search" size={15} strokeWidth={2.3} class="shrink-0 text-neutral-400" />
          <input type="search" name="q" placeholder="Search library" class="min-w-0 flex-1 bg-transparent text-[13px] font-medium text-neutral-900 outline-none placeholder:text-neutral-400" />
        </form>
      </div>
    </aside>
  </div>

  <!-- ═══════════════ CONTENT ═══════════════ -->
  <div class="content-wrap lg:pl-[260px]">
    <main class="min-h-[60vh]">
      <slot />
    </main>

    <footer transition:persist class="mt-20 border-t border-neutral-200 bg-neutral-50">
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
  </div>

  <!-- ═══════════════ VIEW TRANSITION + DRAWER STYLES ═══════════════ -->
  <style is:global>
    /* Smooth cross-page fade */
    @view-transition { navigation: auto; }

    ::view-transition-old(root) {
      animation: 180ms cubic-bezier(0.16, 1, 0.3, 1) both fade-out;
    }
    ::view-transition-new(root) {
      animation: 300ms cubic-bezier(0.16, 1, 0.3, 1) both fade-in;
    }
    @keyframes fade-out {
      from { opacity: 1; transform: translateY(0); }
      to   { opacity: 0; transform: translateY(-4px); }
    }
    @keyframes fade-in {
      from { opacity: 0; transform: translateY(8px); }
      to   { opacity: 1; transform: translateY(0); }
    }

    /* Sidebar and mobile bar stay put across navigations */
    .sidebar      { view-transition-name: app-sidebar; }
    .mobile-bar   { view-transition-name: app-mobilebar; }
    footer        { view-transition-name: app-footer; }

    /* Drawer nudge on nav link tap (mobile feedback) */
    .nav-link:active { transform: scale(0.98); }

    /* Respect reduced motion */
    @media (prefers-reduced-motion: reduce) {
      ::view-transition-old(root),
      ::view-transition-new(root) { animation: none !important; }
      * { transition-duration: 0.01ms !important; animation-duration: 0.01ms !important; }
    }
  </style>

  <!-- ═══════════════ DRAWER SCRIPT ═══════════════ -->
  <script is:inline>
    (function () {
      var drawer = document.getElementById('drawer');
      var panel = document.getElementById('drawer-panel');
      var backdrop = document.getElementById('drawer-backdrop');
      var openBtn = document.getElementById('open-drawer');
      var closeBtn = document.getElementById('close-drawer');
      if (!drawer) return;

      var opening = false;

      function open() {
        if (opening) return;
        opening = true;
        drawer.classList.remove('hidden');
        drawer.setAttribute('aria-hidden', 'false');
        document.body.style.overflow = 'hidden';
        // Force reflow so the transition kicks in
        void panel.offsetWidth;
        requestAnimationFrame(function () {
          panel.classList.remove('-translate-x-full');
          backdrop.classList.remove('opacity-0');
          backdrop.classList.add('opacity-100');
          opening = false;
        });
      }
      function close() {
        panel.classList.add('-translate-x-full');
        backdrop.classList.add('opacity-0');
        backdrop.classList.remove('opacity-100');
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
      document.querySelectorAll('#drawer-panel a').forEach(function (a) {
        a.addEventListener('click', close);
      });
    })();
  </script>
</body>
</html>
EOF

rm -rf .astro node_modules/.vite node_modules/.astro dist

echo ""
echo "════════════════════════════════════════════"
echo "  Sidebar layout with smooth animations"
echo "════════════════════════════════════════════"
echo ""
echo "  Desktop (lg+):"
echo "    - Fixed sidebar (260px) on the left"
echo "    - Brand header, Main + Library sections"
echo "    - Search at the bottom of the sidebar"
echo "    - Content fills the rest, no top bar"
echo ""
echo "  Mobile:"
echo "    - Slim top bar with hamburger + brand + search"
echo "    - Tap hamburger → drawer slides in with backdrop fade"
echo "    - Tap link, backdrop, X, or Escape → closes"
echo ""
echo "  Animations:"
echo "    - Cross-page fade via View Transitions API"
echo "    - Sidebar persists across navigation (no flicker)"
echo "    - Nav link icons scale 110% on hover"
echo "    - Active link shows a blue dot marker"
echo "    - Drawer: 300ms cubic-bezier(0.16, 1, 0.3, 1) slide"
echo ""
echo "  Run:  npm run dev"