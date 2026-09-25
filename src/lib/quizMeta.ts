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
