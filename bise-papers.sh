#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  BISE papers + gazettes (2018–2026)"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  1. Add BISE helper to boards.ts
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib
p = pathlib.Path('src/lib/boards.ts')
s = p.read_text()

if 'getBiseByName' not in s:
    s += '''

export function getBiseByName(name: string) {
  return PUNJAB_BISES.find(b => b.name.toLowerCase() === name.toLowerCase());
}
'''
    p.write_text(s)
    print('  ✓ getBiseByName added')
PY

# ─────────────────────────────────────────────
#  2. Create BISE route tree under Punjab
# ─────────────────────────────────────────────
mkdir -p 'src/pages/board/punjab/[bise]/[class]'

# ── BISE hub page ──
cat > 'src/pages/board/punjab/[bise]/index.astro' <<'ASTRO'
---
import BaseLayout from '../../../../layouts/BaseLayout.astro';
import Icon from '../../../../components/Icon.astro';
import { url } from '../../../../lib/url';
import { PUNJAB_BISES, biseBySlug } from '../../../../lib/boards';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  return PUNJAB_BISES.map(b => ({ params: { bise: b.slug } }));
}

const { bise: biseSlug } = Astro.params;
const bise = biseBySlug(biseSlug!);
if (!bise) return Astro.redirect('/board/punjab');

const allPapers = await getCollection('pastPapers');
const allGazettes = await getCollection('gazettes');

// Filter to this BISE
const papers = allPapers.filter((p: any) => p.data.bise === bise.name);
const gazettes = allGazettes.filter((g: any) => g.data.bise === bise.name);

// Classes with content
const classSet = new Set<string>();
[...papers, ...gazettes].forEach((i: any) => classSet.add(i.data.class));
const classes = [...classSet].sort((a, b) => Number(a) - Number(b));
---
<BaseLayout
  title={`BISE ${bise.name} — Class 9 & 10 Past Papers & Gazettes | TaleemHub`}
  description={`All past papers and result gazettes for BISE ${bise.name}, Punjab Board. Class 9 and Class 10, 2018 to 2026.`}
>
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/boards')} class="hover:text-[#1d4ed8]">Boards</a>
        <span>/</span>
        <a href={url('/board/punjab')} class="hover:text-[#1d4ed8]">Punjab</a>
        <span>/</span>
        <span class="text-slate-500">BISE {bise.name}</span>
      </nav>
      <div class="max-w-2xl">
        <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">BISE {bise.name}</h1>
        <p class="mt-3 text-base text-slate-600">
          Punjab Board · {classes.length} {classes.length === 1 ? 'class' : 'classes'} · {papers.length + gazettes.length} items
        </p>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
    <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Pick your class</h2>
    {classes.length === 0 ? (
      <div class="mt-6 rounded-xl border border-dashed border-slate-300 bg-white p-12 text-center">
        <p class="text-sm font-bold text-slate-900">No content yet for BISE {bise.name}</p>
      </div>
    ) : (
      <div class="mt-6 grid grid-cols-1 gap-2.5 sm:grid-cols-2 lg:grid-cols-3">
        {classes.map(c => (
          <a href={url(`/board/punjab/${bise.slug}/class-${c}`)} class="row group">
            <span class="tile">
              <Icon name="graduation-cap" size={19} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <div class="row-title">Class {c}</div>
            </div>
            <Icon name="arrow-right" size={15} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
          </a>
        ))}
      </div>
    )}

    <div class="mt-12 rounded-xl border border-slate-200 bg-white p-6">
      <p class="text-sm leading-relaxed text-slate-600">
        <strong class="text-slate-900">Note:</strong> Textbooks and syllabus are shared across all 9 Punjab BISEs. Only past papers and result gazettes are board-specific. Looking for shared resources? <a href={url('/board/punjab')} class="font-bold text-[#1d4ed8] hover:underline">Browse Punjab-level content</a>.
      </p>
    </div>
  </div>
</BaseLayout>
ASTRO

# ── Class hub under BISE ──
cat > 'src/pages/board/punjab/[bise]/[class]/index.astro' <<'ASTRO'
---
import BaseLayout from '../../../../../layouts/BaseLayout.astro';
import Icon from '../../../../../components/Icon.astro';
import { url } from '../../../../../lib/url';
import { PUNJAB_BISES, biseBySlug } from '../../../../../lib/boards';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  return PUNJAB_BISES.map(b => ({
    params: { bise: b.slug, class: `class-9` },
  })).concat(
    PUNJAB_BISES.map(b => ({
      params: { bise: b.slug, class: `class-10` },
    }))
  );
}

const { bise: biseSlug, class: classParam } = Astro.params;
const cls = String(classParam).replace(/^class-/, '');
const bise = biseBySlug(biseSlug!);
if (!bise) return Astro.redirect('/board/punjab');

const allPapers = await getCollection('pastPapers');
const allGazettes = await getCollection('gazettes');
const papers = allPapers.filter((p: any) => p.data.bise === bise.name && p.data.class === cls);
const gazettes = allGazettes.filter((g: any) => g.data.bise === bise.name && g.data.class === cls);

// Subject set
const subjectSet = new Set<string>();
papers.forEach((p: any) => subjectSet.add(p.data.subject));
const subjects = [...subjectSet].sort();
---
<BaseLayout
  title={`BISE ${bise.name} Class ${cls} — Past Papers & Gazettes | TaleemHub`}
  description={`All Class ${cls} past papers and result gazettes for BISE ${bise.name}, Punjab Board. 2018 to 2026.`}
>
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/boards')} class="hover:text-[#1d4ed8]">Boards</a>
        <span>/</span>
        <a href={url('/board/punjab')} class="hover:text-[#1d4ed8]">Punjab</a>
        <span>/</span>
        <a href={url(`/board/punjab/${bise.slug}`)} class="hover:text-[#1d4ed8]">BISE {bise.name}</a>
        <span>/</span>
        <span class="text-slate-500">Class {cls}</span>
      </nav>
      <div class="max-w-2xl">
        <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">Class {cls} · {bise.name}</h1>
        <p class="mt-3 text-base text-slate-600">{papers.length} past papers · {gazettes.length} gazettes</p>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
    <h2 class="text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Board-specific resources</h2>
    <p class="mt-2 text-sm text-slate-500">Unique to BISE {bise.name}.</p>
    <div class="mt-6 grid grid-cols-1 gap-2.5 sm:grid-cols-2 lg:grid-cols-3">
      <a href={url(`/board/punjab/${bise.slug}/class-${cls}/past-papers`)} class="row group">
        <span class="tile"><Icon name="scroll-text" size={18} strokeWidth={2.2} /></span>
        <div class="min-w-0 flex-1">
          <div class="row-title">Past Papers</div>
        </div>
        <Icon name="arrow-right" size={15} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
      </a>
      <a href={url(`/board/punjab/${bise.slug}/class-${cls}/gazettes`)} class="row group">
        <span class="tile"><Icon name="newspaper" size={18} strokeWidth={2.2} /></span>
        <div class="min-w-0 flex-1">
          <div class="row-title">Result Gazettes</div>
        </div>
        <Icon name="arrow-right" size={15} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
      </a>
    </div>

    {subjects.length > 0 && (
      <>
        <h2 class="mt-12 text-xl font-extrabold tracking-tight text-slate-900 sm:text-2xl">Past papers by subject</h2>
        <div class="mt-6 grid grid-cols-1 gap-2.5 sm:grid-cols-2 lg:grid-cols-3">
          {subjects.map(s => (
            <a href={url(`/board/punjab/${bise.slug}/class-${cls}/${s.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/^-|-$/g,'')}`)} class="row group">
              <span class="tile"><Icon name="scroll-text" size={18} strokeWidth={2.2} /></span>
              <div class="min-w-0 flex-1">
                <div class="row-title">{s}</div>
              </div>
              <Icon name="arrow-right" size={15} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
            </a>
          ))}
        </div>
      </>
    )}

    <div class="mt-12 rounded-xl border border-slate-200 bg-white p-6">
      <h3 class="text-sm font-extrabold text-slate-900">Looking for shared resources?</h3>
      <p class="mt-2 text-sm text-slate-600">
        Notes, textbooks and quizzes are identical across all Punjab BISEs.
      </p>
      <div class="mt-4 flex flex-wrap gap-2">
        <a href={url(`/board/punjab/class-${cls}/notes`)} class="btn btn-outline text-xs">Notes</a>
        <a href={url(`/board/punjab/class-${cls}/books`)} class="btn btn-outline text-xs">Books</a>
        <a href={url(`/board/punjab/class-${cls}/quizzes`)} class="btn btn-outline text-xs">Quizzes</a>
      </div>
    </div>
  </div>
</BaseLayout>
ASTRO

# ── Subject/type list under BISE ──
cat > 'src/pages/board/punjab/[bise]/[class]/[subject].astro' <<'ASTRO'
---
import BaseLayout from '../../../../../../layouts/BaseLayout.astro';
import Icon from '../../../../../../components/Icon.astro';
import { url } from '../../../../../../lib/url';
import { PUNJAB_BISES, biseBySlug } from '../../../../../../lib/boards';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const papers = await getCollection('pastPapers');
  const gazettes = await getCollection('gazettes');
  const paths: any[] = [];
  const seen = new Set<string>();

  const slug = (s: string) => s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');

  for (const b of PUNJAB_BISES) {
    for (const cls of ['9', '10']) {
      // Type pages
      for (const t of ['past-papers', 'gazettes']) {
        const key = `${b.slug}-${cls}-${t}`;
        if (!seen.has(key)) { seen.add(key); paths.push({ params: { bise: b.slug, class: `class-${cls}`, subject: t } }); }
      }
      // Subject pages (from papers)
      const subjSet = new Set<string>();
      papers.filter((p: any) => p.data.bise === b.name && p.data.class === cls).forEach((p: any) => subjSet.add(slug(p.data.subject)));
      subjSet.forEach(s => {
        const key = `${b.slug}-${cls}-${s}`;
        if (!seen.has(key)) { seen.add(key); paths.push({ params: { bise: b.slug, class: `class-${cls}`, subject: s } }); }
      });
    }
  }
  return paths;
}

const { bise: biseSlug, class: classParam, subject: subjectSlug } = Astro.params;
const cls = String(classParam).replace(/^class-/, '');
const bise = biseBySlug(biseSlug!);
if (!bise) return Astro.redirect('/board/punjab');

const allPapers = await getCollection('pastPapers');
const allGazettes = await getCollection('gazettes');

const isGazette = subjectSlug === 'gazettes';
const isPastPapers = subjectSlug === 'past-papers';

let items: any[] = [];
let typeLabel = '';
let iconName = '';

if (isGazette) {
  items = allGazettes.filter((g: any) => g.data.bise === bise.name && g.data.class === cls)
    .sort((a: any, b: any) => (b.data.year || 0) - (a.data.year || 0));
  typeLabel = 'Result Gazettes';
  iconName = 'newspaper';
} else if (isPastPapers) {
  items = allPapers.filter((p: any) => p.data.bise === bise.name && p.data.class === cls)
    .sort((a: any, b: any) => (b.data.year || 0) - (a.data.year || 0));
  typeLabel = 'Past Papers';
  iconName = 'scroll-text';
} else {
  // Subject-specific
  const slugFn = (s: string) => s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
  items = allPapers
    .filter((p: any) => p.data.bise === bise.name && p.data.class === cls && slugFn(p.data.subject) === subjectSlug)
    .sort((a: any, b: any) => (b.data.year || 0) - (a.data.year || 0));
  typeLabel = items[0]?.data?.subject || subjectSlug;
  iconName = 'scroll-text';
}
---
<BaseLayout
  title={`${typeLabel} — BISE ${bise.name} Class ${cls} | TaleemHub`}
  description={`All ${typeLabel.toLowerCase()} for BISE ${bise.name} Class ${cls}, Punjab Board. 2018 to 2026, free download.`}
>
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[1200px] px-5 pt-10 pb-10 sm:px-7 lg:px-10 lg:pt-14 lg:pb-12">
      <nav class="mb-5 flex flex-wrap items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/boards')} class="hover:text-[#1d4ed8]">Boards</a>
        <span>/</span>
        <a href={url('/board/punjab')} class="hover:text-[#1d4ed8]">Punjab</a>
        <span>/</span>
        <a href={url(`/board/punjab/${bise.slug}`)} class="hover:text-[#1d4ed8]">{bise.name}</a>
        <span>/</span>
        <a href={url(`/board/punjab/${bise.slug}/class-${cls}`)} class="hover:text-[#1d4ed8]">Class {cls}</a>
        <span>/</span>
        <span class="text-slate-500">{typeLabel}</span>
      </nav>
      <div class="max-w-2xl">
        <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl lg:text-5xl">{typeLabel}</h1>
        <p class="mt-3 text-base text-slate-600">BISE {bise.name} · Class {cls} · {items.length} {items.length === 1 ? 'item' : 'items'}</p>
      </div>
    </div>
  </div>

  <div class="mx-auto max-w-[1200px] px-5 py-12 sm:px-7 lg:px-10 lg:py-14">
    {items.length === 0 ? (
      <div class="rounded-xl border border-dashed border-slate-300 bg-white p-12 text-center">
        <p class="text-sm font-bold text-slate-900">Nothing here yet</p>
        <a href={url(`/board/punjab/${bise.slug}/class-${cls}`)} class="mt-5 inline-flex items-center gap-1.5 rounded-lg bg-[#1d4ed8] px-4 py-2.5 text-sm font-bold text-white hover:bg-[#1e3a8a]">Back to Class {cls}</a>
      </div>
    ) : (
      <div class="grid grid-cols-1 gap-2.5 sm:grid-cols-2">
        {items.map((item: any) => (
          <a href={url(`/${isGazette ? 'gazettes' : 'past-papers'}/${item.id}`)} class="row group">
            <span class="tile">
              <Icon name={iconName} size={18} strokeWidth={2.2} />
            </span>
            <div class="min-w-0 flex-1">
              <div class="row-title">{item.data.title}</div>
              <div class="mt-1 flex flex-wrap gap-1.5">
                {item.data.year && <span class="inline-flex items-center rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate-600">{item.data.year}</span>}
                <span class="inline-flex items-center rounded bg-[#eff4ff] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#1d4ed8]">{bise.name}</span>
              </div>
            </div>
            <Icon name="arrow-right" size={15} strokeWidth={2.4} class="shrink-0 text-slate-300 transition-all group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" />
          </a>
        ))}
      </div>
    )}

    <div class="mt-10">
      <a href={url(`/board/punjab/${bise.slug}/class-${cls}`)} class="inline-flex items-center gap-2 text-sm font-semibold text-slate-500 hover:text-[#1d4ed8]">
        <Icon name="arrow-left" size={16} strokeWidth={2.4} /> Back to Class {cls}
      </a>
    </div>
  </div>
</BaseLayout>
ASTRO

echo "  ✓ BISE route tree created"

# ─────────────────────────────────────────────
#  3. Generate content: papers + gazettes
# ─────────────────────────────────────────────
python3 - <<'PY'
import json
import pathlib

PP_DIR = pathlib.Path("src/content/past-papers")
GZ_DIR = pathlib.Path("src/content/gazettes")
PP_DIR.mkdir(parents=True, exist_ok=True)
GZ_DIR.mkdir(parents=True, exist_ok=True)

PUNJAB_BISES = [
    'Lahore', 'Gujranwala', 'Multan', 'Faisalabad', 'Rawalpindi',
    'Sargodha', 'Bahawalpur', 'DG Khan', 'Sahiwal'
]
SUBJECTS = [
    'Physics', 'Chemistry', 'Biology', 'Mathematics',
    'English', 'Urdu', 'Islamiat', 'Pakistan Studies', 'Computer Science',
]
YEARS = list(range(2018, 2027))  # 2018 → 2026
CLASSES = ['9', '10']

def slug(s):
    return s.lower().replace(' & ', '-and-').replace(' ', '-').replace('.', '')

# ── PAPERS: per BISE per class per subject per year ──
paper_count = 0
for bise in PUNJAB_BISES:
    bise_slug = slug(bise)
    for cls in CLASSES:
        for subject in SUBJECTS:
            subj_slug = slug(subject)
            for year in YEARS:
                fname = f"{subj_slug}-{cls}-{bise_slug}-{year}"
                fpath = PP_DIR / f"{fname}.json"
                if fpath.exists():
                    continue
                data = {
                    "title": f"{subject} Class {cls} Past Paper {year} — BISE {bise}",
                    "subject": subject,
                    "class": cls,
                    "year": year,
                    "boards": ["Punjab"],
                    "bises": [bise],
                    "bise": bise,
                    "pdfUrl": f"/pdfs/past-papers/{fname}.pdf"
                }
                fpath.write_text(json.dumps(data, indent=2))
                paper_count += 1

print(f"  ✓ {paper_count} Punjab BISE papers generated")

# ── PAPERS: Federal (no BISE) ──
federal_count = 0
for cls in CLASSES:
    for subject in SUBJECTS:
        subj_slug = slug(subject)
        for year in YEARS:
            fname = f"{subj_slug}-{cls}-federal-{year}"
            fpath = PP_DIR / f"{fname}.json"
            if fpath.exists():
                continue
            data = {
                "title": f"{subject} Class {cls} Past Paper {year} — Federal Board",
                "subject": subject,
                "class": cls,
                "year": year,
                "boards": ["Federal"],
                "pdfUrl": f"/pdfs/past-papers/{fname}.pdf"
            }
            fpath.write_text(json.dumps(data, indent=2))
            federal_count += 1

print(f"  ✓ {federal_count} Federal papers generated")

# ── GAZETTES: per BISE per class per year ──
gz_count = 0
for bise in PUNJAB_BISES:
    bise_slug = slug(bise)
    for cls in CLASSES:
        for year in YEARS:
            fname = f"gazette-{bise_slug}-{cls}-{year}"
            fpath = GZ_DIR / f"{fname}.json"
            if fpath.exists():
                continue
            data = {
                "title": f"BISE {bise} Class {cls} Result Gazette {year}",
                "year": year,
                "board": "Punjab",
                "boards": ["Punjab"],
                "bise": bise,
                "class": cls,
                "pdfUrl": f"/pdfs/gazettes/{fname}.pdf"
            }
            fpath.write_text(json.dumps(data, indent=2))
            gz_count += 1

print(f"  ✓ {gz_count} Punjab BISE gazettes generated")

# ── GAZETTES: Federal ──
fed_gz = 0
for cls in CLASSES:
    for year in YEARS:
        fname = f"gazette-federal-{cls}-{year}"
        fpath = GZ_DIR / f"{fname}.json"
        if fpath.exists():
            continue
        data = {
            "title": f"Federal Board Class {cls} Result Gazette {year}",
            "year": year,
            "board": "Federal",
            "boards": ["Federal"],
            "class": cls,
            "pdfUrl": f"/pdfs/gazettes/{fname}.pdf"
        }
        fpath.write_text(json.dumps(data, indent=2))
        fed_gz += 1

print(f"  ✓ {fed_gz} Federal gazettes generated")

print()
print(f"  TOTAL NEW FILES: {paper_count + federal_count + gz_count + fed_gz}")
PY

# ─────────────────────────────────────────────
#  4. Add gazettes route under board
# ─────────────────────────────────────────────
mkdir -p 'src/pages/board/[board]/[class]'

# Update gazettes schema import path (already exists), no change

# ─────────────────────────────────────────────
#  5. Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -10

echo ""
echo "════════════════════════════════════════════"
echo "  Done."
echo ""
echo "  Preview:"
echo "    pkill -f 'astro dev' || true"
echo "    npm run dev"
echo ""
echo "  Test these URLs:"
echo "    /board/punjab"
echo "    /board/punjab/lahore"
echo "    /board/punjab/lahore/class-10"
echo "    /board/punjab/lahore/class-10/past-papers"
echo "    /board/punjab/lahore/class-10/physics"
echo "    /board/punjab/multan/class-9/past-papers"
echo "    /board/punjab/lahore/class-10/gazettes"
echo ""
echo "  What was generated:"
echo "    · 9 BISEs × 2 classes × 9 subjects × 9 years = 1,458 Punjab papers"
echo "    · 2 classes × 9 subjects × 9 years = 162 Federal papers"
echo "    · 9 BISEs × 2 classes × 9 years = 162 Punjab gazettes"
echo "    · 2 classes × 9 years = 18 Federal gazettes"
echo ""
echo "  Total new files: ~1,800"
echo "════════════════════════════════════════════"