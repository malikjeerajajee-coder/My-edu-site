import type { CollectionEntry } from 'astro:content';

const BOARD_META: Record<string, {
  slug: string;
  fullName: string;
  province: string;
  abbreviation: string;
  authority: string;
  description: string;
}> = {
  'Punjab': {
    slug: 'punjab',
    fullName: 'Punjab Textbook Board',
    province: 'Punjab',
    abbreviation: 'PTB / PCTB',
    authority: 'Punjab Curriculum and Textbook Board (PCTB)',
    description: 'The Punjab Textbook Board (PTB), also known as the Punjab Curriculum and Textbook Board (PCTB), publishes official textbooks for all schools in Punjab, from Class 1 through Class 12. These books follow the Single National Curriculum (SNC) framework.',
  },
  'Federal': {
    slug: 'federal',
    fullName: 'Federal Board (FBISE)',
    province: 'Federal',
    abbreviation: 'FBISE',
    authority: 'Federal Board of Intermediate and Secondary Education (FBISE)',
    description: 'FBISE publishes textbooks for federal government schools, cadet colleges, and Pakistani schools overseas. The curriculum is slightly more analytical than provincial boards, with emphasis on conceptual understanding.',
  },
  'Sindh': {
    slug: 'sindh',
    fullName: 'Sindh Textbook Board',
    province: 'Sindh',
    abbreviation: 'STBB',
    authority: 'Sindh Textbook Board (STBB)',
    description: 'The Sindh Textbook Board (STBB) publishes textbooks for all schools in Sindh, in English, Urdu and Sindhi mediums. Books follow the Single National Curriculum (SNC) with regional adaptations.',
  },
  'Balochistan': {
    slug: 'balochistan',
    fullName: 'Balochistan Textbook Board',
    province: 'Balochistan',
    abbreviation: 'BTBB',
    authority: 'Balochistan Textbook Board (BTBB)',
    description: 'The Balochistan Textbook Board (BTBB) publishes official textbooks for all schools in Balochistan. Books are available in English and Urdu mediums.',
  },
  'KPK': {
    slug: 'kpk',
    fullName: 'Khyber Pakhtunkhwa Textbook Board',
    province: 'KPK',
    abbreviation: 'KPTBB',
    authority: 'Khyber Pakhtunkhwa Textbook Board (KPTBB)',
    description: 'The Khyber Pakhtunkhwa Textbook Board publishes official textbooks for schools in KPK.',
  },
  'AJK': {
    slug: 'ajk',
    fullName: 'AJK Textbook Board',
    province: 'AJK',
    abbreviation: 'AJKTB',
    authority: 'AJK Textbook Board',
    description: 'The AJK Textbook Board publishes official textbooks for schools in Azad Jammu and Kashmir.',
  },
};

export function boardMeta(boardName: string) {
  return BOARD_META[boardName] || {
    slug: boardName.toLowerCase(),
    fullName: `${boardName} Textbook Board`,
    province: boardName,
    abbreviation: boardName,
    authority: `${boardName} Textbook Board`,
    description: `Official textbooks published by the ${boardName} Textbook Board for Pakistani schools.`,
  };
}

export function classLabel(cls: string): string {
  return `Class ${cls}`;
}

export function subjectSlug(subject: string): string {
  return subject
    .toLowerCase()
    .replace(/\(.*?\)/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
}

export function bookSubjectName(subject: string): string {
  return subject.replace(/\s*\([^)]*\)\s*/g, '').trim();
}

// Build a book's SEO title / description
export function bookSeoTitle(book: CollectionEntry<'books'>): string {
  const d = book.data;
  const board = boardMeta((d.boards || [])[0] || 'Punjab');
  const medium = d.medium === 'english' ? 'English Medium'
    : d.medium === 'urdu' ? 'Urdu Medium'
    : d.medium === 'sindhi' ? 'Sindhi Medium'
    : '';
  const year = d.year ? ` (${d.year})` : '';
  const subj = bookSubjectName(d.subject);
  return `${subj} Class ${d.class} Textbook — ${board.abbreviation}${medium ? ' ' + medium : ''}${year} | Parhayi`;
}

export function bookSeoDescription(book: CollectionEntry<'books'>): string {
  const d = book.data;
  const board = boardMeta((d.boards || [])[0] || 'Punjab');
  const subj = bookSubjectName(d.subject);
  const medium = d.medium === 'english' ? 'English medium'
    : d.medium === 'urdu' ? 'Urdu medium'
    : d.medium === 'sindhi' ? 'Sindhi medium'
    : '';
  const year = d.year ? `${d.year} edition` : 'current edition';
  return `Download the free PDF of ${subj} Class ${d.class} textbook — published by ${board.fullName}${medium ? ', ' + medium : ''}. ${year}. No sign-up, no ads.`;
}

// Board-level SEO
export function boardSeo(boardName: string, classes: string[], totalBooks: number) {
  const board = boardMeta(boardName);
  return {
    title: `${board.province} Textbooks — Class 1 to 12 Free PDF | ${board.abbreviation} | Parhayi`,
    description: `Download all ${board.abbreviation} textbooks for free — Classes ${classes[0]} to ${classes[classes.length - 1]}, all subjects. ${totalBooks} books available. ${board.description.split('.')[0]}.`,
    heading: `${board.province} Textbooks`,
    lede: board.description,
  };
}

// Class-level SEO
export function classSeo(boardName: string, cls: string, subjects: string[], totalBooks: number) {
  const board = boardMeta(boardName);
  const subjectList = subjects.slice(0, 6).join(', ');
  return {
    title: `Class ${cls} ${board.province} Textbooks — All Subjects | ${board.abbreviation} | Parhayi`,
    description: `Free Class ${cls} textbook PDFs from ${board.fullName} — ${subjectList}${subjects.length > 6 ? ', and more' : ''}. ${totalBooks} books, one click download.`,
    heading: `Class ${cls} Textbooks — ${board.province} Board`,
    lede: `All ${totalBooks} Class ${cls} textbooks from ${board.authority}. Download any book as a free PDF.`,
  };
}
