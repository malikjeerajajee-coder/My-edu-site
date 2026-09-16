#!/bin/bash
set -e

mkdir -p src/lib src/pages/class

# ============ TAXONOMY LIBRARY (extended) ============
cat > src/lib/taxonomy.ts <<'EOF'
import { getCollection } from 'astro:content';

export function slugify(s: string) {
  return s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

const CLASS_ORDER = ['9', '10', '11', '12'];

export async function getAll() {
  const [notes, quizzes, books, gazettes] = await Promise.all([
    getCollection('notes'),
    getCollection('quizzes'),
    getCollection('books'),
    getCollection('gazettes'),
  ]);
  return { notes, quizzes, books, gazettes };
}

export async function getClassList() {
  const { notes, quizzes, books, gazettes } = await getAll();
  const set = new Set<string>();
  [...notes, ...quizzes, ...books, ...gazettes].forEach(x => set.add(x.data.class));
  return [...set].sort((a, b) => {
    const ai = CLASS_ORDER.indexOf(a), bi = CLASS_ORDER.indexOf(b);
    if (ai === -1 && bi === -1) return Number(a) - Number(b);
    if (ai === -1) return 1;
    if (bi === -1) return -1;
    return ai - bi;
  });
}

export async function getClassContent(cls: string) {
  const { notes, quizzes, books, gazettes } = await getAll();

  const cNotes    = notes.filter(n => n.data.class === cls);
  const cQuizzes  = quizzes.filter(q => q.data.class === cls);
  const cBooks    = books.filter(b => b.data.class === cls);
  const cGazettes = gazettes.filter(g => g.data.class === cls);

  const subjectMap = new Map<string, { notes: any[]; quizzes: any[]; books: any[] }>();
  const ensure = (s: string) => {
    if (!subjectMap.has(s)) subjectMap.set(s, { notes: [], quizzes: [], books: [] });
    return subjectMap.get(s)!;
  };

  cNotes.forEach(n => ensure(n.data.subject).notes.push(n));
  cQuizzes.forEach(q => ensure(q.data.subject).quizzes.push(q));
  cBooks.forEach(b => ensure(b.data.subject).books.push(b));

  const subjects = [...subjectMap.entries()]
    .map(([subject, v]) => ({
      subject,
      slug: slugify(subject),
      notes: v.notes,
      quizzes: v.quizzes,
      books: v.books,
      total: v.notes.length + v.quizzes.length + v.books.length,
    }))
    .sort((a, b) => a.subject.localeCompare(b.subject));

  const boards = [...new Set(cGazettes.map(g => g.data.board))].sort();

  return {
    class: cls,
    notes: cNotes,
    quizzes: cQuizzes,
    books: cBooks,
    gazettes: cGazettes,
    subjects,
    boards,
    total: cNotes.length + cQuizzes.length + cBooks.length + cGazettes.length,
  };
}

export const AVAILABLE_CLASSES = CLASS_ORDER;
EOF

# ============ LAYOUT (class-first nav) ============
cat > src/layouts/BaseLayout.astro <<'EOF'
---
import '../styles/global.css';
import Icon from '../components/Icon.astro';
import { AVAILABLE_CLASSES } from '../lib/taxonomy';

interface Props { title: string; description?: string; }
const {
  title,
  description = 'Free notes, interactive quizzes, textbooks and result gazettes for Pakistani students.',
} = Astro.props;

const path = Astro.url.pathname;

const desktopNav = [
  { href: '/', label: 'Home' },
  ...AVAILABLE_CLASSES.map(c => ({ href: `/class/${c}`, label: `Class ${c}` })),
];

const mobileNav = [
  { href: '/', icon: 'home', label: 'Home' },
  ...AVAILABLE_CLASSES.slice(0, 4).map(c => ({
    href: `/class/${c}`,
    icon: 'graduation-cap',
    label: c,
  })),
];

const isActive = (href: string) =>
  href === '/' ? path === '/' : path.startsWith(href);
---
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
  <meta name="theme-color" content="#047857" />
  <title>{title}</title>
  <meta name="description" content={description} />
  <meta property="og:title" content={title} />
  <meta property="og:description" content={description} />
  <meta property="og:type" content="website" />
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Plus+Jakarta+Sans:wght@600;700;800&display=swap" />
  <link rel="sitemap" href="/sitemap-index.xml" />
</head>
<body class="min-h-screen">
  <header class="sticky top-0 z-50 w-full border-b border-slate-200 bg-white/90 backdrop-blur-lg">
    <div class="mx-auto flex h-16 w-full max-w-7xl items-center gap-4 px-4 sm:px-6 lg:px-8">
      <a href="/" class="flex shrink-0 items-center gap-2.5">
        <span class="grid h-9 w-9 place-items-center rounded-xl bg-emerald-600 text-white">
          <Icon name="graduation-cap" size={20} strokeWidth={2.4} />
        </span>
        <span class="font-display text-lg font-extrabold tracking-tight">TaleemHub</span>
      </a>

      <nav class="ml-4 hidden items-center gap-1 md:flex">
        {desktopNav.map(item => (
          <a
            href={item.href}
            class:list={[
              "rounded-lg px-3 py-2 text-sm font-semibold transition-colors",
              isActive(item.href)
                ? "bg-emerald-50 text-emerald-700"
                : "text-slate-600 hover:bg-slate-100 hover:text-slate-900",
            ]}
          >
            {item.label}
          </a>
        ))}
      </nav>

      <div class="ml-auto flex items-center gap-2">
        <form
          action="/search"
          method="get"
          role="search"
          class="hidden h-10 w-56 items-center gap-2 rounded-xl border border-slate-200 bg-slate-50 px-3 transition-colors focus-within:border-emerald-400 focus-within:bg-white lg:flex"
        >
          <Icon name="search" size={16} strokeWidth={2.4} class="shrink-0 text-slate-400" />
          <input
            type="search"
            name="q"
            placeholder="Search library"
            class="min-w-0 flex-1 bg-transparent text-sm text-slate-900 outline-none placeholder:text-slate-400"
          />
        </form>

        <a
          href="/search"
          class="grid h-10 w-10 place-items-center rounded-xl border border-slate-200 bg-slate-50 text-slate-600 transition-colors hover:bg-white hover:text-slate-900 lg:hidden"
          aria-label="Search"
        >
          <Icon name="search" size={18} strokeWidth={2.4} />
        </a>
      </div>
    </div>
  </header>

  <main class="min-h-[60vh] pb-32 md:pb-0">
    <slot />
  </main>

  <footer class="mt-24 hidden border-t border-slate-200 bg-white md:block">
    <div class="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
      <div class="grid grid-cols-1 gap-10 sm:grid-cols-2 lg:grid-cols-4">
        <div class="sm:col-span-2">
          <div class="flex items-center gap-2.5">
            <span class="grid h-9 w-9 place-items-center rounded-xl bg-emerald-600 text-white">
              <Icon name="graduation-cap" size={20} strokeWidth={2.4} />
            </span>
            <span class="font-display text-lg font-extrabold tracking-tight">TaleemHub</span>
          </div>
          <p class="mt-4 max-w-sm text-sm leading-relaxed text-slate-500">
            Free notes, interactive quizzes, textbooks and result gazettes for Pakistani students — organised by class and subject.
          </p>
        </div>
        <div>
          <h4 class="text-sm font-bold text-slate-900">Classes</h4>
          <ul class="mt-4 space-y-2.5 text-sm text-slate-500">
            {AVAILABLE_CLASSES.map(c => (
              <li><a href={`/class/${c}`} class="hover:text-emerald-700">Class {c}</a></li>
            ))}
          </ul>
        </div>
        <div>
          <h4 class="text-sm font-bold text-slate-900">Explore</h4>
          <ul class="mt-4 space-y-2.5 text-sm text-slate-500">
            <li><a href="/search" class="hover:text-emerald-700">Search</a></li>
            <li><a href="/notes" class="hover:text-emerald-700">All notes</a></li>
            <li><a href="/quizzes" class="hover:text-emerald-700">All quizzes</a></li>
            <li><a href="/gazettes" class="hover:text-emerald-700">All gazettes</a></li>
          </ul>
        </div>
      </div>
      <div class="mt-10 flex flex-col gap-2 border-t border-slate-200 pt-6 text-xs text-slate-400 sm:flex-row sm:items-center sm:justify-between">
        <p>© {new Date().getFullYear()} TaleemHub. Built for students, forever free.</p>
        <p>Made in Pakistan</p>
      </div>
    </div>
  </footer>

  <nav class="fixed inset-x-0 bottom-0 z-50 border-t border-slate-200 bg-white md:hidden">
    <div class="flex items-stretch px-1 pt-2.5" style="padding-bottom: calc(env(safe-area-inset-bottom, 0px) + 26px);">
      {mobileNav.map(item => (
        <a
          href={item.href}
          class:list={[
            "flex min-w-0 flex-1 flex-col items-center gap-1 px-1 text-[11px] font-semibold leading-none transition-colors",
            isActive(item.href) ? "text-emerald-600" : "text-slate-400",
          ]}
        >
          <Icon name={item.icon} size={20} strokeWidth={2.2} />
          <span class="truncate">{item.label}</span>
        </a>
      ))}
    </div>
  </nav>
</body>
</html>
EOF

# ============ HOME — class picker ============
cat > src/pages/index.astro <<'EOF'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { getClassContent, AVAILABLE_CLASSES, getAll } from '../lib/taxonomy';

const classData = await Promise.all(
  AVAILABLE_CLASSES.map(async (cls) => {
    const data = await getClassContent(cls);
    return { cls, ...data };
  })
);

const { notes, quizzes, books, gazettes } = await getAll();
const totals = {
  notes: notes.length,
  quizzes: quizzes.length,
  books: books.length,
  gazettes: gazettes.length,
};

const tints = ['emerald', 'blue', 'amber', 'violet'];
---
<BaseLayout title="TaleemHub — Free Notes, Quizzes & Books for Pakistani Students">
  <section class="relative overflow-hidden border-b border-slate-200 bg-gradient-to-b from-emerald-50/70 via-white to-white">
    <div class="mx-auto w-full max-w-5xl px-4 py-16 text-center sm:px-6 sm:py-20 lg:px-8">
      <span class="inline-flex items-center gap-1.5 rounded-full border border-emerald-200 bg-emerald-50 px-3 py-1 text-xs font-bold uppercase tracking-wider text-emerald-700">
        <Icon name="sparkles" size={13} strokeWidth={2.4} />
        Free for every Pakistani student
      </span>
      <h1 class="mt-6 font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-6xl">
        Which class are you in?
      </h1>
      <p class="mx-auto mt-5 max-w-xl text-base leading-relaxed text-slate-600 sm:text-lg">
        Everything you need — organised by your class and subject. Notes, quizzes, textbooks and result gazettes.
      </p>

      <form action="/search" method="get" role="search" class="mx-auto mt-8 flex max-w-lg items-center gap-2 rounded-2xl border border-slate-200 bg-white p-1.5 pl-4 transition-colors focus-within:border-emerald-400">
        <Icon name="search" size={18} strokeWidth={2.4} class="shrink-0 text-slate-400" />
        <input
          type="search"
          name="q"
          placeholder="Search notes, books, past papers..."
          class="min-w-0 flex-1 bg-transparent py-2.5 text-sm text-slate-900 outline-none placeholder:text-slate-400"
        />
        <button type="submit" class="rounded-xl bg-emerald-600 px-4 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-emerald-700">
          Search
        </button>
      </form>
    </div>
  </section>

  <!-- CLASS PICKER -->
  <section class="mx-auto w-full max-w-5xl px-4 py-14 sm:px-6 lg:px-8">
    <div class="grid grid-cols-2 gap-4 lg:grid-cols-4">
      {classData.map((c, i) => {
        const tint = tints[i % tints.length];
        return (
          <a
            href={`/class/${c.cls}`}
            class="group flex flex-col rounded-2xl border border-slate-200 bg-white p-6 transition-colors hover:border-emerald-300"
          >
            <span class:list={[
              "grid h-14 w-14 place-items-center rounded-xl",
              tint === 'emerald' && "bg-emerald-100 text-emerald-700",
              tint === 'blue'    && "bg-blue-100 text-blue-700",
              tint === 'amber'   && "bg-amber-100 text-amber-700",
              tint === 'violet'  && "bg-violet-100 text-violet-700",
            ]}>
              <Icon name="graduation-cap" size={26} strokeWidth={2.2} />
            </span>
            <h3 class="mt-5 font-display text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">
              Class {c.cls}
            </h3>
            <p class="mt-1 text-sm text-slate-500">
              {c.subjects.length} {c.subjects.length === 1 ? 'subject' : 'subjects'}
            </p>
            <div class="mt-4 flex flex-wrap gap-1.5 text-[11px] font-bold uppercase tracking-wide">
              {c.notes.length > 0 && <span class="rounded-md bg-emerald-50 px-2 py-0.5 text-emerald-700">{c.notes.length} notes</span>}
              {c.quizzes.length > 0 && <span class="rounded-md bg-blue-50 px-2 py-0.5 text-blue-700">{c.quizzes.length} quizzes</span>}
              {c.books.length > 0 && <span class="rounded-md bg-amber-50 px-2 py-0.5 text-amber-700">{c.books.length} books</span>}
            </div>
            <div class="mt-5 flex items-center gap-1 text-sm font-bold text-emerald-700">
              Enter Class {c.cls}
              <Icon name="arrow-right" size={14} strokeWidth={2.6} class="transition-transform group-hover:translate-x-1" />
            </div>
          </a>
        );
      })}
    </div>
  </section>

  <!-- TOTALS -->
  <section class="mx-auto w-full max-w-5xl px-4 pb-20 sm:px-6 lg:px-8">
    <div class="rounded-3xl border border-slate-200 bg-white p-8 sm:p-10">
      <div class="text-center">
        <div class="text-[11px] font-bold uppercase tracking-widest text-slate-400">Across all classes</div>
        <h2 class="mt-2 font-display text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">
          {totals.notes + totals.quizzes + totals.books + totals.gazettes} items, ready to study
        </h2>
      </div>
      <div class="mt-8 grid grid-cols-2 gap-4 sm:grid-cols-4">
        <a href="/notes" class="rounded-2xl border border-slate-200 p-5 text-center transition-colors hover:border-emerald-300">
          <div class="font-display text-3xl font-extrabold tracking-tight text-slate-900">{totals.notes}</div>
          <div class="mt-1 text-xs font-bold uppercase tracking-wider text-slate-500">Notes</div>
        </a>
        <a href="/quizzes" class="rounded-2xl border border-slate-200 p-5 text-center transition-colors hover:border-blue-300">
          <div class="font-display text-3xl font-extrabold tracking-tight text-slate-900">{totals.quizzes}</div>
          <div class="mt-1 text-xs font-bold uppercase tracking-wider text-slate-500">Quizzes</div>
        </a>
        <a href="/books" class="rounded-2xl border border-slate-200 p-5 text-center transition-colors hover:border-amber-300">
          <div class="font-display text-3xl font-extrabold tracking-tight text-slate-900">{totals.books}</div>
          <div class="mt-1 text-xs font-bold uppercase tracking-wider text-slate-500">Books</div>
        </a>
        <a href="/gazettes" class="rounded-2xl border border-slate-200 p-5 text-center transition-colors hover:border-rose-300">
          <div class="font-display text-3xl font-extrabold tracking-tight text-slate-900">{totals.gazettes}</div>
          <div class="mt-1 text-xs font-bold uppercase tracking-wider text-slate-500">Gazettes</div>
        </a>
      </div>
    </div>
  </section>
</BaseLayout>
EOF

# ============ CLASS HUB ============
cat > src/pages/class/[class]/index.astro <<'EOF'
---
import BaseLayout from '../../../layouts/BaseLayout.astro';
import Icon from '../../../components/Icon.astro';
import { getClassContent, getClassList, AVAILABLE_CLASSES } from '../../../lib/taxonomy';

export async function getStaticPaths() {
  const classes = await getClassList();
  const all = new Set([...classes, ...AVAILABLE_CLASSES]);
  return [...all].map(c => ({ params: { class: c } }));
}

const { class: cls } = Astro.params;
const data = await getClassContent(cls!);

const cats = [
  { key: 'notes',    href: `/class/${cls}/notes`,    label: 'Notes',      icon: 'file-text',     tint: 'emerald', items: data.notes,    desc: 'Chapter-wise study notes' },
  { key: 'quizzes',  href: `/class/${cls}/quizzes`,  label: 'Quizzes',    icon: 'file-question', tint: 'blue',    items: data.quizzes,  desc: 'Interactive MCQ practice' },
  { key: 'books',    href: `/class/${cls}/books`,    label: 'Textbooks',  icon: 'book-marked',   tint: 'amber',   items: data.books,    desc: 'Full textbooks to download' },
  { key: 'gazettes', href: `/class/${cls}/gazettes`, label: 'Gazettes',   icon: 'scroll-text',   tint: 'rose',    items: data.gazettes, desc: 'Official result gazettes' },
];
---
<BaseLayout
  title={`Class ${cls} — Notes, Quizzes, Books & Gazettes | TaleemHub`}
  description={`Everything a Class ${cls} student in Pakistan needs: notes, interactive quizzes, textbooks and result gazettes. All free.`}
>
  <div class="mx-auto w-full max-w-7xl px-4 pt-10 sm:px-6 sm:pt-14 lg:px-8">
    <!-- CLASS HEADER -->
    <div class="relative overflow-hidden rounded-3xl border border-emerald-700 bg-gradient-to-br from-emerald-900 via-emerald-800 to-emerald-600 p-8 text-white sm:p-10">
      <div class="flex flex-wrap items-center gap-2">
        <span class="inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider backdrop-blur-sm">
          <Icon name="graduation-cap" size={13} strokeWidth={2.4} /> Class
        </span>
        <span class="text-[11px] font-bold uppercase tracking-wider text-emerald-100">
          {data.total} {data.total === 1 ? 'item' : 'items'} ready
        </span>
      </div>
      <h1 class="mt-4 font-display text-4xl font-extrabold leading-tight tracking-tight sm:text-5xl">
        Class {cls}
      </h1>
      <p class="mt-2 max-w-xl text-emerald-100">
        Everything for your class in one place — notes, interactive quizzes, textbooks and result gazettes.
      </p>

      {data.subjects.length > 0 && (
        <div class="mt-6 flex flex-wrap gap-1.5">
          {data.subjects.map(s => (
            <a href={`/class/${cls}/subject/${s.slug}`}
               class="rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wide backdrop-blur-sm transition-colors hover:bg-white/20">
              {s.subject}
            </a>
          ))}
        </div>
      )}
    </div>

    <!-- CATEGORY QUICK ACCESS -->
    <section class="mt-10">
      <div class="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-4">
        {cats.map(cat => (
          <a href={cat.href} class="group flex flex-col rounded-2xl border border-slate-200 bg-white p-5 transition-colors hover:border-emerald-300">
            <div class="flex items-start justify-between">
              <span class:list={[
                "grid h-11 w-11 place-items-center rounded-xl",
                cat.tint === 'emerald' && "bg-emerald-100 text-emerald-700",
                cat.tint === 'blue'    && "bg-blue-100 text-blue-700",
                cat.tint === 'amber'   && "bg-amber-100 text-amber-700",
                cat.tint === 'rose'    && "bg-rose-100 text-rose-700",
              ]}>
                <Icon name={cat.icon} size={20} strokeWidth={2.2} />
              </span>
              <span class="font-display text-2xl font-extrabold tracking-tight text-slate-900">
                {cat.items.length}
              </span>
            </div>
            <div class="mt-4 font-display text-base font-bold tracking-tight text-slate-900">{cat.label}</div>
            <div class="mt-0.5 text-xs text-slate-500">{cat.desc}</div>
          </a>
        ))}
      </div>
    </section>

    <!-- SUBJECTS -->
    {data.subjects.length > 0 && (
      <section class="mt-14">
        <div class="mb-6">
          <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Subjects in Class {cls}</h2>
          <p class="mt-1.5 text-sm text-slate-500">Pick a subject to see its notes, quizzes and textbooks.</p>
        </div>

        <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {data.subjects.map(s => (
            <a href={`/class/${cls}/subject/${s.slug}`} class="group rounded-2xl border border-slate-200 bg-white p-6 transition-colors hover:border-emerald-300">
              <div class="flex items-start justify-between">
                <span class="grid h-12 w-12 place-items-center rounded-xl bg-emerald-100 text-emerald-700">
                  <Icon name="library" size={22} strokeWidth={2.2} />
                </span>
                <Icon name="arrow-up-right" size={18} strokeWidth={2.4} class="text-slate-300 transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-emerald-600" />
              </div>
              <h3 class="mt-5 font-display text-lg font-bold tracking-tight text-slate-900">{s.subject}</h3>
              <div class="mt-3 flex flex-wrap gap-1.5 text-[11px] font-bold uppercase tracking-wide">
                {s.notes.length > 0 && <span class="rounded-md bg-emerald-50 px-2 py-0.5 text-emerald-700">{s.notes.length} notes</span>}
                {s.quizzes.length > 0 && <span class="rounded-md bg-blue-50 px-2 py-0.5 text-blue-700">{s.quizzes.length} quizzes</span>}
                {s.books.length > 0 && <span class="rounded-md bg-amber-50 px-2 py-0.5 text-amber-700">{s.books.length} books</span>}
              </div>
            </a>
          ))}
        </div>
      </section>
    )}

    <!-- RECENT FOR THIS CLASS -->
    {data.notes.length > 0 && (
      <section class="mt-14 pb-20">
        <div class="mb-6 flex items-end justify-between gap-4">
          <div>
            <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Recent in Class {cls}</h2>
            <p class="mt-1.5 text-sm text-slate-500">Latest study material added.</p>
          </div>
          <a href={`/class/${cls}/notes`} class="hidden items-center gap-1 text-sm font-semibold text-emerald-700 hover:text-emerald-800 sm:inline-flex">
            All notes <Icon name="arrow-right" size={14} strokeWidth={2.6} />
          </a>
        </div>
        <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
          {data.notes.slice(0, 4).map(n => (
            <a href={`/notes/${n.id}`} class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-4 transition-colors hover:border-emerald-300">
              <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-emerald-100 text-emerald-700">
                <Icon name="file-text" size={18} strokeWidth={2.2} />
              </span>
              <div class="min-w-0 flex-1">
                <h3 class="truncate text-[0.925rem] font-bold tracking-tight text-slate-900">{n.data.title}</h3>
                <div class="mt-1.5 flex flex-wrap gap-1.5">
                  <span class="rounded-md bg-emerald-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-emerald-700">{n.data.subject}</span>
                </div>
              </div>
              <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-transform group-hover:translate-x-0.5 group-hover:text-emerald-600" />
            </a>
          ))}
        </div>
      </section>
    )}

    {data.total === 0 && (
      <section class="mt-14 pb-20">
        <div class="rounded-2xl border border-dashed border-slate-300 bg-white p-12 text-center">
          <div class="text-base font-bold text-slate-900">Nothing here yet</div>
          <div class="mt-1 text-sm text-slate-500">Content for Class {cls} is coming soon.</div>
          <a href="/" class="mt-5 inline-flex items-center gap-1.5 rounded-xl bg-emerald-600 px-4 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-emerald-700">
            Back to classes
          </a>
        </div>
      </section>
    )}
  </div>
</BaseLayout>
EOF

# ============ CLASS → NOTES ============
cat > src/pages/class/[class]/notes.astro <<'EOF'
---
import BaseLayout from '../../../layouts/BaseLayout.astro';
import Icon from '../../../components/Icon.astro';
import { getClassContent, getClassList, AVAILABLE_CLASSES } from '../../../lib/taxonomy';

export async function getStaticPaths() {
  const classes = await getClassList();
  const all = new Set([...classes, ...AVAILABLE_CLASSES]);
  return [...all].map(c => ({ params: { class: c } }));
}

const { class: cls } = Astro.params;
const data = await getClassContent(cls!);
const notes = [...data.notes].sort((a, b) => a.data.title.localeCompare(b.data.title));
---
<BaseLayout title={`Class ${cls} Notes — TaleemHub`} description={`Free study notes for all Class ${cls} subjects.`}>
  <div class="mx-auto w-full max-w-7xl px-4 pt-8 sm:px-6 sm:pt-12 lg:px-8">
    <nav class="mb-6 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
      <a href="/" class="transition-colors hover:text-emerald-700">Home</a>
      <span>/</span>
      <a href={`/class/${cls}`} class="transition-colors hover:text-emerald-700">Class {cls}</a>
      <span>/</span>
      <span class="text-slate-500">Notes</span>
    </nav>

    <div class="mb-8">
      <h1 class="font-display text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">Class {cls} Notes</h1>
      <p class="mt-2 text-slate-500">{notes.length} {notes.length === 1 ? 'note' : 'notes'} across all {cls} subjects</p>
    </div>

    {notes.length === 0 ? (
      <div class="rounded-2xl border border-dashed border-slate-300 bg-white p-12 text-center">
        <div class="text-base font-bold text-slate-900">No notes yet for Class {cls}</div>
        <a href={`/class/${cls}`} class="mt-4 inline-block text-sm font-semibold text-emerald-700">Back to Class {cls}</a>
      </div>
    ) : (
      <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
        {notes.map(n => (
          <a href={`/notes/${n.id}`} class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-4 transition-colors hover:border-emerald-300">
            <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-emerald-100 text-emerald-700">
              <Icon name="file-text" size={18} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <h3 class="truncate text-[0.925rem] font-bold tracking-tight text-slate-900">{n.data.title}</h3>
              <div class="mt-1.5 flex flex-wrap gap-1.5">
                <span class="rounded-md bg-emerald-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-emerald-700">{n.data.subject}</span>
                {n.data.board && <span class="rounded-md bg-slate-100 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-slate-600">{n.data.board}</span>}
              </div>
            </div>
            <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-transform group-hover:translate-x-0.5 group-hover:text-emerald-600" />
          </a>
        ))}
      </div>
    )}
  </div>
</BaseLayout>
EOF

# ============ CLASS → QUIZZES ============
cat > src/pages/class/[class]/quizzes.astro <<'EOF'
---
import BaseLayout from '../../../layouts/BaseLayout.astro';
import Icon from '../../../components/Icon.astro';
import { getClassContent, getClassList, AVAILABLE_CLASSES } from '../../../lib/taxonomy';

export async function getStaticPaths() {
  const classes = await getClassList();
  const all = new Set([...classes, ...AVAILABLE_CLASSES]);
  return [...all].map(c => ({ params: { class: c } }));
}

const { class: cls } = Astro.params;
const data = await getClassContent(cls!);
---
<BaseLayout title={`Class ${cls} Quizzes — TaleemHub`} description={`Interactive MCQ quizzes for all Class ${cls} subjects.`}>
  <div class="mx-auto w-full max-w-7xl px-4 pt-8 sm:px-6 sm:pt-12 lg:px-8">
    <nav class="mb-6 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
      <a href="/" class="transition-colors hover:text-emerald-700">Home</a>
      <span>/</span>
      <a href={`/class/${cls}`} class="transition-colors hover:text-emerald-700">Class {cls}</a>
      <span>/</span>
      <span class="text-slate-500">Quizzes</span>
    </nav>

    <div class="mb-8">
      <h1 class="font-display text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">Class {cls} Quizzes</h1>
      <p class="mt-2 text-slate-500">Interactive MCQs with instant feedback and scoring.</p>
    </div>

    {data.quizzes.length === 0 ? (
      <div class="rounded-2xl border border-dashed border-slate-300 bg-white p-12 text-center">
        <div class="text-base font-bold text-slate-900">No quizzes yet for Class {cls}</div>
        <a href={`/class/${cls}`} class="mt-4 inline-block text-sm font-semibold text-emerald-700">Back to Class {cls}</a>
      </div>
    ) : (
      <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
        {data.quizzes.map(q => (
          <a href={`/quizzes/${q.id}`} class="group relative overflow-hidden rounded-2xl border border-slate-200 bg-white p-6 transition-colors hover:border-blue-300">
            <div class="flex items-start justify-between">
              <span class="grid h-12 w-12 place-items-center rounded-xl bg-blue-100 text-blue-700">
                <Icon name="file-question" size={22} strokeWidth={2.2} />
              </span>
              <span class="rounded-md bg-slate-100 px-2 py-1 text-[11px] font-bold uppercase tracking-wider text-slate-600">
                {q.data.questions.length} Q
              </span>
            </div>
            <h3 class="mt-5 font-display text-lg font-bold leading-snug tracking-tight text-slate-900">{q.data.title}</h3>
            <div class="mt-3 flex flex-wrap gap-1.5">
              <span class="rounded-md bg-blue-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-blue-700">{q.data.subject}</span>
            </div>
            <div class="mt-5 flex items-center gap-1.5 text-sm font-bold text-blue-700">
              Start quiz
              <Icon name="arrow-right" size={14} strokeWidth={2.6} class="transition-transform group-hover:translate-x-1" />
            </div>
          </a>
        ))}
      </div>
    )}
  </div>
</BaseLayout>
EOF

# ============ CLASS → BOOKS ============
cat > src/pages/class/[class]/books.astro <<'EOF'
---
import BaseLayout from '../../../layouts/BaseLayout.astro';
import Icon from '../../../components/Icon.astro';
import { getClassContent, getClassList, AVAILABLE_CLASSES } from '../../../lib/taxonomy';

export async function getStaticPaths() {
  const classes = await getClassList();
  const all = new Set([...classes, ...AVAILABLE_CLASSES]);
  return [...all].map(c => ({ params: { class: c } }));
}

const { class: cls } = Astro.params;
const data = await getClassContent(cls!);
---
<BaseLayout title={`Class ${cls} Textbooks — TaleemHub`} description={`Free Class ${cls} textbooks for Pakistani students.`}>
  <div class="mx-auto w-full max-w-7xl px-4 pt-8 sm:px-6 sm:pt-12 lg:px-8">
    <nav class="mb-6 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
      <a href="/" class="transition-colors hover:text-emerald-700">Home</a>
      <span>/</span>
      <a href={`/class/${cls}`} class="transition-colors hover:text-emerald-700">Class {cls}</a>
      <span>/</span>
      <span class="text-slate-500">Textbooks</span>
    </nav>

    <div class="mb-8">
      <h1 class="font-display text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">Class {cls} Textbooks</h1>
      <p class="mt-2 text-slate-500">Full textbooks ready to download as PDF.</p>
    </div>

    {data.books.length === 0 ? (
      <div class="rounded-2xl border border-dashed border-slate-300 bg-white p-12 text-center">
        <div class="text-base font-bold text-slate-900">No textbooks yet for Class {cls}</div>
        <a href={`/class/${cls}`} class="mt-4 inline-block text-sm font-semibold text-emerald-700">Back to Class {cls}</a>
      </div>
    ) : (
      <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
        {data.books.map(b => (
          <a href={`/books/${b.id}`} class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-4 transition-colors hover:border-amber-300">
            <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-amber-100 text-amber-700">
              <Icon name="book-marked" size={18} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <h3 class="truncate text-[0.925rem] font-bold tracking-tight text-slate-900">{b.data.title}</h3>
              <div class="mt-1.5 flex flex-wrap gap-1.5">
                <span class="rounded-md bg-amber-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-amber-700">{b.data.subject}</span>
                {b.data.author && <span class="rounded-md bg-slate-100 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-slate-600">{b.data.author}</span>}
              </div>
            </div>
            <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-transform group-hover:translate-x-0.5 group-hover:text-amber-600" />
          </a>
        ))}
      </div>
    )}
  </div>
</BaseLayout>
EOF

# ============ CLASS → GAZETTES ============
cat > src/pages/class/[class]/gazettes.astro <<'EOF'
---
import BaseLayout from '../../../layouts/BaseLayout.astro';
import Icon from '../../../components/Icon.astro';
import { getClassContent, getClassList, AVAILABLE_CLASSES } from '../../../lib/taxonomy';

export async function getStaticPaths() {
  const classes = await getClassList();
  const all = new Set([...classes, ...AVAILABLE_CLASSES]);
  return [...all].map(c => ({ params: { class: c } }));
}

const { class: cls } = Astro.params;
const data = await getClassContent(cls!);
---
<BaseLayout title={`Class ${cls} Result Gazettes — TaleemHub`} description={`Board result gazettes for Class ${cls} students in Pakistan.`}>
  <div class="mx-auto w-full max-w-7xl px-4 pt-8 sm:px-6 sm:pt-12 lg:px-8">
    <nav class="mb-6 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
      <a href="/" class="transition-colors hover:text-emerald-700">Home</a>
      <span>/</span>
      <a href={`/class/${cls}`} class="transition-colors hover:text-emerald-700">Class {cls}</a>
      <span>/</span>
      <span class="text-slate-500">Gazettes</span>
    </nav>

    <div class="mb-8">
      <h1 class="font-display text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">Class {cls} Result Gazettes</h1>
      <p class="mt-2 text-slate-500">Official results from Pakistani boards.</p>
    </div>

    {data.gazettes.length === 0 ? (
      <div class="rounded-2xl border border-dashed border-slate-300 bg-white p-12 text-center">
        <div class="text-base font-bold text-slate-900">No gazettes yet for Class {cls}</div>
        <a href={`/class/${cls}`} class="mt-4 inline-block text-sm font-semibold text-emerald-700">Back to Class {cls}</a>
      </div>
    ) : (
      <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
        {data.gazettes.map(g => (
          <a href={`/gazettes/${g.id}`} class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-4 transition-colors hover:border-rose-300">
            <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-rose-100 text-rose-700">
              <Icon name="scroll-text" size={18} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <h3 class="truncate text-[0.925rem] font-bold tracking-tight text-slate-900">{g.data.title}</h3>
              <div class="mt-1.5 flex flex-wrap gap-1.5">
                <span class="rounded-md bg-rose-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-rose-700">{g.data.board}</span>
                <span class="rounded-md bg-amber-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-amber-700">{g.data.year}</span>
              </div>
            </div>
            <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-transform group-hover:translate-x-0.5 group-hover:text-rose-600" />
          </a>
        ))}
      </div>
    )}
  </div>
</BaseLayout>
EOF

# ============ CLASS → SUBJECT (deep) ============
cat > src/pages/class/[class]/subject/[subject].astro <<'EOF'
---
import BaseLayout from '../../../../layouts/BaseLayout.astro';
import Icon from '../../../../components/Icon.astro';
import { getClassContent, getClassList, slugify, AVAILABLE_CLASSES } from '../../../../lib/taxonomy';

export async function getStaticPaths() {
  const classes = await getClassList();
  const all = new Set([...classes, ...AVAILABLE_CLASSES]);
  const paths = [];
  for (const cls of all) {
    const data = await getClassContent(cls);
    for (const s of data.subjects) {
      paths.push({ params: { class: cls, subject: s.slug } });
    }
  }
  return paths;
}

const { class: cls, subject: subjectSlug } = Astro.params;
const data = await getClassContent(cls!);
const subject = data.subjects.find(s => s.slug === subjectSlug);

const sections = subject ? [
  { key: 'notes',   label: 'Notes',     icon: 'file-text',     base: '/notes',   tint: 'emerald', items: subject.notes },
  { key: 'quizzes', label: 'Quizzes',   icon: 'file-question', base: '/quizzes', tint: 'blue',    items: subject.quizzes },
  { key: 'books',   label: 'Textbooks', icon: 'book-marked',   base: '/books',   tint: 'amber',   items: subject.books },
].filter(s => s.items.length > 0) : [];
---
{subject ? (
<BaseLayout
  title={`Class ${cls} ${subject.subject} Notes, Quizzes & Books — TaleemHub`}
  description={`Free ${subject.subject} notes, interactive quizzes and textbooks for Class ${cls} students in Pakistan.`}
>
  <div class="mx-auto w-full max-w-7xl px-4 pt-8 sm:px-6 sm:pt-12 lg:px-8">
    <nav class="mb-6 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-slate-400">
      <a href="/" class="transition-colors hover:text-emerald-700">Home</a>
      <span>/</span>
      <a href={`/class/${cls}`} class="transition-colors hover:text-emerald-700">Class {cls}</a>
      <span>/</span>
      <span class="text-slate-500">{subject.subject}</span>
    </nav>

    <div class="relative overflow-hidden rounded-3xl border border-emerald-700 bg-gradient-to-br from-emerald-900 via-emerald-800 to-emerald-600 p-8 text-white sm:p-10">
      <div class="flex flex-wrap gap-1.5">
        <span class="inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider backdrop-blur-sm">
          <Icon name="graduation-cap" size={13} strokeWidth={2.4} /> Class {cls}
        </span>
        <span class="inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider backdrop-blur-sm">
          <Icon name="library" size={13} strokeWidth={2.4} /> {subject.subject}
        </span>
      </div>
      <h1 class="mt-4 font-display text-3xl font-extrabold leading-tight tracking-tight sm:text-4xl">
        {subject.subject}
      </h1>
      <p class="mt-2 text-emerald-100">
        {subject.total} {subject.total === 1 ? 'item' : 'items'} for Class {cls}
      </p>
    </div>

    {sections.map(sec => (
      <section class="mt-12">
        <div class="mb-5 flex items-center gap-3">
          <span class:list={[
            "grid h-10 w-10 place-items-center rounded-xl",
            sec.tint === 'emerald' && "bg-emerald-100 text-emerald-700",
            sec.tint === 'blue'    && "bg-blue-100 text-blue-700",
            sec.tint === 'amber'   && "bg-amber-100 text-amber-700",
          ]}>
            <Icon name={sec.icon} size={20} strokeWidth={2.2} />
          </span>
          <div>
            <h2 class="font-display text-xl font-extrabold tracking-tight text-slate-900">
              {subject.subject} {sec.label}
            </h2>
            <p class="text-sm text-slate-500">{sec.items.length} {sec.items.length === 1 ? 'item' : 'items'}</p>
          </div>
        </div>

        <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
          {sec.items.map((item) => (
            <a href={`${sec.base}/${item.id}`} class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-4 transition-colors hover:border-emerald-300">
              <span class:list={[
                "grid h-11 w-11 shrink-0 place-items-center rounded-xl",
                sec.tint === 'emerald' && "bg-emerald-100 text-emerald-700",
                sec.tint === 'blue'    && "bg-blue-100 text-blue-700",
                sec.tint === 'amber'   && "bg-amber-100 text-amber-700",
              ]}>
                <Icon name={sec.icon} size={18} strokeWidth={2.2} />
              </span>
              <div class="min-w-0 flex-1">
                <h3 class="truncate text-[0.925rem] font-bold tracking-tight text-slate-900">{item.data.title}</h3>
              </div>
              <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-transform group-hover:translate-x-0.5 group-hover:text-emerald-600" />
            </a>
          ))}
        </div>
      </section>
    ))}

    <div class="mt-12 pb-20">
      <a href={`/class/${cls}`} class="inline-flex items-center gap-2 text-sm font-semibold text-slate-500 transition-colors hover:text-emerald-700">
        <Icon name="arrow-left" size={16} strokeWidth={2.4} /> Back to Class {cls}
      </a>
    </div>
  </div>
</BaseLayout>
) : (
<BaseLayout title="Subject not found — TaleemHub">
  <div class="mx-auto w-full max-w-7xl px-4 pt-20 text-center sm:px-6 lg:px-8">
    <h1 class="font-display text-2xl font-extrabold text-slate-900">Subject not found</h1>
    <a href={`/class/${cls}`} class="mt-4 inline-block text-sm font-semibold text-emerald-700">Back to Class {cls}</a>
  </div>
</BaseLayout>
)}
EOF

# ============ CLEAN UP OLD ROUTES ============
# Remove classes/ and subjects/ trees — content now lives under /class/[class]/*
rm -rf src/pages/classes
rm -rf src/pages/subjects

# Keep /notes, /quizzes, /books, /gazettes as global browse (they still work)
# Keep detail pages /notes/[slug], /quizzes/[slug], /books/[slug], /gazettes/[slug]

# ============ CLEAR CACHES ============
rm -rf .astro node_modules/.vite node_modules/.astro dist

echo ""
echo "==================================================="
echo "  Class-first restructure complete"
echo "==================================================="
echo ""
echo "  New IA:"
echo "    /                      → class picker"
echo "    /class/9               → Class 9 hub"
echo "    /class/10              → Class 10 hub"
echo "    /class/10/notes        → all Class 10 notes"
echo "    /class/10/quizzes      → all Class 10 quizzes"
echo "    /class/10/books        → all Class 10 textbooks"
echo "    /class/10/gazettes     → all Class 10 gazettes"
echo "    /class/10/subject/mathematics → Math for Class 10"
echo ""
echo "  Old /classes and /subjects removed"
echo "  /notes /quizzes /books /gazettes still exist as browse-all"
echo ""
echo "Next:"
echo "  1. Stop dev server (Ctrl+C)"
echo "  2. Run:  npm run dev"
echo "  3. Hard-refresh"