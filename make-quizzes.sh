#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "════════════════════════════════════════════"
echo "  Quizzes section — full build"
echo "════════════════════════════════════════════"
echo ""

git branch -f backup-pre-quizzes 2>/dev/null || true
echo "  ✓ backup-pre-quizzes created"
echo ""

# ═════════════════════════════════════════════════════════
#  1. Delete old flat routes, prepare new structure
# ═════════════════════════════════════════════════════════
rm -f 'src/pages/quizzes/[...slug].astro'
rm -f 'src/pages/quizzes/index.astro'
mkdir -p 'src/pages/quizzes/[class]'
mkdir -p src/pages/quiz
echo "  ✓ Cleaned old routes"

# ═════════════════════════════════════════════════════════
#  2. Helper for quiz metadata
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

// Estimated time — ~30 seconds per MCQ
export function estimatedMinutes(q: CollectionEntry<'quizzes'>): number {
  const n = q.data.questions?.length || 0;
  return Math.max(1, Math.round((n * 30) / 60));
}

// Extract unique subjects and classes
export function groupQuizzes(quizzes: CollectionEntry<'quizzes'>[]) {
  const byClass = new Map<string, CollectionEntry<'quizzes'>[]>();
  quizzes.forEach(q => {
    const c = String(q.data.class);
    if (!byClass.has(c)) byClass.set(c, []);
    byClass.get(c)!.push(q);
  });
  return byClass;
}

export function classOrder(a: string, b: string): number {
  return Number(a) - Number(b);
}
TS
echo "  ✓ quizMeta.ts"

# ═════════════════════════════════════════════════════════
#  3. /quizzes — hub with class grid
# ═════════════════════════════════════════════════════════
cat > src/pages/quizzes/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { url } from '../../lib/url';
import { getCollection } from 'astro:content';
import { quizSubjectName, estimatedMinutes } from '../../lib/quizMeta';

const quizzes = await getCollection('quizzes');

const byClass = new Map<string, { count: number; subjects: Set<string>; minutes: number }>();
quizzes.forEach((q: any) => {
  const c = String(q.data.class);
  if (!byClass.has(c)) byClass.set(c, { count: 0, subjects: new Set(), minutes: 0 });
  const s = byClass.get(c)!;
  s.count++;
  s.subjects.add(quizSubjectName(q.data.subject));
  s.minutes += estimatedMinutes(q);
});
const classes = [...byClass.entries()]
  .map(([cls, v]) => ({ cls, count: v.count, subjects: v.subjects.size, minutes: v.minutes }))
  .sort((a, b) => Number(a.cls) - Number(b.cls));

const totalQuestions = quizzes.reduce((n: number, q: any) => n + (q.data.questions?.length || 0), 0);
const totalSubjects = new Set(quizzes.map((q: any) => quizSubjectName(q.data.subject))).size;

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  name: 'Practice Quizzes — Pakistani Board Students',
  description: `Interactive MCQ quizzes for Class 9 to 12. ${quizzes.length} quizzes, ${totalQuestions}+ questions, instant feedback.`,
};
---
<BaseLayout
  title="Practice Quizzes — MCQ Tests for Class 9 to 12 | Parhayi"
  description={`Interactive MCQ quizzes for Pakistani students. ${quizzes.length} quizzes across ${totalSubjects} subjects — instant feedback, no sign-up.`}
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
        Test what you've learned.
      </h1>
      <p class="mt-6 max-w-2xl text-base leading-relaxed text-slate-600 sm:text-lg">
        Interactive MCQ quizzes for Pakistani board students. Instant feedback, a score at the end, no sign-up.
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
      <p class="mt-1.5 text-sm text-slate-500">Pick a class to see quizzes for its subjects.</p>
    </div>

    {classes.length === 0 ? (
      <div class="rounded-2xl border border-dashed border-slate-300 bg-white p-12 text-center">
        <p class="text-sm font-bold text-slate-900">Quizzes are coming soon</p>
        <p class="mt-1 text-xs text-slate-500">We're building interactive MCQ quizzes for every subject and class.</p>
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
              {c.count} {c.count === 1 ? 'quiz' : 'quizzes'} · {c.subjects} {c.subjects === 1 ? 'subject' : 'subjects'}
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
        <h2>Practice makes progress</h2>
        <p>Reading notes and past papers gets you ready. Testing yourself is what makes it stick. Our interactive quizzes are designed to give you quick, focused practice on the material that actually appears in your board exams.</p>
        <p>Every quiz is written for the Pakistani board syllabus — Punjab (PTB), Federal (FBISE), Sindh (STBB), and Balochistan (BTBB). Same material, same difficulty, same style as your real exam.</p>
        <h3>How our quizzes work</h3>
        <ul>
          <li><strong>One question at a time</strong> — no overwhelming wall of questions</li>
          <li><strong>Instant feedback</strong> — you see the correct answer immediately after each choice</li>
          <li><strong>Live score</strong> — your running score updates as you go</li>
          <li><strong>No time limit</strong> — work at your own pace</li>
          <li><strong>Restart anytime</strong> — repeat any quiz as often as you like</li>
        </ul>
        <h3>Where to start</h3>
        <p>Pick your class above, then your subject. If you're not sure where to begin, start with a subject you find hardest — that's usually where the biggest gains are.</p>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ /quizzes (hub)"

# ═════════════════════════════════════════════════════════
#  4. /quizzes/[class] — subject picker
# ═════════════════════════════════════════════════════════
cat > 'src/pages/quizzes/[class]/index.astro' <<'ASTRO'
---
import BaseLayout from '../../../layouts/BaseLayout.astro';
import Icon from '../../../components/Icon.astro';
import SubjectIcon from '../../../components/SubjectIcon.astro';
import { url } from '../../../lib/url';
import { getCollection } from 'astro:content';
import { quizSubjectName, subjectSlug, estimatedMinutes } from '../../../lib/quizMeta';

export async function getStaticPaths() {
  const quizzes = await getCollection('quizzes');
  const classes = new Set(quizzes.map((q: any) => String(q.data.class)));
  return [...classes].map(c => ({ params: { class: `class-${c}` } }));
}

const { class: classParam } = Astro.params;
const cls = String(classParam).replace(/^class-/, '');
const quizzes = (await getCollection('quizzes')).filter((q: any) => String(q.data.class) === cls);

// Group by subject
const bySubject = new Map<string, { count: number; questions: number; minutes: number }>();
quizzes.forEach((q: any) => {
  const subj = quizSubjectName(q.data.subject);
  if (!bySubject.has(subj)) bySubject.set(subj, { count: 0, questions: 0, minutes: 0 });
  const s = bySubject.get(subj)!;
  s.count++;
  s.questions += q.data.questions?.length || 0;
  s.minutes += estimatedMinutes(q);
});
const subjects = [...bySubject.entries()]
  .map(([name, v]) => ({ name, slug: subjectSlug(name), ...v }))
  .sort((a, b) => a.name.localeCompare(b.name));

const totalQuestions = quizzes.reduce((n: number, q: any) => n + (q.data.questions?.length || 0), 0);

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  name: `Class ${cls} Practice Quizzes`,
  description: `Interactive MCQ quizzes for Class ${cls}. ${quizzes.length} quizzes, ${subjects.length} subjects, ${totalQuestions}+ questions.`,
};
---
<BaseLayout
  title={`Class ${cls} Practice Quizzes — MCQ Tests for All Subjects | Parhayi`}
  description={`Free interactive MCQ quizzes for Class ${cls}. ${quizzes.length} quizzes across ${subjects.length} subjects — instant feedback, no sign-up.`}
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
        {quizzes.length} interactive quizzes across {subjects.length} subjects. {totalQuestions} practice questions — all free.
      </p>
      <dl class="mt-10 flex flex-wrap gap-x-12 gap-y-4">
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Quizzes</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{quizzes.length}</dd>
        </div>
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Subjects</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{subjects.length}</dd>
        </div>
        <div>
          <dt class="text-[10px] font-bold uppercase tracking-[0.12em] text-slate-400">Questions</dt>
          <dd class="mt-1 font-display text-2xl font-extrabold tracking-tight text-slate-900">{totalQuestions}</dd>
        </div>
      </dl>
    </div>
  </section>

  <section class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
    <div class="mb-8">
      <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Choose a subject</h2>
      <p class="mt-1.5 text-sm text-slate-500">Every subject has its own set of practice quizzes.</p>
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
                  {s.count} {s.count === 1 ? 'quiz' : 'quizzes'} · {s.questions} questions
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
        <h2>Class {cls} practice quizzes</h2>
        <p>These quizzes cover the full Class {cls} syllabus for the Pakistani board system. Each one is short enough to finish in a study break, and detailed enough to actually find your weak spots.</p>
        <h3>How to use these quizzes</h3>
        <ul>
          <li><strong>Before exams</strong> — work through the quizzes for each subject to find topics you've forgotten</li>
          <li><strong>After reading notes</strong> — verify you've actually understood the material</li>
          <li><strong>Weekly</strong> — revisit quizzes you did well on to keep the material fresh</li>
        </ul>
        <p>Every quiz gives instant feedback — you see the correct answer right away, so you learn as you go.</p>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ /quizzes/[class]"

# ═════════════════════════════════════════════════════════
#  5. /quizzes/[class]/[subject] — quiz list
# ═════════════════════════════════════════════════════════
cat > 'src/pages/quizzes/[class]/[subject].astro' <<'ASTRO'
---
import BaseLayout from '../../../../layouts/BaseLayout.astro';
import Icon from '../../../../components/Icon.astro';
import SubjectIcon from '../../../../components/SubjectIcon.astro';
import { url } from '../../../../lib/url';
import { getCollection } from 'astro:content';
import { quizSubjectName, subjectSlug, estimatedMinutes } from '../../../../lib/quizMeta';

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

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  name: `Class ${cls} ${subjectName} Quizzes`,
  description: `${quizzes.length} interactive MCQ quizzes for Class ${cls} ${subjectName}. ${totalQuestions} practice questions with instant feedback.`,
};
---
<BaseLayout
  title={`Class ${cls} ${subjectName} Quizzes — Interactive MCQs | Parhayi`}
  description={`Free interactive ${subjectName} quizzes for Class ${cls}. ${quizzes.length} quizzes, ${totalQuestions} questions. Instant feedback, no sign-up.`}
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
          <p class="mt-2 text-sm text-slate-500">Class {cls} · {quizzes.length} {quizzes.length === 1 ? 'quiz' : 'quizzes'} · {totalQuestions} questions</p>
        </div>
      </div>
    </div>
  </section>

  <section class="mx-auto max-w-[1200px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
    <div class="mb-8">
      <h2 class="font-display text-2xl font-extrabold tracking-tight text-slate-900">Available quizzes</h2>
      <p class="mt-1.5 text-sm text-slate-500">Pick any quiz to start. Total practice time: ~{totalMinutes} minutes.</p>
    </div>

    <div class="grid grid-cols-1 gap-px overflow-hidden rounded-2xl border border-slate-200 bg-slate-200 sm:grid-cols-2">
      {quizzes.map((q: any) => {
        const n = q.data.questions?.length || 0;
        const mins = estimatedMinutes(q);
        return (
          <a href={url(`/quiz/${q.id}`)} class="group relative flex flex-col bg-white p-6 transition-colors hover:bg-slate-50">
            <h3 class="font-display text-[18px] font-extrabold leading-snug tracking-tight text-slate-900">
              {q.data.title}
            </h3>
            <p class="mt-2 text-[13px] text-slate-500">
              {n} {n === 1 ? 'question' : 'questions'} · ~{mins} min
            </p>
            <div class="mt-6 flex items-center gap-1.5 text-[11px] font-bold uppercase tracking-[0.08em] text-slate-400 transition-colors group-hover:text-[#1d4ed8]">
              Start quiz
              <Icon name="arrow-right" size={11} strokeWidth={2.6} />
            </div>
          </a>
        );
      })}
    </div>
  </section>

  <section class="border-t border-slate-200 bg-white">
    <div class="mx-auto max-w-[820px] px-5 py-16 sm:px-7 lg:px-10">
      <div class="prose">
        <h2>About these {subjectName} quizzes</h2>
        <p>Each quiz focuses on a specific chapter or topic within the Class {cls} {subjectName} syllabus. They're designed to test understanding, not memorisation — the kind of MCQs you'll see in your board exam.</p>
        <h3>How to use these quizzes</h3>
        <ul>
          <li><strong>Take them in order</strong> if you're revising from the start</li>
          <li><strong>Pick by topic</strong> if you want to focus on a specific weak point</li>
          <li><strong>Repeat any quiz</strong> as often as you like — the score helps you track improvement</li>
        </ul>
        <p>Every question gives instant feedback so you learn from both right and wrong answers.</p>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO
echo "  ✓ /quizzes/[class]/[subject]"

# ═════════════════════════════════════════════════════════
#  6. /quiz/[id] — quiz player (moved from /quizzes/[id])
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
    about: { '@type': 'Thing', name: subj },
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
  title={`${d.title} — Interactive Quiz | Parhayi`}
  description={`Take the free ${d.title} — ${n} MCQs with instant feedback. Class ${cls} ${subj}. No sign-up required.`}
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
          <h1 class="font-display text-3xl font-extrabold leading-tight tracking-tight text-slate-900 sm:text-4xl">
            {d.title}
          </h1>
          <p class="mt-2 text-sm text-slate-500">
            Class {cls} · {subj} · {n} {n === 1 ? 'question' : 'questions'} · ~{mins} min
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
          <li>Read every option before choosing — the trickiest MCQs have two very similar options</li>
          <li>You'll see the correct answer right away, so pay attention to <em>why</em> you got it wrong</li>
          <li>Retake the quiz after a day or two — that's when the material really sticks</li>
          <li>Use the keyboard shortcuts (A/B/C/D or 1/2/3/4) if you're on a desktop</li>
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
#  7. Update all internal links /quizzes/[id] → /quiz/[id]
# ═════════════════════════════════════════════════════════
echo ""
echo "▸ 7. Updating internal links..."

# Search index
python3 <<'PY'
import pathlib
p = pathlib.Path('src/pages/search-index.json.ts')
if p.exists():
    s = p.read_text()
    s = s.replace("/quizzes/${q.id}", "/quiz/${q.id}")
    p.write_text(s)
    print('  ✓ search-index.json.ts')
PY

# Update related-content references
find src -name "*.astro" -type f | while read f; do
  if grep -q 'url(`/quizzes/\${' "$f" 2>/dev/null; then
    sed -i "s|url(\`/quizzes/\${\(q\|quiz\)\.id}|url(\`/quiz/\${\1.id}|g" "$f"
    echo "  ✓ $f"
  fi
done

# Update the QuizPlayer reference in board/class/subject hubs
grep -rl '/quizzes/' src/pages/board 2>/dev/null | while read f; do
  sed -i "s|\`/quizzes/\${\(q\|quiz\|item\)\.id}\`|\`/quiz/\${\1.id}\`|g" "$f" || true
done

echo "  ✓ Done"

# ═════════════════════════════════════════════════════════
#  8. Rebuild
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
echo "  Check on mobile:"
echo "    /My-edu-site/quizzes/"
echo "    /My-edu-site/quizzes/class-9/"
echo "    /My-edu-site/quizzes/class-9/physics/"
echo "    /My-edu-site/quiz/physics-9-ch1-quiz/"
echo ""
echo "  Design system (matches books):"
echo "    · Editorial hero with stat row (dl/dt/dd)"
echo "    · Seamed card grids (gap-px bg-slate-200)"
echo "    · Quiet hovers (slate-50 tint + arrow slide)"
echo "    · Blue reserved for CTA only"
echo "    · One accent color throughout"
echo ""
echo "  SEO:"
echo "    · Unique titles per class + subject page"
echo "    · BreadcrumbList + Quiz schema"
echo "    · 200+ words unique copy per page"
echo "    · Clean URL hierarchy"
echo ""
echo "  Push when happy:"
echo "    git add . && git commit -m 'Quizzes: full editorial build' && git push"
echo ""
echo "  Revert: git checkout backup-pre-quizzes"
echo "════════════════════════════════════════════════════════"