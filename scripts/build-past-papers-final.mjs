import { readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

const CSV = process.argv[2];
const OUT = join(process.cwd(), 'src', 'content', 'past-papers');
const raw = readFileSync(CSV, 'utf8').replace(/^\uFEFF/, '');
const lines = raw.split(/\r?\n/).filter(l => l.trim());

function cells(line) {
  const sep = line.includes('|') ? '|' : ',';
  const parts = line.split(sep).map(c => c.trim());
  if (parts[0] === '') parts.shift();
  if (parts.length && parts[parts.length - 1] === '') parts.pop();
  return parts;
}

function driveView(c) {
  for (const cell of c) {
    const m = cell.match(/drive\.google\.com\/file\/d\/([\w-]+)/);
    if (m) return 'https://drive.google.com/file/d/' + m[1] + '/view';
  }
  for (const cell of c) {
    const m = cell.match(/[?&]id=([\w-]+)/);
    if (m) return 'https://drive.google.com/file/d/' + m[1] + '/view';
  }
  for (const cell of c) {
    if (/^[\w-]{20,}$/.test(cell)) return 'https://drive.google.com/file/d/' + cell + '/view';
  }
  return '';
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
  quetta: ['Balochistan', 'Quetta'], zhob: ['Balochistan', 'Zhob'],
  khuzdar: ['Balochistan', 'Khuzdar'], turbat: ['Balochistan', 'Turbat'],
  ajk: ['AJK', null], mirpur: ['AJK', 'Mirpur'],
  muzaffarabad: ['AJK', 'Muzaffarabad'], rawalakot: ['AJK', 'Rawalakot'],
  fbise: ['Federal', null], federal: ['Federal', null],
};
const lookup = r => BISE_MAP[String(r).trim().replace(/^BISE[-_ ]?/i, '').toLowerCase()] || null;
const titleCase = s => String(s).toLowerCase().replace(/_/g, ' ').split(/\s+/).filter(Boolean).map(w => w[0].toUpperCase() + w.slice(1)).join(' ');
const slug = s => String(s).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
const BOARD_SLUG = { Punjab: 'punjab', Sindh: 'sindh', KPK: 'kpk', Balochistan: 'balochistan', AJK: 'ajk', Federal: 'federal' };

let written = 0, dupes = 0, noLink = 0, badName = 0;
const seen = new Set();

for (const line of lines) {
  const c = cells(line);
  if (c.length < 3 || /file name/i.test(c[0])) continue;

  const fileName = c[0];
  const folder = c[1] || '';
  const view = driveView(c);
  if (!view) { noLink++; continue; }

  const m = fileName.match(/^(\d{4})_([A-Za-z][A-Za-z-]*?)_(\d{1,2})_(.+?)\.(pdf|jpg|jpeg|png)$/i);
  if (!m) { badName++; continue; }

  const info = lookup(m[2]);
  if (!info) { badName++; continue; }
  const clsN = parseInt(m[3], 10);
  if (clsN < 1 || clsN > 12) { badName++; continue; }
  const cls = String(clsN);
  const year = Number(m[1]);
  const board = info[0], bise = info[1];
  const subject = titleCase(folder || m[4]);

  const key = [slug(subject), cls, BOARD_SLUG[board], bise ? slug(bise) : null, year].filter(Boolean).join('-');
  if (seen.has(key)) { dupes++; continue; }
  seen.add(key);

  const boardLabel = bise ? bise + ' Board' : (board === 'Federal' ? 'Federal Board' : board + ' Board');
  writeFileSync(join(OUT, key + '.json'), JSON.stringify({
    title: subject + ' Class ' + cls + ' Past Paper ' + year + ' \u2014 ' + boardLabel,
    subject, class: cls, year, boards: [board],
    ...(bise ? { bises: [bise], bise } : {}),
    pdfUrl: view,
  }));
  written++;
}

console.log('✔ wrote ' + written + ' past papers WITH Drive links');
console.log('  duplicate copies skipped: ' + dupes);
console.log('  rows without a Drive link: ' + noLink);
console.log('  unparseable rows: ' + badName);
