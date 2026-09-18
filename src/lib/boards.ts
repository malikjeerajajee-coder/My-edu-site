// ═══════════════════════════════════════════════════════════════
//  Complete Pakistan education board structure
// ═══════════════════════════════════════════════════════════════

export interface BISE {
  slug: string;
  name: string;
  short: string;
}

export interface Province {
  slug: string;
  name: string;
  full: string;
  bises: BISE[];
  biseAware: boolean;
}

// ─── Punjab — 9 BISEs ───
export const PUNJAB_BISES: BISE[] = [
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

// ─── Sindh — 5 BISEs ───
export const SINDH_BISES: BISE[] = [
  { slug: 'karachi',     name: 'Karachi',     short: 'KHI' },
  { slug: 'hyderabad',   name: 'Hyderabad',   short: 'HYD' },
  { slug: 'sukkur',      name: 'Sukkur',      short: 'SKR' },
  { slug: 'larkana',     name: 'Larkana',     short: 'LRK' },
  { slug: 'mirpurkhas',  name: 'Mirpurkhas',  short: 'MPK' },
];

// ─── Khyber Pakhtunkhwa — 8 BISEs ───
export const KPK_BISES: BISE[] = [
  { slug: 'peshawar',    name: 'Peshawar',    short: 'PSH' },
  { slug: 'abbottabad',  name: 'Abbottabad',  short: 'ABT' },
  { slug: 'swat',        name: 'Swat',        short: 'SWT' },
  { slug: 'mardan',      name: 'Mardan',      short: 'MRD' },
  { slug: 'malakand',    name: 'Malakand',    short: 'MLK' },
  { slug: 'kohat',       name: 'Kohat',       short: 'KHT' },
  { slug: 'bannu',       name: 'Bannu',       short: 'BNU' },
  { slug: 'di-khan',     name: 'DI Khan',     short: 'DIK' },
];

// ─── Balochistan — 7 BISEs ───
export const BALOCHISTAN_BISES: BISE[] = [
  { slug: 'quetta',      name: 'Quetta',      short: 'QTA' },
  { slug: 'khuzdar',     name: 'Khuzdar',     short: 'KZD' },
  { slug: 'turbat',      name: 'Turbat',      short: 'TRB' },
  { slug: 'loralai',     name: 'Loralai',     short: 'LRL' },
  { slug: 'zhob',        name: 'Zhob',        short: 'ZHB' },
  { slug: 'nasirabad',   name: 'Nasirabad',   short: 'NSR' },
  { slug: 'makran',      name: 'Makran',      short: 'MKR' },
];

// ─── AJK — 3 BISEs ───
export const AJK_BISES: BISE[] = [
  { slug: 'mirpur',      name: 'Mirpur',      short: 'MPR' },
  { slug: 'muzaffarabad',name: 'Muzaffarabad',short: 'MZD' },
  { slug: 'rawalakot',   name: 'Rawalakot',   short: 'RLK' },
];

// ─── Federal — single board ───
export const FEDERAL_BISES: BISE[] = [
  { slug: 'fbise', name: 'Federal Board (FBISE)', short: 'FBISE' },
];

// ═══════════════════════════════════════════════════════════════
//  Provinces
// ═══════════════════════════════════════════════════════════════

export const BOARDS: Province[] = [
  { slug: 'punjab',      name: 'Punjab',      full: 'Punjab Boards',            bises: PUNJAB_BISES,      biseAware: true },
  { slug: 'federal',     name: 'Federal',     full: 'Federal Board (FBISE)',    bises: FEDERAL_BISES,     biseAware: false },
  { slug: 'sindh',       name: 'Sindh',       full: 'Sindh Boards',             bises: SINDH_BISES,       biseAware: true },
  { slug: 'kpk',         name: 'KPK',         full: 'Khyber Pakhtunkhwa Boards',bises: KPK_BISES,         biseAware: true },
  { slug: 'balochistan', name: 'Balochistan', full: 'Balochistan Boards',      bises: BALOCHISTAN_BISES, biseAware: true },
  { slug: 'ajk',         name: 'AJK',         full: 'AJK Boards',               bises: AJK_BISES,         biseAware: true },
];

// ═══════════════════════════════════════════════════════════════
//  Helper functions
// ═══════════════════════════════════════════════════════════════

export function boardBySlug(slug: string): Province | undefined {
  return BOARDS.find(b => b.slug === slug);
}

export function boardByName(name: string): Province | undefined {
  return BOARDS.find(b => b.name === name);
}

export function getBISEsForProvince(slug: string): BISE[] {
  const board = boardBySlug(slug);
  return board ? board.bises : [];
}

export function biseBySlug(provinceSlug: string, biseSlug: string): BISE | undefined {
  return getBISEsForProvince(provinceSlug).find(b => b.slug === biseSlug);
}

export function hasBISEs(slug: string): boolean {
  const board = boardBySlug(slug);
  return board ? board.biseAware : false;
}

// Content item → which province(s) it belongs to
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

// ═══════════════════════════════════════════════════════════════
//  Classes & subjects
// ═══════════════════════════════════════════════════════════════

export const CLASSES = ['1','2','3','4','5','6','7','8','9','10','11','12'];
export const BOOK_CLASSES = ['1','2','3','4','5','6','7','8','9','10','11','12'];
export const EXAM_CLASSES = ['9','10','11','12'];

export const SUBJECTS = [
  'Mathematics', 'Physics', 'Chemistry', 'Biology',
  'English', 'Urdu', 'Islamiat', 'Pakistan Studies', 'Computer Science',
];

export const CONTENT_TYPES = [
  { slug: 'notes',           label: 'Notes',           icon: 'file-text' },
  { slug: 'quizzes',         label: 'Quizzes',         icon: 'circle-help' },
  { slug: 'books',           label: 'Books',           icon: 'book-marked' },
  { slug: 'past-papers',     label: 'Past Papers',     icon: 'scroll-text' },
  { slug: 'guess-papers',    label: 'Guess Papers',    icon: 'sparkles' },
  { slug: 'pairing-schemes', label: 'Pairing Schemes', icon: 'list' },
  { slug: 'gazettes',        label: 'Result Gazettes', icon: 'newspaper' },
];

export const BISE_AWARE_BOARDS = ['punjab', 'sindh', 'kpk', 'balochistan', 'ajk'];
export const BISE_SPECIFIC_TYPES = ['past-papers', 'gazettes'];
export const SHARED_TYPES = ['notes', 'quizzes', 'books', 'guess-papers', 'pairing-schemes'];

export function isBISESpecific(typeSlug: string): boolean {
  return BISE_SPECIFIC_TYPES.includes(typeSlug);
}

export function getBiseByName(name: string, provinceSlug?: string): BISE | undefined {
  if (provinceSlug) {
    return getBISEsForProvince(provinceSlug).find(b => b.name.toLowerCase() === name.toLowerCase());
  }
  for (const board of BOARDS) {
    const found = board.bises.find(b => b.name.toLowerCase() === name.toLowerCase());
    if (found) return found;
  }
  return undefined;
}

export function slugify(s: string): string {
  return s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}
