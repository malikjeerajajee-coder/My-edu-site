#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "════════════════════════════════════════════"
echo "  Notes section — full build"
echo "════════════════════════════════════════════"
echo ""

git branch -f backup-pre-notes-v2 2>/dev/null || true
echo "  ✓ backup-pre-notes-v2 created"
echo ""

# ═════════════════════════════════════════════════════════
#  1. Update schema — add optional chapter fields
# ═════════════════════════════════════════════════════════
echo "▸ 1. Updating notes schema..."

python3 <<'PY'
import pathlib, re
p = pathlib.Path('src/content.config.ts')
s = p.read_text()

old = """const notes = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/notes' }),
  schema: z.object({
    title: z.string(),
    subject: z.string(),
    class: z.string(),
    board: z.string().optional(),
    boards: z.array(z.string()).optional(),
    pdfUrl: z.string().optional(),
    date: z.date().optional(),
  }),
});"""

new = """const notes = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/notes' }),
  schema: z.object({
    title: z.string(),
    subject: z.string(),
    class: z.string(),
    chapter: z.string().optional(),
    chapterNumber: z.number().optional(),
    board: z.string().optional(),
    boards: z.array(z.string()).optional(),
    pdfUrl: z.string().optional(),
    date: z.date().optional(),
  }),
});"""

if old in s:
    s = s.replace(old, new)
    p.write_text(s)
    print('  ✓ notes schema updated')
else:
    if 'chapterNumber' not in s.split('const quizzes')[0]:
        # Fallback — add fields after class
        s = re.sub(
            r"(const notes = defineCollection\(\{[\s\S]*?class: z\.string\(\),)",
            r"\1\n    chapter: z.string().optional(),\n    chapterNumber: z.number().optional(),",
            s, count=1
        )
        p.write_text(s)
        print('  ✓ notes schema updated (fallback)')
    else:
        print('  · notes schema already has chapter fields')
PY

# ═════════════════════════════════════════════════════════
#  2. Migrate existing notes to add chapter metadata
# ═════════════════════════════════════════════════════════
echo ""
echo "▸ 2. Migrating existing notes..."

python3 <<'PY'
import pathlib, re

NDIR = pathlib.Path('src/content/notes')

migrations = {
    'math-10-ch1.md':      ('Quadratic Equations', 1),
    'physics-9-ch1.md':    ('Physical Quantities & Measurement', 1),
    'chemistry-10-ch1.md': ('Chemical Equilibrium', 1),
    'biology-11-ch1.md':   ('Cell Biology', 1),
    # english-9-essays.md has no chapter (topic-based) — leave as is
}

for fname, (chapter, num) in migrations.items():
    p = NDIR / fname
    if not p.exists():
        print(f'  · {fname} not found — skipping')
        continue
    s = p.read_text()
    fm_end = s.find('---', 3)
    fm = s[:fm_end]
    if 'chapter:' in fm:
        print(f'  · {fname} already has chapter')
        continue
    s = re.sub(
        r'^(class:\s*[^\n]+)\n',
        r'\1\nchapter: "' + chapter + '"\nchapterNumber: ' + str(num) + '\n',
        s, count=1, flags=re.MULTILINE
    )
    p.write_text(s)
    print(f'  ✓ {fname}')
PY

# ═════════════════════════════════════════════════════════
#  3. Notes metadata helper
# ═════════════════════════════════════════════════════════
cat > src/lib/noteMeta.ts <<'TS'
import type { CollectionEntry } from 'astro:content';

export function noteSubjectName(subject: string): string {
  return subject.replace(/\s*\([^)]*\)\s*/g, '').trim();
}

export function subjectSlug(subject: string): string {
  return subject
    .toLowerCase()
    .replace(/\(.*?\)/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
}

// Estimated reading time — ~200 words/min. Notes are markdown, so we estimate.
export function estimatedReadMinutes(n: CollectionEntry<'notes'>): number {
  const body = (n as any).body || '';
  const words = body.split(/\s+/).filter(Boolean).length;
  return Math.max(1, Math.round(words / 200));
}

// Is this note chapter-based or topic-based?
export function isChaptered(n: CollectionEntry<'notes'>): boolean {
  return typeof n.data.chapterNumber === 'number' && !!n.data.chapter;
}
TS
echo "  ✓ noteMeta.ts"

# ═════════════════════════════════════════════════════════
#  4. Clean old routes, prep new tree
# ═════════════════════════════════════════════════════════
rm -rf src/pages/notes
rm -rf src/pages/note
mkdir -p 'src/pages/notes/[class]'
mkdir -p src/pages/note
echo "  ✓ Cleaned"

# ═════════════════════════════════════════════════════════
#  5. /notes — class hub
# ═════════════════════════════════════════════════════════
cat > src/pages/notes/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { getCollection } from 'astro:content';
import { noteSubjectName } from '../../lib/noteMeta';

const notes = await getCollection('notes');

const byClass = new Map<string, { count: number; subjects: Set<string> }>();
notes.forEach((n: any) => {
  const c = String(n.data.class);
  if (!byClass.has(c)) byClass.set(c, { count: 0, subjects: new Set() });
  const entry = byClass.get(c)!;
  entry.count++;
  entry.subjects.add(noteSubjectName(n.data.subject));
});
const classes = [...byClass.entries()]
  .map(([cls, v]) => ({ cls, count: v.count, subjects: v.subjects.size }))
  .sort((a, b) => Number(a.cls) - Number(b.cls));

const totalSubjects = new Set(notes.map((n: any) => noteSubjectName(n.data.subject))).size;

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  name: 'Study Notes for Pakistani Students',
  description: `Subject-wise chapter notes for Class 9 to 12. ${notes.length} notes across ${totalSubjects} subjects.`,
};
---
<BaseLayout
  title="Study Notes — Class 9 to 12 Chapter Notes | Parhayi"
  description={`Free chapter-wise study notes for Pakistani board students. ${notes.length} notes across ${totalSubjects} subjects, all boards.`}
  jsonLd={jsonLd}
>
  <section class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-12 pb-14 sm:px-7 lg:px-10 lg:pt-16 lg:pb-20">
      <nav class="mb-8 flex items-center gap-2 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">Notes</span>
      </nav>
      <h1 class="max-w-3xl font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl lg:text-6xl">
        Chapter notes, written for your board.
      </h1>
      <p class="mt-6 max-w-2xl text-base leading-relaxed text-slate-600 sm:text-lg">
        Clear, focused chapter notes for Pakistani board students — organised by class and subject.
      </p>
      <dl class="mt-10 flex flex-wrap gap-x-12 gap-y-4">
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Notes</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{notes.length}</dd>
        </div>
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Classes</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{classes.length}</dd>
        </div>
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Subjects</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{totalSubjects}</dd>
        </div>
      </dl>
    </div>
  </section>

  <section class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
    <div class="mb-8">
      <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Choose your class</h2>
      <p class="mt-1.5 text-sm text-slate-500">Every class has notes for each subject.</p>
    </div>

    {classes.length === 0 ? (
      <div class="rounded-2xl border border-dashed border-slate-300 bg-white p-12 text-center">
        <p class="text-sm font-bold text-slate-900">Notes coming soon</p>
        <p class="mt-1 text-xs text-slate-500">We're writing notes for every subject and chapter.</p>
      </div>
    ) : (
      <div class="grid grid-cols-2 gap-px overflow-hidden rounded-2xl border border-slate-200 bg-slate-200 sm:grid-cols-3 lg:grid-cols-4">
        {classes.map(c => (
          <a href={url(`/notes/class-${c.cls}`)} class="group relative flex flex-col bg-white p-6 transition-colors hover:bg-slate-50">
            <span class="font-display text-4xl font-extrabold leading-none tracking-tight tabular-nums text-slate-900">
              {c.cls.padStart(2, '0')}
            </span>
            <div class="mt-6 text-[13px] font-bold text-slate-900">Class {c.cls}</div>
            <div class="mt-0.5 text-[12px] text-slate-500">
              {c.count} {c.count === 1 ? 'note' : 'notes'} · {c.subjects} {c.subjects === 1 ? 'subject' : 'subjects'}
            </div>
            <div class="mt-4 flex items-center gap-1 text-[11px] font-bold uppercase tracking-[0.08em] text-slate-400 transition-colors group-hover:text-[#1d4ed8]">
              Open
              <Icon name="arrow-right" size={11} strokeWidth={2.6} />
            </div>
          </a>
        ))}
      </div>
    )}
  </section>

  <section class="border-t border-slate-200 bg-white">
    <div class="mx-auto max-w-[820px] px-5 py-16 sm:px-7 lg:px-10">
      <div class="prose">
        <h2>Notes that actually help</h2>
        <p>Not every note is useful. A wall of text copy-pasted from a textbook doesn't teach you anything. What works is a short, clear summary of each chapter's key ideas — the definitions, the formulas, the concepts that exams actually test.</p>
        <p>Every note on Parhayi is written for one specific chapter, in one specific subject, for one specific class. That's how the board exams are structured, and that's how you should revise.</p>
        <h3>How to use these notes</h3>
        <ul>
          <li><strong>Before class</strong> — skim the chapter's note to know what you're about to learn</li>
          <li><strong>After class</strong> — read the note properly to lock in the concepts</li>
          <li><strong>Before exams</strong> — use the notes as a quick-revision checklist for every chapter</li>
        </ul>
        <h3>What each note includes</h3>
        <ul>
          <li>The key definitions and concepts from the chapter</li>
          <li>Important formulas and their derivations</li>
          <li>Worked examples of the most common question types</li>
          <li>Common mistakes students make (and how to avoid them)</li>
        </ul>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ /notes"

# ═════════════════════════════════════════════════════════
#  6. /notes/[class] — subject list
# ═════════════════════════════════════════════════════════
cat > 'src/pages/notes/[class]/index.astro' <<'ASTRO'
---
import BaseLayout from '../../../layouts/BaseLayout.astro';
import Icon from '../../../components/Icon.astro';
import SubjectIcon from '../../../components/SubjectIcon.astro';
import { url } from '../../../lib/url';
import { getCollection } from 'astro:content';
import { noteSubjectName, subjectSlug, isChaptered } from '../../../lib/noteMeta';

export async function getStaticPaths() {
  const notes = await getCollection('notes');
  const classes = new Set(notes.map((n: any) => String(n.data.class)));
  return [...classes].map(c => ({ params: { class: `class-${c}` } }));
}

const { class: classParam } = Astro.params;
const cls = String(classParam).replace(/^class-/, '');
const allNotes = await getCollection('notes');
const notes = allNotes.filter((n: any) => String(n.data.class) === cls);

const bySubject = new Map<string, { count: number; chaptered: number; topics: number }>();
notes.forEach((n: any) => {
  const subj = noteSubjectName(n.data.subject);
  if (!bySubject.has(subj)) bySubject.set(subj, { count: 0, chaptered: 0, topics: 0 });
  const s = bySubject.get(subj)!;
  s.count++;
  if (isChaptered(n)) s.chaptered++;
  else s.topics++;
});
const subjects = [...bySubject.entries()]
  .map(([name, v]) => ({ name, slug: subjectSlug(name), count: v.count, chaptered: v.chaptered, topics: v.topics }))
  .sort((a, b) => a.name.localeCompare(b.name));

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  name: `Class ${cls} Notes`,
  description: `Free chapter-wise notes for Class ${cls}. ${notes.length} notes across ${subjects.length} subjects.`,
};
---
<BaseLayout
  title={`Class ${cls} Notes — Chapter-wise Study Material | Parhayi`}
  description={`Free study notes for Class ${cls}. ${notes.length} notes across ${subjects.length} subjects — all boards, all chapters.`}
  jsonLd={jsonLd}
>
  <section class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-14 sm:px-7 lg:px-10 lg:pt-12 lg:pb-16">
      <nav class="mb-8 flex items-center gap-2 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <a href={url('/notes')} class="hover:text-[#1d4ed8]">Notes</a>
        <span>/</span>
        <span class="text-slate-500">Class {cls}</span>
      </nav>
      <h1 class="font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl">
        Class {cls} Notes
      </h1>
      <p class="mt-5 max-w-2xl text-base leading-relaxed text-slate-600">
        Chapter-wise notes for every Class {cls} subject. {notes.length} notes across {subjects.length} subjects.
      </p>
    </div>
  </section>

  <section class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
    <div class="mb-8">
      <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Choose a subject</h2>
      <p class="mt-1.5 text-sm text-slate-500">Every subject has its own chapter-wise notes.</p>
    </div>

    {subjects.length === 0 ? (
      <div class="rounded-2xl border border-dashed border-slate-300 bg-white p-12 text-center">
        <p class="text-sm font-bold text-slate-900">No notes yet for Class {cls}</p>
        <a href={url('/notes')} class="mt-4 inline-block text-sm font-semibold text-[#1d4ed8]">Back to all classes</a>
      </div>
    ) : (
      <div class="grid grid-cols-1 gap-px overflow-hidden rounded-2xl border border-slate-200 bg-slate-200 sm:grid-cols-2 lg:grid-cols-3">
        {subjects.map(s => (
          <a href={url(`/notes/class-${cls}/${s.slug}`)} class="group relative flex flex-col bg-white p-6 transition-colors hover:bg-slate-50">
            <div class="flex items-start gap-3">
              <SubjectIcon subject={s.name} size="sm" />
              <div class="min-w-0 flex-1">
                <h3 class="font-display text-[17px] font-extrabold leading-tight tracking-tight text-slate-900">{s.name}</h3>
                <p class="mt-1 text-[12px] text-slate-500">
                  {s.chaptered > 0 && <>{s.chaptered} {s.chaptered === 1 ? 'chapter' : 'chapters'}</>}
                  {s.chaptered > 0 && s.topics > 0 && <> · </>}
                  {s.topics > 0 && <>{s.topics} {s.topics === 1 ? 'topic' : 'topics'}</>}
                </p>
              </div>
            </div>
            <div class="mt-6 flex items-center gap-1 text-[11px] font-bold uppercase tracking-[0.08em] text-slate-400 transition-colors group-hover:text-[#1d4ed8]">
              Read
              <Icon name="arrow-right" size={11} strokeWidth={2.6} />
            </div>
          </a>
        ))}
      </div>
    )}
  </section>

  <section class="border-t border-slate-200 bg-white">
    <div class="mx-auto max-w-[820px] px-5 py-16 sm:px-7 lg:px-10">
      <div class="prose">
        <h2>Class {cls} notes</h2>
        <p>Every Class {cls} subject is organised into chapters by the board. Our notes follow the same structure — one note per chapter, covering the definitions, formulas, and examples that matter most.</p>
        <p>Pick a subject above to see its chapters.</p>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ /notes/[class]"

# ═════════════════════════════════════════════════════════
#  7. /notes/[class]/[subject] — notes grouped by chapter
# ═════════════════════════════════════════════════════════
cat > 'src/pages/notes/[class]/[subject].astro' <<'ASTRO'
---
import BaseLayout from '../../../layouts/BaseLayout.astro';
import Icon from '../../../components/Icon.astro';
import SubjectIcon from '../../../components/SubjectIcon.astro';
import { url } from '../../../lib/url';
import { getCollection } from 'astro:content';
import { noteSubjectName, subjectSlug, isChaptered, estimatedReadMinutes } from '../../../lib/noteMeta';

export async function getStaticPaths() {
  const notes = await getCollection('notes');
  const paths: any[] = [];
  const seen = new Set<string>();
  notes.forEach((n: any) => {
    const cls = String(n.data.class);
    const subj = subjectSlug(noteSubjectName(n.data.subject));
    const key = `${cls}/${subj}`;
    if (!seen.has(key)) {
      seen.add(key);
      paths.push({ params: { class: `class-${cls}`, subject: subj } });
    }
  });
  return paths;
}

const { class: classParam, subject: subjectParam } = Astro.params;
const cls = String(classParam).replace(/^class-/, '');
const allNotes = await getCollection('notes');

const notes = allNotes.filter((n: any) =>
  String(n.data.class) === cls && subjectSlug(noteSubjectName(n.data.subject)) === subjectParam
);

if (!notes.length) return Astro.redirect(`/notes/class-${cls}`);

const subjectName = noteSubjectName(notes[0].data.subject);

// Split into chaptered vs topic-based
const chaptered = notes.filter(isChaptered).sort((a: any, b: any) =>
  (a.data.chapterNumber || 0) - (b.data.chapterNumber || 0)
);
const topicBased = notes.filter((n: any) => !isChaptered(n));

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  name: `Class ${cls} ${subjectName} Notes`,
  description: `${notes.length} study notes for Class ${cls} ${subjectName}. Chapter-wise and topic-based. Free.`,
};
---
<BaseLayout
  title={`Class ${cls} ${subjectName} Notes — Chapter-wise | Parhayi`}
  description={`Free ${subjectName} notes for Class ${cls}. ${notes.length} notes — chapter-wise and topic-based study material.`}
  jsonLd={jsonLd}
>
  <section class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-14 sm:px-7 lg:px-10 lg:pt-12 lg:pb-16">
      <nav class="mb-8 flex flex-wrap items-center gap-2 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <a href={url('/notes')} class="hover:text-[#1d4ed8]">Notes</a>
        <span>/</span>
        <a href={url(`/notes/class-${cls}`)} class="hover:text-[#1d4ed8]">Class {cls}</a>
        <span>/</span>
        <span class="text-slate-500">{subjectName}</span>
      </nav>
      <div class="flex items-start gap-4">
        <SubjectIcon subject={subjectName} size="md" />
        <div>
          <h1 class="font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl">
            {subjectName} Notes
          </h1>
          <p class="mt-2 text-sm text-slate-500">
            Class {cls} · {notes.length} {notes.length === 1 ? 'note' : 'notes'}
            {chaptered.length > 0 && <> · {chaptered.length} {chaptered.length === 1 ? 'chapter' : 'chapters'}</>}
          </p>
        </div>
      </div>
    </div>
  </section>

  <section class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
    {chaptered.length > 0 && (
      <div class="mb-12">
        <div class="mb-8">
          <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Chapter-wise notes</h2>
          <p class="mt-1.5 text-sm text-slate-500">One note per chapter — read in order, or jump to any chapter.</p>
        </div>
        <div class="grid grid-cols-1 gap-px overflow-hidden rounded-2xl border border-slate-200 bg-slate-200 sm:grid-cols-2">
          {chaptered.map((n: any) => {
            const mins = estimatedReadMinutes(n);
            return (
              <a href={url(`/note/${n.id}`)} class="group relative flex flex-col bg-white p-6 transition-colors hover:bg-slate-50">
                <div class="text-[11px] font-bold uppercase tracking-[0.1em] text-slate-400">
                  Chapter {n.data.chapterNumber}
                </div>
                <h3 class="mt-3 font-display text-[17px] font-extrabold leading-snug tracking-tight text-slate-900">
                  {n.data.chapter || n.data.title}
                </h3>
                <p class="mt-2 text-[13px] text-slate-500">
                  {mins} min read
                </p>
                <div class="mt-5 flex items-center gap-1.5 text-[11px] font-bold uppercase tracking-[0.08em] text-slate-400 transition-colors group-hover:text-[#1d4ed8]">
                  Read note
                  <Icon name="arrow-right" size={11} strokeWidth={2.6} />
                </div>
              </a>
            );
          })}
        </div>
      </div>
    )}

    {topicBased.length > 0 && (
      <div>
        <div class="mb-8">
          <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Topic-wise notes</h2>
          <p class="mt-1.5 text-sm text-slate-500">Topic-based study material — essays, references, and quick-revision guides.</p>
        </div>
        <div class="grid grid-cols-1 gap-px overflow-hidden rounded-2xl border border-slate-200 bg-slate-200 sm:grid-cols-2">
          {topicBased.map((n: any) => {
            const mins = estimatedReadMinutes(n);
            return (
              <a href={url(`/note/${n.id}`)} class="group relative flex flex-col bg-white p-6 transition-colors hover:bg-slate-50">
                <h3 class="font-display text-[17px] font-extrabold leading-snug tracking-tight text-slate-900">
                  {n.data.title}
                </h3>
                <p class="mt-2 text-[13px] text-slate-500">
                  {mins} min read
                </p>
                <div class="mt-5 flex items-center gap-1.5 text-[11px] font-bold uppercase tracking-[0.08em] text-slate-400 transition-colors group-hover:text-[#1d4ed8]">
                  Read note
                  <Icon name="arrow-right" size={11} strokeWidth={2.6} />
                </div>
              </a>
            );
          })}
        </div>
      </div>
    )}
  </section>

  <section class="border-t border-slate-200 bg-white">
    <div class="mx-auto max-w-[820px] px-5 py-16 sm:px-7 lg:px-10">
      <div class="prose">
        <h2>About these {subjectName} notes</h2>
        <p>Each note covers one chapter (or one topic) from the Class {cls} {subjectName} syllabus. They're written as revision material — clear summaries you can read in a few minutes and come back to before exams.</p>
        <h3>How to use these notes</h3>
        <ul>
          <li><strong>Before class</strong> — skim the note to know what you're about to learn</li>
          <li><strong>After class</strong> — read it fully to reinforce what was taught</li>
          <li><strong>Before exams</strong> — go through every chapter's note as a quick revision checklist</li>
        </ul>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ /notes/[class]/[subject]"

# ═════════════════════════════════════════════════════════
#  8. /note/[id] — read note
# ═════════════════════════════════════════════════════════
cat > 'src/pages/note/[...slug].astro' <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import SubjectIcon from '../../components/SubjectIcon.astro';
import { url } from '../../lib/url';
import { getCollection, render } from 'astro:content';
import { noteSubjectName, subjectSlug, estimatedReadMinutes, isChaptered } from '../../lib/noteMeta';

export async function getStaticPaths() {
  const notes = await getCollection('notes');
  return notes.map((note: any) => ({ params: { slug: note.id }, props: { note } }));
}

const { note } = Astro.props;
const d = note.data;
const { Content } = await render(note);
const subj = noteSubjectName(d.subject);
const subjSlug = subjectSlug(subj);
const cls = String(d.class);
const mins = estimatedReadMinutes(note);

// Related notes: same subject+class, other chapters/notes
const allNotes = await getCollection('notes');
const siblings = allNotes
  .filter((n: any) =>
    n.id !== note.id &&
    String(n.data.class) === cls &&
    subjectSlug(noteSubjectName(n.data.subject)) === subjSlug
  )
  .sort((a: any, b: any) => (a.data.chapterNumber || 999) - (b.data.chapterNumber || 999));

// Related quizzes for same subject+class
const quizzes = await getCollection('quizzes');
const relatedQuizzes = quizzes
  .filter((q: any) =>
    String(q.data.class) === cls && subjectSlug(noteSubjectName(q.data.subject)) === subjSlug
  )
  .slice(0, 4);

const pageTitle = isChaptered(note)
  ? `${d.chapter || d.title} — Class ${cls} ${subj} Notes | Parhayi`
  : `${d.title} — Class ${cls} ${subj} | Parhayi`;

const description = isChaptered(note)
  ? `Free chapter-wise notes for ${d.chapter || d.title} — Class ${cls} ${subj}. Key definitions, formulas and worked examples.`
  : `Free study notes for ${d.title} — Class ${cls} ${subj}.`;

const jsonLd = [
  {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: [
      { '@type': 'ListItem', position: 1, name: 'Home', item: 'https://malikjeerajajee-coder.github.io/My-edu-site/' },
      { '@type': 'ListItem', position: 2, name: 'Notes', item: 'https://malikjeerajajee-coder.github.io/My-edu-site/notes/' },
      { '@type': 'ListItem', position: 3, name: `Class ${cls}`, item: `https://malikjeerajajee-coder.github.io/My-edu-site/notes/class-${cls}/` },
      { '@type': 'ListItem', position: 4, name: subj, item: `https://malikjeerajajee-coder.github.io/My-edu-site/notes/class-${cls}/${subjSlug}/` },
      { '@type': 'ListItem', position: 5, name: d.title },
    ],
  },
  {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: d.title,
    about: d.chapter || subj,
    educationalLevel: `Class ${cls}`,
    inLanguage: 'en',
    publisher: { '@type': 'Organization', name: 'Parhayi' },
    mainEntityOfPage: `https://malikjeerajajee-coder.github.io/My-edu-site/note/${note.id}/`,
  },
];
---
<BaseLayout title={pageTitle} description={description} jsonLd={jsonLd}>
  <section class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[820px] px-5 pt-8 pb-10 sm:px-7 lg:px-10 lg:pt-10 lg:pb-12">
      <nav class="mb-6 flex flex-wrap items-center gap-2 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <a href={url('/notes')} class="hover:text-[#1d4ed8]">Notes</a>
        <span>/</span>
        <a href={url(`/notes/class-${cls}`)} class="hover:text-[#1d4ed8]">Class {cls}</a>
        <span>/</span>
        <a href={url(`/notes/class-${cls}/${subjSlug}`)} class="hover:text-[#1d4ed8]">{subj}</a>
      </nav>

      <div class="flex items-start gap-4">
        <SubjectIcon subject={subj} size="md" />
        <div class="min-w-0 flex-1">
          {isChaptered(note) && (
            <div class="text-[11px] font-bold uppercase tracking-[0.1em] text-slate-400">
              Class {cls} · Chapter {d.chapterNumber}
            </div>
          )}
          <h1 class="mt-2 font-display text-3xl font-extrabold leading-tight tracking-tight text-slate-900 sm:text-4xl">
            {d.chapter || d.title}
          </h1>
          <p class="mt-2 text-sm text-slate-500">
            {subj} · Class {cls} · {mins} min read
          </p>
        </div>
      </div>

      {d.pdfUrl && (
        <a href={d.pdfUrl} target="_blank" rel="noopener"
           class="mt-7 inline-flex items-center gap-2 rounded-lg border border-slate-300 bg-white px-5 py-3 text-sm font-bold text-slate-700 transition-colors hover:border-slate-400">
          <Icon name="download" size={16} strokeWidth={2.4} /> Download PDF version
        </a>
      )}
    </div>
  </section>

  <div class="mx-auto max-w-[820px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
    <article class="prose">
      <Content />
    </article>
  </div>

  {relatedQuizzes.length > 0 && (
    <section class="border-t border-slate-200 bg-slate-50">
      <div class="mx-auto max-w-[820px] px-5 py-14 sm:px-7 lg:px-10">
        <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Test yourself</h2>
        <p class="mt-1.5 text-sm text-slate-500">Practice MCQs for the same subject and class.</p>
        <div class="mt-6 grid grid-cols-1 gap-px overflow-hidden rounded-2xl border border-slate-200 bg-slate-200 sm:grid-cols-2">
          {relatedQuizzes.map((q: any) => {
            const n = q.data.questions?.length || 0;
            return (
              <a href={url(`/quiz/${q.id}`)} class="group relative flex flex-col bg-white p-5 transition-colors hover:bg-slate-50">
                <h3 class="font-display text-[15px] font-extrabold leading-snug tracking-tight text-slate-900">
                  {q.data.title}
                </h3>
                <p class="mt-2 text-[12px] text-slate-500">
                  {n} {n === 1 ? 'question' : 'questions'}
                </p>
                <div class="mt-4 flex items-center gap-1.5 text-[11px] font-bold uppercase tracking-[0.08em] text-slate-400 transition-colors group-hover:text-[#1d4ed8]">
                  Start quiz
                  <Icon name="arrow-right" size={11} strokeWidth={2.6} />
                </div>
              </a>
            );
          })}
        </div>
      </div>
    </section>
  )}

  {siblings.length > 0 && (
    <section class="border-t border-slate-200 bg-white">
      <div class="mx-auto max-w-[820px] px-5 py-14 sm:px-7 lg:px-10">
        <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">More {subj} notes</h2>
        <p class="mt-1.5 text-sm text-slate-500">Other chapters from Class {cls} {subj}.</p>
        <ul class="mt-6 divide-y divide-slate-200 border-y border-slate-200">
          {siblings.map((n: any) => (
            <li>
              <a href={url(`/note/${n.id}`)} class="group flex items-center gap-3 py-4 transition-colors hover:bg-slate-50">
                <span class="min-w-0 flex-1">
                  <span class="block text-sm font-bold text-slate-900">
                    {n.data.chapter || n.data.title}
                  </span>
                  {n.data.chapterNumber && (
                    <span class="block mt-0.5 text-[12px] text-slate-500">Chapter {n.data.chapterNumber}</span>
                  )}
                </span>
                <Icon name="arrow-right" size={14} strokeWidth={2.4} class="shrink-0 text-slate-300 group-hover:text-[#1d4ed8]" />
              </a>
            </li>
          ))}
        </ul>
      </div>
    </section>
  )}

  <div class="mx-auto max-w-[820px] px-5 pb-16 pt-8 sm:px-7 lg:px-10">
    <a href={url(`/notes/class-${cls}/${subjSlug}`)} class="inline-flex items-center gap-2 text-sm font-semibold text-slate-500 hover:text-[#1d4ed8]">
      <Icon name="arrow-left" size={16} strokeWidth={2.4} /> Back to {subj} notes
    </a>
  </div>
</BaseLayout>
ASTRO
echo "  ✓ /note/[id]"

# ═════════════════════════════════════════════════════════
#  9. Update internal links /notes/[id] → /note/[id]
# ═════════════════════════════════════════════════════════
echo ""
echo "▸ 9. Updating internal links..."

python3 <<'PY'
import pathlib, re

# Search index
p = pathlib.Path('src/pages/search-index.json.ts')
if p.exists():
    s = p.read_text()
    s = re.sub(r"`\$\{base\}/notes/\$\{n\.id\}`", "`${base}/note/${n.id}`", s)
    p.write_text(s)
    print('  ✓ search-index.json.ts')

# Other astro files
for f in pathlib.Path('src').rglob('*.astro'):
    s = f.read_text()
    orig = s
    s = re.sub(r"url\(`/notes/\$\{([a-z]+)\.id}`\)", r"url(`/note/${\1.id}`)", s)
    if s != orig:
        f.write_text(s)
        print(f'  ✓ {f.relative_to("src")}')
PY

# ═════════════════════════════════════════════════════════
#  10. Rebuild
# ═════════════════════════════════════════════════════════
echo ""
echo "Rebuilding..."
rm -rf dist .astro node_modules/.vite
npm run build 2>&1 | tail -10

echo ""
echo "════════════════════════════════════════════════════════"
echo "  DONE"
echo ""
echo "  Preview: bash start-server.sh"
echo ""
echo "  URLs:"
echo "    /notes/                                  → class hub"
echo "    /notes/class-9/                          → subject list"
echo "    /notes/class-9/english/                  → notes for English"
echo "    /notes/class-9/english/topic-slug/       → read a note"
echo ""
echo "  Design (matches books & quizzes):"
echo "    · Editorial hero with stat row"
echo "    · Seamed card grids"
echo "    · Chaptered + topic-based notes handled separately"
echo "    · One accent color, quiet hovers"
echo ""
echo "  Push when happy:"
echo "    git add . && git commit -m 'Notes: full editorial build' && git push"
echo ""
echo "  Revert: git checkout backup-pre-notes-v2"
echo "════════════════════════════════════════════════════════"