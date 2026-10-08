import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { join } from 'node:path';

const slug = s => String(s).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
const titleCase = s => String(s).toLowerCase().replace(/_/g, ' ').split(/\s+/).filter(Boolean).map(w => w[0].toUpperCase() + w.slice(1)).join(' ');

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
const lookup = r => BISE_MAP[String(r).trim().replace(/^BISE[-_ ]?/i, '').toLowerCase()] || null;

function rows(csvPath) {
  const raw = readFileSync(csvPath, 'utf8').replace(/^\uFEFF/, '');
  return raw.split(/\r?\n/).filter(l => l.trim()).map(line => {
    const sep = line.includes('|') ? '|' : ',';
    const parts = line.split(sep).map(c => c.trim());
    if (parts[0] === '') parts.shift();
    if (parts.length && parts[parts.length - 1] === '') parts.pop();
    return parts;
  });
}
const viewOf = c => c.find(x => /^https?:\/\/drive\.google\.com\/file\//.test(x)) || '';
const okClass = m => { const n = parseInt(m, 10); return n >= 1 && n <= 12 ? String(n) : null; };

function buildPapers(csv, out) {
  const seen = new Set(); const classes = new Set();
  let written = 0, skipped = 0;
  for (const c of rows(csv)) {
    if (c.length < 4 || /file name/i.test(c[0])) continue;
    const m = c[0].match(/^(\d{4})_([A-Za-z][A-Za-z-]*?)_(\d{1,2})_(.+?)\.(pdf|jpg|jpeg|png)$/i);
    if (!m) { skipped++; continue; }
    const info = lookup(m[2]); if (!info) { skipped++; continue; }
    const cls = okClass(m[3]); if (!cls) { skipped++; continue; }
    const view = viewOf(c); if (!view) { skipped++; continue; }
    const board = info[0], bise = info[1], year = Number(m[1]);
    const subject = titleCase(c[1] || m[4]);
    const key = [slug(subject), cls, slug(board), bise ? slug(bise) : null, year].filter(Boolean).join('-');
    if (seen.has(key)) { skipped++; continue; }
    seen.add(key);
    const boardLabel = bise ? bise + ' Board' : (board === 'Federal' ? 'Federal Board' : board + ' Board');
    writeFileSync(join(out, key + '.json'), JSON.stringify({
      title: subject + ' Class ' + cls + ' Past Paper ' + year + ' \u2014 ' + boardLabel,
      subject, class: cls, year, boards: [board],
      ...(bise ? { bises: [bise], bise } : {}),
      pdfUrl: view,
    }));
    written++; classes.add(cls);
  }
  console.log('past papers: ' + written + ' written, ' + skipped + ' skipped/duplicate copies');
  return classes;
}

function buildGazettes(csv, out) {
  const seen = new Set(); const classes = new Set();
  let written = 0, skipped = 0;
  for (const c of rows(csv)) {
    if (c.length < 3 || /filename/i.test(c[0])) continue;
    const m = c[0].match(/^(\d{4})_([A-Za-z0-9-]+)_(\d{1,2})_([A-Za-z0-9_]+)\.pdf$/i);
    if (!m) { skipped++; continue; }
    const info = lookup(m[2]); if (!info) { skipped++; continue; }
    const cls = okClass(m[3]); if (!cls) { skipped++; continue; }
    const view = viewOf(c); if (!view) { skipped++; continue; }
    const board = info[0], bise = info[1], year = Number(m[1]);
    const examType = titleCase(m[4]);
    const key = ['gazette', board === 'Federal' ? 'federal' : slug(bise || board), cls, slug(examType), year].join('-');
    if (seen.has(key)) { skipped++; continue; }
    seen.add(key);
    const biseLabel = bise ? bise + ' Board' : (board === 'Federal' ? 'Federal Board' : board + ' Board');
    writeFileSync(join(out, key + '.json'), JSON.stringify({
      title: biseLabel + ' Class ' + cls + ' Result Gazette ' + year + ' (' + examType + ')',
      year, board, boards: [board],
      ...(bise ? { bise } : {}),
      class: cls, examType, driveUrl: view,
    }));
    written++; classes.add(cls);
  }
  console.log('gazettes: ' + written + ' written, ' + skipped + ' skipped/duplicate copies');
  return classes;
}

const pp = process.argv[2], gz = process.argv[3];
const c1 = buildPapers(pp, join(process.cwd(), 'src', 'content', 'past-papers'));
const c2 = buildGazettes(gz, join(process.cwd(), 'src', 'content', 'gazettes'));
console.log('class values now: ' + [...new Set([...c1, ...c2])].sort((a, b) => a - b).join(', '));
