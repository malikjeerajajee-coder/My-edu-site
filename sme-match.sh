#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Matching Save My Exams structure"
echo "════════════════════════════════════════════"
echo ""

# ═══════════════════════════════════════════════
#  1. GLOBAL CSS — SME-grade flat design
# ═══════════════════════════════════════════════
cat > src/styles/global.css <<'CSS'
@import "tailwindcss";

@theme {
  --font-sans: "Plus Jakarta Sans", ui-sans-serif, system-ui, -apple-system, sans-serif;
}

:root {
  --brand: #1d4ed8;
  --brand-dark: #1e3a8a;
  --brand-deep: #172554;
  --brand-tint: #eff4ff;
  --brand-line: #c7d7fe;

  --ink: #0f172a;
  --body: #334155;
  --muted: #64748b;
  --subtle: #94a3b8;

  --surface: #ffffff;
  --surface-2: #f8fafc;
  --surface-3: #f1f5f9;
  --bg: #ffffff;

  --line: #e5e9f0;
  --line-2: #cbd5e1;
}

html {
  -webkit-text-size-adjust: 100%;
  scroll-behavior: smooth;
}

body {
  font-family: var(--font-sans);
  background: var(--bg);
  color: var(--body);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  overflow-x: hidden;
  font-feature-settings: "ss01", "cv11";
}

a { color: inherit; text-decoration: none; }
button { font-family: inherit; cursor: pointer; }
input, select, textarea { font-family: inherit; }

h1, h2, h3, h4 {
  color: var(--ink);
  letter-spacing: -0.03em;
  font-weight: 800;
  line-height: 1.15;
}

/* ═══ FLAT — zero shadows anywhere ═══ */
*, *::before, *::after { box-shadow: none !important; }

/* ═══ SME-style pill badge ═══ */
.pill {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.4rem 0.9rem;
  border-radius: 999px;
  border: 1px solid var(--line);
  background: var(--surface);
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--muted);
  letter-spacing: 0.01em;
}
.pill-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--brand);
}

/* ═══ Card row — SME-style horizontal list ═══ */
.row {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.1rem 1.25rem;
  background: var(--surface);
  border: 1px solid var(--line);
  border-radius: 10px;
  transition: border-color .15s ease, background-color .15s ease;
}
.row:hover {
  border-color: var(--brand);
  background: var(--brand-tint);
}

/* ═══ Icon tile ═══ */
.tile {
  display: grid;
  place-items: center;
  width: 2.5rem;
  height: 2.5rem;
  border-radius: 8px;
  background: var(--brand-tint);
  color: var(--brand);
  flex-shrink: 0;
  transition: background-color .15s ease, color .15s ease;
}
.row:hover .tile {
  background: var(--brand);
  color: #ffffff;
}

/* ═══ Buttons ═══ */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.75rem 1.25rem;
  border-radius: 8px;
  font-weight: 700;
  font-size: 0.875rem;
  letter-spacing: -0.005em;
  transition: background-color .15s ease, border-color .15s ease, color .15s ease;
}
.btn-primary {
  background: var(--brand);
  color: #ffffff !important;
  border: 1px solid var(--brand);
}
.btn-primary:hover {
  background: var(--brand-dark);
  border-color: var(--brand-dark);
}
.btn-outline {
  background: var(--surface);
  color: var(--ink);
  border: 1px solid var(--line-2);
}
.btn-outline:hover {
  border-color: var(--brand);
  color: var(--brand);
}

/* ═══ Force white text on colored buttons ═══ */
a[class*="bg-[#1d4ed8]"],
a[class*="bg-[#1e3a8a]"],
button[class*="bg-[#1d4ed8]"] {
  color: #ffffff !important;
}
a[class*="bg-[#1d4ed8]"] svg,
a[class*="bg-[#1e3a8a]"] svg,
button[class*="bg-[#1d4ed8]"] svg {
  color: #ffffff !important;
  stroke: #ffffff !important;
}

/* ═══ Section rhythm ═══ */
.section { padding: 4rem 0; }
@media (min-width: 768px) { .section { padding: 5.5rem 0; } }

.section-inner {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1.25rem;
}
@media (min-width: 640px) { .section-inner { padding: 0 1.75rem; } }
@media (min-width: 1024px) { .section-inner { padding: 0 2.5rem; } }

/* ═══ SME numbered step — circular blue badge ═══ */
.step-num {
  display: inline-grid;
  place-items: center;
  width: 2.25rem;
  height: 2.25rem;
  border-radius: 50%;
  background: var(--brand);
  color: #ffffff;
  font-weight: 800;
  font-size: 0.875rem;
  flex-shrink: 0;
}

/* ═══ SME feature list — checkmark bullets ═══ */
.feature-list {
  display: grid;
  gap: 0.75rem;
}
.feature-list li {
  display: flex;
  align-items: flex-start;
  gap: 0.75rem;
  font-size: 0.9375rem;
  color: var(--body);
}
.feature-list li::before {
  content: "";
  flex-shrink: 0;
  margin-top: 0.35rem;
  width: 1rem;
  height: 1rem;
  background: var(--brand);
  color: #ffffff;
  border-radius: 50%;
  background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='3.5' stroke-linecap='round' stroke-linejoin='round'><path d='M20 6 9 17l-5-5'/></svg>");
  background-size: 60%;
  background-position: center;
  background-repeat: no-repeat;
}

/* ═══ Focus rings ═══ */
input:focus-visible, button:focus-visible, a:focus-visible, [tabindex]:focus-visible {
  outline: 2px solid var(--brand);
  outline-offset: 2px;
}

/* ═══ Prose ═══ */
.prose { font-size: 1rem; line-height: 1.75; color: var(--body); }
.prose h1, .prose h2, .prose h3 { color: var(--ink); font-weight: 800; letter-spacing: -0.02em; }
.prose h2 { font-size: 1.25rem; margin: 2rem 0 0.75rem; padding-bottom: 0.5rem; border-bottom: 1px solid var(--line); }
.prose h3 { font-size: 1.05rem; margin: 1.5rem 0 0.5rem; }
.prose h2:first-child, .prose h3:first-child { margin-top: 0; }
.prose p { margin-bottom: 1rem; }
.prose ul, .prose ol { padding-left: 1.25rem; margin-bottom: 1rem; }
.prose li { margin-bottom: 0.375rem; }
.prose li::marker { color: var(--brand); }
.prose code { background: var(--brand-tint); color: var(--brand-deep); padding: 0.125rem 0.375rem; border-radius: 6px; font-size: 0.85em; font-weight: 600; }
.prose strong { font-weight: 700; color: var(--ink); }
.prose table { width: 100%; border-collapse: collapse; margin: 1rem 0; font-size: 0.875rem; border: 1px solid var(--line); border-radius: 10px; overflow: hidden; }
.prose th { background: var(--surface-2); text-align: left; padding: 0.625rem 0.75rem; font-weight: 700; color: var(--ink); border-bottom: 1px solid var(--line); }
.prose td { padding: 0.625rem 0.75rem; border-top: 1px solid var(--line); }
.prose a { color: var(--brand); text-decoration: underline; text-underline-offset: 2px; }

/* ═══ Animations ═══ */
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(6px); }
  to   { opacity: 1; transform: translateY(0); }
}
.animate-in { animation: fadeUp .4s cubic-bezier(.16, 1, .3, 1) both; }

@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: .01ms !important;
    transition-duration: .01ms !important;
  }
}
CSS

echo "  global.css — SME flat design system"

# ═══════════════════════════════════════════════
#  2. Homepage — SME's exact structure
# ═══════════════════════════════════════════════
cat > src/pages/index.astro <<'ASTRO'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { url } from '../lib/url';
import { BOARDS } from '../lib/boards';
import { getBoardCounts } from '../lib/boardContent';

const counts = await getBoardCounts();
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
            Enjoy the relief and reassurance that every revision guide is written specifically for your board — so you only revise what you need to know.
          </p>
        </div>
        <div class="flex flex-col items-start gap-5 sm:items-center sm:text-center">
          <span class="step-num">2</span>
          <h3 class="text-lg font-extrabold tracking-tight text-slate-900">Test yourself and check progress</h3>
          <p class="text-sm leading-relaxed text-slate-600">
            Feel empowered and confident going into exams knowing that you've covered all the topics and have a greater understanding of each subject.
          </p>
        </div>
        <div class="flex flex-col items-start gap-5 sm:items-center sm:text-center">
          <span class="step-num">3</span>
          <h3 class="text-lg font-extrabold tracking-tight text-slate-900">Improve answer by answer</h3>
          <p class="text-sm leading-relaxed text-slate-600">
            Gain certainty that you're answering questions that get maximum marks, from model answers for every question, explained by an expert examiner.
          </p>
        </div>
      </div>
    </div>
  </section>

  <!-- ═══ WHAT ARE YOU STUDYING? ═══ -->
  <section class="border-t border-slate-200 bg-slate-50 section">
    <div class="section-inner">
      <div class="mx-auto max-w-2xl text-center">
        <h2 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">What are you studying?</h2>
        <p class="mt-4 text-base text-slate-600">Choose your board to get started.</p>
      </div>

      <div class="mx-auto mt-12 grid max-w-3xl grid-cols-1 gap-3 sm:grid-cols-2">
        {BOARDS.map(b => (
          <a href={url(`/board/${b.slug}`)} class="row group">
            <span class="tile">
              <Icon name="graduation-cap" size={20} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <div class="text-[15px] font-extrabold tracking-tight text-slate-900">{b.name}</div>
              <div class="text-xs text-slate-500">{counts[b.slug] || 0} {counts[b.slug] === 1 ? 'resource' : 'resources'}</div>
            </div>
            <Icon name="arrow-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
          </a>
        ))}
      </div>
    </div>
  </section>

  <!-- ═══ GET STARTED — FOR FREE ═══ -->
  <section class="section border-t border-slate-200">
    <div class="section-inner">
      <div class="mx-auto max-w-3xl text-center">
        <h2 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">Get started — for free</h2>
        <p class="mt-4 text-base text-slate-600">
          No sign-up required. Every resource on TaleemHub is free, forever.
        </p>
        <div class="mt-8 flex flex-wrap items-center justify-center gap-3">
          <a href={url('/boards')} class="btn btn-primary">Browse boards</a>
          <a href={url('/notes')} class="btn btn-outline">Browse notes</a>
        </div>
      </div>
    </div>
  </section>

  <!-- ═══ MEET OUR EXPERTS ═══ -->
  <section class="section border-t border-slate-200 bg-slate-50">
    <div class="section-inner">
      <div class="mx-auto max-w-3xl text-center">
        <h2 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">Meet our experts</h2>
        <p class="mt-5 text-base leading-relaxed text-slate-600">
          Our revision resources are written by teachers and examiners. That means notes, questions by topic and worked solutions that show exactly what the examiners for each specific exam are looking for.
        </p>
        <p class="mt-4 text-base font-bold text-slate-900">We work harder so you can study smarter.</p>
      </div>

      <div class="mx-auto mt-12 grid max-w-3xl grid-cols-2 gap-4 sm:grid-cols-4">
        {[
          { value: '6', label: 'Boards' },
          { value: '9–12', label: 'Classes' },
          { value: '7', label: 'Resource types' },
          { value: 'Free', label: 'Forever' },
        ].map(s => (
          <div class="text-center rounded-lg border border-slate-200 bg-white p-6">
            <div class="text-3xl font-extrabold tracking-tight text-slate-900">{s.value}</div>
            <div class="mt-1.5 text-xs font-semibold uppercase tracking-wider text-slate-500">{s.label}</div>
          </div>
        ))}
      </div>
    </div>
  </section>

  <!-- ═══ WHAT IS TALEEMHUB? ═══ -->
  <section class="section border-t border-slate-200">
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

echo "  homepage — SME structure"

# ═══════════════════════════════════════════════
#  3. Rebuild
# ═══════════════════════════════════════════════
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -8

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Push:"
echo ""
echo "    git add ."
echo "    git commit -m 'Match Save My Exams structure'"
echo "    git push"
echo ""
echo "  Homepage now matches SME:"
echo "    · Centered hero with pill badge"
echo "    · 'Why it works' — 3 numbered steps"
echo "    · 'What are you studying?' — board picker"
echo "    · 'Get started — for free' CTA"
echo "    · 'Meet our experts' trust section"
echo "    · 'What is TaleemHub?' FAQ content"
echo ""
echo "  Zero shadows. Zero glass morphism. Flat white."
echo "════════════════════════════════════════════"