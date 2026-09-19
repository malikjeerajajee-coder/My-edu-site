#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Fixing audit issues — batch 1"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  Backup
# ─────────────────────────────────────────────
git branch -f backup-pre-audit
git push -u origin backup-pre-audit 2>&1 | tail -2 || echo "  (backup push failed — do manually)"
echo "  ✓ backup-pre-audit created"
echo ""

# ─────────────────────────────────────────────
#  1. FIX SEARCH INDEX — base path + all collections
# ─────────────────────────────────────────────
cat > src/pages/search.json.ts <<'TS'
export const prerender = true;
import { getCollection } from 'astro:content';

export async function GET() {
  const base = import.meta.env.BASE_URL.replace(/\/+$/, '');

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
    ...notes.map((n: any) => ({
      type: 'note',
      title: n.data.title,
      url: `${base}/notes/${n.id}`,
      subject: n.data.subject,
      class: n.data.class,
    })),
    ...quizzes.map((q: any) => ({
      type: 'quiz',
      title: q.data.title,
      url: `${base}/quizzes/${q.id}`,
      subject: q.data.subject,
      class: q.data.class,
    })),
    ...books.map((b: any) => ({
      type: 'book',
      title: b.data.title,
      url: `${base}/books/${b.id}`,
      subject: b.data.subject,
      class: b.data.class,
    })),
    ...gazettes.map((g: any) => ({
      type: 'gazette',
      title: g.data.title,
      url: `${base}/gazettes/${g.id}`,
      subject: g.data.board || '',
      class: g.data.class,
    })),
    ...pastPapers.map((p: any) => ({
      type: 'past-paper',
      title: p.data.title,
      url: `${base}/past-papers/${p.id}`,
      subject: p.data.subject,
      class: p.data.class,
    })),
    ...guessPapers.map((p: any) => ({
      type: 'guess-paper',
      title: p.data.title,
      url: `${base}/guess-papers/${p.id}`,
      subject: p.data.subject,
      class: p.data.class,
    })),
    ...pairingSchemes.map((p: any) => ({
      type: 'pairing-scheme',
      title: p.data.title,
      url: `${base}/pairing-schemes/${p.id}`,
      subject: p.data.board || '',
      class: p.data.class,
    })),
  ];

  return new Response(JSON.stringify(index), {
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
  });
}
TS
echo "  ✓ search.json.ts — base path + 7 collections"

# ─────────────────────────────────────────────
#  2. FIX NOTES INDEX — actual title
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re
p = pathlib.Path('src/pages/notes/index.astro')
if p.exists():
    s = p.read_text()
    s = s.replace(
        '<div class="row-title">{n.data.subject} — Chapter</div>',
        '<div class="row-title">{n.data.title}</div>'
    )
    p.write_text(s)
    print('  ✓ notes index — title fixed')
PY

# ─────────────────────────────────────────────
#  3. FIX BRAND SPLIT — TaleemHub → Parhayi everywhere
# ─────────────────────────────────────────────
echo ""
echo "  Rebranding TaleemHub → Parhayi..."
python3 - <<'PY'
import pathlib

count = 0
for astro in pathlib.Path('src').rglob('*.astro'):
    s = astro.read_text()
    orig = s
    # Replace in titles, meta descriptions, headings, JSON-LD
    s = s.replace('TaleemHub', 'Parhayi')
    s = s.replace('taleemhub', 'parhayi')
    if s != orig:
        astro.write_text(s)
        count += 1
        print(f'    {astro.relative_to("src")}')
print(f'  ✓ Rebranded {count} files')
PY

# ─────────────────────────────────────────────
#  4. FIX FAVICON LINK
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib
p = pathlib.Path('src/layouts/BaseLayout.astro')
s = p.read_text()

if 'rel="icon"' not in s:
    s = s.replace(
        '<link rel="sitemap"',
        '<link rel="icon" type="image/svg+xml" href={url(\'/favicon.svg\')} />\n  <link rel="sitemap"',
        1
    )
    p.write_text(s)
    print('  ✓ favicon linked')
else:
    print('  · favicon already linked')
PY

# ─────────────────────────────────────────────
#  5. FIX BISE PICKER — remove hardcoded "Punjab has 9"
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re

p = pathlib.Path('src/pages/board/[board]/index.astro')
s = p.read_text()

# Replace the hardcoded Punjab text block with dynamic
old = re.compile(
    r'<p class="mt-3 text-sm leading-relaxed text-slate-600 max-w-2xl">\s*Punjab has 9 separate Boards of Intermediate and Secondary Education \(BISEs\)\. Textbooks and syllabus are identical across all 9, but <strong class="text-slate-900">past papers and result gazettes are unique to each board</strong>\. Pick your board to see the right papers\.\s*</p>',
    re.DOTALL
)

new = '''<p class="mt-3 text-sm leading-relaxed text-slate-600 max-w-2xl">
            {board.name} has {getBISEsForProvince(String(slug)).length} separate Boards of Intermediate and Secondary Education (BISEs). Textbooks and syllabus are identical across all of them, but <strong class="text-slate-900">past papers and result gazettes are unique to each board</strong>. Pick your board to see the right papers.
          </p>'''

s2 = old.sub(new, s)

# Replace the "Not sure which BISE" text
old2 = re.compile(
    r'<p class="text-sm text-slate-600">\s*<strong class="text-slate-900">Not sure which BISE\?</strong> The board depends on your school\'s city\. All 9 boards follow the same curriculum, so any paper from any BISE gives you the same topic coverage and difficulty\.\s*</p>',
    re.DOTALL
)
new2 = '''<p class="text-sm text-slate-600">
            <strong class="text-slate-900">Not sure which BISE?</strong> The board depends on your school's city. All {board.name} boards follow the same curriculum, so any paper from any BISE gives you the same topic coverage and difficulty.
          </p>'''
s2 = old2.sub(new2, s2)

if s2 != s:
    p.write_text(s2)
    print('  ✓ BISE picker — dynamic board name')
else:
    print('  · BISE picker text already dynamic or pattern changed')
PY

# ─────────────────────────────────────────────
#  6. FIX PAST-PAPER BREADCRUMB
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib
p = pathlib.Path('src/pages/past-papers/[...slug].astro')
s = p.read_text()

# Add boardBySlug import
if 'boardBySlug' not in s:
    s = s.replace(
        "import { url } from '../../lib/url';",
        "import { url } from '../../lib/url';\nimport { boardBySlug } from '../../lib/boards';"
    )

# Add computed board slug
if 'const boardSlug' not in s:
    s = s.replace(
        "const boardName = d.bise ? `BISE ${d.bise}` : (d.boards?.[0] || 'Punjab Board');",
        """const boardName = d.bise ? `BISE ${d.bise}` : (d.boards?.[0] || 'Punjab Board');
const primaryBoard = (d.boards || [])[0] || 'Punjab';
const boardData = boardBySlug(primaryBoard.toLowerCase());
const boardSlug = boardData?.slug || 'punjab';"""
    )

# Fix breadcrumb
s = s.replace(
    '<a href={url(\'/board/punjab\')} class="hover:text-[#1d4ed8]">Punjab</a>',
    '<a href={url(`/board/${boardSlug}`)} class="hover:text-[#1d4ed8]">{primaryBoard}</a>'
)

p.write_text(s)
print('  ✓ past-paper breadcrumb — dynamic')
PY

# ─────────────────────────────────────────────
#  7. FIX paperContent — board-aware FAQ/intro
# ─────────────────────────────────────────────
cat > src/lib/paperContent.ts <<'TS'
// Curriculum chapters per subject+class
export const CURRICULUM: Record<string, string[]> = {
  'Physics|9': ['Physical Quantities & Measurement','Kinematics','Dynamics','Turning Effect of Forces','Gravitation','Work & Energy','Properties of Matter','Thermal Properties','Transfer of Heat'],
  'Physics|10': ['Simple Harmonic Motion & Waves','Sound','Geometrical Optics','Electrostatics','Current Electricity','Electromagnetism','Basic Electronics','Information & Communication Technology','Radioactivity'],
  'Physics|11': ['Measurements','Vectors & Equilibrium','Motion & Force','Work & Energy','Rotational & Circular Motion','Fluid Dynamics','Oscillations','Waves','Physical Optics','Optical Instruments','Heat & Thermodynamics'],
  'Physics|12': ['Electrostatics','Current Electricity','Electromagnetism','Electromagnetic Induction','Alternating Current','Physics of Solids','Electronics','Dawn of Modern Physics','Atomic Spectra','Nuclear Physics'],
  'Chemistry|9': ['Fundamentals of Chemistry','Structure of Atoms','Periodic Table & Periodicity','Structure of Molecules','Physical States of Matter','Solutions','Electrochemistry','Chemical Reactivity'],
  'Chemistry|10': ['Chemical Equilibrium','Acids, Bases & Salts','Organic Chemistry','Hydrocarbons','Biochemistry','Environmental Chemistry','Water','Chemical Industries'],
  'Chemistry|11': ['Basic Concepts','Experimental Techniques','Gases','Liquids','Solids','Chemical Equilibrium','Reaction Kinetics','Thermochemistry','Electrochemistry','Chemical Bonding','S & p-Block Elements'],
  'Chemistry|12': ['Periodic Classification','s-Block Elements','Group IIIA & IVA','Group VA & VIA','Halogens & Noble Gases','Transition Elements','Fundamental Principles of Organic Chemistry','Aliphatic Hydrocarbons','Aromatic Hydrocarbons','Alkyl Halides','Alcohols, Phenols & Ethers','Carbonyl Compounds','Carboxylic Acids','Macromolecules'],
  'Biology|9': ['Introduction to Biology','Solving a Biological Problem','Biodiversity','Cells & Tissues','Cell Cycle','Enzymes','Bioenergetics','Nutrition','Transport'],
  'Biology|10': ['Gaseous Exchange','Homeostasis','Coordination & Control','Support & Movement','Reproduction','Inheritance','Man & His Environment','Biotechnology'],
  'Biology|11': ['Introduction','Biological Molecules','Enzymes','The Cell','Variety of Life','Kingdom Monera','Kingdom Protista','Kingdom Fungi','Kingdom Plantae','Kingdom Animalia','Bioenergetics'],
  'Biology|12': ['Homeostasis','Support & Movement','Coordination & Control','Reproduction','Growth & Development','Chromosomes & DNA','Evolution','Ecosystem','Some Major Ecosystems','Man & His Environment'],
  'Mathematics|9': ['Matrices & Determinants','Real & Complex Numbers','Logarithms','Algebraic Expressions','Factorization','Algebraic Manipulation','Linear Equations & Inequalities','Linear Graphs & Their Applications','Introduction to Coordinate Geometry'],
  'Mathematics|10': ['Quadratic Equations','Theory of Quadratic Equations','Variations','Partial Fractions','Sets & Functions','Basic Statistics','Introduction to Trigonometry','Projection of a Side of a Triangle','Chords of a Circle','Tangent to a Circle','Chords & Arcs','Angle in a Segment','Practical Geometry — Triangles'],
  'Mathematics|11': ['Number Systems','Sets, Functions & Groups','Matrices & Determinants','Quadratic Equations','Sequences & Series','Permutation & Combination','Mathematical Induction & Binomial Theorem','Mathematical Functions','Linear Programming','Trigonometric Identities','Trigonometric Functions & Their Graphs'],
  'Mathematics|12': ['Functions & Limits','Differentiation','Integration','Introduction to Analytic Geometry','Linear Inequalities & Linear Programming','Conic Sections','Vectors','Introduction to Numerical Methods','Further Applications of Integration'],
  'English|9': ['Reading Comprehension','Vocabulary','Grammar & Structure','Translation','Letter Writing','Story Writing','Essay Writing'],
  'English|10': ['Reading Comprehension','Vocabulary','Grammar & Structure','Translation','Letter Writing','Story Writing','Essay Writing'],
  'English|11': ['Reading Comprehension','Vocabulary','Grammar & Structure','Idioms','Letter & Application Writing','Story Writing','Essay Writing','Translation'],
  'English|12': ['Reading Comprehension','Vocabulary','Grammar & Structure','Idioms','Letter & Application Writing','Story Writing','Essay Writing','Translation'],
  'Urdu|9': ['Nazm','Ghazal','Afsanay','Drama','Grammar','Letter Writing','Essay Writing'],
  'Urdu|10': ['Nazm','Ghazal','Afsanay','Drama','Grammar','Letter Writing','Essay Writing'],
  'Urdu|11': ['Nazm','Ghazal','Afsanay','Drama','Grammar','Letter Writing','Essay Writing','Translation'],
  'Urdu|12': ['Nazm','Ghazal','Afsanay','Drama','Grammar','Letter Writing','Essay Writing','Translation'],
  'Islamiat|9': ['Quran Majeed','Hadith Sharif','Ibadat','Seerat-un-Nabi (SAW)','Akhlaqiat','Social Life'],
  'Islamiat|10': ['Quran Majeed','Hadith Sharif','Ibadat','Seerat-un-Nabi (SAW)','Akhlaqiat','Social Life'],
  'Pakistan Studies|9': ['Ideology of Pakistan','Constitutional Development of Pakistan','Land & People of Pakistan'],
  'Pakistan Studies|10': ['Economic Development of Pakistan','Foreign Policy of Pakistan','Pakistan & the Muslim World'],
  'Computer Science|9': ['Introduction to Computers','Computer Components','Input & Output Devices','Storage Devices','Number Systems','Software','Networking'],
  'Computer Science|10': ['Programming Fundamentals','C Language Basics','Control Structures','Arrays & Strings','Functions','File Handling'],
  'Computer Science|11': ['Computer Basics','Data Communication','Applications & Uses of Computers','Programming in C','Data Types & Operators','Decision Making','Loops','Arrays','Functions'],
  'Computer Science|12': ['Data Basics','Database Systems','Database Design Process','Data Integrity & Normalization','Introduction to Microsoft Access','Programming in C++','Objects & Classes','File Handling in C++'],
};

export function chaptersFor(subject: string, cls: string): string[] | null {
  return CURRICULUM[`${subject}|${cls}`] || null;
}

// ── Board-aware helpers ──
function provinceOf(data: any): string {
  return (data.boards || [])[0] || 'Punjab';
}
function boardLabel(data: any): string {
  const province = provinceOf(data);
  if (data.bise) return `BISE ${data.bise}`;
  return province === 'Federal' ? 'Federal Board (FBISE)' : `${province} Board`;
}

// ── Marks: board-aware ──
export function marksFor(subject: string, cls: string, province?: string): number {
  const isFederal = province === 'Federal';
  const isHSSC = ['11','12'].includes(cls);

  if (isFederal) {
    if (isHSSC) return 100;
    return subject === 'Islamiat' ? 50 : subject === 'Pakistan Studies' ? 50 : 75;
  }

  // Punjab (PCTB) default
  if (isHSSC) {
    if (['Physics','Chemistry','Biology'].includes(subject)) return 85;
    return 100;
  }
  // SSC
  const m: Record<string, number> = {
    Physics: 60, Chemistry: 60, Biology: 60,
    'Computer Science': 60,
    English: 75, Urdu: 75,
    Islamiat: 100, 'Pakistan Studies': 50,
    Mathematics: 75,
    'General Mathematics': 75, 'General Science': 60,
  };
  return m[subject] || 75;
}

export function durationFor(subject: string, cls: string, province?: string): string {
  if (province === 'Federal') {
    return ['11','12'].includes(cls) ? '3 hours' : '2 hours 40 minutes';
  }
  if (['Physics','Chemistry','Biology'].includes(subject) && ['9','10'].includes(cls)) return '2 hours 10 minutes';
  if (subject === 'Islamiat') return '3 hours';
  return '2 hours 30 minutes';
}

// ── Intro: board-aware ──
export function paperIntro(data: any): string {
  const board = boardLabel(data);
  const province = provinceOf(data);
  const exam = ['9','10'].includes(data.class) ? 'SSC' : 'HSSC';
  const part = ['9','11'].includes(data.class) ? 'Part-I' : 'Part-II';

  let provinceContext = '';
  if (province === 'Federal') {
    provinceContext = 'The Federal Board of Intermediate and Secondary Education (FBISE) sets a single unified paper for all its affiliated institutions across Pakistan.';
  } else if (province === 'Punjab') {
    provinceContext = `${board} follows the PBCC (Punjab Boards Committee of Chairpersons) syllabus and paper pattern shared across all 9 Punjab BISEs, but sets its own question paper.`;
  } else if (province === 'Sindh') {
    provinceContext = `Sindh has 5 separate BISEs and this paper is specifically from ${board}.`;
  } else if (province === 'KPK') {
    provinceContext = `Khyber Pakhtunkhwa has 8 separate BISEs; this paper is specifically from ${board}.`;
  } else if (province === 'Balochistan') {
    provinceContext = `Balochistan has 7 separate BISEs; this paper is specifically from ${board}.`;
  } else if (province === 'AJK') {
    provinceContext = `Azad Jammu & Kashmir has 3 separate BISEs; this paper is specifically from ${board}.`;
  }

  return `${data.subject} is a core subject in the Class ${data.class} curriculum under ${board}. ` +
    `This is the official paper set for the ${data.year} ${exam} ${part} annual examination — ` +
    `the paper thousands of Pakistani students actually sat that year. ` +
    `${provinceContext} Studying it gives you the single clearest picture of the difficulty, ` +
    `the question distribution, and the paper pattern used by ${board}.`;
}

// ── FAQ: board-aware ──
export function paperFAQ(data: any): { q: string; a: string }[] {
  const board = boardLabel(data);
  const province = provinceOf(data);
  const marks = marksFor(data.subject, data.class, province);
  const dur = durationFor(data.subject, data.class, province);

  const sameAcrossQuestion = province === 'Punjab'
    ? `Is this paper the same across all Punjab boards?`
    : province === 'Federal'
    ? `Does FBISE set one paper for the whole country?`
    : `Is this paper the same across all ${province} boards?`;

  const sameAcrossAnswer = province === 'Punjab'
    ? (data.bise
        ? `No. Each of the 9 Punjab BISEs — Lahore, Gujranwala, Multan, Faisalabad, Rawalpindi, Sargodha, Bahawalpur, DG Khan and Sahiwal — sets its own questions from the same PBCC syllabus. This is specifically the ${data.year} paper from BISE ${data.bise}.`
        : `This paper is from ${board}.`)
    : province === 'Federal'
    ? `Yes. FBISE sets a single unified paper for every affiliated school and college across Pakistan, whether in Islamabad, cantonments, or overseas. This is the ${data.year} paper.`
    : `No. ${province} has multiple separate BISEs, each setting its own paper from the shared provincial syllabus. This is specifically the ${data.year} paper from ${board}.`;

  return [
    { q: sameAcrossQuestion, a: sameAcrossAnswer },
    { q: `What is the total marks for ${data.subject} Class ${data.class}?`, a: `${marks} marks.` },
    { q: `How long do students get to complete the paper?`, a: `${dur}.` },
    { q: `Where can I find papers from other years?`, a: `All ${data.subject} papers for ${board} are available on this site — see the related papers section below.` },
    { q: `Does this download include answers?`, a: `No, this is the question paper as it was originally printed. For detailed explanations, browse the ${data.subject} Class ${data.class} notes on this site.` },
  ];
}
TS

# Update PaperEnrichment to pass province
python3 - <<'PY'
import pathlib
p = pathlib.Path('src/components/PaperEnrichment.astro')
s = p.read_text()
s = s.replace(
    "const marks = marksFor(d.subject, d.class);\nconst duration = durationFor(d.subject, d.class);",
    "const province = (d.boards || [])[0] || 'Punjab';\nconst marks = marksFor(d.subject, d.class, province);\nconst duration = durationFor(d.subject, d.class, province);"
)
p.write_text(s)
print('  ✓ PaperEnrichment — passes province')
PY
echo "  ✓ paperContent.ts — board-aware"

# ─────────────────────────────────────────────
#  8. FIX guess/pairing download buttons
# ─────────────────────────────────────────────
for f in 'src/pages/guess-papers/[...slug].astro' 'src/pages/pairing-schemes/[...slug].astro'; do
  python3 - "$f" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
if not p.exists():
    sys.exit(0)
s = p.read_text()
if 'href={' in s and 'pdfUrl' in s:
    print(f'  · {sys.argv[1]} — already wired')
else:
    # Replace href="#" with href={url(d.pdfUrl)}
    s = s.replace('href="#"', 'href={url(d.pdfUrl)}')
    # Ensure url import exists
    if "from '../../lib/url'" not in s and "from '../../lib/url'" not in s:
        if "import Icon" in s:
            s = s.replace(
                "import Icon from '../../components/Icon.astro';",
                "import Icon from '../../components/Icon.astro';\nimport { url } from '../../lib/url';"
            )
    p.write_text(s)
    print(f'  ✓ {sys.argv[1]} — pdfUrl wired')
PY
done

# ─────────────────────────────────────────────
#  9. FIX FBSE typo
# ─────────────────────────────────────────────
grep -rl "FBSE" src/ 2>/dev/null | while read f; do
  sed -i 's/FBSE/FBISE/g' "$f"
  echo "  ✓ Fixed FBSE → FBISE in $f"
done

# ─────────────────────────────────────────────
#  10. FIX BISE class page subject links
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re
p = pathlib.Path('src/pages/board/[board]/[bise]/[class]/index.astro')
s = p.read_text()

# Find the subject grid that links everything to /past-papers
old_pattern = re.compile(
    r'<a href=\{url\(`/board/\$\{board\.slug\}/\$\{bise\.slug\}/class-\$\{cls\}/past-papers`\)\} class="row group">',
    re.DOTALL
)
new_link = '<a href={url(`/board/${board.slug}/${bise.slug}/class-${cls}/past-papers?subject=${encodeURIComponent(s)}`)} class="row group">'
s2 = old_pattern.sub(new_link, s)

# Also add url import if missing
if 'from' in s and "lib/url" not in s:
    s2 = s2.replace(
        "import Icon from '../../../../../components/Icon.astro';",
        "import Icon from '../../../../../components/Icon.astro';\nimport { url } from '../../../../../lib/url';"
    )

if s2 != s:
    p.write_text(s2)
    print('  ✓ BISE class page — subject filter links')
else:
    print('  · BISE subject grid pattern not matched')
PY

# ─────────────────────────────────────────────
#  11. CLEAN ICON DUPLICATES
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re
p = pathlib.Path('src/components/Icon.astro')
s = p.read_text()

# Find the icons object and dedupe keys
# Match key: 'value',
pattern = re.compile(r"^\s*'?([\w-]+)'?:\s*'([^']*)',?\s*$", re.MULTILINE)

# Extract icons block
icons_match = re.search(r'const icons: Record<string, string> = \{([\s\S]*?)\};', s)
if icons_match:
    block = icons_match.group(1)
    entries = re.findall(r"^\s*'?([\w-]+)'?:\s*'(.*?)',?\s*$", block, re.MULTILINE)
    seen = {}
    for k, v in entries:
        if k not in seen:
            seen[k] = v
    # Rebuild
    new_block = '\n' + '\n'.join(f"  '{k}': '{v}'," for k, v in seen.items()) + '\n'
    s = s.replace(icons_match.group(0), f'const icons: Record<string, string> = {{{new_block}}};')
    p.write_text(s)
    print(f'  ✓ Icon.astro — deduplicated ({len(entries)} → {len(seen)} entries)')
else:
    print('  · Icon block not matched')
PY

# ─────────────────────────────────────────────
#  12. REBUILD
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding (2-3 min)..."
npm run build 2>&1 | tail -8

echo ""
echo "════════════════════════════════════════════════════════"
echo "  AUDIT FIX BATCH 1 — DONE"
echo "════════════════════════════════════════════════════════"
echo ""
echo "  Preview:"
echo "    pkill -f 'astro dev' || true"
echo "    npm run dev"
echo ""
echo "  Verify these fixes:"
echo "    1. /search  → search something, click result — should load, not 404"
echo "    2. /notes   → note cards show title, not 'Subject — Chapter'"
echo "    3. Any page → <title> says Parhayi"
echo "    4. Browser tab → favicon appears"
echo "    5. /board/sindh → text says 'Sindh has 5 BISEs'"
echo "    6. /past-papers/<federal-paper> → breadcrumb shows 'Federal', not 'Punjab'"
echo "    7. /past-papers/<federal-paper> → FAQ says 'FBISE', not 'Punjab BISEs'"
echo "    8. /board/sindh/karachi/class-10 → subject grid links filter by subject"
echo "    9. /guess-papers/<id> → download button opens the PDF"
echo ""
echo "  Push only after previewing:"
echo "    git add ."
echo "    git commit -m 'Fix audit bugs: search 404, brand, board-aware content'"
echo "    git push"
echo ""
echo "  Revert if needed:"
echo "    git fetch origin backup-pre-audit && git checkout backup-pre-audit"
echo "════════════════════════════════════════════════════════"