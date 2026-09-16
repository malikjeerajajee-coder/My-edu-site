#!/bin/bash
set -e

echo "Applying Tailwind CDN fallback..."

# 1. Simplify global.css — no @import "tailwindcss" (CDN handles utilities)
cat > src/styles/global.css <<'CSS'
/* Fonts */
body {
  font-family: 'Inter', ui-sans-serif, system-ui, -apple-system, sans-serif;
}
.font-display {
  font-family: 'Plus Jakarta Sans', 'Inter', ui-sans-serif, system-ui, sans-serif;
  letter-spacing: -0.02em;
}

/* Base */
html {
  -webkit-text-size-adjust: 100%;
  scroll-behavior: smooth;
  overflow-x: hidden;
}
body {
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

/* Animation */
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(12px); }
  to   { opacity: 1; transform: translateY(0); }
}
.animate-in { animation: fadeUp 0.55s cubic-bezier(0.16,1,0.3,1) both; }
CSS

# 2. Add Tailwind CDN + Fonts to BaseLayout head
python3 - <<'PY'
import re, pathlib

p = pathlib.Path("src/layouts/BaseLayout.astro")
src = p.read_text()

# Remove old font preconnect/link lines we may have added
src = re.sub(r'\s*<link rel="preconnect"[^>]*/>\s*', '\n  ', src)
src = re.sub(r'\s*<link rel="stylesheet" href="https://fonts\.googleapis[^>]*/>\s*', '\n  ', src)

inject = """
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Plus+Jakarta+Sans:wght@600;700;800&display=swap" />
  <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
"""

# Insert right after <head>
src = src.replace("<head>\n", "<head>\n" + inject, 1)

p.write_text(src)
print("Patched BaseLayout.astro")
PY

# 3. Also remove the FontLinks.astro if it exists (no longer needed)
rm -f src/components/FontLinks.astro

# 4. Clean caches
rm -rf .astro node_modules/.vite

echo ""
echo "==================================================="
echo "  Tailwind CDN fallback applied"
echo "==================================================="
echo ""
echo "Now:"
echo "  1. Stop dev server (Ctrl+C)"
echo "  2. Run:  npm run dev"
echo "  3. Hard-refresh browser (clear cache)"
echo ""
echo "You should now see the full styled design."