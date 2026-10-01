import { readFileSync, writeFileSync, mkdirSync, existsSync, rmSync } from 'node:fs';
import { join } from 'node:path';

const CSV = process.argv[2];
if (!CSV || !existsSync(CSV)) { console.error('CSV not found: ' + CSV); process.exit(1); }

const OUT = join(process.cwd(), 'src', 'content', 'gazettes');
if (existsSync(OUT)) rmSync(OUT, { recursive: true, force: true });
mkdirSync(OUT, { recursive: true });

const raw = readFileSync(CSV, 'utf8').replace(/^\uFEFF/, '');

const FILE_RE = /(?:BISE_[A-Za-z_]+?|FBISE)_(?:9|10|11|12)th_Class_[A-Za-z0-9_]+?_\d{4}(?:_[a-z]+)*\.pdf/g;
const VIEW_RE = /drive\.google\.com\/file\/d\/([\w-]+)\/view/g;

// Position-aware pairing: each row lists the filename TWICE (once inside the
// folder path, once as its own column). Index-based pairing shifted the Drive
// links by one row. Instead: every Drive ID binds to the nearest filename
// appearing just before it.
const tokens = [];
for (const m of raw.matchAll(FILE_RE)) tokens.push({ pos: m.index, kind: 'f', v: m[0] });
for (const m of raw.matchAll(VIEW_RE)) tokens.push({ pos: m.index, kind: 'i', v: m[1] });
tokens.sort((a, b) => a.pos - b.pos);

const pairs = [];
let pending = null;
for (const t of tokens) {
  if (t.kind === 'f') pending = t.v;
  else if (pending) { pairs.push([pending, t.v]); pending = null; }
}
console.log('found ' + pairs.length + ' filename↔drive pairs');

const BISE_BOARD = {
  lahore: 'Punjab', gujranwala: 'Punjab', faisalabad: 'Punjab', multan: 'Punjab',
  rawalpindi: 'Punjab', sargodha: 'Punjab', sahiwal: 'Punjab', bahawalpur: 'Punjab', 'dg-khan': 'Punjab',
  karachi: 'Sindh', hyderabad: 'Sindh', sukkur: 'Sindh', larkana: 'Sindh', mirpurkhas: 'Sindh',
  nawabshah: 'Sindh', 'shaheed-benazirabad': 'Sindh',
  peshawar: 'KPK', mardan: 'KPK', abbottabad: 'KPK', swat: 'KPK', kohat: 'KPK',
  bannu: 'KPK', malakand: 'KPK', 'di-khan': 'KPK',
  quetta: 'Balochistan', zhob: 'Balochistan', nasirabad: 'Balochistan', makran: 'Balochistan', sibi: 'Balochistan',
  mirpur: 'AJK', muzaffarabad: 'AJK', rawalakot: 'AJK',
};
const titleCase = s => s.toLowerCase().split(/[\s_]+/).filter(Boolean)
  .map(w => w[0].toUpperCase() + w.slice(1)).join(' ')
  .replace(/\bDi\b/, 'DI').replace(/\bDg\b/, 'DG');
const slug = s => s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');

let written = 0, minY = 9999, maxY = 0;
const seen = new Set(); const warnings = [];

for (const [name, id] of pairs) {
  const m = name.match(/^(BISE_[A-Za-z_]+?|FBISE)_(9|10|11|12)th_Class_(.+?)_(\d{4})(?:_([a-z_]+))?\.pdf$/);
  if (!m) { warnings.push('unparseable: ' + name); continue; }
  const [, biseRaw, cls, typeRaw, yearRaw, variantRaw] = m;
  const year = Number(yearRaw);
  const isFederal = biseRaw === 'FBISE';
  const bise = isFederal ? null : titleCase(biseRaw.replace(/^BISE_/, ''));
  const board = isFederal ? 'Federal' : BISE_BOARD[slug(bise || '')];
  if (!board) { warnings.push('unknown BISE: ' + biseRaw + ' (' + name + ')'); continue; }
  const examType = titleCase(typeRaw);
  const variant = variantRaw ? titleCase(variantRaw) : null;
  if (year < minY) minY = year;
  if (year > maxY) maxY = year;

  const biseLabel = isFederal ? 'Federal Board' : board === 'Punjab' ? 'BISE ' + bise : bise + ' Board';
  const title = biseLabel + ' Class ' + cls + ' Result Gazette ' + year + ' (' + examType + ')' + (variant ? ' — ' + variant : '');

  const base = isFederal ? 'gazette-federal' : 'gazette-' + slug(bise);
  const fname = base + '-' + cls + '-' + slug(typeRaw) + '-' + year + (variantRaw ? '-' + slug(variantRaw) : '') + '.json';
  if (seen.has(fname)) { warnings.push('duplicate: ' + fname); continue; }
  seen.add(fname);

  writeFileSync(join(OUT, fname), JSON.stringify({
    title, year, board, boards: [board],
    ...(bise ? { bise } : {}),
    class: cls, examType,
    ...(variant ? { variant } : {}),
    driveUrl: 'https://drive.google.com/file/d/' + id + '/view',
  }));
  written++;
}

console.log('✔ wrote ' + written + ' gazettes (years ' + minY + '–' + maxY + ')');
warnings.slice(0, 30).forEach(w => console.warn('  ⚠ ' + w));
