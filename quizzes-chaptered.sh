#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "════════════════════════════════════════════"
echo "  Quizzes — chapter-based structure"
echo "════════════════════════════════════════════"
echo ""

git branch -f backup-pre-quiz-chapters 2>/dev/null || true
echo "  ✓ backup-pre-quiz-chapters created"
echo ""

# ═════════════════════════════════════════════════════════
#  1. Update schema — add chapter + chapterNumber
# ═════════════════════════════════════════════════════════
echo "▸ 1. Updating quiz schema..."

python3 <<'PY'
import pathlib, re
p = pathlib.Path('src/content.config.ts')
s = p.read_text()

old = """const quizzes = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/quizzes' }),
  schema: z.object({
    title: z.string(),
    subject: z.string(),
    class: z.string(),
    board: z.string().optional(),
    boards: z.array(z.string()).optional(),
    questions: z.array(z.object({
      question: z.string(),
      options: z.array(z.string()),
      answer: z.number(),
    })),
  }),
});"""

new = """const quizzes = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/quizzes' }),
  schema: z.object({
    title: z.string(),
    subject: z.string(),
    class: z.string(),
    chapter: z.string(),
    chapterNumber: z.number(),
    board: z.string().optional(),
    boards: z.array(z.string()).optional(),
    questions: z.array(z.object({
      question: z.string(),
      options: z.array(z.string()),
      answer: z.number(),
    })),
  }),
});"""

if old in s:
    s = s.replace(old, new)
    p.write_text(s)
    print('  ✓ schema updated')
else:
    print('  ! schema block not found — checking current form')
    # Fallback: insert chapter fields if missing
    if 'chapter: z.string()' not in s:
        s = s.replace(
            "    class: z.string(),\n    board: z.string().optional(),\n    boards: z.array(z.string()).optional(),\n    questions: z.array",
            "    class: z.string(),\n    chapter: z.string(),\n    chapterNumber: z.number(),\n    board: z.string().optional(),\n    boards: z.array(z.string()).optional(),\n    questions: z.array"
        )
        p.write_text(s)
        print('  ✓ chapter fields added (fallback)')
PY

# ═════════════════════════════════════════════════════════
#  2. Migrate existing 3 quizzes to include chapter
# ═════════════════════════════════════════════════════════
echo ""
echo "▸ 2. Migrating existing quizzes..."

python3 <<'PY'
import pathlib, re

QDIR = pathlib.Path('src/content/quizzes')

chapters = {
    'math-10-ch1-quiz.md':       ('Quadratic Equations', 1),
    'physics-9-ch1-quiz.md':     ('Physical Quantities & Measurement', 1),
    'chemistry-10-ch1-quiz.md':  ('Chemical Equilibrium', 1),
}

for fname, (chapter, num) in chapters.items():
    p = QDIR / fname
    if not p.exists():
        print(f'  · {fname} not found — skipping')
        continue
    s = p.read_text()
    fm_end = s.find('---', 3)
    fm = s[:fm_end]
    if 'chapter:' in fm:
        print(f'  · {fname} already has chapter')
        continue
    # Insert chapter fields after `class:` line
    s = re.sub(
        r'^(class:\s*[^\n]+)\n',
        r'\1\nchapter: "' + chapter + '"\nchapterNumber: ' + str(num) + '\n',
        s, count=1, flags=re.MULTILINE
    )
    p.write_text(s)
    print(f'  ✓ {fname}')
PY

# ═════════════════════════════════════════════════════════
#  3. Helper — quiz metadata
# ═════════════════════════════════════════════════════════
cat > src/lib/quizMeta.ts <<'TS'
import type { CollectionEntry } from 'astro:content';

export function quizSubjectName(subject: string): string {
  return subject.replace(/\s*\([^)]*\)\s*/g, '').trim();
}

export function subjectSlug(subject: string): string {
  return subject
    .toLowerCase()
    .replace(/\(.*?\)/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
}

// Approximate reading time — 30 seconds per MCQ
export function estimatedMinutes(q: CollectionEntry<'quizzes'>): number {
  const n = q.data.questions?.length || 0;
  return Math.max(1, Math.round((n * 30) / 60));
}
TS
echo ""
echo "  ✓ quizMeta.ts"

# ═════════════════════════════════════════════════════════
#  4. Remove old routes, prep new tree
# ═════════════════════════════════════════════════════════
rm -rf src/pages/quizzes
rm -rf src/pages/quiz
mkdir -p 'src/pages/quizzes/[class]'
mkdir -p src/pages/quiz
echo "  ✓ Cleaned"

# ═════════════════════════════════════════════════════════
#  5. /quizzes — class hub
# ═════════════════════════════════════════════════════════
cat > src/pages/quizzes/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { getCollection } from 'astro:content';
import { quizSubjectName } from '../../lib/quizMeta';

const quizzes = await getCollection('quizzes');

const byClass = new Map<string, { count: number; subjects: Set<string>; questions: number }>();
quizzes.forEach((q: any) => {
  const c = String(q.data.class);
  if (!byClass.has(c)) byClass.set(c, { count: 0, subjects: new Set(), questions: 0 });
  const entry = byClass.get(c)!;
  entry.count++;
  entry.subjects.add(quizSubjectName(q.data.subject));
  entry.questions += q.data.questions?.length || 0;
});
const classes = [...byClass.entries()]
  .map(([cls, v]) => ({ cls, count: v.count, subjects: v.subjects.size, questions: v.questions }))
  .sort((a, b) => Number(a.cls) - Number(b.cls));

const totalQuestions = quizzes.reduce((n: number, q: any) => n + (q.data.questions?.length || 0), 0);
const totalSubjects = new Set(quizzes.map((q: any) => quizSubjectName(q.data.subject))).size;

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  name: 'Chapter-wise Practice Quizzes — Pakistani Board Students',
  description: `Interactive MCQ quizzes organised by class, subject and chapter. ${quizzes.length} quizzes, ${totalQuestions} questions, instant feedback.`,
};
---
<BaseLayout
  title="Chapter-wise Practice Quizzes — Class 9 to 12 MCQs | Parhayi"
  description={`Interactive MCQ quizzes organised by class, subject and chapter. ${quizzes.length} quizzes, ${totalQuestions} questions — instant feedback, no sign-up.`}
  jsonLd={jsonLd}
>
  <section class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-12 pb-14 sm:px-7 lg:px-10 lg:pt-16 lg:pb-20">
      <nav class="mb-8 flex items-center gap-2 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">Quizzes</span>
      </nav>
      <h1 class="max-w-3xl font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl lg:text-6xl">
        Chapter-wise quizzes.
      </h1>
      <p class="mt-6 max-w-2xl text-base leading-relaxed text-slate-600 sm:text-lg">
        Interactive MCQ quizzes organised by class, subject and chapter — matching exactly what appears in your board exam.
      </p>
      <dl class="mt-10 flex flex-wrap gap-x-12 gap-y-4">
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Quizzes</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{quizzes.length}</dd>
        </div>
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Questions</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{totalQuestions}</dd>
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
      <p class="mt-1.5 text-sm text-slate-500">Every class has its own chapter-wise quizzes.</p>
    </div>

    {classes.length === 0 ? (
      <div class="rounded-2xl border border-dashed border-slate-300 bg-white p-12 text-center">
        <p class="text-sm font-bold text-slate-900">Quizzes coming soon</p>
        <p class="mt-1 text-xs text-slate-500">We're building chapter-wise MCQ quizzes for every class and subject.</p>
      </div>
    ) : (
      <div class="grid grid-cols-2 gap-px overflow-hidden rounded-2xl border border-slate-200 bg-slate-200 sm:grid-cols-3 lg:grid-cols-4">
        {classes.map(c => (
          <a href={url(`/quizzes/class-${c.cls}`)} class="group relative flex flex-col bg-white p-6 transition-colors hover:bg-slate-50">
            <span class="font-display text-4xl font-extrabold leading-none tracking-tight tabular-nums text-slate-900">
              {c.cls.padStart(2, '0')}
            </span>
            <div class="mt-6 text-[13px] font-bold text-slate-900">Class {c.cls}</div>
            <div class="mt-0.5 text-[12px] text-slate-500">
              {c.subjects} {c.subjects === 1 ? 'subject' : 'subjects'} · {c.questions} questions
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
        <h2>Why chapter-wise quizzes work</h2>
        <p>Reading notes gets you ready. Testing yourself is what makes it stick. But a general "Physics quiz" barely helps — you need to know <em>which chapters</em> you've actually mastered, and which still trip you up.</p>
        <p>Every quiz on Parhayi is tied to one specific chapter within one specific subject and class. That's how the board exams are structured, and that's how you should test yourself.</p>
        <h3>How to use these quizzes</h3>
        <ul>
          <li><strong>After studying a chapter</strong> — take the quiz to see if you've really understood it</li>
          <li><strong>Before an exam</strong> — go through each chapter's quiz to find your weak spots</li>
          <li><strong>Spaced repetition</strong> — retake quizzes a week later to lock in the material</li>
        </ul>
        <h3>What to expect</h3>
        <ul>
          <li>One question at a time — no overwhelming wall of MCQs</li>
          <li>Instant feedback after each choice</li>
          <li>A running score and a final percentage</li>
          <li>Restart any quiz as many times as you like</li>
        </ul>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ /quizzes"

# ═════════════════════════════════════════════════════════
#  6. /quizzes/[class] — subject list
# ═════════════════════════════════════════════════════════
cat > 'src/pages/quizzes/[class]/index.astro' <<'ASTRO'
---
import BaseLayout from '../../../layouts/BaseLayout.astro';
import Icon from '../../../components/Icon.astro';
import SubjectIcon from '../../../components/SubjectIcon.astro';
import { url } from '../../../lib/url';
import { getCollection } from 'astro:content';
import { quizSubjectName, subjectSlug } from '../../../lib/quizMeta';

export async function getStaticPaths() {
  const quizzes = await getCollection('quizzes');
  const classes = new Set(quizzes.map((q: any) => String(q.data.class)));
  return [...classes].map(c => ({ params: { class: `class-${c}` } }));
}

const { class: classParam } = Astro.params;
const cls = String(classParam).replace(/^class-/, '');
const allQuizzes = await getCollection('quizzes');
const quizzes = allQuizzes.filter((q: any) => String(q.data.class) === cls);

const bySubject = new Map<string, { count: number; questions: number; chapters: Set<string> }>();
quizzes.forEach((q: any) => {
  const subj = quizSubjectName(q.data.subject);
  if (!bySubject.has(subj)) bySubject.set(subj, { count: 0, questions: 0, chapters: new Set() });
  const s = bySubject.get(subj)!;
  s.count++;
  s.questions += q.data.questions?.length || 0;
  s.chapters.add(String(q.data.chapterNumber) + '|' + q.data.chapter);
});
const subjects = [...bySubject.entries()]
  .map(([name, v]) => ({ name, slug: subjectSlug(name), count: v.count, questions: v.questions, chapters: v.chapters.size }))
  .sort((a, b) => a.name.localeCompare(b.name));

const totalQuestions = quizzes.reduce((n: number, q: any) => n + (q.data.questions?.length || 0), 0);

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  name: `Class ${cls} Practice Quizzes`,
  description: `Interactive chapter-wise MCQ quizzes for Class ${cls}. ${quizzes.length} quizzes across ${subjects.length} subjects.`,
};
---
<BaseLayout
  title={`Class ${cls} Quizzes — Chapter-wise MCQs by Subject | Parhayi`}
  description={`Free chapter-wise MCQ quizzes for Class ${cls}. ${quizzes.length} quizzes across ${subjects.length} subjects, ${totalQuestions} questions with instant feedback.`}
  jsonLd={jsonLd}
>
  <section class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-14 sm:px-7 lg:px-10 lg:pt-12 lg:pb-16">
      <nav class="mb-8 flex items-center gap-2 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <a href={url('/quizzes')} class="hover:text-[#1d4ed8]">Quizzes</a>
        <span>/</span>
        <span class="text-slate-500">Class {cls}</span>
      </nav>
      <h1 class="font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl">
        Class {cls} Quizzes
      </h1>
      <p class="mt-5 max-w-2xl text-base leading-relaxed text-slate-600">
        Chapter-wise MCQ quizzes for every Class {cls} subject. {totalQuestions} practice questions across {subjects.length} subjects.
      </p>
    </div>
  </section>

  <section class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
    <div class="mb-8">
      <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Choose a subject</h2>
      <p class="mt-1.5 text-sm text-slate-500">Every subject has its own chapter-wise quizzes.</p>
    </div>

    {subjects.length === 0 ? (
      <div class="rounded-2xl border border-dashed border-slate-300 bg-white p-12 text-center">
        <p class="text-sm font-bold text-slate-900">No quizzes yet for Class {cls}</p>
        <a href={url('/quizzes')} class="mt-4 inline-block text-sm font-semibold text-[#1d4ed8]">Back to all classes</a>
      </div>
    ) : (
      <div class="grid grid-cols-1 gap-px overflow-hidden rounded-2xl border border-slate-200 bg-slate-200 sm:grid-cols-2 lg:grid-cols-3">
        {subjects.map(s => (
          <a href={url(`/quizzes/class-${cls}/${s.slug}`)} class="group relative flex flex-col bg-white p-6 transition-colors hover:bg-slate-50">
            <div class="flex items-start gap-3">
              <SubjectIcon subject={s.name} size="sm" />
              <div class="min-w-0 flex-1">
                <h3 class="font-display text-[17px] font-extrabold leading-tight tracking-tight text-slate-900">{s.name}</h3>
                <p class="mt-1 text-[12px] text-slate-500">
                  {s.chapters} {s.chapters === 1 ? 'chapter' : 'chapters'} · {s.questions} questions
                </p>
              </div>
            </div>
            <div class="mt-6 flex items-center gap-1 text-[11px] font-bold uppercase tracking-[0.08em] text-slate-400 transition-colors group-hover:text-[#1d4ed8]">
              Start
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
        <h2>Class {cls} chapter-wise quizzes</h2>
        <p>Every Class {cls} subject is organised into chapters by the board. Our quizzes follow the same structure — one quiz per chapter, so you can test yourself as you go.</p>
        <p>Pick a subject above to see all its chapters.</p>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ /quizzes/[class]"

# ═════════════════════════════════════════════════════════
#  7. /quizzes/[class]/[subject] — quizzes grouped by chapter
# ═════════════════════════════════════════════════════════
cat > 'src/pages/quizzes/[class]/[subject].astro' <<'ASTRO'
---
import BaseLayout from '../../../layouts/BaseLayout.astro';
import Icon from '../../../components/Icon.astro';
import SubjectIcon from '../../../components/SubjectIcon.astro';
import { url } from '../../../lib/url';
import { getCollection } from 'astro:content';
import { quizSubjectName, subjectSlug, estimatedMinutes } from '../../../lib/quizMeta';

export async function getStaticPaths() {
  const quizzes = await getCollection('quizzes');
  const paths: any[] = [];
  const seen = new Set<string>();
  quizzes.forEach((q: any) => {
    const cls = String(q.data.class);
    const subj = subjectSlug(quizSubjectName(q.data.subject));
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
const allQuizzes = await getCollection('quizzes');

const quizzes = allQuizzes.filter((q: any) =>
  String(q.data.class) === cls && subjectSlug(quizSubjectName(q.data.subject)) === subjectParam
);

if (!quizzes.length) return Astro.redirect(`/quizzes/class-${cls}`);

const subjectName = quizSubjectName(quizzes[0].data.subject);
const totalQuestions = quizzes.reduce((n: number, q: any) => n + (q.data.questions?.length || 0), 0);
const totalMinutes = quizzes.reduce((n: number, q: any) => n + estimatedMinutes(q), 0);

// Group by chapter
const byChapter = new Map<number, { chapter: string; quizzes: typeof quizzes }>();
quizzes.forEach((q: any) => {
  const num = q.data.chapterNumber;
  if (!byChapter.has(num)) byChapter.set(num, { chapter: q.data.chapter, quizzes: [] });
  byChapter.get(num)!.quizzes.push(q);
});
const chapters = [...byChapter.entries()]
  .map(([num, v]) => ({ num, chapter: v.chapter, quizzes: v.quizzes }))
  .sort((a, b) => a.num - b.num);

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  name: `Class ${cls} ${subjectName} Quizzes — Chapter-wise MCQs`,
  description: `${quizzes.length} interactive chapter-wise quizzes for Class ${cls} ${subjectName}. ${totalQuestions} questions with instant feedback.`,
};
---
<BaseLayout
  title={`Class ${cls} ${subjectName} Quizzes — Chapter-wise MCQs | Parhayi`}
  description={`Free ${subjectName} MCQ quizzes for Class ${cls}, organised chapter by chapter. ${quizzes.length} quizzes, ${totalQuestions} questions.`}
  jsonLd={jsonLd}
>
  <section class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-14 sm:px-7 lg:px-10 lg:pt-12 lg:pb-16">
      <nav class="mb-8 flex flex-wrap items-center gap-2 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <a href={url('/quizzes')} class="hover:text-[#1d4ed8]">Quizzes</a>
        <span>/</span>
        <a href={url(`/quizzes/class-${cls}`)} class="hover:text-[#1d4ed8]">Class {cls}</a>
        <span>/</span>
        <span class="text-slate-500">{subjectName}</span>
      </nav>
      <div class="flex items-start gap-4">
        <SubjectIcon subject={subjectName} size="md" />
        <div>
          <h1 class="font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-5xl">
            {subjectName}
          </h1>
          <p class="mt-2 text-sm text-slate-500">
            Class {cls} · {chapters.length} {chapters.length === 1 ? 'chapter' : 'chapters'} · {totalQuestions} questions · ~{totalMinutes} min total
          </p>
        </div>
      </div>
    </div>
  </section>

  <section class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
    <div class="mb-8">
      <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Quizzes by chapter</h2>
      <p class="mt-1.5 text-sm text-slate-500">Pick any chapter to take its quiz.</p>
    </div>

    <div class="space-y-10">
      {chapters.map(ch => (
        <div>
          <div class="mb-4 flex items-baseline gap-3">
            <span class="font-display text-sm font-extrabold uppercase tracking-[0.1em] text-slate-400">
              Chapter {ch.num}
            </span>
            <h3 class="font-display text-lg font-extrabold leading-snug tracking-tight text-slate-900">
              {ch.chapter}
            </h3>
          </div>

          <div class="grid grid-cols-1 gap-px overflow-hidden rounded-2xl border border-slate-200 bg-slate-200 sm:grid-cols-2">
            {ch.quizzes.map((q: any) => {
              const n = q.data.questions?.length || 0;
              const mins = estimatedMinutes(q);
              return (
                <a href={url(`/quiz/${q.id}`)} class="group relative flex flex-col bg-white p-6 transition-colors hover:bg-slate-50">
                  <h4 class="font-display text-[16px] font-extrabold leading-snug tracking-tight text-slate-900">
                    {q.data.title}
                  </h4>
                  <p class="mt-2 text-[13px] text-slate-500">
                    {n} {n === 1 ? 'question' : 'questions'} · ~{mins} min
                  </p>
                  <div class="mt-5 flex items-center gap-1.5 text-[11px] font-bold uppercase tracking-[0.08em] text-slate-400 transition-colors group-hover:text-[#1d4ed8]">
                    Start quiz
                    <Icon name="arrow-right" size={11} strokeWidth={2.6} />
                  </div>
                </a>
              );
            })}
          </div>
        </div>
      ))}
    </div>
  </section>

  <section class="border-t border-slate-200 bg-white">
    <div class="mx-auto max-w-[820px] px-5 py-16 sm:px-7 lg:px-10">
      <div class="prose">
        <h2>About these {subjectName} quizzes</h2>
        <p>Each quiz covers one specific chapter from the Class {cls} {subjectName} syllabus. They're structured to match the board exam — same topics, same difficulty, same style of questions.</p>
        <h3>How to use them</h3>
        <ul>
          <li><strong>After finishing a chapter</strong> — take that chapter's quiz to check your understanding</li>
          <li><strong>Before an exam</strong> — go through every chapter to find what still needs revision</li>
          <li><strong>Weekly</strong> — retake the quizzes you got wrong last time</li>
        </ul>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ /quizzes/[class]/[subject]"

# ═════════════════════════════════════════════════════════
#  8. /quiz/[id] — quiz player
# ═════════════════════════════════════════════════════════
cat > 'src/pages/quiz/[...slug].astro' <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import QuizPlayer from '../../components/QuizPlayer.astro';
import SubjectIcon from '../../components/SubjectIcon.astro';
import { url } from '../../lib/url';
import { getCollection, render } from 'astro:content';
import { quizSubjectName, subjectSlug, estimatedMinutes } from '../../lib/quizMeta';

export async function getStaticPaths() {
  const quizzes = await getCollection('quizzes');
  return quizzes.map((quiz: any) => ({ params: { slug: quiz.id }, props: { quiz } }));
}

const { quiz } = Astro.props;
const d = quiz.data;
const { Content } = await render(quiz);
const subj = quizSubjectName(d.subject);
const subjSlug = subjectSlug(subj);
const cls = String(d.class);
const n = d.questions?.length || 0;
const mins = estimatedMinutes(quiz);

const jsonLd = [
  {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: [
      { '@type': 'ListItem', position: 1, name: 'Home', item: 'https://malikjeerajajee-coder.github.io/My-edu-site/' },
      { '@type': 'ListItem', position: 2, name: 'Quizzes', item: 'https://malikjeerajajee-coder.github.io/My-edu-site/quizzes/' },
      { '@type': 'ListItem', position: 3, name: `Class ${cls}`, item: `https://malikjeerajajee-coder.github.io/My-edu-site/quizzes/class-${cls}/` },
      { '@type': 'ListItem', position: 4, name: subj, item: `https://malikjeerajajee-coder.github.io/My-edu-site/quizzes/class-${cls}/${subjSlug}/` },
      { '@type': 'ListItem', position: 5, name: d.title },
    ],
  },
  {
    '@context': 'https://schema.org',
    '@type': 'Quiz',
    name: d.title,
    about: { '@type': 'Thing', name: d.chapter },
    educationalLevel: `Class ${cls}`,
    learningResourceType: 'Quiz',
    educationalAlignment: {
      '@type': 'AlignmentObject',
      alignmentType: 'educationalSubject',
      targetName: subj,
    },
  },
];
---
<BaseLayout
  title={`${d.title} — ${subj} Class ${cls} Chapter ${d.chapterNumber} | Parhayi`}
  description={`Take the free ${d.title} — ${n} MCQs with instant feedback. Class ${cls} ${subj}, Chapter ${d.chapterNumber}: ${d.chapter}.`}
  jsonLd={jsonLd}
>
  <section class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[900px] px-5 pt-8 pb-10 sm:px-7 lg:px-10 lg:pt-10 lg:pb-12">
      <nav class="mb-6 flex flex-wrap items-center gap-2 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <a href={url('/quizzes')} class="hover:text-[#1d4ed8]">Quizzes</a>
        <span>/</span>
        <a href={url(`/quizzes/class-${cls}`)} class="hover:text-[#1d4ed8]">Class {cls}</a>
        <span>/</span>
        <a href={url(`/quizzes/class-${cls}/${subjSlug}`)} class="hover:text-[#1d4ed8]">{subj}</a>
      </nav>

      <div class="flex items-start gap-4">
        <SubjectIcon subject={subj} size="md" />
        <div class="min-w-0 flex-1">
          <div class="text-[11px] font-bold uppercase tracking-[0.1em] text-slate-400">
            Class {cls} · Chapter {d.chapterNumber}
          </div>
          <h1 class="mt-2 font-display text-3xl font-extrabold leading-tight tracking-tight text-slate-900 sm:text-4xl">
            {d.title}
          </h1>
          <p class="mt-2 text-sm text-slate-500">
            {d.chapter} · {n} {n === 1 ? 'question' : 'questions'} · ~{mins} min
          </p>
        </div>
      </div>
    </div>
  </section>

  <div class="mx-auto max-w-[900px] px-5 py-10 sm:px-7 lg:px-10 lg:py-12">
    <QuizPlayer questions={d.questions} title={d.title} />
  </div>

  {Content && (
    <div class="mx-auto max-w-[820px] px-5 pb-16 sm:px-7 lg:px-10">
      <article class="prose">
        <Content />
      </article>
    </div>
  )}

  <section class="border-t border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[820px] px-5 py-14 sm:px-7 lg:px-10">
      <div class="prose">
        <h2>Tips for this quiz</h2>
        <ul>
          <li>Read every option before choosing — the trickiest MCQs have two similar answers</li>
          <li>Pay attention to <em>why</em> you got a question wrong — that's where learning happens</li>
          <li>Retake the quiz a day later — that's when the material really sticks</li>
          <li>On desktop, use keys A/B/C/D or 1/2/3/4 to answer faster</li>
        </ul>
      </div>
    </div>
  </section>

  <div class="mx-auto max-w-[900px] px-5 pb-16 pt-8 sm:px-7 lg:px-10">
    <a href={url(`/quizzes/class-${cls}/${subjSlug}`)} class="inline-flex items-center gap-2 text-sm font-semibold text-slate-500 hover:text-[#1d4ed8]">
      <Icon name="arrow-left" size={16} strokeWidth={2.4} /> Back to {subj} quizzes
    </a>
  </div>
</BaseLayout>
ASTRO
echo "  ✓ /quiz/[id]"

# ═════════════════════════════════════════════════════════
#  9. Update internal links from /quizzes/[id] → /quiz/[id]
# ═════════════════════════════════════════════════════════
echo ""
echo "▸ 9. Updating internal links..."

python3 <<'PY'
import pathlib, re

# Search index
p = pathlib.Path('src/pages/search-index.json.ts')
if p.exists():
    s = p.read_text()
    s = re.sub(r"`\$\{base\}/quizzes/\$\{q\.id\}`", "`${base}/quiz/${q.id}`", s)
    p.write_text(s)
    print('  ✓ search-index.json.ts')

# Any other file linking to /quizzes/${...}
for f in pathlib.Path('src').rglob('*.astro'):
    s = f.read_text()
    orig = s
    s = re.sub(r"url\(`/quizzes/\$\{([a-z]+)\.id}`\)", r"url(`/quiz/${\1.id}`)", s)
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
echo "    /quizzes/                              → class hub"
echo "    /quizzes/class-9/                      → subject list"
echo "    /quizzes/class-9/physics/              → quizzes grouped by chapter"
echo "    /quiz/physics-9-ch1-quiz/              → take the quiz"
echo ""
echo "  What changed:"
echo "    · Every quiz now has 'chapter' + 'chapterNumber'"
echo "    · Subject page groups quizzes by chapter"
echo "    · Quiz page shows chapter context in breadcrumb + header"
echo "    · Quiz schema includes chapter as the topic"
echo "    · URLs are clean and semantic"
echo ""
echo "  Push when happy:"
echo "    git add . && git commit -m 'Quizzes: chapter-based structure' && git push"
echo ""
echo "  Revert: git checkout backup-pre-quiz-chapters"
echo "════════════════════════════════════════════════════════"