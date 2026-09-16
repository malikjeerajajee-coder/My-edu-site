#!/bin/bash
set -e

echo "Building class & subject taxonomy..."

mkdir -p src/lib src/pages/classes src/pages/subjects

# ============ TAXONOMY UTILITY ============
cat > src/lib/taxonomy.ts <<'EOF'
import { getCollection } from 'astro:content';

export function slugify(s: string) {
  return s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

export async function getTaxonomy() {
  const [notes, quizzes, books, gazettes] = await Promise.all([
    getCollection('notes'),
    getCollection('quizzes'),
    getCollection('books'),
    getCollection('gazettes'),
  ]);

  const classMap = new Map<string, { notes: any[]; quizzes: any[]; books: any[]; gazettes: any[]; subjects: Set<string> }>();
  const subjectMap = new Map<string, { notes: any[]; quizzes: any[]; books: any[]; classes: Set<string> }>();

  const ensureClass = (cls: string) => {
    if (!classMap.has(cls)) classMap.set(cls, { notes: [], quizzes: [], books: [], gazettes: [], subjects: new Set() });
    return classMap.get(cls)!;
  };
  const ensureSubject = (subj: string) => {
    if (!subjectMap.has(subj)) subjectMap.set(subj, { notes: [], quizzes: [], books: [], classes: new Set() });
    return subjectMap.get(subj)!;
  };

  notes.forEach(n => {
    ensureClass(n.data.class).notes.push(n);
    ensureClass(n.data.class).subjects.add(n.data.subject);
    ensureSubject(n.data.subject).notes.push(n);
    ensureSubject(n.data.subject).classes.add(n.data.class);
  });
  quizzes.forEach(q => {
    ensureClass(q.data.class).quizzes.push(q);
    ensureClass(q.data.class).subjects.add(q.data.subject);
    ensureSubject(q.data.subject).quizzes.push(q);
    ensureSubject(q.data.subject).classes.add(q.data.class);
  });
  books.forEach(b => {
    ensureClass(b.data.class).books.push(b);
    ensureClass(b.data.class).subjects.add(b.data.subject);
    ensureSubject(b.data.subject).books.push(b);
    ensureSubject(b.data.subject).classes.add(b.data.class);
  });
  gazettes.forEach(g => {
    ensureClass(g.data.class).gazettes.push(g);
  });

  const classes = [...classMap.entries()]
    .map(([cls, v]) => ({
      class: cls,
      notes: v.notes, quizzes: v.quizzes, books: v.books, gazettes: v.gazettes,
      subjects: [...v.subjects].sort(),
      total: v.notes.length + v.quizzes.length + v.books.length + v.gazettes.length,
    }))
    .sort((a, b) => Number(a.class) - Number(b.class));

  const subjects = [...subjectMap.entries()]
    .map(([subject, v]) => ({
      subject,
      notes: v.notes, quizzes: v.quizzes, books: v.books,
      classes: [...v.classes].sort((a, b) => Number(a) - Number(b)),
      total: v.notes.length + v.quizzes.length + v.books.length,
    }))
    .sort((a, b) => a.subject.localeCompare(b.subject));

  return { classes, subjects };
}
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

    <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
      {classes.map((c, i) => {
        const tint = tints[i % tints.length];
        return (
          <a
            href={`/classes/${c.class}`}
            class="group relative overflow-hidden rounded-2xl border border-slate-200 bg-white p-6 transition-colors hover:border-emerald-300"
          >
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
              <Icon
                name="arrow-up-right"
                size={18}
                strokeWidth={2.4}
                class="text-slate-300 transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-emerald-600"
              />
            </div>
            <h3 class="mt-5 font-display text-2xl font-extrabold tracking-tight text-slate-900">Class {c.class}</h3>
            <p class="mt-1 text-sm text-slate-500">
              {c.subjects.length} {c.subjects.length === 1 ? 'subject' : 'subjects'} · {c.total} {c.total === 1 ? 'item' : 'items'}
            </p>
            <div class="mt-4 flex flex-wrap gap-1.5">
              {c.notes.length > 0 && <span class="rounded-md bg-emerald-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-emerald-700">{c.notes.length} notes</span>}
              {c.quizzes.length > 0 && <span class="rounded-md bg-blue-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-blue-700">{c.quizzes.length} quizzes</span>}
              {c.books.length > 0 && <span class="rounded-md bg-amber-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-amber-700">{c.books.length} books</span>}
            </div>
          </a>
        );
      })}
    </div>
  </div>
</BaseLayout>
EOF

# ============ CLASS DETAIL ============
cat > src/pages/classes/[class].astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { getTaxonomy } from '../../lib/taxonomy';

export async function getStaticPaths() {
  const { classes } = await getTaxonomy();
  return classes.map(c => ({ params: { class: c.class } }));
}

const { class: cls } = Astro.params;
const { classes } = await getTaxonomy();
const data = classes.find(c => c.class === cls);
if (!data) return Astro.redirect('/classes');

const sections = [
  { key: 'notes',    label: 'Notes',      icon: 'file-text',     base: '/notes',    tint: 'emerald', items: data.notes },
  { key: 'quizzes',  label: 'Quizzes',    icon: 'file-question', base: '/quizzes',  tint: 'blue',    items: data.quizzes },
  { key: 'books',    label: 'Textbooks',  icon: 'book-marked',   base: '/books',    tint: 'amber',   items: data.books },
  { key: 'gazettes', label: 'Gazettes',   icon: 'scroll-text',   base: '/gazettes', tint: 'rose',    items: data.gazettes },
].filter(s => s.items.length > 0);
---
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
      <p class="mt-2 text-emerald-100">
        {data.subjects.length} {data.subjects.length === 1 ? 'subject' : 'subjects'} · {data.total} {data.total === 1 ? 'item' : 'items'}
      </p>
      {data.subjects.length > 0 && (
        <div class="mt-5 flex flex-wrap gap-1.5">
          {data.subjects.map(s => (
            <a href={`/subjects/${s.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/^-|-$/g,'')}`}
               class="rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wide backdrop-blur-sm transition-colors hover:bg-white/20">
              {s}
            </a>
          ))}
        </div>
      )}
    </div>

    {sections.map(sec => (
      <section class="mt-12">
        <div class="mb-5 flex items-end justify-between gap-4">
          <div class="flex items-center gap-3">
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
          <a href={sec.base} class="hidden items-center gap-1 text-sm font-semibold text-emerald-700 hover:text-emerald-800 sm:inline-flex">
            View all <Icon name="arrow-right" size={14} strokeWidth={2.6} />
          </a>
        </div>

        <div class="grid gap-3 md:grid-cols-2">
          {sec.items.map((item: any) => {
            const isGazette = sec.key === 'gazettes';
            const isBook = sec.key === 'books';
            const subjectLine = isGazette ? item.data.board : item.data.subject;
            return (
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
                  <div class="mt-1.5 flex flex-wrap gap-1.5">
                    {subjectLine && <span class="rounded-md bg-slate-100 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-slate-600">{subjectLine}</span>}
                    {isBook && item.data.author && <span class="rounded-md bg-slate-100 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-slate-600">{item.data.author}</span>}
                    {isGazette && <span class="rounded-md bg-slate-100 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-slate-600">{item.data.year}</span>}
                  </div>
                </div>
                <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-transform group-hover:translate-x-0.5 group-hover:text-emerald-600" />
              </a>
            );
          })}
        </div>
      </section>
    ))}
  </div>
</BaseLayout>
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

    <div class="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
      {subjects.map(s => (
        <a href={`/subjects/${slugify(s.subject)}`} class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-5 transition-colors hover:border-emerald-300">
          <span class="grid h-12 w-12 shrink-0 place-items-center rounded-xl bg-emerald-100 text-emerald-700">
            <Icon name="library" size={22} strokeWidth={2.2} />
          </span>
          <div class="min-w-0 flex-1">
            <h3 class="font-display text-base font-extrabold tracking-tight text-slate-900">{s.subject}</h3>
            <p class="mt-0.5 text-xs font-semibold text-slate-500">
              {s.total} {s.total === 1 ? 'item' : 'items'} · Class {s.classes.join(', ')}
            </p>
          </div>
          <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-transform group-hover:translate-x-0.5 group-hover:text-emerald-600" />
        </a>
      ))}
    </div>
  </div>
</BaseLayout>
EOF

# ============ SUBJECT DETAIL ============
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
if (!data) return Astro.redirect('/subjects');

const sections = [
  { key: 'notes',   label: 'Notes',     icon: 'file-text',     base: '/notes',   items: data.notes },
  { key: 'quizzes', label: 'Quizzes',   icon: 'file-question', base: '/quizzes', items: data.quizzes },
  { key: 'books',   label: 'Textbooks', icon: 'book-marked',   base: '/books',   items: data.books },
].filter(s => s.items.length > 0);
---
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
          <a href={`/classes/${c}`}
             class="rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wide backdrop-blur-sm transition-colors hover:bg-white/20">
            Class {c}
          </a>
        ))}
      </div>
    </div>

    {sections.map(sec => (
      <section class="mt-12">
        <div class="mb-5 flex items-end justify-between gap-4">
          <div>
            <h2 class="font-display text-xl font-extrabold tracking-tight text-slate-900">{data.subject} {sec.label}</h2>
            <p class="text-sm text-slate-500">{sec.items.length} {sec.items.length === 1 ? 'item' : 'items'}</p>
          </div>
          <a href={sec.base} class="hidden items-center gap-1 text-sm font-semibold text-emerald-700 hover:text-emerald-800 sm:inline-flex">
            View all <Icon name="arrow-right" size={14} strokeWidth={2.6} />
          </a>
        </div>

        <div class="grid gap-3 md:grid-cols-2">
          {sec.items.map((item: any) => (
            <a href={`${sec.base}/${item.id}`} class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-4 transition-colors hover:border-emerald-300">
              <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-emerald-100 text-emerald-700">
                <Icon name={sec.icon} size={18} strokeWidth={2.2} />
              </span>
              <div class="min-w-0 flex-1">
                <h3 class="truncate text-[0.925rem] font-bold tracking-tight text-slate-900">{item.data.title}</h3>
                <div class="mt-1.5 flex flex-wrap gap-1.5">
                  <span class="rounded-md bg-emerald-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-emerald-700">Class {item.data.class}</span>
                  {item.data.board && <span class="rounded-md bg-slate-100 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-slate-600">{item.data.board}</span>}
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
EOF

# ============ LAYOUT: add Classes + Subjects to nav ============
python3 - <<'PY'
import re, pathlib
p = pathlib.Path("src/layouts/BaseLayout.astro")
s = p.read_text()

old_nav = re.search(r'const navItems = \[.*?\];', s, re.DOTALL)
new_nav = '''const desktopNav = [
  { href: '/',         label: 'Home',     icon: 'home' },
  { href: '/classes',  label: 'Classes',  icon: 'graduation-cap' },
  { href: '/subjects', label: 'Subjects', icon: 'library' },
  { href: '/notes',    label: 'Notes',    icon: 'book-open' },
  { href: '/quizzes',  label: 'Quizzes',  icon: 'circle-help' },
  { href: '/books',    label: 'Books',    icon: 'book-marked' },
  { href: '/gazettes', label: 'Gazettes', icon: 'newspaper' },
];
const mobileNav = [
  { href: '/',         label: 'Home',     icon: 'home' },
  { href: '/classes',  label: 'Classes',  icon: 'graduation-cap' },
  { href: '/notes',    label: 'Notes',    icon: 'book-open' },
  { href: '/quizzes',  label: 'Quizzes',  icon: 'circle-help' },
  { href: '/books',    label: 'Books',    icon: 'library' },
];'''
if old_nav: s = s[:old_nav.start()] + new_nav + s[old_nav.end():]

# Replace desktop nav iteration
s = re.sub(
  r'\{navItems\.map\(item => \(\s*<a\s*href=\{item\.href\}\s*class:list=\{\[[^]]*\]\}\s*>\s*\{item\.label\}\s*</a>\s*\)\)\}',
  '{desktopNav.map(item => (\n          <a\n            href={item.href}\n            class:list={[\n              "rounded-lg px-3 py-2 text-sm font-semibold transition-colors",\n              isActive(item.href)\n                ? "bg-emerald-50 text-emerald-700"\n                : "text-slate-600 hover:bg-slate-100 hover:text-slate-900",\n            ]}\n          >\n            {item.label}\n          </a>\n        ))}',
  s, count=1, flags=re.DOTALL
)

# Replace bottom nav iteration
s = re.sub(
  r'\{navItems\.map\(item => \(\s*<a\s*href=\{item\.href\}[\s\S]*?</a>\s*\)\)\}',
  '{mobileNav.map(item => (\n        <a\n          href={item.href}\n          class:list={[\n            "flex min-w-0 flex-1 flex-col items-center gap-1.5 px-1 pt-2.5 pb-1 text-[11px] font-semibold leading-none transition-colors",\n            isActive(item.href) ? "text-emerald-600" : "text-slate-400",\n          ]}\n        >\n          <Icon name={item.icon} size={20} strokeWidth={2.2} />\n          <span>{item.label}</span>\n        </a>\n      ))}',
  s, count=1, flags=re.DOTALL
)

p.write_text(s)
print("BaseLayout patched.")
PY

# ============ HOME: add Classes + Subjects sections ============
python3 - <<'PY'
import re, pathlib
p = pathlib.Path("src/pages/index.astro")
s = p.read_text()

# Add taxonomy import
s = s.replace(
  "import { getCollection } from 'astro:content';",
  "import { getCollection } from 'astro:content';\nimport { getTaxonomy, slugify } from '../lib/taxonomy';"
)

# Add taxonomy fetch
s = s.replace(
  "const gazettes = await getCollection('gazettes');",
  "const gazettes = await getCollection('gazettes');\nconst { classes, subjects } = await getTaxonomy();"
)

# Insert Classes + Subjects sections right before the RECENT NOTES section
classes_subjects = '''
  <!-- BROWSE BY CLASS -->
  <section class="mx-auto w-full max-w-7xl px-4 pb-4 pt-4 sm:px-6 lg:px-8">
    <div class="mb-6 flex items-end justify-between gap-4">
      <div>
        <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Browse by class</h2>
        <p class="mt-1.5 text-sm text-slate-500">Everything for your class in one place.</p>
      </div>
      <a href="/classes" class="hidden items-center gap-1 text-sm font-semibold text-emerald-700 hover:text-emerald-800 sm:inline-flex">
        All classes <Icon name="arrow-right" size={14} strokeWidth={2.6} />
      </a>
    </div>
    <div class="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
      {classes.map(c => (
        <a href={`/classes/${c.class}`} class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-5 transition-colors hover:border-emerald-300">
          <span class="grid h-12 w-12 shrink-0 place-items-center rounded-xl bg-emerald-100 text-emerald-700">
            <Icon name="graduation-cap" size={22} strokeWidth={2.2} />
          </span>
          <div class="min-w-0">
            <div class="font-display text-lg font-extrabold tracking-tight text-slate-900">Class {c.class}</div>
            <div class="text-xs font-semibold text-slate-500">{c.total} {c.total === 1 ? 'item' : 'items'}</div>
          </div>
        </a>
      ))}
    </div>
  </section>

  <!-- BROWSE BY SUBJECT -->
  <section class="mx-auto w-full max-w-7xl px-4 pb-4 pt-8 sm:px-6 lg:px-8">
    <div class="mb-6 flex items-end justify-between gap-4">
      <div>
        <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900 sm:text-3xl">Browse by subject</h2>
        <p class="mt-1.5 text-sm text-slate-500">Pick your subject, then your class.</p>
      </div>
      <a href="/subjects" class="hidden items-center gap-1 text-sm font-semibold text-emerald-700 hover:text-emerald-800 sm:inline-flex">
        All subjects <Icon name="arrow-right" size={14} strokeWidth={2.6} />
      </a>
    </div>
    <div class="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
      {subjects.map(s => (
        <a href={`/subjects/${slugify(s.subject)}`} class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-5 transition-colors hover:border-emerald-300">
          <span class="grid h-11 w-11 shrink-0 place-items-center rounded-xl bg-emerald-100 text-emerald-700">
            <Icon name="library" size={20} strokeWidth={2.2} />
          </span>
          <div class="min-w-0 flex-1">
            <div class="font-display text-base font-extrabold tracking-tight text-slate-900">{s.subject}</div>
            <div class="text-xs font-semibold text-slate-500">{s.total} {s.total === 1 ? 'item' : 'items'}</div>
          </div>
          <Icon name="chevron-right" size={16} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-transform group-hover:translate-x-0.5 group-hover:text-emerald-600" />
        </a>
      ))}
    </div>
  </section>
'''

marker = '  <!-- RECENT -->'
if marker in s:
    s = s.replace(marker, classes_subjects + '\n' + marker)
else:
    # Fallback: insert before closing </BaseLayout>
    s = s.replace('</BaseLayout>', classes_subjects + '\n</BaseLayout>')

p.write_text(s)
print("Home page patched.")
PY

# ============ Clear caches ============
rm -rf .astro node_modules/.vite

echo ""
echo "==================================================="
echo "  Taxonomy build complete"
echo "==================================================="
echo ""
echo "  New routes:"
echo "    /classes            - all classes hub"
echo "    /classes/9,10,11,12 - content for each class"
echo "    /subjects           - all subjects hub"
echo "    /subjects/[slug]    - content for each subject"
echo ""
echo "  Nav updated:"
echo "    Desktop: Home | Classes | Subjects | Notes | Quizzes | Books | Gazettes"
echo "    Mobile:  Home | Classes | Notes | Quizzes | Books"
echo ""
echo "  Home page:"
echo "    - Hero + stat cards"
echo "    - Browse by class (4 cards)"
echo "    - Browse by subject (grid)"
echo "    - Browse library"
echo "    - Recent notes"
echo ""
echo "Next: stop dev server, run  npm run dev"