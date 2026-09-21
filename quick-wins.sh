#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "════════════════════════════════════════════"
echo "  Quick wins"
echo "  1. About / Contact / Privacy"
echo "  2. FAQ schema on hub pages"
echo "  3. Federal BOARD_INFO"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  Backup
# ─────────────────────────────────────────────
git branch -f backup-pre-quick-wins 2>/dev/null || true
git push -u origin backup-pre-quick-wins 2>&1 | tail -2 || echo "  (backup push failed — do manually)"
echo "  ✓ backup-pre-quick-wins created"
echo ""

# ═════════════════════════════════════════════════════════
#  1. ABOUT PAGE
# ═════════════════════════════════════════════════════════
mkdir -p src/pages

cat > src/pages/about.astro <<'ASTRO'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import { url } from '../lib/url';

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'AboutPage',
  name: 'About Parhayi',
  description: 'Parhayi is a free study platform for Pakistani students — notes, past papers, textbooks and result gazettes organised by board and class.',
  publisher: { '@type': 'Organization', name: 'Parhayi' },
};
---
<BaseLayout
  title="About — Parhayi"
  description="Parhayi is a free study platform for Pakistani students — notes, past papers, guess papers, textbooks and result gazettes, all organised by board and class."
  jsonLd={jsonLd}
>
  <div class="mx-auto max-w-3xl px-5 py-12 sm:px-7 lg:px-10 lg:py-20">
    <nav class="mb-6 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
      <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
      <span>/</span>
      <span class="text-slate-500">About</span>
    </nav>

    <h1 class="text-4xl font-extrabold tracking-tight text-slate-900 sm:text-5xl">About Parhayi</h1>
    <p class="mt-5 text-lg leading-relaxed text-slate-600">
      Parhayi is a free study platform built for Pakistani students. We bring every resource a student actually needs — notes, past papers, guess papers, textbooks and result gazettes — into one place, organised by board and class.
    </p>

    <div class="prose mt-10">
      <h2>Why we built this</h2>
      <p>
        Pakistani students waste hours looking for the right paper. Google returns outdated links, WhatsApp groups share inconsistent PDFs, and most study sites are either paywalled, ad-choked, or cover just one or two boards.
      </p>
      <p>
        Parhayi fixes that. We've collected and organised:
      </p>
      <ul>
        <li><strong>6,000+ past papers</strong> — Class 9–12, all 6 provinces (Punjab, Federal, Sindh, KPK, Balochistan, AJK), all 33 BISEs, from 2018 to 2026</li>
        <li><strong>180+ textbooks</strong> — full PDFs of the Punjab Curriculum and Textbook Board (PTB) and Federal Board (FBISE) books for Class 1 to 12</li>
        <li><strong>Notes and chapter breakdowns</strong> — subject-wise, with exam-relevant focus</li>
        <li><strong>Result gazettes</strong> — Class 9 and 10, all BISEs</li>
        <li><strong>Guess papers and pairing schemes</strong> — updated each year</li>
      </ul>

      <h2>How it's organised</h2>
      <p>
        Most study sites force you to browse everything at once. Parhayi is built around two simple ideas:
      </p>
      <ol>
        <li><strong>Your board comes first.</strong> Punjab has 9 separate BISEs, Sindh has 5, KPK has 8. Each sets its own papers. We let you pick your exact board before showing you anything.</li>
        <li><strong>Your class second.</strong> A Class 9 student never needs to see Class 12 content — and vice versa.</li>
      </ol>

      <h2>Free, forever</h2>
      <p>
        No sign-up. No subscription. No ads. No paywall. Every resource on Parhayi is free to download and use.
      </p>
      <p>
        This is a public good. Education shouldn't be gated by income, and we intend to keep it that way.
      </p>

      <h2>Where our content comes from</h2>
      <p>
        Our papers, textbooks and gazettes come from publicly-published material by the Boards of Intermediate and Secondary Education (BISEs) across Pakistan and the Punjab Curriculum and Textbook Board. We organise and cross-reference these sources; we do not claim ownership of the underlying exam papers.
      </p>
      <p>
        If you're a rights holder and would like a specific file removed, see our <a href={url('/contact')}>Contact page</a>.
      </p>

      <h2>Get in touch</h2>
      <p>
        Have a question, a correction, or a request? <a href={url('/contact')}>Contact us</a>.
      </p>
    </div>
  </div>
</BaseLayout>
ASTRO
echo "  ✓ /about"

# ═════════════════════════════════════════════════════════
#  2. CONTACT PAGE
# ═════════════════════════════════════════════════════════
cat > src/pages/contact.astro <<'ASTRO'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import { url } from '../lib/url';

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'ContactPage',
  name: 'Contact Parhayi',
  description: 'Get in touch with the Parhayi team — corrections, contributions, and takedown requests.',
};
---
<BaseLayout
  title="Contact — Parhayi"
  description="Get in touch with Parhayi — corrections, contributions, partnership, or removal requests."
  jsonLd={jsonLd}
>
  <div class="mx-auto max-w-3xl px-5 py-12 sm:px-7 lg:px-10 lg:py-20">
    <nav class="mb-6 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
      <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
      <span>/</span>
      <span class="text-slate-500">Contact</span>
    </nav>

    <h1 class="text-4xl font-extrabold tracking-tight text-slate-900 sm:text-5xl">Contact</h1>
    <p class="mt-5 text-lg leading-relaxed text-slate-600">
      Corrections, contributions, takedown requests — all welcome.
    </p>

    <div class="mt-10 space-y-4">
      <div class="row">
        <span class="tile">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><rect width="20" height="16" x="2" y="4" rx="2"/><path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"/></svg>
        </span>
        <div class="min-w-0 flex-1">
          <div class="row-title">Email</div>
          <div class="row-sub">parhayi@example.com — we reply within 48 hours</div>
        </div>
      </div>
    </div>

    <div class="prose mt-12">
      <h2>Report an error</h2>
      <p>
        If a paper is missing, has the wrong year, or a link is broken, email us the page URL and what needs fixing. We correct verified errors quickly.
      </p>

      <h2>Contribute content</h2>
      <p>
        If you have official papers, textbooks, or notes we're missing — especially for Sindh, Balochistan, AJK, or older years — we'd love to add them. Send them as PDF attachments.
      </p>

      <h2>Takedown requests</h2>
      <p>
        Parhayi hosts publicly-published educational material by Pakistani examination boards and textbook boards. If you're a rights holder and believe a specific file should not be publicly available, email us with:
      </p>
      <ul>
        <li>The URL of the file</li>
        <li>A description of the copyright you hold</li>
        <li>Your contact details</li>
      </ul>
      <p>
        We respond to all legitimate takedown requests within 7 days.
      </p>

      <h2>For teachers and schools</h2>
      <p>
        Teachers and schools are welcome to use Parhayi resources freely in their classrooms, print them, share them, and modify them. Attribution is appreciated but not required.
      </p>
    </div>
  </div>
</BaseLayout>
ASTRO
echo "  ✓ /contact"

# ═════════════════════════════════════════════════════════
#  3. PRIVACY PAGE
# ═════════════════════════════════════════════════════════
cat > src/pages/privacy.astro <<'ASTRO'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import { url } from '../lib/url';

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'WebPage',
  name: 'Privacy Policy — Parhayi',
  description: 'Parhayi privacy policy. What we collect (very little), what we don\'t, and how we handle your data.',
};
---
<BaseLayout
  title="Privacy Policy — Parhayi"
  description="Parhayi privacy policy. What we collect (very little), what we don't, and how we handle your data."
  jsonLd={jsonLd}
>
  <div class="mx-auto max-w-3xl px-5 py-12 sm:px-7 lg:px-10 lg:py-20">
    <nav class="mb-6 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
      <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
      <span>/</span>
      <span class="text-slate-500">Privacy</span>
    </nav>

    <h1 class="text-4xl font-extrabold tracking-tight text-slate-900 sm:text-5xl">Privacy Policy</h1>
    <p class="mt-3 text-sm text-slate-500">Last updated: {new Date().toLocaleDateString('en-PK', { year: 'numeric', month: 'long', day: 'numeric' })}</p>

    <div class="prose mt-10">
      <h2>What we collect</h2>
      <p>
        Parhayi collects very little. We do not require sign-up. We do not use advertising trackers. We do not sell any data.
      </p>

      <h2>Analytics</h2>
      <p>
        We may use privacy-friendly analytics to understand aggregate traffic — total page views, popular pages, countries. No personal data, no IP addresses stored, no cookies used for tracking.
      </p>

      <h2>Cookies</h2>
      <p>
        We use a single first-party cookie to remember your UI preferences (like the mobile drawer state). We do not use third-party cookies.
      </p>

      <h2>Third-party services</h2>
      <p>
        We load fonts, PDFs and images from our own servers. No external trackers, no ad networks, no analytics pixels.
      </p>

      <h2>What we don't do</h2>
      <ul>
        <li>We don't sell your data</li>
        <li>We don't show ads</li>
        <li>We don't use fingerprinting</li>
        <li>We don't track you across other sites</li>
      </ul>

      <h2>Children's privacy</h2>
      <p>
        Parhayi is designed for students of all ages, including children under 13. We don't collect personal information from anyone — no registration, no accounts, no emails.
      </p>

      <h2>Data retention</h2>
      <p>
        We retain only anonymised aggregate analytics. There is nothing to delete because we don't collect personal data in the first place.
      </p>

      <h2>Contact</h2>
      <p>
        Questions? <a href={url('/contact')}>Contact us</a>.
      </p>
    </div>
  </div>
</BaseLayout>
ASTRO
echo "  ✓ /privacy"

# ═════════════════════════════════════════════════════════
#  4. Add footer links to BaseLayout
# ═════════════════════════════════════════════════════════
echo ""
echo "  Adding footer links..."

python3 <<'PY'
import pathlib, re
p = pathlib.Path('src/layouts/BaseLayout.astro')
s = p.read_text()

# Find footer's bottom line and add the extra links
old_bottom = '''<div class="mt-10 border-t border-slate-200 pt-6 text-xs text-slate-400">
          <p>© {new Date().getFullYear()} Parhayi. Built for students, forever free.</p>
        </div>'''

new_bottom = '''<div class="mt-10 flex flex-col gap-3 border-t border-slate-200 pt-6 text-xs text-slate-400 sm:flex-row sm:items-center sm:justify-between">
          <p>© {new Date().getFullYear()} Parhayi. Built for students, forever free.</p>
          <nav class="flex flex-wrap gap-4">
            <a href={url('/about')} class="hover:text-[#1d4ed8]">About</a>
            <a href={url('/contact')} class="hover:text-[#1d4ed8]">Contact</a>
            <a href={url('/privacy')} class="hover:text-[#1d4ed8]">Privacy</a>
            <a href={url('/search')} class="hover:text-[#1d4ed8]">Search</a>
          </nav>
        </div>'''

if old_bottom in s:
    s = s.replace(old_bottom, new_bottom)
    p.write_text(s)
    print('  ✓ Footer — About / Contact / Privacy / Search links added')
else:
    # Try alternate with TaleemHub
    alt = old_bottom.replace('Parhayi', 'TaleemHub')
    if alt in s:
        s = s.replace(alt, new_bottom)
        p.write_text(s)
        print('  ✓ Footer — links added (alt match)')
    else:
        # Broad regex
        pat = re.compile(
            r'<div class="mt-10 border-t border-slate-200 pt-6 text-xs text-slate-400">\s*<p>© \{new Date\(\)\.getFullYear\(\)\}[^<]*</p>\s*</div>',
            re.DOTALL
        )
        if pat.search(s):
            s = pat.sub(new_bottom, s)
            p.write_text(s)
            print('  ✓ Footer — links added (regex match)')
        else:
            print('  ! Footer pattern not found — add manually if needed')
PY

# ═════════════════════════════════════════════════════════
#  5. Add BoardInfo for Federal
# ═════════════════════════════════════════════════════════
echo ""
echo "  Adding Federal BOARD_INFO..."

python3 <<'PY'
import pathlib, re

p = pathlib.Path('src/lib/boardInfo.ts')
s = p.read_text()

# Check if federal already exists
if "'federal':" in s or '"federal":' in s or 'federal: {' in s:
    print('  · Federal already present')
else:
    # Find the closing of the BOARD_INFO object and add federal before it
    # The structure ends with:   },\n};  or similar
    federal_entry = '''
  federal: {
    slug: 'federal',
    overview: 'The Federal Board of Intermediate and Secondary Education (FBISE) is Pakistan\\'s national-level board, headquartered in Islamabad. It serves students in federal government schools and colleges across Pakistan, in cantonment areas, and in Pakistani institutions overseas. Unlike provincial boards, FBISE sets a single unified paper for the entire country — every student affiliated with FBISE sits the same exam on the same day. FBISE is known for a slightly more analytical paper pattern than provincial boards, with greater emphasis on conceptual understanding over rote memorisation.',
    boardsServed: [
      'Federal Board (FBISE)',
    ],
    totalMarks: 550,
    passingMarks: 182,
    examMonths: 'February to April (annual), October (supplementary)',
    groups: [
      { name: 'Science Group', subjects: ['English', 'Urdu', 'Islamiat', 'Pakistan Studies', 'Mathematics', 'Physics', 'Chemistry', 'Biology / Computer Science'] },
      { name: 'Arts Group', subjects: ['English', 'Urdu', 'Islamiat', 'Pakistan Studies', 'General Mathematics', 'General Science', 'Two electives of choice'] },
    ],
    subjects: [
      { name: 'English',              marks: 75,  type: 'compulsory' },
      { name: 'Urdu',                 marks: 75,  type: 'compulsory' },
      { name: 'Islamiat',             marks: 50,  type: 'compulsory' },
      { name: 'Pakistan Studies',     marks: 50,  type: 'compulsory' },
      { name: 'Mathematics',          marks: 75,  type: 'elective' },
      { name: 'Physics',              marks: 60,  type: 'elective' },
      { name: 'Chemistry',            marks: 60,  type: 'elective' },
      { name: 'Biology',              marks: 60,  type: 'elective' },
      { name: 'Computer Science',     marks: 60,  type: 'elective' },
    ],
    paperPatterns: [
      { subject: 'English',      totalMarks: 75, objective: '15 MCQs + short', subjective: '60 marks — short & long questions, grammar, composition', duration: '2 hr 40 min' },
      { subject: 'Urdu',         totalMarks: 75, objective: '15 MCQs + short', subjective: '60 marks — short & long questions, grammar', duration: '2 hr 40 min' },
      { subject: 'Mathematics',  totalMarks: 75, objective: '12 MCQs + short', subjective: '52 marks — short & long questions', duration: '2 hr 40 min' },
      { subject: 'Physics',      totalMarks: 60, objective: '12 MCQs + short', subjective: '48 marks — including numericals', duration: '2 hr 10 min' },
      { subject: 'Chemistry',    totalMarks: 60, objective: '12 MCQs + short', subjective: '48 marks — short & long', duration: '2 hr 10 min' },
      { subject: 'Biology',      totalMarks: 60, objective: '12 MCQs + short', subjective: '48 marks — short & long', duration: '2 hr 10 min' },
      { subject: 'Islamiat',     totalMarks: 50, objective: 'MCQs + short',    subjective: 'Short & long questions', duration: '2 hr' },
    ],
    faq: [
      { q: 'What is FBISE?', a: 'FBISE stands for Federal Board of Intermediate and Secondary Education. It\\'s the national examination board of Pakistan, headquartered in Islamabad, and sets one unified paper for all affiliated institutions across the country.' },
      { q: 'Does FBISE set one paper for the whole country?', a: 'Yes. Unlike provincial boards which have 5–9 separate BISEs, FBISE sets a single paper for every affiliated school — whether in Islamabad, Karachi, Lahore, or overseas. Every student sits the same exam.' },
      { q: 'What is the total marks for FBISE Class 9?', a: 'FBISE Class 9 is worth 550 marks across 8 subjects. Passing requires at least 182 marks (33%).' },
      { q: 'When are FBISE Class 9 exams held?', a: 'FBISE typically holds the annual SSC Part-I (Class 9) exams in February to April. Supplementary exams are held in October.' },
      { q: 'How is FBISE different from provincial boards?', a: 'FBISE papers are known for a slightly more analytical pattern, with more emphasis on conceptual understanding and application. The syllabus is similar but the question style rewards deeper reasoning.' },
      { q: 'Which schools come under FBISE?', a: 'Federal government schools and colleges (FGEIs), Pakistan Army and Air Force schools, cadet colleges, and Pakistani schools in embassies and missions abroad.' },
      { q: 'Are FBISE past papers accepted by other boards?', a: 'No — FBISE sets a completely different paper from provincial boards. If you\\'re sitting FBISE, you must study FBISE past papers specifically.' },
      { q: 'What is the passing marks for FBISE 9th class?', a: 'Passing marks are 182 out of 550, which is 33%. Students must pass each subject individually as well as overall.' },
    ],
  },
'''
    # Find the position of the closing of the BOARD_INFO object
    # BOARD_INFO structure: export const BOARD_INFO: Record<string, BoardInfo> = { punjab: { ... }, };
    # Insert federal just before the final };
    idx = s.rfind('};')
    if idx > 0:
        s = s[:idx] + federal_entry + s[idx:]
        p.write_text(s)
        print('  ✓ Federal BOARD_INFO added')
    else:
        print('  ! Could not find insertion point for Federal info')
PY

# ═════════════════════════════════════════════════════════
#  6. Add FAQ JSON-LD to board hub pages
# ═════════════════════════════════════════════════════════
echo ""
echo "  Adding FAQ schema to board pages..."

python3 <<'PY'
import pathlib, re

p = pathlib.Path('src/pages/board/[board]/index.astro')
s = p.read_text()

# Check if FAQ jsonLd already wired
if 'faqJsonLd' in s:
    print('  · FAQ schema already present')
else:
    # 1. Add FAQ JSON-LD computation in frontmatter
    # Find where jsonLd is passed to BaseLayout
    if 'jsonLd=' in s:
        # Replace single jsonLd with array including FAQ
        if "const boardFaqJsonLd = info?.faq?.length ? {" not in s:
            s = s.replace(
                "const info = getBoardInfo(slug!);",
                """const info = getBoardInfo(slug!);

const boardFaqJsonLd = info?.faq?.length ? {
  '@context': 'https://schema.org',
  '@type': 'FAQPage',
  mainEntity: info.faq.map((f: any) => ({
    '@type': 'Question',
    name: f.q,
    acceptedAnswer: { '@type': 'Answer', text: f.a },
  })),
} : null;

const boardBreadcrumbJsonLd = {
  '@context': 'https://schema.org',
  '@type': 'BreadcrumbList',
  itemListElement: [
    { '@type': 'ListItem', position: 1, name: 'Home', item: 'https://malikjeerajajee-coder.github.io/My-edu-site/' },
    { '@type': 'ListItem', position: 2, name: 'Boards', item: 'https://malikjeerajajee-coder.github.io/My-edu-site/boards/' },
    { '@type': 'ListItem', position: 3, name: board.full },
  ],
};

const boardJsonLd = [
  boardBreadcrumbJsonLd,
  ...(boardFaqJsonLd ? [boardFaqJsonLd] : []),
];"""
            )
            # Replace the BaseLayout invocation to use the array
            s = re.sub(
                r'<BaseLayout\s+title=([^>]+?)\s+description=([^>]+?)\s*>',
                r'<BaseLayout title=\1 description=\2 jsonLd={boardJsonLd}>',
                s, count=1
            )
            p.write_text(s)
            print('  ✓ Board page — FAQ + Breadcrumb JSON-LD added')
        else:
            print('  · Already present')
    else:
        print('  ! Could not find BaseLayout invocation')
PY

# Also add FAQ schema to BISE hub pages
python3 <<'PY'
import pathlib, re

p = pathlib.Path('src/pages/board/[board]/[bise]/index.astro')
if p.exists():
    s = p.read_text()
    if 'jsonLd' not in s:
        # Add simple breadcrumb schema
        s = s.replace(
            "const board = boardBySlug(boardSlug!);",
            """const board = boardBySlug(boardSlug!);
const biseBreadcrumbJsonLd = {
  '@context': 'https://schema.org',
  '@type': 'BreadcrumbList',
  itemListElement: [
    { '@type': 'ListItem', position: 1, name: 'Home', item: 'https://malikjeerajajee-coder.github.io/My-edu-site/' },
    { '@type': 'ListItem', position: 2, name: 'Boards', item: 'https://malikjeerajajee-coder.github.io/My-edu-site/boards/' },
    { '@type': 'ListItem', position: 3, name: board?.name || 'Board', item: `https://malikjeerajajee-coder.github.io/My-edu-site/board/${boardSlug}/` },
    { '@type': 'ListItem', position: 4, name: bise?.name || 'BISE' },
  ],
};"""
        )
        # Add jsonLd to BaseLayout
        s = re.sub(
            r'<BaseLayout\s+title=([^>]+?)\s+description=([^>]+?)\s*>',
            r'<BaseLayout title=\1 description=\2 jsonLd={biseBreadcrumbJsonLd}>',
            s, count=1
        )
        p.write_text(s)
        print('  ✓ BISE hub — Breadcrumb JSON-LD added')
    else:
        print('  · BISE hub already has jsonLd')
PY

# ═════════════════════════════════════════════════════════
#  7. Rebuild
# ═════════════════════════════════════════════════════════
echo ""
echo "Rebuilding (5-8 min)..."
rm -rf .astro node_modules/.vite dist
npm run build 2>&1 | tail -10

echo ""
echo "════════════════════════════════════════════════════════"
echo "  DONE"
echo ""
echo "  Preview:"
echo "    bash start-server.sh"
echo ""
echo "  Test:"
echo "    /My-edu-site/about/       — new about page"
echo "    /My-edu-site/contact/     — new contact page"
echo "    /My-edu-site/privacy/     — new privacy page"
echo "    /My-edu-site/board/federal/ — now has full info + FAQ schema"
echo "    /My-edu-site/board/sindh/   — FAQ schema added"
echo "    Footer of any page          — new links"
echo ""
echo "  Push when happy:"
echo "    git add ."
echo "    git commit -m 'Quick wins: About/Contact/Privacy + FAQ schema + Federal info'"
echo "    git push"
echo ""
echo "  Revert if needed:"
echo "    git checkout backup-pre-quick-wins"
echo "════════════════════════════════════════════════════════"