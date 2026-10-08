import { readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

const CSV = process.argv[2];
const OUT = join(process.cwd(), 'src', 'content', 'gazettes');
const raw = readFileSync(CSV, 'utf8').replace(/^\uFEFF/, '');

const BISE_MAP = {
  lahore: ['Punjab', 'Lahore'], gujranwala: ['Punjab', 'Gujranwala'],
  faisalabad: ['Punjab', 'Faisalabad'], multan: ['Punjab', 'Multan'],
  rawalpindi: ['Punjab', 'Rawalpindi'], sargodha: ['Punjab', 'Sargodha'],
  sahiwal: ['Punjab', 'Sahiwal'], bahawalpur: ['Punjab', 'Bahawalpur'],
  'dg-khan': ['Punjab', 'DG Khan'], 'dg khan': ['Punjab', 'DG Khan'],
  abbottabad: ['KPK', 'Abbottabad'], bannu: ['KPK', 'Bannu'],
  'di-khan': ['KPK', 'DI Khan'], 'di khan': ['KPK', 'DI Khan'],
  kohat: ['KPK', 'Kohat'], malakand: ['KPK', 'Malakand'],
  mardan: ['KPK', 'Mardan'], peshawar: ['KPK', 'Peshawar'], swat: ['KPK', 'Swat'],
  karachi: ['Sindh', 'Karachi'], hyderabad: ['Sindh', 'Hyderabad'],
  sukkur: ['Sindh', 'Sukkur'], larkana: ['Sindh', 'Larkana'],
  mirpurkhas: ['Sindh', 'Mirpurkhas'],
  quetta: ['Balochistan', 'Quetta'],
  ajk: ['AJK', null], mirpur: ['AJK', 'Mirpur'],
  muzaffarabad: ['AJK', 'Muzaffarabad'], rawalakot: ['AJK', 'Rawalakot'],
  fbise: ['Federal', null], federal: ['Federal', null],
};

function lookup(codeRaw) {
  const code = String(codeRaw).trim().replace(/^BISE[-_ ]?/i, '');
  return BISE_MAP[code.toLowerCase()] || null;
}

const titleCase = s => String(s).toLowerCase().replace(/_/g, ' ')
  .split(/\s+/).filter(Boolean)
  .map(w => w[0].toUpperCase() + w.slice(1)).join(' ');
const slug = s => String(s).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');

const tokens = [];

// Pattern 1: Old format (BISE_Sargodha_12th_Class_2nd_Annual_Supply_2023.pdf)
const OLD_RE = /(?:BISE_[A-Za-z_]+?|FBISE)_(?:9|10|11|12)th_Class_[A-Za-z0-9_]+?_\d{4}(?:_[a-z]+)*\.pdf/gi;
for (const m of raw.matchAll(OLD_RE)) {
  tokens.push({ pos: m.index, kind: 'f', v: m[0], fmt: 'old' });
}

// Pattern 2: New format (2023_BISE-Lahore_10_Annual.pdf)
const NEW_RE = /\b(\d{4})_([A-Za-z0-9-]+)_(\d{1,2})_([A-Za-z0-9_]+)\.pdf\b/gi;
for (const m of raw.matchAll(NEW_RE)) {
  tokens.push({ pos: m.index, kind: 'f', v: m[0], fmt: 'new', year: m[1], board: m[2], cls: m[3], exam: m[4] });
}

// Drive IDs
const VIEW_RE = /drive\.google\.com\/file\/d\/([\w-]+)\/view/g;
for (const m of raw.matchAll(VIEW_RE)) {
  tokens.push({ pos: m.index, kind: 'i', v: m[1] });
}

tokens.sort((a, b) => a.pos - b.pos);

const pairs = [];
let pending = null;
let pendingFmt = null;
let pendingMeta = null;

for (const t of tokens) {
  if (t.kind === 'f') {
    pending = t.v;
    pendingFmt = t.fmt;
    pendingMeta = t;
  } else if (t.kind === 'i' && pending) {
    pairs.push({ file: pending, id: t.v, fmt: pendingFmt, meta: pendingMeta });
    pending = null;
  }
}

console.log('found ' + pairs.length + ' filename↔drive pairs');

let written = 0, dupes = 0, minY = 9999, maxY = 0;
const seen = new Set();
const skipped = [];

for (const p of pairs) {
  let year, board, bise, cls, examType, variant;

  if (p.fmt === 'old') {
    const m = p.file.match(/^(BISE_[A-Za-z_]+?|FBISE)_(9|10|11|12)th_Class_(.+?)_(\d{4})(?:_([a-z_]+))?\.pdf$/i);
    if (!m) { skipped.push(p.file); continue; }
    const info = lookup(m[1]);
    if (!info) { skipped.push(p.file + ' (unknown board)'); continue; }
    board = info[0]; bise = info[1];
    cls = m[2];
    year = Number(m[4]);
    examType = titleCase(m[3]);
    variant = m[5] ? titleCase(m[5]) : null;
  } else {
    const info = lookup(p.meta.board);
    if (!info) { skipped.push(p.file + ' (unknown board)'); continue; }
    board = info[0]; bise = info[1];
    cls = p.meta.cls;
    year = Number(p.meta.year);
    examType = titleCase(p.meta.exam);
    variant = null;
  }

  if (year < minY) minY = year;
  if (year > maxY) maxY = year;

  const biseLabel = bise ? bise + ' Board' : (board === 'Federal' ? 'Federal Board' : board + ' Board');
  const title = biseLabel + ' Class ' + cls + ' Result Gazette ' + year + ' (' + examType + ')' + (variant ? ' — ' + variant : '');

  const base = board === 'Federal' ? 'gazette-federal' : 'gazette-' + slug(bise || board);
  const fname = base + '-' + cls + '-' + slug(examType) + '-' + year + (variant ? '-' + slug(variant) : '') + '.json';
  
  if (seen.has(fname)) { dupes++; continue; }
  seen.add(fname);

  writeFileSync(join(OUT, fname), JSON.stringify({
    title, year, board, boards: [board],
    ...(bise ? { bise } : {}),
    class: cls, examType,
    ...(variant ? { variant } : {}),
    driveUrl: 'https://drive.google.com/file/d/' + p.id + '/view',
  }));
  written++;
}

console.log('✔ wrote ' + written + ' gazettes (years ' + minY + '–' + maxY + ')');
console.log('  duplicates skipped: ' + dupes);
console.log('  skipped: ' + skipped.length);
skipped.slice(0, 10).forEach(s => console.warn('    ⚠ ' + s));
