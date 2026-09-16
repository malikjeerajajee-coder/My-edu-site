import { getCollection } from 'astro:content';

export function slugify(s: string) {
  return s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

const CLASS_ORDER = ['9', '10', '11', '12'];

export async function getAll() {
  const [notes, quizzes, books, gazettes] = await Promise.all([
    getCollection('notes'),
    getCollection('quizzes'),
    getCollection('books'),
    getCollection('gazettes'),
  ]);
  return { notes, quizzes, books, gazettes };
}

export async function getTaxonomy() {
  const { notes, quizzes, books, gazettes } = await getAll();

  const classMap = new Map<string, any>();
  const subjectMap = new Map<string, any>();

  const ensureClass = (cls: string) => {
    if (!classMap.has(cls)) classMap.set(cls, { notes: [], quizzes: [], books: [], gazettes: [], subjects: new Set<string>() });
    return classMap.get(cls);
  };
  const ensureSubject = (subj: string) => {
    if (!subjectMap.has(subj)) subjectMap.set(subj, { notes: [], quizzes: [], books: [], classes: new Set<string>() });
    return subjectMap.get(subj);
  };

  notes.forEach((n: any) => {
    ensureClass(n.data.class).notes.push(n);
    ensureClass(n.data.class).subjects.add(n.data.subject);
    ensureSubject(n.data.subject).notes.push(n);
    ensureSubject(n.data.subject).classes.add(n.data.class);
  });
  quizzes.forEach((q: any) => {
    ensureClass(q.data.class).quizzes.push(q);
    ensureClass(q.data.class).subjects.add(q.data.subject);
    ensureSubject(q.data.subject).quizzes.push(q);
    ensureSubject(q.data.subject).classes.add(q.data.class);
  });
  books.forEach((b: any) => {
    ensureClass(b.data.class).books.push(b);
    ensureClass(b.data.class).subjects.add(b.data.subject);
    ensureSubject(b.data.subject).books.push(b);
    ensureSubject(b.data.subject).classes.add(b.data.class);
  });
  gazettes.forEach((g: any) => {
    ensureClass(g.data.class).gazettes.push(g);
  });

  const classes = [...classMap.entries()]
    .map(([cls, v]: [string, any]) => ({
      class: cls,
      notes: v.notes,
      quizzes: v.quizzes,
      books: v.books,
      gazettes: v.gazettes,
      subjects: [...v.subjects].sort(),
      total: v.notes.length + v.quizzes.length + v.books.length + v.gazettes.length,
    }))
    .sort((a, b) => {
      const ai = CLASS_ORDER.indexOf(a.class), bi = CLASS_ORDER.indexOf(b.class);
      if (ai === -1 && bi === -1) return Number(a.class) - Number(b.class);
      if (ai === -1) return 1;
      if (bi === -1) return -1;
      return ai - bi;
    });

  const subjects = [...subjectMap.entries()]
    .map(([subject, v]: [string, any]) => ({
      subject,
      notes: v.notes,
      quizzes: v.quizzes,
      books: v.books,
      classes: [...v.classes].sort((a: string, b: string) => Number(a) - Number(b)),
      total: v.notes.length + v.quizzes.length + v.books.length,
    }))
    .sort((a, b) => a.subject.localeCompare(b.subject));

  return { classes, subjects };
}

export async function getClassList() {
  const { notes, quizzes, books, gazettes } = await getAll();
  const set = new Set<string>();
  [...notes, ...quizzes, ...books, ...gazettes].forEach((x: any) => set.add(x.data.class));
  return [...set].sort((a, b) => {
    const ai = CLASS_ORDER.indexOf(a), bi = CLASS_ORDER.indexOf(b);
    if (ai === -1 && bi === -1) return Number(a) - Number(b);
    if (ai === -1) return 1;
    if (bi === -1) return -1;
    return ai - bi;
  });
}

export async function getClassContent(cls: string) {
  const { notes, quizzes, books, gazettes } = await getAll();
  const cNotes = notes.filter((n: any) => n.data.class === cls);
  const cQuizzes = quizzes.filter((q: any) => q.data.class === cls);
  const cBooks = books.filter((b: any) => b.data.class === cls);
  const cGazettes = gazettes.filter((g: any) => g.data.class === cls);

  const subjectMap = new Map<string, any>();
  const ensure = (s: string) => {
    if (!subjectMap.has(s)) subjectMap.set(s, { notes: [], quizzes: [], books: [] });
    return subjectMap.get(s);
  };
  cNotes.forEach((n: any) => ensure(n.data.subject).notes.push(n));
  cQuizzes.forEach((q: any) => ensure(q.data.subject).quizzes.push(q));
  cBooks.forEach((b: any) => ensure(b.data.subject).books.push(b));

  const subjects = [...subjectMap.entries()]
    .map(([subject, v]: [string, any]) => ({
      subject,
      slug: slugify(subject),
      notes: v.notes,
      quizzes: v.quizzes,
      books: v.books,
      total: v.notes.length + v.quizzes.length + v.books.length,
    }))
    .sort((a, b) => a.subject.localeCompare(b.subject));

  return {
    class: cls,
    notes: cNotes,
    quizzes: cQuizzes,
    books: cBooks,
    gazettes: cGazettes,
    subjects,
    total: cNotes.length + cQuizzes.length + cBooks.length + cGazettes.length,
  };
}

export const AVAILABLE_CLASSES = CLASS_ORDER;
