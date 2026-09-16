export const prerender = true;
import { getCollection } from 'astro:content';

export async function GET() {
  const [notes, quizzes, books, gazettes] = await Promise.all([
    getCollection('notes'),
    getCollection('quizzes'),
    getCollection('books'),
    getCollection('gazettes'),
  ]);
  const index = [
    ...notes.map(n => ({ type: 'note', title: n.data.title, url: `/notes/${n.id}`, subject: n.data.subject, class: n.data.class })),
    ...quizzes.map(q => ({ type: 'quiz', title: q.data.title, url: `/quizzes/${q.id}`, subject: q.data.subject, class: q.data.class })),
    ...books.map(b => ({ type: 'book', title: b.data.title, url: `/books/${b.id}`, subject: b.data.subject, class: b.data.class })),
    ...gazettes.map(g => ({ type: 'gazette', title: g.data.title, url: `/gazettes/${g.id}`, subject: g.data.board, class: g.data.class })),
  ];
  return new Response(JSON.stringify(index), {
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
  });
}
