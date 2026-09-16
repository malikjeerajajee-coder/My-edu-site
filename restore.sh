#!/bin/bash
set -e

mkdir -p src/pages/classes src/pages/subjects

# ============ BASE LAYOUT (Classes + Subjects nav) ============
cat > src/layouts/BaseLayout.astro <<'EOF'
---
import '../styles/global.css';
import Icon from '../components/Icon.astro';

interface Props { title: string; description?: string; }
const {
  title,
  description = 'Free notes, interactive quizzes, textbooks and result gazettes for Pakistani students.',
} = Astro.props;

const path = Astro.url.pathname;

const desktopNav = [
  { href: '/',         label: 'Home' },
  { href: '/classes',  label: 'Classes' },
  { href: '/subjects', label: 'Subjects' },
  { href: '/notes',    label: 'Notes' },
  { href: '/quizzes',  label: 'Quizzes' },
  { href: '/books',    label: 'Books' },
  { href: '/gazettes', label: 'Gazettes' },
];

const mobileNav = [
  { href: '/',         label: 'Home',     icon: 'home' },
  { href: '/classes',  label: 'Classes',  icon: 'graduation-cap' },
  { href: '/notes',    label: 'Notes',    icon: 'book-open' },
  { href: '/quizzes',  label: 'Quizzes',  icon: 'circle-help' },
  { href: '/books',    label: 'Books',    icon: 'library' },
];

const isActive = (href: string) => href === '/' ? path === '/' : path.startsWith(href);
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

      <nav class="ml-4 hidden items-center gap-0.5 lg:flex">
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
            Free notes, interactive quizzes, textbooks and result gazettes for students across Pakistan — all in one place.
          </p>
        </div>
        <div>
          <h4 class="text-sm font-bold text-slate-900">Library</h4>
          <ul class="mt-4 space-y-2.5 text-sm text-slate-500">
            <li><a href="/classes" class="hover:text-emerald-700">Classes</a></li>
            <li><a href="/subjects" class="hover:text-emerald-700">Subjects</a></li>
            <li><a href="/notes" class="hover:text-emerald-700">Notes</a></li>
            <li><a href="/quizzes" class="hover:text-emerald-700">Quizzes</a></li>
          </ul>
        </div>
        <div>
          <h4 class="text-sm font-bold text-slate-900">Explore</h4>
          <ul class="mt-4 space-y-2.5 text-sm text-slate-500">
            <li><a href="/books" class="hover:text-emerald-700">Textbooks</a></li>
            <li><a href="/gazettes" class="hover:text-emerald-700">Gazettes</a></li>
            <li><a href="/search" class="hover:text-emerald-700">Search</a></li>
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

# ============ HOME (Learn anything hero) ============
cat > src/pages/index.astro <<'EOF'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { getCollection } from 'astro:content';
import { getTaxonomy, slugify } from '../lib/taxonomy';

const notes = await getCollection('notes');
const quizzes = await getCollection('quizzes');
const books = await getCollection('books');
const gazettes = await getCollection('gazettes');
const { classes, subjects } = await getTaxonomy();

const categories = [
  { href: '/notes',    label: 'Notes',    count: notes.length,    icon: 'file-text',     tint: 'emerald', desc: 'Chapter-wise notes for every subject' },
  { href: '/quizzes',  label: 'Quizzes',  count: quizzes.length,  icon: 'file-question', tint: 'blue',    desc: 'Practice MCQs with instant answers' },
  { href: '/books',    label: 'Books',    count: books.length,    icon: 'book-marked',   tint: 'amber',   desc: 'Full textbooks from every board' },
  { href: '/gazettes', label: 'Gazettes', count: gazettes.length, icon: 'scroll-text',   tint: 'rose',    desc: 'Official results and past gazettes' },
];

const recent = [...notes].slice(0, 6);
---
<BaseLayout title="TaleemHub — Notes, Quizzes & Books for Pakistani Students">
  <section class="relative overflow-hidden border-b border-slate-200 bg-gradient-to-b from-emerald-50/70 via-white to-white">
    <div class="mx-auto w-full max-w-7xl px-4 py-16 sm:px-6 sm:py-24 lg:px-8 lg:py-28">
      <div class="mx-auto max-w-3xl text-center">
        <span class="inline-flex items-center gap-1.5 rounded-full border border-emerald-200 bg-emerald-50 px-3 py-1 text-xs font-bold uppercase tracking-wider text-emerald-700">
          <Icon name="sparkles" size={13} strokeWidth={2.4} />
          Free for every Pakistani student
        </span>
        <h1 class="mt-6 font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-6xl">
          Learn anything.<br />
          <span class="text-emerald-600">From Class 9 to Class 12.</span>
        </h1>
        <p class="mx-auto mt-6 max-w-xl text-base leading-relaxed text-slate-600 sm:text-lg">
          Notes, interactive quizzes, textbooks and result gazettes — organised by class and subject, all completely free.
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

        <div class="mt-6 flex flex-wrap items-center justify-center gap-x-6 gap-y-2 text-sm text-slate-500">
          <span class="flex items-center gap-1.5"><Icon name="zap" size={14} strokeWidth={2.4} class="text-emerald-600" /> Instant answers</span>
          <span class="flex items-center gap-1.5"><Icon name="download" size={14} strokeWidth={2.4} class="text-emerald-600" /> Free PDFs</span>
          <span class="flex items-center gap-1.5"><Icon name="check" size={14} strokeWidth={2.6} class="text-emerald-600" /> All boards</span>
        </div>
      </div>

      <div class="mx-auto mt-14 grid max-w-4xl grid-cols-2 gap-3 sm:grid-cols-4 sm:gap-4">
        {categories.map(cat => (
          <a href={cat.href} class="group rounded-2xl border border-slate-200 bg-white p-5 transition-colors hover:border-emerald-300">
            <span class:list={[
              "grid h-11 w-11 place-items-center rounded-xl",
              cat.tint === 'emerald' && "bg-emerald-100 text-emerald-700",
              cat.tint === 'blue'    && "bg-blue-100 text-blue-700",
              cat.tint === 'amber'   && "bg-amber-100 text-amber-700",
              cat.tint === 'rose'    && "bg-rose-100 text-rose-700",
            ]}>
              <Icon name={cat.icon} size={20} strokeWidth={2.2} />
            </span>
            <div class="mt-4 font-display text-3xl font-extrabold tracking-tight text-slate-900">{cat.count}</div>
            <div class="mt-0.5 flex items-center gap-1 text-sm font-semibold text-slate-500">
              {cat.label}
              <Icon name="arrow-up-right" size={13} strokeWidth={2.4} class="opacity-0 transition-opacity group-hover:opacity-100" />
            </div>
          </a>
        ))}
      </div>
    </div>
  </section>

  {classes.length > 0 && (
    <section class="mx-auto w-full max-w-7xl px-4 py-14 sm:px-6 lg:px-8">
      <div class="mb-6 flex items-end justify-between gap-4">
        <div>
          <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Browse by class</h2>
          <p class="mt-1.5 text-sm text-slate-500">Everything for your class in one place.</p>
        </div>
        <a href="/classes" class="hidden items-center gap-1 text-sm font-semibold text-emerald-700 hover:text-emerald-800 sm:inline-flex">
          All classes <Icon name="arrow-right" size={14} strokeWidth={2.6} />
        </a>
      </div>
      <div class="grid grid-cols-2 gap-3 lg:grid-cols-4">
        {classes.map(c => (
          <a href={`/classes/${c.class}`} class="group flex items-center gap-3 rounded-2xl border border-slate-200 bg-white p-4 transition-colors hover:border-emerald-300 sm:gap-4 sm:p-5">
            <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-emerald-100 text-emerald-700 sm:h-12 sm:w-12">
              <Icon name="graduation-cap" size={20} strokeWidth={2.2} />
            </span>
            <div class="min-w-0">
              <div class="font-display text-base font-extrabold tracking-tight text-slate-900 sm:text-lg">Class {c.class}</div>
              <div class="truncate text-xs font-semibold text-slate-500">{c.total} {c.total === 1 ? 'item' : 'items'}</div>
            </div>
          </a>
        ))}
      </div>
    </section>
  )}

  {subjects.length > 0 && (
    <section class="mx-auto w-full max-w-7xl px-4 pb-4 sm:px-6 lg:px-8">
      <div class="mb-6 flex items-end justify-between gap-4">
        <div>
          <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Browse by subject</h2>
          <p class="mt-1.5 text-sm text-slate-500">Pick your subject, then your class.</p>
        </div>
        <a href="/subjects" class="hidden items-center gap-1 text-sm font-semibold text-emerald-700 hover:text-emerald-800 sm:inline-flex">
          All subjects <Icon name="arrow-right" size={14} strokeWidth={2.6} />
        </a>
      </div>
      <div class="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
        {subjects.map(s => (
          <a href={`/subjects/${slugify(s.subject)}`} class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-5 transition-colors hover:border-emerald-300">
            <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-emerald-100 text-emerald-700">
              <Icon name="library" size={20} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <div class="font-display text-base font-extrabold tracking-tight text-slate-900">{s.subject}</div>
              <div class="truncate text-xs font-semibold text-slate-500">{s.total} {s.total === 1 ? 'item' : 'items'} · Class {s.classes.join(', ')}</div>
            </div>
            <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-transform group-hover:translate-x-0.5 group-hover:text-emerald-600" />
          </a>
        ))}
      </div>
    </section>
  )}

  <section class="mx-auto w-full max-w-7xl px-4 py-14 sm:px-6 lg:px-8">
    <div class="mb-6">
      <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Browse the library</h2>
      <p class="mt-1.5 text-sm text-slate-500">Jump straight into what you're studying.</p>
    </div>
    <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
      {categories.map(cat => (
        <a href={cat.href} class="group relative overflow-hidden rounded-2xl border border-slate-200 bg-white p-6 transition-colors hover:border-emerald-300">
          <div class="flex items-start justify-between">
            <span class:list={[
              "grid h-12 w-12 place-items-center rounded-xl",
              cat.tint === 'emerald' && "bg-emerald-100 text-emerald-700",
              cat.tint === 'blue'    && "bg-blue-100 text-blue-700",
              cat.tint === 'amber'   && "bg-amber-100 text-amber-700",
              cat.tint === 'rose'    && "bg-rose-100 text-rose-700",
            ]}>
              <Icon name={cat.icon} size={22} strokeWidth={2.2} />
            </span>
            <Icon name="arrow-up-right" size={18} strokeWidth={2.4} class="text-slate-300 transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-emerald-600" />
          </div>
          <h3 class="mt-5 font-display text-lg font-bold tracking-tight text-slate-900">{cat.label}</h3>
          <p class="mt-1 text-sm text-slate-500">{cat.desc}</p>
          <p class="mt-4 text-xs font-semibold uppercase tracking-wide text-slate-400">{cat.count} {cat.count === 1 ? 'item' : 'items'}</p>
        </a>
      ))}
    </div>
  </section>

  {recent.length > 0 && (
    <section class="mx-auto w-full max-w-7xl px-4 pb-20 sm:px-6 lg:px-8">
      <div class="mb-6 flex items-end justify-between gap-4">
        <div>
          <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Recent notes</h2>
          <p class="mt-1.5 text-sm text-slate-500">Freshly added study material.</p>
        </div>
        <a href="/notes" class="hidden items-center gap-1 text-sm font-semibold text-emerald-700 hover:text-emerald-800 sm:inline-flex">
          View all <Icon name="arrow-right" size={14} strokeWidth={2.6} />
        </a>
      </div>
      <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
        {recent.map(n => (
          <a href={`/notes/${n.id}`} class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-4 transition-colors hover:border-emerald-300">
            <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-emerald-100 text-emerald-700">
              <Icon name="file-text" size={18} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <h3 class="truncate text-[0.925rem] font-bold tracking-tight text-slate-900">{n.data.title}</h3>
              <div class="mt-1.5 flex flex-wrap gap-1.5">
                <span class="rounded-md bg-emerald-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-emerald-700">{n.data.subject}</span>
                <span class="rounded-md bg-blue-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-blue-700">Class {n.data.class}</span>
              </div>
            </div>
            <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-transform group-hover:translate-x-0.5 group-hover:text-emerald-600" />
          </a>
        ))}
      </div>
    </section>
  )}
</BaseLayout>
EOF

# ============ CLASSES HUB ============
cat > src/pages/classes/index.astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { getTaxonomy } from '../../lib/taxonomy';

const { classes } = await getTaxonomy();
const tints = ['emerald', 'blue', 'amber', 'violet'];
---
<BaseLayout title="Classes — TaleemHub" description="Browse notes, quizzes and textbooks by class for Pakistani students.">
  <div class="mx-auto w-full max-w-7xl px-4 pt-10 sm:px-6 sm:pt-14 lg:px-8">
    <div class="mb-10">
      <h1 class="font-display text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">Browse by class</h1>
      <p class="mt-2 text-slate-500">Pick your class and see every note, quiz, textbook and gazette we have.</p>
    </div>
    {classes.length === 0 ? (
      <div class="rounded-2xl border border-dashed border-slate-300 bg-white p-12 text-center">
        <div class="text-base font-bold text-slate-900">No content yet</div>
      </div>
    ) : (
      <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {classes.map((c, i) => {
          const tint = tints[i % tints.length];
          return (
            <a href={`/classes/${c.class}`} class="group relative overflow-hidden rounded-2xl border border-slate-200 bg-white p-6 transition-colors hover:border-emerald-300">
              <div class="flex items-start justify-between">
                <span class:list={[
                  "grid h-12 w-12 place-items-center rounded-xl",
                  tint === 'emerald' && "bg-emerald-100 text-emerald-700",
                  tint === 'blue'    && "bg-blue-100 text-blue-700",
                  tint === 'amber'   && "bg-amber-100 text-amber-700",
                  tint === 'violet'  && "bg-violet-100 text-violet-700",
                ]}>
                  <Icon name="graduation-cap" size={22} strokeWidth={2.2} />
                </span>
                <Icon name="arrow-up-right" size={18} strokeWidth={2.4} class="text-slate-300 transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-emerald-600" />
              </div>
              <h3 class="mt-5 font-display text-2xl font-extrabold tracking-tight text-slate-900">Class {c.class}</h3>
              <p class="mt-1 text-sm text-slate-500">{c.subjects.length} {c.subjects.length === 1 ? 'subject' : 'subjects'} · {c.total} {c.total === 1 ? 'item' : 'items'}</p>
            </a>
          );
        })}
      </div>
    )}
  </div>
</BaseLayout>
EOF

cat > src/pages/classes/[class].astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { getTaxonomy, slugify } from '../../lib/taxonomy';

export async function getStaticPaths() {
  const { classes } = await getTaxonomy();
  return classes.map(c => ({ params: { class: c.class } }));
}

const { class: cls } = Astro.params;
const { classes } = await getTaxonomy();
const data = classes.find(c => c.class === cls);

const sections = data ? [
  { key: 'notes',    label: 'Notes',     icon: 'file-text',     base: '/notes',    tint: 'emerald', items: data.notes },
  { key: 'quizzes',  label: 'Quizzes',   icon: 'file-question', base: '/quizzes',  tint: 'blue',    items: data.quizzes },
  { key: 'books',    label: 'Textbooks', icon: 'book-marked',   base: '/books',    tint: 'amber',   items: data.books },
  { key: 'gazettes', label: 'Gazettes',  icon: 'scroll-text',   base: '/gazettes', tint: 'rose',    items: data.gazettes },
].filter(s => s.items.length > 0) : [];
---
{data ? (
<BaseLayout title={`Class ${cls} Notes, Quizzes & Books — TaleemHub`} description={`Free notes, quizzes, textbooks and gazettes for Class ${cls} students in Pakistan.`}>
  <div class="mx-auto w-full max-w-7xl px-4 pt-10 sm:px-6 sm:pt-14 lg:px-8">
    <a href="/classes" class="mb-6 inline-flex items-center gap-2 text-sm font-semibold text-slate-500 transition-colors hover:text-emerald-700">
      <Icon name="arrow-left" size={16} strokeWidth={2.4} /> All classes
    </a>

    <div class="relative overflow-hidden rounded-3xl border border-emerald-700 bg-gradient-to-br from-emerald-900 via-emerald-800 to-emerald-600 p-8 text-white sm:p-10">
      <span class="inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider backdrop-blur-sm">
        <Icon name="graduation-cap" size={13} strokeWidth={2.4} /> Class
      </span>
      <h1 class="mt-4 font-display text-4xl font-extrabold leading-tight tracking-tight sm:text-5xl">Class {cls}</h1>
      <p class="mt-2 text-emerald-100">{data.subjects.length} {data.subjects.length === 1 ? 'subject' : 'subjects'} · {data.total} {data.total === 1 ? 'item' : 'items'}</p>
      {data.subjects.length > 0 && (
        <div class="mt-5 flex flex-wrap gap-1.5">
          {data.subjects.map(s => (
            <a href={`/subjects/${slugify(s)}`} class="rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wide backdrop-blur-sm transition-colors hover:bg-white/20">
              {s}
            </a>
          ))}
        </div>
      )}
    </div>

    {sections.map(sec => (
      <section class="mt-12">
        <div class="mb-5 flex items-center gap-3">
          <span class:list={[
            "grid h-10 w-10 place-items-center rounded-xl",
            sec.tint === 'emerald' && "bg-emerald-100 text-emerald-700",
            sec.tint === 'blue'    && "bg-blue-100 text-blue-700",
            sec.tint === 'amber'   && "bg-amber-100 text-amber-700",
            sec.tint === 'rose'    && "bg-rose-100 text-rose-700",
          ]}>
            <Icon name={sec.icon} size={20} strokeWidth={2.2} />
          </span>
          <div>
            <h2 class="font-display text-xl font-extrabold tracking-tight text-slate-900">{sec.label}</h2>
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
                sec.tint === 'rose'    && "bg-rose-100 text-rose-700",
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
  </div>
</BaseLayout>
) : (
<BaseLayout title="Class not found — TaleemHub">
  <div class="mx-auto w-full max-w-7xl px-4 pt-20 text-center sm:px-6 lg:px-8">
    <a href="/classes" class="text-sm font-semibold text-emerald-700">Back to classes</a>
  </div>
</BaseLayout>
)}
EOF

# ============ SUBJECTS HUB ============
cat > src/pages/subjects/index.astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { getTaxonomy, slugify } from '../../lib/taxonomy';

const { subjects } = await getTaxonomy();
---
<BaseLayout title="Subjects — TaleemHub" description="Browse notes, quizzes and textbooks by subject.">
  <div class="mx-auto w-full max-w-7xl px-4 pt-10 sm:px-6 sm:pt-14 lg:px-8">
    <div class="mb-10">
      <h1 class="font-display text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">Browse by subject</h1>
      <p class="mt-2 text-slate-500">Every subject we cover, across all classes.</p>
    </div>
    {subjects.length === 0 ? (
      <div class="rounded-2xl border border-dashed border-slate-300 bg-white p-12 text-center">
        <div class="text-base font-bold text-slate-900">No content yet</div>
      </div>
    ) : (
      <div class="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
        {subjects.map(s => (
          <a href={`/subjects/${slugify(s.subject)}`} class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-5 transition-colors hover:border-emerald-300">
            <span class="grid h-12 w-12 shrink-0 place-items-center rounded-xl bg-emerald-100 text-emerald-700">
              <Icon name="library" size={22} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <h3 class="font-display text-base font-extrabold tracking-tight text-slate-900">{s.subject}</h3>
              <p class="mt-0.5 truncate text-xs font-semibold text-slate-500">{s.total} {s.total === 1 ? 'item' : 'items'} · Class {s.classes.join(', ')}</p>
            </div>
            <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-transform group-hover:translate-x-0.5 group-hover:text-emerald-600" />
          </a>
        ))}
      </div>
    )}
  </div>
</BaseLayout>
EOF

cat > src/pages/subjects/[subject].astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { getTaxonomy, slugify } from '../../lib/taxonomy';

export async function getStaticPaths() {
  const { subjects } = await getTaxonomy();
  return subjects.map(s => ({ params: { subject: slugify(s.subject) } }));
}

const { subject: slug } = Astro.params;
const { subjects } = await getTaxonomy();
const data = subjects.find(s => slugify(s.subject) === slug);

const sections = data ? [
  { key: 'notes',   label: 'Notes',     icon: 'file-text',     base: '/notes',   items: data.notes },
  { key: 'quizzes', label: 'Quizzes',   icon: 'file-question', base: '/quizzes', items: data.quizzes },
  { key: 'books',   label: 'Textbooks', icon: 'book-marked',   base: '/books',   items: data.books },
].filter(s => s.items.length > 0) : [];
---
{data ? (
<BaseLayout title={`${data.subject} Notes, Quizzes & Books — TaleemHub`} description={`Free ${data.subject} notes, quizzes and textbooks for Pakistani students across all classes.`}>
  <div class="mx-auto w-full max-w-7xl px-4 pt-10 sm:px-6 sm:pt-14 lg:px-8">
    <a href="/subjects" class="mb-6 inline-flex items-center gap-2 text-sm font-semibold text-slate-500 transition-colors hover:text-emerald-700">
      <Icon name="arrow-left" size={16} strokeWidth={2.4} /> All subjects
    </a>

    <div class="relative overflow-hidden rounded-3xl border border-emerald-700 bg-gradient-to-br from-emerald-900 via-emerald-800 to-emerald-600 p-8 text-white sm:p-10">
      <span class="inline-flex items-center gap-1.5 rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider backdrop-blur-sm">
        <Icon name="library" size={13} strokeWidth={2.4} /> Subject
      </span>
      <h1 class="mt-4 font-display text-4xl font-extrabold leading-tight tracking-tight sm:text-5xl">{data.subject}</h1>
      <p class="mt-2 text-emerald-100">{data.total} {data.total === 1 ? 'item' : 'items'} across Class {data.classes.join(', ')}</p>
      <div class="mt-5 flex flex-wrap gap-1.5">
        {data.classes.map(c => (
          <a href={`/classes/${c}`} class="rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wide backdrop-blur-sm transition-colors hover:bg-white/20">
            Class {c}
          </a>
        ))}
      </div>
    </div>

    {sections.map(sec => (
      <section class="mt-12">
        <div class="mb-5">
          <h2 class="font-display text-xl font-extrabold tracking-tight text-slate-900">{data.subject} {sec.label}</h2>
          <p class="text-sm text-slate-500">{sec.items.length} {sec.items.length === 1 ? 'item' : 'items'}</p>
        </div>
        <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
          {sec.items.map((item) => (
            <a href={`${sec.base}/${item.id}`} class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-4 transition-colors hover:border-emerald-300">
              <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-emerald-100 text-emerald-700">
                <Icon name={sec.icon} size={18} strokeWidth={2.2} />
              </span>
              <div class="min-w-0 flex-1">
                <h3 class="truncate text-[0.925rem] font-bold tracking-tight text-slate-900">{item.data.title}</h3>
                <div class="mt-1.5 flex flex-wrap gap-1.5">
                  <span class="rounded-md bg-emerald-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-emerald-700">Class {item.data.class}</span>
                </div>
              </div>
              <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-transform group-hover:translate-x-0.5 group-hover:text-emerald-600" />
            </a>
          ))}
        </div>
      </section>
    ))}
  </div>
</BaseLayout>
) : (
<BaseLayout title="Subject not found — TaleemHub">
  <div class="mx-auto w-full max-w-7xl px-4 pt-20 text-center sm:px-6 lg:px-8">
    <a href="/subjects" class="text-sm font-semibold text-emerald-700">Back to subjects</a>
  </div>
</BaseLayout>
)}
EOF

# ============ REMOVE the class-first routes ============
rm -rf src/pages/class

# ============ CLEAR CACHES ============
rm -rf .astro node_modules/.vite node_modules/.astro dist

echo ""
echo "Restored to the version you liked."
echo ""
echo "Run:  npm run dev"
echo "Then hard-refresh the browser."