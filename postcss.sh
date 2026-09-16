#!/bin/bash
set -e

echo "Switching to build-time Tailwind via PostCSS..."

# 1. Install PostCSS pipeline
npm install tailwindcss @tailwindcss/postcss postcss --silent

# 2. Remove the CDN script from BaseLayout
python3 - <<'PY'
import re, pathlib

p = pathlib.Path("src/layouts/BaseLayout.astro")
src = p.read_text()
src = re.sub(r'\s*<script src="https://cdn\.jsdelivr\.net/npm/@tailwindcss/browser@4"></script>\s*', '\n  ', src)

# Fix the bottom-nav: even distribution + truncated labels
old = '''<nav class="fixed inset-x-0 bottom-0 z-50 border-t border-slate-200 bg-white/95 backdrop-blur-lg md:hidden" style="padding-bottom: env(safe-area-inset-bottom);">
    <div class="flex items-center justify-around">'''
new = '''<nav class="fixed inset-x-0 bottom-0 z-50 border-t border-slate-200 bg-white/95 backdrop-blur-lg md:hidden" style="padding-bottom: env(safe-area-inset-bottom);">
    <div class="flex items-stretch">'''
src = src.replace(old, new)

src = src.replace(
  '"flex min-w-[56px] flex-col items-center gap-1 px-3 py-2.5 text-[11px] font-semibold transition-colors"',
  '"flex min-w-0 flex-1 flex-col items-center gap-1 px-1 py-2.5 text-[10px] font-semibold leading-none transition-colors"'
)

p.write_text(src)
print("Layout patched.")
PY

# 3. Restore global.css with proper Tailwind import at the top
cat > src/styles/global.css <<'CSS'
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

/* Prose */
.prose { font-size: 0.975rem; line-height: 1.75; color: #334155; }
.prose h1, .prose h2, .prose h3 { color: #0f172a; font-weight: 700; letter-spacing: -0.02em; }
.prose h2 { font-size: 1.25rem; margin-top: 2rem; margin-bottom: 0.75rem; padding-bottom: 0.5rem; border-bottom: 1px solid #e2e8f0; }
.prose h3 { font-size: 1.05rem; margin-top: 1.5rem; margin-bottom: 0.5rem; }
.prose h2:first-child, .prose h3:first-child { margin-top: 0; }
.prose p { margin-bottom: 1rem; }
.prose ul, .prose ol { padding-left: 1.25rem; margin-bottom: 1rem; }
.prose li { margin-bottom: 0.375rem; }
.prose li::marker { color: #059669; }
.prose code { background: #ecfdf5; color: #065f46; padding: 0.125rem 0.375rem; border-radius: 0.375rem; font-size: 0.85em; font-weight: 600; }
.prose strong { font-weight: 700; color: #0f172a; }
.prose table { width: 100%; border-collapse: collapse; margin: 1rem 0; font-size: 0.875rem; border: 1px solid #e2e8f0; border-radius: 0.5rem; overflow: hidden; }
.prose th { background: #f8fafc; text-align: left; padding: 0.625rem 0.75rem; font-weight: 700; color: #0f172a; border-bottom: 1px solid #e2e8f0; }
.prose td { padding: 0.625rem 0.75rem; border-top: 1px solid #e2e8f0; }
.prose a { color: #059669; text-decoration: underline; text-underline-offset: 2px; }

@keyframes fadeUp {
  from { opacity: 0; transform: translateY(12px); }
  to   { opacity: 1; transform: translateY(0); }
}
.animate-in { animation: fadeUp 0.55s cubic-bezier(0.16,1,0.3,1) both; }
CSS

# 4. PostCSS config
cat > postcss.config.mjs <<'CONF'
export default {
  plugins: {
    '@tailwindcss/postcss': {},
  },
};
CONF

# 5. Clean astro.config.mjs (no vite plugin needed)
cat > astro.config.mjs <<'CONF'
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://your-site.pages.dev',
  integrations: [sitemap()],
});
CONF

# 6. Clean caches
rm -rf .astro node_modules/.vite

echo ""
echo "==================================================="
echo "  Build-time Tailwind enabled"
echo "==================================================="
echo ""
echo "  - Tailwind now compiles at build time (no FOUC)"
echo "  - PostCSS pipeline installed"
echo "  - Bottom nav labels fixed"
echo ""
echo "Next: stop dev server (Ctrl+C), then run:  npm run dev"