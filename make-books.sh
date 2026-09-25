#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "════════════════════════════════════════════"
echo "  Rebuilding textbooks section"
echo "  · /books                   → board picker"
echo "  · /books/[board]           → class picker"
echo "  · /books/[board]/class-N   → subject list"
echo "  · /textbook/[id]           → book detail"
echo "════════════════════════════════════════════"
echo ""

git branch -f backup-pre-books-section 2>/dev/null || true
echo "  ✓ backup-pre-books-section created"
echo ""

# ═════════════════════════════════════════════════════════
#  1. Add subject icons to Icon.astro
# ═════════════════════════════════════════════════════════
echo "▸ 1. Adding subject icons..."

python3 <<'PY'
import pathlib, re

p = pathlib.Path('src/components/Icon.astro')
s = p.read_text()

new_icons = {
    'feather': "<path d=\"M12.67 19a2 2 0 0 0 1.416-.588l6.154-6.172a6 6 0 0 0-8.49-8.49L5.586 9.914A2 2 0 0 0 5 11.328V18a1 1 0 0 0 1 1z\"/><path d=\"M16 8 2 22\"/><path d=\"M17.5 15H9\"/>",
    'pen-tool': "<path d=\"M15.707 21.293a1 1 0 0 1-1.414 0l-1.586-1.586a1 1 0 0 1 0-1.414l5.586-5.586a1 1 0 0 1 1.414 0l1.586 1.586a1 1 0 0 1 0 1.414z\"/><path d=\"m18 13-1.375-6.874a1 1 0 0 0-.746-.776L3.235 2.028a1 1 0 0 0-1.207 1.207L5.35 15.879a1 1 0 0 0 .776.746L13 18\"/><path d=\"m2.3 2.3 7.286 7.286\"/><circle cx=\"11\" cy=\"11\" r=\"2\"/>",
    'sigma': "<path d=\"M18 7V5a1 1 0 0 0-1-1H6.5a.5.5 0 0 0-.4.8l4.5 6a2 2 0 0 1 0 2.4l-4.5 6a.5.5 0 0 0 .4.8H17a1 1 0 0 0 1-1v-2\"/>",
    'atom': "<circle cx=\"12\" cy=\"12\" r=\"1\"/><path d=\"M20.2 20.2c2.04-2.03.02-7.36-4.5-11.9-4.54-4.52-9.87-6.54-11.9-4.5-2.04 2.03-.02 7.36 4.5 11.9 4.54 4.52 9.87 6.54 11.9 4.5Z\"/><path d=\"M15.7 15.7c4.52-4.54 6.54-9.87 4.5-11.9-2.03-2.04-7.36-.02-11.9 4.5-4.52 4.54-6.54 9.87-4.5 11.9 2.03 2.04 7.36.02 11.9-4.5Z\"/>",
    'flask': "<path d=\"M10 2v7.527a2 2 0 0 1-.211.896L4.72 20.55a1 1 0 0 0 .9 1.45h12.76a1 1 0 0 0 .9-1.45l-5.069-10.127A2 2 0 0 1 14 9.527V2\"/><path d=\"M8.5 2h7\"/><path d=\"M7 16h10\"/>",
    'leaf': "<path d=\"M11 20A7 7 0 0 1 9.8 6.1C15.5 5 17 4.48 19 2c1 2 2 4.18 2 8 0 5.5-4.78 10-10 10Z\"/><path d=\"M2 21c0-3 1.85-5.36 5.08-6C9.5 14.52 12 13 13 12\"/>",
    'cpu': "<rect width=\"16\" height=\"16\" x=\"4\" y=\"4\" rx=\"2\"/><rect width=\"6\" height=\"6\" x=\"9\" y=\"9\" rx=\"1\"/><path d=\"M15 2v2\"/><path d=\"M15 20v2\"/><path d=\"M2 15h2\"/><path d=\"M2 9h2\"/><path d=\"M20 15h2\"/><path d=\"M20 9h2\"/><path d=\"M9 2v2\"/><path d=\"M9 20v2\"/>",
    'star': "<polygon points=\"12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2\"/>",
    'map': "<path d=\"M14.106 5.553a2 2 0 0 0 1.788 0l3.659-1.83A1 1 0 0 1 21 4.619v12.764a1 1 0 0 1-.553.894l-4.553 2.277a2 2 0 0 1-1.788 0l-4.212-2.106a2 2 0 0 0-1.788 0l-3.659 1.83A1 1 0 0 1 3 19.381V6.618a1 1 0 0 1 .553-.894l4.553-2.277a2 2 0 0 1 1.788 0z\"/><path d=\"M15 5.764v15\"/><path d=\"M9 3.236v15\"/>",
    'scroll': "<path d=\"M19 17V5a2 2 0 0 0-2-2H4\"/><path d=\"M8 21h12a2 2 0 0 0 2-2v-1a1 1 0 0 0-1-1H11a1 1 0 0 0-1 1v1a2 2 0 1 1-4 0V5a2 2 0 1 0-4 0v2a1 1 0 0 0 1 1h3\"/>",
    'microscope': "<path d=\"M6 18h8\"/><path d=\"M3 22h18\"/><path d=\"M14 22a7 7 0 1 0 0-14h-1\"/><path d=\"M9 14h2\"/><path d=\"M9 12a2 2 0 0 1-2-2V6h6v4a2 2 0 0 1-2 2Z\"/><path d=\"M12 6V3a1 1 0 0 0-1-1H9a1 1 0 0 0-1 1v3\"/>",
    'lightbulb': "<path d=\"M15 14c.2-1 .7-1.7 1.5-2.5 1-.9 1.5-2.2 1.5-3.5A6 6 0 0 0 6 8c0 1 .2 2.2 1.5 3.5.7.7 1.3 1.5 1.5 2.5\"/><path d=\"M9 18h6\"/><path d=\"M10 22h4\"/>",
    'heart': "<path d=\"M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z\"/>",
    'landmark': "<line x1=\"3\" x2=\"21\" y1=\"22\" y2=\"22\"/><line x1=\"6\" x2=\"6\" y1=\"18\" y2=\"11\"/><line x1=\"10\" x2=\"10\" y1=\"18\" y2=\"11\"/><line x1=\"14\" x2=\"14\" y1=\"18\" y2=\"11\"/><line x1=\"18\" x2=\"18\" y1=\"18\" y2=\"11\"/><polygon points=\"12 2 20 7 4 7\"/>",
    'trending-up': "<polyline points=\"22 7 13.5 15.5 8.5 10.5 2 17\"/><polyline points=\"16 7 22 7 22 13\"/>",
    'bar-chart': "<line x1=\"12\" x2=\"12\" y1=\"20\" y2=\"10\"/><line x1=\"18\" x2=\"18\" y1=\"20\" y2=\"4\"/><line x1=\"6\" x2=\"6\" y1=\"20\" y2=\"16\"/>",
    'brain': "<path d=\"M12 5a3 3 0 1 0-5.997.125 4 4 0 0 0-2.526 5.77 4 4 0 0 0 .556 6.588A4 4 0 1 0 12 18Z\"/><path d=\"M12 5a3 3 0 1 1 5.997.125 4 4 0 0 1 2.526 5.77 4 4 0 0 1-.556 6.588A4 4 0 1 1 12 18Z\"/>",
    'activity': "<path d=\"M22 12h-2.48a2 2 0 0 0-1.93 1.46l-2.35 8.36a.25.25 0 0 1-.48 0L9.24 2.18a.25.25 0 0 0-.48 0l-2.35 8.36A2 2 0 0 1 4.49 12H2\"/>",
    'palette': "<circle cx=\"13.5\" cy=\"6.5\" r=\".5\"/><circle cx=\"17.5\" cy=\"10.5\" r=\".5\"/><circle cx=\"8.5\" cy=\"7.5\" r=\".5\"/><circle cx=\"6.5\" cy=\"12.5\" r=\".5\"/><path d=\"M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10c.926 0 1.648-.746 1.648-1.688 0-.437-.18-.835-.437-1.125-.29-.289-.438-.652-.438-1.125a1.64 1.64 0 0 1 1.668-1.668h1.996c3.051 0 5.555-2.503 5.555-5.554C21.965 6.012 17.461 2 12 2z\"/>",
    'globe': "<circle cx=\"12\" cy=\"12\" r=\"10\"/><path d=\"M12 2a14.5 14.5 0 0 0 0 20 14.5 14.5 0 0 0 0-20\"/><path d=\"M2 12h20\"/>",
    'calculator': "<rect width=\"16\" height=\"20\" x=\"4\" y=\"2\" rx=\"2\"/><line x1=\"8\" x2=\"16\" y1=\"6\" y2=\"6\"/><line x1=\"16\" x2=\"16\" y1=\"14\" y2=\"18\"/><path d=\"M16 10h.01\"/><path d=\"M12 10h.01\"/><path d=\"M8 10h.01\"/><path d=\"M12 14h.01\"/><path d=\"M8 14h.01\"/><path d=\"M12 18h.01\"/><path d=\"M8 18h.01\"/>",
    'book': "<path d=\"M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H19a1 1 0 0 1 1 1v18a1 1 0 0 1-1 1H6.5a1 1 0 0 1 0-5H20\"/>",
    'languages': "<path d=\"m5 8 6 6\"/><path d=\"m4 14 6-6 2-3\"/><path d=\"M2 5h12\"/><path d=\"M7 2h1\"/><path d=\"m22 22-5-10-5 10\"/><path d=\"M14 18h6\"/>",
}

# Find the icons object
match = re.search(r'const icons: Record<string, string> = \{(.*?)\n\};', s, re.DOTALL)
if not match:
    print('  ! Could not find icons object')
    raise SystemExit(0)

block = match.group(1)

# Append new icons not already present
to_add = []
for k, v in new_icons.items():
    if f"'{k}'" not in block and f'"{k}"' not in block:
        to_add.append(f"  '{k}': '{v}',")

if to_add:
    new_block = block.rstrip() + '\n' + '\n'.join(to_add)
    s = s[:match.start()] + 'const icons: Record<string, string> = {' + new_block + '\n};' + s[match.end():]
    p.write_text(s)
    print(f'  ✓ Added {len(to_add)} new icons: {", ".join(new_icons.keys())}')
else:
    print('  · All icons already present')
PY

# ═════════════════════════════════════════════════════════
#  2. Create SubjectIcon.astro mapper
# ═════════════════════════════════════════════════════════
echo ""
echo "▸ 2. Creating SubjectIcon component..."

cat > src/components/SubjectIcon.astro <<'ASTRO'
---
import Icon from './Icon.astro';

interface Props {
  subject: string;
  size?: 'sm' | 'md' | 'lg';
  class?: string;
}

const { subject, size = 'md', class: className = '' } = Astro.props;

// Normalise the subject string: strip medium markers, parens, etc.
const key = subject.toLowerCase()
  .replace(/\(.*?\)/g, '')
  .replace(/[^a-z\s]/g, '')
  .trim();

// Subject → icon + color mapping
const MAP: Record<string, { icon: string; color: string }> = {
  // Languages
  'english':            { icon: 'feather',      color: 'amber' },
  'urdu':               { icon: 'pen-tool',     color: 'teal' },
  'sindhi':             { icon: 'pen-tool',     color: 'teal' },
  'punjabi':            { icon: 'pen-tool',     color: 'teal' },
  'farsi':              { icon: 'pen-tool',     color: 'teal' },
  'arabic':             { icon: 'languages',    color: 'teal' },
  'salees urdu':        { icon: 'pen-tool',     color: 'teal' },
  'gulzar e urdu':      { icon: 'pen-tool',     color: 'teal' },

  // Sciences
  'physics':            { icon: 'atom',         color: 'blue' },
  'chemistry':          { icon: 'flask',        color: 'emerald' },
  'biology':            { icon: 'leaf',         color: 'green' },
  'general science':    { icon: 'microscope',   color: 'sky' },
  'science':            { icon: 'microscope',   color: 'sky' },
  'bio tech':           { icon: 'leaf',         color: 'green' },

  // Math
  'mathematics':        { icon: 'sigma',        color: 'violet' },
  'math':               { icon: 'sigma',        color: 'violet' },
  'riazi':              { icon: 'sigma',        color: 'violet' },
  'statistics':         { icon: 'bar-chart',    color: 'violet' },
  'general mathematics':{ icon: 'sigma',        color: 'violet' },

  // Humanities
  'geography':          { icon: 'map',          color: 'amber' },
  'history':            { icon: 'scroll',       color: 'amber' },
  'islamiat':           { icon: 'star',         color: 'emerald' },
  'islamiyat':          { icon: 'star',         color: 'emerald' },
  'islamic studies':    { icon: 'star',         color: 'emerald' },
  'pakistan studies':   { icon: 'map',          color: 'emerald' },
  'pak study':          { icon: 'map',          color: 'emerald' },
  'mutala e pakistan':  { icon: 'map',          color: 'emerald' },
  'civics':             { icon: 'landmark',     color: 'indigo' },
  'economics':          { icon: 'trending-up',  color: 'amber' },
  'psychology':         { icon: 'brain',        color: 'rose' },
  'nafsiyat':           { icon: 'brain',        color: 'rose' },
  'education':          { icon: 'graduation-cap', color: 'indigo' },
  'ilm ul taleem':      { icon: 'graduation-cap', color: 'indigo' },

  // Religion / Ethics
  'tarjuma tul quran':  { icon: 'book',         color: 'emerald' },
  'translation quran':  { icon: 'book',         color: 'emerald' },
  'tarjuma tul quran majeed': { icon: 'book',   color: 'emerald' },
  'nazra quran':        { icon: 'book',         color: 'emerald' },
  'akhlaqiat':          { icon: 'heart',        color: 'rose' },
  'mazhabi taleemat':   { icon: 'heart',        color: 'rose' },
  'religious studies':  { icon: 'heart',        color: 'rose' },
  'buddhism':           { icon: 'heart',        color: 'rose' },
  'sikhism':            { icon: 'heart',        color: 'rose' },
  'sanatan dharam':     { icon: 'heart',        color: 'rose' },
  'zoroastrian religion': { icon: 'heart',      color: 'rose' },
  'mashi taleem':       { icon: 'heart',        color: 'rose' },

  // Vocational
  'computer science':   { icon: 'cpu',          color: 'cyan' },
  'computer':           { icon: 'cpu',          color: 'cyan' },
  'computer education': { icon: 'cpu',          color: 'cyan' },
  'computer ki taleem': { icon: 'cpu',          color: 'cyan' },
  'computer ji taleem': { icon: 'cpu',          color: 'cyan' },
  'ict':                { icon: 'cpu',          color: 'cyan' },
  'health physical education': { icon: 'activity', color: 'rose' },
  'home economics':     { icon: 'home',         color: 'rose' },
  'art drawing':        { icon: 'palette',      color: 'fuchsia' },
  'general knowledge':  { icon: 'lightbulb',    color: 'amber' },
  'waqfiyat e aama':    { icon: 'lightbulb',    color: 'amber' },
  'muasharti uloom':    { icon: 'globe',        color: 'amber' },
  'social studies':     { icon: 'globe',        color: 'amber' },
};

const cfg = MAP[key] || { icon: 'book', color: 'blue' };

const sizes = {
  sm: { box: '2rem', icon: 14, radius: '8px' },
  md: { box: '2.5rem', icon: 18, radius: '10px' },
  lg: { box: '3rem', icon: 22, radius: '12px' },
};
const s = sizes[size];

const colorMap: Record<string, { bg: string; fg: string; border: string }> = {
  amber:   { bg: '#fef3c7', fg: '#b45309', border: '#fde68a' },
  teal:    { bg: '#ccfbf1', fg: '#0f766e', border: '#99f6e4' },
  blue:    { bg: '#dbeafe', fg: '#1d4ed8', border: '#bfdbfe' },
  emerald: { bg: '#d1fae5', fg: '#047857', border: '#a7f3d0' },
  green:   { bg: '#dcfce7', fg: '#15803d', border: '#bbf7d0' },
  sky:     { bg: '#e0f2fe', fg: '#0369a1', border: '#bae6fd' },
  violet:  { bg: '#ede9fe', fg: '#6d28d9', border: '#ddd6fe' },
  cyan:    { bg: '#cffafe', fg: '#0e7490', border: '#a5f3fc' },
  indigo:  { bg: '#e0e7ff', fg: '#4338ca', border: '#c7d2fe' },
  rose:    { bg: '#ffe4e6', fg: '#be123c', border: '#fecdd3' },
  fuchsia: { bg: '#fae8ff', fg: '#a21caf', border: '#f5d0fe' },
};
const c = colorMap[cfg.color] || colorMap.blue;
---
<span
  class={`subj-icon ${className}`}
  style={`display:inline-grid;place-items:center;width:${s.box};height:${s.box};border-radius:${s.radius};background:${c.bg};color:${c.fg};border:1px solid ${c.border};flex-shrink:0;`}
  aria-hidden="true"
>
  <Icon name={cfg.icon} size={s.icon} strokeWidth={2.2} />
</span>
ASTRO

echo "  ✓ SubjectIcon.astro created"

# ═════════════════════════════════════════════════════════
#  3. SEO helper library
# ═════════════════════════════════════════════════════════
echo ""
echo "▸ 3. Creating SEO helpers..."

cat > src/lib/bookSeo.ts <<'TS'
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
TS

echo "  ✓ bookSeo.ts created"

# ═════════════════════════════════════════════════════════
#  4. Remove old flat books pages
# ═════════════════════════════════════════════════════════
echo ""
echo "▸ 4. Removing old flat routes..."
rm -f src/pages/books/[...slug].astro
rm -f src/pages/books/index.astro
mkdir -p 'src/pages/books/[board]'
echo "  ✓ Cleaned"

# ═════════════════════════════════════════════════════════
#  5. New /books — hub with board picker
# ═════════════════════════════════════════════════════════
echo ""
echo "▸ 5. Creating /books (board picker)..."

cat > src/pages/books/index.astro <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import SubjectIcon from '../../components/SubjectIcon.astro';
import { url } from '../../lib/url';
import { getCollection } from 'astro:content';

const books = await getCollection('books');

// Count by board
const boardCounts = new Map<string, number>();
books.forEach((b: any) => {
  const board = (b.data.boards || [])[0];
  if (board) boardCounts.set(board, (boardCounts.get(board) || 0) + 1);
});

const ORDER = ['Punjab', 'Federal', 'Sindh', 'KPK', 'Balochistan', 'AJK'];
const boards = [...boardCounts.keys()]
  .sort((a, b) => {
    const ai = ORDER.indexOf(a), bi = ORDER.indexOf(b);
    if (ai === -1 && bi === -1) return a.localeCompare(b);
    if (ai === -1) return 1;
    if (bi === -1) return -1;
    return ai - bi;
  });

const META: Record<string, { desc: string; short: string }> = {
  'Punjab':      { short: 'PTB / PCTB', desc: 'Punjab Curriculum and Textbook Board — books for all schools in Punjab.' },
  'Federal':     { short: 'FBISE',      desc: 'Federal Board — books for federal schools, cadet colleges, and Pakistani schools abroad.' },
  'Sindh':       { short: 'STBB',       desc: 'Sindh Textbook Board — English, Urdu, and Sindhi medium books for all Sindh schools.' },
  'KPK':         { short: 'KPTBB',      desc: 'Khyber Pakhtunkhwa Textbook Board — official books for KPK schools.' },
  'Balochistan': { short: 'BTBB',       desc: 'Balochistan Textbook Board — official books for all Balochistan schools.' },
  'AJK':         { short: 'AJKTB',      desc: 'AJK Textbook Board — official books for Azad Jammu and Kashmir schools.' },
};

const totalBooks = books.length;

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  name: 'Pakistani Textbooks — Free PDF Library',
  description: `Complete library of official Pakistani textbooks — ${totalBooks} books from Punjab (PTB), Federal (FBISE), Sindh (STBB), Balochistan (BTBB), and other boards. Free PDF downloads for Class 1 to 12.`,
  url: 'https://malikjeerajajee-coder.github.io/My-edu-site/books/',
  hasPart: boards.map(b => ({
    '@type': 'CollectionPage',
    name: `${b} Textbooks`,
    url: `https://malikjeerajajee-coder.github.io/My-edu-site/books/${b.toLowerCase()}/`,
  })),
};
---
<BaseLayout
  title="Pakistani Textbooks — Free PDF Library Class 1 to 12 | Parhayi"
  description={`Download official Pakistani textbooks for free. ${totalBooks} books from Punjab (PTB), Federal (FBISE), Sindh (STBB), Balochistan (BTBB). Class 1 to 12, all subjects, all mediums.`}
  jsonLd={jsonLd}
>
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">Textbooks</span>
      </nav>
      <div class="max-w-2xl">
        <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">Pakistani Textbooks</h1>
        <p class="mt-4 text-base leading-relaxed text-slate-600 sm:text-lg">
          Download official textbooks from every major Pakistani board — <strong class="text-slate-900">Punjab (PTB)</strong>, <strong class="text-slate-900">Federal (FBISE)</strong>, <strong class="text-slate-900">Sindh (STBB)</strong>, and <strong class="text-slate-900">Balochistan (BTBB)</strong>. Free PDFs, no sign-up, no ads.
        </p>
      </div>
      <div class="mt-6 flex flex-wrap gap-x-6 gap-y-2 text-sm text-slate-500">
        <span><strong class="font-extrabold text-slate-900">{totalBooks}</strong> books</span>
        <span><strong class="font-extrabold text-slate-900">{boards.length}</strong> boards</span>
        <span><strong class="font-extrabold text-slate-900">Class 1–12</strong></span>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
    <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Choose your board</h2>
    <p class="mt-2 text-sm text-slate-500">Each board publishes its own textbooks. Pick the one that matches your school.</p>

    <div class="mt-6 grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
      {boards.map(b => {
        const meta = META[b] || { short: b, desc: `Official textbooks published by the ${b} board.` };
        const count = boardCounts.get(b) || 0;
        return (
          <a href={url(`/books/${b.toLowerCase()}`)} class="group rounded-2xl border border-slate-200 bg-white p-6 transition-colors hover:border-[#1d4ed8]">
            <div class="flex items-start justify-between">
              <span class="inline-flex items-center rounded-md bg-[#eff4ff] px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider text-[#1d4ed8]">{meta.short}</span>
              <svg class="text-slate-300 transition-all group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M7 7h10v10"/><path d="M7 17 17 7"/></svg>
            </div>
            <h3 class="mt-4 font-display text-xl font-extrabold tracking-tight text-slate-900">{b}</h3>
            <p class="mt-2 text-sm leading-relaxed text-slate-500">{meta.desc}</p>
            <div class="mt-4 text-xs font-bold uppercase tracking-wider text-slate-400">{count} {count === 1 ? 'book' : 'books'}</div>
          </a>
        );
      })}
    </div>
  </div>

  <!-- SEO copy -->
  <section class="border-t border-slate-200 bg-white">
    <div class="mx-auto max-w-[900px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
      <div class="prose">
        <h2>Pakistan's complete textbook library</h2>
        <p>Textbooks are the foundation of every board exam. Whether you're in Class 1 learning your first Urdu letters, or in Class 12 preparing for your HSSC exams, the right textbook is the starting point for everything else.</p>
        <p>Parhayi hosts the official textbooks published by Pakistan's four largest education boards — the <strong>Punjab Textbook Board (PTB / PCTB)</strong>, the <strong>Federal Board (FBISE)</strong>, the <strong>Sindh Textbook Board (STBB)</strong>, and the <strong>Balochistan Textbook Board (BTBB)</strong> — plus resources from Khyber Pakhtunkhwa and Azad Jammu and Kashmir.</p>
        <h3>What you'll find here</h3>
        <ul>
          <li><strong>Every class from 1 to 12</strong>, from primary through intermediate</li>
          <li><strong>Every subject</strong> — Mathematics, Physics, Chemistry, Biology, English, Urdu, Islamiat, Pakistan Studies, Computer Science, and more</li>
          <li><strong>Every medium</strong> — English medium (EM), Urdu medium (UM), and Sindhi medium where relevant</li>
          <li><strong>Every scheme</strong> — current Single National Curriculum (SNC), the previous scheme, and the newest 2025–27 editions</li>
        </ul>
        <h3>How to find your textbook</h3>
        <p>Choose your board above, then your class, then your subject. Every book opens as a free PDF download — no registration, no paywall, no ads. The full library is over 300 books and growing.</p>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO

echo "  ✓ /books created"

# ═════════════════════════════════════════════════════════
#  6. New /books/[board] — class picker
# ═════════════════════════════════════════════════════════
cat > 'src/pages/books/[board]/index.astro' <<'ASTRO'
---
import BaseLayout from '../../../layouts/BaseLayout.astro';
import { url } from '../../../lib/url';
import { boardMeta, classLabel } from '../../../lib/bookSeo';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const books = await getCollection('books');
  const boards = new Set<string>();
  books.forEach((b: any) => (b.data.boards || []).forEach((x: string) => boards.add(x)));
  return [...boards].map(b => ({ params: { board: b.toLowerCase() } }));
}

const { board: boardSlug } = Astro.params;
const allBooks = await getCollection('books');

// Find the real board name from the slug
const boardName = [...new Set(allBooks.flatMap((b: any) => b.data.boards || []))]
  .find(n => n.toLowerCase() === boardSlug);
if (!boardName) return Astro.redirect('/books');

const meta = boardMeta(boardName);
const books = allBooks.filter((b: any) => (b.data.boards || []).includes(boardName));

// Group by class
const byClass = new Map<string, number>();
books.forEach((b: any) => {
  const cls = String(b.data.class);
  byClass.set(cls, (byClass.get(cls) || 0) + 1);
});
const classes = [...byClass.keys()].sort((a, b) => Number(a) - Number(b));

// Total subjects (unique across all classes)
const subjects = new Set<string>();
books.forEach((b: any) => subjects.add(b.data.subject));

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  name: `${boardName} Textbooks — Class 1 to 12`,
  description: `Complete library of ${boardName} textbooks (${meta.abbreviation}). ${books.length} books for classes 1–12, all subjects.`,
  url: `https://malikjeerajajee-coder.github.io/My-edu-site/books/${boardSlug}/`,
};
---
<BaseLayout
  title={`${boardName} Textbooks — Class 1 to 12 Free PDF | ${meta.abbreviation} | Parhayi`}
  description={`Download all ${boardName} textbooks for free. ${books.length} books — Classes ${classes[0]} to ${classes[classes.length - 1]}, all subjects, all mediums.`}
  jsonLd={jsonLd}
>
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <a href={url('/books')} class="hover:text-[#1d4ed8]">Textbooks</a>
        <span>/</span>
        <span class="text-slate-500">{boardName}</span>
      </nav>
      <div class="max-w-2xl">
        <div class="inline-flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-[#1d4ed8]">
          <span class="h-1.5 w-1.5 rounded-full bg-[#1d4ed8]"></span>
          {meta.abbreviation}
        </div>
        <h1 class="mt-3 text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">{boardName} Textbooks</h1>
        <p class="mt-4 text-base leading-relaxed text-slate-600 sm:text-lg">
          Official textbooks for {meta.province} board schools — Class 1 to Class 12. Download any book as a free PDF.
        </p>
      </div>
      <div class="mt-6 flex flex-wrap gap-x-6 gap-y-2 text-sm text-slate-500">
        <span><strong class="font-extrabold text-slate-900">{books.length}</strong> books</span>
        <span><strong class="font-extrabold text-slate-900">{classes.length}</strong> classes</span>
        <span><strong class="font-extrabold text-slate-900">{subjects.size}</strong> subjects</span>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
    <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Choose your class</h2>
    <p class="mt-2 text-sm text-slate-500">Every class has its own set of {boardName} textbooks.</p>

    <div class="mt-6 grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
      {classes.map(c => {
        const count = byClass.get(c) || 0;
        return (
          <a href={url(`/books/${boardSlug}/class-${c}`)} class="group rounded-2xl border border-slate-200 bg-white p-5 transition-colors hover:border-[#1d4ed8]">
            <span class="inline-flex h-12 w-12 place-items-center rounded-xl bg-[#eff4ff] font-display text-2xl font-extrabold text-[#1d4ed8]">{c}</span>
            <div class="mt-4 font-display text-lg font-extrabold tracking-tight text-slate-900">Class {c}</div>
            <div class="mt-1 text-xs font-bold uppercase tracking-wider text-slate-400">{count} {count === 1 ? 'book' : 'books'}</div>
          </a>
        );
      })}
    </div>
  </div>

  <!-- SEO copy -->
  <section class="border-t border-slate-200 bg-white">
    <div class="mx-auto max-w-[900px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
      <div class="prose">
        <h2>About {boardName} textbooks</h2>
        <p>{meta.description}</p>
        <h3>What's included</h3>
        <ul>
          <li><strong>{classes.length} classes</strong> — every year from {classes[0]} through {classes[classes.length - 1]}</li>
          <li><strong>{subjects.size} subjects</strong> — including Mathematics, English, Urdu, Islamiat, and every other subject published by the board</li>
          <li><strong>Free PDF downloads</strong> — no sign-up, no paywall, no ads</li>
        </ul>
        <h3>How to download</h3>
        <p>Choose your class above, find the subject you need, and click Download PDF. Every textbook opens directly in your browser or downloads to your device.</p>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO

echo "  ✓ /books/[board] created"

# ═════════════════════════════════════════════════════════
#  7. New /books/[board]/[class] — subject list
# ═════════════════════════════════════════════════════════
cat > 'src/pages/books/[board]/[class].astro' <<'ASTRO'
---
import BaseLayout from '../../../layouts/BaseLayout.astro';
import Icon from '../../../components/Icon.astro';
import SubjectIcon from '../../../components/SubjectIcon.astro';
import { url } from '../../../lib/url';
import { boardMeta, bookSubjectName, subjectSlug } from '../../../lib/bookSeo';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const books = await getCollection('books');
  const paths: any[] = [];
  const seen = new Set<string>();
  books.forEach((b: any) => {
    const board = (b.data.boards || [])[0];
    if (!board) return;
    const key = `${board.toLowerCase()}/class-${b.data.class}`;
    if (!seen.has(key)) {
      seen.add(key);
      paths.push({ params: { board: board.toLowerCase(), class: `class-${b.data.class}` } });
    }
  });
  return paths;
}

const { board: boardSlug, class: classParam } = Astro.params;
const cls = String(classParam).replace(/^class-/, '');
const allBooks = await getCollection('books');

const boardName = [...new Set(allBooks.flatMap((b: any) => b.data.boards || []))]
  .find(n => n.toLowerCase() === boardSlug);
if (!boardName) return Astro.redirect('/books');

const meta = boardMeta(boardName);
const books = allBooks
  .filter((b: any) => (b.data.boards || []).includes(boardName) && String(b.data.class) === cls)
  .sort((a: any, b: any) => a.data.subject.localeCompare(b.data.subject));

// Group by subject for cleaner display
const bySubject = new Map<string, any[]>();
books.forEach((b: any) => {
  const subj = bookSubjectName(b.data.subject);
  if (!bySubject.has(subj)) bySubject.set(subj, []);
  bySubject.get(subj)!.push(b);
});
const subjects = [...bySubject.keys()].sort();

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'CollectionPage',
  name: `Class ${cls} ${boardName} Textbooks — All Subjects`,
  description: `Download all Class ${cls} ${boardName} textbooks for free. ${subjects.length} subjects available including ${subjects.slice(0, 5).join(', ')}.`,
  url: `https://malikjeerajajee-coder.github.io/My-edu-site/books/${boardSlug}/class-${cls}/`,
};
---
<BaseLayout
  title={`Class ${cls} ${boardName} Textbooks — All Subjects Free PDF | ${meta.abbreviation} | Parhayi`}
  description={`Download all Class ${cls} ${boardName} textbook PDFs. ${subjects.length} subjects including ${subjects.slice(0, 4).join(', ')}. Free, no sign-up.`}
  jsonLd={jsonLd}
>
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <a href={url('/books')} class="hover:text-[#1d4ed8]">Textbooks</a>
        <span>/</span>
        <a href={url(`/books/${boardSlug}`)} class="hover:text-[#1d4ed8]">{boardName}</a>
        <span>/</span>
        <span class="text-slate-500">Class {cls}</span>
      </nav>
      <div class="max-w-2xl">
        <div class="inline-flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-[#1d4ed8]">
          <span class="h-1.5 w-1.5 rounded-full bg-[#1d4ed8]"></span>
          {meta.abbreviation} · Class {cls}
        </div>
        <h1 class="mt-3 text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">
          Class {cls} Textbooks — {boardName}
        </h1>
        <p class="mt-4 text-base leading-relaxed text-slate-600 sm:text-lg">
          Every {boardName} Class {cls} textbook in one place. {books.length} books across {subjects.length} subjects — all free PDFs.
        </p>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
    <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">All Class {cls} subjects</h2>
    <p class="mt-2 text-sm text-slate-500">Click a subject to download the textbook PDF.</p>

    <div class="mt-6 grid grid-cols-1 gap-2.5 sm:grid-cols-2">
      {subjects.map(subj => {
        const items = bySubject.get(subj)!;
        // If only one edition, link directly
        if (items.length === 1) {
          const b = items[0];
          return (
            <a href={url(`/textbook/${b.id}`)} class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-4 transition-colors hover:border-[#1d4ed8]">
              <SubjectIcon subject={subj} size="md" />
              <div class="min-w-0 flex-1">
                <div class="text-[0.9375rem] font-extrabold tracking-tight text-slate-900">{subj}</div>
                <div class="mt-1 flex flex-wrap gap-1.5">
                  {b.data.medium && <span class="rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate-600">{b.data.medium}</span>}
                  {b.data.year && <span class="rounded bg-[#eff4ff] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#1d4ed8]">{b.data.year}</span>}
                </div>
              </div>
              <Icon name="arrow-right" size={15} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
            </a>
          );
        }
        // Multiple editions — show each
        return items.map(b => (
          <a href={url(`/textbook/${b.id}`)} class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-4 transition-colors hover:border-[#1d4ed8]">
            <SubjectIcon subject={subj} size="md" />
            <div class="min-w-0 flex-1">
              <div class="text-[0.9375rem] font-extrabold tracking-tight text-slate-900">{subj}</div>
              <div class="mt-1 flex flex-wrap gap-1.5">
                {b.data.medium && <span class="rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate-600">{b.data.medium}</span>}
                {b.data.year && <span class="rounded bg-[#eff4ff] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#1d4ed8]">{b.data.year}</span>}
              </div>
            </div>
            <Icon name="arrow-right" size={15} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
          </a>
        ));
      })}
    </div>
  </div>

  <!-- SEO copy -->
  <section class="border-t border-slate-200 bg-white">
    <div class="mx-auto max-w-[900px] px-5 py-14 sm:px-7 lg:px-10 lg:py-16">
      <div class="prose">
        <h2>Class {cls} {boardName} textbooks</h2>
        <p>
          Class {cls} is a critical year in the {boardName} system. The {subjects.length} subjects listed on this page are the official textbooks published by the {meta.authority}. Every textbook is available as a free PDF download.
        </p>
        <h3>Subjects in Class {cls}</h3>
        <ul>
          {subjects.map(s => <li><strong>{s}</strong> — official {boardName} textbook</li>)}
        </ul>
        <h3>Medium and editions</h3>
        <p>
          Where the board publishes both <strong>English medium (EM)</strong> and <strong>Urdu medium (UM)</strong> editions, both are listed. If a subject has been revised under the current Single National Curriculum (SNC), the newest edition is shown first — with the year clearly tagged.
        </p>
      </div>
    </div>
  </section>
</BaseLayout>
ASTRO

echo "  ✓ /books/[board]/[class] created"

# ═════════════════════════════════════════════════════════
#  8. New /textbook/[slug] — book detail
# ═════════════════════════════════════════════════════════
mkdir -p src/pages/textbook

cat > 'src/pages/textbook/[...slug].astro' <<'ASTRO'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import SubjectIcon from '../../components/SubjectIcon.astro';
import { url } from '../../lib/url';
import { boardMeta, bookSeoTitle, bookSeoDescription, bookSubjectName, subjectSlug } from '../../lib/bookSeo';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const books = await getCollection('books');
  return books.map((book: any) => ({ params: { slug: book.id }, props: { book } }));
}

const { book } = Astro.props;
const d = book.data;
const boardName = (d.boards || [])[0] || 'Punjab';
const meta = boardMeta(boardName);
const subj = bookSubjectName(d.subject);
const boardSlug = boardName.toLowerCase();

const canonical = `https://malikjeerajajee-coder.github.io/My-edu-site/textbook/${book.id}/`;

// Related: same board, same class, other subjects (up to 6)
const allBooks = await getCollection('books');
const related = allBooks
  .filter((b: any) =>
    b.id !== book.id &&
    (b.data.boards || []).includes(boardName) &&
    String(b.data.class) === String(d.class)
  )
  .slice(0, 6);

const jsonLd = [
  {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: [
      { '@type': 'ListItem', position: 1, name: 'Home', item: 'https://malikjeerajajee-coder.github.io/My-edu-site/' },
      { '@type': 'ListItem', position: 2, name: 'Textbooks', item: 'https://malikjeerajajee-coder.github.io/My-edu-site/books/' },
      { '@type': 'ListItem', position: 3, name: boardName, item: `https://malikjeerajajee-coder.github.io/My-edu-site/books/${boardSlug}/` },
      { '@type': 'ListItem', position: 4, name: `Class ${d.class}`, item: `https://malikjeerajajee-coder.github.io/My-edu-site/books/${boardSlug}/class-${d.class}/` },
      { '@type': 'ListItem', position: 5, name: subj },
    ],
  },
  {
    '@context': 'https://schema.org',
    '@type': 'Book',
    name: `${subj} — Class ${d.class}`,
    bookEdition: d.year || undefined,
    inLanguage: d.medium === 'urdu' ? 'ur' : d.medium === 'sindhi' ? 'sd' : 'en',
    publisher: {
      '@type': 'Organization',
      name: meta.authority,
    },
    educationalLevel: `Class ${d.class}`,
    learningResourceType: 'Textbook',
    about: subj,
    url: canonical,
  },
];
---
<BaseLayout
  title={bookSeoTitle(book)}
  description={bookSeoDescription(book)}
  jsonLd={jsonLd}
>
  <!-- Header -->
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1100px] px-5 pt-8 pb-10 sm:px-7 lg:px-10 lg:pt-12 lg:pb-12">
      <nav class="mb-6 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <a href={url('/books')} class="hover:text-[#1d4ed8]">Textbooks</a>
        <span>/</span>
        <a href={url(`/books/${boardSlug}`)} class="hover:text-[#1d4ed8]">{boardName}</a>
        <span>/</span>
        <a href={url(`/books/${boardSlug}/class-${d.class}`)} class="hover:text-[#1d4ed8]">Class {d.class}</a>
        <span>/</span>
        <span class="text-slate-500">{subj}</span>
      </nav>

      <div class="grid grid-cols-1 gap-8 sm:grid-cols-[140px_1fr] lg:grid-cols-[180px_1fr]">
        <!-- Big subject icon as "cover" -->
        <div class="mx-auto w-full max-w-[140px] sm:mx-0 lg:max-w-none">
          <div class="aspect-[5/7] rounded-xl border border-slate-200 bg-white overflow-hidden grid place-items-center">
            <SubjectIcon subject={subj} size="lg" class="!w-20 !h-20" />
          </div>
        </div>

        <div>
          <div class="flex flex-wrap gap-1.5">
            <span class="badge-soft">{meta.abbreviation}</span>
            <span class="badge-soft">Class {d.class}</span>
            {d.medium && <span class="badge-soft">{d.medium}</span>}
            {d.year && <span class="badge-soft">{d.year}</span>}
          </div>
          <h1 class="mt-4 text-3xl font-extrabold leading-tight tracking-tight text-slate-900 sm:text-4xl">
            {subj} — Class {d.class} Textbook
          </h1>
          <p class="mt-3 text-base leading-relaxed text-slate-600">
            Official {meta.abbreviation} textbook for Class {d.class} {subj}. {d.year ? `Published for the ${d.year} session.` : 'Current edition.'} Free PDF download.
          </p>

          <a href={d.pdfUrl} target="_blank" rel="noopener"
             class="mt-7 inline-flex items-center gap-2 rounded-lg bg-[#1d4ed8] px-6 py-3.5 text-sm font-bold text-white transition-colors hover:bg-[#1e3a8a]">
            <Icon name="download" size={17} strokeWidth={2.4} /> Download textbook PDF
          </a>
        </div>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[900px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
    <article class="prose">
      <h2>About this textbook</h2>
      <p>
        This is the official {subj} textbook for Class {d.class} students, published by the {meta.authority}. Every chapter, worked example, and exercise in the book corresponds directly to the questions asked in {boardName} board exams.
      </p>
      <p>
        {meta.description}
      </p>
      <h3>Why download the official textbook?</h3>
      <ul>
        <li><strong>Complete coverage</strong> — everything that can appear in your exam is drawn from this book</li>
        <li><strong>Offline access</strong> — download once, study anywhere without internet</li>
        <li><strong>Free forever</strong> — no sign-up, no ads, no subscription</li>
      </ul>
      <h3>How to use this book effectively</h3>
      <p>
        Start with the chapter summaries, then work through the worked examples, then attempt the end-of-chapter exercises. Compare your answers with the model solutions in the {subj} notes section of Parhayi.
      </p>
    </article>

    {related.length > 0 && (
      <section class="mt-14">
        <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Other Class {d.class} {boardName} textbooks</h2>
        <div class="mt-5 grid grid-cols-1 gap-2.5 sm:grid-cols-2">
          {related.map((b: any) => (
            <a href={url(`/textbook/${b.id}`)} class="group flex items-center gap-4 rounded-2xl border border-slate-200 bg-white p-4 transition-colors hover:border-[#1d4ed8]">
              <SubjectIcon subject={bookSubjectName(b.data.subject)} size="md" />
              <div class="min-w-0 flex-1">
                <div class="text-[0.9375rem] font-extrabold tracking-tight text-slate-900">{bookSubjectName(b.data.subject)}</div>
                <div class="mt-1 flex flex-wrap gap-1.5">
                  {b.data.medium && <span class="rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate-600">{b.data.medium}</span>}
                  {b.data.year && <span class="rounded bg-[#eff4ff] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#1d4ed8]">{b.data.year}</span>}
                </div>
              </div>
              <Icon name="arrow-right" size={15} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
            </a>
          ))}
        </div>
      </section>
    )}

    <div class="mt-12">
      <a href={url(`/books/${boardSlug}/class-${d.class}`)} class="inline-flex items-center gap-2 text-sm font-semibold text-slate-500 hover:text-[#1d4ed8]">
        <Icon name="arrow-left" size={16} strokeWidth={2.4} /> Back to Class {d.class} {boardName}
      </a>
    </div>
  </div>
</BaseLayout>
ASTRO

echo "  ✓ /textbook/[slug] created"

# ═════════════════════════════════════════════════════════
#  9. Fix references to /books/[slug] elsewhere
# ═════════════════════════════════════════════════════════
echo ""
echo "▸ 9. Updating internal links..."
grep -rl "/books/\${" src/pages src/components 2>/dev/null | while read f; do
  sed -i "s|/books/\${\(b\|book\|item\)\.id}|/textbook/\${\1.id}|g" "$f" || true
done
echo "  ✓ Done"

# ═════════════════════════════════════════════════════════
#  10. Rebuild
# ═════════════════════════════════════════════════════════
echo ""
echo "Rebuilding..."
rm -rf .astro node_modules/.vite dist
npm run build 2>&1 | tail -10

echo ""
echo "════════════════════════════════════════════════════════"
echo "  DONE"
echo ""
echo "  Preview:"
echo "    bash start-server.sh"
echo ""
echo "  Check these:"
echo "    /My-edu-site/books/                        → board picker"
echo "    /My-edu-site/books/punjab                  → Punjab classes"
echo "    /My-edu-site/books/punjab/class-9          → Class 9 Punjab subjects"
echo "    /My-edu-site/books/sindh/class-10          → Class 10 Sindh subjects"
echo "    /My-edu-site/textbook/9-pectaa-mathematics-e-2025_26 → detail"
echo ""
echo "  Push:"
echo "    git add ."
echo "    git commit -m 'Rebuild textbooks: proper navigation, subject icons, SEO'"
echo "    git push"
echo "════════════════════════════════════════════════════════"