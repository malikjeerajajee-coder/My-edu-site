#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Homepage: boards + content types"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  1. Global CSS — no shadows (reinforced)
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib
p = pathlib.Path('src/styles/global.css')
s = p.read_text()

# Ensure the shadow kill rule exists
if 'box-shadow: none !important' not in s:
    # Insert after body block
    marker = 'a { color: inherit; text-decoration: none; }'
    s = s.replace(marker, '*, *::before, *::after { box-shadow: none !important; }\n\n' + marker)

p.write_text(s)
print('  ✓ shadow kill enforced')
PY

# ─────────────────────────────────────────────
#  2. Rebuild homepage with cards
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
  { href: '/gazettes',        icon: 'newspaper',     label: 'Result Gazettes', count: gazettes.length },
];
---
<BaseLayout title="TaleemHub — Exam-specific revision for Pakistani students">
  <!-- ═══ HERO ═══ -->
  <section class="border-b border-slate-200">
    <div class="mx-auto max-w-[1200px] px-5 pt-20 pb-16 sm:px-7 sm:pt-28 sm:pb-20 lg:px-10 lg:pt-32 lg:pb-24">
      <div class="mx-auto max-w-3xl text-center">
        <div class="pill mx-auto">
          <span class="pill-dot"></span>
          Trusted by students across Pakistan
        </div>
        <h1 class="mt-7 text-[2.5rem] font-extrabold leading-[1.05] tracking-[-0.04em] text-slate-900 sm:text-[3.5rem] lg:text-[4rem]">
          Exam-specific revision,<br />
          made by trusted educators
        </h1>
        <p class="mx-auto mt-7 max-w-xl text-base leading-relaxed text-slate-600 sm:text-lg">
          Real expertise. Real results. Everything you need — notes, past papers, guess papers and pairing schemes — organised for your exact board and class.
        </p>

        <form action={url('/search')} method="get" role="search" class="mx-auto mt-10 flex max-w-xl items-center gap-2 rounded-lg border border-slate-300 bg-white p-1.5 pl-4 transition-colors focus-within:border-[#1d4ed8]">
          <Icon name="search" size={18} strokeWidth={2.4} class="shrink-0 text-slate-400" />
          <input type="search" name="q" placeholder="Search notes, past papers, books..." class="min-w-0 flex-1 bg-transparent py-3 text-sm text-slate-900 outline-none placeholder:text-slate-400" />
          <button type="submit" class="btn btn-primary">Search</button>
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

      <div class="mx-auto mt-14 grid max-w-4xl grid-cols-1 gap-12 sm:grid-cols-3 sm:gap-10">
        <div class="flex flex-col items-start gap-5 sm:items-center sm:text-center">
          <span class="step-num">1</span>
          <h3 class="text-lg font-extrabold tracking-tight text-slate-900">Revise only what you need</h3>
          <p class="text-sm leading-relaxed text-slate-600">
            Every resource is written specifically for your board — so you only revise what's on your paper.
          </p>
        </div>
        <div class="flex flex-col items-start gap-5 sm:items-center sm:text-center">
          <span class="step-num">2</span>
          <h3 class="text-lg font-extrabold tracking-tight text-slate-900">Test yourself and check progress</h3>
          <p class="text-sm leading-relaxed text-slate-600">
            Practice with past papers and interactive quizzes so you walk into your exam hall confident.
          </p>
        </div>
        <div class="flex flex-col items-start gap-5 sm:items-center sm:text-center">
          <span class="step-num">3</span>
          <h3 class="text-lg font-extrabold tracking-tight text-slate-900">Improve answer by answer</h3>
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
      <div class="mb-10 flex flex-wrap items-end justify-between gap-4">
        <div>
          <h2 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">Choose your board</h2>
          <p class="mt-3 text-base text-slate-600">Everything is organised for your specific board.</p>
        </div>
        <a href={url('/boards')} class="hidden items-center gap-1 text-sm font-bold text-[#1d4ed8] hover:text-[#1e3a8a] sm:inline-flex">
          All boards <Icon name="arrow-right" size={14} strokeWidth={2.6} />
        </a>
      </div>

      <div class="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
        {BOARDS.map(b => (
          <a href={url(`/board/${b.slug}`)} class="group rounded-xl border border-slate-200 bg-white p-6 transition-colors hover:border-[#1d4ed8]">
            <div class="flex items-start justify-between">
              <span class="tile">
                <Icon name="graduation-cap" size={20} strokeWidth={2.2} />
              </span>
              <Icon name="arrow-up-right" size={18} strokeWidth={2.4} class="text-slate-300 transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
            </div>
            <div class="mt-5 text-xl font-extrabold tracking-tight text-slate-900">{b.name}</div>
            <div class="mt-1 text-sm text-slate-500">{counts[b.slug] || 0} {counts[b.slug] === 1 ? 'resource' : 'resources'}</div>
          </a>
        ))}
      </div>
    </div>
  </section>

  <!-- ═══ BROWSE BY RESOURCE ═══ -->
  <section class="section">
    <div class="section-inner">
      <div class="mb-10">
        <h2 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">Browse by resource</h2>
        <p class="mt-3 text-base text-slate-600">Seven content types — all free, all board-specific.</p>
      </div>

      <div class="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
        {resources.map(r => (
          <a href={url(r.href)} class="group rounded-xl border border-slate-200 bg-white p-5 transition-colors hover:border-[#1d4ed8]">
            <div class="flex items-start justify-between">
              <span class="tile">
                <Icon name={r.icon} size={20} strokeWidth={2.2} />
              </span>
              <span class="text-lg font-extrabold tracking-tight text-slate-900">{r.count}</span>
            </div>
            <div class="mt-4 text-[15px] font-extrabold tracking-tight text-slate-900">{r.label}</div>
          </a>
        ))}
        <!-- All boards tile -->
        <a href={url('/boards')} class="group rounded-xl border border-slate-200 bg-white p-5 transition-colors hover:border-[#1d4ed8]">
          <div class="flex items-start justify-between">
            <span class="tile">
              <Icon name="graduation-cap" size={20} strokeWidth={2.2} />
            </span>
            <span class="text-lg font-extrabold tracking-tight text-slate-900">6</span>
          </div>
          <div class="mt-4 text-[15px] font-extrabold tracking-tight text-slate-900">All Boards</div>
        </a>
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

echo "  ✓ homepage rebuilt — boards + resource cards"

# ─────────────────────────────────────────────
#  3. Sweep any lingering shadow classes
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re

pattern = re.compile(r'\b(shadow-sm|shadow-md|shadow-lg|shadow-xl|shadow-2xl|shadow-inner|shadow-none)\b')
count = 0
for astro in pathlib.Path('src').rglob('*.astro'):
    s = astro.read_text()
    orig = s
    s = pattern.sub('', s)
    s = re.sub(r'\s+', ' ', s) if s != orig else s
    if s != orig:
        astro.write_text(s)
        count += 1
print(f'  ✓ {count} files — shadow classes stripped')
PY

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
echo "    git commit -m 'Homepage: boards + resource cards, no shadows'"
echo "    git push"
echo ""
echo "  Homepage sections (top → bottom):"
echo "    1. Hero (centered, pill badge, search)"
echo "    2. Why it works (3 numbered steps)"
echo "    3. Choose your board (6 card tiles)"
echo "    4. Browse by resource (8 cards: 7 resource types + All Boards)"
echo "    5. Trust strip (4 stats)"
echo "    6. What is TaleemHub? (FAQ content)"
echo ""
echo "  Cards use 1px borders only — zero shadows anywhere."
echo "════════════════════════════════════════════"