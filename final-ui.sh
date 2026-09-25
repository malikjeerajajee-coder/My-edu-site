#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "════════════════════════════════════════════"
echo "  Full site — editorial design pass"
echo "════════════════════════════════════════════"
echo ""

git branch -f backup-pre-final-ui 2>/dev/null || true
echo "  ✓ backup-pre-final-ui created"
echo ""

# ═════════════════════════════════════════════════════════
#  HOMEPAGE
# ═════════════════════════════════════════════════════════
echo "▸ Homepage..."

cat > src/pages/index.astro <<'ASTRO'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { url } from '../lib/url';
import { BOARDS } from '../lib/boards';
import { getCollection } from 'astro:content';

const [notes, quizzes, books, gazettes, pastPapers, guessPapers, pairingSchemes] = await Promise.all([
  getCollection('notes'),
  getCollection('quizzes'),
  getCollection('books'),
  getCollection('gazettes'),
  getCollection('pastPapers'),
  getCollection('guessPapers'),
  getCollection('pairingSchemes'),
]);

const all = [...notes, ...quizzes, ...books, ...gazettes, ...pastPapers, ...guessPapers, ...pairingSchemes];

// Classes with content
const classSet = new Set<string>();
all.forEach((i: any) => classSet.add(String(i.data.class)));
const classes = [...classSet].sort((a, b) => Number(a) - Number(b));
const classCount = (c: string) => all.filter((i: any) => String(i.data.class) === c).length;

// Boards with content
const boardSet = new Set<string>();
books.forEach((b: any) => (b.data.boards || []).forEach((x: string) => boardSet.add(x)));
pastPapers.forEach((p: any) => (p.data.boards || []).forEach((x: string) => boardSet.add(x)));
gazettes.forEach((g: any) => (g.data.boards || []).forEach((x: string) => boardSet.add(x)));
const activeBoards = BOARDS.filter(b => boardSet.has(b.name));
const boardCount = (name: string) =>
  books.filter((b: any) => (b.data.boards || []).includes(name)).length +
  pastPapers.filter((p: any) => (p.data.boards || []).includes(name)).length +
  gazettes.filter((g: any) => (g.data.boards || []).includes(name)).length;

const resources = [
  { href: '/notes',           icon: 'file-text',     label: 'Notes',           desc: 'Chapter-wise revision notes', count: notes.length },
  { href: '/past-papers',     icon: 'scroll-text',   label: 'Past Papers',     desc: 'Official board exam papers',  count: pastPapers.length },
  { href: '/guess-papers',    icon: 'sparkles',      label: 'Guess Papers',    desc: 'Expected exam questions',     count: guessPapers.length },
  { href: '/pairing-schemes', icon: 'list',          label: 'Pairing Schemes', desc: 'Exam paper structure',        count: pairingSchemes.length },
  { href: '/quizzes',         icon: 'circle-help',   label: 'Quizzes',         desc: 'Interactive MCQs',            count: quizzes.length },
  { href: '/books',           icon: 'book-marked',   label: 'Textbooks',       desc: 'Official board textbooks',    count: books.length },
  { href: '/gazettes',        icon: 'newspaper',     label: 'Result Gazettes', desc: 'Board result documents',      count: gazettes.length },
];

const totalPages = all.length;

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'WebSite',
  name: 'Parhayi',
  alternateName: 'parhayi.com',
  url: 'https://parhayi.pages.dev/',
  description: 'Free notes, past papers, guess papers, textbooks and result gazettes for Pakistani students — organised by board, class and subject.',
  inLanguage: 'en',
  potentialAction: {
    '@type': 'SearchAction',
    target: 'https://parhayi.pages.dev/search/?q={search_term_string}',
    'query-input': 'required name=search_term_string',
  },
};
---
<BaseLayout
  title="Parhayi — Free Notes, Past Papers & Textbooks for Pakistani Students"
  description={`${totalPages.toLocaleString()} free study resources for Pakistani students — notes, past papers, guess papers, textbooks and result gazettes. Organised by board, class and subject.`}
  jsonLd={jsonLd}
>
  <!-- Hero -->
  <section class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-14 pb-16 sm:px-7 lg:px-10 lg:pt-20 lg:pb-24">
      <div class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-[#1d4ed8]">
        <span class="h-1.5 w-1.5 rounded-full bg-[#1d4ed8]"></span>
        Trusted by students across Pakistan
      </div>

      <h1 class="mt-6 max-w-4xl font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl lg:text-6xl">
        Study smarter. Score higher.
      </h1>

      <p class="mt-6 max-w-2xl text-base leading-relaxed text-slate-600 sm:text-lg">
        Free notes, past papers, guess papers, textbooks, quizzes and result gazettes — organised by <strong class="text-slate-900">board</strong>, <strong class="text-slate-900">class</strong> and <strong class="text-slate-900">subject</strong>.
      </p>

      <form action={url('/search')} method="get" role="search" class="mt-8 flex max-w-xl items-center gap-2 rounded-xl border border-slate-300 bg-white p-1.5 pl-4 transition-colors focus-within:border-[#1d4ed8]">
        <Icon name="search" size={18} strokeWidth={2.4} class="shrink-0 text-slate-400" />
        <input type="search" name="q" placeholder="Search notes, past papers, books…" class="min-w-0 flex-1 bg-transparent py-2.5 text-sm text-slate-900 outline-none placeholder:text-slate-400" />
        <button type="submit" class="rounded-lg bg-[#1d4ed8] px-5 py-2.5 text-sm font-bold text-white transition-colors hover:bg-[#1e3a8a]">Search</button>
      </form>

      <dl class="mt-12 grid grid-cols-2 gap-x-8 gap-y-6 sm:flex sm:flex-wrap sm:gap-x-14">
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Resources</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{totalPages.toLocaleString()}</dd>
        </div>
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Boards</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{activeBoards.length}</dd>
        </div>
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Classes</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{classes[0]}–{classes[classes.length - 1]}</dd>
        </div>
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Cost</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">Free</dd>
        </div>
      </dl>
    </div>
  </section>

  <!-- Choose your class -->
  <section class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
    <div class="mb-8">
      <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Choose your class</h2>
      <p class="mt-1.5 text-sm text-slate-500">Every class has its own notes, textbooks, past papers and quizzes.</p>
    </div>

    <div class="grid grid-cols-2 gap-px overflow-hidden rounded-2xl border border-slate-200 bg-slate-200 sm:grid-cols-4 lg:grid-cols-6">
      {classes.map(c => (
        <a href={url(`/class/${c}`)} class="group relative flex flex-col bg-white p-6 transition-colors hover:bg-slate-50">
          <span class="font-display text-3xl font-extrabold leading-none tracking-tight tabular-nums text-slate-900">
            {c.padStart(2, '0')}
          </span>
          <div class="mt-5 text-[13px] font-bold text-slate-900">Class {c}</div>
          <div class="mt-0.5 text-[11px] text-slate-500">{classCount(c).toLocaleString()} items</div>
          <div class="mt-4 flex items-center gap-1 text-[10px] font-bold uppercase tracking-[0.08em] text-slate-400 transition-colors group-hover:text-[#1d4ed8]">
            Open
            <Icon name="arrow-right" size={10} strokeWidth={2.8} />
          </div>
        </a>
      ))}
    </div>
  </section>

  <!-- Browse by board -->
  <section class="border-t border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
      <div class="mb-8">
        <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Browse by board</h2>
        <p class="mt-1.5 text-sm text-slate-500">Every board publishes its own papers, textbooks and gazettes.</p>
      </div>

      <div class="grid grid-cols-1 gap-px overflow-hidden rounded-2xl border border-slate-200 bg-slate-200 sm:grid-cols-2 lg:grid-cols-3">
        {activeBoards.map(b => (
          <a href={url(`/board/${b.slug}`)} class="group relative flex flex-col bg-white p-6 transition-colors hover:bg-slate-50">
            <div class="flex items-start justify-between gap-4">
              <h3 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">{b.name}</h3>
              <Icon name="arrow-up-right" size={16} strokeWidth={2.4} class="mt-1.5 text-slate-300 transition-all group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
            </div>
            <p class="mt-2 text-[13px] leading-relaxed text-slate-500">{b.full}</p>
            <div class="mt-6 text-[11px] font-bold uppercase tracking-[0.1em] text-slate-400">
              {boardCount(b.name).toLocaleString()} resources
            </div>
          </a>
        ))}
      </div>
    </div>
  </section>

  <!-- Browse by resource -->
  <section class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
    <div class="mb-8">
      <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Browse by resource</h2>
      <p class="mt-1.5 text-sm text-slate-500">Seven ways to study — all free, all board-specific.</p>
    </div>

    <div class="grid grid-cols-1 gap-px overflow-hidden rounded-2xl border border-slate-200 bg-slate-200 sm:grid-cols-2 lg:grid-cols-3">
      {resources.map(r => (
        <a href={url(r.href)} class="group relative flex flex-col bg-white p-6 transition-colors hover:bg-slate-50">
          <div class="flex items-start gap-4">
            <span class="grid h-10 w-10 shrink-0 place-items-center rounded-lg bg-slate-100 text-slate-600">
              <Icon name={r.icon} size={17} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <h3 class="font-display text-[16px] font-extrabold leading-tight tracking-tight text-slate-900">{r.label}</h3>
              <p class="mt-1 text-[12px] text-slate-500">{r.desc}</p>
            </div>
          </div>
          <div class="mt-6 flex items-center justify-between">
            <span class="text-[11px] font-bold uppercase tracking-[0.1em] text-slate-400">
              {r.count.toLocaleString()} {r.count === 1 ? 'item' : 'items'}
            </span>
            <span class="inline-flex items-center gap-1 text-[11px] font-bold uppercase tracking-[0.08em] text-slate-400 transition-colors group-hover:text-[#1d4ed8]">
              Browse
              <Icon name="arrow-right" size={11} strokeWidth={2.6} />
            </span>
          </div>
        </a>
      ))}
    </div>
  </section>

  <!-- Prose -->
  <section class="border-t border-slate-200 bg-white">
    <div class="mx-auto max-w-[820px] px-5 py-16 sm:px-7 lg:px-10">
      <div class="prose">
        <h2>Pakistan's complete study library</h2>
        <p>Every Pakistani student deserves free access to the material they need — the official notes, the past papers, the textbooks, and the result gazettes. Not scattered across WhatsApp groups and outdated websites, but organised the way the board exams actually work.</p>
        <p>Parhayi hosts <strong>{totalPages.toLocaleString()}+ free resources</strong> for Class 1 through Class 12, covering every major board in Pakistan: Punjab (PTB), Federal (FBISE), Sindh (STBB), Khyber Pakhtunkhwa (KPTBB), Balochistan (BTBB), and Azad Jammu and Kashmir (AJKTB).</p>
        <h3>How to find what you need</h3>
        <p>Pick your class, then your board, then your subject. Every resource — notes, past papers, textbooks, quizzes — is one click away. No sign-up. No paywall. No ads.</p>
        <h3>What you'll find</h3>
        <ul>
          <li><strong>Notes</strong> — chapter-wise summaries for every subject</li>
          <li><strong>Past papers</strong> — 2018 to 2026, from every BISE</li>
          <li><strong>Textbooks</strong> — the official PDFs from each board</li>
          <li><strong>Quizzes</strong> — interactive MCQs with instant feedback</li>
          <li><strong>Guess papers, pairing schemes, gazettes</strong> — the exam tools students actually use</li>
        </ul>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ Homepage"

# ═════════════════════════════════════════════════════════
#  /boards — all boards hub
# ═════════════════════════════════════════════════════════
echo "▸ /boards..."

cat > src/pages/boards.astro <<'ASTRO'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { url } from '../lib/url';
import { BOARDS } from '../lib/boards';
import { getCollection } from 'astro:content';

const [books, pastPapers, gazettes] = await Promise.all([
  getCollection('books'),
  getCollection('pastPapers'),
  getCollection('gazettes'),
]);

const count = (name: string) =>
  books.filter((b: any) => (b.data.boards || []).includes(name)).length +
  pastPapers.filter((p: any) => (p.data.boards || []).includes(name)).length +
  gazettes.filter((g: any) => (g.data.boards || []).includes(name)).length;

const boards = BOARDS.map(b => ({ ...b, count: count(b.name) }));

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  name: 'Pakistani Education Boards',
  description: `Browse textbooks, past papers and gazettes from every major Pakistani board — Punjab, Federal, Sindh, KPK, Balochistan, AJK.`,
};
---
<BaseLayout
  title="Pakistani Education Boards — Textbooks & Papers | Parhayi"
  description="Every major Pakistani education board — Punjab (PTB), Federal (FBISE), Sindh (STBB), KPK, Balochistan, AJK. Free textbooks, past papers and result gazettes."
  jsonLd={jsonLd}
>
  <section class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-12 pb-14 sm:px-7 lg:px-10 lg:pt-14 lg:pb-16">
      <nav class="mb-8 flex items-center gap-2 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">Boards</span>
      </nav>
      <h1 class="max-w-3xl font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl lg:text-6xl">
        Pakistani education boards.
      </h1>
      <p class="mt-6 max-w-2xl text-base leading-relaxed text-slate-600 sm:text-lg">
        Six provincial and federal boards. Every board publishes its own textbooks, past papers and result gazettes.
      </p>
    </div>
  </section>

  <section class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
    <div class="mb-8">
      <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Choose your board</h2>
      <p class="mt-1.5 text-sm text-slate-500">Each board publishes its own material — pick the one that matches your school.</p>
    </div>

    <div class="grid grid-cols-1 gap-px overflow-hidden rounded-2xl border border-slate-200 bg-slate-200 sm:grid-cols-2 lg:grid-cols-3">
      {boards.map(b => (
        <a href={url(`/board/${b.slug}`)} class="group relative flex flex-col bg-white p-7 transition-colors hover:bg-slate-50">
          <div class="flex items-start justify-between gap-4">
            <h3 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">{b.name}</h3>
            <Icon name="arrow-up-right" size={16} strokeWidth={2.4} class="mt-1.5 text-slate-300 transition-all group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
          </div>
          <p class="mt-2 text-[13px] leading-relaxed text-slate-500">{b.full}</p>
          <div class="mt-8 text-[11px] font-bold uppercase tracking-[0.1em] text-slate-400">
            {b.count.toLocaleString()} {b.count === 1 ? 'resource' : 'resources'}
          </div>
        </a>
      ))}
    </div>
  </section>

  <section class="border-t border-slate-200 bg-white">
    <div class="mx-auto max-w-[820px] px-5 py-16 sm:px-7 lg:px-10">
      <div class="prose">
        <h2>Which board am I in?</h2>
        <p>Your board depends on your school's location:</p>
        <ul>
          <li><strong>Punjab (PTB)</strong> — all schools in Punjab province</li>
          <li><strong>Federal (FBISE)</strong> — federal government schools, cadet colleges, and Pakistani schools abroad</li>
          <li><strong>Sindh (STBB)</strong> — all schools in Sindh</li>
          <li><strong>KPK (KPTBB)</strong> — all schools in Khyber Pakhtunkhwa</li>
          <li><strong>Balochistan (BTBB)</strong> — all schools in Balochistan</li>
          <li><strong>AJK (AJKTB)</strong> — all schools in Azad Jammu and Kashmir</li>
        </ul>
        <p>If you're not sure, ask your school office — they'll know exactly which board your exams are affiliated with.</p>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ /boards"

# ═════════════════════════════════════════════════════════
#  /class/[class] — class-first hub
# ═════════════════════════════════════════════════════════
echo "▸ /class/[class]..."

mkdir -p src/pages/class
cat > 'src/pages/class/[class].astro' <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { BOARDS } from '../../lib/boards';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const [notes, quizzes, books, gazettes, papers, guess, pairing] = await Promise.all([
    getCollection('notes'),
    getCollection('quizzes'),
    getCollection('books'),
    getCollection('gazettes'),
    getCollection('pastPapers'),
    getCollection('guessPapers'),
    getCollection('pairingSchemes'),
  ]);
  const set = new Set<string>();
  [...notes, ...quizzes, ...books, ...gazettes, ...papers, ...guess, ...pairing].forEach((i: any) => set.add(String(i.data.class)));
  return [...set].map(c => ({ params: { class: c } }));
}

const { class: cls } = Astro.params;

const [notes, quizzes, books, gazettes, papers, guess, pairing] = await Promise.all([
  getCollection('notes'),
  getCollection('quizzes'),
  getCollection('books'),
  getCollection('gazettes'),
  getCollection('pastPapers'),
  getCollection('guessPapers'),
  getCollection('pairingSchemes'),
]);

const filter = (arr: any[]) => arr.filter((i: any) => String(i.data.class) === cls);
const cNotes = filter(notes);
const cQuizzes = filter(quizzes);
const cBooks = filter(books);
const cGazettes = filter(gazettes);
const cPapers = filter(papers);
const cGuess = filter(guess);
const cPairing = filter(pairing);

const total = cNotes.length + cQuizzes.length + cBooks.length + cGazettes.length + cPapers.length + cGuess.length + cPairing.length;

// Boards offering this class
const boardSet = new Set<string>();
[...cBooks, ...cPapers, ...cGazettes].forEach((i: any) => (i.data.boards || []).forEach((x: string) => boardSet.add(x)));
const boards = BOARDS.filter(b => boardSet.has(b.name));

// Subjects this class covers
const subjectSet = new Set<string>();
[...cNotes, ...cQuizzes, ...cBooks].forEach((i: any) => subjectSet.add(i.data.subject));
const subjects = [...subjectSet].sort();

const resources = [
  { href: `/class/${cls}/notes`,    icon: 'file-text',     label: 'Notes',           count: cNotes.length },
  { href: `/class/${cls}/past-papers`, icon: 'scroll-text', label: 'Past Papers',     count: cPapers.length },
  { href: `/class/${cls}/guess-papers`, icon: 'sparkles',  label: 'Guess Papers',    count: cGuess.length },
  { href: `/class/${cls}/pairing-schemes`, icon: 'list',   label: 'Pairing Schemes', count: cPairing.length },
  { href: `/class/${cls}/quizzes`,  icon: 'circle-help',   label: 'Quizzes',         count: cQuizzes.length },
  { href: `/class/${cls}/books`,    icon: 'book-marked',   label: 'Textbooks',       count: cBooks.length },
  { href: `/class/${cls}/gazettes`, icon: 'newspaper',     label: 'Gazettes',        count: cGazettes.length },
].filter(r => r.count > 0);

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  name: `Class ${cls} Study Resources`,
  description: `Free notes, past papers, textbooks and quizzes for Class ${cls} students in Pakistan.`,
};
---
<BaseLayout
  title={`Class ${cls} — Notes, Past Papers & Books for Pakistani Students | Parhayi`}
  description={`Free Class ${cls} study material for every Pakistani board — notes, past papers, textbooks, quizzes and gazettes. ${total.toLocaleString()} resources.`}
  jsonLd={jsonLd}
>
  <section class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-12 pb-14 sm:px-7 lg:px-10 lg:pt-14 lg:pb-16">
      <nav class="mb-8 flex items-center gap-2 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">Class {cls}</span>
      </nav>
      <div class="text-[11px] font-bold uppercase tracking-[0.14em] text-[#1d4ed8]">Class {cls}</div>
      <h1 class="mt-3 font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl lg:text-6xl">
        Everything for Class {cls}.
      </h1>
      <p class="mt-6 max-w-2xl text-base leading-relaxed text-slate-600 sm:text-lg">
        {total.toLocaleString()} resources across {boards.length} boards and {subjects.length} subjects — all free.
      </p>
      <dl class="mt-10 flex flex-wrap gap-x-12 gap-y-4">
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Resources</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{total.toLocaleString()}</dd>
        </div>
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Boards</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{boards.length}</dd>
        </div>
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Subjects</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{subjects.length}</dd>
        </div>
      </dl>
    </div>
  </section>

  <section class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
    <div class="mb-8">
      <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Browse resources</h2>
      <p class="mt-1.5 text-sm text-slate-500">Every resource type for Class {cls}.</p>
    </div>

    <div class="grid grid-cols-1 gap-px overflow-hidden rounded-2xl border border-slate-200 bg-slate-200 sm:grid-cols-2 lg:grid-cols-3">
      {resources.map(r => (
        <a href={url(r.href)} class="group relative flex flex-col bg-white p-6 transition-colors hover:bg-slate-50">
          <div class="flex items-start gap-4">
            <span class="grid h-10 w-10 shrink-0 place-items-center rounded-lg bg-slate-100 text-slate-600">
              <Icon name={r.icon} size={17} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <h3 class="font-display text-[16px] font-extrabold leading-tight tracking-tight text-slate-900">{r.label}</h3>
              <p class="mt-1 text-[12px] text-slate-500">{r.count.toLocaleString()} {r.count === 1 ? 'item' : 'items'}</p>
            </div>
          </div>
          <div class="mt-6 flex items-center gap-1 text-[11px] font-bold uppercase tracking-[0.08em] text-slate-400 transition-colors group-hover:text-[#1d4ed8]">
            Browse
            <Icon name="arrow-right" size={11} strokeWidth={2.6} />
          </div>
        </a>
      ))}
    </div>
  </section>

  {boards.length > 0 && (
    <section class="border-t border-slate-200 bg-slate-50">
      <div class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
        <div class="mb-8">
          <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Boards offering Class {cls}</h2>
          <p class="mt-1.5 text-sm text-slate-500">Papers and textbooks are different for each board.</p>
        </div>

        <div class="grid grid-cols-1 gap-px overflow-hidden rounded-2xl border border-slate-200 bg-slate-200 sm:grid-cols-2 lg:grid-cols-3">
          {boards.map(b => (
            <a href={url(`/board/${b.slug}/class-${cls}`)} class="group relative flex flex-col bg-white p-6 transition-colors hover:bg-slate-50">
              <h3 class="font-display text-xl font-extrabold tracking-tight text-slate-900">{b.name}</h3>
              <p class="mt-1.5 text-[12px] text-slate-500">{b.full}</p>
              <div class="mt-6 flex items-center gap-1 text-[11px] font-bold uppercase tracking-[0.08em] text-slate-400 transition-colors group-hover:text-[#1d4ed8]">
                View Class {cls}
                <Icon name="arrow-right" size={11} strokeWidth={2.6} />
              </div>
            </a>
          ))}
        </div>
      </div>
    </section>
  )}

  <section class="border-t border-slate-200 bg-white">
    <div class="mx-auto max-w-[820px] px-5 py-16 sm:px-7 lg:px-10">
      <div class="prose">
        <h2>Class {cls} resources</h2>
        <p>Everything a Class {cls} student in Pakistan needs — notes, past papers, textbooks, quizzes, guess papers, pairing schemes, and result gazettes. All free, all downloadable as PDF.</p>
        <p>Pick a resource type above, or browse by board to see content specific to your exam board.</p>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ /class/[class]"

# ═════════════════════════════════════════════════════════
#  /past-papers — index
# ═════════════════════════════════════════════════════════
echo "▸ /past-papers..."

cat > src/pages/past-papers/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { BOARDS } from '../../lib/boards';
import { getCollection } from 'astro:content';

const papers = await getCollection('pastPapers');
const count = (name: string) => papers.filter((p: any) => (p.data.boards || []).includes(name)).length;
const boards = BOARDS.map(b => ({ ...b, count: count(b.name) })).filter(b => b.count > 0);

const classes = [...new Set(papers.map((p: any) => String(p.data.class)))].sort((a, b) => Number(a) - Number(b));
const years = [...new Set(papers.map((p: any) => p.data.year))].sort((a, b) => b - a);

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  name: 'Past Papers — Pakistani Board Exams',
  description: `${papers.length} past papers from every major Pakistani board. Class 9 to 12, all subjects, 2018–2026.`,
};
---
<BaseLayout
  title={`Past Papers — ${papers.length} Board Exam Papers 2018–2026 | Parhayi`}
  description={`Download ${papers.length} past papers from every Pakistani board. Punjab, Federal, Sindh, KPK, Balochistan, AJK. Class 9 to 12, all subjects.`}
  jsonLd={jsonLd}
>
  <section class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-12 pb-14 sm:px-7 lg:px-10 lg:pt-14 lg:pb-16">
      <nav class="mb-8 flex items-center gap-2 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">Past Papers</span>
      </nav>
      <h1 class="max-w-3xl font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl lg:text-6xl">
        Past papers from every board.
      </h1>
      <p class="mt-6 max-w-2xl text-base leading-relaxed text-slate-600 sm:text-lg">
        Official board exam papers from 2018 to 2026 — Class 9 to 12, all subjects, all boards. Free PDF downloads.
      </p>
      <dl class="mt-10 flex flex-wrap gap-x-12 gap-y-4">
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Papers</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{papers.length.toLocaleString()}</dd>
        </div>
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Boards</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{boards.length}</dd>
        </div>
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Years</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{years[years.length - 1]}–{years[0]}</dd>
        </div>
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Classes</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{classes[0]}–{classes[classes.length - 1]}</dd>
        </div>
      </dl>
    </div>
  </section>

  <section class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
    <div class="mb-8">
      <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Choose your board</h2>
      <p class="mt-1.5 text-sm text-slate-500">Papers are set by each board separately. Pick yours to see the right papers.</p>
    </div>

    <div class="grid grid-cols-1 gap-px overflow-hidden rounded-2xl border border-slate-200 bg-slate-200 sm:grid-cols-2 lg:grid-cols-3">
      {boards.map(b => (
        <a href={url(`/board/${b.slug}/class-9/past-papers`)} class="group relative flex flex-col bg-white p-7 transition-colors hover:bg-slate-50">
          <div class="flex items-start justify-between gap-4">
            <h3 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">{b.name}</h3>
            <Icon name="arrow-up-right" size={16} strokeWidth={2.4} class="mt-1.5 text-slate-300 transition-all group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
          </div>
          <p class="mt-2 text-[13px] leading-relaxed text-slate-500">{b.full}</p>
          <div class="mt-8 text-[11px] font-bold uppercase tracking-[0.1em] text-slate-400">
            {b.count.toLocaleString()} {b.count === 1 ? 'paper' : 'papers'}
          </div>
        </a>
      ))}
    </div>
  </section>

  <section class="border-t border-slate-200 bg-white">
    <div class="mx-auto max-w-[820px] px-5 py-16 sm:px-7 lg:px-10">
      <div class="prose">
        <h2>Why past papers matter</h2>
        <p>The single most effective way to prepare for a board exam is to work through its past papers. They show you exactly how questions are worded, which topics recur, and how much time each section really takes.</p>
        <p>Each of Pakistan's boards — Punjab, Federal, Sindh, KPK, Balochistan, and AJK — sets its own papers from the same syllabus. That means the questions differ even when the topics are the same. You need the papers from <strong>your</strong> board.</p>
        <h3>How to use these papers</h3>
        <ul>
          <li><strong>Start with the most recent paper</strong> — it reflects the current exam pattern best</li>
          <li><strong>Work backwards through the years</strong> — 3 to 5 years of papers is usually enough</li>
          <li><strong>Time yourself</strong> — the real value comes from practising under exam conditions</li>
          <li><strong>Mark your own answers</strong> — compare with model solutions where available</li>
        </ul>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ /past-papers"

# ═════════════════════════════════════════════════════════
#  /gazettes
# ═════════════════════════════════════════════════════════
echo "▸ /gazettes..."

cat > src/pages/gazettes/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { BOARDS } from '../../lib/boards';
import { getCollection } from 'astro:content';

const gazettes = await getCollection('gazettes');
const count = (name: string) => gazettes.filter((g: any) => (g.data.boards || []).includes(name)).length;
const boards = BOARDS.map(b => ({ ...b, count: count(b.name) })).filter(b => b.count > 0);
const years = [...new Set(gazettes.map((g: any) => g.data.year))].sort((a, b) => b - a);

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  name: 'Result Gazettes — Pakistani Boards',
  description: `${gazettes.length} result gazettes from every major Pakistani board. Class 9 to 12, 2018–2026.`,
};
---
<BaseLayout
  title={`Result Gazettes — ${gazettes.length} Board Results | Parhayi`}
  description={`Download ${gazettes.length} official result gazettes from Pakistani boards. Punjab, Federal, Sindh, KPK, Balochistan, AJK. Free PDFs.`}
  jsonLd={jsonLd}
>
  <section class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-12 pb-14 sm:px-7 lg:px-10 lg:pt-14 lg:pb-16">
      <nav class="mb-8 flex items-center gap-2 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">Result Gazettes</span>
      </nav>
      <h1 class="max-w-3xl font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl lg:text-6xl">
        Official result gazettes.
      </h1>
      <p class="mt-6 max-w-2xl text-base leading-relaxed text-slate-600 sm:text-lg">
        Download the official result gazettes from every Pakistani board. Free PDFs, 2018 to 2026.
      </p>
      <dl class="mt-10 flex flex-wrap gap-x-12 gap-y-4">
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Gazettes</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{gazettes.length.toLocaleString()}</dd>
        </div>
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Boards</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{boards.length}</dd>
        </div>
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Years</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{years[years.length - 1]}–{years[0]}</dd>
        </div>
      </dl>
    </div>
  </section>

  <section class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
    <div class="mb-8">
      <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Choose your board</h2>
      <p class="mt-1.5 text-sm text-slate-500">Every board publishes its own result gazettes.</p>
    </div>

    <div class="grid grid-cols-1 gap-px overflow-hidden rounded-2xl border border-slate-200 bg-slate-200 sm:grid-cols-2 lg:grid-cols-3">
      {boards.map(b => (
        <a href={url(`/board/${b.slug}`)} class="group relative flex flex-col bg-white p-7 transition-colors hover:bg-slate-50">
          <div class="flex items-start justify-between gap-4">
            <h3 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">{b.name}</h3>
            <Icon name="arrow-up-right" size={16} strokeWidth={2.4} class="mt-1.5 text-slate-300 transition-all group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
          </div>
          <p class="mt-2 text-[13px] leading-relaxed text-slate-500">{b.full}</p>
          <div class="mt-8 text-[11px] font-bold uppercase tracking-[0.1em] text-slate-400">
            {b.count.toLocaleString()} {b.count === 1 ? 'gazette' : 'gazettes'}
          </div>
        </a>
      ))}
    </div>
  </section>

  <section class="border-t border-slate-200 bg-white">
    <div class="mx-auto max-w-[820px] px-5 py-16 sm:px-7 lg:px-10">
      <div class="prose">
        <h2>What is a result gazette?</h2>
        <p>A result gazette is the official document published by each board after exams are marked. It lists every student's roll number, name, and marks — arranged by school and registration number. If you need to verify a result, apply for a duplicate certificate, or resolve a discrepancy, the gazette is the authoritative source.</p>
        <h3>When you need it</h3>
        <ul>
          <li><strong>Verification</strong> — proving your result to a college, university, or employer</li>
          <li><strong>Correction requests</strong> — if a printed result shows an error</li>
          <li><strong>Historical research</strong> — comparing results across years</li>
        </ul>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ /gazettes"

# ═════════════════════════════════════════════════════════
#  /guess-papers
# ═════════════════════════════════════════════════════════
echo "▸ /guess-papers..."

cat > src/pages/guess-papers/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { BOARDS } from '../../lib/boards';
import { getCollection } from 'astro:content';

const papers = await getCollection('guessPapers');
const count = (name: string) => papers.filter((p: any) => (p.data.boards || []).includes(name)).length;
const boards = BOARDS.map(b => ({ ...b, count: count(b.name) })).filter(b => b.count > 0);

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  name: 'Guess Papers — Pakistani Boards',
  description: `${papers.length} guess papers for Pakistani board students. Class 9 to 12, all subjects.`,
};
---
<BaseLayout
  title={`Guess Papers — Expected Exam Questions | Parhayi`}
  description={`Download ${papers.length} guess papers for Pakistani board exams. Class 9 to 12, all subjects, every board. Free PDFs.`}
  jsonLd={jsonLd}
>
  <section class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-12 pb-14 sm:px-7 lg:px-10 lg:pt-14 lg:pb-16">
      <nav class="mb-8 flex items-center gap-2 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">Guess Papers</span>
      </nav>
      <h1 class="max-w-3xl font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl lg:text-6xl">
        Guess papers, based on real exam patterns.
      </h1>
      <p class="mt-6 max-w-2xl text-base leading-relaxed text-slate-600 sm:text-lg">
        The most important questions likely to appear in your board exam — chosen from years of paper trends.
      </p>
      <dl class="mt-10 flex flex-wrap gap-x-12 gap-y-4">
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Papers</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{papers.length}</dd>
        </div>
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Boards</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{boards.length}</dd>
        </div>
      </dl>
    </div>
  </section>

  <section class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
    <div class="mb-8">
      <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Choose your board</h2>
      <p class="mt-1.5 text-sm text-slate-500">Each board's guess paper covers the subjects most likely to appear.</p>
    </div>

    {boards.length === 0 ? (
      <div class="rounded-2xl border border-dashed border-slate-300 bg-white p-12 text-center">
        <p class="text-sm font-bold text-slate-900">Guess papers coming soon</p>
      </div>
    ) : (
      <div class="grid grid-cols-1 gap-px overflow-hidden rounded-2xl border border-slate-200 bg-slate-200 sm:grid-cols-2 lg:grid-cols-3">
        {boards.map(b => (
          <a href={url(`/board/${b.slug}`)} class="group relative flex flex-col bg-white p-7 transition-colors hover:bg-slate-50">
            <div class="flex items-start justify-between gap-4">
              <h3 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">{b.name}</h3>
              <Icon name="arrow-up-right" size={16} strokeWidth={2.4} class="mt-1.5 text-slate-300 transition-all group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
            </div>
            <p class="mt-2 text-[13px] leading-relaxed text-slate-500">{b.full}</p>
            <div class="mt-8 text-[11px] font-bold uppercase tracking-[0.1em] text-slate-400">
              {b.count} {b.count === 1 ? 'paper' : 'papers'}
            </div>
          </a>
        ))}
      </div>
    )}
  </section>

  <section class="border-t border-slate-200 bg-white">
    <div class="mx-auto max-w-[820px] px-5 py-16 sm:px-7 lg:px-10">
      <div class="prose">
        <h2>What is a guess paper?</h2>
        <p>A guess paper is a curated set of the most likely exam questions for a specific subject, board, and class — compiled by looking at 5+ years of past papers to spot repeating patterns.</p>
        <p>Every guess paper on Parhayi is board-specific. A Punjab Class 10 Physics guess paper is different from a Federal Class 10 Physics guess paper, because the two boards test slightly different things.</p>
        <h3>How to use them</h3>
        <ul>
          <li><strong>Revise, don't replace</strong> — use the guess paper alongside the textbook, not instead of it</li>
          <li><strong>Check every topic</strong> — if a chapter appears in the guess paper, make sure you know it cold</li>
          <li><strong>Combine with past papers</strong> — real papers show you the exact difficulty; guess papers show you where to focus</li>
        </ul>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ /guess-papers"

# ═════════════════════════════════════════════════════════
#  /pairing-schemes
# ═════════════════════════════════════════════════════════
echo "▸ /pairing-schemes..."

cat > src/pages/pairing-schemes/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { BOARDS } from '../../lib/boards';
import { getCollection } from 'astro:content';

const schemes = await getCollection('pairingSchemes');
const count = (name: string) => schemes.filter((p: any) => (p.data.boards || []).includes(name)).length;
const boards = BOARDS.map(b => ({ ...b, count: count(b.name) })).filter(b => b.count > 0);

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  name: 'Pairing Schemes — Pakistani Boards',
  description: `${schemes.length} official pairing schemes for Pakistani board students. Class 9 to 12.`,
};
---
<BaseLayout
  title="Pairing Schemes — Official Paper Structure | Parhayi"
  description={`Download ${schemes.length} official pairing schemes. See exactly how marks are distributed across each board exam. Free PDFs.`}
  jsonLd={jsonLd}
>
  <section class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-12 pb-14 sm:px-7 lg:px-10 lg:pt-14 lg:pb-16">
      <nav class="mb-8 flex items-center gap-2 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">Pairing Schemes</span>
      </nav>
      <h1 class="max-w-3xl font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl lg:text-6xl">
        Know your paper before you sit it.
      </h1>
      <p class="mt-6 max-w-2xl text-base leading-relaxed text-slate-600 sm:text-lg">
        Official pairing schemes from every board — how marks are distributed, which chapters carry weight, and what the paper looks like.
      </p>
      <dl class="mt-10 flex flex-wrap gap-x-12 gap-y-4">
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Schemes</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{schemes.length}</dd>
        </div>
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Boards</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{boards.length}</dd>
        </div>
      </dl>
    </div>
  </section>

  <section class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
    <div class="mb-8">
      <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Choose your board</h2>
      <p class="mt-1.5 text-sm text-slate-500">Each board's pairing scheme shows how its papers are structured.</p>
    </div>

    {boards.length === 0 ? (
      <div class="rounded-2xl border border-dashed border-slate-300 bg-white p-12 text-center">
        <p class="text-sm font-bold text-slate-900">Pairing schemes coming soon</p>
      </div>
    ) : (
      <div class="grid grid-cols-1 gap-px overflow-hidden rounded-2xl border border-slate-200 bg-slate-200 sm:grid-cols-2 lg:grid-cols-3">
        {boards.map(b => (
          <a href={url(`/board/${b.slug}`)} class="group relative flex flex-col bg-white p-7 transition-colors hover:bg-slate-50">
            <div class="flex items-start justify-between gap-4">
              <h3 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">{b.name}</h3>
              <Icon name="arrow-up-right" size={16} strokeWidth={2.4} class="mt-1.5 text-slate-300 transition-all group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
            </div>
            <p class="mt-2 text-[13px] leading-relaxed text-slate-500">{b.full}</p>
            <div class="mt-8 text-[11px] font-bold uppercase tracking-[0.1em] text-slate-400">
              {b.count} {b.count === 1 ? 'scheme' : 'schemes'}
            </div>
          </a>
        ))}
      </div>
    )}
  </section>

  <section class="border-t border-slate-200 bg-white">
    <div class="mx-auto max-w-[820px] px-5 py-16 sm:px-7 lg:px-10">
      <div class="prose">
        <h2>What is a pairing scheme?</h2>
        <p>A pairing scheme (also called a paper pattern or assessment scheme) is the official document that shows exactly how an exam paper is structured — how many MCQs, how many short questions, how many long questions, and how the marks are distributed across chapters.</p>
        <p>Every board publishes its pairing scheme at the start of the academic year. Reading it tells you:</p>
        <ul>
          <li><strong>How many questions of each type</strong> to expect</li>
          <li><strong>Which chapters carry the most marks</strong></li>
          <li><strong>How much choice</strong> you'll have in the exam</li>
          <li><strong>How much time</strong> to spend on each section</li>
        </ul>
        <p>Students who read their pairing scheme study more efficiently — they know exactly where to focus their time.</p>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ /pairing-schemes"

# ═════════════════════════════════════════════════════════
#  Rebuild
# ═════════════════════════════════════════════════════════
echo ""
echo "Rebuilding..."
rm -rf dist .astro node_modules/.vite
npm run build 2>&1 | tail -10

echo ""
echo "════════════════════════════════════════════════════════"
echo "  DONE — 7 pages redesigned"
echo ""
echo "  Preview: bash start-server.sh"
echo ""
echo "  Check on mobile:"
echo "    /                        → homepage"
echo "    /boards                  → all boards"
echo "    /class/9                 → Class 9 hub"
echo "    /class/10                → Class 10 hub"
echo "    /past-papers             → past papers hub"
echo "    /gazettes                → gazettes hub"
echo "    /guess-papers            → guess papers hub"
echo "    /pairing-schemes         → pairing schemes hub"
echo ""
echo "  Design system now applied to:"
echo "    · Homepage"
echo "    · /boards"
echo "    · /class/[class]"
echo "    · 4 type indexes"
echo "  (Books, quizzes, notes already done)"
echo ""
echo "  Push when happy:"
echo "    git add . && git commit -m 'Full editorial UI pass' && git push"
echo ""
echo "  Revert: git checkout backup-pre-final-ui"
echo "════════════════════════════════════════════════════════"