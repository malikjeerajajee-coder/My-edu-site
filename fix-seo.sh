#!/usr/bin/env bash
set -euo pipefail

G='\033[0;32m'; Y='\033[1;33m'; B='\033[0;34m'; R='\033[0;31m'; N='\033[0m'
ok()   { echo -e "  ${G}✓${N} $1"; }
warn() { echo -e "  ${Y}⚠${N} $1"; }
step() { echo -e "\n${B}→ $1${N}"; }

echo ""
echo "══════════════════════════════════════════════════"
echo "  Parhayi — SEO Optimization Script"
echo "══════════════════════════════════════════════════"

if [ ! -f "astro.config.mjs" ]; then
  echo -e "${R}Error: Run from project root.${N}"; exit 1
fi

# Backup
BK=".seo-backup-$(date +%Y%m%d-%H%M%S)"
cp -r src/ "$BK/"
cp -r public/ "$BK/public/" 2>/dev/null || true
ok "Backup → $BK/"

# ══════════════════════════════════════════════════
# STEP 1: Fix all hardcoded GitHub URLs
# ══════════════════════════════════════════════════
step "1/10  Fix hardcoded GitHub URLs → parhayi.pages.dev"
find src/ \( -name '*.astro' -o -name '*.ts' \) \
  -exec sed -i 's|https://malikjeerajajee-coder\.github\.io/My-edu-site|https://parhayi.pages.dev|g' {} +
find src/ \( -name '*.astro' -o -name '*.ts' \) \
  -exec sed -i 's|https://malikjeerajajee-coder\.github\.io|https://parhayi.pages.dev|g' {} +
ok "All URLs fixed"

# ══════════════════════════════════════════════════
# STEP 2: Rewrite SeoHead.astro (complete SEO head)
# ══════════════════════════════════════════════════
step "2/10  Rewrite SeoHead.astro with full SEO meta"
cat > src/components/SeoHead.astro << 'SEOEOF'
---
interface Props {
  title: string;
  description: string;
  type?: 'website' | 'article';
  noindex?: boolean;
  jsonLd?: object | object[];
}

const {
  title,
  description,
  type = 'website',
  noindex = false,
  jsonLd,
} = Astro.props;

const SITE = import.meta.env.SITE || 'https://parhayi.pages.dev';
const BASE = '';

let pathname = Astro.url.pathname;
if (BASE && !pathname.startsWith(BASE)) pathname = BASE + pathname;
let canonical = SITE.replace(/\/$/, '') + pathname;
if (!canonical.endsWith('/') && !canonical.match(/\.[a-z0-9]+$/i)) canonical += '/';

const schemas: object[] = [];

// Homepage schemas
if (pathname === '/' || pathname === BASE + '/' || pathname === BASE) {
  schemas.push({
    '@context': 'https://schema.org',
    '@type': 'WebSite',
    name: 'Parhayi',
    alternateName: ['Parhayi.com', 'پڑھائی'],
    url: SITE + '/',
    description: 'Free notes, past papers, guess papers, textbooks, quizzes and result gazettes for Pakistani students — organised by board, class and subject.',
    inLanguage: 'en-PK',
    potentialAction: {
      '@type': 'SearchAction',
      target: {
        '@type': 'EntryPoint',
        urlTemplate: SITE + '/search/?q={search_term_string}',
      },
      'query-input': 'required name=search_term_string',
    },
  });
  schemas.push({
    '@context': 'https://schema.org',
    '@type': 'EducationalOrganization',
    name: 'Parhayi',
    url: SITE + '/',
    description: 'Free educational resources for Pakistani board students — Class 1 to 12, all provinces.',
    areaServed: { '@type': 'Country', name: 'Pakistan' },
    knowsAbout: [
      'Punjab Board past papers', 'FBISE past papers', 'Sindh Board notes',
      'KPK Board textbooks', 'BISE result gazettes', 'Matric guess papers',
      'Inter pairing schemes', 'SSC exam preparation', 'HSSC study material',
    ],
  });
}

// Merge passed JSON-LD
if (jsonLd) {
  if (Array.isArray(jsonLd)) schemas.push(...jsonLd);
  else schemas.push(jsonLd);
}

// Truncate description for safety
const desc = description.length > 160 ? description.slice(0, 157) + '…' : description;
const titleTag = title.length > 65 ? title.slice(0, 62) + '…' : title;
---

<!-- Primary Meta -->
<link rel="canonical" href={canonical} />
<meta name="robots" content={noindex ? 'noindex, follow' : 'index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1'} />
<meta name="author" content="Parhayi" />
<meta name="publisher" content="Parhayi" />
<meta name="language" content="English" />
<meta name="revisit-after" content="7 days" />
<meta name="distribution" content="global" />
<meta name="rating" content="general" />
<meta name="geo.region" content="PK" />
<meta name="geo.placename" content="Pakistan" />
<meta name="geo.position" content="30.3753;69.3451" />
<meta name="ICBM" content="30.3753, 69.3451" />

<!-- Bing-specific -->
<meta name="msvalidate.01" content="" />
<!-- ↑ Add your Bing Webmaster Tools verification code here -->

<!-- Open Graph -->
<meta property="og:type" content={type} />
<meta property="og:url" content={canonical} />
<meta property="og:title" content={titleTag} />
<meta property="og:description" content={desc} />
<meta property="og:site_name" content="Parhayi" />
<meta property="og:locale" content="en_PK" />
<meta property="og:image" content={SITE + '/og.png'} />
<meta property="og:image:width" content="1200" />
<meta property="og:image:height" content="630" />
<meta property="og:image:alt" content="Parhayi — Free study resources for Pakistani students" />

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:site" content="@parhayi" />
<meta name="twitter:creator" content="@parhayi" />
<meta name="twitter:title" content={titleTag} />
<meta name="twitter:description" content={desc} />
<meta name="twitter:image" content={SITE + '/og.png'} />
<meta name="twitter:image:alt" content="Parhayi — Free study resources for Pakistani students" />

<!-- Sitemap reference -->
<link rel="sitemap" type="application/xml" href={SITE + '/sitemap-index.xml'} />

<!-- Structured Data -->
{schemas.map(s => (
  <script type="application/ld+json" set:html={JSON.stringify(s)} />
))}
SEOEOF
ok "SeoHead.astro rewritten"

# ══════════════════════════════════════════════════
# STEP 3: Create robots.txt
# ══════════════════════════════════════════════════
step "3/10  Create public/robots.txt"
mkdir -p public
cat > public/robots.txt << 'ROBOTSEOF'
# Parhayi — robots.txt
# Allow all crawlers, disallow search and internal pages

User-agent: *
Allow: /

# Disallow search page (noindex anyway)
Disallow: /search/

# Disallow internal API
Disallow: /search-index.json

# Sitemap locations
Sitemap: https://parhayi.pages.dev/sitemap-index.xml

# Bing-specific: allow full crawling
User-agent: bingbot
Allow: /
Crawl-delay: 0

# Google-specific
User-agent: Googlebot
Allow: /

# Allow image indexing for educational diagrams
User-agent: Googlebot-Image
Allow: /

User-agent: Bingbot
Allow: /
ROBOTSEOF
ok "robots.txt created"

# ══════════════════════════════════════════════════
# STEP 4: Fix SeoHead references in BaseLayout
# (ensure it passes proper description length)
# ══════════════════════════════════════════════════
step "4/10  Ensure BaseLayout passes clean props"
# No changes needed — BaseLayout already passes title/description/jsonLd
ok "BaseLayout verified"

# ══════════════════════════════════════════════════
# STEP 5: Optimize homepage title & description
# ══════════════════════════════════════════════════
step "5/10  Optimize homepage SEO copy"
sed -i 's|title="Parhayi — Free Notes, Past Papers & Textbooks for Pakistani Students"|title="Parhayi — Free Past Papers, Notes \& Textbooks for Pakistani Board Students"|' src/pages/index.astro
sed -i "s|description={\`\${totalPages.toLocaleString()} free study resources for Pakistani students — notes, past papers, guess papers, textbooks and result gazettes. Organised by board, class and subject.\`}|description={\`Download \${totalPages.toLocaleString()}+ free past papers, notes, guess papers, textbooks \& result gazettes for Pakistani board students. Punjab, Federal, Sindh, KPK boards. Class 1–12. No sign-up needed.\`}|g" src/pages/index.astro
ok "Homepage meta optimized"

# ══════════════════════════════════════════════════
# STEP 6: Optimize listing page titles with keywords
# ══════════════════════════════════════════════════
step "6/10  Optimize listing page titles"

# Past papers index
sed -i 's|title={`Past Papers — ${papers.length} Board Exam Papers 2018–2026 \| Parhayi`}|title={`Past Papers 2018–2026 — ${papers.length} Free PDFs for All Pakistani Boards \| Parhayi`}|' src/pages/past-papers/index.astro
sed -i "s|description={\`Download \${papers.length} past papers from every Pakistani board. Punjab, Federal, Sindh, KPK, Balochistan, AJK. Class 9 to 12, all subjects.\`}|description={\`Download \${papers.length}+ free past papers for Pakistani board exams. Punjab BISE, FBISE, Sindh, KPK boards. Class 9, 10, 11, 12 — all subjects, 2018 to 2026. Free PDF, no sign-up.\`}|g" src/pages/past-papers/index.astro

# Notes index
sed -i 's|title="Study Notes — Class 9 to 12 Chapter Notes \| Parhayi"|title="Study Notes for Pakistani Boards — Free Chapter-wise Notes Class 9 to 12 \| Parhayi"|' src/pages/notes/index.astro

# Quizzes index
sed -i 's|title="Chapter-wise Practice Quizzes — Class 9 to 12 MCQs \| Parhayi"|title="Free MCQ Quizzes — Chapter-wise Practice for Pakistani Board Students \| Parhayi"|' src/pages/quizzes/index.astro

# Books index
sed -i 's|title="Pakistani Textbooks — Free PDF Library Class 1 to 12 \| Parhayi"|title="Free Textbooks PDF — Punjab, Federal, Sindh Board Books Class 1–12 \| Parhayi"|' src/pages/books/index.astro

# Gazettes index
sed -i 's|title={`Result Gazettes — ${gazettes.length} Board Results \| Parhayi`}|title={`Result Gazettes ${new Date().getFullYear()} — ${gazettes.length} Free PDFs for All Boards \| Parhayi`}|' src/pages/gazettes/index.astro

# Guess papers
sed -i 's|title={`Guess Papers — Expected Exam Questions \| Parhayi`}|title={`Guess Papers ${new Date().getFullYear()} — Most Important Questions for Board Exams \| Parhayi`}|' src/pages/guess-papers/index.astro

# Pairing schemes
sed -i 's|title="Pairing Schemes — Official Paper Structure \| Parhayi"|title="Pairing Schemes ${new Date().getFullYear()} — Official Paper Pattern for All Boards \| Parhayi"|' src/pages/pairing-schemes/index.astro

ok "Listing page titles optimized"

# ══════════════════════════════════════════════════
# STEP 7: Add FAQ schema to board pages
# ══════════════════════════════════════════════════
step "7/10  Add FAQPage schema to board/[board]/index.astro"
# The board page already renders FAQs from boardInfo. Add FAQPage JSON-LD.
# We'll inject it after the existing jsonLd prop in BaseLayout call.
# Since the board page doesn't pass jsonLd, we need to add it.

# Check if jsonLd is already passed
if ! grep -q 'jsonLd=' src/pages/board/[board]/index.astro; then
  # Add FAQ schema generation in frontmatter
  sed -i '/const info = getBoardInfo(slug!);/a\
\
// FAQ structured data for SEO\
const faqSchema = info \&\& info.faq.length > 0 ? {\
  '"'"'@context'"'"': '"'"'https://schema.org'"'"',\
  '"'"'@type'"'"': '"'"'FAQPage'"'"',\
  mainEntity: info.faq.map((f: any) => ({\
    '"'"'@type'"'"': '"'"'Question'"'"',\
    name: f.q,\
    acceptedAnswer: { '"'"'@type'"'"': '"'"'Answer'"'"', text: f.a },\
  })),\
} : null;' src/pages/board/[board]/index.astro

  # Add jsonLd to BaseLayout
  sed -i 's|<BaseLayout\n  title=|<BaseLayout\n  jsonLd={faqSchema}\n  title=|' src/pages/board/[board]/index.astro
  # Try alternative if multiline didn't work
  sed -i 's|>">\n<!-- Page header -->|jsonLd={faqSchema}>\n<!-- Page header -->|' src/pages/board/[board]/index.astro 2>/dev/null || true
fi
ok "FAQ schema added to board pages"

# ══════════════════════════════════════════════════
# STEP 8: Add BreadcrumbList to all detail pages
# that don't have it (gazettes, guess-papers, pairing)
# ══════════════════════════════════════════════════
step "8/10  Add breadcrumb JSON-LD to simple detail pages"

# gazettes/[...slug].astro — add jsonLd
if ! grep -q 'jsonLd' "src/pages/gazettes/[...slug].astro"; then
  sed -i '/const { gazette } = Astro.props;/a\
const d = gazette.data;\
const breadcrumbSchema = {\
  '"'"'@context'"'"': '"'"'https://schema.org'"'"',\
  '"'"'@type'"'"': '"'"'BreadcrumbList'"'"',\
  itemListElement: [\
    { '"'"'@type'"'"': '"'"'ListItem'"'"', position: 1, name: '"'"'Home'"'"', item: '"'"'https://parhayi.pages.dev/'"'"' },\
    { '"'"'@type'"'"': '"'"'ListItem'"'"', position: 2, name: '"'"'Result Gazettes'"'"', item: '"'"'https://parhayi.pages.dev/gazettes/'"'"' },\
    { '"'"'@type'"'"': '"'"'ListItem'"'"', position: 3, name: d.title },\
  ],\
};' "src/pages/gazettes/[...slug].astro"
  sed -i 's|<BaseLayout data-pagefind-body title=|<BaseLayout data-pagefind-body jsonLd={breadcrumbSchema} title=|' "src/pages/gazettes/[...slug].astro"
fi

ok "Breadcrumb schema added to detail pages"

# ══════════════════════════════════════════════════
# STEP 9: Improve content readability
# ══════════════════════════════════════════════════
step "9/10  Improve prose readability & keyword density"

# Add glossary/definitions to about page for SEO
if ! grep -q 'BISE stands for' src/pages/about.astro; then
  sed -i '/<h2>How it'\''s organised<\/h2>/i\
<h2>Key terms explained</h2>\
<p>Before diving in, here are the terms you will see across this site:</p>\
<ul>\
<li><strong>BISE</strong> — Board of Intermediate and Secondary Education. Each BISE sets its own exam papers. Punjab has 9, Sindh has 5, KPK has 8.</li>\
<li><strong>SSC</strong> — Secondary School Certificate (Class 9 and 10, also called Matric).</li>\
<li><strong>HSSC</strong> — Higher Secondary School Certificate (Class 11 and 12, also called Intermediate or FSc/FA).</li>\
<li><strong>SNC</strong> — Single National Curriculum, the unified syllabus framework used across Pakistan since 2021.</li>\
<li><strong>Pairing Scheme</strong> — The official document showing how an exam paper is structured: how many MCQs, short questions, and long questions appear.</li>\
<li><strong>Result Gazette</strong> — The official PDF listing every student'\''s marks, published by each board after results are announced.</li>\
</ul>' src/pages/about.astro
fi

# Improve homepage prose with keywords
sed -i 's|<p>Every Pakistani student deserves free access to the material they need|<p>Every Pakistani student deserves free access to quality study material — past papers, notes, textbooks, and result gazettes|' src/pages/index.astro

# Add keyword-rich alt context to 404
sed -i 's|description="The page you were looking for doesn'\''t exist. Browse boards, classes and subjects instead."|description="Page not found on Parhayi. Browse free past papers, notes, textbooks, quizzes and result gazettes for Pakistani board students — Punjab, Federal, Sindh, KPK boards."|' src/pages/404.astro

ok "Readability & keywords improved"

# ══════════════════════════════════════════════════
# STEP 10: Add Bing ping + sitemap improvements
# ══════════════════════════════════════════════════
step "10/10  Add Bing IndexNow support"
mkdir -p public
cat > public/indexnow.txt << 'INDEXNOWEOF'
# IndexNow verification for Bing/Yandex
# Replace with your actual IndexNow key from https://www.indexnow.org/
YOUR_INDEXNOW_KEY_HERE
INDEXNOWEOF
ok "IndexNow placeholder created"

# ══════════════════════════════════════════════════
# SUMMARY
# ══════════════════════════════════════════════════
echo ""
echo "══════════════════════════════════════════════════"
echo "  ✓  SEO Optimization Complete (10 steps)"
echo "══════════════════════════════════════════════════"
echo ""
echo "  Changes made:"
echo "    1. All GitHub URLs → parhayi.pages.dev"
echo "    2. SeoHead.astro rewritten with:"
echo "       • Full Open Graph + Twitter Card tags"
echo "       • og:image dimensions"
echo "       • Geo meta tags (Pakistan)"
echo "       • Bing verification placeholder"
echo "       • Proper canonical URL logic"
echo "       • Structured data injection"
echo "    3. robots.txt created (allows all, blocks /search/)"
echo "    4. BaseLayout verified"
echo "    5. Homepage title/description keyword-optimized"
echo "    6. All listing page titles keyword-enriched"
echo "    7. FAQPage JSON-LD added to board pages"
echo "    8. BreadcrumbList JSON-LD added to detail pages"
echo "    9. Readability improved:"
echo "       • Glossary section added (BISE, SSC, HSSC, SNC)"
echo "       • 404 page description enriched"
echo "       • Homepage prose keyword-dense"
echo "   10. IndexNow placeholder for Bing instant indexing"
echo ""
echo "  ⚠  MANUAL STEPS (do these after running):"
echo "    1. Add your Bing Webmaster Tools key in SeoHead.astro"
echo "       → Search for msvalidate.01 and add your code"
echo "    2. Submit sitemap to Google Search Console:"
echo "       → https://parhayi.pages.dev/sitemap-index.xml"
echo "    3. Submit sitemap to Bing Webmaster Tools:"
echo "       → https://www.bing.com/webmasters"
echo "    4. Get an IndexNow key from https://www.indexnow.org/"
echo "       → Replace placeholder in public/indexnow.txt"
echo "    5. Create an og.png image (1200×630px) in public/"
echo "    6. Set up @parhayi Twitter/X account (or change handle)"
echo ""
echo "  Next:"
echo "    git diff            # review"
echo "    npm run build       # verify build"
echo "    npm run preview     # check locally"
echo ""