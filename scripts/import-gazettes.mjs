import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const CSV = path.join(ROOT, 'pakistani_gazettes_links.csv');
const OUT_DIR = path.join(ROOT, 'src/content/gazettes');

const DRY_RUN = process.argv.includes('--dry-run');
const SKIP_AJK = process.env.SKIP_AJK !== '0'; // default: skip AJK (already hand-curated)

const boardMap = {
  AJK_Board:       { region: 'AJK',         bise: null },
  FBISE:           { region: 'Federal',     bise: null },
  BISE_Abbottabad: { region: 'KPK',         bise: 'Abbottabad' },
  BISE_Bannu:      { region: 'KPK',         bise: 'Bannu' },
  BISE_DI_Khan:    { region: 'KPK',         bise: 'DI Khan' },
  BISE_Kohat:      { region: 'KPK',         bise: 'Kohat' },
  BISE_Malakand:   { region: 'KPK',         bise: 'Malakand' },
  BISE_Mardan:     { region: 'KPK',         bise: 'Mardan' },
  BISE_Peshawar:   { region: 'KPK',         bise: 'Peshawar' },
  BISE_Swat:       { region: 'KPK',         bise: 'Swat' },
  BISE_Bahawalpur: { region: 'Punjab',      bise: 'Bahawalpur' },
  BISE_DG_Khan:    { region: 'Punjab',      bise: 'DG Khan' },
  BISE_Faisalabad: { region: 'Punjab',      bise: 'Faisalabad' },
  BISE_Gujranwala: { region: 'Punjab',      bise: 'Gujranwala' },
  BISE_Lahore:     { region: 'Punjab',      bise: 'Lahore' },
  BISE_Multan:     { region: 'Punjab',      bise: 'Multan' },
  BISE_Rawalpindi: { region: 'Punjab',      bise: 'Rawalpindi' },
  BISE_Sahiwal:    { region: 'Punjab',      bise: 'Sahiwal' },
  BISE_Sargodha:   { region: 'Punjab',      bise: 'Sargodha' },
  BISE_Hyderabad:  { region: 'Sindh',       bise: 'Hyderabad' },
  BISE_Larkana:    { region: 'Sindh',       bise: 'Larkana' },
  BISE_Sukkur:     { region: 'Sindh',       bise: 'Sukkur' },
  BSEK_Karachi:    { region: 'Sindh',       bise: 'Karachi' },
  BISE_Quetta:     { region: 'Balochistan', bise: 'Quetta' },
};

const slugify = s =>
  s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');

function detectSubDistrict(filename) {
  const m = filename.match(/_(ghotki|khairpur)_/i);
  if (!m) return null;
  return m[1][0].toUpperCase() + m[1].slice(1).toLowerCase();
}

// --- read CSV --------------------------------------------------------------
let raw = fs.readFileSync(CSV, 'utf8').replace(/^\uFEFF/, '');
const lines = raw.split(/\r?\n/).filter(l => l.trim().length > 0);
const header = lines.shift().split(',').map(h => h.trim());
const idx = {
  rel: header.indexOf('relative_path'),
  view: header.indexOf('view_link'),
  dl: header.indexOf('direct_download_link'),
  drive: header.indexOf('drive_id'),
};
if (idx.rel < 0 || idx.drive < 0) {
  console.error('ERROR: CSV missing required columns'); process.exit(1);
}

let created = 0, skipped = 0, bad = 0, ajkSkipped = 0;
const seenSlugs = new Set();

for (const line of lines) {
  const cells = line.split(',');
  const rel = cells[idx.rel];
  if (!rel) continue;

  const parts = rel.split('/');
  if (parts.length !== 4) { bad++; continue; }
  const [boardRaw, classRaw, examRaw, filename] = parts;

  if (SKIP_AJK && boardRaw === 'AJK_Board') { ajkSkipped++; continue; }

  const map = boardMap[boardRaw];
  if (!map) { console.warn('Unknown board:', boardRaw, rel); bad++; continue; }

  const classNum = classRaw.match(/^(\d+)/)?.[1];
  const yearMatch = filename.match(/(\d{4})/);
  if (!classNum || !yearMatch) { bad++; continue; }
  const year = parseInt(yearMatch[1], 10);

  let examType = 'annual';
  if (/2nd[_-]?annual|supply/i.test(examRaw))  examType = 'supply';
  else if (/special/i.test(examRaw))           examType = 'special';
  else if (/2nd-annual/i.test(filename))       examType = 'supply';

  let stream = null;
  if (/_science/.test(filename))      stream = 'science';
  else if (/_general/.test(filename)) stream = 'general';

  const subDistrict = detectSubDistrict(filename);

  const anchor = map.bise ? slugify(map.bise) : slugify(map.region);
  let slug = `gazette-${anchor}-${classNum}-${year}`;
  if (examType === 'supply')  slug += '-supply';
  if (examType === 'special') slug += '-special';
  if (stream)                 slug += `-${stream}`;
  if (subDistrict)            slug += `-${slugify(subDistrict)}`;

  const outFile = path.join(OUT_DIR, `${slug}.json`);
  if (seenSlugs.has(slug))  { skipped++; continue; }
  if (fs.existsSync(outFile)) { skipped++; continue; }
  seenSlugs.add(slug);

  const boardLabel = map.bise
    ? `BISE ${map.bise}`
    : (map.region === 'Federal' ? 'Federal Board' : `${map.region} Board`);
  const titleParts = [boardLabel, `Class ${classNum}`, 'Result Gazette', String(year)];
  if (examType === 'supply')  titleParts.push('(2nd Annual / Supply)');
  if (examType === 'special') titleParts.push('(Special)');
  if (stream)                 titleParts.push(`(${stream[0].toUpperCase()}${stream.slice(1)})`);
  if (subDistrict)            titleParts.push(`- ${subDistrict}`);

  const driveId = cells[idx.drive];
  const data = {
    title: titleParts.join(' '),
    year,
    board: map.region,
    boards: [map.region],
    class: classNum,
    examType,
    ...(map.bise    ? { bise: map.bise } : {}),
    ...(stream      ? { stream } : {}),
    ...(subDistrict ? { subDistrict } : {}),
    pdfUrl: `https://drive.google.com/file/d/${driveId}/preview`,
    viewUrl: cells[idx.view],
    downloadUrl: cells[idx.dl],
    driveId,
  };

  if (DRY_RUN) {
    console.log('[dry]', slug);
  } else {
    fs.writeFileSync(outFile, JSON.stringify(data, null, 2) + '\n');
  }
  created++;
}

console.log('---');
console.log(`created:     ${created}`);
console.log(`skipped:     ${skipped}  (already exists or duplicate)`);
console.log(`bad rows:    ${bad}`);
if (SKIP_AJK) console.log(`AJK skipped: ${ajkSkipped}  (set SKIP_AJK=0 to import)`);
if (DRY_RUN) console.log('(dry run — no files written)');
