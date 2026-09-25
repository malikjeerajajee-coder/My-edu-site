export const prerender = true;
import { getCollection } from 'astro:content';

interface Doc {
  id: string;
  type: 'note' | 'quiz' | 'book' | 'past-paper' | 'guess-paper' | 'pairing-scheme' | 'gazette';
  title: string;
  url: string;
  subject?: string;
  class?: string;
  board?: string;
  bise?: string;
  year?: number;
}

export async function GET() {
  const base = import.meta.env.BASE_URL.replace(/\/+$/, '');

  const [notes, quizzes, books, gazettes, pastPapers, guessPapers, pairingSchemes] =
    await Promise.all([
      getCollection('notes'),
      getCollection('quizzes'),
      getCollection('books'),
      getCollection('gazettes'),
      getCollection('pastPapers'),
      getCollection('guessPapers'),
      getCollection('pairingSchemes'),
    ]);

  const docs: Doc[] = [
    ...notes.map((n: any) => ({
      id: `note:${n.id}`,
      type: 'note' as const,
      title: n.data.title,
      url: `${base}/notes/${n.id}/`,
      subject: n.data.subject,
      class: n.data.class,
    })),
    ...quizzes.map((q: any) => ({
      id: `quiz:${q.id}`,
      type: 'quiz' as const,
      title: q.data.title,
      url: `${base}/quiz/${q.id}/`,
      subject: q.data.subject,
      class: q.data.class,
    })),
    ...books.map((b: any) => ({
      id: `book:${b.id}`,
      type: 'book' as const,
      title: b.data.title,
      url: `${base}/books/${b.id}/`,
      subject: b.data.subject,
      class: b.data.class,
      board: (b.data.boards || [])[0],
    })),
    ...gazettes.map((g: any) => ({
      id: `gazette:${g.id}`,
      type: 'gazette' as const,
      title: g.data.title,
      url: `${base}/gazettes/${g.id}/`,
      class: g.data.class,
      board: (g.data.boards || [])[0],
      bise: g.data.bise,
      year: g.data.year,
    })),
    ...pastPapers.map((p: any) => ({
      id: `past-paper:${p.id}`,
      type: 'past-paper' as const,
      title: p.data.title,
      url: `${base}/past-papers/${p.id}/`,
      subject: p.data.subject,
      class: p.data.class,
      board: (p.data.boards || [])[0],
      bise: p.data.bise,
      year: p.data.year,
    })),
    ...guessPapers.map((p: any) => ({
      id: `guess-paper:${p.id}`,
      type: 'guess-paper' as const,
      title: p.data.title,
      url: `${base}/guess-papers/${p.id}/`,
      subject: p.data.subject,
      class: p.data.class,
      board: (p.data.boards || [])[0],
      year: p.data.year,
    })),
    ...pairingSchemes.map((p: any) => ({
      id: `pairing-scheme:${p.id}`,
      type: 'pairing-scheme' as const,
      title: p.data.title,
      url: `${base}/pairing-schemes/${p.id}/`,
      class: p.data.class,
      board: (p.data.boards || [])[0],
      year: p.data.year,
    })),
  ];

  return new Response(JSON.stringify(docs), {
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'public, max-age=3600',
    },
  });
}
