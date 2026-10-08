import { readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

const CSV = process.argv[2];
const OUT = join(process.cwd(), 'src', 'content', 'past-papers');

const raw = readFileSync(CSV, 'utf8').replace(/^\uFEFF/, '');
const lines = raw.split(/\r?\n/).filter(l => l.trim());

function cells(line) {
  const sep = line.includes('|') ? '|' : ',';
  const parts = line.split(sep).map(c => c.trim());
  if (parts.length && parts[0] === '') parts.shift();
  if (parts.length && parts[parts.length - 1] === '') parts.pop();
  return parts;
}

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
const BOARD_SLUG = { Punjab: 'punjab', Sindh: 'sindh', KPK: 'kpk', Balochistan: 'balochistan', AJK: 'ajk', Federal: 'federal' };

let written = 0, dupes = 0, minY = 9999, maxY = 0;
const seen = new Set();
const skipped = [];
const boardCounts = {};

for (const line of lines) {
  const c = cells(line);
  if (c.length < 4) continue;
  if (/file name/i.test(c[0])) continue;

  const fileName = c[0];
  const folder = c[1] || '';
  const fileId = c[2] || '';
  let view = c[3] || '';
  if (!/^https?:/.test(view) && fileId) view = 'https://drive.google.com/file/d/' + fileId + '/view';

  const m = fileName.match(/^(\d{4})_([A-Za-z][A-Za-z-]*?)_(\d{1,2})_(.+?)\.(pdf|jpg|jpeg|png)$/i);
  if (!m) { skipped.push(fileName + ' (unparseable name)'); continue; }

  const year = Number(m[1]);
  const info = lookup(m[2]);
  if (!info) { skipped.push(fileName + ' (unknown board: ' + m[2] + ')'); continue; }
  const board = info[0];
  const bise = info[1];
  const cls = String(Number(m[3]));
  const subject = titleCase(folder || m[4]);

  const fname = slug(subject) + '-' + cls + '-' + BOARD_SLUG[board] + (bise ? '-' + slug(bise) : '') + '-' + year + '.json';
  if (seen.has(fname)) { dupes++; continue; }
  seen.add(fname);

  const boardLabel = bise ? bise + ' Board' : (board === 'Federal' ? 'Federal Board' : board + ' Board');
  const title = subject + ' Class ' + cls + ' Past Paper ' + year + ' \u2014 ' + boardLabel;

  writeFileSync(join(OUT, fname), JSON.stringify({
    title, subject, class: cls, year,
    boards: [board],
    ...(bise ? { bises: [bise], bise } : {}),
    pdfUrl: view,
  }));
  written++;
  boardCounts[board] = (boardCounts[board] || 0) + 1;
  if (year < minY) minY = year;
  if (year > maxY) maxY = year;
}

console.log('✔ wrote ' + written + ' past papers (years ' + minY + '\u2013' + maxY + ')');
console.log('  duplicates skipped: ' + dupes);
console.log('  skipped: ' + skipped.length);
skipped.slice(0, 25).forEach(s => console.warn('    ⚠ ' + s));
Object.keys(boardCounts).sort().forEach(b => console.log('  ' + b + ': ' + boardCounts[b]));
