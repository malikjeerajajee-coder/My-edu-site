#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "════════════════════════════════════════════"
echo "  Books section — professional redesign"
echo "  (no covers, clean rows, proper rhythm)"
echo "════════════════════════════════════════════"
echo ""

git branch -f backup-pre-books-clean 2>/dev/null || true
echo "  ✓ backup-pre-books-clean created"
echo ""

# ═════════════════════════════════════════════════════════
#  1. Delete BookCover entirely
# ═════════════════════════════════════════════════════════
rm -f src/components/BookCover.astro
echo "  ✓ Removed BookCover component"

# ═════════════════════════════════════════════════════════
#  2. Simplify SubjectIcon — smaller, subtler
# ═════════════════════════════════════════════════════════
cat > src/components/SubjectIcon.astro <<'ASTRO'
---
import Icon from './Icon.astro';

interface Props {
  subject: string;
  size?: 'sm' | 'md';
  class?: string;
}

const { subject, size = 'md', class: className = '' } = Astro.props;

const key = subject.toLowerCase()
  .replace(/\(.*?\)/g, '')
  .replace(/[^a-z\s]/g, '')
  .trim();

const MAP: Record<string, string> = {
  'english': 'feather', 'urdu': 'pen-tool', 'sindhi': 'pen-tool', 'punjabi': 'pen-tool',
  'farsi': 'pen-tool', 'arabic': 'languages', 'salees urdu': 'pen-tool', 'gulzar e urdu': 'pen-tool',
  'physics': 'atom', 'chemistry': 'flask', 'biology': 'leaf',
  'general science': 'microscope', 'science': 'microscope', 'bio tech': 'leaf',
  'mathematics': 'sigma', 'math': 'sigma', 'riazi': 'sigma', 'statistics': 'bar-chart',
  'general mathematics': 'sigma', 'geography': 'map', 'history': 'scroll',
  'islamiat': 'star', 'islamiyat': 'star', 'islamic studies': 'star',
  'pakistan studies': 'map', 'pak study': 'map', 'mutala e pakistan': 'map',
  'civics': 'landmark', 'economics': 'trending-up', 'psychology': 'brain', 'nafsiyat': 'brain',
  'education': 'graduation-cap', 'ilm ul taleem': 'graduation-cap',
  'tarjuma tul quran': 'book', 'translation quran': 'book', 'tarjuma tul quran majeed': 'book',
  'nazra quran': 'book', 'akhlaqiat': 'heart', 'mazhabi taleemat': 'heart',
  'religious studies': 'heart', 'buddhism': 'heart', 'sikhism': 'heart',
  'sanatan dharam': 'heart', 'zoroastrian religion': 'heart', 'mashi taleem': 'heart',
  'computer science': 'cpu', 'computer': 'cpu', 'computer education': 'cpu',
  'computer ki taleem': 'cpu', 'computer ji taleem': 'cpu', 'ict': 'cpu',
  'health physical education': 'activity', 'home economics': 'home',
  'art drawing': 'palette', 'general knowledge': 'lightbulb',
  'waqfiyat e aama': 'lightbulb', 'muasharti uloom': 'globe', 'social studies': 'globe',
};
const glyph = MAP[key] || 'book';

const sizes = {
  sm: { box: 32, icon: 15, radius: 8 },
  md: { box: 38, icon: 17, radius: 9 },
}[size];
---
<span
  class={className}
  style={`display:inline-grid;place-items:center;width:${sizes.box}px;height:${sizes.box}px;border-radius:${sizes.radius}px;background:#eff4ff;color:#1d4ed8;flex-shrink:0;`}
  aria-hidden="true"
>
  <Icon name={glyph} size={sizes.icon} strokeWidth={2.1} />
</span>
ASTRO
echo "  ✓ SubjectIcon simplified"

# ═════════════════════════════════════════════════════════
#  3. Class picker — clean horizontal rows
# ═════════════════════════════════════════════════════════
cat > 'src/pages/books/[board]/index.astro' <<'ASTRO'
---
import BaseLayout from '../../../layouts/BaseLayout.astro';
import Icon from '../../../components/Icon.astro';
import { url } from '../../../lib/url';
import { boardMeta, bookSubjectName } from '../../../lib/bookSeo';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const books = await getCollection('books');
  const boards = new Set<string>();
  books.forEach((b: any) => (b.data.boards || []).forEach((x: string) => boards.add(x)));
  return [...boards].map(b => ({ params: { board: b.toLowerCase() } }));
}

const { board: boardSlug } = Astro.params;
const allBooks = await getCollection('books');

const boardName = [...new Set(allBooks.flatMap((b: any) => b.data.boards || []))]
  .find(n => n.toLowerCase() === boardSlug);
if (!boardName) return Astro.redirect('/books');

const meta = boardMeta(boardName);
const books = allBooks.filter((b: any) => (b.data.boards || []).includes(boardName));

interface ClassData { cls: string; books: number; subjects: number; mediums: Set<string>; }
const classMap = new Map<string, ClassData>();
books.forEach((b: any) => {
  const cls = String(b.data.class);
  if (!classMap.has(cls)) classMap.set(cls, { cls, books: 0, subjects: 0, mediums: new Set() });
  const cd = classMap.get(cls)!;
  cd.books++;
  if (b.data.medium) cd.mediums.add(b.data.medium);
});
// count unique subjects per class
classMap.forEach(cd => {
  const subjs = new Set(
    books.filter((b: any) => String(b.data.class) === cd.cls).map((b: any) => bookSubjectName(b.data.subject))
  );
  cd.subjects = subjs.size;
});
const classes = [...classMap.values()].sort((a, b) => Number(a.cls) - Number(b.cls));

const totalSubjects = new Set(books.map((b: any) => bookSubjectName(b.data.subject))).size;

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  name: `${boardName} Textbooks — Class 1 to 12`,
  description: `Complete library of ${boardName} textbooks (${meta.abbreviation}). ${books.length} books for classes 1–12.`,
};
---
<BaseLayout
  title={`${boardName} Textbooks — Class 1 to 12 Free PDF | ${meta.abbreviation} | Parhayi`}
  description={`Download all ${boardName} textbooks free. ${books.length} books across ${classes.length} classes and ${totalSubjects} subjects.`}
  jsonLd={jsonLd}
>
  <!-- Header -->
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <a href={url('/books')} class="hover:text-[#1d4ed8]">Textbooks</a>
        <span>/</span>
        <span class="text-slate-500">{boardName}</span>
      </nav>
      <div class="flex flex-wrap items-start gap-4">
        <span class="inline-flex items-center rounded-md border border-[#c7d7fe] bg-[#eff4ff] px-3 py-1.5 text-[12px] font-bold uppercase tracking-[0.06em] text-[#1d4ed8]">
          {meta.abbreviation}
        </span>
      </div>
      <h1 class="mt-4 text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">{boardName} Textbooks</h1>
      <p class="mt-3 max-w-2xl text-base leading-relaxed text-slate-600">
        Every {boardName} textbook from Class 1 to Class 12 — free PDF downloads, no sign-up.
      </p>
      <div class="mt-6 flex flex-wrap gap-x-8 gap-y-2 text-sm">
        <div>
          <span class="font-display text-lg font-extrabold text-slate-900">{books.length}</span>
          <span class="ml-1 text-slate-500">books</span>
        </div>
        <div>
          <span class="font-display text-lg font-extrabold text-slate-900">{classes.length}</span>
          <span class="ml-1 text-slate-500">classes</span>
        </div>
        <div>
          <span class="font-display text-lg font-extrabold text-slate-900">{totalSubjects}</span>
          <span class="ml-1 text-slate-500">subjects</span>
        </div>
      </div>
    </div>
  </div>

  <!-- Class list -->
  <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
    <h2 class="text-lg font-extrabold tracking-tight text-slate-900">Choose your class</h2>
    <p class="mt-1 text-sm text-slate-500">Every class has its own set of textbooks.</p>

    <ul class="mt-6 divide-y divide-slate-200 border-y border-slate-200">
      {classes.map(c => (
        <li>
          <a href={url(`/books/${boardSlug}/class-${c.cls}`)} class="group flex items-center gap-5 py-4 transition-colors hover:bg-slate-50">
            <!-- Class number -->
            <span class="w-12 shrink-0 font-display text-2xl font-extrabold tracking-tight text-slate-900 tabular-nums">
              {c.cls.padStart(2, '0')}
            </span>

            <!-- Title + meta -->
            <div class="min-w-0 flex-1">
              <div class="text-[15px] font-bold tracking-tight text-slate-900">Class {c.cls}</div>
              <div class="mt-0.5 text-[13px] text-slate-500">
                {c.subjects} {c.subjects === 1 ? 'subject' : 'subjects'}
                <span class="mx-1.5 text-slate-300">·</span>
                {c.books} {c.books === 1 ? 'book' : 'books'}
              </div>
            </div>

            <!-- Chevron -->
            <Icon name="arrow-right" size={16} strokeWidth={2.2} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
          </a>
        </li>
      ))}
    </ul>
  </div>

  <!-- SEO copy -->
  <section class="border-t border-slate-200 bg-white">
    <div class="mx-auto max-w-[820px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
      <div class="prose">
        <h2>About {boardName} textbooks</h2>
        <p>{meta.description}</p>
        <h3>What's included</h3>
        <ul>
          <li><strong>{classes.length} classes</strong> — every year from Class {classes[0].cls} through Class {classes[classes.length - 1].cls}</li>
          <li><strong>{totalSubjects} subjects</strong> — Mathematics, English, Urdu, Islamiat, and every other subject published by the board</li>
          <li><strong>Free PDF downloads</strong> — no sign-up, no paywall, no ads</li>
        </ul>
        <h3>How to download</h3>
        <p>Choose your class above, find the subject you need, and click Download PDF. Every textbook opens directly in your browser or saves to your device.</p>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ Class picker rebuilt"

# ═════════════════════════════════════════════════════════
#  4. Subject list — clean, grouped, no covers
# ═════════════════════════════════════════════════════════
cat > 'src/pages/books/[board]/[class].astro' <<'ASTRO'
---
import BaseLayout from '../../../layouts/BaseLayout.astro';
import Icon from '../../../components/Icon.astro';
import SubjectIcon from '../../../components/SubjectIcon.astro';
import { url } from '../../../lib/url';
import { boardMeta, bookSubjectName } from '../../../lib/bookSeo';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const books = await getCollection('books');
  const paths: any[] = [];
  const seen = new Set<string>();
  books.forEach((b: any) => {
    const board = (b.data.boards || [])[0];
    if (!board) return;
    const key = `${board.toLowerCase()}/class-${b.data.class}`;
    if (!seen.has(key)) {
      seen.add(key);
      paths.push({ params: { board: board.toLowerCase(), class: `class-${b.data.class}` } });
    }
  });
  return paths;
}

const { board: boardSlug, class: classParam } = Astro.params;
const cls = String(classParam).replace(/^class-/, '');
const allBooks = await getCollection('books');

const boardName = [...new Set(allBooks.flatMap((b: any) => b.data.boards || []))]
  .find(n => n.toLowerCase() === boardSlug);
if (!boardName) return Astro.redirect('/books');

const meta = boardMeta(boardName);
const books = allBooks
  .filter((b: any) => (b.data.boards || []).includes(boardName) && String(b.data.class) === cls);

// Sort: new scheme first, then year desc, then subject
books.sort((a: any, b: any) => {
  const score = (x: any) => x.data.scheme === 'new' ? 3 : x.data.scheme === 'snc' ? 2 : x.data.scheme === 'previous' ? 1 : 2;
  if (score(a) !== score(b)) return score(b) - score(a);
  const ay = a.data.year || '', by = b.data.year || '';
  if (ay !== by) return by.localeCompare(ay);
  return a.data.subject.localeCompare(b.data.subject);
});

const subjects = [...new Set(books.map((b: any) => bookSubjectName(b.data.subject)))].sort();

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  name: `Class ${cls} ${boardName} Textbooks — All Subjects`,
  description: `Download all Class ${cls} ${boardName} textbooks free. ${subjects.length} subjects available.`,
};
---
<BaseLayout
  title={`Class ${cls} ${boardName} Textbooks — All Subjects Free PDF | ${meta.abbreviation} | Parhayi`}
  description={`Download all Class ${cls} ${boardName} textbook PDFs. ${subjects.length} subjects including ${subjects.slice(0, 4).join(', ')}. Free, no sign-up.`}
  jsonLd={jsonLd}
>
  <!-- Header -->
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-12 lg:pb-12">
      <nav class="mb-5 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <a href={url('/books')} class="hover:text-[#1d4ed8]">Textbooks</a>
        <span>/</span>
        <a href={url(`/books/${boardSlug}`)} class="hover:text-[#1d4ed8]">{boardName}</a>
        <span>/</span>
        <span class="text-slate-500">Class {cls}</span>
      </nav>
      <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">
        Class {cls} · {boardName}
      </h1>
      <p class="mt-3 max-w-2xl text-base leading-relaxed text-slate-600">
        {books.length} textbooks across {subjects.length} subjects — all free PDF downloads.
      </p>
    </div>
  </div>

  <!-- Subjects list -->
  <div class="mx-auto max-w-[1200px] px-5 py-10 sm:px-7 lg:px-10 lg:py-12">
    <ul class="divide-y divide-slate-200 border-y border-slate-200">
      {books.map(b => {
        const subj = bookSubjectName(b.data.subject);
        const schemeLabel = b.data.scheme === 'new' ? 'New' : b.data.scheme === 'snc' ? 'SNC' : b.data.scheme === 'previous' ? 'Previous' : '';
        const mediumLabel = b.data.medium === 'english' ? 'English Medium' : b.data.medium === 'urdu' ? 'Urdu Medium' : b.data.medium === 'sindhi' ? 'Sindhi Medium' : '';
        return (
          <li>
            <a href={url(`/textbook/${b.id}`)} class="group flex items-center gap-4 py-4 transition-colors hover:bg-slate-50">
              <SubjectIcon subject={subj} size="md" />

              <div class="min-w-0 flex-1">
                <div class="flex flex-wrap items-center gap-x-2 gap-y-1">
                  <span class="text-[15px] font-bold tracking-tight text-slate-900">{subj}</span>
                  {schemeLabel && (
                    <span class="rounded bg-[#eff4ff] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wider text-[#1d4ed8]">{schemeLabel}</span>
                  )}
                </div>
                <div class="mt-0.5 flex flex-wrap items-center gap-x-2 gap-y-0.5 text-[13px] text-slate-500">
                  {mediumLabel && <span>{mediumLabel}</span>}
                  {mediumLabel && b.data.year && <span class="text-slate-300">·</span>}
                  {b.data.year && <span>{b.data.year}</span>}
                  {!mediumLabel && !b.data.year && <span>Current edition</span>}
                </div>
              </div>

              <Icon name="arrow-right" size={16} strokeWidth={2.2} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
            </a>
          </li>
        );
      })}
    </ul>
  </div>

  <!-- SEO copy -->
  <section class="border-t border-slate-200 bg-white">
    <div class="mx-auto max-w-[820px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
      <div class="prose">
        <h2>Class {cls} {boardName} textbooks</h2>
        <p>
          Class {cls} is a critical year in the {boardName} system. The {subjects.length} subjects listed above are the official textbooks published by the {meta.authority}. Every textbook is available as a free PDF download.
        </p>
        <h3>Subjects in Class {cls}</h3>
        <ul>
          {subjects.map(s => <li><strong>{s}</strong> — official {boardName} textbook</li>)}
        </ul>
        <h3>Mediums and editions</h3>
        <p>Where the board publishes both English medium (EM) and Urdu medium (UM) editions, both are listed. If a subject has been revised under the current Single National Curriculum (SNC), the newest edition is shown first with its year clearly tagged.</p>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ Subject list rebuilt"

# ═════════════════════════════════════════════════════════
#  5. Book detail — no cover, clean editorial layout
# ═════════════════════════════════════════════════════════
cat > 'src/pages/textbook/[...slug].astro' <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import SubjectIcon from '../../components/SubjectIcon.astro';
import { url } from '../../lib/url';
import { boardMeta, bookSeoTitle, bookSeoDescription, bookSubjectName, subjectSlug } from '../../lib/bookSeo';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const books = await getCollection('books');
  return books.map((book: any) => ({ params: { slug: book.id }, props: { book } }));
}

const { book } = Astro.props;
const d = book.data;
const boardName = (d.boards || [])[0] || 'Punjab';
const meta = boardMeta(boardName);
const subj = bookSubjectName(d.subject);
const boardSlug = boardName.toLowerCase();
const subjSlug = subjectSlug(subj);

const canonical = `https://malikjeerajajee-coder.github.io/My-edu-site/textbook/${book.id}/`;

const allBooks = await getCollection('books');
const relatedBooks = allBooks
  .filter((b: any) =>
    b.id !== book.id &&
    (b.data.boards || []).includes(boardName) &&
    String(b.data.class) === String(d.class)
  )
  .slice(0, 6);

const [notes, quizzes, papers] = await Promise.all([
  getCollection('notes'),
  getCollection('quizzes'),
  getCollection('pastPapers'),
]);
const slugMatch = (s: string) => subjectSlug(bookSubjectName(s)) === subjSlug;
const classMatch = (c: string) => String(c) === String(d.class);

const relatedNotes = notes.filter((n: any) => slugMatch(n.data.subject) && classMatch(n.data.class)).slice(0, 4);
const relatedQuizzes = quizzes.filter((q: any) => slugMatch(q.data.subject) && classMatch(q.data.class)).slice(0, 4);
const relatedPapers = papers.filter((p: any) =>
  slugMatch(p.data.subject) && classMatch(p.data.class) &&
  (p.data.boards || []).some((b: string) => b === boardName)
).slice(0, 4);

const hasRelated = relatedNotes.length + relatedQuizzes.length + relatedPapers.length > 0;

const mediumLabel = d.medium === 'english' ? 'English Medium' : d.medium === 'urdu' ? 'Urdu Medium' : d.medium === 'sindhi' ? 'Sindhi Medium' : '';
const schemeLabel = d.scheme === 'new' ? `New ${d.year || ''}` : d.scheme === 'snc' ? `SNC ${d.year || ''}` : d.scheme === 'previous' ? `Previous ${d.year || ''}` : (d.year || '');

const jsonLd = [
  {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: [
      { '@type': 'ListItem', position: 1, name: 'Home', item: 'https://malikjeerajajee-coder.github.io/My-edu-site/' },
      { '@type': 'ListItem', position: 2, name: 'Textbooks', item: 'https://malikjeerajajee-coder.github.io/My-edu-site/books/' },
      { '@type': 'ListItem', position: 3, name: boardName, item: `https://malikjeerajajee-coder.github.io/My-edu-site/books/${boardSlug}/` },
      { '@type': 'ListItem', position: 4, name: `Class ${d.class}`, item: `https://malikjeerajajee-coder.github.io/My-edu-site/books/${boardSlug}/class-${d.class}/` },
      { '@type': 'ListItem', position: 5, name: subj },
    ],
  },
  {
    '@context': 'https://schema.org',
    '@type': 'Book',
    name: `${subj} — Class ${d.class}`,
    bookEdition: d.year || undefined,
    inLanguage: d.medium === 'urdu' ? 'ur' : d.medium === 'sindhi' ? 'sd' : 'en',
    publisher: { '@type': 'Organization', name: meta.authority },
    educationalLevel: `Class ${d.class}`,
    learningResourceType: 'Textbook',
    about: subj,
    url: canonical,
  },
];
---
<BaseLayout title={bookSeoTitle(book)} description={bookSeoDescription(book)} jsonLd={jsonLd}>
  <!-- Header -->
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1100px] px-5 pt-8 pb-12 sm:px-7 lg:px-10 lg:pt-10 lg:pb-14">
      <nav class="mb-8 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <a href={url('/books')} class="hover:text-[#1d4ed8]">Textbooks</a>
        <span>/</span>
        <a href={url(`/books/${boardSlug}`)} class="hover:text-[#1d4ed8]">{boardName}</a>
        <span>/</span>
        <a href={url(`/books/${boardSlug}/class-${d.class}`)} class="hover:text-[#1d4ed8]">Class {d.class}</a>
        <span>/</span>
        <span class="text-slate-500">{subj}</span>
      </nav>

      <div class="flex items-start gap-5 sm:gap-6">
        <SubjectIcon subject={subj} size="md" class="mt-1" />
        <div class="min-w-0 flex-1">
          <div class="flex flex-wrap gap-x-3 gap-y-1.5 text-[11px] font-bold uppercase tracking-[0.08em] text-slate-400">
            <span>{meta.abbreviation}</span>
            <span>·</span>
            <span>Class {d.class}</span>
            {mediumLabel && <><span>·</span><span>{mediumLabel}</span></>}
            {schemeLabel && <><span>·</span><span class="text-[#1d4ed8]">{schemeLabel}</span></>}
          </div>
          <h1 class="mt-3 text-3xl font-extrabold leading-tight tracking-tight text-slate-900 sm:text-4xl">
            {subj} — Class {d.class}
          </h1>
          <p class="mt-3 max-w-2xl text-base leading-relaxed text-slate-600">
            Official {meta.abbreviation} textbook for Class {d.class} {subj}. {d.year ? `${d.year} edition.` : 'Current edition.'} Free PDF download.
          </p>

          <div class="mt-7 flex flex-wrap items-center gap-3">
            <a href={d.pdfUrl} target="_blank" rel="noopener"
               class="inline-flex items-center gap-2 rounded-lg bg-[#1d4ed8] px-5 py-3 text-sm font-bold text-white transition-colors hover:bg-[#1e3a8a]">
              <Icon name="download" size={16} strokeWidth={2.4} /> Download PDF
            </a>
            <a href={url(`/books/${boardSlug}/class-${d.class}`)}
               class="inline-flex items-center gap-2 rounded-lg border border-slate-300 bg-white px-5 py-3 text-sm font-bold text-slate-700 transition-colors hover:border-slate-400">
              All Class {d.class} books
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Content -->
  <div class="mx-auto max-w-[820px] px-5 py-12 sm:px-7 lg:px-10 lg:py-16">
    <article class="prose">
      <h2>About this textbook</h2>
      <p>
        This is the official {subj} textbook for Class {d.class} students, published by the {meta.authority}. Every chapter, worked example, and exercise corresponds directly to the questions asked in {boardName} board exams.
      </p>
      <p>{meta.description}</p>
      <h3>Why download the official textbook?</h3>
      <ul>
        <li><strong>Complete coverage</strong> — everything that can appear in your exam is drawn from this book</li>
        <li><strong>Offline access</strong> — download once, study anywhere without internet</li>
        <li><strong>Free forever</strong> — no sign-up, no ads, no subscription</li>
      </ul>
      <h3>How to use this book effectively</h3>
      <p>
        Start with the chapter summaries, work through the worked examples, then attempt the end-of-chapter exercises. Compare your answers against the model solutions in the {subj} notes section on Parhayi.
      </p>
    </article>
  </div>

  {hasRelated && (
    <div class="border-t border-slate-200 bg-slate-50">
      <div class="mx-auto max-w-[1100px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
        <h2 class="text-lg font-extrabold tracking-tight text-slate-900">Related study material</h2>
        <p class="mt-1 text-sm text-slate-500">More free resources for {subj} Class {d.class} {boardName}.</p>

        {relatedNotes.length > 0 && (
          <section class="mt-8">
            <h3 class="text-[11px] font-bold uppercase tracking-[0.1em] text-slate-400">Notes</h3>
            <ul class="mt-3 divide-y divide-slate-200 border-y border-slate-200 bg-white">
              {relatedNotes.map((n: any) => (
                <li>
                  <a href={url(`/notes/${n.id}`)} class="group flex items-center gap-3 px-4 py-3 transition-colors hover:bg-slate-50">
                    <span class="min-w-0 flex-1 truncate text-sm font-semibold text-slate-900">{n.data.title}</span>
                    <Icon name="arrow-right" size={14} strokeWidth={2.4} class="shrink-0 text-slate-300 group-hover:text-[#1d4ed8]" />
                  </a>
                </li>
              ))}
            </ul>
          </section>
        )}

        {relatedQuizzes.length > 0 && (
          <section class="mt-8">
            <h3 class="text-[11px] font-bold uppercase tracking-[0.1em] text-slate-400">Quizzes</h3>
            <ul class="mt-3 divide-y divide-slate-200 border-y border-slate-200 bg-white">
              {relatedQuizzes.map((q: any) => (
                <li>
                  <a href={url(`/quizzes/${q.id}`)} class="group flex items-center gap-3 px-4 py-3 transition-colors hover:bg-slate-50">
                    <span class="min-w-0 flex-1 truncate text-sm font-semibold text-slate-900">{q.data.title}</span>
                    <span class="shrink-0 text-[11px] font-bold text-slate-400">{q.data.questions?.length || 0} MCQs</span>
                    <Icon name="arrow-right" size={14} strokeWidth={2.4} class="shrink-0 text-slate-300 group-hover:text-[#1d4ed8]" />
                  </a>
                </li>
              ))}
            </ul>
          </section>
        )}

        {relatedPapers.length > 0 && (
          <section class="mt-8">
            <h3 class="text-[11px] font-bold uppercase tracking-[0.1em] text-slate-400">Past papers</h3>
            <ul class="mt-3 divide-y divide-slate-200 border-y border-slate-200 bg-white">
              {relatedPapers.map((p: any) => (
                <li>
                  <a href={url(`/past-papers/${p.id}`)} class="group flex items-center gap-3 px-4 py-3 transition-colors hover:bg-slate-50">
                    <span class="min-w-0 flex-1 truncate text-sm font-semibold text-slate-900">{p.data.subject} — {p.data.year}</span>
                    <span class="shrink-0 text-[11px] font-bold text-slate-400">{p.data.bise ? `BISE ${p.data.bise}` : p.data.boards?.[0]}</span>
                    <Icon name="arrow-right" size={14} strokeWidth={2.4} class="shrink-0 text-slate-300 group-hover:text-[#1d4ed8]" />
                  </a>
                </li>
              ))}
            </ul>
          </section>
        )}
      </div>
    </div>
  )}

  {relatedBooks.length > 0 && (
    <div class="border-t border-slate-200 bg-white">
      <div class="mx-auto max-w-[1100px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
        <h2 class="text-lg font-extrabold tracking-tight text-slate-900">Other Class {d.class} {boardName} textbooks</h2>
        <ul class="mt-5 divide-y divide-slate-200 border-y border-slate-200">
          {relatedBooks.map((b: any) => (
            <li>
              <a href={url(`/textbook/${b.id}`)} class="group flex items-center gap-3 py-3 transition-colors hover:bg-slate-50">
                <SubjectIcon subject={bookSubjectName(b.data.subject)} size="sm" />
                <span class="min-w-0 flex-1">
                  <span class="block truncate text-sm font-semibold text-slate-900">{bookSubjectName(b.data.subject)}</span>
                  {b.data.year && <span class="block text-[12px] text-slate-500">{b.data.year}</span>}
                </span>
                <Icon name="arrow-right" size={14} strokeWidth={2.4} class="shrink-0 text-slate-300 group-hover:text-[#1d4ed8]" />
              </a>
            </li>
          ))}
        </ul>
      </div>
    </div>
  )}

  <div class="mx-auto max-w-[1100px] px-5 pb-16 pt-8 sm:px-7 lg:px-10">
    <a href={url(`/books/${boardSlug}/class-${d.class}`)} class="inline-flex items-center gap-2 text-sm font-semibold text-slate-500 hover:text-[#1d4ed8]">
      <Icon name="arrow-left" size={16} strokeWidth={2.4} /> Back to Class {d.class} {boardName}
    </a>
  </div>
</BaseLayout>
ASTRO
echo "  ✓ Book detail rebuilt"

# ═════════════════════════════════════════════════════════
#  6. Simplify /books — same treatment as class picker
# ═════════════════════════════════════════════════════════
cat > src/pages/books/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { getCollection } from 'astro:content';

const books = await getCollection('books');

const boardCounts = new Map<string, number>();
books.forEach((b: any) => {
  const board = (b.data.boards || [])[0];
  if (board) boardCounts.set(board, (boardCounts.get(board) || 0) + 1);
});

const ORDER = ['Punjab', 'Federal', 'Sindh', 'KPK', 'Balochistan', 'AJK'];
const boards = [...boardCounts.keys()].sort((a, b) => {
  const ai = ORDER.indexOf(a), bi = ORDER.indexOf(b);
  if (ai === -1 && bi === -1) return a.localeCompare(b);
  if (ai === -1) return 1;
  if (bi === -1) return -1;
  return ai - bi;
});

const META: Record<string, { short: string; desc: string }> = {
  'Punjab':      { short: 'PTB',   desc: 'Punjab Curriculum and Textbook Board' },
  'Federal':     { short: 'FBISE', desc: 'Federal Board of Intermediate and Secondary Education' },
  'Sindh':       { short: 'STBB',  desc: 'Sindh Textbook Board' },
  'KPK':         { short: 'KPTBB', desc: 'Khyber Pakhtunkhwa Textbook Board' },
  'Balochistan': { short: 'BTBB',  desc: 'Balochistan Textbook Board' },
  'AJK':         { short: 'AJKTB', desc: 'AJK Textbook Board' },
};

const totalBooks = books.length;

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  name: 'Pakistani Textbooks — Free PDF Library',
  description: `Complete library of official Pakistani textbooks — ${totalBooks} books from Punjab (PTB), Federal (FBISE), Sindh (STBB), Balochistan (BTBB).`,
};
---
<BaseLayout
  title="Pakistani Textbooks — Free PDF Library Class 1 to 12 | Parhayi"
  description={`Download official Pakistani textbooks free. ${totalBooks} books from Punjab (PTB), Federal (FBISE), Sindh (STBB), Balochistan (BTBB). Class 1–12.`}
  jsonLd={jsonLd}
>
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">Textbooks</span>
      </nav>
      <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">Pakistani Textbooks</h1>
      <p class="mt-3 max-w-2xl text-base leading-relaxed text-slate-600">
        Official textbooks from every major Pakistani board — free PDF downloads, no sign-up.
      </p>
      <div class="mt-6 flex flex-wrap gap-x-8 gap-y-2 text-sm">
        <div>
          <span class="font-display text-lg font-extrabold text-slate-900">{totalBooks}</span>
          <span class="ml-1 text-slate-500">books</span>
        </div>
        <div>
          <span class="font-display text-lg font-extrabold text-slate-900">{boards.length}</span>
          <span class="ml-1 text-slate-500">boards</span>
        </div>
        <div>
          <span class="font-display text-lg font-extrabold text-slate-900">1–12</span>
          <span class="ml-1 text-slate-500">classes</span>
        </div>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
    <h2 class="text-lg font-extrabold tracking-tight text-slate-900">Choose your board</h2>
    <p class="mt-1 text-sm text-slate-500">Each board publishes its own textbooks.</p>

    <ul class="mt-6 divide-y divide-slate-200 border-y border-slate-200">
      {boards.map(b => {
        const t = META[b] || { short: b, desc: `${b} Textbook Board` };
        const count = boardCounts.get(b) || 0;
        return (
          <li>
            <a href={url(`/books/${b.toLowerCase()}`)} class="group flex items-center gap-5 py-5 transition-colors hover:bg-slate-50">
              <span class="inline-flex w-[64px] shrink-0 items-center justify-center rounded-md border border-[#c7d7fe] bg-[#eff4ff] px-2 py-1.5 text-[11px] font-bold uppercase tracking-wider text-[#1d4ed8]">
                {t.short}
              </span>

              <div class="min-w-0 flex-1">
                <div class="text-[15px] font-bold tracking-tight text-slate-900">{b}</div>
                <div class="mt-0.5 text-[13px] text-slate-500">{t.desc}</div>
              </div>

              <span class="hidden shrink-0 text-[12px] font-semibold uppercase tracking-wide text-slate-400 sm:inline">
                {count} {count === 1 ? 'book' : 'books'}
              </span>

              <Icon name="arrow-right" size={16} strokeWidth={2.2} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
            </a>
          </li>
        );
      })}
    </ul>
  </div>

  <section class="border-t border-slate-200 bg-white">
    <div class="mx-auto max-w-[820px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
      <div class="prose">
        <h2>Pakistan's complete textbook library</h2>
        <p>Textbooks are the foundation of every board exam. Whether you're in Class 1 learning your first Urdu letters or in Class 12 preparing for your HSSC exams, the right textbook is the starting point for everything else.</p>
        <p>Parhayi hosts the official textbooks published by Pakistan's four largest education boards — the <strong>Punjab Textbook Board (PTB / PCTB)</strong>, the <strong>Federal Board (FBISE)</strong>, the <strong>Sindh Textbook Board (STBB)</strong>, and the <strong>Balochistan Textbook Board (BTBB)</strong> — plus resources from Khyber Pakhtunkhwa and Azad Jammu and Kashmir.</p>
        <h3>What you'll find here</h3>
        <ul>
          <li><strong>Every class from 1 to 12</strong>, from primary through intermediate</li>
          <li><strong>Every subject</strong> — Mathematics, Physics, Chemistry, Biology, English, Urdu, Islamiat, Pakistan Studies, Computer Science, and more</li>
          <li><strong>Every medium</strong> — English medium (EM), Urdu medium (UM), and Sindhi medium where relevant</li>
          <li><strong>Every scheme</strong> — current SNC, previous scheme, and the newest 2025–27 editions</li>
        </ul>
        <h3>How to find your textbook</h3>
        <p>Choose your board above, then your class, then your subject. Every book opens as a free PDF — no registration, no paywall, no ads.</p>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ Board picker rebuilt"

# ═════════════════════════════════════════════════════════
#  7. Rebuild
# ═════════════════════════════════════════════════════════
echo ""
echo "Rebuilding..."
rm -rf dist .astro node_modules/.vite
npm run build 2>&1 | tail -8

echo ""
echo "════════════════════════════════════════════════════════"
echo "  DONE"
echo ""
echo "  Preview:"
echo "    bash start-server.sh"
echo ""
echo "  Check on mobile:"
echo "    /My-edu-site/books/"
echo "    /My-edu-site/books/punjab/"
echo "    /My-edu-site/books/punjab/class-9/"
echo "    /My-edu-site/textbook/9-pectaa-mathematics-e-2025_26"
echo ""
echo "  What changed:"
echo "    · Removed BookCover component entirely"
echo "    · Replaced card grids with list rows (like Stripe/Linear)"
echo "    · Class numbers padded to two digits (01, 02, …)"
echo "    · Typography hierarchy is now: subject > meta > badges"
echo "    · 1px dividers between rows, no card borders"
echo "    · Row hover is subtle (slate-50 background)"
echo "    · Removed fake covers, rainbow colors, decorative circles"
echo "    · Same blue accent, less chrome"
echo ""
echo "  Push when happy:"
echo "    git add ."
echo "    git commit -m 'Books section: cleaner professional layout, no covers'"
echo "    git push"
echo ""
echo "  Revert:"
echo "    git checkout backup-pre-books-clean"
echo "════════════════════════════════════════════════════════"