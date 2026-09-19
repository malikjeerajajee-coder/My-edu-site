export const prerender = true;

import { getCollection } from 'astro:content';

const base = (import.meta.env.BASE_URL || '/').replace(/\/+$/, '');

export async function GET() {
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

  const index = [
    ...notes.map((n: any) => ({ type: 'note', title: n.data.title, url: `${base}/notes/${n.id}`, subject: n.data.subject, class: n.data.class })),
    ...quizzes.map((q: any) => ({ type: 'quiz', title: q.data.title, url: `${base}/quizzes/${q.id}`, subject: q.data.subject, class: q.data.class })),
    ...books.map((b: any) => ({ type: 'book', title: b.data.title, url: `${base}/books/${b.id}`, subject: b.data.subject, class: b.data.class })),
    ...gazettes.map((g: any) => ({ type: 'gazette', title: g.data.title, url: `${base}/gazettes/${g.id}`, subject: g.data.board, class: g.data.class })),
    ...pastPapers.map((p: any) => ({ type: 'past-paper', title: p.data.title, url: `${base}/past-papers/${p.id}`, subject: p.data.subject, class: p.data.class })),
    ...guessPapers.map((p: any) => ({ type: 'guess-paper', title: p.data.title, url: `${base}/guess-papers/${p.id}`, subject: p.data.subject, class: p.data.class })),
    ...pairingSchemes.map((p: any) => ({ type: 'pairing-scheme', title: p.data.title, url: `${base}/pairing-schemes/${p.id}`, subject: '', class: p.data.class })),
  ];

  return new Response(JSON.stringify(index), {
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
  });
}
