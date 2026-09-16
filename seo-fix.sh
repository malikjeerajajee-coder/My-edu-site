#!/bin/bash
set -e

echo "Applying SEO improvements..."
mkdir -p public

# 1. robots.txt
cat > public/robots.txt <<'ROBOTS'
User-agent: *
Allow: /

Sitemap: https://malikjeerajajee-coder.github.io/My-edu-site/sitemap-index.xml
ROBOTS
echo "  robots.txt created"

# 2. SeoHead component
cat > src/components/SeoHead.astro <<'SEO'
---
interface Props {
  title: string;
  description?: string;
  type?: 'website' | 'article';
  noindex?: boolean;
}

const {
  title,
  description = 'Free notes, interactive quizzes, textbooks and result gazettes for Pakistani students.',
  type = 'website',
  noindex = false,
} = Astro.props;

const siteOrigin = 'https://malikjeerajajee-coder.github.io';
const basePath = '/My-edu-site';

let pathname = Astro.url.pathname;
if (!pathname.startsWith(basePath)) pathname = basePath + pathname;

let canonical = siteOrigin + pathname;
if (!canonical.endsWith('/') && !canonical.match(/\.[a-z0-9]+$/i)) canonical += '/';
canonical = canonical.replace(new RegExp(siteOrigin + basePath + basePath, 'g'), siteOrigin + basePath);

const siteUrl = siteOrigin + basePath + '/';

const orgJsonLd = {
  '@context': 'https://schema.org',
  '@type': 'EducationalOrganization',
  name: 'TaleemHub',
  url: siteUrl,
  description: description,
  areaServed: 'PK',
  inLanguage: 'en',
};

const siteJsonLd = {
  '@context': 'https://schema.org',
  '@type': 'WebSite',
  name: 'TaleemHub',
  url: siteUrl,
  potentialAction: {
    '@type': 'SearchAction',
    target: siteUrl + 'search/?q={search_term_string}',
    'query-input': 'required name=search_term_string',
  },
};
---
<link rel="canonical" href={canonical} />
<meta name="robots" content={noindex ? 'noindex, follow' : 'index, follow'} />
<meta name="author" content="TaleemHub" />
<meta name="language" content="English" />
<meta name="geo.region" content="PK" />

<meta property="og:type" content={type} />
<meta property="og:url" content={canonical} />
<meta property="og:title" content={title} />
<meta property="og:description" content={description} />
<meta property="og:site_name" content="TaleemHub" />
<meta property="og:locale" content="en_PK" />

<meta name="twitter:card" content="summary" />
<meta name="twitter:title" content={title} />
<meta name="twitter:description" content={description} />

<link rel="sitemap" type="application/xml" href={siteUrl + 'sitemap-index.xml'} />

<script type="application/ld+json" set:html={JSON.stringify(orgJsonLd)} />
<script type="application/ld+json" set:html={JSON.stringify(siteJsonLd)} />
SEO
echo "  SeoHead.astro created"

# 3. Patch BaseLayout head
python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/layouts/BaseLayout.astro")
s = p.read_text()

if "SeoHead" not in s:
    s = s.replace(
        "import Icon from '../components/Icon.astro';",
        "import Icon from '../components/Icon.astro';\nimport SeoHead from '../components/SeoHead.astro';",
        1
    )

new_head = '''<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>{title}</title>
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" />
  <SeoHead title={title} description={description} />
</head>'''

pattern = re.compile(r'<head>.*?</head>', re.DOTALL)
if pattern.search(s):
    s = pattern.sub(new_head, s, count=1)
    p.write_text(s)
    print("  BaseLayout.astro patched")
else:
    print("  WARNING: <head> not found")
PY

echo ""
echo "Rebuilding..."
npm run build

echo ""
echo "Sitemap check:"
if [ -f dist/sitemap-0.xml ]; then
    grep -o '<loc>[^<]*</loc>' dist/sitemap-0.xml | head -3
elif [ -f dist/sitemap-index.xml ]; then
    head -c 200 dist/sitemap-index.xml
fi

echo ""
echo "════════════════════════════════════════════"
echo "  SEO fixes applied."
echo ""
echo "  Now push:"
echo "    git add ."
echo "    git commit -m 'SEO improvements'"
echo "    git push"
echo "════════════════════════════════════════════"