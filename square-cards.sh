#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Adding square cards where they belong"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  1. Add square-card component style
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib
p = pathlib.Path('src/styles/global.css')
s = p.read_text()

# Replace the .res-card block with a square variant
old_block_start = s.find('.res-card {')
old_block_end = s.find('.res-card-sub {')

if old_block_start != -1 and old_block_end != -1:
    # Find end of res-card-sub rule
    end_of_sub = s.find('}', old_block_end + len('.res-card-sub {'))
    if end_of_sub != -1:
        end_of_sub += 1
        # Remove everything from .res-card to end of res-card-sub
        s = s[:old_block_start] + s[end_of_sub:]

# Add the new square card style
if '.sq-card' not in s:
    s = s.rstrip() + '''

/* ═══ Square card — grid navigation tiles ═══ */
.sq-card {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  aspect-ratio: 1 / 1;
  padding: 1.125rem;
  background: var(--surface);
  border: 1px solid #e8ebf1;
  border-radius: 16px;
  transition: border-color .15s ease;
}
@media (hover: hover) {
  .sq-card:hover { border-color: var(--brand); }
}

.sq-card-icon {
  display: grid;
  place-items: center;
  width: 2.5rem;
  height: 2.5rem;
  border-radius: 11px;
  background: var(--brand-tint);
  color: var(--brand);
  flex-shrink: 0;
  transition: background-color .15s ease, color .15s ease;
}
@media (hover: hover) {
  .sq-card:hover .sq-card-icon {
    background: var(--brand);
    color: #ffffff;
  }
}

.sq-card-body {
  display: flex;
  flex-direction: column;
  gap: 0.125rem;
}
.sq-card-count {
  font-size: 1.75rem;
  font-weight: 800;
  letter-spacing: -0.04em;
  color: var(--ink);
  line-height: 1;
}
.sq-card-count-muted {
  font-size: 1.75rem;
  font-weight: 800;
  letter-spacing: -0.04em;
  color: var(--subtle);
  line-height: 1;
}
.sq-card-label {
  font-size: 0.875rem;
  font-weight: 800;
  letter-spacing: -0.015em;
  color: var(--ink);
  line-height: 1.2;
}
.sq-card-sub {
  font-size: 0.6875rem;
  font-weight: 600;
  color: var(--muted);
  text-transform: uppercase;
  letter-spacing: 0.03em;
}

/* Square card — alternate neutral/blue variant */
.sq-card-tint {
  background: var(--brand-tint);
  border-color: var(--brand-line);
}
.sq-card-tint .sq-card-icon {
  background: #ffffff;
}
.sq-card-tint .sq-card-count { color: var(--brand-deep); }
.sq-card-tint .sq-card-label { color: var(--brand-deep); }
.sq-card-tint .sq-card-sub   { color: var(--brand); }
'''
    print('  ✓ .sq-card added to global.css')

p.write_text(s)
PY

# ─────────────────────────────────────────────
#  2. Rewrite homepage resource section with square cards
# ─────────────────────────────────────────────
cat > src/pages/index.astro <<'ASTRO'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { url } from '../lib/url';
import { BOARDS } from '../lib/boards';
import { getBoardCounts } from '../lib/boardContent';
import { getCollection } from 'astro:content';

const counts = await getBoardCounts();

const [notes, quizzes, books, gazettes, pastPapers, guessPapers, pairingSchemes] = await Promise.all([
  getCollection('notes'),
  getCollection('quizzes'),
  getCollection('books'),
  getCollection('gazettes'),
  getCollection('pastPapers'),
  getCollection('guessPapers'),
  getCollection('pairingSchemes'),
]);

const resources = [
  { href: '/notes',           icon: 'file-text',     label: 'Notes',           count: notes.length },
  { href: '/past-papers',     icon: 'scroll-text',   label: 'Past Papers',     count: pastPapers.length },
  { href: '/guess-papers',    icon: 'sparkles',      label: 'Guess Papers',    count: guessPapers.length },
  { href: '/pairing-schemes', icon: 'list',          label: 'Pairing Schemes', count: pairingSchemes.length },
  { href: '/quizzes',         icon: 'circle-help',   label: 'Quizzes',         count: quizzes.length },
  { href: '/books',           icon: 'book-marked',   label: 'Books',           count: books.length },
  { href: '/gazettes',        icon: 'newspaper',     label: 'Gazettes',        count: gazettes.length },
  { href: '/boards',          icon: 'graduation-cap',label: 'All Boards',      count: BOARDS.length, tint: true },
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
              <div class="row-sub">{counts[b.slug] || 0} {counts[b.slug] === 1 ? 'resource' : 'resources'}</div>
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
              <span class:list={[r.count > 0 ? 'sq-card-count' : 'sq-card-count-muted']}>{r.count}</span>
              <span class="sq-card-label">{r.label}</span>
              <span class="sq-card-sub">{r.count === 1 ? 'item' : 'items'}</span>
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

echo "  ✓ homepage — resource section uses square cards"

# ─────────────────────────────────────────────
#  3. Also make the /boards page a square-card grid
# ─────────────────────────────────────────────
cat > src/pages/boards.astro <<'ASTRO'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { url } from '../lib/url';
import { BOARDS } from '../lib/boards';
import { getBoardCounts } from '../lib/boardContent';

const counts = await getBoardCounts();
---
<BaseLayout title="All Boards — TaleemHub" description="Browse notes, past papers, guess papers and result gazettes for all Pakistani boards: Punjab, Federal, KPK, Sindh, Balochistan, AJK.">
  <!-- Page header -->
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

  <!-- Board square cards -->
  <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-16">
    <div class="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
      {BOARDS.map(b => (
        <a href={url(`/board/${b.slug}`)} class="sq-card group">
          <span class="sq-card-icon">
            <Icon name="graduation-cap" size={20} strokeWidth={2.2} />
          </span>
          <div class="sq-card-body">
            <span class="sq-card-count">{counts[b.slug] || 0}</span>
            <span class="sq-card-label">{b.name}</span>
            <span class="sq-card-sub">Board</span>
          </div>
        </a>
      ))}
    </div>
  </div>
</BaseLayout>
ASTRO

echo "  ✓ /boards — square card grid"

# ─────────────────────────────────────────────
#  4. Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -6

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Push:"
echo ""
echo "    git add ."
echo "    git commit -m 'Add square cards for grid navigation'"
echo "    git push"
echo ""
echo "  Design system now uses:"
echo "    · ROW cards (horizontal) — for lists:"
echo "        board picker, class picker, subject picker,"
echo "        notes, quizzes, books, papers, related items"
echo "    · SQUARE cards — for grid navigation:"
echo "        homepage 'Browse by resource' (8 tiles)"
echo "        /boards page (6 board tiles)"
echo ""
echo "  Square card layout:"
echo "    ┌──────────────┐"
echo "    │ 📄           │"
echo "    │              │"
echo "    │              │"
echo "    │  5           │"
echo "    │  Notes       │"
echo "    │  ITEMS       │"
echo "    └──────────────┘"
echo "    · aspect-ratio: 1/1"
echo "    · 16px radius"
echo "    · 18px padding"
echo "    · Icon top-left, count + label + sub at bottom"
echo "    · 'All Boards' tile uses blue tint variant"
echo "════════════════════════════════════════════"