export const BOARDS = [
  { slug: 'punjab',      name: 'Punjab',      full: 'Punjab Boards',           short: 'Punjab' },
  { slug: 'federal',     name: 'Federal',     full: 'Federal Board (FBISE)',   short: 'Federal' },
  { slug: 'kpk',         name: 'KPK',         full: 'Khyber Pakhtunkhwa Boards', short: 'KPK' },
  { slug: 'sindh',       name: 'Sindh',       full: 'Sindh Boards',            short: 'Sindh' },
  { slug: 'balochistan', name: 'Balochistan', full: 'Balochistan Boards',      short: 'Balochistan' },
  { slug: 'ajk',         name: 'AJK',         full: 'AJK Boards',              short: 'AJK' },
];

export function boardBySlug(slug: string) {
  return BOARDS.find(b => b.slug === slug);
}

export function boardByName(name: string) {
  return BOARDS.find(b => b.name === name);
}

// Given a content item, work out which boards it belongs to.
// Priority: `boards` array → `board` string → all boards.
export function itemBoards(data: any): string[] {
  if (Array.isArray(data?.boards) && data.boards.length) return data.boards;
  if (typeof data?.board === 'string' && data.board) {
    if (data.board === 'All Boards' || data.board === 'All') return BOARDS.map(b => b.name);
    return [data.board];
  }
  return BOARDS.map(b => b.name);
}

export function matchesBoard(data: any, boardName: string): boolean {
  return itemBoards(data).includes(boardName);
}

export const SUBJECTS = [
  'Mathematics', 'Physics', 'Chemistry', 'Biology',
  'English', 'Urdu', 'Islamiat', 'Pakistan Studies',
  'Computer Science',
];

export const CLASSES = ['9', '10', '11', '12'];
export const BOOK_CLASSES = ['1','2','3','4','5','6','7','8','9','10','11','12'];

export const CONTENT_TYPES = [
  { slug: 'notes',            label: 'Notes',            icon: 'file-text',     plural: 'notes' },
  { slug: 'quizzes',          label: 'Quizzes',          icon: 'circle-help',   plural: 'quizzes' },
  { slug: 'books',            label: 'Books',            icon: 'book-marked',   plural: 'books' },
  { slug: 'past-papers',      label: 'Past Papers',      icon: 'scroll-text',   plural: 'past papers' },
  { slug: 'guess-papers',     label: 'Guess Papers',     icon: 'sparkles',      plural: 'guess papers' },
  { slug: 'pairing-schemes',  label: 'Pairing Schemes',  icon: 'list',          plural: 'pairing schemes' },
  { slug: 'gazettes',         label: 'Result Gazettes',  icon: 'newspaper',     plural: 'gazettes' },
];


// The 9 Punjab Boards of Intermediate and Secondary Education (BISEs)
// All operate under the Punjab Boards Committee of Chairpersons (PBCC)
// — same syllabus, same paper pattern, different questions each year.
export const PUNJAB_BISES = [
  { slug: 'lahore',      name: 'Lahore',      short: 'LHR' },
  { slug: 'gujranwala',  name: 'Gujranwala',  short: 'GUJ' },
  { slug: 'multan',      name: 'Multan',      short: 'MTN' },
  { slug: 'faisalabad',  name: 'Faisalabad',  short: 'FBD' },
  { slug: 'rawalpindi',  name: 'Rawalpindi',  short: 'RWP' },
  { slug: 'sargodha',    name: 'Sargodha',    short: 'SGD' },
  { slug: 'bahawalpur',  name: 'Bahawalpur',  short: 'BWP' },
  { slug: 'dg-khan',     name: 'DG Khan',     short: 'DGK' },
  { slug: 'sahiwal',     name: 'Sahiwal',     short: 'SWL' },
];

export const PUNJAB_BISE_NAMES = PUNJAB_BISES.map(b => b.name);

export function biseBySlug(slug: string) {
  return PUNJAB_BISES.find(b => b.slug === slug);
}
