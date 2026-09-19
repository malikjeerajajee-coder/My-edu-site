#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  Parhayi (My-edu-site) — one-shot fix script
#  Fixes the critical bugs, SEO and performance issues from the audit.
#
#  Usage:
#    bash fix-all.sh             # apply fixes only
#    bash fix-all.sh --build     # apply fixes, then run npm run build
#
#  Safe to re-run (idempotent). Creates a timestamped backup first.
# ═══════════════════════════════════════════════════════════════════
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

DO_BUILD=0
for arg in "$@"; do
  case "$arg" in --build) DO_BUILD=1 ;; esac
done

echo "═══════════════════════════════════════════════"
echo "  Parhayi site — automated fix script"
echo "═══════════════════════════════════════════════"

# ── Preflight ──────────────────────────────────────────────────────
command -v node >/dev/null 2>&1 || { echo "✘ Node.js is required"; exit 1; }
[ -f astro.config.mjs ] || { echo "✘ Run this from the project root (astro.config.mjs not found)"; exit 1; }
[ -d src ] || { echo "✘ src/ not found — run from project root"; exit 1; }
if [ -d .git ] && ! git diff --quiet 2>/dev/null; then
  echo "  ⚠ You have uncommitted git changes (script makes its own backup anyway)."
fi

# ── Backup ─────────────────────────────────────────────────────────
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="fix-backup-$STAMP"
mkdir -p "$BACKUP"
cp -r src "$BACKUP/src"
cp astro.config.mjs "$BACKUP/astro.config.mjs"
echo "✔ Backup created → ./$BACKUP/"

# ═══════════════════════════════════════════════════════════════════
# FIX 1 — Search: 404 links + missing collections (full rewrite)
# ═══════════════════════════════════════════════════════════════════
echo ""
echo "▶ Rewriting src/pages/search.json.ts"
cat > src/pages/search.json.ts <<'TSEOF'
export const prerender = true;

import { getCollection } from 'astro:content';

const base = (import.meta.env.BASE_URL || '/').replace(/\/+$/, '');

export async function GET() {
  const [notes, quizzes, books, gazettes, pastPapers, guessPapers, pairingSchemes] =
    await Promise.all([
      getCollection('notes'),
      getCollection('quizzes'),
      getCollection('books'),
      getCollection('gazettes'),
      getCollection('pastPapers'),
      getCollection('guessPapers'),
      getCollection('pairingSchemes'),
    ]);

  const index = [
    ...notes.map((n: any) => ({ type: 'note', title: n.data.title, url: `${base}/notes/${n.id}`, subject: n.data.subject, class: n.data.class })),
    ...quizzes.map((q: any) => ({ type: 'quiz', title: q.data.title, url: `${base}/quizzes/${q.id}`, subject: q.data.subject, class: q.data.class })),
    ...books.map((b: any) => ({ type: 'book', title: b.data.title, url: `${base}/books/${b.id}`, subject: b.data.subject, class: b.data.class })),
    ...gazettes.map((g: any) => ({ type: 'gazette', title: g.data.title, url: `${base}/gazettes/${g.id}`, subject: g.data.board, class: g.data.class })),
    ...pastPapers.map((p: any) => ({ type: 'past-paper', title: p.data.title, url: `${base}/past-papers/${p.id}`, subject: p.data.subject, class: p.data.class })),
    ...guessPapers.map((p: any) => ({ type: 'guess-paper', title: p.data.title, url: `${base}/guess-papers/${p.id}`, subject: p.data.subject, class: p.data.class })),
    ...pairingSchemes.map((p: any) => ({ type: 'pairing-scheme', title: p.data.title, url: `${base}/pairing-schemes/${p.id}`, subject: '', class: p.data.class })),
  ];

  return new Response(JSON.stringify(index), {
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
  });
}
TSEOF
echo "  ✔ search.json.ts — base path fixed, all 7 collections indexed"

# ═══════════════════════════════════════════════════════════════════
# FIX 2…N — surgical patches (Node: exact-string, idempotent)
# ═══════════════════════════════════════════════════════════════════
echo ""
echo "▶ Applying source patches"
node <<'NODEOF'
const fs = require('fs');
const path = require('path');
const ROOT = process.cwd();
let applied = 0, already = 0;
const problems = [];

function patch(file, find, replace, label) {
  const fp = path.join(ROOT, file);
  if (!fs.existsSync(fp)) { problems.push('missing file: ' + file + ' (' + label + ')'); return; }
  let src = fs.readFileSync(fp, 'utf8');
  if (src.includes(replace)) { console.log('  = already applied: ' + label); already++; return; }
  if (!src.includes(find))   { problems.push('pattern not found: ' + label + '  (' + file + ')'); return; }
  fs.writeFileSync(fp, src.split(find).join(replace));
  console.log('  ✔ ' + label);
  applied++;
}

function walk(dir, out) {
  out = out || [];
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) walk(p, out);
    else if (/\.(astro|ts|tsx|js|mjs|cjs|css|md)$/.test(e.name)) out.push(p);
  }
  return out;
}

/* ── Brand: TaleemHub → Parhayi everywhere ── */
console.log('\n  [1/9] Brand unification');
let brandFixed = 0;
for (const f of walk(path.join(ROOT, 'src'))) {
  const s = fs.readFileSync(f, 'utf8');
  if (s.includes('TaleemHub')) {
    fs.writeFileSync(f, s.split('TaleemHub').join('Parhayi'));
    console.log('  ✔ ' + path.relative(ROOT, f));
    brandFixed++;
  }
}
if (!brandFixed) console.log('  = brand already unified');
applied += brandFixed;

/* ── Icon.astro: remove duplicated keys (keeps first occurrence) ── */
console.log('\n  [2/9] Icon.astro duplicate keys');
{
  const iconPath = path.join(ROOT, 'src/components/Icon.astro');
  const dups = [
    "expand: '<path d=\"M15 3h6v6\"/><path d=\"M9 21H3v-6\"/><path d=\"M21 3l-7 7\"/><path d=\"M3 21l7-7\"/>',",
    "'external-link': '<path d=\"M15 3h6v6\"/><path d=\"M10 14 21 3\"/><path d=\"M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6\"/>',",
    "'file-pdf': '<path d=\"M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z\"/><path d=\"M14 2v4a2 2 0 0 0 2 2h4\"/><path d=\"M9 13h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1H9\"/><path d=\"M15 13h-1v5h1a2 2 0 0 0 2-2v-1a2 2 0 0 0-2-2Z\"/>',"
  ];
  if (fs.existsSync(iconPath)) {
    let s = fs.readFileSync(iconPath, 'utf8');
    let removed = 0;
    for (const needle of dups) {
      const first = s.indexOf(needle);
      const last = s.lastIndexOf(needle);
      if (first !== -1 && last > first) {
        const lineStart = s.lastIndexOf('\n', last - 1) + 1;
        let lineEnd = s.indexOf('\n', last);
        lineEnd = lineEnd === -1 ? s.length : lineEnd + 1;
        s = s.slice(0, lineStart) + s.slice(lineEnd);
        removed++;
      }
    }
    if (removed) { fs.writeFileSync(iconPath, s); applied++; console.log('  ✔ removed ' + removed + ' duplicate icon keys'); }
    else { already++; console.log('  = no duplicates found'); }
  } else problems.push('missing file: src/components/Icon.astro');
}

/* ── Critical UI bugs ── */
console.log('\n  [3/9] Critical bugs');
patch('src/pages/guess-papers/[...slug].astro',
  `<a href="#" target="_blank"`, `<a href={url(d.pdfUrl)} target="_blank"`,
  'guess papers: dead "#" button → real PDF link');
patch('src/pages/pairing-schemes/[...slug].astro',
  `<a href="#" target="_blank"`, `<a href={url(d.pdfUrl)} target="_blank"`,
  'pairing schemes: dead "#" button → real PDF link');
patch('src/pages/notes/index.astro',
  `<div class="row-title">{n.data.subject} — Chapter</div>`,
  `<div class="row-title">{n.data.title}</div>`,
  'notes list: show real note title');
patch('src/pages/class/[class].astro',
  `Federal (FBSE)`, `Federal (FBISE)`,
  'typo FBSE → FBISE');

/* ── <head>: favicon, og:image, twitter:image ── */
console.log('\n  [4/9] Head tags (favicon + social images)');
patch('src/layouts/BaseLayout.astro',
  `<meta name="theme-color" content="#1d4ed8" />`,
  `<meta name="theme-color" content="#1d4ed8" />\n    <link rel="icon" type="image/svg+xml" href={url('/favicon.svg')} />`,
  'favicon <link> added');
patch('src/components/SeoHead.astro',
  `<meta property="og:locale" content="en_PK" />`,
  `<meta property="og:locale" content="en_PK" />\n<meta property="og:image" content={SITE + BASE + '/og.png'} />`,
  'og:image added');
patch('src/components/SeoHead.astro',
  `<meta name="twitter:description" content={description} />`,
  `<meta name="twitter:description" content={description} />\n<meta name="twitter:image" content={SITE + BASE + '/og.png'} />`,
  'twitter:image added');

/* ── Performance config ── */
console.log('\n  [5/9] Performance');
patch('astro.config.mjs',
  `prefetch: { prefetchAll: true, defaultStrategy: 'viewport' },`,
  `prefetch: { prefetchAll: false, defaultStrategy: 'hover' },`,
  'stop pre-downloading PDFs (prefetchAll → false)');
patch('astro.config.mjs',
  `trailingSlash: 'ignore',`,
  `trailingSlash: 'always',`,
  'trailingSlash matches canonicals/sitemap');
{
  const f = 'src/layouts/BaseLayout.astro';
  const fp = path.join(ROOT, f);
  if (fs.existsSync(fp)) {
    const src = fs.readFileSync(fp, 'utf8');
    const re = /^[ \t]*<link rel="preload" as="style"[^>\n]*>\r?\n/m;
    if (re.test(src)) { fs.writeFileSync(fp, src.replace(re, '')); applied++; console.log('  ✔ removed redundant Google Fonts preload'); }
    else { already++; console.log('  = font preload already removed'); }
  }
}

/* ── Board-aware content fixes ── */
console.log('\n  [6/9] Board-aware text (no more Punjab hardcoding)');
patch('src/pages/board/[board]/index.astro',
  `Punjab has 9 separate Boards of Intermediate and Secondary Education (BISEs)`,
  `{board.name} has {getBISEsForProvince(String(slug)).length} separate Boards of Intermediate and Secondary Education (BISEs)`,
  'BISE picker count is now dynamic');
patch('src/pages/board/[board]/index.astro',
  `identical across all 9, but`, `identical across all of them, but`,
  'BISE picker wording generalized');
patch('src/pages/board/[board]/index.astro',
  `All 9 boards follow the same curriculum`, `All boards follow the same curriculum`,
  'BISE note wording generalized');
patch('src/pages/past-papers/[...slug].astro',
  `import { url } from '../../lib/url';`,
  `import { url } from '../../lib/url';\nimport { boardByName } from '../../lib/boards';`,
  'paper page: import boardByName');
patch('src/pages/past-papers/[...slug].astro',
  `href={url('/board/punjab')}`,
  "href={url(`/board/${(boardByName(d.boards?.[0] || '') || { slug: 'punjab' }).slug}`)}",
  'paper breadcrumb: board link is now dynamic');
patch('src/lib/paperContent.ts',
  "q: `Is this paper the same across all Punjab boards?`,",
  "q: data.bise ? `Is this paper the same across all ${data.boards?.[0] || 'Punjab'} boards?` : `Is this paper used across all ${boardName} centres?`,",
  'paper FAQ question is board-aware');
patch('src/lib/paperContent.ts',
  `No. Each of the 9 Punjab BISEs — Lahore, Gujranwala, Multan, Faisalabad, Rawalpindi, Sargodha, Bahawalpur, DG Khan and Sahiwal — sets its own questions from the same PBCC syllabus.`,
  "No. Each BISE in ${data.boards?.[0] || 'Punjab'} sets its own questions from the same shared syllabus.",
  'paper FAQ answer is board-aware');
patch('src/components/PaperEnrichment.astro',
  `The full Class {d.class} {d.subject} curriculum prescribed by the Punjab Curriculum and Textbook Board (PCTB) / Federal Board.`,
  `The full Class {d.class} {d.subject} curriculum prescribed by the relevant provincial textbook board.`,
  'enrichment fallback generalized');

/* ── Filters & links ── */
console.log('\n  [7/9] Filters & broken/hardcoded links');
patch('src/components/PageFilter.astro',
  `if (target !== String(active[k]).toLowerCase()) { matches = false; break; }`,
  "if (target.split(/\\s+/).indexOf(String(active[k]).toLowerCase()) === -1) { matches = false; break; }",
  'PageFilter supports multi-value attributes');
patch('src/pages/books/index.astro',
  `data-board={(b.data.boards || [])[0]}`,
  `data-board={(b.data.boards || []).join(' ')}`,
  'books: filter matches every tagged board');
patch('src/pages/board/[board]/[bise]/[class]/index.astro',
  "<a href={url(`/board/${board.slug}/${bise.slug}/class-${cls}/past-papers`)} class=\"row group\">",
  "<a href={url(`/board/${board.slug}/${bise.slug}/class-${cls}/past-papers?subject=${encodeURIComponent(s)}`)} class=\"row group\">",
  'BISE class page: subject cards now deep-link to subject');
patch('src/pages/gazettes/[...slug].astro',
  `import Icon from '../../components/Icon.astro';`,
  `import Icon from '../../components/Icon.astro';\nimport { url } from '../../lib/url';`,
  'gazette page: import url()');
patch('src/pages/gazettes/[...slug].astro',
  `<a href="/" class="transition-colors hover:text-[#110176]">Home</a>`,
  `<a href={url('/')} class="transition-colors hover:text-[#110176]">Home</a>`,
  'gazette page: Home link uses url()');
patch('src/pages/gazettes/[...slug].astro',
  `<a href="/gazettes" class="transition-colors hover:text-[#110176]">Gazettes</a>`,
  `<a href={url('/gazettes')} class="transition-colors hover:text-[#110176]">Gazettes</a>`,
  'gazette page: breadcrumb uses url()');
patch('src/pages/gazettes/[...slug].astro',
  `<a href="/gazettes" class="mb-6 inline-flex items-center gap-2 text-sm font-semibold text-neutral-500 transition-colors hover:text-rose-700">`,
  `<a href={url('/gazettes')} class="mb-6 inline-flex items-center gap-2 text-sm font-semibold text-neutral-500 transition-colors hover:text-rose-700">`,
  'gazette page: back link uses url()');
patch('src/pages/gazettes/[...slug].astro',
  `href={gazette.data.pdfUrl}`, `href={url(gazette.data.pdfUrl)}`,
  'gazette page: PDF link via url()');
patch('src/pages/notes/[...slug].astro',
  `import Icon from '../../components/Icon.astro';`,
  `import Icon from '../../components/Icon.astro';\nimport { url } from '../../lib/url';`,
  'note page: import url()');
patch('src/pages/notes/[...slug].astro',
  `<a href="/" class="transition-colors hover:text-[#110176]">Home</a>`,
  `<a href={url('/')} class="transition-colors hover:text-[#110176]">Home</a>`,
  'note page: Home link uses url()');
patch('src/pages/notes/[...slug].astro',
  `<a href="/notes" class="transition-colors hover:text-[#110176]">Notes</a>`,
  `<a href={url('/notes')} class="transition-colors hover:text-[#110176]">Notes</a>`,
  'note page: breadcrumb uses url()');
patch('src/pages/notes/[...slug].astro',
  `<a href="/notes" class="mb-6 inline-flex items-center gap-2 text-sm font-semibold text-neutral-500 transition-colors hover:text-[#110176]">`,
  `<a href={url('/notes')} class="mb-6 inline-flex items-center gap-2 text-sm font-semibold text-neutral-500 transition-colors hover:text-[#110176]">`,
  'note page: back link uses url()');
patch('src/pages/notes/[...slug].astro',
  `href={note.data.pdfUrl}`, `href={url(note.data.pdfUrl)}`,
  'note page: PDF link via url()');
patch('src/pages/quizzes/[...slug].astro',
  `import Icon from '../../components/Icon.astro';`,
  `import Icon from '../../components/Icon.astro';\nimport { url } from '../../lib/url';`,
  'quiz page: import url()');
patch('src/pages/quizzes/[...slug].astro',
  `<a href="/" class="transition-colors hover:text-[#110176]">Home</a>`,
  `<a href={url('/')} class="transition-colors hover:text-[#110176]">Home</a>`,
  'quiz page: Home link uses url()');
patch('src/pages/quizzes/[...slug].astro',
  `<a href="/quizzes" class="transition-colors hover:text-[#110176]">Quizzes</a>`,
  `<a href={url('/quizzes')} class="transition-colors hover:text-[#110176]">Quizzes</a>`,
  'quiz page: breadcrumb uses url()');
patch('src/pages/gazettes/[...slug].astro', `class="mt-4 font-display text-2xl`, `class="mt-4 text-2xl`, 'gazette page: dead font-display class removed');
patch('src/pages/notes/[...slug].astro',    `class="mt-4 font-display text-2xl`, `class="mt-4 text-2xl`, 'note page: dead font-display class removed');
patch('src/pages/quizzes/[...slug].astro',  `class="mt-4 font-display text-2xl`, `class="mt-4 text-2xl`, 'quiz page: dead font-display class removed');

/* ── SEO: noindex for empty generated pages ── */
console.log('\n  [8/9] noindex for empty pages');
patch('src/layouts/BaseLayout.astro',
  `interface Props { title: string; description?: string; jsonLd?: any; }`,
  `interface Props { title: string; description?: string; noindex?: boolean; jsonLd?: any; }`,
  'BaseLayout: noindex prop (interface)');
{
  const f = 'src/layouts/BaseLayout.astro';
  const fp = path.join(ROOT, f);
  if (fs.existsSync(fp)) {
    let src = fs.readFileSync(fp, 'utf8');
    if (src.includes('noindex = false')) { console.log('  = already applied: BaseLayout noindex destructure'); already++; }
    else if (/const\s*\{\s*title,\s*jsonLd,/.test(src)) {
      fs.writeFileSync(fp, src.replace(/const\s*\{\s*title,\s*jsonLd,/, 'const {\n  title,\n  noindex = false,\n  jsonLd,'));
      console.log('  ✔ BaseLayout: noindex prop (destructure)'); applied++;
    } else problems.push('destructure pattern not found (BaseLayout noindex)');
  }
}
patch('src/layouts/BaseLayout.astro',
  `<SeoHead title={title} description={description} jsonLd={jsonLd} />`,
  `<SeoHead title={title} description={description} noindex={noindex} jsonLd={jsonLd} />`,
  'BaseLayout: noindex passed to SeoHead');
patch('src/pages/board/[board]/[bise]/[class]/[type].astro',
  "description={`All Class ${cls} ${typeLabel.toLowerCase()} for ${bise!.name} Board (${board!.full}). Filter by subject and year. Free PDF downloads.`}",
  "description={`All Class ${cls} ${typeLabel.toLowerCase()} for ${bise!.name} Board (${board!.full}). Filter by subject and year. Free PDF downloads.`}\n  noindex={items.length === 0}",
  'BISE type pages: noindex when empty');
patch('src/pages/board/[board]/[bise]/[class]/index.astro',
  "description={`All Class ${cls} past papers and result gazettes for ${bise.name} Board (${board.full}). Download free PDFs, 2018 to 2026.`}",
  "description={`All Class ${cls} past papers and result gazettes for ${bise.name} Board (${board.full}). Download free PDFs, 2018 to 2026.`}\n  noindex={papers.length + gazettes.length === 0}",
  'BISE class hubs: noindex when empty');
patch('src/pages/board/[board]/[bise]/index.astro',
  "description={`Download past papers and result gazettes for ${bise.name} Board (${board.full}). Class 9 and Class 10, 2018 to 2026. Free PDFs.`}",
  "description={`Download past papers and result gazettes for ${bise.name} Board (${board.full}). Class 9 and Class 10, 2018 to 2026. Free PDFs.`}\n  noindex={papers.length + gazettes.length === 0}",
  'BISE hubs: noindex when empty');

/* ── Homepage + a11y copy fixes ── */
console.log('\n  [9/9] Homepage & misc');
patch('src/pages/index.astro',
  `a: 'Class 9, 10, 11 and 12 (Matric and Intermediate). Resources are organised by class first, so you only see content that applies to you.'`,
  `a: 'Textbooks are available for Class 1 to 12, and exam resources — notes, past papers, guess papers and quizzes — cover Class 9, 10, 11 and 12 (Matric and Intermediate).'`,
  'homepage FAQ matches the Class 1–12 grid');
patch('src/pages/search.astro',
  `<div id="status" class="mt-6 text-sm font-semibold text-slate-500">`,
  `<div id="status" aria-live="polite" class="mt-6 text-sm font-semibold text-slate-500">`,
  'search results announced to screen readers');

console.log('\n  ─────────────────────────────────────────');
console.log('  Patches applied : ' + applied);
console.log('  Already applied : ' + already);
if (problems.length) {
  console.log('  ⚠ Could not apply (check manually):');
  problems.forEach(p => console.log('    - ' + p));
}
NODEOF

# ═══════════════════════════════════════════════════════════════════
# Verify
# ═══════════════════════════════════════════════════════════════════
echo ""
echo "▶ Verifying"
v_has() { if grep -rqF -- "$3" "$2" 2>/dev/null; then echo "  ✔ $1"; else echo "  ✘ $1"; fi; }
v_not() { if grep -rqF -- "$3" "$2" 2>/dev/null; then echo "  ✘ $1"; else echo "  ✔ $1"; fi; }

v_not "brand unified (no TaleemHub left)"            src "TaleemHub"
v_not "dead PDF buttons gone (guess papers)"         "src/pages/guess-papers" 'href="#"'
v_not "dead PDF buttons gone (pairing schemes)"      "src/pages/pairing-schemes" 'href="#"'
v_not "notes list title bug gone"                    "src/pages/notes/index.astro" '{n.data.subject} — Chapter'
v_has "favicon linked"                               "src/layouts/BaseLayout.astro" 'rel="icon"'
v_has "og:image present"                             "src/components/SeoHead.astro" 'og:image'
v_has "search index includes past papers"            "src/pages/search.json.ts" 'pastPapers'
v_has "prefetch limited"                             "astro.config.mjs" 'prefetchAll: false'
v_has "trailing slash consistent"                    "astro.config.mjs" "trailingSlash: 'always'"
v_has "dynamic board breadcrumb"                     "src/pages/past-papers/[...slug].astro" 'boardByName'

if [ ! -f public/og.png ]; then
  echo "  ⚠ public/og.png missing — og:image tags are wired; add a 1200×630 PNG at public/og.png"
fi

# ═══════════════════════════════════════════════════════════════════
# Optional build
# ═══════════════════════════════════════════════════════════════════
if [ "$DO_BUILD" = "1" ]; then
  echo ""
  echo "▶ Building (npm run build)"
  npm run build
fi

echo ""
echo "═══════════════════════════════════════════════"
echo "  Done. Manual steps the script cannot do:"
echo "═══════════════════════════════════════════════"
echo "  1. Add public/og.png (1200×630) — og:image tags are already wired."
echo "  2. Run: npm run build && npm run preview → open a quiz page and"
echo "     confirm QuizPlayer works (define:vars + is:inline risk)."
echo "  3. Verify marks data: lib/paperContent.ts says 65, lib/boardInfo.ts"
echo "     says 60 for Physics/Chem/Bio — confirm against official PBCC scheme."
echo "  4. Add BOARD_INFO for federal / sindh / kpk / balochistan / ajk"
echo "     (only Punjab exists today)."
echo "  5. Add About / Contact / Privacy pages + footer links (E-E-A-T)."
echo "  6. Register in Google Search Console and submit sitemap-index.xml."
echo "  7. Update stale dates: '2026 exams are scheduled…' is now past tense."
echo ""
echo "  If anything goes wrong: delete src + astro.config.mjs and restore"
echo "  from ./$BACKUP/"