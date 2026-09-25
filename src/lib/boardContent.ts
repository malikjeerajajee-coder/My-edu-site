import { getCollection } from 'astro:content';
import { BOARDS, itemBoards, boardBySlug, CLASSES, CONTENT_TYPES, SUBJECTS } from './boards';

export function slugify(s: string) {
  return s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

async function loadAll() {
  const [notes, quizzes, books, gazettes, pastPapers, guessPapers, pairingSchemes] = await Promise.all([
    getCollection('notes'),
    getCollection('quizzes'),
    getCollection('books'),
    getCollection('gazettes'),
    getCollection('pastPapers'),
    getCollection('guessPapers'),
    getCollection('pairingSchemes'),
  ]);
  return { notes, quizzes, books, gazettes, pastPapers, guessPapers, pairingSchemes };
}

export async function getBoardCounts() {
  const all = await loadAll();
  const counts: Record<string, number> = {};
  for (const b of BOARDS) {
    let n = 0;
    for (const coll of Object.values(all)) {
      n += coll.filter((i: any) => itemBoards(i.data).includes(b.name)).length;
    }
    counts[b.slug] = n;
  }
  return counts;
}

export async function getBoardContent(boardSlug: string) {
  const board = boardBySlug(boardSlug);
  if (!board) return null;
  const all = await loadAll();

  const filter = (items: any[]) => items.filter((i: any) => itemBoards(i.data).includes(board.name));

  const notes = filter(all.notes);
  const quizzes = filter(all.quizzes);
  const books = filter(all.books);
  const gazettes = filter(all.gazettes);
  const pastPapers = filter(all.pastPapers);
  const guessPapers = filter(all.guessPapers);
  const pairingSchemes = filter(all.pairingSchemes);

  // All classes that have any content under this board
  const classSet = new Set<string>();
  [...notes, ...quizzes, ...books, ...gazettes, ...pastPapers, ...guessPapers, ...pairingSchemes]
    .forEach((i: any) => classSet.add(i.data.class));
  const classes = [...classSet].sort((a, b) => Number(a) - Number(b));

  return {
    board,
    notes, quizzes, books, gazettes,
    pastPapers, guessPapers, pairingSchemes,
    classes,
    total: notes.length + quizzes.length + books.length + gazettes.length + pastPapers.length + guessPapers.length + pairingSchemes.length,
  };
}

export async function getClassContent(boardSlug: string, cls: string) {
  const board = boardBySlug(boardSlug);
  if (!board) return null;
  const all = await loadAll();
  const match = (i: any) => itemBoards(i.data).includes(board.name) && i.data.class === cls;

  const notes = all.notes.filter(match);
  const quizzes = all.quizzes.filter(match);
  const books = all.books.filter(match);
  const gazettes = all.gazettes.filter(match);
  const pastPapers = all.pastPapers.filter(match);
  const guessPapers = all.guessPapers.filter(match);
  const pairingSchemes = all.pairingSchemes.filter(match);

  // Subject set for this class
  const subjectSet = new Set<string>();
  [...notes, ...quizzes, ...books, ...pastPapers, ...guessPapers]
    .forEach((i: any) => subjectSet.add(i.data.subject));
  const subjects = [...subjectSet].sort();

  return {
    board, class: cls,
    notes, quizzes, books, gazettes,
    pastPapers, guessPapers, pairingSchemes,
    subjects,
    total: notes.length + quizzes.length + books.length + gazettes.length + pastPapers.length + guessPapers.length + pairingSchemes.length,
  };
}

export async function getSubjectContent(boardSlug: string, cls: string, subjectSlug: string) {
  const board = boardBySlug(boardSlug);
  if (!board) return null;
  const all = await loadAll();
  const match = (i: any) =>
    itemBoards(i.data).includes(board.name) &&
    i.data.class === cls &&
    i.data.subject &&
    slugify(i.data.subject) === subjectSlug;

  const notes = all.notes.filter(match);
  const quizzes = all.quizzes.filter(match);
  const books = all.books.filter(match);
  const pastPapers = all.pastPapers.filter(match);
  const guessPapers = all.guessPapers.filter(match);

  const displayName = (notes[0] || quizzes[0] || books[0] || pastPapers[0] || guessPapers[0])?.data?.subject || subjectSlug;

  return { board, class: cls, subject: displayName, subjectSlug, notes, quizzes, books, pastPapers, guessPapers };
}

export async function getAllBoardPaths() {
  const paths: { board: string }[] = BOARDS.map(b => ({ board: b.slug }));
  return paths;
}

export async function getAllClassPaths() {
  const all = await loadAll();
  const seen = new Set<string>();
  const paths: { board: string; class: string }[] = [];
  for (const b of BOARDS) {
    for (const coll of Object.values(all)) {
      for (const i of coll as any[]) {
        if (itemBoards(i.data).includes(b.name)) {
          const key = b.slug + '/' + i.data.class;
          if (!seen.has(key)) { seen.add(key); paths.push({ board: b.slug, class: i.data.class }); }
        }
      }
    }
  }
  return paths;
}

export async function getAllSubjectPaths() {
  const all = await loadAll();
  const seen = new Set<string>();
  const paths: { board: string; class: string; subject: string }[] = [];
  for (const b of BOARDS) {
    for (const coll of Object.values(all)) {
      for (const i of coll as any[]) {
        if (i.data.subject && itemBoards(i.data).includes(b.name)) {
          const subj = slugify(i.data.subject);
          const key = b.slug + '/' + i.data.class + '/' + subj;
          if (!seen.has(key)) { seen.add(key); paths.push({ board: b.slug, class: i.data.class, subject: subj }); }
        }
      }
    }
  }
  return paths;
}

export { CLASSES, SUBJECTS, CONTENT_TYPES, BOARDS };


const TYPE_MAP: Record<string, { label: string; icon: string; collection: string; base: string }> = {
  'notes':            { label: 'Notes',           icon: 'file-text',     collection: 'notes',           base: '/notes' },
  'quizzes':          { label: 'Quizzes',         icon: 'circle-help',   collection: 'quizzes',         base: '/quizzes' },
  'books':            { label: 'Books',           icon: 'book-marked',   collection: 'books',           base: '/textbook' },
  'past-papers':      { label: 'Past Papers',     icon: 'scroll-text',   collection: 'pastPapers',      base: '/past-papers' },
  'guess-papers':     { label: 'Guess Papers',    icon: 'sparkles',      collection: 'guessPapers',     base: '/guess-papers' },
  'pairing-schemes':  { label: 'Pairing Schemes', icon: 'list',          collection: 'pairingSchemes',  base: '/pairing-schemes' },
  'gazettes':         { label: 'Result Gazettes', icon: 'newspaper',     collection: 'gazettes',        base: '/gazettes' },
};

export const TYPE_SLUGS = Object.keys(TYPE_MAP);

export async function getClassTypeContent(boardSlug: string, cls: string, typeSlug: string) {
  const board = boardBySlug(boardSlug);
  const cfg = TYPE_MAP[typeSlug];
  if (!board || !cfg) return null;

  const all = await loadAll();
  const collection = (all as any)[cfg.collection] as any[];
  const items = collection.filter(
    (i: any) => itemBoards(i.data).includes(board.name) && i.data.class === cls
  );

  // Group by subject when possible (past-papers, notes, quizzes, books, guess-papers)
  const subjectMap = new Map<string, any[]>();
  let hasSubjects = false;
  for (const i of items) {
    if (i.data.subject) {
      hasSubjects = true;
      const key = i.data.subject;
      if (!subjectMap.has(key)) subjectMap.set(key, []);
      subjectMap.get(key)!.push(i);
    }
  }
  const groups = hasSubjects
    ? [...subjectMap.entries()].map(([subject, items]) => ({ subject, items })).sort((a, b) => a.subject.localeCompare(b.subject))
    : null;

  // For year-based types, sort descending
  if (!hasSubjects) {
    items.sort((a: any, b: any) => (b.data.year || 0) - (a.data.year || 0));
  }

  return { board, class: cls, type: typeSlug, ...cfg, items, groups };
}
