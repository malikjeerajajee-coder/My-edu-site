#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "════════════════════════════════════════════"
echo "  Search v3 — MiniSearch + filters + SEO"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  Backup
# ─────────────────────────────────────────────
git branch -f backup-pre-search-v3 2>/dev/null || true
git push -u origin backup-pre-search-v3 2>&1 | tail -2 || echo "  (backup push failed — do manually)"
echo "  ✓ backup-pre-search-v3 created"
echo ""

# ─────────────────────────────────────────────
#  1. Install MiniSearch
# ─────────────────────────────────────────────
echo "▸ 1. Installing MiniSearch..."
npm install minisearch --silent
echo "  ✓ minisearch installed"

# ─────────────────────────────────────────────
#  2. Remove Pagefind from build + install
# ─────────────────────────────────────────────
echo ""
echo "▸ 2. Removing Pagefind..."
npm uninstall pagefind --silent 2>/dev/null || true

python3 <<'PY'
import json, pathlib
p = pathlib.Path('package.json')
data = json.loads(p.read_text())
scripts = data.get('scripts', {})
scripts['build'] = 'astro build'
data['scripts'] = scripts
p.write_text(json.dumps(data, indent=2) + '\n')
print('  ✓ package.json — build now just astro build')
PY

# Clean pagefind output
rm -rf public/pagefind dist/pagefind
echo "  ✓ Cleaned Pagefind output"

# ─────────────────────────────────────────────
#  3. Update astro.config.mjs — exclude /search/ from sitemap
# ─────────────────────────────────────────────
echo ""
echo "▸ 3. Updating astro.config.mjs..."

python3 <<'PY'
import pathlib, re
p = pathlib.Path('astro.config.mjs')
s = p.read_text()

# Add search exclusion in the sitemap filter — modify the first 'if' to skip /search
if "if (/\\/search\\//.test(u)) return undefined" not in s:
    # Insert at the start of serialize function
    s = s.replace(
        "serialize(item) {\n        const u = item.url;",
        "serialize(item) {\n        const u = item.url;\n        // Exclude search page (it's noindex)\n        if (/\\/search\\/?$/.test(u)) return undefined;"
    )

p.write_text(s)
print('  ✓ Sitemap now excludes /search/')
PY

# ─────────────────────────────────────────────
#  4. Build-time search index endpoint
# ─────────────────────────────────────────────
echo ""
echo "▸ 4. Creating search index endpoint..."

cat > src/pages/search-index.json.ts <<'TS'
export const prerender = true;
import { getCollection } from 'astro:content';

interface Doc {
  id: string;
  type: 'note' | 'quiz' | 'book' | 'past-paper' | 'guess-paper' | 'pairing-scheme' | 'gazette';
  title: string;
  url: string;
  subject?: string;
  class?: string;
  board?: string;
  bise?: string;
  year?: number;
}

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

  const docs: Doc[] = [
    ...notes.map((n: any) => ({
      id: `note:${n.id}`,
      type: 'note' as const,
      title: n.data.title,
      url: `${base}/notes/${n.id}/`,
      subject: n.data.subject,
      class: n.data.class,
    })),
    ...quizzes.map((q: any) => ({
      id: `quiz:${q.id}`,
      type: 'quiz' as const,
      title: q.data.title,
      url: `${base}/quizzes/${q.id}/`,
      subject: q.data.subject,
      class: q.data.class,
    })),
    ...books.map((b: any) => ({
      id: `book:${b.id}`,
      type: 'book' as const,
      title: b.data.title,
      url: `${base}/books/${b.id}/`,
      subject: b.data.subject,
      class: b.data.class,
      board: (b.data.boards || [])[0],
    })),
    ...gazettes.map((g: any) => ({
      id: `gazette:${g.id}`,
      type: 'gazette' as const,
      title: g.data.title,
      url: `${base}/gazettes/${g.id}/`,
      class: g.data.class,
      board: (g.data.boards || [])[0],
      bise: g.data.bise,
      year: g.data.year,
    })),
    ...pastPapers.map((p: any) => ({
      id: `past-paper:${p.id}`,
      type: 'past-paper' as const,
      title: p.data.title,
      url: `${base}/past-papers/${p.id}/`,
      subject: p.data.subject,
      class: p.data.class,
      board: (p.data.boards || [])[0],
      bise: p.data.bise,
      year: p.data.year,
    })),
    ...guessPapers.map((p: any) => ({
      id: `guess-paper:${p.id}`,
      type: 'guess-paper' as const,
      title: p.data.title,
      url: `${base}/guess-papers/${p.id}/`,
      subject: p.data.subject,
      class: p.data.class,
      board: (p.data.boards || [])[0],
      year: p.data.year,
    })),
    ...pairingSchemes.map((p: any) => ({
      id: `pairing-scheme:${p.id}`,
      type: 'pairing-scheme' as const,
      title: p.data.title,
      url: `${base}/pairing-schemes/${p.id}/`,
      class: p.data.class,
      board: (p.data.boards || [])[0],
      year: p.data.year,
    })),
  ];

  return new Response(JSON.stringify(docs), {
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'public, max-age=3600',
    },
  });
}
TS
echo "  ✓ search-index.json.ts"

# ─────────────────────────────────────────────
#  5. Rewrite search.astro — MiniSearch + filters
# ─────────────────────────────────────────────
echo ""
echo "▸ 5. Building new search page..."

cat > src/pages/search.astro <<'ASTRO'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { url } from '../lib/url';

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'WebPage',
  name: 'Search — Parhayi',
  description: 'Search notes, past papers, guess papers, quizzes, books and result gazettes across all Pakistani boards.',
  isPartOf: {
    '@type': 'WebSite',
    name: 'Parhayi',
    url: 'https://malikjeerajajee-coder.github.io/My-edu-site/',
  },
};
---
<BaseLayout
  title="Search — Parhayi"
  description="Search 6,800+ notes, past papers, guess papers, quizzes, textbooks and result gazettes for Pakistani students. Filter by board, class, subject and year."
  noindex={true}
  jsonLd={jsonLd}
>
  <div class="mx-auto max-w-5xl px-5 py-10 sm:px-7 lg:px-10 lg:py-14">
    <!-- Header -->
    <div class="mb-8 max-w-2xl">
      <div class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-[#1d4ed8]">
        <span class="h-1.5 w-1.5 rounded-full bg-[#1d4ed8]"></span>
        Search
      </div>
      <h1 class="mt-4 text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">
        Find anything in the library
      </h1>
      <p class="mt-3 text-base leading-relaxed text-slate-500">
        Search across <span class="font-bold text-slate-700">6,800+ items</span> — notes, past papers, guess papers, quizzes, textbooks and result gazettes.
      </p>
    </div>

    <!-- Search bar -->
    <div class="sw" id="sw" data-index={url('/search-index.json')}>
      <div class="sw-bar">
        <span class="sw-icon" aria-hidden="true">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
        </span>
        <input
          type="search"
          id="sw-input"
          class="sw-input"
          placeholder="Search notes, past papers, books…"
          autocomplete="off"
          autocapitalize="off"
          spellcheck="false"
          aria-label="Search library"
        />
        <kbd class="sw-kbd">/</kbd>
        <button type="button" id="sw-clear" class="sw-clear" aria-label="Clear search">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
        </button>
      </div>

      <!-- Filters -->
      <div class="sw-filters" id="sw-filters">
        <div class="sw-facet" data-facet="type">
          <span class="sw-facet-label">Type</span>
          <div class="sw-chips" id="chips-type"></div>
        </div>
        <div class="sw-facet" data-facet="board">
          <span class="sw-facet-label">Board</span>
          <div class="sw-chips" id="chips-board"></div>
        </div>
        <div class="sw-facet" data-facet="class">
          <span class="sw-facet-label">Class</span>
          <div class="sw-chips" id="chips-class"></div>
        </div>
        <div class="sw-facet" data-facet="subject">
          <span class="sw-facet-label">Subject</span>
          <div class="sw-chips" id="chips-subject"></div>
        </div>
        <div class="sw-facet" data-facet="year">
          <span class="sw-facet-label">Year</span>
          <div class="sw-chips" id="chips-year"></div>
        </div>
      </div>

      <!-- Status -->
      <div class="sw-status" id="sw-status">Loading library…</div>
    </div>

    <!-- Results -->
    <div id="sw-results" class="sw-results"></div>

    <!-- Fallback browse links (visible always, helps SEO + no-JS users) -->
    <div class="mt-16 border-t border-slate-200 pt-10">
      <h2 class="text-lg font-extrabold tracking-tight text-slate-900">Or browse by category</h2>
      <div class="mt-4 grid grid-cols-2 gap-2.5 sm:grid-cols-4">
        {[
          { href: '/boards',          label: 'All boards' },
          { href: '/notes',           label: 'Notes' },
          { href: '/past-papers',     label: 'Past papers' },
          { href: '/guess-papers',    label: 'Guess papers' },
          { href: '/pairing-schemes', label: 'Pairing schemes' },
          { href: '/quizzes',         label: 'Quizzes' },
          { href: '/books',           label: 'Textbooks' },
          { href: '/gazettes',        label: 'Result gazettes' },
        ].map(c => (
          <a href={url(c.href)} class="row group">
            <span class="tile"><Icon name="arrow-right" size={16} strokeWidth={2.4} /></span>
            <div class="min-w-0 flex-1">
              <div class="row-title">{c.label}</div>
            </div>
          </a>
        ))}
      </div>
    </div>
  </div>

  <script is:inline define:vars={{ INDEX_URL: url('/search-index.json') }}>
    // ── Minimal MiniSearch-compatible engine (inlined to avoid bundling) ──
    // We load MiniSearch from the CDN in a size-optimized way, then use it
    // to index the flat metadata documents.
    // If the CDN fails, we fall back to a simple substring matcher.

    (function () {
      var TYPE_LABELS = {
        'note': 'Note',
        'quiz': 'Quiz',
        'book': 'Book',
        'past-paper': 'Past Paper',
        'guess-paper': 'Guess Paper',
        'pairing-scheme': 'Pairing Scheme',
        'gazette': 'Gazette'
      };

      var state = {
        docs: [],
        ready: false,
        q: '',
        filters: { type: 'all', board: 'all', class: 'all', subject: 'all', year: 'all' },
        results: []
      };

      var input = document.getElementById('sw-input');
      var clearBtn = document.getElementById('sw-clear');
      var statusEl = document.getElementById('sw-status');
      var resultsEl = document.getElementById('sw-results');

      // ── Load MiniSearch + index in background ──
      var miniSearch = null;

      function loadMiniSearch(cb) {
        if (window.MiniSearch) return cb();
        var s = document.createElement('script');
        s.src = 'https://cdn.jsdelivr.net/npm/minisearch@7.1.0/dist/umd/index.min.js';
        s.onload = cb;
        s.onerror = function () { console.warn('MiniSearch CDN failed — using fallback'); cb(); };
        document.head.appendChild(s);
      }

      function normalize(s) { return String(s == null ? '' : s).trim(); }

      function buildIndex() {
        if (!window.MiniSearch) {
          // Fallback: no index, just array filtering
          state.ready = true;
          statusEl.textContent = state.docs.length + ' items in library';
          return;
        }
        miniSearch = new window.MiniSearch({
          fields: ['title', 'subject', 'board', 'bise'],
          storeFields: ['id', 'type', 'title', 'url', 'subject', 'class', 'board', 'bise', 'year'],
          idField: 'id',
          searchOptions: {
            boost: { title: 30, subject: 15, board: 10, bise: 10 },
            fuzzy: 0.2,
            prefix: true,
            combineWith: 'AND'
          }
        });
        // Add all docs one by one so we can control field extraction
        state.docs.forEach(function (d) {
          miniSearch.add({
            id: d.id,
            type: d.type,
            title: normalize(d.title),
            url: d.url,
            subject: normalize(d.subject),
            class: normalize(d.class),
            board: normalize(d.board),
            bise: normalize(d.bise),
            year: d.year
          });
        });
        state.ready = true;
        statusEl.textContent = state.docs.length + ' items in library';
        updateFacetCounts();
      }

      // ── Facet chips ──
      var facets = {
        type:    { el: 'chips-type',    key: 'type',    order: ['note','quiz','book','past-paper','guess-paper','pairing-scheme','gazette'], labelFn: function (v) { return TYPE_LABELS[v] || v; } },
        board:   { el: 'chips-board',   key: 'board',   order: null },
        class:   { el: 'chips-class',   key: 'class',   order: ['1','2','3','4','5','6','7','8','9','10','11','12'] },
        subject: { el: 'chips-subject', key: 'subject', order: null },
        year:    { el: 'chips-year',    key: 'year',    order: null }
      };

      function updateFacetCounts() {
        Object.keys(facets).forEach(function (f) {
          var cfg = facets[f];
          var el = document.getElementById(cfg.el);
          if (!el) return;

          // Count unique values across all docs
          var counts = {};
          state.docs.forEach(function (d) {
            var v = d[cfg.key];
            if (v == null || v === '') return;
            v = String(v);
            counts[v] = (counts[v] || 0) + 1;
          });

          var values = Object.keys(counts);
          if (cfg.order) {
            values.sort(function (a, b) {
              var ai = cfg.order.indexOf(a), bi = cfg.order.indexOf(b);
              if (ai === -1 && bi === -1) return a.localeCompare(b);
              if (ai === -1) return 1;
              if (bi === -1) return -1;
              return ai - bi;
            });
          } else if (cfg.key === 'year') {
            values.sort(function (a, b) { return Number(b) - Number(a); });
          } else {
            values.sort();
          }

          var html = '<button type="button" class="sw-chip is-active" data-facet="' + cfg.key + '" data-value="all">All</button>';
          values.forEach(function (v) {
            var label = cfg.labelFn ? cfg.labelFn(v) : v;
            html += '<button type="button" class="sw-chip" data-facet="' + cfg.key + '" data-value="' + v.replace(/"/g, '&quot;') + '">' + label + '</button>';
          });
          el.innerHTML = html;

          // Wire clicks
          el.querySelectorAll('.sw-chip').forEach(function (chip) {
            chip.addEventListener('click', function () {
              el.querySelectorAll('.sw-chip').forEach(function (c) { c.classList.remove('is-active'); });
              chip.classList.add('is-active');
              state.filters[cfg.key] = chip.getAttribute('data-value');
              render();
            });
          });
        });
      }

      // ── Render ──
      function highlight(text, terms) {
        var safe = String(text == null ? '' : text)
          .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
        if (!terms.length) return safe;
        terms.forEach(function (t) {
          if (!t) return;
          var re = new RegExp('(' + t.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + ')', 'gi');
          safe = safe.replace(re, '<mark>$1</mark>');
        });
        return safe;
      }

      function esc(s) {
        return String(s == null ? '' : s)
          .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
      }

      function getResults() {
        var q = state.q.trim();
        var f = state.filters;

        var pool = state.docs.filter(function (d) {
          if (f.type !== 'all' && d.type !== f.type) return false;
          if (f.board !== 'all' && d.board !== f.board) return false;
          if (f.class !== 'all' && d.class !== f.class) return false;
          if (f.subject !== 'all' && d.subject !== f.subject) return false;
          if (f.year !== 'all' && String(d.year) !== f.year) return false;
          return true;
        });

        if (!q) return pool.slice(0, 60);

        if (miniSearch) {
          // Build filter function for miniSearch
          var allowedIds = new Set(pool.map(function (d) { return d.id; }));
          var matches = miniSearch.search(q);
          return matches
            .filter(function (m) { return allowedIds.has(m.id); })
            .slice(0, 100)
            .map(function (m) {
              return {
                id: m.id, type: m.type, title: m.title, url: m.url,
                subject: m.subject, class: m.class, board: m.board, bise: m.bise, year: m.year
              };
            });
        }

        // Fallback: simple substring match
        var lower = q.toLowerCase();
        var terms = lower.split(/\s+/).filter(Boolean);
        return pool.filter(function (d) {
          var hay = [d.title, d.subject, d.board, d.bise, String(d.year)].join(' ').toLowerCase();
          return terms.every(function (t) { return hay.indexOf(t) !== -1; });
        }).slice(0, 60);
      }

      function render() {
        clearBtn.classList.toggle('is-visible', input.value.length > 0);

        if (!state.ready) {
          statusEl.textContent = 'Loading library…';
          return;
        }

        var results = getResults();
        var q = state.q.trim();
        var hasFilter = q || Object.keys(state.filters).some(function (k) { return state.filters[k] !== 'all'; });

        // Status
        if (hasFilter) {
          statusEl.textContent = results.length + ' result' + (results.length === 1 ? '' : 's') +
            (q ? ' for “' + q + '”' : '');
        } else {
          statusEl.textContent = state.docs.length + ' items in library';
        }

        // Results
        if (!results.length) {
          resultsEl.innerHTML = hasFilter
            ? '<div class="sw-empty"><div class="sw-empty-title">No results</div><div class="sw-empty-sub">Try a different keyword or clear the filters.</div></div>'
            : '';
          return;
        }

        var terms = q ? q.toLowerCase().split(/\s+/).filter(Boolean) : [];

        // Group by type
        var groups = {};
        results.forEach(function (r) {
          if (!groups[r.type]) groups[r.type] = [];
          groups[r.type].push(r);
        });

        var orderedTypes = Object.keys(groups).sort(function (a, b) {
          var order = ['past-paper','note','book','guess-paper','pairing-scheme','quiz','gazette'];
          return order.indexOf(a) - order.indexOf(b);
        });

        var html = '';
        orderedTypes.forEach(function (t) {
          var items = groups[t];
          html += '<div class="sw-group">';
          html += '<div class="sw-group-head"><span class="sw-group-label">' + esc(TYPE_LABELS[t] || t) + '</span><span class="sw-group-count">' + items.length + '</span></div>';
          html += '<div class="sw-group-list">';
          items.forEach(function (r) {
            var badges = [];
            if (r.subject) badges.push('<span class="sw-badge">' + esc(r.subject) + '</span>');
            if (r.class)   badges.push('<span class="sw-badge sw-badge-blue">Class ' + esc(r.class) + '</span>');
            if (r.bise)    badges.push('<span class="sw-badge sw-badge-purple">' + esc(r.bise) + '</span>');
            else if (r.board) badges.push('<span class="sw-badge sw-badge-purple">' + esc(r.board) + '</span>');
            if (r.year)    badges.push('<span class="sw-badge sw-badge-muted">' + esc(r.year) + '</span>');

            html +=
              '<a href="' + esc(r.url) + '" class="sw-result">' +
                '<div class="sw-result-body">' +
                  '<div class="sw-result-title">' + highlight(r.title, terms) + '</div>' +
                  (badges.length ? '<div class="sw-result-meta">' + badges.join('') + '</div>' : '') +
                '</div>' +
                '<svg class="sw-result-arrow" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>' +
              '</a>';
          });
          html += '</div></div>';
        });

        resultsEl.innerHTML = html;
      }

      // ── Boot ──
      var params = new URLSearchParams(location.search);
      var initialQ = params.get('q') || '';
      if (initialQ) input.value = initialQ;

      input.addEventListener('input', function () {
        state.q = input.value;
        clearTimeout(input._t);
        input._t = setTimeout(render, 60);
      });

      clearBtn.addEventListener('click', function () {
        input.value = '';
        state.q = '';
        input.focus();
        render();
      });

      document.addEventListener('keydown', function (e) {
        if (e.key === '/' && document.activeElement !== input && !/INPUT|TEXTAREA/.test(document.activeElement.tagName)) {
          e.preventDefault();
          input.focus();
          input.select();
        }
      });

      // Load index + MiniSearch in parallel
      var pending = 2;
      function done() {
        pending--;
        if (pending === 0) {
          state.q = input.value;
          buildIndex();
          render();
        }
      }

      fetch(INDEX_URL)
        .then(function (r) { if (!r.ok) throw new Error(r.status); return r.json(); })
        .then(function (data) { state.docs = data; done(); })
        .catch(function (e) {
          console.error('Index load failed:', e);
          statusEl.textContent = 'Could not load library.';
          resultsEl.innerHTML = '<div class="sw-empty"><div class="sw-empty-title">Search unavailable</div><div class="sw-empty-sub">Please refresh the page.</div></div>';
          pending = 0;
        });

      loadMiniSearch(done);
    })();
  </script>

  <style is:global>
    /* ═══ Search widget ═══ */
    .sw-bar {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      padding: 0 0.875rem 0 1.125rem;
      height: 3.5rem;
      border: 1px solid #e5e9f0;
      border-radius: 14px;
      background: #ffffff;
      transition: border-color .15s ease, box-shadow .15s ease;
    }
    .sw-bar:focus-within {
      border-color: #1d4ed8;
      box-shadow: 0 0 0 4px rgba(29, 78, 216, 0.08);
    }
    .sw-icon { display: inline-flex; color: #94a3b8; flex-shrink: 0; }
    .sw-input {
      flex: 1;
      min-width: 0;
      border: 0;
      outline: none;
      background: transparent;
      font-size: 1rem;
      font-weight: 500;
      color: #0b1220;
      font-family: inherit;
    }
    .sw-input::placeholder { color: #94a3b8; }
    .sw-kbd {
      display: none;
      font-family: ui-monospace, monospace;
      font-size: 0.6875rem;
      font-weight: 700;
      color: #94a3b8;
      padding: 0.25rem 0.4rem;
      border: 1px solid #e5e9f0;
      border-radius: 6px;
      background: #f8fafc;
    }
    @media (min-width: 640px) { .sw-kbd { display: inline-block; } }
    .sw-clear {
      display: none;
      align-items: center;
      justify-content: center;
      width: 1.75rem;
      height: 1.75rem;
      border: 0;
      border-radius: 6px;
      background: transparent;
      color: #94a3b8;
      cursor: pointer;
      flex-shrink: 0;
    }
    .sw-clear:hover { background: #f1f5f9; color: #475569; }
    .sw-clear.is-visible { display: inline-flex; }

    /* Facets */
    .sw-filters {
      margin-top: 1rem;
      display: flex;
      flex-direction: column;
      gap: 0.75rem;
    }
    .sw-facet {
      display: flex;
      align-items: flex-start;
      gap: 0.75rem;
    }
    .sw-facet-label {
      flex-shrink: 0;
      width: 4.25rem;
      padding-top: 0.375rem;
      font-size: 0.6875rem;
      font-weight: 800;
      letter-spacing: 0.08em;
      text-transform: uppercase;
      color: #94a3b8;
    }
    .sw-chips {
      display: flex;
      gap: 0.375rem;
      overflow-x: auto;
      padding-bottom: 0.25rem;
      scrollbar-width: none;
      flex: 1;
      min-width: 0;
    }
    .sw-chips::-webkit-scrollbar { display: none; }
    .sw-chip {
      flex-shrink: 0;
      padding: 0.375rem 0.7rem;
      font-size: 0.75rem;
      font-weight: 700;
      color: #475569;
      background: #ffffff;
      border: 1px solid #e5e9f0;
      border-radius: 999px;
      cursor: pointer;
      white-space: nowrap;
      font-family: inherit;
      transition: all .15s ease;
    }
    .sw-chip:hover { border-color: #1d4ed8; color: #1d4ed8; }
    .sw-chip.is-active {
      background: #1d4ed8;
      border-color: #1d4ed8;
      color: #ffffff !important;
    }

    /* Status */
    .sw-status {
      margin-top: 1.25rem;
      font-size: 0.8125rem;
      font-weight: 700;
      letter-spacing: 0.02em;
      color: #64748b;
    }

    /* Results */
    .sw-results { margin-top: 1.5rem; }
    .sw-group { margin-bottom: 2rem; }
    .sw-group-head {
      display: flex;
      align-items: baseline;
      gap: 0.5rem;
      margin-bottom: 0.75rem;
      padding-bottom: 0.5rem;
      border-bottom: 1px solid #e5e9f0;
    }
    .sw-group-label {
      font-size: 0.75rem;
      font-weight: 800;
      letter-spacing: 0.08em;
      text-transform: uppercase;
      color: #0b1220;
    }
    .sw-group-count {
      font-size: 0.6875rem;
      font-weight: 700;
      color: #94a3b8;
    }
    .sw-group-list { display: flex; flex-direction: column; gap: 0.5rem; }

    .sw-result {
      display: flex;
      align-items: center;
      gap: 1rem;
      padding: 0.875rem 1rem;
      background: #ffffff;
      border: 1px solid #e5e9f0;
      border-radius: 12px;
      text-decoration: none;
      transition: border-color .15s ease, background-color .15s ease;
    }
    .sw-result:hover {
      border-color: #1d4ed8;
      background: #fafbff;
    }
    .sw-result-body { flex: 1; min-width: 0; }
    .sw-result-title {
      font-size: 0.9375rem;
      font-weight: 800;
      letter-spacing: -0.02em;
      color: #0b1220;
      line-height: 1.3;
    }
    .sw-result:hover .sw-result-title { color: #1d4ed8; }
    .sw-result-meta { margin-top: 0.375rem; display: flex; flex-wrap: wrap; gap: 0.375rem; }
    .sw-badge {
      font-size: 0.6875rem;
      font-weight: 700;
      letter-spacing: 0.03em;
      text-transform: uppercase;
      padding: 0.15rem 0.5rem;
      border-radius: 5px;
      background: #f1f5f9;
      color: #475569;
    }
    .sw-badge-blue { background: #eff4ff; color: #1d4ed8; }
    .sw-badge-purple { background: #f5f3ff; color: #6d28d9; }
    .sw-badge-muted { background: #f1f5f9; color: #64748b; }
    .sw-result-arrow { flex-shrink: 0; color: #cbd5e1; }
    .sw-result:hover .sw-result-arrow { color: #1d4ed8; }

    mark {
      background: #fffbeb;
      color: #92400e;
      padding: 0 0.15em;
      border-radius: 3px;
      font-weight: 800;
    }

    /* Empty state */
    .sw-empty {
      padding: 3rem 1.5rem;
      text-align: center;
      border: 1px dashed #cbd5e1;
      border-radius: 14px;
      background: #ffffff;
    }
    .sw-empty-title {
      font-size: 1rem;
      font-weight: 800;
      color: #0b1220;
    }
    .sw-empty-sub {
      margin-top: 0.5rem;
      font-size: 0.875rem;
      color: #64748b;
    }
  </style>
</BaseLayout>
ASTRO

echo "  ✓ search.astro rewritten"

# ─────────────────────────────────────────────
#  6. Update BaseLayout to pass noindex through to SeoHead
# ─────────────────────────────────────────────
python3 <<'PY'
import pathlib, re
p = pathlib.Path('src/layouts/BaseLayout.astro')
s = p.read_text()

# Add noindex to Props
if 'noindex' not in s.split('<SeoHead')[0]:
    s = s.replace(
        "interface Props { title: string; description?: string; jsonLd?: any; }",
        "interface Props { title: string; description?: string; jsonLd?: any; noindex?: boolean; }"
    )
    s = s.replace(
        "const {\n  title,\n  jsonLd,",
        "const {\n  title,\n  jsonLd,\n  noindex = false,"
    )
    s = s.replace(
        '<SeoHead title={title} description={description} jsonLd={jsonLd} />',
        '<SeoHead title={title} description={description} jsonLd={jsonLd} noindex={noindex} />'
    )
    p.write_text(s)
    print('  ✓ BaseLayout forwards noindex')
else:
    print('  · BaseLayout already forwards noindex')
PY

# Also verify SeoHead accepts noindex
if [ -f "src/components/SeoHead.astro" ]; then
  grep -q "noindex" src/components/SeoHead.astro && echo "  ✓ SeoHead supports noindex" || echo "  ! SeoHead may not support noindex prop"
fi

# ─────────────────────────────────────────────
#  7. Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding (4-6 min)..."
rm -rf .astro node_modules/.vite dist
npm run build 2>&1 | tail -12

echo ""
echo "════════════════════════════════════════════"
echo "  DONE"
echo ""
echo "  Preview:"
echo "    bash start-server.sh"
echo ""
echo "  Test:"
echo "    http://localhost:4321/My-edu-site/search/"
echo ""
echo "  Then try:"
echo "    · 'physics'         → all physics items"
echo "    · 'lahore 2024'     → Lahore 2024 papers"
echo "    · 'phisics'         → typo tolerance works"
echo "    · Click Type chip   → filter by paper type"
echo "    · Click Board chip  → filter by board"
echo "    · Combine filters   → Punjab + Class 10 + Physics"
echo ""
echo "  Push when happy:"
echo "    git add ."
echo "    git commit -m 'Search v3: MiniSearch + filters + noindex'"
echo "    git push"
echo ""
echo "  Revert if needed:"
echo "    git checkout backup-pre-search-v3"
echo "════════════════════════════════════════════"