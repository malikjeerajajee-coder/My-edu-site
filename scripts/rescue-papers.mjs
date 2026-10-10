import { readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

const CSV = process.argv[2];
const OUT = join(process.cwd(), 'src', 'content', 'past-papers');
const raw = readFileSync(CSV, 'utf8').replace(/^\uFEFF/, '');
const lines = raw.split(/\r?\n/).filter(l => l.trim());

function cells(line) {
  const sep = line.includes('|') ? '|' : ',';
  const p = line.split(sep).map(c => c.trim());
  if (p[0] === '') p.shift();
  if (p.length && p[p.length - 1] === '') p.pop();
  return p;
}
function driveView(c) {
  for (const cell of c) { const m = cell.match(/drive\.google\.com\/file\/d\/([\w-]+)/); if (m) return 'https://drive.google.com/file/d/' + m[1] + '/view'; }
  for (const cell of c) { const m = cell.match(/[?&]id=([\w-]+)/); if (m) return 'https://drive.google.com/file/d/' + m[1] + '/view'; }
  for (const cell of c) { if (/^[\w-]{20,}$/.test(cell)) return 'https://drive.google.com/file/d/' + cell + '/view'; }
  return '';
}

const BISE_MAP = {
  lahore: ['Punjab','Lahore'], gujranwala: ['Punjab','Gujranwala'], faisalabad: ['Punjab','Faisalabad'],
  multan: ['Punjab','Multan'], rawalpindi: ['Punjab','Rawalpindi'], sargodha: ['Punjab','Sargodha'],
  sahiwal: ['Punjab','Sahiwal'], bahawalpur: ['Punjab','Bahawalpur'], 'dg-khan': ['Punjab','DG Khan'],
  abbottabad: ['KPK','Abbottabad'], bannu: ['KPK','Bannu'], banu: ['KPK','Bannu'],
  'di-khan': ['KPK','DI Khan'], kohat: ['KPK','Kohat'], malakand: ['KPK','Malakand'],
  mardan: ['KPK','Mardan'], peshawar: ['KPK','Peshawar'], swat: ['KPK','Swat'],
  karachi: ['Sindh','Karachi'], hyderabad: ['Sindh','Hyderabad'], sukkur: ['Sindh','Sukkur'],
  larkana: ['Sindh','Larkana'], mirpurkhas: ['Sindh','Mirpurkhas'],
  quetta: ['Balochistan','Quetta'], zhob: ['Balochistan','Zhob'], khuzdar: ['Balochistan','Khuzdar'],
  turbat: ['Balochistan','Turbat'], nasirabad: ['Balochistan','Nasirabad'], loralai: ['Balochistan','Loralai'],
  sibi: ['Balochistan','Sibi'], kalat: ['Balochistan','Kalat'], makran: ['Balochistan','Makran'],
  ajk: ['AJK',null], mirpur: ['AJK','Mirpur'], muzaffarabad: ['AJK','Muzaffarabad'], rawalakot: ['AJK','Rawalakot'],
  fbise: ['Federal',null], federal: ['Federal',null],
};
const lookup = c => BISE_MAP[String(c).toLowerCase()] || null;
const titleCase = s => String(s).toLowerCase().replace(/_/g,' ').split(/\s+/).filter(Boolean).map(w => w[0].toUpperCase()+w.slice(1)).join(' ');
const slug = s => String(s).toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/^-+|-+$/g,'');
const BOARD_SLUG = { Punjab:'punjab', Sindh:'sindh', KPK:'kpk', Balochistan:'balochistan', AJK:'ajk', Federal:'federal' };

function parseName(name) {
  const base = name.replace(/\.[a-z0-9]+$/i, '');
  const tokens = base.split(/[_\s]+/).filter(Boolean);
  let year = null, cls = null, board = null, unknownBoard = null;
  const subj = [];
  for (let i = 0; i < tokens.length; i++) {
    const t = tokens[i], low = t.toLowerCase();
    if (year === null && /^(19|20)\d{2}$/.test(t)) { year = Number(t); continue; }
    if (low === 'unknown' || low === 'board' || low === 'paper' || low === 'year') continue;
    if (cls === null && /^1st$/i.test(t) && /^year$/i.test(tokens[i+1] || '')) { cls = '11'; i++; continue; }
    if (cls === null && /^2nd$/i.test(t) && /^year$/i.test(tokens[i+1] || '')) { cls = '12'; i++; continue; }
    if (cls === null && /^(0?[1-9]|1[0-2])(st|nd|rd|th)?$/i.test(t)) { cls = String(parseInt(t, 10)); continue; }
    if (board === null) {
      let code = null, extra = 0;
      if (/^bise[-_]/i.test(t)) code = t.replace(/^bise[-_]/i, '');
      else if (low === 'fbise' || low === 'federal') code = 'federal';
      else if (BISE_MAP[low]) code = low;
      else if (BISE_MAP[low + '-' + (tokens[i+1] || '').toLowerCase()]) { code = low + '-' + tokens[i+1].toLowerCase(); extra = 1; }
      if (code && lookup(code)) { board = lookup(code); i += extra; continue; }
      if (/^bise[-_]/i.test(t) || low === 'fbise' || low === 'federal') { unknownBoard = t; continue; }
    }
    subj.push(t);
  }
  if (unknownBoard) return { skip: 'unknown board: ' + unknownBoard };
  if (!year) return { skip: 'no year in filename' };
  if (!cls) return { skip: 'no class in filename' };
  if (!board) return { skip: 'no board in filename' };
  return { year, cls, board: board[0], bise: board[1], subject: subj.join(' ') };
}

let written = 0, dupes = 0;
const reasons = {};
const samples = {};
const seen = new Set();

for (const line of lines) {
  const c = cells(line);
  if (c.length < 3 || /file name/i.test(c[0])) continue;
  const view = driveView(c);
  if (!view) { reasons['no Drive link'] = (reasons['no Drive link']||0)+1; (samples['no Drive link'] ||= []).push(c[0]); continue; }
  const r = parseName(c[0]);
  if (r.skip) { reasons[r.skip] = (reasons[r.skip]||0)+1; (samples[r.skip] ||= []).push(c[0]); continue; }
  const folder = c[1] || '';
  const subject = titleCase(/^(19|20)\d{2}$/.test(folder) || !folder ? (r.subject || 'General') : folder);
  const key = [slug(subject), r.cls, BOARD_SLUG[r.board], r.bise ? slug(r.bise) : null, r.year].filter(Boolean).join('-');
  if (seen.has(key)) { dupes++; continue; }
  seen.add(key);
  const boardLabel = r.bise ? r.bise + ' Board' : (r.board === 'Federal' ? 'Federal Board' : r.board + ' Board');
  writeFileSync(join(OUT, key + '.json'), JSON.stringify({
    title: subject + ' Class ' + r.cls + ' Past Paper ' + r.year + ' \u2014 ' + boardLabel,
    subject, class: r.cls, year: r.year, boards: [r.board],
    ...(r.bise ? { bises: [r.bise], bise: r.bise } : {}),
    pdfUrl: view,
  }));
  written++;
}

console.log('✔ imported: ' + written + ' | duplicate copies: ' + dupes);
console.log('── SKIP REPORT (files NOT added and why) ──');
const keys = Object.keys(reasons);
if (!keys.length) console.log('  none — every CSV row was imported!');
keys.forEach(k => {
  console.log('  ' + k + ': ' + reasons[k] + ' file(s)');
  (samples[k] || []).slice(0, 8).forEach(s => console.log('      e.g. ' + s));
});
