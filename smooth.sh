#!/bin/bash
set -e

echo "Enabling smooth client-side navigation..."

# Add ClientRouter import + <ClientRouter /> in head, and transition:persist on header/footer
python3 - <<'PY'
import pathlib, re

p = pathlib.Path("src/layouts/BaseLayout.astro")
s = p.read_text()

# 1. Add import after the Icon import
if "ClientRouter" not in s:
    s = s.replace(
        "import Icon from '../components/Icon.astro';",
        "import Icon from '../components/Icon.astro';\nimport { ClientRouter } from 'astro:transitions';",
        1
    )

# 2. Add <ClientRouter /> right before </head>
if "<ClientRouter" not in s:
    s = s.replace("</head>", "  <ClientRouter />\n</head>", 1)

# 3. Add transition:persist to <header> so it doesn't re-render
s = re.sub(
    r'<header class="sticky top-0 z-50 w-full border-b border-neutral-200 bg-white">',
    '<header transition:persist class="sticky top-0 z-50 w-full border-b border-neutral-200 bg-white">',
    s, count=1
)

# 4. Add transition:persist to <footer>
s = re.sub(
    r'<footer class="mt-20 border-t border-neutral-200 bg-neutral-50">',
    '<footer transition:persist class="mt-20 border-t border-neutral-200 bg-neutral-50">',
    s, count=1
)

# 5. Add <style is:global> for view transition animations before </body>
if "::view-transition" not in s:
    styles = """
  <style is:global>
    /* Smooth cross-page transition */
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

    /* Let the persistent header stay put */
    header { view-transition-name: site-header; }
    footer { view-transition-name: site-footer; }

    /* Respect reduced motion */
    @media (prefers-reduced-motion: reduce) {
      ::view-transition-old(root),
      ::view-transition-new(root) { animation: none !important; }
    }
  </style>
</body>"""
    s = s.replace("</body>", styles, 1)

p.write_text(s)
print("BaseLayout patched: ClientRouter + persist + transitions")
PY

# Ensure no old bottom-nav remnants survive
grep -l "fixed inset-x-0 bottom-0" src/layouts/*.astro 2>/dev/null && echo "WARNING: bottom nav still found" || true

# Clear caches
rm -rf .astro node_modules/.vite node_modules/.astro dist

echo ""
echo "════════════════════════════════════════════"
echo "  Smooth navigation enabled"
echo "════════════════════════════════════════════"
echo ""
echo "  - Full-page reloads replaced with SPA-style client-side routing"
echo "  - Header and footer stay mounted (no re-render flicker)"
echo "  - Page content cross-fades in (180ms out, 300ms in)"
echo "  - Respects prefers-reduced-motion"
echo ""
echo "  Run:  npm run dev"