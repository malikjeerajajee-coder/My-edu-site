#!/bin/bash
set -e

mkdir -p src/pages

cat > src/pages/logo-concepts.astro <<'ASTRO'
---
import BaseLayout from '../layouts/BaseLayout.astro';
---
<BaseLayout title="Logo Concepts — Parhayi">
  <div class="mx-auto max-w-5xl px-5 py-16">
    <h1 class="text-3xl font-extrabold tracking-tight">Logo concepts</h1>
    <p class="mt-3 text-slate-600">Pick the one you like — or tell me what to change.</p>

    <div class="mt-12 grid grid-cols-2 gap-8 sm:grid-cols-3 lg:grid-cols-5">

      <!-- Concept 1: Letter P monogram -->
      <div>
        <svg viewBox="0 0 64 64" style="width:100%;max-width:120px;display:block;">
          <rect width="64" height="64" rx="14" fill="#1d4ed8"/>
          <text x="32" y="46" text-anchor="middle"
                font-family="'Plus Jakarta Sans', sans-serif"
                font-size="40" font-weight="800" fill="#ffffff"
                letter-spacing="-2">P</text>
          <circle cx="48" cy="20" r="4" fill="#fbbf24"/>
        </svg>
        <p class="mt-3 text-xs font-bold uppercase tracking-wider text-slate-500">1. Monogram P</p>
      </div>

      <!-- Concept 2: Open book only (minimal) -->
      <div>
        <svg viewBox="0 0 64 64" style="width:100%;max-width:120px;display:block;">
          <rect width="64" height="64" rx="14" fill="#1d4ed8"/>
          <path d="M 12 48 L 12 30 Q 22 27 32 22 L 32 48 Z" fill="#ffffff"/>
          <path d="M 52 48 L 52 30 Q 42 27 32 22 L 32 48 Z" fill="#ffffff"/>
          <line x1="32" y1="22" x2="32" y2="48" stroke="rgba(15,23,42,0.15)" stroke-width="1.2"/>
          <circle cx="32" cy="14" r="3" fill="#fbbf24"/>
        </svg>
        <p class="mt-3 text-xs font-bold uppercase tracking-wider text-slate-500">2. Open book</p>
      </div>

      <!-- Concept 3: P + book combined -->
      <div>
        <svg viewBox="0 0 64 64" style="width:100%;max-width:120px;display:block;">
          <rect width="64" height="64" rx="14" fill="#1d4ed8"/>
          <path d="M 14 52 L 14 24 Q 14 20 18 20 L 30 20 Q 34 20 34 24 L 34 52" fill="none" stroke="#ffffff" stroke-width="5" stroke-linecap="round"/>
          <path d="M 30 24 Q 30 22 32 22 L 42 22 Q 46 22 46 26 L 46 52" fill="none" stroke="#ffffff" stroke-width="5" stroke-linecap="round" opacity="0.55"/>
          <circle cx="40" cy="16" r="3.5" fill="#fbbf24"/>
        </svg>
        <p class="mt-3 text-xs font-bold uppercase tracking-wider text-slate-500">3. P + book</p>
      </div>

      <!-- Concept 4: Triangle / rising mountain (achievement) -->
      <div>
        <svg viewBox="0 0 64 64" style="width:100%;max-width:120px;display:block;">
          <rect width="64" height="64" rx="14" fill="#1d4ed8"/>
          <path d="M 32 12 L 52 50 L 12 50 Z" fill="none" stroke="#ffffff" stroke-width="3.5" stroke-linejoin="round"/>
          <path d="M 32 12 L 42 30 L 22 30 Z" fill="#fbbf24" opacity="0.95"/>
          <rect x="12" y="50" width="40" height="3" rx="1.5" fill="#ffffff"/>
        </svg>
        <p class="mt-3 text-xs font-bold uppercase tracking-wider text-slate-500">4. Rising peak</p>
      </div>

      <!-- Concept 5: Owl (education symbol) -->
      <div>
        <svg viewBox="0 0 64 64" style="width:100%;max-width:120px;display:block;">
          <rect width="64" height="64" rx="14" fill="#1d4ed8"/>
          <circle cx="32" cy="34" r="18" fill="none" stroke="#ffffff" stroke-width="3"/>
          <circle cx="25" cy="30" r="5" fill="#fbbf24"/>
          <circle cx="39" cy="30" r="5" fill="#fbbf24"/>
          <circle cx="25" cy="30" r="2" fill="#1d4ed8"/>
          <circle cx="39" cy="30" r="2" fill="#1d4ed8"/>
          <path d="M 30 40 L 32 43 L 34 40 Z" fill="#ffffff"/>
        </svg>
        <p class="mt-3 text-xs font-bold uppercase tracking-wider text-slate-500">5. Owl</p>
      </div>

    </div>

    <div class="mt-16 rounded-xl border border-slate-200 bg-slate-50 p-8">
      <h2 class="text-lg font-extrabold">In context</h2>
      <p class="mt-2 text-sm text-slate-600">Each concept at header size:</p>
      <div class="mt-6 space-y-6">
        {[
          { label: '1. Monogram', svg: '<rect width="64" height="64" rx="14" fill="#1d4ed8"/><text x="32" y="46" text-anchor="middle" font-family="Plus Jakarta Sans, sans-serif" font-size="40" font-weight="800" fill="#ffffff" letter-spacing="-2">P</text><circle cx="48" cy="20" r="4" fill="#fbbf24"/>' },
          { label: '2. Open book', svg: '<rect width="64" height="64" rx="14" fill="#1d4ed8"/><path d="M 12 48 L 12 30 Q 22 27 32 22 L 32 48 Z" fill="#ffffff"/><path d="M 52 48 L 52 30 Q 42 27 32 22 L 32 48 Z" fill="#ffffff"/><circle cx="32" cy="14" r="3" fill="#fbbf24"/>' },
          { label: '3. P + book', svg: '<rect width="64" height="64" rx="14" fill="#1d4ed8"/><path d="M 14 52 L 14 24 Q 14 20 18 20 L 30 20 Q 34 20 34 24 L 34 52" fill="none" stroke="#ffffff" stroke-width="5" stroke-linecap="round"/><circle cx="40" cy="16" r="3.5" fill="#fbbf24"/>' },
          { label: '4. Rising peak', svg: '<rect width="64" height="64" rx="14" fill="#1d4ed8"/><path d="M 32 12 L 52 50 L 12 50 Z" fill="none" stroke="#ffffff" stroke-width="3.5" stroke-linejoin="round"/><path d="M 32 12 L 42 30 L 22 30 Z" fill="#fbbf24"/>' },
          { label: '5. Owl', svg: '<rect width="64" height="64" rx="14" fill="#1d4ed8"/><circle cx="32" cy="34" r="18" fill="none" stroke="#ffffff" stroke-width="3"/><circle cx="25" cy="30" r="5" fill="#fbbf24"/><circle cx="39" cy="30" r="5" fill="#fbbf24"/>' },
        ].map(item => (
          <div class="flex items-center gap-4">
            <svg viewBox="0 0 64 64" style="width:32px;height:32px;flex-shrink:0;" set:html={item.svg}/>
            <span class="text-lg font-extrabold tracking-tight">Parhayi</span>
            <span class="text-xs text-slate-400">— {item.label}</span>
          </div>
        ))}
      </div>
    </div>
  </div>
</BaseLayout>
ASTRO

echo "  ✓ logo-concepts.astro created"

# Rebuild + serve
npm run build 2>&1 | tail -3

# Serve
pkill -f "http.server 4321" 2>/dev/null || true
rm -rf .preview && mkdir -p .preview
ln -sfn "$(pwd)/dist" .preview/My-edu-site

echo ""
echo "════════════════════════════════════════════"
echo "  Open this URL:"
echo "    http://localhost:4321/My-edu-site/logo-concepts/"
echo ""
echo "  You'll see 5 concepts side by side."
echo "  Tell me the number you like, or describe what you want."
echo "════════════════════════════════════════════"
echo ""

cd .preview
python3 -m http.server 4321