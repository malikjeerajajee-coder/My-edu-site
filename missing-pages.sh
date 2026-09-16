#!/bin/bash
set -e

echo "Adding missing pages..."

mkdir -p src/pages/past-papers src/pages/guess-papers src/pages/pairing-schemes

# ═══════════════════════════════════════════════
#  PAST PAPERS
# ═══════════════════════════════════════════════
cat > src/pages/past-papers/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { getCollection } from 'astro:content';
import { BOARDS, itemBoards, slugify } from '../../lib/boards';

const papers = (await getCollection('pastPapers')).sort((a: any, b: any) => {
  if (a.data.class !== b.data.class) return Number(a.data.class) - Number(b.data.class);
  if (a.data.subject !== b.data.subject) return a.data.subject.localeCompare(b.data.subject);
  return (b.data.year || 0) - (a.data.year || 0);
});

// Count per board
const boardCounts: Record<string, number> = {};
for (const b of BOARDS) {
  boardCounts[b.slug] = papers.filter((p: any) => itemBoards(p.data).includes(b.name)).length;
}
const boardWithContent = BOARDS.filter(b => boardCounts[b.slug] > 0);
---
<BaseLayout title="Past Papers — All Boards & Classes | TaleemHub" description="Download past papers for Class 9-12 across all Pakistani boards. Punjab, Federal, KPK, Sindh, Balochistan, AJK.">
  <div class="mx-auto max-w-[1320px] px-4 pt-10 sm:px-6 sm:pt-14 lg:px-8">
    <div class="mb-10">
      <h1 class="text-3xl font-extrabold tracking-tight text-neutral-900 sm:text-4xl">Past Papers</h1>
      <p class="mt-2 text-neutral-500">{papers.length} {papers.length === 1 ? 'paper' : 'papers'} across {boardWithContent.length} {boardWithContent.length === 1 ? 'board' : 'boards'}</p>
    </div>

    <section class="mb-12">
      <h2 class="mb-4 text-sm font-bold uppercase tracking-wider text-neutral-400">Browse by board</h2>
      <div class="grid grid-cols-2 gap-3 lg:grid-cols-3">
        {boardWithContent.map(b => (
          <a href={url(`/board/${b.slug}`)} class="group rounded-2xl border border-neutral-200 bg-white p-5 transition-colors hover:border-[#0620ed]">
            <div class="flex items-center justify-between">
              <span class="grid h-11 w-11 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
                <Icon name="scroll-text" size={19} strokeWidth={2.2} />
              </span>
              <span class="text-xl font-extrabold text-neutral-900">{boardCounts[b.slug]}</span>
            </div>
            <h3 class="mt-4 text-base font-extrabold tracking-tight text-neutral-900">{b.name}</h3>
          </a>
        ))}
      </div>
    </section>

    <section class="pb-16">
      <h2 class="mb-4 text-sm font-bold uppercase tracking-wider text-neutral-400">All papers</h2>
      <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
        {papers.map((p: any) => (
          <a href={url(`/past-papers/${p.id}`)} class="group flex items-center gap-4 rounded-2xl border border-neutral-200 bg-white p-4 transition-colors hover:border-[#0620ed]">
            <span class="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
              <Icon name="scroll-text" size={17} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <h3 class="truncate text-sm font-bold text-neutral-900">{p.data.title}</h3>
              <div class="mt-1.5 flex flex-wrap gap-1.5">
                <span class="rounded-md bg-[#eef2fe] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#0620ed]">Class {p.data.class}</span>
                <span class="rounded-md bg-neutral-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-neutral-600">{p.data.year}</span>
              </div>
            </div>
            <Icon name="chevron-right" size={15} strokeWidth={2.4} class="shrink-0 text-neutral-300 transition-transform group-hover:translate-x-0.5 group-hover:text-[#0620ed]" />
          </a>
        ))}
      </div>
    </section>
  </div>
</BaseLayout>
ASTRO

cat > 'src/pages/past-papers/[...slug].astro' <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const papers = await getCollection('pastPapers');
  return papers.map((p: any) => ({ params: { slug: p.id }, props: { paper: p } }));
}
const { paper } = Astro.props;
const d = paper.data;
---
<BaseLayout title={`${d.title} | TaleemHub`} description={`Download ${d.title}. Free PDF for Pakistani students.`}>
  <div class="mx-auto max-w-4xl px-4 pt-8 sm:px-6 sm:pt-12 lg:px-8">
    <nav class="mb-6 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-neutral-400">
      <a href={url('/')} class="hover:text-[#0620ed]">Home</a>
      <span>/</span>
      <a href={url('/past-papers')} class="hover:text-[#0620ed]">Past Papers</a>
      <span>/</span>
      <span class="text-neutral-500">Class {d.class}</span>
    </nav>

    <div class="rounded-3xl border border-[#0620ed] bg-gradient-to-br from-[#110176] via-[#0620ed] to-[#265bf6] p-7 text-white sm:p-9">
      <div class="flex flex-wrap gap-1.5">
        {d.boards?.map((b: string) => (
          <span class="inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider">{b}</span>
        ))}
        <span class="inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider">Class {d.class}</span>
        <span class="inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider">{d.year}</span>
      </div>
      <h1 class="mt-4 text-2xl font-extrabold leading-tight tracking-tight sm:text-3xl">{d.title}</h1>
    </div>

    <a href={url(d.pdfUrl)} target="_blank" rel="noopener" class="mt-5 flex w-full items-center justify-center gap-2 rounded-xl bg-[#0620ed] px-5 py-3.5 text-sm font-bold text-white transition-colors hover:bg-[#110176]">
      <Icon name="download" size={18} strokeWidth={2.4} /> Download PDF
    </a>

    <div class="mt-8 rounded-2xl border border-neutral-200 bg-white p-6 sm:p-8">
      <h2 class="text-lg font-extrabold tracking-tight text-neutral-900">About this paper</h2>
      <p class="mt-3 text-sm leading-relaxed text-neutral-600">
        This is the official {d.subject} past paper for Class {d.class} from {d.boards?.join(', ')} board, held in {d.year}. Download the PDF to see the actual questions asked in the exam. Ideal for revision and understanding the paper pattern.
      </p>
    </div>
  </div>
</BaseLayout>
ASTRO

echo "  past-papers pages"

# ═══════════════════════════════════════════════
#  GUESS PAPERS
# ═══════════════════════════════════════════════
cat > src/pages/guess-papers/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { getCollection } from 'astro:content';
import { BOARDS, itemBoards } from '../../lib/boards';

const papers = (await getCollection('guessPapers')).sort((a: any, b: any) => {
  if (a.data.class !== b.data.class) return Number(a.data.class) - Number(b.data.class);
  return (b.data.year || 0) - (a.data.year || 0);
});

const boardCounts: Record<string, number> = {};
for (const b of BOARDS) {
  boardCounts[b.slug] = papers.filter((p: any) => itemBoards(p.data).includes(b.name)).length;
}
const boardWithContent = BOARDS.filter(b => boardCounts[b.slug] > 0);
---
<BaseLayout title="Guess Papers — All Boards & Classes | TaleemHub" description="Latest guess papers for Class 9-12 across Pakistani boards. Free PDF downloads.">
  <div class="mx-auto max-w-[1320px] px-4 pt-10 sm:px-6 sm:pt-14 lg:px-8">
    <div class="mb-10">
      <h1 class="text-3xl font-extrabold tracking-tight text-neutral-900 sm:text-4xl">Guess Papers</h1>
      <p class="mt-2 text-neutral-500">{papers.length} {papers.length === 1 ? 'paper' : 'papers'} — expected questions for upcoming exams</p>
    </div>

    {boardWithContent.length > 0 && (
      <section class="mb-12">
        <h2 class="mb-4 text-sm font-bold uppercase tracking-wider text-neutral-400">Browse by board</h2>
        <div class="grid grid-cols-2 gap-3 lg:grid-cols-3">
          {boardWithContent.map(b => (
            <a href={url(`/board/${b.slug}`)} class="group rounded-2xl border border-neutral-200 bg-white p-5 transition-colors hover:border-[#0620ed]">
              <div class="flex items-center justify-between">
                <span class="grid h-11 w-11 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
                  <Icon name="sparkles" size={19} strokeWidth={2.2} />
                </span>
                <span class="text-xl font-extrabold text-neutral-900">{boardCounts[b.slug]}</span>
              </div>
              <h3 class="mt-4 text-base font-extrabold tracking-tight text-neutral-900">{b.name}</h3>
            </a>
          ))}
        </div>
      </section>
    )}

    <section class="pb-16">
      <h2 class="mb-4 text-sm font-bold uppercase tracking-wider text-neutral-400">All papers</h2>
      {papers.length === 0 ? (
        <div class="rounded-2xl border border-dashed border-neutral-300 bg-white p-12 text-center">
          <p class="text-base font-bold text-neutral-900">No guess papers yet</p>
          <p class="mt-1 text-sm text-neutral-500">Check back soon.</p>
        </div>
      ) : (
        <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
          {papers.map((p: any) => (
            <a href={url(`/guess-papers/${p.id}`)} class="group flex items-center gap-4 rounded-2xl border border-neutral-200 bg-white p-4 transition-colors hover:border-[#0620ed]">
              <span class="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
                <Icon name="sparkles" size={17} strokeWidth={2.2} />
              </span>
              <div class="min-w-0 flex-1">
                <h3 class="truncate text-sm font-bold text-neutral-900">{p.data.title}</h3>
                <div class="mt-1.5 flex flex-wrap gap-1.5">
                  <span class="rounded-md bg-[#eef2fe] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#0620ed]">Class {p.data.class}</span>
                  <span class="rounded-md bg-neutral-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-neutral-600">{p.data.year}</span>
                </div>
              </div>
              <Icon name="chevron-right" size={15} strokeWidth={2.4} class="shrink-0 text-neutral-300 transition-transform group-hover:translate-x-0.5 group-hover:text-[#0620ed]" />
            </a>
          ))}
        </div>
      )}
    </section>
  </div>
</BaseLayout>
ASTRO

cat > 'src/pages/guess-papers/[...slug].astro' <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const papers = await getCollection('guessPapers');
  return papers.map((p: any) => ({ params: { slug: p.id }, props: { paper: p } }));
}
const { paper } = Astro.props;
const d = paper.data;
---
<BaseLayout title={`${d.title} | TaleemHub`} description={`Download ${d.title}. Expected exam questions for Pakistani students.`}>
  <div class="mx-auto max-w-4xl px-4 pt-8 sm:px-6 sm:pt-12 lg:px-8">
    <nav class="mb-6 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-neutral-400">
      <a href={url('/')} class="hover:text-[#0620ed]">Home</a>
      <span>/</span>
      <a href={url('/guess-papers')} class="hover:text-[#0620ed]">Guess Papers</a>
      <span>/</span>
      <span class="text-neutral-500">Class {d.class}</span>
    </nav>

    <div class="rounded-3xl border border-[#0620ed] bg-gradient-to-br from-[#110176] via-[#0620ed] to-[#265bf6] p-7 text-white sm:p-9">
      <div class="flex flex-wrap gap-1.5">
        {d.boards?.map((b: string) => (
          <span class="inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider">{b}</span>
        ))}
        <span class="inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider">Class {d.class}</span>
        <span class="inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider">{d.year}</span>
      </div>
      <h1 class="mt-4 text-2xl font-extrabold leading-tight tracking-tight sm:text-3xl">{d.title}</h1>
    </div>

    <a href={url(d.pdfUrl)} target="_blank" rel="noopener" class="mt-5 flex w-full items-center justify-center gap-2 rounded-xl bg-[#0620ed] px-5 py-3.5 text-sm font-bold text-white transition-colors hover:bg-[#110176]">
      <Icon name="download" size={18} strokeWidth={2.4} /> Download PDF
    </a>

    <div class="mt-8 rounded-2xl border border-neutral-200 bg-white p-6 sm:p-8">
      <h2 class="text-lg font-extrabold tracking-tight text-neutral-900">About this guess paper</h2>
      <p class="mt-3 text-sm leading-relaxed text-neutral-600">
        This is a {d.subject} guess paper for Class {d.class} from {d.boards?.join(', ')} board for the {d.year} exam. It highlights the most important questions likely to appear in the paper, based on past trends and examiner focus areas.
      </p>
    </div>
  </div>
</BaseLayout>
ASTRO

echo "  guess-papers pages"

# ═══════════════════════════════════════════════
#  PAIRING SCHEMES
# ═══════════════════════════════════════════════
cat > src/pages/pairing-schemes/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { getCollection } from 'astro:content';
import { BOARDS, itemBoards } from '../../lib/boards';

const schemes = (await getCollection('pairingSchemes')).sort((a: any, b: any) => {
  if (a.data.class !== b.data.class) return Number(a.data.class) - Number(b.data.class);
  return (b.data.year || 0) - (a.data.year || 0);
});

const boardCounts: Record<string, number> = {};
for (const b of BOARDS) {
  boardCounts[b.slug] = schemes.filter((p: any) => itemBoards(p.data).includes(b.name)).length;
}
const boardWithContent = BOARDS.filter(b => boardCounts[b.slug] > 0);
---
<BaseLayout title="Pairing Schemes — All Boards & Classes | TaleemHub" description="Official pairing schemes for Class 9-12 across Pakistani boards. Understand your paper structure.">
  <div class="mx-auto max-w-[1320px] px-4 pt-10 sm:px-6 sm:pt-14 lg:px-8">
    <div class="mb-10">
      <h1 class="text-3xl font-extrabold tracking-tight text-neutral-900 sm:text-4xl">Pairing Schemes</h1>
      <p class="mt-2 text-neutral-500">{schemes.length} {schemes.length === 1 ? 'scheme' : 'schemes'} — official paper structure and marks distribution</p>
    </div>

    {boardWithContent.length > 0 && (
      <section class="mb-12">
        <h2 class="mb-4 text-sm font-bold uppercase tracking-wider text-neutral-400">Browse by board</h2>
        <div class="grid grid-cols-2 gap-3 lg:grid-cols-3">
          {boardWithContent.map(b => (
            <a href={url(`/board/${b.slug}`)} class="group rounded-2xl border border-neutral-200 bg-white p-5 transition-colors hover:border-[#0620ed]">
              <div class="flex items-center justify-between">
                <span class="grid h-11 w-11 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
                  <Icon name="list" size={19} strokeWidth={2.2} />
                </span>
                <span class="text-xl font-extrabold text-neutral-900">{boardCounts[b.slug]}</span>
              </div>
              <h3 class="mt-4 text-base font-extrabold tracking-tight text-neutral-900">{b.name}</h3>
            </a>
          ))}
        </div>
      </section>
    )}

    <section class="pb-16">
      <h2 class="mb-4 text-sm font-bold uppercase tracking-wider text-neutral-400">All schemes</h2>
      {schemes.length === 0 ? (
        <div class="rounded-2xl border border-dashed border-neutral-300 bg-white p-12 text-center">
          <p class="text-base font-bold text-neutral-900">No pairing schemes yet</p>
          <p class="mt-1 text-sm text-neutral-500">Check back soon.</p>
        </div>
      ) : (
        <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
          {schemes.map((p: any) => (
            <a href={url(`/pairing-schemes/${p.id}`)} class="group flex items-center gap-4 rounded-2xl border border-neutral-200 bg-white p-4 transition-colors hover:border-[#0620ed]">
              <span class="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
                <Icon name="list" size={17} strokeWidth={2.2} />
              </span>
              <div class="min-w-0 flex-1">
                <h3 class="truncate text-sm font-bold text-neutral-900">{p.data.title}</h3>
                <div class="mt-1.5 flex flex-wrap gap-1.5">
                  <span class="rounded-md bg-[#eef2fe] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#0620ed]">Class {p.data.class}</span>
                  <span class="rounded-md bg-neutral-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-neutral-600">{p.data.year}</span>
                </div>
              </div>
              <Icon name="chevron-right" size={15} strokeWidth={2.4} class="shrink-0 text-neutral-300 transition-transform group-hover:translate-x-0.5 group-hover:text-[#0620ed]" />
            </a>
          ))}
        </div>
      )}
    </section>
  </div>
</BaseLayout>
ASTRO

cat > 'src/pages/pairing-schemes/[...slug].astro' <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const schemes = await getCollection('pairingSchemes');
  return schemes.map((s: any) => ({ params: { slug: s.id }, props: { scheme: s } }));
}
const { scheme } = Astro.props;
const d = scheme.data;
---
<BaseLayout title={`${d.title} | TaleemHub`} description={`Download ${d.title}. Official paper structure for Pakistani students.`}>
  <div class="mx-auto max-w-4xl px-4 pt-8 sm:px-6 sm:pt-12 lg:px-8">
    <nav class="mb-6 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-neutral-400">
      <a href={url('/')} class="hover:text-[#0620ed]">Home</a>
      <span>/</span>
      <a href={url('/pairing-schemes')} class="hover:text-[#0620ed]">Pairing Schemes</a>
      <span>/</span>
      <span class="text-neutral-500">Class {d.class}</span>
    </nav>

    <div class="rounded-3xl border border-[#0620ed] bg-gradient-to-br from-[#110176] via-[#0620ed] to-[#265bf6] p-7 text-white sm:p-9">
      <div class="flex flex-wrap gap-1.5">
        {d.boards?.map((b: string) => (
          <span class="inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider">{b}</span>
        ))}
        <span class="inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider">Class {d.class}</span>
        <span class="inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider">{d.year}</span>
      </div>
      <h1 class="mt-4 text-2xl font-extrabold leading-tight tracking-tight sm:text-3xl">{d.title}</h1>
    </div>

    <a href={url(d.pdfUrl)} target="_blank" rel="noopener" class="mt-5 flex w-full items-center justify-center gap-2 rounded-xl bg-[#0620ed] px-5 py-3.5 text-sm font-bold text-white transition-colors hover:bg-[#110176]">
      <Icon name="download" size={18} strokeWidth={2.4} /> Download PDF
    </a>

    <div class="mt-8 rounded-2xl border border-neutral-200 bg-white p-6 sm:p-8">
      <h2 class="text-lg font-extrabold tracking-tight text-neutral-900">About this pairing scheme</h2>
      <p class="mt-3 text-sm leading-relaxed text-neutral-600">
        This is the official pairing scheme for Class {d.class} from {d.boards?.join(', ')} board for the {d.year} exam. It shows exactly how marks are distributed across the paper — the objective, subjective, short question and long question sections — so you know what to expect and how to prioritise your study time.
      </p>
    </div>
  </div>
</BaseLayout>
ASTRO

echo "  pairing-schemes pages"

# ═══════════════════════════════════════════════
#  404 PAGE
# ═══════════════════════════════════════════════
cat > src/pages/404.astro <<'ASTRO'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { url } from '../lib/url';
---
<BaseLayout title="Page not found — TaleemHub" description="The page you were looking for doesn't exist. Browse boards, classes and subjects instead.">
  <div class="mx-auto max-w-2xl px-4 py-24 text-center sm:px-6 lg:px-8">
    <div class="text-[7rem] font-extrabold leading-none tracking-tighter text-[#0620ed]">404</div>
    <h1 class="mt-4 text-3xl font-extrabold tracking-tight text-neutral-900">Page not found</h1>
    <p class="mt-3 text-base text-neutral-500">
      The page you're looking for doesn't exist or has been moved. Let's get you back to studying.
    </p>
    <div class="mt-8 flex flex-wrap justify-center gap-3">
      <a href={url('/')} class="inline-flex items-center gap-1.5 rounded-xl bg-[#0620ed] px-5 py-3 text-sm font-bold text-white hover:bg-[#110176]">
        <Icon name="home" size={15} strokeWidth={2.4} /> Go home
      </a>
      <a href={url('/boards')} class="inline-flex items-center gap-1.5 rounded-xl border border-neutral-200 bg-white px-5 py-3 text-sm font-bold text-neutral-700 hover:border-[#0620ed] hover:text-[#0620ed]">
        <Icon name="graduation-cap" size={15} strokeWidth={2.4} /> Browse boards
      </a>
      <a href={url('/search')} class="inline-flex items-center gap-1.5 rounded-xl border border-neutral-200 bg-white px-5 py-3 text-sm font-bold text-neutral-700 hover:border-[#0620ed] hover:text-[#0620ed]">
        <Icon name="search" size={15} strokeWidth={2.4} /> Search
      </a>
    </div>
  </div>
</BaseLayout>
ASTRO

echo "  404 page"

# ═══════════════════════════════════════════════
#  REBUILD
# ═══════════════════════════════════════════════
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -20

echo ""
echo "════════════════════════════════════════════"
echo "  Done."
echo ""
echo "  New pages:"
echo "    /past-papers                    list all"
echo "    /past-papers/[slug]             detail"
echo "    /guess-papers                   list all"
echo "    /guess-papers/[slug]            detail"
echo "    /pairing-schemes                list all"
echo "    /pairing-schemes/[slug]         detail"
echo "    404.astro                       custom 404"
echo ""
echo "  Push:"
echo "    git add ."
echo "    git commit -m 'Add missing pages + 404'"
echo "    git push"
echo "════════════════════════════════════════════"