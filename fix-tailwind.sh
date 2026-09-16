#!/bin/bash
set -e

echo "Reinstalling Tailwind + fixing config..."

# 1. Reinstall Tailwind cleanly
npm install tailwindcss @tailwindcss/vite --silent

# 2. Rewrite astro.config.mjs (clean)
cat > astro.config.mjs <<'CONF'
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://your-site.pages.dev',
  integrations: [sitemap()],
  vite: {
    plugins: [tailwindcss()],
  },
});
CONF

# 3. Rewrite global.css — Tailwind import MUST be first
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

# 4. Add font link tags directly (in case @import is being stripped)
cat > src/components/FontLinks.astro <<'EOF'
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Plus+Jakarta+Sans:wght@600;700;800&display=swap" />
EOF

# 5. Patch the layout to include the font links
if ! grep -q "FontLinks" src/layouts/BaseLayout.astro; then
  # Add the import line after the existing import
  sed -i "s|import Icon from '../components/Icon.astro';|import Icon from '../components/Icon.astro';\nimport FontLinks from '../components/FontLinks.astro';|" src/layouts/BaseLayout.astro

  # Add <FontLinks /> right after <head> ... actually before </head>
  sed -i "s|</head>|<FontLinks />\n</head>|" src/layouts/BaseLayout.astro
fi

echo ""
echo "==================================================="
echo "  Fix applied"
echo "==================================================="
echo ""
echo "  Next steps:"
echo "    1. STOP the dev server (Ctrl+C in the terminal)"
echo "    2. Delete Astro/Vite cache:  rm -rf node_modules/.vite .astro"
echo "    3. Start fresh:              npm run dev"
echo ""