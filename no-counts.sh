#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Removing resource counts from cards"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  1. Homepage — remove counts from square cards
# ─────────────────────────────────────────────
cat > src/pages/index.astro <<'ASTRO'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { url } from '../lib/url';
import { BOARDS } from '../lib/boards';

const resources = [
  { href: '/notes',           icon: 'file-text',     label: 'Notes' },
  { href: '/past-papers',     icon: 'scroll-text',   label: 'Past Papers' },
  { href: '/guess-papers',    icon: 'sparkles',      label: 'Guess Papers' },
  { href: '/pairing-schemes', icon: 'list',          label: 'Pairing Schemes' },
  { href: '/quizzes',         icon: 'circle-help',   label: 'Quizzes' },
  { href: '/books',           icon: 'book-marked',   label: 'Books' },
  { href: '/gazettes',        icon: 'newspaper',     label: 'Gazettes' },
  { href: '/boards',          icon: 'graduation-cap',label: 'All Boards', tint: true },
];
---
<BaseLayout title="TaleemHub — Exam-specific revision for Pakistani students">
  <!-- ═══ HERO ═══ -->
  <section class="border-b border-slate-200">
    <div class="mx-auto max-w-[1200px] px-5 pt-20 pb-14 sm:px-7 sm:pt-24 sm:pb-16 lg:px-10 lg:pt-28 lg:pb-20">
      <div class="mx-auto max-w-3xl text-center">
        <div class="pill mx-auto">
          <span class="pill-dot"></span>
          Trusted by students across Pakistan
        </div>
        <h1 class="mt-6 text-[2.5rem] font-extrabold leading-[1.05] tracking-[-0.04em] text-slate-900 sm:text-[3.25rem] lg:text-[3.75rem]">
          Exam-specific revision,<br />
          made by trusted educators
        </h1>
        <p class="mx-auto mt-6 max-w-xl text-base leading-relaxed text-slate-600">
          Real expertise. Real results. Everything organised for your exact board and class.
        </p>

        <form action={url('/search')} method="get" role="search" class="mx-auto mt-9 flex max-w-xl items-stretch overflow-hidden rounded-xl border border-slate-300 bg-white transition-colors focus-within:border-[#1d4ed8]">
          <span class="grid w-12 shrink-0 place-items-center text-slate-400">
            <Icon name="search" size={18} strokeWidth={2.4} />
          </span>
          <input type="search" name="q" placeholder="Search notes, past papers, books..." class="min-w-0 flex-1 bg-transparent py-3.5 pr-3 text-sm text-slate-900 outline-none placeholder:text-slate-400" />
          <button type="submit" class="m-1.5 rounded-lg bg-[#1d4ed8] px-5 text-sm font-bold text-white transition-colors hover:bg-[#1e3a8a]">Search</button>
        </form>
      </div>
    </div>
  </section>

  <!-- ═══ WHY IT WORKS ═══ -->
  <section class="section">
    <div class="section-inner">
      <div class="mx-auto max-w-2xl text-center">
        <h2 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">Why it works</h2>
      </div>

      <div class="mx-auto mt-12 grid max-w-4xl grid-cols-1 gap-10 sm:grid-cols-3 sm:gap-8">
        <div class="flex flex-col items-start gap-4 sm:items-center sm:text-center">
          <span class="step-num">1</span>
          <h3 class="text-base font-extrabold tracking-tight text-slate-900">Revise only what you need</h3>
          <p class="text-sm leading-relaxed text-slate-600">
            Every resource is written specifically for your board — so you only revise what's on your paper.
          </p>
        </div>
        <div class="flex flex-col items-start gap-4 sm:items-center sm:text-center">
          <span class="step-num">2</span>
          <h3 class="text-base font-extrabold tracking-tight text-slate-900">Test yourself and check progress</h3>
          <p class="text-sm leading-relaxed text-slate-600">
            Practice with past papers and interactive quizzes so you walk into your exam hall confident.
          </p>
        </div>
        <div class="flex flex-col items-start gap-4 sm:items-center sm:text-center">
          <span class="step-num">3</span>
          <h3 class="text-base font-extrabold tracking-tight text-slate-900">Improve answer by answer</h3>
          <p class="text-sm leading-relaxed text-slate-600">
            See exactly which topics carry the most marks, from pairing schemes and examiner trends.
          </p>
        </div>
      </div>
    </div>
  </section>

  <!-- ═══ CHOOSE YOUR BOARD ═══ -->
  <section class="border-t border-slate-200 bg-slate-50 section">
    <div class="section-inner">
      <div class="mb-8 flex flex-wrap items-end justify-between gap-4">
        <div>
          <h2 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">Choose your board</h2>
          <p class="mt-3 text-base text-slate-600">Everything is organised for your specific board.</p>
        </div>
        <a href={url('/boards')} class="hidden items-center gap-1 text-sm font-bold text-[#1d4ed8] hover:text-[#1e3a8a] sm:inline-flex">
          All boards <Icon name="arrow-right" size={14} strokeWidth={2.6} />
        </a>
      </div>

      <div class="grid grid-cols-1 gap-2.5 sm:grid-cols-2">
        {BOARDS.map(b => (
          <a href={url(`/board/${b.slug}`)} class="row group">
            <span class="tile">
              <Icon name="graduation-cap" size={20} strokeWidth={2.2} />
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
  <section class="section">
    <div class="section-inner">
      <div class="mb-8">
        <h2 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">Browse by resource</h2>
        <p class="mt-3 text-base text-slate-600">Everything free, everything board-specific.</p>
      </div>

      <div class="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
        {resources.map(r => (
          <a href={url(r.href)} class:list={["sq-card group", r.tint && "sq-card-tint"]}>
            <span class="sq-card-icon">
              <Icon name={r.icon} size={20} strokeWidth={2.2} />
            </span>
            <div class="sq-card-body">
              <span class="sq-card-label">{r.label}</span>
            </div>
          </a>
        ))}
      </div>
    </div>
  </section>

  <!-- ═══ TRUST STRIP ═══ -->
  <section class="border-y border-slate-200 bg-slate-50 section">
    <div class="section-inner">
      <div class="mx-auto grid max-w-3xl grid-cols-2 gap-6 sm:grid-cols-4">
        {[
          { value: '6', label: 'Boards covered' },
          { value: '9–12', label: 'Classes' },
          { value: '7', label: 'Resource types' },
          { value: 'Free', label: 'Forever' },
        ].map(s => (
          <div class="text-center">
            <div class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">{s.value}</div>
            <div class="mt-1.5 text-xs font-semibold uppercase tracking-wider text-slate-500">{s.label}</div>
          </div>
        ))}
      </div>
    </div>
  </section>

  <!-- ═══ WHAT IS TALEEMHUB? ═══ -->
  <section class="section">
    <div class="section-inner">
      <div class="mx-auto max-w-3xl">
        <h2 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">What is TaleemHub?</h2>
        <div class="mt-6 space-y-4 text-base leading-relaxed text-slate-600">
          <p>
            TaleemHub is an online revision platform that helps Pakistani students across Class 9 to 12 prepare for their board exams. Students gain access to resources written for their specific board and class — from notes and past papers to guess papers and pairing schemes.
          </p>
          <p>
            Every resource is matched to your board's specification. That means you focus on exactly what's on your paper, not what might have been on someone else's.
          </p>
          <p>
            Teachers can find ready-to-use classroom materials, and students can revise from any device — offline or online.
          </p>
        </div>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ homepage — counts removed"

# ─────────────────────────────────────────────
#  2. /boards — remove counts
# ─────────────────────────────────────────────
cat > src/pages/boards.astro <<'ASTRO'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { url } from '../lib/url';
import { BOARDS } from '../lib/boards';
---
<BaseLayout title="All Boards — TaleemHub" description="Browse notes, past papers, guess papers and result gazettes for all Pakistani boards: Punjab, Federal, KPK, Sindh, Balochistan, AJK.">
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">Boards</span>
      </nav>
      <div class="max-w-2xl">
        <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">All boards</h1>
        <p class="mt-3 text-base leading-relaxed text-slate-600">
          Pick your board to find every note, past paper, guess paper and result gazette tailored to your syllabus.
        </p>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-16">
    <div class="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
      {BOARDS.map(b => (
        <a href={url(`/board/${b.slug}`)} class="sq-card group">
          <span class="sq-card-icon">
            <Icon name="graduation-cap" size={20} strokeWidth={2.2} />
          </span>
          <div class="sq-card-body">
            <span class="sq-card-label">{b.name}</span>
            <span class="sq-card-sub">Board</span>
          </div>
        </a>
      ))}
    </div>
  </div>
</BaseLayout>
ASTRO
echo "  ✓ /boards — counts removed"

# ─────────────────────────────────────────────
#  3. /board/[board] — remove class counts
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re

p = pathlib.Path('src/pages/board/[board]/index.astro')
s = p.read_text()

# Remove the count calculation + display in class rows
old = re.compile(
    r'\{classes\.map\(c => \{[\s\S]*?<div class="row-title">Class \{c\}</div>[\s\S]*?<div class="row-sub">\{count\} \{count === 1 \? \'item\' : \'items\'\}</div>[\s\S]*?\}\)\(\)\}',
    re.DOTALL
)

# Simpler: replace the whole mapped section with a simpler version
new_section = '''{classes.map(c => (
          <a href={url(`/board/${slug}/class-${c}`)} class="row group">
            <span class="tile"><Icon name="graduation-cap" size={20} strokeWidth={2.2} /></span>
            <div class="min-w-0 flex-1">
              <div class="row-title">Class {c}</div>
            </div>
            <Icon name="arrow-right" size={15} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
          </a>
        ))}'''

# Find the entire grid block for classes
grid_pattern = re.compile(
    r'<div class="grid grid-cols-1 gap-2\.5 sm:grid-cols-2 lg:grid-cols-4">[\s\S]*?(?=</div>\s*</div>\s*\{info)',
    re.DOTALL
)

if grid_pattern.search(s):
    s = grid_pattern.sub('<div class="grid grid-cols-1 gap-2.5 sm:grid-cols-2 lg:grid-cols-4">\n        ' + new_section + '\n      ', s, count=1)
    p.write_text(s)
    print('  ✓ /board/[board] — class counts removed')
else:
    print('  · /board/[board] — pattern not found, trying simpler approach')

    # Fallback: just strip the row-sub div with item counts
    s = re.sub(r'<div class="row-sub">\{count\} \{count === 1 \? .item. : .items.\}</div>\s*', '', s)
    p.write_text(s)
    print('  ✓ /board/[board] — counts stripped (fallback)')
PY

# ─────────────────────────────────────────────
#  4. /board/[board]/[class] — remove item counts from rows
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re

p = pathlib.Path('src/pages/board/[board]/[class]/index.astro')
s = p.read_text()

# Remove counts from resource-type rows
s = re.sub(
    r'<div class="row-sub">\{s\.count\} \{s\.count === 1 \? .item. : .items.\}</div>\s*',
    '',
    s
)

# Remove subject count pills block
pills_pattern = re.compile(
    r'<div class="mt-1 flex flex-wrap items-center gap-1\.5">[\s\S]*?</div>\s*</div>\s*<Icon name="arrow-right"',
    re.DOTALL
)
if pills_pattern.search(s):
    s = pills_pattern.sub('<Icon name="arrow-right"', s)

p.write_text(s)
print('  ✓ /board/[board]/[class] — item counts removed')
PY

# ─────────────────────────────────────────────
#  5. Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -6

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Push:"
echo ""
echo "    git add ."
echo "    git commit -m 'Remove resource counts from all cards'"
echo "    git push"
echo ""
echo "  Cards now show:"
echo "    · Board rows  → board name only"
echo "    · Class rows  → 'Class 9' only"
echo "    · Subject rows → subject name only"
echo "    · Square cards → label only"
echo ""
echo "  Cleaner, less noise, same navigation."
echo "════════════════════════════════════════════"