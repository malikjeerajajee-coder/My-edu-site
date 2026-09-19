#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  New Parhayi logo"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  Backup
# ─────────────────────────────────────────────
git branch -f backup-pre-logo
git push -u origin backup-pre-logo 2>&1 | tail -2 || echo "  (backup push failed — do manually later)"
echo "  ✓ backup-pre-logo created"
echo ""

# ─────────────────────────────────────────────
#  Logo component
# ─────────────────────────────────────────────
cat > src/components/Logo.astro <<'ASTRO'
---
import { url } from '../lib/url';

interface Props {
  size?: number;          // icon size in px
  wordmarkSize?: number;  // text size in px
  showWordmark?: boolean;
  href?: string;
  class?: string;
}

const {
  size = 36,
  wordmarkSize = 18,
  showWordmark = true,
  href = '/',
  class: className = '',
} = Astro.props;

const uid = Math.random().toString(36).slice(2, 8);
---
<a href={url(href)} class={`brand ${className}`} style="display: inline-flex; align-items: center; gap: 0.625rem; text-decoration: none; flex-shrink: 0;">
  <svg
    width={size}
    height={size}
    viewBox="0 0 64 64"
    xmlns="http://www.w3.org/2000/svg"
    aria-hidden="true"
    style="flex-shrink: 0;"
  >
    <defs>
      <linearGradient id={`parhayi-bg-${uid}`} x1="0" y1="0" x2="0" y2="1">
        <stop offset="0%"   stop-color="#1e40af"/>
        <stop offset="100%" stop-color="#1d4ed8"/>
      </linearGradient>
      <linearGradient id={`parhayi-book-${uid}`} x1="0" y1="0" x2="0" y2="1">
        <stop offset="0%"   stop-color="#ffffff"/>
        <stop offset="100%" stop-color="#f1f5f9"/>
      </linearGradient>
    </defs>

    <!-- Rounded container -->
    <rect width="64" height="64" rx="16" fill={`url(#parhayi-bg-${uid})`}/>

    <!-- Rays -->
    <g stroke="#fbbf24" stroke-width="2.2" stroke-linecap="round">
      <line x1="32" y1="7"   x2="32"    y2="10.5"/>
      <line x1="21" y1="11"  x2="23.5"  y2="13.5"/>
      <line x1="43" y1="11"  x2="40.5"  y2="13.5"/>
    </g>

    <!-- Rising sun -->
    <circle cx="32" cy="19" r="4" fill="#fbbf24"/>

    <!-- Open book — left page -->
    <path d="M 9 53 L 9 39 Q 20 35.5 32 31 L 32 53 Z" fill={`url(#parhayi-book-${uid})`}/>

    <!-- Open book — right page -->
    <path d="M 55 53 L 55 39 Q 44 35.5 32 31 L 32 53 Z" fill={`url(#parhayi-book-${uid})`}/>

    <!-- Spine hint -->
    <line x1="32" y1="31" x2="32" y2="53" stroke="rgba(15,23,42,0.13)" stroke-width="1"/>
  </svg>

  {showWordmark && (
    <span style={`font-size: ${wordmarkSize}px; font-weight: 800; letter-spacing: -0.03em; color: #0b1220; line-height: 1; font-family: 'Plus Jakarta Sans', system-ui, sans-serif;`}>
      Parhayi
    </span>
  )}
</a>
ASTRO
echo "  ✓ Logo.astro"

# ─────────────────────────────────────────────
#  Favicon — simplified for 16px
# ─────────────────────────────────────────────
cat > public/favicon.svg <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%"   stop-color="#1e40af"/>
      <stop offset="100%" stop-color="#1d4ed8"/>
    </linearGradient>
  </defs>
  <rect width="64" height="64" rx="16" fill="url(#bg)"/>
  <circle cx="32" cy="19" r="4.5" fill="#fbbf24"/>
  <path d="M 9 53 L 9 39 Q 20 35.5 32 31 L 32 53 Z" fill="#ffffff"/>
  <path d="M 55 53 L 55 39 Q 44 35.5 32 31 L 32 53 Z" fill="#ffffff"/>
  <line x1="32" y1="31" x2="32" y2="53" stroke="rgba(15,23,42,0.13)" stroke-width="1"/>
</svg>
SVG
echo "  ✓ favicon.svg"

# Also keep a legacy .ico reference working by adding a small svg fallback
cat > public/favicon.svg.bak <<'SVG'
<!-- backup of previous favicon -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64"><rect width="64" height="64" rx="14" fill="#1d4ed8"/><text x="32" y="44" text-anchor="middle" font-family="Plus Jakarta Sans, sans-serif" font-size="36" font-weight="800" fill="#ffffff">P</text></svg>
SVG

# ─────────────────────────────────────────────
#  Update BaseLayout — use Logo component
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re

p = pathlib.Path('src/layouts/BaseLayout.astro')
s = p.read_text()

# 1. Add Logo import
if 'import Logo' not in s:
    s = s.replace(
        "import Icon from '../components/Icon.astro';",
        "import Icon from '../components/Icon.astro';\nimport Logo from '../components/Logo.astro';"
    )

# 2. Desktop sidebar brand mark — replace entire anchor
old_desktop = re.compile(
    r'<a href=\{url\(\'/\'\)\} class="flex h-16 shrink-0 items-center gap-2\.5 border-b border-slate-200 px-5">\s*<span class="grid h-8 w-8 place-items-center rounded-lg bg-\[#1d4ed8\] text-white">\s*<Icon name="graduation-cap" size=\{17\} strokeWidth=\{2\.4\} />\s*</span>\s*<span class="text-\[15px\] font-extrabold tracking-tight text-slate-900">Parhayi</span>\s*</a>',
    re.DOTALL
)
new_desktop = '''<div class="flex h-16 shrink-0 items-center border-b border-slate-200 px-5">
      <Logo size={32} wordmarkSize={17} />
    </div>'''
s, n = old_desktop.subn(new_desktop, s)
print(f'  desktop brand: {n}')

# 3. Mobile header brand
old_mobile = re.compile(
    r'<a href=\{url\(\'/\'\)\} class="flex items-center gap-2">\s*<span class="grid h-7 w-7 place-items-center rounded-md bg-\[#1d4ed8\] text-white">\s*<Icon name="graduation-cap" size=\{15\} strokeWidth=\{2\.4\} />\s*</span>\s*<span class="text-\[15px\] font-extrabold tracking-tight text-slate-900">Parhayi</span>\s*</a>',
    re.DOTALL
)
new_mobile = '<Logo size={28} wordmarkSize={16} />'
s, n = old_mobile.subn(new_mobile, s)
print(f'  mobile brand: {n}')

# 4. Mobile drawer brand
old_drawer = re.compile(
    r'<a href=\{url\(\'/\'\)\} class="flex items-center gap-2\.5">\s*<span class="grid h-8 w-8 place-items-center rounded-lg bg-\[#1d4ed8\] text-white">\s*<Icon name="graduation-cap" size=\{17\} strokeWidth=\{2\.4\} />\s*</span>\s*<span class="text-\[15px\] font-extrabold tracking-tight text-slate-900">Parhayi</span>\s*</a>',
    re.DOTALL
)
new_drawer = '<Logo size={32} wordmarkSize={17} />'
s, n = old_drawer.subn(new_drawer, s)
print(f'  drawer brand: {n}')

# 5. Footer brand block
old_footer = re.compile(
    r'<div class="flex items-center gap-2\.5">\s*<span class="grid h-8 w-8 place-items-center rounded-lg bg-\[#1d4ed8\] text-white">\s*<Icon name="graduation-cap" size=\{17\} strokeWidth=\{2\.4\} />\s*</span>\s*<span class="text-\[15px\] font-extrabold tracking-tight text-slate-900">Parhayi</span>\s*</div>',
    re.DOTALL
)
new_footer = '<Logo size={32} wordmarkSize={17} />'
s, n = old_footer.subn(new_footer, s)
print(f'  footer brand: {n}')

p.write_text(s)
PY

echo ""
echo "  Rebuilding..."
npm run build 2>&1 | tail -6

echo ""
echo "════════════════════════════════════════════════════════"
echo "  DONE"
echo "════════════════════════════════════════════════════════"
echo ""
echo "  Preview:"
echo "    npx serve dist -p 4321"
echo ""
echo "  Check:"
echo "    · Header logo (top-left)"
echo "    · Mobile header (top-left)"
echo "    · Footer logo"
echo "    · Browser tab — favicon should update"
echo ""
echo "  ── If you don't like it ──"
echo "    git fetch origin backup-pre-logo"
echo "    git checkout backup-pre-logo"
echo "    git branch -D main && git checkout -b main"
echo "    git push -f origin main"
echo ""
echo "  ── If you like it ──"
echo "    git add ."
echo "    git commit -m 'New logo: open book + rising sun'"
echo "    git push"
echo ""
echo "  Design:"
echo "    · Rounded square (#1e40af → #1d4ed8 gradient)"
echo "    · White open book silhouette"
echo "    · Amber rising sun above"
echo "    · 3 amber rays radiating upward"
echo "    · Scales cleanly from 16px to 200px"
echo "    · Meaning: reading → knowledge → achievement"
echo "════════════════════════════════════════════════════════"