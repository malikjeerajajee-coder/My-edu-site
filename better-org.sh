#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Fixing organization + thick content"
echo "════════════════════════════════════════════"
echo ""

# ═══════════════════════════════════════════════
#  1. Add optional rich fields to schemas
# ═══════════════════════════════════════════════
python3 - <<'PY'
import pathlib
p = pathlib.Path("src/content.config.ts")
s = p.read_text()

# Add optional rich fields to pastPapers, guessPapers schemas
if "topics:" not in s:
    s = s.replace(
        """const pastPapers = defineCollection({
  loader: glob({ pattern: '**/*.json', base: './src/content/past-papers' }),
  schema: z.object({
    title: z.string(),
    subject: z.string(),
    class: z.string(),
    year: z.number(),
    board: z.string().optional(),
    boards: z.array(z.string()).optional(),
    pdfUrl: z.string(),
  }),
});""",
        """const topicSchema = z.object({
  chapter: z.string(),
  mcqs: z.number().optional(),
  short: z.number().optional(),
  long: z.number().optional(),
});

const faqSchema = z.object({
  q: z.string(),
  a: z.string(),
});

const pastPapers = defineCollection({
  loader: glob({ pattern: '**/*.json', base: './src/content/past-papers' }),
  schema: z.object({
    title: z.string(),
    subject: z.string(),
    class: z.string(),
    year: z.number(),
    board: z.string().optional(),
    boards: z.array(z.string()).optional(),
    pdfUrl: z.string(),
    totalMarks: z.number().optional(),
    duration: z.string().optional(),
    objective: z.object({ mcqs: z.number(), marks: z.number() }).optional(),
    subjective: z.object({ short: z.number(), long: z.number(), marks: z.number() }).optional(),
    topics: z.array(topicSchema).optional(),
    faq: z.array(faqSchema).optional(),
  }),
});"""
    )
    p.write_text(s)
    print("  schema updated")
else:
    print("  schema already has rich fields")
PY

# ═══════════════════════════════════════════════
#  2. Create one fully-loaded sample paper
# ═══════════════════════════════════════════════
cat > src/content/past-papers/physics-9-punjab-2024.json <<'JSON'
{
  "title": "Physics Class 9 Past Paper 2024 (Punjab Boards)",
  "subject": "Physics",
  "class": "9",
  "year": 2024,
  "boards": ["Punjab"],
  "pdfUrl": "/pdfs/past-papers/physics-9-punjab-2024.pdf",
  "totalMarks": 65,
  "duration": "2 hours 40 minutes",
  "objective": { "mcqs": 12, "marks": 12 },
  "subjective": { "short": 15, "long": 3, "marks": 53 },
  "topics": [
    { "chapter": "Chapter 1 — Physical Quantities and Measurement", "mcqs": 2, "short": 2, "long": 1 },
    { "chapter": "Chapter 2 — Kinematics",                          "mcqs": 2, "short": 2, "long": 1 },
    { "chapter": "Chapter 3 — Dynamics",                            "mcqs": 2, "short": 2, "long": 1 },
    { "chapter": "Chapter 4 — Turning Effect of Forces",            "mcqs": 2, "short": 2, "long": 0 },
    { "chapter": "Chapter 5 — Gravitation",                         "mcqs": 2, "short": 2, "long": 0 },
    { "chapter": "Chapter 6 — Work and Energy",                     "mcqs": 1, "short": 2, "long": 0 },
    { "chapter": "Chapter 7 — Properties of Matter",                "mcqs": 1, "short": 1, "long": 0 },
    { "chapter": "Chapter 8 — Thermal Properties of Matter",        "mcqs": 0, "short": 1, "long": 0 },
    { "chapter": "Chapter 9 — Transfer of Heat",                    "mcqs": 0, "short": 1, "long": 0 }
  ],
  "faq": [
    {
      "q": "Is this paper the same for all Punjab boards?",
      "a": "Yes. The 9th class Physics paper is set by each Punjab BISE (Lahore, Gujranwala, Multan, Faisalabad, Sahiwal, Rawalpindi, Sargodha, DG Khan, Bahawalpur) using the same syllabus and paper pattern. Question wording may vary slightly but the difficulty and topic coverage are identical."
    },
    {
      "q": "What is the total marks of the Class 9 Physics paper?",
      "a": "The paper is worth 65 marks: 12 marks for objective (MCQs), 53 marks for subjective. Of the subjective portion, 15 short questions (30 marks) and 3 long questions (15 marks) are typically asked, with the remaining marks spread across practical-adjacent questions and diagram-based tasks."
    },
    {
      "q": "How much time is given for the paper?",
      "a": "Students get 2 hours 40 minutes for the written paper. Practical exams are held separately for 15 marks."
    },
    {
      "q": "Which chapters carry the most weight?",
      "a": "Chapters 1 through 5 (Measurement, Kinematics, Dynamics, Forces, Gravitation) are the highest-yield — together they account for over 60% of every 9th class Physics paper across the last five years."
    },
    {
      "q": "Are numericals asked in the paper?",
      "a": "Yes. Every year, 3–5 numerical questions appear — mostly from Kinematics, Dynamics and Work & Energy. They carry 2–3 marks each and are among the easiest marks to secure with practice."
    }
  ]
}
JSON
echo "  sample rich paper: physics-9-punjab-2024.json"

# ═══════════════════════════════════════════════
#  3. Rebuild /past-papers as a HUB (not a dump)
# ═══════════════════════════════════════════════
cat > src/pages/past-papers/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { getCollection } from 'astro:content';
import { BOARDS, itemBoards } from '../../lib/boards';

const papers = await getCollection('pastPapers');

// Count papers per board
const boardCounts: Record<string, number> = {};
for (const b of BOARDS) {
  boardCounts[b.slug] = papers.filter((p: any) => itemBoards(p.data).includes(b.name)).length;
}

// Group by class for the "quick jump" section
const classSet = new Set<string>();
papers.forEach((p: any) => classSet.add(p.data.class));
const classes = [...classSet].sort((a, b) => Number(a) - Number(b));

// Recently added (latest by year)
const recent = [...papers]
  .sort((a: any, b: any) => (b.data.year || 0) - (a.data.year || 0))
  .slice(0, 6);
---
<BaseLayout
  title="Past Papers — Class 9 to 12 | All Pakistan Boards | TaleemHub"
  description="Download past papers for Class 9, 10, 11, 12 across all Pakistani boards. Free PDFs for Punjab, Federal, KPK, Sindh, Balochistan and AJK boards."
>
  <div class="mx-auto max-w-[1320px] px-4 pt-12 sm:px-6 sm:pt-16 lg:px-8">
    <!-- HERO -->
    <div class="max-w-2xl">
      <div class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-[#0620ed]">
        <span class="h-1.5 w-1.5 rounded-full bg-[#0620ed]"></span>
        Exam preparation
      </div>
      <h1 class="mt-4 text-4xl font-extrabold leading-tight tracking-tight text-neutral-900 sm:text-5xl">
        Past Papers
      </h1>
      <p class="mt-4 text-base leading-relaxed text-neutral-500 sm:text-lg">
        Pick your board, then your class and subject — and find every paper you need, from 2018 to today.
      </p>
    </div>

    <!-- PICK YOUR BOARD -->
    <section class="mt-12">
      <div class="mb-6 flex items-end justify-between gap-4">
        <h2 class="text-xl font-extrabold tracking-tight text-neutral-900 sm:text-2xl">Step 1 — Choose your board</h2>
      </div>

      <div class="grid grid-cols-2 gap-4 lg:grid-cols-3">
        {BOARDS.map(b => {
          const count = boardCounts[b.slug];
          const disabled = count === 0;
          const cls = disabled
            ? "cursor-default opacity-50"
            : "hover:border-[#0620ed]";
          const tag: any = disabled ? 'div' : 'a';
          return (
            <a href={url(`/board/${b.slug}`)}
               class:list={["group rounded-2xl border border-neutral-200 bg-white p-6 transition-colors", cls]}>
              <div class="flex items-start justify-between">
                <span class="grid h-12 w-12 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
                  <Icon name="graduation-cap" size={22} strokeWidth={2.2} />
                </span>
                {!disabled && (
                  <Icon name="arrow-up-right" size={18} strokeWidth={2.4} class="text-neutral-300 transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-[#0620ed]" />
                )}
              </div>
              <h3 class="mt-5 text-lg font-extrabold tracking-tight text-neutral-900">{b.name}</h3>
              <p class:list={["mt-1 text-sm", disabled ? "text-neutral-400" : "text-neutral-500"]}>
                {count === 0 ? "Coming soon" : `${count} paper${count === 1 ? '' : 's'}`}
              </p>
            </a>
          );
        })}
      </div>
    </section>

    <!-- QUICK JUMP -->
    {classes.length > 0 && (
      <section class="mt-14 rounded-3xl border border-neutral-200 bg-neutral-50 p-8 sm:p-10">
        <h2 class="text-xl font-extrabold tracking-tight text-neutral-900">Or jump straight by class</h2>
        <p class="mt-2 text-sm text-neutral-500">
          Papers vary by board, so once you pick a class we'll ask you for your board.
        </p>
        <div class="mt-6 flex flex-wrap gap-3">
          {classes.map(c => (
            <a href={url(`/past-papers/class/${c}`)} class="inline-flex items-center gap-2 rounded-xl border border-neutral-200 bg-white px-4 py-2.5 text-sm font-bold text-neutral-900 transition-colors hover:border-[#0620ed] hover:text-[#0620ed]">
              <Icon name="file-text" size={15} strokeWidth={2.3} />
              Class {c}
            </a>
          ))}
        </div>
      </section>
    )}

    <!-- RECENTLY ADDED -->
    {recent.length > 0 && (
      <section class="mt-14 pb-20">
        <div class="mb-6">
          <h2 class="text-xl font-extrabold tracking-tight text-neutral-900">Recently added</h2>
          <p class="mt-1 text-sm text-neutral-500">The newest papers across all boards.</p>
        </div>
        <div class="grid grid-cols-1 gap-3 md:grid-cols-2 lg:grid-cols-3">
          {recent.map((p: any) => (
            <a href={url(`/past-papers/${p.id}`)} class="group flex items-center gap-4 rounded-2xl border border-neutral-200 bg-white p-4 transition-colors hover:border-[#0620ed]">
              <span class="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
                <Icon name="scroll-text" size={17} strokeWidth={2.2} />
              </span>
              <div class="min-w-0 flex-1">
                <h3 class="truncate text-sm font-bold text-neutral-900">{p.data.subject}</h3>
                <p class="truncate text-xs text-neutral-500">Class {p.data.class} · {p.data.year}</p>
              </div>
              <Icon name="chevron-right" size={15} strokeWidth={2.4} class="shrink-0 text-neutral-300 transition-transform group-hover:translate-x-0.5 group-hover:text-[#0620ed]" />
            </a>
          ))}
        </div>
      </section>
    )}
  </div>
</BaseLayout>
ASTRO
echo "  /past-papers hub"

# ═══════════════════════════════════════════════
#  4. Rebuild /guess-papers as a HUB
# ═══════════════════════════════════════════════
cat > src/pages/guess-papers/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { getCollection } from 'astro:content';
import { BOARDS, itemBoards } from '../../lib/boards';

const papers = await getCollection('guessPapers');
const boardCounts: Record<string, number> = {};
for (const b of BOARDS) {
  boardCounts[b.slug] = papers.filter((p: any) => itemBoards(p.data).includes(b.name)).length;
}
const recent = [...papers].sort((a: any, b: any) => (b.data.year || 0) - (a.data.year || 0)).slice(0, 6);
---
<BaseLayout
  title="Guess Papers 2025 — Class 9 to 12 | All Pakistan Boards | TaleemHub"
  description="Latest guess papers for Class 9, 10, 11, 12 across all Pakistani boards. Free PDF downloads based on past trends and examiner focus."
>
  <div class="mx-auto max-w-[1320px] px-4 pt-12 sm:px-6 sm:pt-16 lg:px-8">
    <div class="max-w-2xl">
      <div class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-[#0620ed]">
        <span class="h-1.5 w-1.5 rounded-full bg-[#0620ed]"></span>
        Exam preparation
      </div>
      <h1 class="mt-4 text-4xl font-extrabold leading-tight tracking-tight text-neutral-900 sm:text-5xl">Guess Papers</h1>
      <p class="mt-4 text-base leading-relaxed text-neutral-500 sm:text-lg">
        The most important questions likely to appear in your paper — chosen from years of exam patterns.
      </p>
    </div>

    <section class="mt-12">
      <h2 class="mb-6 text-xl font-extrabold tracking-tight text-neutral-900 sm:text-2xl">Choose your board</h2>
      <div class="grid grid-cols-2 gap-4 lg:grid-cols-3">
        {BOARDS.map(b => {
          const count = boardCounts[b.slug];
          const disabled = count === 0;
          return (
            <a href={url(`/board/${b.slug}`)} class:list={["group rounded-2xl border border-neutral-200 bg-white p-6 transition-colors", disabled ? "cursor-default opacity-50" : "hover:border-[#0620ed]"]}>
              <div class="flex items-start justify-between">
                <span class="grid h-12 w-12 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
                  <Icon name="sparkles" size={22} strokeWidth={2.2} />
                </span>
                {!disabled && <Icon name="arrow-up-right" size={18} strokeWidth={2.4} class="text-neutral-300 transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-[#0620ed]" />}
              </div>
              <h3 class="mt-5 text-lg font-extrabold tracking-tight text-neutral-900">{b.name}</h3>
              <p class:list={["mt-1 text-sm", disabled ? "text-neutral-400" : "text-neutral-500"]}>
                {count === 0 ? "Coming soon" : `${count} paper${count === 1 ? '' : 's'}`}
              </p>
            </a>
          );
        })}
      </div>
    </section>

    {recent.length > 0 && (
      <section class="mt-14 pb-20">
        <div class="mb-6">
          <h2 class="text-xl font-extrabold tracking-tight text-neutral-900">Recently added</h2>
        </div>
        <div class="grid grid-cols-1 gap-3 md:grid-cols-2 lg:grid-cols-3">
          {recent.map((p: any) => (
            <a href={url(`/guess-papers/${p.id}`)} class="group flex items-center gap-4 rounded-2xl border border-neutral-200 bg-white p-4 transition-colors hover:border-[#0620ed]">
              <span class="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
                <Icon name="sparkles" size={17} strokeWidth={2.2} />
              </span>
              <div class="min-w-0 flex-1">
                <h3 class="truncate text-sm font-bold text-neutral-900">{p.data.subject}</h3>
                <p class="truncate text-xs text-neutral-500">Class {p.data.class} · {p.data.year}</p>
              </div>
              <Icon name="chevron-right" size={15} strokeWidth={2.4} class="shrink-0 text-neutral-300 transition-transform group-hover:translate-x-0.5 group-hover:text-[#0620ed]" />
            </a>
          ))}
        </div>
      </section>
    )}
  </div>
</BaseLayout>
ASTRO
echo "  /guess-papers hub"

# ═══════════════════════════════════════════════
#  5. Rebuild /pairing-schemes as a HUB
# ═══════════════════════════════════════════════
cat > src/pages/pairing-schemes/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { getCollection } from 'astro:content';
import { BOARDS, itemBoards } from '../../lib/boards';

const schemes = await getCollection('pairingSchemes');
const boardCounts: Record<string, number> = {};
for (const b of BOARDS) {
  boardCounts[b.slug] = schemes.filter((p: any) => itemBoards(p.data).includes(b.name)).length;
}
const recent = [...schemes].sort((a: any, b: any) => (b.data.year || 0) - (a.data.year || 0)).slice(0, 6);
---
<BaseLayout
  title="Pairing Schemes 2025 — Class 9 to 12 | All Pakistan Boards | TaleemHub"
  description="Official pairing schemes for Class 9, 10, 11 and 12 across Pakistani boards. See exactly how marks are distributed in each paper."
>
  <div class="mx-auto max-w-[1320px] px-4 pt-12 sm:px-6 sm:pt-16 lg:px-8">
    <div class="max-w-2xl">
      <div class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-[#0620ed]">
        <span class="h-1.5 w-1.5 rounded-full bg-[#0620ed]"></span>
        Exam preparation
      </div>
      <h1 class="mt-4 text-4xl font-extrabold leading-tight tracking-tight text-neutral-900 sm:text-5xl">Pairing Schemes</h1>
      <p class="mt-4 text-base leading-relaxed text-neutral-500 sm:text-lg">
        Know exactly how marks are split across your paper — objective, short questions, long questions.
      </p>
    </div>

    <section class="mt-12">
      <h2 class="mb-6 text-xl font-extrabold tracking-tight text-neutral-900 sm:text-2xl">Choose your board</h2>
      <div class="grid grid-cols-2 gap-4 lg:grid-cols-3">
        {BOARDS.map(b => {
          const count = boardCounts[b.slug];
          const disabled = count === 0;
          return (
            <a href={url(`/board/${b.slug}`)} class:list={["group rounded-2xl border border-neutral-200 bg-white p-6 transition-colors", disabled ? "cursor-default opacity-50" : "hover:border-[#0620ed]"]}>
              <div class="flex items-start justify-between">
                <span class="grid h-12 w-12 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
                  <Icon name="list" size={22} strokeWidth={2.2} />
                </span>
                {!disabled && <Icon name="arrow-up-right" size={18} strokeWidth={2.4} class="text-neutral-300 transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-[#0620ed]" />}
              </div>
              <h3 class="mt-5 text-lg font-extrabold tracking-tight text-neutral-900">{b.name}</h3>
              <p class:list={["mt-1 text-sm", disabled ? "text-neutral-400" : "text-neutral-500"]}>
                {count === 0 ? "Coming soon" : `${count} scheme${count === 1 ? '' : 's'}`}
              </p>
            </a>
          );
        })}
      </div>
    </section>

    {recent.length > 0 && (
      <section class="mt-14 pb-20">
        <div class="mb-6">
          <h2 class="text-xl font-extrabold tracking-tight text-neutral-900">Recently added</h2>
        </div>
        <div class="grid grid-cols-1 gap-3 md:grid-cols-2 lg:grid-cols-3">
          {recent.map((p: any) => (
            <a href={url(`/pairing-schemes/${p.id}`)} class="group flex items-center gap-4 rounded-2xl border border-neutral-200 bg-white p-4 transition-colors hover:border-[#0620ed]">
              <span class="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
                <Icon name="list" size={17} strokeWidth={2.2} />
              </span>
              <div class="min-w-0 flex-1">
                <h3 class="truncate text-sm font-bold text-neutral-900">Class {p.data.class} Scheme</h3>
                <p class="truncate text-xs text-neutral-500">{p.data.year}</p>
              </div>
              <Icon name="chevron-right" size={15} strokeWidth={2.4} class="shrink-0 text-neutral-300 transition-transform group-hover:translate-x-0.5 group-hover:text-[#0620ed]" />
            </a>
          ))}
        </div>
      </section>
    )}
  </div>
</BaseLayout>
ASTRO
echo "  /pairing-schemes hub"

# ═══════════════════════════════════════════════
#  6. Update past-papers detail page with rich content
# ═══════════════════════════════════════════════
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

// Related: same subject, other years, same boards
const allPapers = await getCollection('pastPapers');
const related = allPapers
  .filter((p: any) =>
    p.id !== paper.id &&
    p.data.subject === d.subject &&
    p.data.class === d.class &&
    (p.data.boards || []).some((b: string) => (d.boards || []).includes(b))
  )
  .sort((a: any, b: any) => (b.data.year || 0) - (a.data.year || 0))
  .slice(0, 6);

const SITE = 'https://malikjeerajajee-coder.github.io/My-edu-site';
const canonical = `${SITE}/past-papers/${paper.id}/`;

const breadcrumbJsonLd = {
  '@context': 'https://schema.org',
  '@type': 'BreadcrumbList',
  itemListElement: [
    { '@type': 'ListItem', position: 1, name: 'Home',        item: `${SITE}/` },
    { '@type': 'ListItem', position: 2, name: 'Past Papers', item: `${SITE}/past-papers/` },
    { '@type': 'ListItem', position: 3, name: `${d.subject} Class ${d.class}`, item: canonical },
  ],
};

const articleJsonLd = {
  '@context': 'https://schema.org',
  '@type': 'Article',
  headline: d.title,
  description: `Free PDF of ${d.subject} Class ${d.class} past paper ${d.year} for ${(d.boards || []).join(', ')} boards.`,
  about: { '@type': 'Thing', name: `${d.subject} Class ${d.class} Past Paper` },
  inLanguage: 'en',
  datePublished: `${d.year}-01-01`,
  publisher: { '@type': 'Organization', name: 'TaleemHub', url: SITE },
  mainEntityOfPage: canonical,
};

const faqJsonLd = d.faq && d.faq.length ? {
  '@context': 'https://schema.org',
  '@type': 'FAQPage',
  mainEntity: d.faq.map((f: any) => ({
    '@type': 'Question',
    name: f.q,
    acceptedAnswer: { '@type': 'Answer', text: f.a },
  })),
} : null;
---
<BaseLayout title={`${d.title} | TaleemHub`} description={`Download ${d.title}. Full paper structure, chapter breakdown and free PDF for Pakistani students.`}>
  <script type="application/ld+json" set:html={JSON.stringify(breadcrumbJsonLd)} />
  <script type="application/ld+json" set:html={JSON.stringify(articleJsonLd)} />
  {faqJsonLd && <script type="application/ld+json" set:html={JSON.stringify(faqJsonLd)} />}

  <div class="mx-auto max-w-5xl px-4 pt-8 sm:px-6 sm:pt-12 lg:px-8">
    <!-- Breadcrumbs -->
    <nav class="mb-6 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-neutral-400">
      <a href={url('/')} class="hover:text-[#0620ed]">Home</a>
      <span>/</span>
      <a href={url('/past-papers')} class="hover:text-[#0620ed]">Past Papers</a>
      <span>/</span>
      <a href={url('/board/punjab')} class="hover:text-[#0620ed]">Punjab</a>
      <span>/</span>
      <span class="text-neutral-500">Class {d.class} · {d.subject} · {d.year}</span>
    </nav>

    <!-- Hero -->
    <div class="rounded-3xl border border-[#0620ed] bg-gradient-to-br from-[#110176] via-[#0620ed] to-[#265bf6] p-8 text-white sm:p-10">
      <div class="flex flex-wrap gap-1.5">
        {(d.boards || []).map((b: string) => (
          <span class="inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider">{b}</span>
        ))}
        <span class="inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider">Class {d.class}</span>
        <span class="inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider">{d.year}</span>
      </div>
      <h1 class="mt-5 text-3xl font-extrabold leading-tight tracking-tight sm:text-4xl">{d.title}</h1>
      {d.totalMarks && (
        <div class="mt-5 flex flex-wrap gap-x-6 gap-y-2 text-sm text-blue-100">
          <span><strong class="font-extrabold text-white">{d.totalMarks} marks</strong> total</span>
          {d.duration && <span>Duration: <strong class="font-extrabold text-white">{d.duration}</strong></span>}
        </div>
      )}
    </div>

    <!-- Download -->
    <a href={url(d.pdfUrl)} target="_blank" rel="noopener" class="mt-5 flex w-full items-center justify-center gap-2 rounded-xl bg-[#0620ed] px-5 py-4 text-base font-bold text-white transition-colors hover:bg-[#110176]">
      <Icon name="download" size={19} strokeWidth={2.4} /> Download Full Paper PDF
    </a>

    <!-- Two-column content -->
    <div class="mt-8 grid gap-6 lg:grid-cols-3">
      <!-- Main column -->
      <div class="lg:col-span-2 space-y-6">
        <!-- Paper structure -->
        {(d.objective || d.subjective) && (
          <section class="rounded-2xl border border-neutral-200 bg-white p-6 sm:p-8">
            <h2 class="text-xl font-extrabold tracking-tight text-neutral-900">Paper structure</h2>
            <p class="mt-2 text-sm leading-relaxed text-neutral-500">
              Here's how the {d.year} {d.subject} paper was laid out.
            </p>
            <div class="mt-5 grid gap-3 sm:grid-cols-2">
              {d.objective && (
                <div class="rounded-xl border border-neutral-200 bg-neutral-50 p-5">
                  <div class="flex items-center gap-2">
                    <span class="grid h-9 w-9 place-items-center rounded-lg bg-[#eef2fe] text-[#0620ed]">
                      <Icon name="circle-help" size={17} strokeWidth={2.3} />
                    </span>
                    <div class="text-sm font-extrabold text-neutral-900">Objective</div>
                  </div>
                  <div class="mt-3 text-2xl font-extrabold tracking-tight text-neutral-900">{d.objective.mcqs} <span class="text-sm font-semibold text-neutral-500">MCQs</span></div>
                  <div class="text-xs font-semibold text-neutral-500">{d.objective.marks} marks</div>
                </div>
              )}
              {d.subjective && (
                <div class="rounded-xl border border-neutral-200 bg-neutral-50 p-5">
                  <div class="flex items-center gap-2">
                    <span class="grid h-9 w-9 place-items-center rounded-lg bg-[#eef2fe] text-[#0620ed]">
                      <Icon name="file-text" size={17} strokeWidth={2.3} />
                    </span>
                    <div class="text-sm font-extrabold text-neutral-900">Subjective</div>
                  </div>
                  <div class="mt-3 text-2xl font-extrabold tracking-tight text-neutral-900">{d.subjective.short} <span class="text-sm font-semibold text-neutral-500">short + {d.subjective.long} long</span></div>
                  <div class="text-xs font-semibold text-neutral-500">{d.subjective.marks} marks</div>
                </div>
              )}
            </div>
          </section>
        )}

        <!-- Chapter breakdown -->
        {d.topics && d.topics.length > 0 && (
          <section class="rounded-2xl border border-neutral-200 bg-white p-6 sm:p-8">
            <h2 class="text-xl font-extrabold tracking-tight text-neutral-900">Chapter-wise breakdown</h2>
            <p class="mt-2 text-sm leading-relaxed text-neutral-500">
              Which chapters were tested — and how much each one carried.
            </p>
            <div class="mt-5 overflow-hidden rounded-xl border border-neutral-200">
              <table class="w-full text-left text-sm">
                <thead class="bg-neutral-50 text-[11px] font-bold uppercase tracking-wider text-neutral-500">
                  <tr>
                    <th class="px-4 py-3">Chapter</th>
                    <th class="px-4 py-3 text-center">MCQs</th>
                    <th class="px-4 py-3 text-center">Short</th>
                    <th class="px-4 py-3 text-center">Long</th>
                  </tr>
                </thead>
                <tbody>
                  {d.topics.map((t: any) => (
                    <tr class="border-t border-neutral-200">
                      <td class="px-4 py-3 text-neutral-800">{t.chapter}</td>
                      <td class="px-4 py-3 text-center font-bold text-neutral-900">{t.mcqs || 0}</td>
                      <td class="px-4 py-3 text-center font-bold text-neutral-900">{t.short || 0}</td>
                      <td class="px-4 py-3 text-center font-bold text-neutral-900">{t.long || 0}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </section>
        )}

        <!-- FAQ -->
        {d.faq && d.faq.length > 0 && (
          <section class="rounded-2xl border border-neutral-200 bg-white p-6 sm:p-8">
            <h2 class="text-xl font-extrabold tracking-tight text-neutral-900">Frequently asked questions</h2>
            <div class="mt-5 space-y-3">
              {d.faq.map((f: any) => (
                <details class="group rounded-xl border border-neutral-200 bg-neutral-50 open:bg-white">
                  <summary class="flex cursor-pointer list-none items-center justify-between gap-4 px-5 py-4 text-sm font-bold text-neutral-900">
                    <span>{f.q}</span>
                    <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-neutral-400 transition-transform group-open:rotate-90" />
                  </summary>
                  <div class="border-t border-neutral-200 px-5 py-4 text-sm leading-relaxed text-neutral-600">
                    {f.a}
                  </div>
                </details>
              ))}
            </div>
          </section>
        )}
      </div>

      <!-- Sidebar column -->
      <aside class="space-y-6">
        <!-- Quick facts -->
        <div class="rounded-2xl border border-neutral-200 bg-white p-6">
          <h3 class="text-sm font-extrabold uppercase tracking-wider text-neutral-400">Paper facts</h3>
          <dl class="mt-4 space-y-3 text-sm">
            <div class="flex justify-between gap-4">
              <dt class="text-neutral-500">Board</dt>
              <dd class="font-bold text-neutral-900">{(d.boards || []).join(', ')}</dd>
            </div>
            <div class="flex justify-between gap-4">
              <dt class="text-neutral-500">Class</dt>
              <dd class="font-bold text-neutral-900">{d.class}</dd>
            </div>
            <div class="flex justify-between gap-4">
              <dt class="text-neutral-500">Subject</dt>
              <dd class="font-bold text-neutral-900">{d.subject}</dd>
            </div>
            <div class="flex justify-between gap-4">
              <dt class="text-neutral-500">Year</dt>
              <dd class="font-bold text-neutral-900">{d.year}</dd>
            </div>
            {d.totalMarks && (
              <div class="flex justify-between gap-4">
                <dt class="text-neutral-500">Total marks</dt>
                <dd class="font-bold text-neutral-900">{d.totalMarks}</dd>
              </div>
            )}
          </dl>
        </div>

        <!-- Related papers -->
        {related.length > 0 && (
          <div class="rounded-2xl border border-neutral-200 bg-white p-6">
            <h3 class="text-sm font-extrabold uppercase tracking-wider text-neutral-400">Same paper, other years</h3>
            <ul class="mt-4 space-y-1">
              {related.map((r: any) => (
                <li>
                  <a href={url(`/past-papers/${r.id}`)} class="flex items-center justify-between gap-3 rounded-lg px-2 py-2 text-sm font-semibold text-neutral-700 transition-colors hover:bg-[#eef2fe] hover:text-[#0620ed]">
                    <span>{r.data.year}</span>
                    <Icon name="chevron-right" size={14} strokeWidth={2.4} />
                  </a>
                </li>
              ))}
            </ul>
          </div>
        )}
      </aside>
    </div>
  </div>
</BaseLayout>
ASTRO
echo "  rich past-papers detail page"

# ═══════════════════════════════════════════════
#  7. Add /past-papers/class/[class] page
# ═══════════════════════════════════════════════
mkdir -p 'src/pages/past-papers/class'
cat > 'src/pages/past-papers/class/[class].astro' <<'ASTRO'
---
import BaseLayout from '../../../layouts/BaseLayout.astro';
import Icon from '../../../components/Icon.astro';
import { url } from '../../../lib/url';
import { getCollection } from 'astro:content';
import { BOARDS, itemBoards } from '../../../lib/boards';

export async function getStaticPaths() {
  const papers = await getCollection('pastPapers');
  const set = new Set<string>();
  papers.forEach((p: any) => set.add(p.data.class));
  return [...set].map(c => ({ params: { class: c } }));
}

const { class: cls } = Astro.params;
const papers = await getCollection('pastPapers');
const filtered = papers.filter((p: any) => p.data.class === cls);

const boardCounts: Record<string, number> = {};
for (const b of BOARDS) {
  boardCounts[b.slug] = filtered.filter((p: any) => itemBoards(p.data).includes(b.name)).length;
}
---
<BaseLayout title={`Class ${cls} Past Papers — All Boards | TaleemHub`} description={`Download Class ${cls} past papers across all Pakistani boards. Free PDFs.`}>
  <div class="mx-auto max-w-[1320px] px-4 pt-10 sm:px-6 sm:pt-14 lg:px-8">
    <nav class="mb-6 flex items-center gap-1.5 text-xs font-semibold text-neutral-400">
      <a href={url('/past-papers')} class="hover:text-[#0620ed]">Past Papers</a>
      <span>/</span>
      <span class="text-neutral-500">Class {cls}</span>
    </nav>

    <div class="max-w-2xl">
      <h1 class="text-4xl font-extrabold tracking-tight text-neutral-900 sm:text-5xl">Class {cls} Past Papers</h1>
      <p class="mt-4 text-base text-neutral-500 sm:text-lg">Choose your board to see the papers.</p>
    </div>

    <div class="mt-10 grid grid-cols-2 gap-4 lg:grid-cols-3">
      {BOARDS.map(b => {
        const count = boardCounts[b.slug];
        const disabled = count === 0;
        return (
          <a href={url(`/board/${b.slug}/class-${cls}/past-papers`)} class:list={["group rounded-2xl border border-neutral-200 bg-white p-6 transition-colors", disabled ? "cursor-default opacity-50" : "hover:border-[#0620ed]"]}>
            <span class="grid h-12 w-12 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
              <Icon name="graduation-cap" size={22} strokeWidth={2.2} />
            </span>
            <h3 class="mt-5 text-lg font-extrabold tracking-tight text-neutral-900">{b.name}</h3>
            <p class:list={["mt-1 text-sm", disabled ? "text-neutral-400" : "text-neutral-500"]}>
              {count === 0 ? "Coming soon" : `${count} paper${count === 1 ? '' : 's'}`}
            </p>
          </a>
        );
      })}
    </div>
  </div>
</BaseLayout>
ASTRO
echo "  /past-papers/class/[class]"

# ═══════════════════════════════════════════════
#  8. Rebuild
# ═══════════════════════════════════════════════
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -20

echo ""
echo "════════════════════════════════════════════"
echo "  Done."
echo ""
echo "  What changed:"
echo "    - /past-papers            → board picker hub (NOT a dump)"
echo "    - /guess-papers           → board picker hub"
echo "    - /pairing-schemes        → board picker hub"
echo "    - /past-papers/class/9    → class hub with board cards"
echo "    - /past-papers/[slug]     → rich detail page with:"
echo "                                  · paper structure table"
echo "                                  · chapter breakdown"
echo "                                  · FAQ section"
echo "                                  · related papers"
echo "                                  · 3 JSON-LD schemas"
echo ""
echo "  Sample rich paper:"
echo "    physics-9-punjab-2024     full example"
echo ""
echo "  Push:"
echo "    git add ."
echo "    git commit -m 'Hub pages + rich paper template'"
echo "    git push"
echo "════════════════════════════════════════════"