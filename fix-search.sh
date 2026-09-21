#!/bin/bash
set -e

cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "════════════════════════════════════════════"
echo "  Fixing search: better results + clean UI"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  1. Add Pagefind config to exclude index pages
# ─────────────────────────────────────────────
cat > pagefind.yml <<'YAML'
# Pagefind configuration
site: dist

# Only index detail pages, not index/hub pages
# This prevents "Books" index, "Notes" index etc. from cluttering results
exclude_selectors:
  - ".pf-exclude"

# Only include content in <main>
root_selector: "main"

# Keep the index small and fast
force_language: "en"
YAML
echo "  ✓ pagefind.yml created"

# ─────────────────────────────────────────────
#  2. Add data-pagefind-body to detail pages only
# ─────────────────────────────────────────────
echo ""
echo "  Marking detail pages for Pagefind..."

# Detail pages that SHOULD be searchable
DETAIL_PAGES=(
  "src/pages/notes/[...slug].astro"
  "src/pages/quizzes/[...slug].astro"
  "src/pages/books/[...slug].astro"
  "src/pages/past-papers/[...slug].astro"
  "src/pages/guess-papers/[...slug].astro"
  "src/pages/pairing-schemes/[...slug].astro"
  "src/pages/gazettes/[...slug].astro"
)

for f in "${DETAIL_PAGES[@]}"; do
  if [ -f "$f" ]; then
    # Add data-pagefind-body to the main element if not present
    python3 - "$f" <<'PY'
import pathlib, re, sys
p = pathlib.Path(sys.argv[1])
s = p.read_text()
if 'data-pagefind-body' not in s:
    # Try to find <main> or a wrapping div
    if '<main' in s:
        s = re.sub(r'<main\b([^>]*)>', r'<main\1 data-pagefind-body>', s, count=1)
    else:
        # Add to the outermost content div
        s = s.replace('<BaseLayout', '<BaseLayout data-pagefind-body', 1) if '<BaseLayout' in s and 'data-pagefind-body' not in s else s
    p.write_text(s)
    print(f'  ✓ {sys.argv[1]}')
else:
    print(f'  · {sys.argv[1]} — already marked')
PY
  fi
done

# ─────────────────────────────────────────────
#  3. Rebuild search.astro with cleaner UI
# ─────────────────────────────────────────────
echo ""
echo "  Rebuilding search page..."

cat > src/pages/search.astro <<'ASTRO'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { url } from '../lib/url';
---
<BaseLayout title="Search — Parhayi" description="Search notes, past papers, guess papers, quizzes, books and result gazettes across all Pakistani boards.">
  <link rel="stylesheet" href={url('/pagefind/pagefind-ui.css')} />

  <div class="mx-auto max-w-4xl px-5 py-10 sm:px-7 lg:px-10 lg:py-14">
    <div class="mb-8 max-w-2xl">
      <div class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-[#1d4ed8]">
        <span class="h-1.5 w-1.5 rounded-full bg-[#1d4ed8]"></span>
        Search
      </div>
      <h1 class="mt-4 text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">
        Find anything in the library
      </h1>
      <p class="mt-3 text-base text-slate-500">
        Notes, past papers, guess papers, quizzes, books and gazettes.
      </p>
    </div>

    <div id="pagefind-search" data-bundle={url('/pagefind/')}></div>
  </div>

  <script is:inline src={url('/pagefind/pagefind-ui.js')}></script>

  <script is:inline>
    (function () {
      var el = document.getElementById('pagefind-search');
      var bundle = el.dataset.bundle;

      var params = new URLSearchParams(location.search);
      var initialQ = params.get('q') || '';

      function init() {
        if (typeof PagefindUI === 'undefined') {
          setTimeout(init, 50);
          return;
        }
        new PagefindUI({
          element: '#pagefind-search',
          bundlePath: bundle,
          showSubResults: false,
          showImages: false,
          pageSize: 8,
          resetStyles: false,
          translations: {
            placeholder: 'Search notes, past papers, books…',
            clear_search: 'Clear',
            load_more: 'Load more',
            search_label: 'Search this site',
            zero_results: 'No results for [SEARCH_TERM]',
            many_results: '[COUNT] results',
            one_result: '[COUNT] result',
            alt_search: 'No results. Try [DIFFERENT_TERM]',
            search_suggestion: 'Try one of these:',
            searching: 'Searching…',
          },
        });

        if (initialQ) {
          var input = document.querySelector('.pagefind-ui__search-input');
          if (input) {
            input.value = initialQ;
            input.dispatchEvent(new Event('input', { bubbles: true }));
          }
        }
      }

      if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
      } else {
        init();
      }
    })();
  </script>

  <style is:global>
    /* ═══ Pagefind UI — fully custom ═══ */
    .pagefind-ui {
      --pagefind-ui-scale: 1;
      --pagefind-ui-primary: #1d4ed8;
      --pagefind-ui-text: #0b1220;
      --pagefind-ui-background: #ffffff;
      --pagefind-ui-border: #e5e9f0;
      --pagefind-ui-tag: #eff4ff;
      --pagefind-ui-border-width: 1px;
      --pagefind-ui-border-radius: 12px;
      --pagefind-ui-font: 'Plus Jakarta Sans Variable', 'Plus Jakarta Sans', system-ui, sans-serif;
    }

    /* Search input */
    .pagefind-ui .pagefind-ui__form {
      margin: 0;
    }
    .pagefind-ui .pagefind-ui__search-input {
      font-family: inherit;
      font-weight: 600;
      font-size: 1rem;
      padding: 1.125rem 1.125rem 1.125rem 3rem;
      border-radius: 12px;
      border: 1px solid #e5e9f0;
      background: #ffffff;
      color: #0b1220;
      transition: border-color .15s ease;
    }
    .pagefind-ui .pagefind-ui__search-input:focus {
      border-color: #1d4ed8;
      outline: none;
      box-shadow: 0 0 0 3px rgba(29, 78, 216, 0.12);
    }
    .pagefind-ui .pagefind-ui__search-clear {
      padding: 0 1rem;
      color: #64748b;
      font-size: 0.8125rem;
      font-weight: 700;
      background: transparent;
    }

    /* Results wrapper */
    .pagefind-ui .pagefind-ui__results-area {
      margin-top: 1.5rem;
    }

    /* Result count message */
    .pagefind-ui .pagefind-ui__message {
      padding: 0;
      margin-bottom: 1rem;
      font-size: 0.8125rem;
      font-weight: 700;
      letter-spacing: 0.02em;
      color: #64748b;
      text-transform: uppercase;
      border-bottom: 0;
    }

    /* Each result */
    .pagefind-ui .pagefind-ui__result {
      padding: 1.25rem 1.25rem 1.25rem 1rem;
      border: 1px solid #e5e9f0;
      border-radius: 12px;
      margin-bottom: 0.625rem;
      background: #ffffff;
      transition: border-color .15s ease, background-color .15s ease;
      position: relative;
      border-left: 3px solid transparent;
      display: block;
    }
    .pagefind-ui .pagefind-ui__result:hover {
      border-color: #1d4ed8;
      border-left-color: #1d4ed8;
      background: #fafbff;
    }
    .pagefind-ui .pagefind-ui__result-inner {
      margin: 0;
    }

    /* Result title */
    .pagefind-ui .pagefind-ui__result-title {
      margin-bottom: 0;
    }
    .pagefind-ui .pagefind-ui__result-link {
      color: #0b1220 !important;
      font-family: inherit;
      font-weight: 800;
      font-size: 1rem;
      letter-spacing: -0.02em;
      text-decoration: none;
      line-height: 1.35;
      display: block;
    }
    .pagefind-ui .pagefind-ui__result-link:hover {
      color: #1d4ed8 !important;
    }
    .pagefind-ui .pagefind-ui__result-link:before {
      display: none;
    }

    /* Result excerpt */
    .pagefind-ui .pagefind-ui__result-excerpt {
      color: #64748b;
      font-size: 0.875rem;
      line-height: 1.55;
      margin-top: 0.5rem;
      font-weight: 500;
    }

    /* Highlight */
    .pagefind-ui mark {
      background: #fffbeb;
      color: #92400e;
      padding: 0 0.2em;
      border-radius: 3px;
      font-weight: 700;
      font-style: normal;
    }

    /* Sub-results */
    .pagefind-ui .pagefind-ui__result-nested {
      margin-left: 0;
      margin-top: 0.75rem;
      padding-left: 0;
      border-left: 0;
    }

    /* Load more button */
    .pagefind-ui .pagefind-ui__button {
      background: #ffffff;
      color: #1d4ed8;
      font-family: inherit;
      font-weight: 700;
      font-size: 0.875rem;
      border: 1px solid #e5e9f0;
      border-radius: 10px;
      padding: 0.75rem 1.25rem;
      margin-top: 1rem;
      transition: all .15s ease;
    }
    .pagefind-ui .pagefind-ui__button:hover {
      background: #eff4ff;
      border-color: #1d4ed8;
    }
    .pagefind-ui .pagefind-ui__button:before,
    .pagefind-ui .pagefind-ui__button:after {
      display: none;
    }

    /* No results */
    .pagefind-ui .pagefind-ui__message:empty {
      display: none;
    }
  </style>
</BaseLayout>
ASTRO

echo "  ✓ search.astro — cleaned up"

# ─────────────────────────────────────────────
#  4. Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding with new Pagefind config..."
rm -rf dist .astro node_modules/.vite
npm run build 2>&1 | tail -15

echo ""
echo "════════════════════════════════════════════"
echo "  DONE"
echo ""
echo "  Preview:"
echo "    bash start-server.sh"
echo ""
echo "  Test on /search/:"
echo "    · 'Class 9 English Book' → individual books listed (not index pages)"
echo "    · 'physics' → individual papers listed"
echo "    · 'phisics' (typo) → still works"
echo ""
echo "  Push when happy:"
echo "    git add ."
echo "    git commit -m 'Fix search: config, UI, result quality'"
echo "    git push"
echo "════════════════════════════════════════════"