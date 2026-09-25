#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "════════════════════════════════════════════"
echo "  Books v2 — richer, distinct page anatomies"
echo "════════════════════════════════════════════"
echo ""

git branch -f backup-pre-books-v2 2>/dev/null || true
echo "  ✓ backup-pre-books-v2 created"
echo ""

# ═════════════════════════════════════════════════════════
#  1. New BookCover component — designed, not a placeholder
# ═════════════════════════════════════════════════════════
echo "▸ 1. Building BookCover component..."

cat > src/components/BookCover.astro <<'ASTRO'
---
import Icon from './Icon.astro';

interface Props {
  subject: string;
  classNumber: string;
  board: string;
  boardShort: string;
  medium?: string;
  year?: string;
  size?: 'sm' | 'md' | 'lg';
  class?: string;
}

const { subject, classNumber, board, boardShort, medium, year, size = 'md', class: className = '' } = Astro.props;

// ── Subject → color + icon (mirrors SubjectIcon map) ──
const key = subject.toLowerCase()
  .replace(/\(.*?\)/g, '')
  .replace(/[^a-z\s]/g, '')
  .trim();

const MAP: Record<string, { icon: string; color: string }> = {
  'english':            { icon: 'feather',      color: 'amber' },
  'urdu':               { icon: 'pen-tool',     color: 'teal' },
  'sindhi':             { icon: 'pen-tool',     color: 'teal' },
  'punjabi':            { icon: 'pen-tool',     color: 'teal' },
  'farsi':              { icon: 'pen-tool',     color: 'teal' },
  'arabic':             { icon: 'languages',    color: 'teal' },
  'salees urdu':        { icon: 'pen-tool',     color: 'teal' },
  'gulzar e urdu':      { icon: 'pen-tool',     color: 'teal' },
  'physics':            { icon: 'atom',         color: 'blue' },
  'chemistry':          { icon: 'flask',        color: 'emerald' },
  'biology':            { icon: 'leaf',         color: 'green' },
  'general science':    { icon: 'microscope',   color: 'sky' },
  'science':            { icon: 'microscope',   color: 'sky' },
  'bio tech':           { icon: 'leaf',         color: 'green' },
  'mathematics':        { icon: 'sigma',        color: 'violet' },
  'math':               { icon: 'sigma',        color: 'violet' },
  'riazi':              { icon: 'sigma',        color: 'violet' },
  'statistics':         { icon: 'bar-chart',    color: 'violet' },
  'general mathematics':{ icon: 'sigma',        color: 'violet' },
  'geography':          { icon: 'map',          color: 'amber' },
  'history':            { icon: 'scroll',       color: 'amber' },
  'islamiat':           { icon: 'star',         color: 'emerald' },
  'islamiyat':          { icon: 'star',         color: 'emerald' },
  'islamic studies':    { icon: 'star',         color: 'emerald' },
  'pakistan studies':   { icon: 'map',          color: 'emerald' },
  'pak study':          { icon: 'map',          color: 'emerald' },
  'mutala e pakistan':  { icon: 'map',          color: 'emerald' },
  'civics':             { icon: 'landmark',     color: 'indigo' },
  'economics':          { icon: 'trending-up',  color: 'amber' },
  'psychology':         { icon: 'brain',        color: 'rose' },
  'nafsiyat':           { icon: 'brain',        color: 'rose' },
  'education':          { icon: 'graduation-cap', color: 'indigo' },
  'ilm ul taleem':      { icon: 'graduation-cap', color: 'indigo' },
  'tarjuma tul quran':  { icon: 'book',         color: 'emerald' },
  'translation quran':  { icon: 'book',         color: 'emerald' },
  'tarjuma tul quran majeed': { icon: 'book',   color: 'emerald' },
  'nazra quran':        { icon: 'book',         color: 'emerald' },
  'akhlaqiat':          { icon: 'heart',        color: 'rose' },
  'mazhabi taleemat':   { icon: 'heart',        color: 'rose' },
  'religious studies':  { icon: 'heart',        color: 'rose' },
  'buddhism':           { icon: 'heart',        color: 'rose' },
  'sikhism':            { icon: 'heart',        color: 'rose' },
  'sanatan dharam':     { icon: 'heart',        color: 'rose' },
  'zoroastrian religion': { icon: 'heart',      color: 'rose' },
  'mashi taleem':       { icon: 'heart',        color: 'rose' },
  'computer science':   { icon: 'cpu',          color: 'cyan' },
  'computer':           { icon: 'cpu',          color: 'cyan' },
  'computer education': { icon: 'cpu',          color: 'cyan' },
  'computer ki taleem': { icon: 'cpu',          color: 'cyan' },
  'computer ji taleem': { icon: 'cpu',          color: 'cyan' },
  'ict':                { icon: 'cpu',          color: 'cyan' },
  'health physical education': { icon: 'activity', color: 'rose' },
  'home economics':     { icon: 'home',         color: 'rose' },
  'art drawing':        { icon: 'palette',      color: 'fuchsia' },
  'general knowledge':  { icon: 'lightbulb',    color: 'amber' },
  'waqfiyat e aama':    { icon: 'lightbulb',    color: 'amber' },
  'muasharti uloom':    { icon: 'globe',        color: 'amber' },
  'social studies':     { icon: 'globe',        color: 'amber' },
};
const cfg = MAP[key] || { icon: 'book', color: 'blue' };

const COLORS: Record<string, { bg: string; tint: string; fg: string; line: string }> = {
  amber:   { bg: '#f59e0b', tint: '#fef3c7', fg: '#b45309', line: '#fde68a' },
  teal:    { bg: '#14b8a6', tint: '#ccfbf1', fg: '#0f766e', line: '#99f6e4' },
  blue:    { bg: '#3b82f6', tint: '#dbeafe', fg: '#1d4ed8', line: '#bfdbfe' },
  emerald: { bg: '#10b981', tint: '#d1fae5', fg: '#047857', line: '#a7f3d0' },
  green:   { bg: '#22c55e', tint: '#dcfce7', fg: '#15803d', line: '#bbf7d0' },
  sky:     { bg: '#0ea5e9', tint: '#e0f2fe', fg: '#0369a1', line: '#bae6fd' },
  violet:  { bg: '#8b5cf6', tint: '#ede9fe', fg: '#6d28d9', line: '#ddd6fe' },
  cyan:    { bg: '#06b6d4', tint: '#cffafe', fg: '#0e7490', line: '#a5f3fc' },
  indigo:  { bg: '#6366f1', tint: '#e0e7ff', fg: '#4338ca', line: '#c7d2fe' },
  rose:    { bg: '#f43f5e', tint: '#ffe4e6', fg: '#be123c', line: '#fecdd3' },
  fuchsia: { bg: '#d946ef', tint: '#fae8ff', fg: '#a21caf', line: '#f5d0fe' },
};
const c = COLORS[cfg.color] || COLORS.blue;

const sizes = {
  sm: { width: 80, spine: 5, icon: 22, titleFs: 10, metaFs: 8, pad: 8 },
  md: { width: 140, spine: 8, icon: 38, titleFs: 13, metaFs: 9, pad: 14 },
  lg: { width: 200, spine: 10, icon: 52, titleFs: 17, metaFs: 11, pad: 18 },
}[size];

const mediumShort = medium === 'english' ? 'EM' : medium === 'urdu' ? 'UM' : medium === 'sindhi' ? 'SM' : '';
---
<div class={`book-cover book-cover-${size} ${className}`} style={`width: ${sizes.width}px; aspect-ratio: 3 / 4; position: relative; background: #ffffff; border: 1px solid #e5e9f0; border-radius: 6px; overflow: hidden; flex-shrink: 0;`}>
  <!-- Colored spine on the left -->
  <div style={`position: absolute; inset: 0 auto 0 0; width: ${sizes.spine}px; background: ${c.bg};`}></div>

  <!-- Top colored band -->
  <div style={`position: absolute; top: 0; left: ${sizes.spine}px; right: 0; height: 3px; background: ${c.bg}; opacity: 0.25;`}></div>

  <!-- Content -->
  <div style={`position: absolute; inset: 0; padding: ${sizes.pad}px ${sizes.pad}px ${sizes.pad}px ${sizes.pad + sizes.spine}px; display: flex; flex-direction: column;`}>
    <!-- Board -->
    <div style={`font-size: ${sizes.metaFs}px; font-weight: 800; letter-spacing: 0.08em; text-transform: uppercase; color: ${c.fg};`}>
      {boardShort}
    </div>

    <!-- Icon -->
    <div style={`flex: 1; display: grid; place-items: center; color: ${c.bg};`}>
      <Icon name={cfg.icon} size={sizes.icon} strokeWidth={1.8} />
    </div>

    <!-- Subject title -->
    <div style={`font-size: ${sizes.titleFs}px; font-weight: 800; letter-spacing: -0.02em; color: #0b1220; line-height: 1.15; word-break: break-word;`}>
      {subject}
    </div>

    <!-- Bottom meta -->
    <div style={`margin-top: 8px; padding-top: 8px; border-top: 1px solid ${c.line}; display: flex; align-items: center; justify-content: space-between; gap: 4px;`}>
      <span style={`font-size: ${sizes.metaFs}px; font-weight: 800; color: #64748b; letter-spacing: 0.04em;`}>
        CLASS {classNumber}
      </span>
      {mediumShort && (
        <span style={`font-size: ${sizes.metaFs}px; font-weight: 800; color: ${c.fg}; background: ${c.tint}; padding: 1px 5px; border-radius: 3px;`}>
          {mediumShort}
        </span>
      )}
    </div>
  </div>
</div>
ASTRO

echo "  ✓ BookCover rebuilt"

# ═════════════════════════════════════════════════════════
#  2. Improved /books — board cards with province colors
# ═════════════════════════════════════════════════════════
echo ""
echo "▸ 2. Rewriting /books board picker..."

cat > src/pages/books/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import { url } from '../../lib/url';
import { getCollection } from 'astro:content';

const books = await getCollection('books');

const boardCounts = new Map<string, number>();
books.forEach((b: any) => {
  const board = (b.data.boards || [])[0];
  if (board) boardCounts.set(board, (boardCounts.get(board) || 0) + 1);
});

const ORDER = ['Punjab', 'Federal', 'Sindh', 'KPK', 'Balochistan', 'AJK'];
const boards = [...boardCounts.keys()]
  .sort((a, b) => {
    const ai = ORDER.indexOf(a), bi = ORDER.indexOf(b);
    if (ai === -1 && bi === -1) return a.localeCompare(b);
    if (ai === -1) return 1;
    if (bi === -1) return -1;
    return ai - bi;
  });

// Province color themes
const THEME: Record<string, { short: string; desc: string; color: string; bg: string; line: string; fg: string }> = {
  'Punjab':      { short: 'PTB',   desc: 'Punjab Curriculum and Textbook Board — books for all schools in Punjab.',           color: '#10b981', bg: '#d1fae5', line: '#a7f3d0', fg: '#047857' },
  'Federal':     { short: 'FBISE', desc: 'Federal Board — federal schools, cadet colleges, and Pakistani schools abroad.', color: '#3b82f6', bg: '#dbeafe', line: '#bfdbfe', fg: '#1d4ed8' },
  'Sindh':       { short: 'STBB',  desc: 'Sindh Textbook Board — English, Urdu, and Sindhi medium books for all Sindh schools.', color: '#8b5cf6', bg: '#ede9fe', line: '#ddd6fe', fg: '#6d28d9' },
  'KPK':         { short: 'KPTBB', desc: 'Khyber Pakhtunkhwa Textbook Board — official KPK books.',                          color: '#0ea5e9', bg: '#e0f2fe', line: '#bae6fd', fg: '#0369a1' },
  'Balochistan': { short: 'BTBB',  desc: 'Balochistan Textbook Board — official books for all Balochistan schools.',          color: '#f59e0b', bg: '#fef3c7', line: '#fde68a', fg: '#b45309' },
  'AJK':         { short: 'AJKTB', desc: 'AJK Textbook Board — books for Azad Jammu and Kashmir schools.',                    color: '#f43f5e', bg: '#ffe4e6', line: '#fecdd3', fg: '#be123c' },
};

const totalBooks = books.length;

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  name: 'Pakistani Textbooks — Free PDF Library',
  description: `Complete library of official Pakistani textbooks — ${totalBooks} books from Punjab (PTB), Federal (FBISE), Sindh (STBB), Balochistan (BTBB). Free downloads for Class 1–12.`,
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
      <div class="max-w-2xl">
        <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">Pakistani Textbooks</h1>
        <p class="mt-4 text-base leading-relaxed text-slate-600 sm:text-lg">
          Official textbooks from every major Pakistani board — free PDFs, no sign-up, no ads.
        </p>
      </div>
      <div class="mt-6 flex flex-wrap gap-x-6 gap-y-2 text-sm text-slate-500">
        <span><strong class="font-extrabold text-slate-900">{totalBooks}</strong> books</span>
        <span><strong class="font-extrabold text-slate-900">{boards.length}</strong> boards</span>
        <span><strong class="font-extrabold text-slate-900">Class 1–12</strong></span>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
    <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Choose your board</h2>
    <p class="mt-2 text-sm text-slate-500">Each board publishes its own textbooks. Pick the one that matches your school.</p>

    <div class="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
      {boards.map(b => {
        const t = THEME[b] || { short: b, desc: `Official ${b} textbooks.`, color: '#1d4ed8', bg: '#eff4ff', line: '#c7d7fe', fg: '#1d4ed8' };
        const count = boardCounts.get(b) || 0;
        return (
          <a href={url(`/books/${b.toLowerCase()}`)} class="group relative overflow-hidden rounded-2xl border border-slate-200 bg-white transition-colors hover:border-slate-300">
            <!-- Colored top band -->
            <div style={`height: 4px; background: ${t.color};`}></div>
            <div class="p-6">
              <div class="flex items-start justify-between gap-4">
                <!-- Board abbreviation as mini logo -->
                <span style={`display:inline-grid;place-items:center;min-width:52px;height:32px;padding:0 10px;border-radius:8px;background:${t.bg};color:${t.fg};font-size:11px;font-weight:800;letter-spacing:0.05em;`}>
                  {t.short}
                </span>
                <svg class="text-slate-300 transition-all group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-slate-500" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M7 7h10v10"/><path d="M7 17 17 7"/></svg>
              </div>
              <h3 class="mt-5 font-display text-xl font-extrabold tracking-tight text-slate-900">{b}</h3>
              <p class="mt-2 text-sm leading-relaxed text-slate-500">{t.desc}</p>
              <div class="mt-5 flex items-center gap-3">
                <span style={`font-size:11px;font-weight:800;letter-spacing:0.06em;text-transform:uppercase;color:${t.fg};`}>{count} {count === 1 ? 'book' : 'books'}</span>
                <span class="h-1 w-1 rounded-full bg-slate-300"></span>
                <span class="text-[11px] font-bold uppercase tracking-wider text-slate-400">Class 1–12</span>
              </div>
            </div>
          </a>
        );
      })}
    </div>
  </div>

  <!-- SEO copy -->
  <section class="border-t border-slate-200 bg-white">
    <div class="mx-auto max-w-[900px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
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
        <p>Choose your board above, then your class, then your subject. Every book opens as a free PDF — no registration, no paywall, no ads. The full library is over {totalBooks} books and growing.</p>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO

echo "  ✓ /books updated"

# ═════════════════════════════════════════════════════════
#  3. Improved class picker — with subject preview
# ═════════════════════════════════════════════════════════
echo ""
echo "▸ 3. Rewriting class picker..."

cat > 'src/pages/books/[board]/index.astro' <<'ASTRO'
---
import BaseLayout from '../../../layouts/BaseLayout.astro';
import SubjectIcon from '../../../components/SubjectIcon.astro';
import { url } from '../../../lib/url';
import { boardMeta, bookSubjectName, subjectSlug } from '../../../lib/bookSeo';
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

// Build per-class data with subject preview
interface ClassData {
  cls: string;
  count: number;
  subjects: { subject: string; slug: string }[];
  mediums: Set<string>;
}
const classMap = new Map<string, ClassData>();
books.forEach((b: any) => {
  const cls = String(b.data.class);
  if (!classMap.has(cls)) classMap.set(cls, { cls, count: 0, subjects: [], mediums: new Set() });
  const cd = classMap.get(cls)!;
  cd.count++;
  const subj = bookSubjectName(b.data.subject);
  if (!cd.subjects.find(s => s.subject === subj)) {
    cd.subjects.push({ subject: subj, slug: subjectSlug(subj) });
  }
  if (b.data.medium) cd.mediums.add(b.data.medium);
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
  description={`Download all ${boardName} textbooks for free. ${books.length} books across ${classes.length} classes and ${totalSubjects} subjects.`}
  jsonLd={jsonLd}
>
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <a href={url('/books')} class="hover:text-[#1d4ed8]">Textbooks</a>
        <span>/</span>
        <span class="text-slate-500">{boardName}</span>
      </nav>
      <div class="max-w-2xl">
        <div class="inline-flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-[#1d4ed8]">
          <span class="h-1.5 w-1.5 rounded-full bg-[#1d4ed8]"></span>
          {meta.abbreviation}
        </div>
        <h1 class="mt-3 text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">{boardName} Textbooks</h1>
        <p class="mt-4 text-base leading-relaxed text-slate-600 sm:text-lg">
          Every {boardName} textbook from Class 1 to Class 12 — {books.length} books across {totalSubjects} subjects.
        </p>
      </div>
      <div class="mt-6 flex flex-wrap gap-x-6 gap-y-2 text-sm text-slate-500">
        <span><strong class="font-extrabold text-slate-900">{books.length}</strong> books</span>
        <span><strong class="font-extrabold text-slate-900">{classes.length}</strong> classes</span>
        <span><strong class="font-extrabold text-slate-900">{totalSubjects}</strong> subjects</span>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
    <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Choose your class</h2>
    <p class="mt-2 text-sm text-slate-500">Every class has its own set of {boardName} textbooks.</p>

    <div class="mt-6 grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
      {classes.map(c => (
        <a href={url(`/books/${boardSlug}/class-${c.cls}`)} class="group rounded-2xl border border-slate-200 bg-white p-5 transition-colors hover:border-[#1d4ed8]">
          <div class="flex items-start justify-between gap-3">
            <div class="flex items-baseline gap-2">
              <span class="font-display text-3xl font-extrabold leading-none tracking-tight text-slate-900">{c.cls}</span>
              <span class="text-[11px] font-bold uppercase tracking-wider text-slate-400">Class</span>
            </div>
            <span class="rounded-md bg-[#eff4ff] px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider text-[#1d4ed8]">
              {c.count} {c.count === 1 ? 'book' : 'books'}
            </span>
          </div>

          <!-- Subject preview icons -->
          <div class="mt-5 flex flex-wrap gap-1.5">
            {c.subjects.slice(0, 8).map(s => (
              <SubjectIcon subject={s.subject} size="sm" />
            ))}
            {c.subjects.length > 8 && (
              <span class="grid place-items-center h-8 min-w-[32px] px-2 rounded-lg bg-slate-100 text-[10px] font-bold text-slate-500">
                +{c.subjects.length - 8}
              </span>
            )}
          </div>

          <div class="mt-4 flex items-center justify-between">
            <span class="text-[11px] font-bold uppercase tracking-wider text-slate-400">
              {c.subjects.length} {c.subjects.length === 1 ? 'subject' : 'subjects'}
            </span>
            <span class="inline-flex items-center gap-1 text-xs font-bold text-[#1d4ed8] opacity-0 transition-opacity group-hover:opacity-100">
              Open
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>
            </span>
          </div>
        </a>
      ))}
    </div>
  </div>

  <!-- SEO copy -->
  <section class="border-t border-slate-200 bg-white">
    <div class="mx-auto max-w-[900px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
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

echo "  ✓ Class picker updated"

# ═════════════════════════════════════════════════════════
#  4. Improved subject list — with cover thumbnails
# ═════════════════════════════════════════════════════════
echo ""
echo "▸ 4. Rewriting subject list..."

cat > 'src/pages/books/[board]/[class].astro' <<'ASTRO'
---
import BaseLayout from '../../../layouts/BaseLayout.astro';
import Icon from '../../../components/Icon.astro';
import BookCover from '../../../components/BookCover.astro';
import { url } from '../../../lib/url';
import { boardMeta, bookSubjectName, subjectSlug } from '../../../lib/bookSeo';
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
  .filter((b: any) => (b.data.boards || []).includes(boardName) && String(b.data.class) === cls)
  .sort((a: any, b: any) => a.data.subject.localeCompare(b.data.subject));

// Sort by scheme (new first) then year
books.sort((a: any, b: any) => {
  const score = (x: any) => x.data.scheme === 'new' ? 3 : x.data.scheme === 'snc' ? 2 : 1;
  if (score(a) !== score(b)) return score(b) - score(a);
  return (b.data.year || '').localeCompare(a.data.year || '');
});

const subjects = [...new Set(books.map((b: any) => bookSubjectName(b.data.subject)))].sort();

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  name: `Class ${cls} ${boardName} Textbooks — All Subjects`,
  description: `Download all Class ${cls} ${boardName} textbooks free. ${subjects.length} subjects available including ${subjects.slice(0, 5).join(', ')}.`,
};
---
<BaseLayout
  title={`Class ${cls} ${boardName} Textbooks — All Subjects Free PDF | ${meta.abbreviation} | Parhayi`}
  description={`Download all Class ${cls} ${boardName} textbook PDFs. ${subjects.length} subjects including ${subjects.slice(0, 4).join(', ')}. Free, no sign-up.`}
  jsonLd={jsonLd}
>
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <a href={url('/books')} class="hover:text-[#1d4ed8]">Textbooks</a>
        <span>/</span>
        <a href={url(`/books/${boardSlug}`)} class="hover:text-[#1d4ed8]">{boardName}</a>
        <span>/</span>
        <span class="text-slate-500">Class {cls}</span>
      </nav>
      <div class="max-w-2xl">
        <div class="inline-flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-[#1d4ed8]">
          <span class="h-1.5 w-1.5 rounded-full bg-[#1d4ed8]"></span>
          {meta.abbreviation} · Class {cls}
        </div>
        <h1 class="mt-3 text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">
          Class {cls} Textbooks — {boardName}
        </h1>
        <p class="mt-4 text-base leading-relaxed text-slate-600 sm:text-lg">
          {books.length} textbooks across {subjects.length} subjects. All free PDFs.
        </p>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
    <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">All subjects</h2>
    <p class="mt-2 text-sm text-slate-500">Click a subject to open the textbook.</p>

    <div class="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
      {books.map(b => {
        const subj = bookSubjectName(b.data.subject);
        return (
          <a href={url(`/textbook/${b.id}`)} class="group flex gap-4 rounded-2xl border border-slate-200 bg-white p-4 transition-colors hover:border-[#1d4ed8]">
            <!-- Mini cover -->
            <BookCover
              subject={subj}
              classNumber={String(b.data.class)}
              board={boardName}
              boardShort={meta.abbreviation}
              medium={b.data.medium}
              year={b.data.year}
              size="sm"
            />
            <!-- Meta -->
            <div class="min-w-0 flex-1 flex flex-col justify-between py-1">
              <div>
                <div class="text-[0.9375rem] font-extrabold tracking-tight text-slate-900 leading-tight">{subj}</div>
                <div class="mt-2 flex flex-wrap gap-1.5">
                  {b.data.scheme === 'new' && b.data.year && (
                    <span class="rounded bg-[#ecfdf5] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#047857]">New {b.data.year}</span>
                  )}
                  {b.data.scheme === 'snc' && b.data.year && (
                    <span class="rounded bg-[#fffbeb] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#b45309]">SNC {b.data.year}</span>
                  )}
                  {b.data.scheme === 'previous' && b.data.year && (
                    <span class="rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate-600">{b.data.year}</span>
                  )}
                  {!b.data.scheme && b.data.year && (
                    <span class="rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate-600">{b.data.year}</span>
                  )}
                  {b.data.medium === 'english' && <span class="rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate-600">EM</span>}
                  {b.data.medium === 'urdu' && <span class="rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate-600">UM</span>}
                  {b.data.medium === 'sindhi' && <span class="rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate-600">SM</span>}
                </div>
              </div>
              <div class="flex items-center gap-1 text-[11px] font-bold uppercase tracking-wider text-[#1d4ed8] opacity-0 transition-opacity group-hover:opacity-100">
                View book
                <Icon name="arrow-right" size={12} strokeWidth={2.6} />
              </div>
            </div>
          </a>
        );
      })}
    </div>
  </div>

  <!-- SEO copy -->
  <section class="border-t border-slate-200 bg-white">
    <div class="mx-auto max-w-[900px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
      <div class="prose">
        <h2>Class {cls} {boardName} textbooks</h2>
        <p>Class {cls} is a critical year in the {boardName} system. The {subjects.length} subjects listed above are the official textbooks published by the {meta.authority}. Every textbook is available as a free PDF download.</p>
        <h3>Subjects in Class {cls}</h3>
        <ul>
          {subjects.map(s => <li><strong>{s}</strong> — official {boardName} textbook</li>)}
        </ul>
        <h3>Mediums and editions</h3>
        <p>Where the board publishes both <strong>English medium (EM)</strong> and <strong>Urdu medium (UM)</strong> editions, both are shown. If a subject has been revised under the current Single National Curriculum (SNC), the newest edition is listed first with its year clearly tagged.</p>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO

echo "  ✓ Subject list updated"

# ═════════════════════════════════════════════════════════
#  5. Improved book detail — real cover + richer content
# ═════════════════════════════════════════════════════════
echo ""
echo "▸ 5. Rewriting book detail page..."

cat > 'src/pages/textbook/[...slug].astro' <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import BookCover from '../../components/BookCover.astro';
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
  .slice(0, 8);

// Look for related materials: notes, quizzes, past-papers, guess-papers for same subject+class
const [notes, quizzes, papers, guessPapers] = await Promise.all([
  getCollection('notes'),
  getCollection('quizzes'),
  getCollection('pastPapers'),
  getCollection('guessPapers'),
]);

const slugMatch = (s: string) => subjectSlug(bookSubjectName(s)) === subjSlug;
const classMatch = (c: string) => String(c) === String(d.class);

const relatedNotes = notes.filter((n: any) => slugMatch(n.data.subject) && classMatch(n.data.class)).slice(0, 4);
const relatedQuizzes = quizzes.filter((q: any) => slugMatch(q.data.subject) && classMatch(q.data.class)).slice(0, 4);
const relatedPapers = papers.filter((p: any) =>
  slugMatch(p.data.subject) && classMatch(p.data.class) &&
  (p.data.boards || []).some((b: string) => b === boardName)
).slice(0, 6);
const relatedGuess = guessPapers.filter((p: any) =>
  slugMatch(p.data.subject) && classMatch(p.data.class) &&
  (p.data.boards || []).some((b: string) => b === boardName)
).slice(0, 4);

const hasRelated = relatedNotes.length + relatedQuizzes.length + relatedPapers.length + relatedGuess.length > 0;

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
<BaseLayout
  title={bookSeoTitle(book)}
  description={bookSeoDescription(book)}
  jsonLd={jsonLd}
>
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-8 pb-12 sm:px-7 lg:px-10 lg:pt-10 lg:pb-16">
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

      <div class="grid gap-10 sm:grid-cols-[160px_1fr] lg:grid-cols-[200px_1fr] lg:gap-14">
        <!-- Book cover -->
        <div class="mx-auto sm:mx-0">
          <BookCover
            subject={subj}
            classNumber={String(d.class)}
            board={boardName}
            boardShort={meta.abbreviation}
            medium={d.medium}
            year={d.year}
            size="lg"
          />
        </div>

        <!-- Meta -->
        <div class="min-w-0">
          <div class="flex flex-wrap gap-1.5">
            <span class="badge-soft">{meta.abbreviation}</span>
            <span class="badge-soft">Class {d.class}</span>
            {d.medium === 'english' && <span class="badge-soft">English Medium</span>}
            {d.medium === 'urdu' && <span class="badge-soft">Urdu Medium</span>}
            {d.medium === 'sindhi' && <span class="badge-soft">Sindhi Medium</span>}
            {d.scheme === 'new' && d.year && <span class="badge-soft">New {d.year}</span>}
            {d.scheme === 'snc' && d.year && <span class="badge-soft">SNC {d.year}</span>}
          </div>

          <h1 class="mt-4 text-3xl font-extrabold leading-tight tracking-tight text-slate-900 sm:text-4xl lg:text-[2.75rem]">
            {subj} — Class {d.class}
          </h1>

          <p class="mt-4 max-w-2xl text-base leading-relaxed text-slate-600 sm:text-lg">
            Official {meta.abbreviation} textbook for Class {d.class} {subj}. {d.year ? `Published for the ${d.year} session.` : 'Current edition.'} Free PDF download.
          </p>

          <div class="mt-8 flex flex-wrap items-center gap-3">
            <a href={d.pdfUrl} target="_blank" rel="noopener"
               class="inline-flex items-center gap-2 rounded-lg bg-[#1d4ed8] px-6 py-3.5 text-sm font-bold text-white transition-colors hover:bg-[#1e3a8a]">
              <Icon name="download" size={17} strokeWidth={2.4} /> Download PDF
            </a>
            <a href={url(`/books/${boardSlug}/class-${d.class}`)}
               class="inline-flex items-center gap-2 rounded-lg border border-slate-300 bg-white px-6 py-3.5 text-sm font-bold text-slate-700 transition-colors hover:border-[#1d4ed8] hover:text-[#1d4ed8]">
              All Class {d.class} books
            </a>
          </div>

          <!-- Specs row -->
          <div class="mt-8 grid grid-cols-2 gap-3 sm:grid-cols-4">
            <div class="rounded-xl border border-slate-200 bg-white p-4">
              <div class="text-[10px] font-bold uppercase tracking-wider text-slate-400">Format</div>
              <div class="mt-1 text-sm font-extrabold text-slate-900">PDF</div>
            </div>
            <div class="rounded-xl border border-slate-200 bg-white p-4">
              <div class="text-[10px] font-bold uppercase tracking-wider text-slate-400">Board</div>
              <div class="mt-1 text-sm font-extrabold text-slate-900">{meta.abbreviation}</div>
            </div>
            <div class="rounded-xl border border-slate-200 bg-white p-4">
              <div class="text-[10px] font-bold uppercase tracking-wider text-slate-400">Edition</div>
              <div class="mt-1 text-sm font-extrabold text-slate-900">{d.year || 'Current'}</div>
            </div>
            <div class="rounded-xl border border-slate-200 bg-white p-4">
              <div class="text-[10px] font-bold uppercase tracking-wider text-slate-400">Medium</div>
              <div class="mt-1 text-sm font-extrabold text-slate-900">
                {d.medium === 'english' ? 'English' : d.medium === 'urdu' ? 'Urdu' : d.medium === 'sindhi' ? 'Sindhi' : '—'}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[900px] px-5 py-12 sm:px-7 lg:px-10 lg:py-16">
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
      <p>Start with the chapter summaries, work through the worked examples, then attempt the end-of-chapter exercises. Compare your answers against the model solutions in the {subj} notes section on Parhayi.</p>
    </article>
  </div>

  {hasRelated && (
    <div class="border-t border-slate-200 bg-slate-50">
      <div class="mx-auto max-w-[1100px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
        <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Related study material</h2>
        <p class="mt-2 text-sm text-slate-500">More free resources for {subj} Class {d.class} {boardName}.</p>

        {relatedNotes.length > 0 && (
          <section class="mt-8">
            <h3 class="text-[11px] font-bold uppercase tracking-[0.1em] text-slate-400">Notes</h3>
            <div class="mt-3 grid grid-cols-1 gap-2.5 sm:grid-cols-2">
              {relatedNotes.map((n: any) => (
                <a href={url(`/notes/${n.id}`)} class="group flex items-center gap-3 rounded-xl border border-slate-200 bg-white p-3.5 transition-colors hover:border-[#1d4ed8]">
                  <SubjectIcon subject={subj} size="sm" />
                  <div class="min-w-0 flex-1">
                    <div class="truncate text-[0.875rem] font-bold text-slate-900">{n.data.title}</div>
                  </div>
                  <Icon name="arrow-right" size={14} strokeWidth={2.4} class="shrink-0 text-slate-300 group-hover:text-[#1d4ed8]" />
                </a>
              ))}
            </div>
          </section>
        )}

        {relatedQuizzes.length > 0 && (
          <section class="mt-8">
            <h3 class="text-[11px] font-bold uppercase tracking-[0.1em] text-slate-400">Quizzes</h3>
            <div class="mt-3 grid grid-cols-1 gap-2.5 sm:grid-cols-2">
              {relatedQuizzes.map((q: any) => (
                <a href={url(`/quizzes/${q.id}`)} class="group flex items-center gap-3 rounded-xl border border-slate-200 bg-white p-3.5 transition-colors hover:border-[#1d4ed8]">
                  <span class="grid h-8 w-8 shrink-0 place-items-center rounded-lg bg-[#eff4ff] text-[#1d4ed8] text-[11px] font-extrabold">
                    {q.data.questions?.length || '?'}
                  </span>
                  <div class="min-w-0 flex-1">
                    <div class="truncate text-[0.875rem] font-bold text-slate-900">{q.data.title}</div>
                  </div>
                  <Icon name="arrow-right" size={14} strokeWidth={2.4} class="shrink-0 text-slate-300 group-hover:text-[#1d4ed8]" />
                </a>
              ))}
            </div>
          </section>
        )}

        {relatedPapers.length > 0 && (
          <section class="mt-8">
            <h3 class="text-[11px] font-bold uppercase tracking-[0.1em] text-slate-400">Past papers</h3>
            <div class="mt-3 grid grid-cols-1 gap-2.5 sm:grid-cols-2">
              {relatedPapers.map((p: any) => (
                <a href={url(`/past-papers/${p.id}`)} class="group flex items-center gap-3 rounded-xl border border-slate-200 bg-white p-3.5 transition-colors hover:border-[#1d4ed8]">
                  <span class="grid h-8 w-8 shrink-0 place-items-center rounded-lg bg-[#f5f3ff] text-[#6d28d9] text-[10px] font-extrabold">
                    {p.data.year}
                  </span>
                  <div class="min-w-0 flex-1">
                    <div class="truncate text-[0.875rem] font-bold text-slate-900">{p.data.subject}</div>
                    <div class="text-[11px] text-slate-500">{p.data.bise ? `BISE ${p.data.bise}` : p.data.boards?.[0]}</div>
                  </div>
                  <Icon name="arrow-right" size={14} strokeWidth={2.4} class="shrink-0 text-slate-300 group-hover:text-[#1d4ed8]" />
                </a>
              ))}
            </div>
          </section>
        )}
      </div>
    </div>
  )}

  {relatedBooks.length > 0 && (
    <div class="border-t border-slate-200 bg-white">
      <div class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
        <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Other Class {d.class} {boardName} textbooks</h2>
        <div class="mt-6 grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4">
          {relatedBooks.map((b: any) => (
            <a href={url(`/textbook/${b.id}`)} class="group flex flex-col gap-3 rounded-xl border border-slate-200 bg-white p-3 transition-colors hover:border-[#1d4ed8]">
              <BookCover
                subject={bookSubjectName(b.data.subject)}
                classNumber={String(b.data.class)}
                board={boardName}
                boardShort={meta.abbreviation}
                medium={b.data.medium}
                year={b.data.year}
                size="md"
                class="mx-auto"
              />
              <div class="text-center">
                <div class="text-[0.8125rem] font-bold text-slate-900 truncate">{bookSubjectName(b.data.subject)}</div>
                <div class="mt-0.5 text-[10px] font-bold uppercase tracking-wider text-slate-400">
                  {b.data.year || 'Current'}
                </div>
              </div>
            </a>
          ))}
        </div>
      </div>
    </div>
  )}

  <div class="mx-auto max-w-[1200px] px-5 pb-16 pt-8 sm:px-7 lg:px-10">
    <a href={url(`/books/${boardSlug}/class-${d.class}`)} class="inline-flex items-center gap-2 text-sm font-semibold text-slate-500 hover:text-[#1d4ed8]">
      <Icon name="arrow-left" size={16} strokeWidth={2.4} /> Back to Class {d.class} {boardName}
    </a>
  </div>
</BaseLayout>
ASTRO

echo "  ✓ Book detail updated"

# ═════════════════════════════════════════════════════════
#  6. Rebuild
# ═════════════════════════════════════════════════════════
echo ""
echo "Rebuilding..."
rm -rf dist .astro node_modules/.vite
npm run build 2>&1 | tail -10

echo ""
echo "════════════════════════════════════════════════════════"
echo "  DONE — Books v2"
echo ""
echo "  Preview:"
echo "    bash start-server.sh"
echo ""
echo "  Check these on mobile:"
echo "    /My-edu-site/books/"
echo "    /My-edu-site/books/punjab/"
echo "    /My-edu-site/books/punjab/class-9/"
echo "    /My-edu-site/textbook/9-pectaa-mathematics-e-2025_26"
echo ""
echo "  What changed:"
echo "    · Board cards now have province colors + abbreviated logo"
echo "    · Class cards show subject-icon previews + medium info"
echo "    · Subject cards show real book cover thumbnails"
echo "    · Book cover is a designed component (spine + icon + title)"
echo "    · Book detail has specs, related notes/quizzes/past-papers"
echo "    · Strong internal linking between books/notes/quizzes/papers"
echo ""
echo "  Push when happy:"
echo "    git add ."
echo "    git commit -m 'Books v2: richer pages, real cover, related materials'"
echo "    git push"
echo ""
echo "  Revert:"
echo "    git checkout backup-pre-books-v2"
echo "════════════════════════════════════════════════════════"