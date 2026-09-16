#!/bin/bash
set -e

echo "Removing illustrations..."

rm -f src/components/Illustration.astro

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
  { href: '/notes',    label: 'Notes',    count: notes.length,    icon: 'file-text',     desc: 'Chapter-wise notes for every subject' },
  { href: '/quizzes',  label: 'Quizzes',  count: quizzes.length,  icon: 'file-question', desc: 'Practice MCQs with instant answers' },
  { href: '/books',    label: 'Books',    count: books.length,    icon: 'book-marked',   desc: 'Full textbooks from every board' },
  { href: '/gazettes', label: 'Gazettes', count: gazettes.length, icon: 'scroll-text',   desc: 'Official results and past gazettes' },
];

const recent = [...notes].slice(0, 6);
---
<BaseLayout title="TaleemHub — Exam-specific revision for Pakistani students">
  <!-- HERO -->
  <section class="border-b border-neutral-200 bg-neutral-50">
    <div class="mx-auto max-w-[1320px] px-4 py-16 lg:px-8 lg:py-24">
      <div class="max-w-3xl">
        <div class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-[#0620ed]">
          <span class="h-1.5 w-1.5 rounded-full bg-[#0620ed]"></span>
          Trusted by students across Pakistan
        </div>
        <h1 class="mt-5 text-[2.5rem] font-extrabold leading-[1.08] tracking-[-0.035em] text-neutral-900 sm:text-6xl">
          Exam-specific revision,<br />
          made simple.
        </h1>
        <p class="mt-6 max-w-xl text-base leading-relaxed text-neutral-500 sm:text-lg">
          Notes, interactive quizzes, textbooks and result gazettes — organised by class and subject, all completely free.
        </p>

        <form action="/search" method="get" role="search" class="mt-8 flex max-w-lg items-center gap-2 rounded-2xl border border-neutral-200 bg-white p-1.5 pl-4 focus-within:border-[#0620ed]">
          <Icon name="search" size={18} strokeWidth={2.4} class="shrink-0 text-neutral-400" />
          <input type="search" name="q" placeholder="Search notes, books, past papers..." class="min-w-0 flex-1 bg-transparent py-2.5 text-sm text-neutral-900 outline-none placeholder:text-neutral-400" />
          <button type="submit" class="rounded-xl bg-[#0620ed] px-4 py-2.5 text-sm font-bold text-white transition-colors hover:bg-[#110176]">Search</button>
        </form>

        <div class="mt-6 flex flex-wrap items-center gap-x-5 gap-y-2 text-sm font-medium text-neutral-500">
          <span class="flex items-center gap-1.5"><Icon name="zap" size={14} strokeWidth={2.4} class="text-[#0620ed]" /> Instant answers</span>
          <span class="h-1 w-1 rounded-full bg-neutral-300"></span>
          <span class="flex items-center gap-1.5"><Icon name="download" size={14} strokeWidth={2.4} class="text-[#0620ed]" /> Free PDFs</span>
          <span class="h-1 w-1 rounded-full bg-neutral-300"></span>
          <span class="flex items-center gap-1.5"><Icon name="check" size={14} strokeWidth={2.6} class="text-[#0620ed]" /> All boards</span>
        </div>
      </div>
    </div>
  </section>

  <!-- STATS -->
  <section class="mx-auto max-w-[1320px] px-4 py-14 lg:px-8">
    <div class="grid grid-cols-2 gap-4 lg:grid-cols-4">
      {categories.map(cat => (
        <a href={cat.href} class="group rounded-2xl border border-neutral-200 bg-white p-5 transition-colors hover:border-neutral-400">
          <span class="grid h-11 w-11 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
            <Icon name={cat.icon} size={20} strokeWidth={2.2} />
          </span>
          <div class="mt-4 text-3xl font-extrabold tracking-tight text-neutral-900">{cat.count}</div>
          <div class="mt-0.5 flex items-center gap-1 text-sm font-semibold text-neutral-500">
            {cat.label}
            <Icon name="arrow-up-right" size={13} strokeWidth={2.4} class="opacity-0 transition-opacity group-hover:opacity-100" />
          </div>
        </a>
      ))}
    </div>
  </section>

  <!-- BROWSE BY CLASS -->
  {classes.length > 0 && (
    <section class="mx-auto max-w-[1320px] px-4 py-10 lg:px-8">
      <div class="mb-6 flex items-end justify-between gap-4">
        <div>
          <h2 class="text-2xl font-extrabold tracking-tight text-neutral-900 sm:text-3xl">Browse by class</h2>
          <p class="mt-1.5 text-sm text-neutral-500">Everything for your class in one place.</p>
        </div>
        <a href="/classes" class="hidden items-center gap-1 text-sm font-bold text-[#0620ed] hover:text-[#110176] sm:inline-flex">
          All classes <Icon name="arrow-right" size={14} strokeWidth={2.6} />
        </a>
      </div>
      <div class="grid grid-cols-2 gap-3 lg:grid-cols-4">
        {classes.map(c => (
          <a href={`/classes/${c.class}`} class="group flex items-center gap-3.5 rounded-2xl border border-neutral-200 bg-white p-4 transition-colors hover:border-[#0620ed] sm:p-5">
            <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
              <Icon name="graduation-cap" size={20} strokeWidth={2.2} />
            </span>
            <div class="min-w-0">
              <div class="text-base font-extrabold tracking-tight text-neutral-900">Class {c.class}</div>
              <div class="truncate text-xs font-semibold text-neutral-500">{c.total} {c.total === 1 ? 'item' : 'items'}</div>
            </div>
          </a>
        ))}
      </div>
    </section>
  )}

  <!-- BROWSE BY SUBJECT -->
  {subjects.length > 0 && (
    <section class="mx-auto max-w-[1320px] px-4 pb-6 lg:px-8">
      <div class="mb-6 flex items-end justify-between gap-4">
        <div>
          <h2 class="text-2xl font-extrabold tracking-tight text-neutral-900 sm:text-3xl">Browse by subject</h2>
          <p class="mt-1.5 text-sm text-neutral-500">Pick your subject, then your class.</p>
        </div>
        <a href="/subjects" class="hidden items-center gap-1 text-sm font-bold text-[#0620ed] hover:text-[#110176] sm:inline-flex">
          All subjects <Icon name="arrow-right" size={14} strokeWidth={2.6} />
        </a>
      </div>
      <div class="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
        {subjects.map(s => (
          <a href={`/subjects/${slugify(s.subject)}`} class="group flex items-center gap-4 rounded-2xl border border-neutral-200 bg-white p-5 transition-colors hover:border-[#0620ed]">
            <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
              <Icon name="library" size={20} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <div class="text-base font-extrabold tracking-tight text-neutral-900">{s.subject}</div>
              <div class="truncate text-xs font-semibold text-neutral-500">{s.total} {s.total === 1 ? 'item' : 'items'} · Class {s.classes.join(', ')}</div>
            </div>
            <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-neutral-300 transition-transform group-hover:translate-x-0.5 group-hover:text-[#0620ed]" />
          </a>
        ))}
      </div>
    </section>
  )}

  <!-- BROWSE THE LIBRARY -->
  <section class="mx-auto max-w-[1320px] px-4 py-14 lg:px-8">
    <div class="mb-6">
      <h2 class="text-2xl font-extrabold tracking-tight text-neutral-900 sm:text-3xl">Browse the library</h2>
      <p class="mt-1.5 text-sm text-neutral-500">Jump straight into what you're studying.</p>
    </div>
    <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
      {categories.map(cat => (
        <a href={cat.href} class="group rounded-2xl border border-neutral-200 bg-white p-6 transition-colors hover:border-neutral-400">
          <div class="flex items-start justify-between">
            <span class="grid h-11 w-11 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
              <Icon name={cat.icon} size={20} strokeWidth={2.2} />
            </span>
            <Icon name="arrow-up-right" size={17} strokeWidth={2.3} class="text-neutral-300 transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-[#0620ed]" />
          </div>
          <h3 class="mt-5 text-base font-extrabold tracking-tight text-neutral-900">{cat.label}</h3>
          <p class="mt-1.5 text-sm leading-relaxed text-neutral-500">{cat.desc}</p>
          <p class="mt-5 text-[11px] font-bold uppercase tracking-wider text-neutral-400">{cat.count} {cat.count === 1 ? 'item' : 'items'}</p>
        </a>
      ))}
    </div>
  </section>

  <!-- RECENT -->
  {recent.length > 0 && (
    <section class="mx-auto max-w-[1320px] px-4 pb-20 lg:px-8">
      <div class="mb-6 flex items-end justify-between gap-4">
        <div>
          <h2 class="text-2xl font-extrabold tracking-tight text-neutral-900 sm:text-3xl">Recent notes</h2>
          <p class="mt-1.5 text-sm text-neutral-500">Freshly added study material.</p>
        </div>
        <a href="/notes" class="hidden items-center gap-1 text-sm font-bold text-[#0620ed] hover:text-[#110176] sm:inline-flex">
          View all <Icon name="arrow-right" size={14} strokeWidth={2.6} />
        </a>
      </div>
      <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
        {recent.map(n => (
          <a href={`/notes/${n.id}`} class="group flex items-center gap-4 rounded-2xl border border-neutral-200 bg-white p-4 transition-colors hover:border-[#0620ed]">
            <span class="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-[#eef2fe] text-[#0620ed]">
              <Icon name="file-text" size={17} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <h3 class="truncate text-sm font-bold text-neutral-900">{n.data.title}</h3>
              <div class="mt-1.5 flex flex-wrap gap-1.5">
                <span class="rounded-md bg-neutral-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-neutral-600">{n.data.subject}</span>
                <span class="rounded-md bg-[#eef2fe] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#0620ed]">Class {n.data.class}</span>
              </div>
            </div>
            <Icon name="chevron-right" size={15} strokeWidth={2.4} class="shrink-0 text-neutral-300 transition-transform group-hover:translate-x-0.5 group-hover:text-[#0620ed]" />
          </a>
        ))}
      </div>
    </section>
  )}
</BaseLayout>
EOF

rm -rf .astro node_modules/.vite node_modules/.astro dist

echo ""
echo "Illustrations removed. Home page restored."
echo ""
echo "Run:  npm run dev"