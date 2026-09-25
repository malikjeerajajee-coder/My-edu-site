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
