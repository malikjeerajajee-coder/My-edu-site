#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Reverting Qwen's changes"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  1. Delete files Qwen created
# ─────────────────────────────────────────────
rm -f public/polish.css
rm -f public/search-enhance.js
rm -f upgrade_design.py
rm -f search-index.json
rm -rf scripts
echo "  Deleted: polish.css, search-enhance.js, upgrade_design.py, search-index.json, scripts/"

# ─────────────────────────────────────────────
#  2. Remove injected tags from layouts/components
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re
for base in ['src/layouts', 'src/components']:
    for p in pathlib.Path(base).glob('*.astro'):
        s = p.read_text()
        orig = s
        s = re.sub(r'<link[^>]*polish\.css[^>]*/?>\s*', '', s)
        s = re.sub(r'<script[^>]*search-enhance\.js[^>]*>\s*</script>\s*', '', s)
        # Handle literal backslash-n leftover from bash single-quote quirk
        s = s.replace('\\n<script src="/My-edu-site/search-enhance.js" defer></script>', '')
        s = s.replace('<link rel="stylesheet" href="/My-edu-site/polish.css">\\n', '')
        s = s.replace('\\n<script src="/My-edu-site/search-enhance.js" defer></script>', '')
        if s != orig:
            p.write_text(s)
            print(f'  cleaned {p}')
PY

# ─────────────────────────────────────────────
#  3. Revert color #2563eb → #1d4ed8
# ─────────────────────────────────────────────
find src public -type f \( -name '*.astro' -o -name '*.css' -o -name '*.html' \) -exec sed -i 's/#2563eb/#1d4ed8/g' {} + 2>/dev/null || true
echo "  Reverted #2563eb → #1d4ed8 (our brand blue)"

# ─────────────────────────────────────────────
#  4. Revert package.json build script
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, json
p = pathlib.Path('package.json')
if p.exists():
    data = json.loads(p.read_text())
    scripts = data.get('scripts', {})
    if 'build' in scripts:
        scripts['build'] = 'astro build && node fix-links.mjs'
        data['scripts'] = scripts
        p.write_text(json.dumps(data, indent=2) + '\n')
        print('  reverted package.json → astro build && node fix-links.mjs')
PY

# ─────────────────────────────────────────────
#  5. Regenerate index.astro — clean, Qwen-free
# ─────────────────────────────────────────────
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
  <!-- ═══ HERO ═══ -->
  <section class="relative overflow-hidden border-b border-slate-200" style="background: linear-gradient(180deg, #f5f8ff 0%, #fbfcfe 100%);">
    <div class="pointer-events-none absolute -right-40 -top-40 h-[440px] w-[440px] rounded-full" style="background: radial-gradient(closest-side, rgba(29,78,216,0.08), transparent);"></div>

    <div class="relative mx-auto max-w-[1320px] px-4 pt-16 pb-16 sm:px-6 sm:pt-24 sm:pb-20 lg:px-10 lg:pt-28 lg:pb-24">
      <div class="max-w-3xl">
        <div class="inline-flex items-center gap-2 rounded-full border border-slate-200 bg-white px-3 py-1 text-xs font-bold uppercase tracking-wider text-slate-600 shadow-sm">
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

        <form action={url('/search')} method="get" role="search" class="mt-9 flex max-w-xl items-center gap-2 rounded-xl border border-slate-300 bg-white p-1.5 pl-4 shadow-sm transition-colors focus-within:border-[#1d4ed8] focus-within:ring-4 focus-within:ring-[#eff4ff]">
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

  <!-- ═══ CHOOSE YOUR BOARD ═══ -->
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

  <!-- ═══ BROWSE BY RESOURCE ═══ -->
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

  <!-- ═══ TRUST STRIP ═══ -->
  <section class="section">
    <div class="section-inner">
      <div class="grid grid-cols-2 gap-6 rounded-2xl border border-slate-200 bg-white p-8 shadow-sm sm:grid-cols-4 sm:p-10">
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

echo "  Regenerated src/pages/index.astro (Qwen-free)"

# ─────────────────────────────────────────────
#  6. Verify no Qwen artifacts remain
# ─────────────────────────────────────────────
echo ""
echo "Verifying cleanup..."
LEFTOVERS=$(grep -rln "polish.css\|search-enhance.js\|Popular:\|Why top students\|Curated by Pakistan\|Real Results from Real" src/ 2>/dev/null || true)
if [ -z "$LEFTOVERS" ]; then
    echo "  ✓ No Qwen artifacts remain in src/"
else
    echo "  ✗ Still found in:"
    echo "$LEFTOVERS" | sed 's/^/    /'
fi

# ─────────────────────────────────────────────
#  7. Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -10

echo ""
echo "════════════════════════════════════════════"
echo "  Reverted. Push:"
echo ""
echo "    git add ."
echo "    git commit -m 'Revert Qwen design changes'"
echo "    git push"
echo ""
echo "  Then clear browser cache."
echo "════════════════════════════════════════════"