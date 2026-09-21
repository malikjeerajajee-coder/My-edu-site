#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "════════════════════════════════════════════"
echo "  Search UI v3 — clean filter toolbar"
echo "════════════════════════════════════════════"
echo ""

git branch -f backup-pre-srch2 2>/dev/null || true
echo "  ✓ backup-pre-srch2 created"
echo ""

cat > src/pages/search.astro <<'ASTRO'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import { url } from '../lib/url';

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'WebPage',
  name: 'Search — Parhayi',
  description: 'Search notes, past papers, guess papers, quizzes, books and result gazettes across all Pakistani boards.',
};

const browseLinks = [
  { href: '/boards',          label: 'All boards' },
  { href: '/notes',           label: 'Notes' },
  { href: '/past-papers',     label: 'Past papers' },
  { href: '/guess-papers',    label: 'Guess papers' },
  { href: '/books',           label: 'Textbooks' },
  { href: '/gazettes',        label: 'Result gazettes' },
];

const popularSearches = [
  'Physics class 9',
  'Past papers Lahore 2024',
  'English essays class 10',
  'Chemistry notes',
  'Mathematics class 10',
  'Biology class 11',
  'Federal board papers',
  'Computer science notes',
];
---
<BaseLayout
  title="Search — Parhayi"
  description="Search 6,800+ notes, past papers, guess papers, quizzes, textbooks and result gazettes for Pakistani students. Filter by board, class, subject and year."
  noindex={true}
  jsonLd={jsonLd}
>
  <div class="sx" id="sx">
    <!-- ═══ HEADER ═══ -->
    <div class="sx-head">
      <div class="sx-eyebrow">
        <span class="sx-dot"></span>
        Search
      </div>
      <h1 class="sx-title">Find anything in the library</h1>
      <p class="sx-lede">
        Search across <strong>6,800+ items</strong> — notes, past papers, guess papers, quizzes, textbooks and result gazettes.
      </p>
    </div>

    <!-- ═══ SEARCH INPUT ═══ -->
    <div class="sx-bar">
      <span class="sx-bar-icon" aria-hidden="true">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
      </span>
      <input
        type="search"
        id="sx-input"
        class="sx-input"
        placeholder="Search notes, past papers, books…"
        autocomplete="off"
        autocapitalize="off"
        spellcheck="false"
        aria-label="Search library"
      />
      <button type="button" id="sx-clear" class="sx-clear" aria-label="Clear search">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
      </button>
      <kbd class="sx-kbd">/</kbd>
    </div>

    <!-- ═══ TOOLBAR — desktop dropdowns + mobile filter button ═══ -->
    <div class="sx-toolbar" id="sx-toolbar">
      <!-- Desktop dropdowns -->
      <div class="sx-dd-wrap">
        <div class="sx-dd" data-facet="type">
          <button type="button" class="sx-dd-btn" data-dd-btn>
            <span class="sx-dd-label">Type</span>
            <span class="sx-dd-value" data-dd-value>All</span>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="m6 9 6 6 6-6"/></svg>
          </button>
          <div class="sx-dd-menu" data-dd-menu hidden></div>
        </div>

        <div class="sx-dd" data-facet="board">
          <button type="button" class="sx-dd-btn" data-dd-btn>
            <span class="sx-dd-label">Board</span>
            <span class="sx-dd-value" data-dd-value>All</span>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="m6 9 6 6 6-6"/></svg>
          </button>
          <div class="sx-dd-menu" data-dd-menu hidden></div>
        </div>

        <div class="sx-dd" data-facet="class">
          <button type="button" class="sx-dd-btn" data-dd-btn>
            <span class="sx-dd-label">Class</span>
            <span class="sx-dd-value" data-dd-value>All</span>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="m6 9 6 6 6-6"/></svg>
          </button>
          <div class="sx-dd-menu" data-dd-menu hidden></div>
        </div>

        <div class="sx-dd" data-facet="subject">
          <button type="button" class="sx-dd-btn" data-dd-btn>
            <span class="sx-dd-label">Subject</span>
            <span class="sx-dd-value" data-dd-value>All</span>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="m6 9 6 6 6-6"/></svg>
          </button>
          <div class="sx-dd-menu" data-dd-menu hidden></div>
        </div>

        <div class="sx-dd" data-facet="year">
          <button type="button" class="sx-dd-btn" data-dd-btn>
            <span class="sx-dd-label">Year</span>
            <span class="sx-dd-value" data-dd-value>All</span>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="m6 9 6 6 6-6"/></svg>
          </button>
          <div class="sx-dd-menu" data-dd-menu hidden></div>
        </div>

        <button type="button" class="sx-reset" id="sx-reset" hidden>Reset</button>
      </div>

      <!-- Mobile filter button -->
      <button type="button" class="sx-mobile-filter" id="sx-open-filters">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><line x1="4" x2="20" y1="8" y2="8"/><line x1="4" x2="14" y1="16" y2="16"/><circle cx="17" cy="8" r="2.5"/><circle cx="9" cy="16" r="2.5"/></svg>
        <span>Filters</span>
        <span class="sx-mobile-count" id="sx-mobile-count" hidden>0</span>
      </button>
    </div>

    <!-- ═══ STATUS ═══ -->
    <div class="sx-status" id="sx-status" aria-live="polite">Loading library…</div>

    <!-- ═══ RESULTS ═══ -->
    <div id="sx-results" class="sx-results"></div>

    <!-- ═══ EMPTY STATE (no query) ═══ -->
    <div id="sx-empty" class="sx-empty">
      <section class="sx-empty-section">
        <h2 class="sx-empty-head">Popular searches</h2>
        <div class="sx-popular">
          {popularSearches.map(p => (
            <button type="button" class="sx-popular-chip" data-search={p}>{p}</button>
          ))}
        </div>
      </section>
      <section class="sx-empty-section">
        <h2 class="sx-empty-head">Browse by category</h2>
        <div class="sx-browse-grid">
          {browseLinks.map(c => (
            <a href={url(c.href)} class="sx-browse-link">
              <span>{c.label}</span>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>
            </a>
          ))}
        </div>
      </section>
    </div>
  </div>

  <!-- ═══ MOBILE FILTER SHEET ═══ -->
  <div class="sx-sheet-wrap" id="sx-sheet-wrap" hidden>
    <div class="sx-sheet-backdrop" id="sx-sheet-backdrop"></div>
    <div class="sx-sheet" role="dialog" aria-modal="true" aria-label="Filters">
      <div class="sx-sheet-handle"></div>
      <div class="sx-sheet-head">
        <h2 class="sx-sheet-title">Filters</h2>
        <button type="button" class="sx-sheet-close" id="sx-close-filters" aria-label="Close">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
        </button>
      </div>
      <div class="sx-sheet-body">
        <div class="sx-sheet-facet" data-facet="type">
          <div class="sx-sheet-label">Type</div>
          <div class="sx-sheet-chips" id="sheet-type"></div>
        </div>
        <div class="sx-sheet-facet" data-facet="board">
          <div class="sx-sheet-label">Board</div>
          <div class="sx-sheet-chips" id="sheet-board"></div>
        </div>
        <div class="sx-sheet-facet" data-facet="class">
          <div class="sx-sheet-label">Class</div>
          <div class="sx-sheet-chips" id="sheet-class"></div>
        </div>
        <div class="sx-sheet-facet" data-facet="subject">
          <div class="sx-sheet-label">Subject</div>
          <div class="sx-sheet-chips" id="sheet-subject"></div>
        </div>
        <div class="sx-sheet-facet" data-facet="year">
          <div class="sx-sheet-label">Year</div>
          <div class="sx-sheet-chips" id="sheet-year"></div>
        </div>
      </div>
      <div class="sx-sheet-foot">
        <button type="button" class="sx-sheet-clear" id="sx-sheet-clear">Clear all</button>
        <button type="button" class="sx-sheet-apply" id="sx-sheet-apply">Show results</button>
      </div>
    </div>
  </div>

  <script is:inline define:vars={{ INDEX_URL: url('/search-index.json') }}>
    (function () {
      var TYPE_LABELS = {
        'note': 'Note', 'quiz': 'Quiz', 'book': 'Book',
        'past-paper': 'Past Paper', 'guess-paper': 'Guess Paper',
        'pairing-scheme': 'Pairing Scheme', 'gazette': 'Gazette'
      };
      var TYPE_ORDER = ['past-paper','note','book','guess-paper','pairing-scheme','quiz','gazette'];

      var state = {
        docs: [], ready: false, q: '',
        filters: { type: 'all', board: 'all', class: 'all', subject: 'all', year: 'all' }
      };
      var miniSearch = null;
      var lastIdx = -1;
      var lastResults = [];

      var input    = document.getElementById('sx-input');
      var clearBtn = document.getElementById('sx-clear');
      var statusEl = document.getElementById('sx-status');
      var resultsEl= document.getElementById('sx-results');
      var emptyEl  = document.getElementById('sx-empty');
      var resetBtn = document.getElementById('sx-reset');
      var countBadge = document.getElementById('sx-mobile-count');

      var sheetWrap = document.getElementById('sx-sheet-wrap');
      var sheetBackdrop = document.getElementById('sx-sheet-backdrop');
      var sheetClose = document.getElementById('sx-close-filters');
      var sheetClear = document.getElementById('sx-sheet-clear');
      var sheetApply = document.getElementById('sx-sheet-apply');
      var openFilters = document.getElementById('sx-open-filters');

      function esc(s) {
        return String(s == null ? '' : s)
          .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
      }

      function loadMiniSearch(cb) {
        if (window.MiniSearch) return cb();
        var s = document.createElement('script');
        s.src = 'https://cdn.jsdelivr.net/npm/minisearch@7.1.0/dist/umd/index.min.js';
        s.onload = cb;
        s.onerror = function () { console.warn('MiniSearch CDN failed'); cb(); };
        document.head.appendChild(s);
      }

      function buildIndex() {
        if (!window.MiniSearch) { state.ready = true; render(); return; }
        miniSearch = new window.MiniSearch({
          fields: ['title', 'subject', 'board', 'bise'],
          storeFields: ['id', 'type', 'title', 'url', 'subject', 'class', 'board', 'bise', 'year'],
          idField: 'id',
          searchOptions: {
            boost: { title: 30, subject: 15, board: 10, bise: 10 },
            fuzzy: 0.2, prefix: true, combineWith: 'AND'
          }
        });
        state.docs.forEach(function (d) {
          miniSearch.add({
            id: d.id, type: d.type, title: d.title || '', url: d.url,
            subject: d.subject || '', class: String(d.class || ''),
            board: d.board || '', bise: d.bise || '', year: d.year
          });
        });
        state.ready = true;
        buildFacets();
        render();
      }

      // ═══ Facet value lists ═══
      var FACETS = {
        type:    { desktop: 'type',    sheet: 'sheet-type',    order: ['past-paper','note','book','guess-paper','pairing-scheme','quiz','gazette'], label: function (v) { return TYPE_LABELS[v] || v; } },
        board:   { desktop: 'board',   sheet: 'sheet-board',   order: null },
        class:   { desktop: 'class',   sheet: 'sheet-class',   order: ['1','2','3','4','5','6','7','8','9','10','11','12'], label: function (v) { return 'Class ' + v; } },
        subject: { desktop: 'subject', sheet: 'sheet-subject', order: null },
        year:    { desktop: 'year',    sheet: 'sheet-year',    order: null }
      };

      function buildFacets() {
        Object.keys(FACETS).forEach(function (f) {
          var cfg = FACETS[f];
          var counts = {};
          state.docs.forEach(function (d) {
            var v = d[f];
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
          } else if (f === 'year') {
            values.sort(function (a, b) { return Number(b) - Number(a); });
          } else {
            values.sort();
          }

          // Desktop dropdown menu
          var ddEl = document.querySelector('[data-facet="' + f + '"] [data-dd-menu]');
          if (ddEl) {
            var html = '<button type="button" class="sx-dd-item is-active" data-facet="' + f + '" data-value="all">All ' + f + 's</button>';
            values.forEach(function (v) {
              var label = cfg.label ? cfg.label(v) : v;
              html += '<button type="button" class="sx-dd-item" data-facet="' + f + '" data-value="' + esc(v) + '">' + esc(label) + ' <span class="sx-dd-count">' + counts[v] + '</span></button>';
            });
            ddEl.innerHTML = html;
            ddEl.querySelectorAll('.sx-dd-item').forEach(function (item) {
              item.addEventListener('click', function () {
                ddEl.querySelectorAll('.sx-dd-item').forEach(function (x) { x.classList.remove('is-active'); });
                item.classList.add('is-active');
                state.filters[f] = item.getAttribute('data-value');
                closeAllDropdowns();
                updateFacetUI();
                render();
              });
            });
          }

          // Mobile sheet chips
          var sheetEl = document.getElementById(cfg.sheet);
          if (sheetEl) {
            var sHtml = '<button type="button" class="sx-sheet-chip is-active" data-facet="' + f + '" data-value="all">All</button>';
            values.forEach(function (v) {
              var label = cfg.label ? cfg.label(v) : v;
              sHtml += '<button type="button" class="sx-sheet-chip" data-facet="' + f + '" data-value="' + esc(v) + '">' + esc(label) + '</button>';
            });
            sheetEl.innerHTML = sHtml;
            sheetEl.querySelectorAll('.sx-sheet-chip').forEach(function (chip) {
              chip.addEventListener('click', function () {
                sheetEl.querySelectorAll('.sx-sheet-chip').forEach(function (c) { c.classList.remove('is-active'); });
                chip.classList.add('is-active');
                state.filters[f] = chip.getAttribute('data-value');
                updateFacetUI();
                render();
              });
            });
          }
        });
        updateFacetUI();
      }

      // ═══ Dropdown open/close ═══
      document.querySelectorAll('[data-dd-btn]').forEach(function (btn) {
        btn.addEventListener('click', function (e) {
          e.stopPropagation();
          var parent = btn.closest('.sx-dd');
          var menu = parent.querySelector('[data-dd-menu]');
          var isOpen = !menu.hidden;
          closeAllDropdowns();
          if (!isOpen) {
            menu.hidden = false;
            parent.classList.add('is-open');
          }
        });
      });

      function closeAllDropdowns() {
        document.querySelectorAll('.sx-dd-menu').forEach(function (m) { m.hidden = true; });
        document.querySelectorAll('.sx-dd').forEach(function (d) { d.classList.remove('is-open'); });
      }
      document.addEventListener('click', function (e) {
        if (!e.target.closest('.sx-dd')) closeAllDropdowns();
      });

      // ═══ Update filter button labels + mobile badge ═══
      function updateFacetUI() {
        var active = 0;
        Object.keys(FACETS).forEach(function (f) {
          var val = state.filters[f];
          var btn = document.querySelector('[data-facet="' + f + '"] [data-dd-btn]');
          var valEl = btn ? btn.querySelector('[data-dd-value]') : null;
          if (valEl) {
            if (val === 'all') {
              valEl.textContent = 'All';
              btn.classList.remove('has-value');
            } else {
              var cfg = FACETS[f];
              valEl.textContent = cfg.label ? cfg.label(val) : val;
              btn.classList.add('has-value');
            }
          }
          if (val !== 'all') active++;
        });

        if (active > 0) {
          resetBtn.hidden = false;
          countBadge.hidden = false;
          countBadge.textContent = active;
        } else {
          resetBtn.hidden = true;
          countBadge.hidden = true;
        }
      }

      // ═══ Mobile sheet open/close ═══
      function openSheet() {
        sheetWrap.hidden = false;
        requestAnimationFrame(function () {
          sheetWrap.classList.add('is-open');
        });
        document.body.style.overflow = 'hidden';
      }
      function closeSheet() {
        sheetWrap.classList.remove('is-open');
        setTimeout(function () {
          sheetWrap.hidden = true;
          document.body.style.overflow = '';
        }, 250);
      }
      openFilters.addEventListener('click', openSheet);
      sheetClose.addEventListener('click', closeSheet);
      sheetBackdrop.addEventListener('click', closeSheet);
      sheetApply.addEventListener('click', closeSheet);
      sheetClear.addEventListener('click', function () {
        Object.keys(state.filters).forEach(function (k) { state.filters[k] = 'all'; });
        document.querySelectorAll('.sx-sheet-chip').forEach(function (c) {
          c.classList.toggle('is-active', c.getAttribute('data-value') === 'all');
        });
        updateFacetUI();
        render();
      });

      // ═══ Reset all ═══
      resetBtn.addEventListener('click', function () {
        Object.keys(state.filters).forEach(function (k) { state.filters[k] = 'all'; });
        document.querySelectorAll('.sx-dd-item').forEach(function (i) {
          i.classList.toggle('is-active', i.getAttribute('data-value') === 'all');
        });
        document.querySelectorAll('.sx-sheet-chip').forEach(function (c) {
          c.classList.toggle('is-active', c.getAttribute('data-value') === 'all');
        });
        updateFacetUI();
        render();
      });

      // ═══ Search + results ═══
      function getResults() {
        var q = state.q.trim();
        var f = state.filters;
        var pool = state.docs.filter(function (d) {
          if (f.type !== 'all' && d.type !== f.type) return false;
          if (f.board !== 'all' && d.board !== f.board) return false;
          if (f.class !== 'all' && String(d.class) !== f.class) return false;
          if (f.subject !== 'all' && d.subject !== f.subject) return false;
          if (f.year !== 'all' && String(d.year) !== f.year) return false;
          return true;
        });
        if (!q) return pool.slice(0, 60);
        if (miniSearch) {
          var allowedIds = new Set(pool.map(function (d) { return d.id; }));
          return miniSearch.search(q)
            .filter(function (m) { return allowedIds.has(m.id); })
            .slice(0, 100)
            .map(function (m) {
              return { id: m.id, type: m.type, title: m.title, url: m.url,
                subject: m.subject, class: m.class, board: m.board, bise: m.bise, year: m.year };
            });
        }
        var lower = q.toLowerCase();
        var terms = lower.split(/\s+/).filter(Boolean);
        return pool.filter(function (d) {
          var hay = [d.title, d.subject, d.board, d.bise, String(d.year)].join(' ').toLowerCase();
          return terms.every(function (t) { return hay.indexOf(t) !== -1; });
        }).slice(0, 60);
      }

      function hl(text, terms) {
        var safe = esc(text);
        if (!terms.length) return safe;
        terms.forEach(function (t) {
          if (!t) return;
          var re = new RegExp('(' + t.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + ')', 'gi');
          safe = safe.replace(re, '<mark>$1</mark>');
        });
        return safe;
      }

      function render() {
        clearBtn.classList.toggle('is-visible', input.value.length > 0);

        if (!state.ready) { statusEl.textContent = 'Loading library…'; return; }

        var q = state.q.trim();
        var hasFilter = q || Object.keys(state.filters).some(function (k) { return state.filters[k] !== 'all'; });
        var results = getResults();

        if (!hasFilter) {
          emptyEl.style.display = '';
          resultsEl.innerHTML = '';
          statusEl.textContent = state.docs.length.toLocaleString() + ' items in library';
          lastResults = [];
          return;
        }
        emptyEl.style.display = 'none';
        lastResults = results;

        var label = results.length.toLocaleString() + ' result' + (results.length === 1 ? '' : 's');
        if (q) label += ' for “' + q + '”';
        statusEl.textContent = label;

        if (!results.length) {
          resultsEl.innerHTML =
            '<div class="sx-no-results">' +
              '<div class="sx-no-results-title">No matches found</div>' +
              '<div class="sx-no-results-sub">Try a shorter keyword, check spelling, or reset the filters.</div>' +
            '</div>';
          return;
        }

        var terms = q ? q.toLowerCase().split(/\s+/).filter(Boolean) : [];
        var groups = {};
        results.forEach(function (r) {
          if (!groups[r.type]) groups[r.type] = [];
          groups[r.type].push(r);
        });
        var types = Object.keys(groups).sort(function (a, b) {
          return TYPE_ORDER.indexOf(a) - TYPE_ORDER.indexOf(b);
        });

        var html = '';
        types.forEach(function (t) {
          var items = groups[t];
          html += '<section class="sx-group">';
          html += '<header class="sx-group-head">';
          html += '<h2 class="sx-group-title">' + esc(TYPE_LABELS[t] || t) + '</h2>';
          html += '<span class="sx-group-count">' + items.length + '</span>';
          html += '</header>';
          html += '<div class="sx-group-list">';
          items.forEach(function (r, idx) {
            var badges = [];
            if (r.subject) badges.push('<span class="sx-badge">' + esc(r.subject) + '</span>');
            if (r.class)   badges.push('<span class="sx-badge sx-badge-blue">Class ' + esc(r.class) + '</span>');
            if (r.bise)    badges.push('<span class="sx-badge sx-badge-purple">' + esc(r.bise) + '</span>');
            else if (r.board) badges.push('<span class="sx-badge sx-badge-purple">' + esc(r.board) + '</span>');
            if (r.year)    badges.push('<span class="sx-badge sx-badge-muted">' + esc(r.year) + '</span>');
            html +=
              '<a href="' + esc(r.url) + '" class="sx-result" data-idx="' + idx + '">' +
                '<div class="sx-result-body">' +
                  '<div class="sx-result-title">' + hl(r.title, terms) + '</div>' +
                  (badges.length ? '<div class="sx-result-meta">' + badges.join('') + '</div>' : '') +
                '</div>' +
                '<svg class="sx-result-arrow" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>' +
              '</a>';
          });
          html += '</div></section>';
        });
        resultsEl.innerHTML = html;
      }

      // ═══ Keyboard ═══
      document.addEventListener('keydown', function (e) {
        if (e.key === '/' && document.activeElement !== input && !/INPUT|TEXTAREA/.test(document.activeElement.tagName)) {
          e.preventDefault(); input.focus(); input.select(); return;
        }
        if (e.key === 'Escape') {
          if (sheetWrap && !sheetWrap.hidden) closeSheet();
          if (input.value) { input.value = ''; state.q = ''; render(); }
        }
        if (!lastResults.length) return;
        var nodes = resultsEl.querySelectorAll('.sx-result');
        if (e.key === 'ArrowDown') { e.preventDefault(); lastIdx = Math.min(lastIdx + 1, nodes.length - 1); }
        else if (e.key === 'ArrowUp') { e.preventDefault(); lastIdx = Math.max(lastIdx - 1, 0); }
        else if (e.key === 'Enter' && lastIdx >= 0) { e.preventDefault(); nodes[lastIdx].click(); return; }
        else return;
        nodes.forEach(function (n, i) { n.classList.toggle('is-focused', i === lastIdx); });
        if (nodes[lastIdx]) nodes[lastIdx].scrollIntoView({ block: 'nearest' });
      });

      var t;
      input.addEventListener('input', function () {
        state.q = input.value;
        lastIdx = -1;
        clearTimeout(t);
        t = setTimeout(render, 60);
      });

      clearBtn.addEventListener('click', function () {
        input.value = ''; state.q = ''; lastIdx = -1; input.focus(); render();
      });

      document.querySelectorAll('.sx-popular-chip').forEach(function (btn) {
        btn.addEventListener('click', function () {
          var q = btn.getAttribute('data-search');
          input.value = q; state.q = q; input.focus(); render();
        });
      });

      // ═══ Load ═══
      var params = new URLSearchParams(location.search);
      if (params.get('q')) { input.value = params.get('q'); state.q = params.get('q'); }

      var pending = 2;
      function done() { pending--; if (pending === 0) { state.q = input.value; buildIndex(); } }

      fetch(INDEX_URL)
        .then(function (r) { if (!r.ok) throw new Error(r.status); return r.json(); })
        .then(function (data) {
          state.docs = (data || []).map(function (d) {
            return { id: d.id, type: d.type, title: d.title, url: d.url,
              subject: d.subject, class: String(d.class || ''),
              board: d.board, bise: d.bise, year: d.year };
          });
          done();
        })
        .catch(function (e) {
          console.error('Index load failed:', e);
          statusEl.textContent = 'Could not load library.';
          pending = 0;
        });
      loadMiniSearch(done);
    })();
  </script>

  <style is:global>
    /* ═══ Container ═══ */
    .sx { max-width: 1000px; margin: 0 auto; padding: 2.5rem 1.25rem 5rem; }
    @media (min-width: 640px) { .sx { padding: 3rem 1.75rem 6rem; } }
    @media (min-width: 1024px) { .sx { padding: 4rem 2.5rem 8rem; } }

    /* ═══ Header ═══ */
    .sx-head { max-width: 40rem; margin-bottom: 2rem; }
    .sx-eyebrow {
      display: inline-flex; align-items: center; gap: 0.5rem;
      font-size: 0.6875rem; font-weight: 800;
      letter-spacing: 0.14em; text-transform: uppercase;
      color: #1d4ed8;
    }
    .sx-dot { width: 6px; height: 6px; border-radius: 50%; background: #1d4ed8; }
    .sx-title {
      margin-top: 1rem;
      font-size: clamp(1.75rem, 4vw, 2.5rem);
      font-weight: 800; letter-spacing: -0.035em;
      color: #0b1220; line-height: 1.1;
    }
    .sx-lede {
      margin-top: 0.75rem; font-size: 0.9375rem;
      line-height: 1.6; color: #64748b;
    }
    .sx-lede strong { color: #0b1220; font-weight: 800; }

    /* ═══ Search bar ═══ */
    .sx-bar {
      display: flex; align-items: center; gap: 0.75rem;
      padding: 0 0.75rem 0 1.125rem;
      min-height: 3.5rem;
      border: 1px solid #e5e9f0;
      border-radius: 14px;
      background: #ffffff;
      transition: border-color .15s ease;
    }
    .sx-bar:focus-within { border-color: #1d4ed8; }
    .sx-bar-icon { display: inline-flex; color: #94a3b8; flex-shrink: 0; }
    .sx-input {
      flex: 1; min-width: 0; border: 0; outline: none;
      background: transparent; font-size: 1rem; font-weight: 500;
      color: #0b1220; font-family: inherit; padding: 1rem 0;
    }
    .sx-input::placeholder { color: #94a3b8; }
    .sx-kbd {
      display: none; flex-shrink: 0;
      font-family: ui-monospace, monospace;
      font-size: 0.6875rem; font-weight: 700;
      color: #94a3b8;
      padding: 0.25rem 0.5rem;
      border: 1px solid #e5e9f0; border-radius: 6px;
      background: #f8fafc;
    }
    @media (min-width: 640px) { .sx-kbd { display: inline-block; } }
    .sx-clear {
      display: none; align-items: center; justify-content: center;
      width: 1.75rem; height: 1.75rem; flex-shrink: 0;
      border: 0; border-radius: 6px;
      background: transparent; color: #94a3b8; cursor: pointer;
    }
    .sx-clear:hover { background: #f1f5f9; color: #475569; }
    .sx-clear.is-visible { display: inline-flex; }

    /* ═══ Toolbar ═══ */
    .sx-toolbar {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      margin-top: 1rem;
      flex-wrap: wrap;
    }

    /* Desktop dropdowns */
    .sx-dd-wrap { display: none; align-items: center; gap: 0.5rem; flex-wrap: wrap; }
    @media (min-width: 768px) { .sx-dd-wrap { display: flex; } }

    .sx-dd { position: relative; }
    .sx-dd-btn {
      display: inline-flex; align-items: center; gap: 0.5rem;
      padding: 0.5rem 0.75rem;
      border: 1px solid #e5e9f0;
      border-radius: 10px;
      background: #ffffff;
      color: #334155;
      font-family: inherit;
      font-size: 0.8125rem;
      font-weight: 700;
      cursor: pointer;
      transition: all .15s ease;
    }
    .sx-dd-btn:hover { border-color: #c7d7fe; background: #fafbff; }
    .sx-dd.is-open .sx-dd-btn,
    .sx-dd-btn.has-value { border-color: #1d4ed8; color: #1d4ed8; background: #eff4ff; }
    .sx-dd-btn svg { color: #94a3b8; transition: transform .15s ease; }
    .sx-dd.is-open .sx-dd-btn svg { transform: rotate(180deg); }
    .sx-dd-label { color: inherit; opacity: 0.7; }
    .sx-dd-value { color: inherit; font-weight: 800; }

    .sx-dd-menu {
      position: absolute;
      top: calc(100% + 6px);
      left: 0;
      min-width: 220px;
      max-height: 320px;
      overflow-y: auto;
      background: #ffffff;
      border: 1px solid #e5e9f0;
      border-radius: 12px;
      padding: 0.375rem;
      z-index: 60;
      animation: ddIn .15s ease both;
    }
    @keyframes ddIn {
      from { opacity: 0; transform: translateY(-4px); }
      to { opacity: 1; transform: translateY(0); }
    }
    .sx-dd-item {
      display: flex; align-items: center; justify-content: space-between;
      gap: 0.75rem;
      width: 100%;
      padding: 0.5rem 0.75rem;
      border: 0; border-radius: 8px;
      background: transparent;
      color: #334155;
      font-family: inherit;
      font-size: 0.8125rem;
      font-weight: 600;
      text-align: left;
      cursor: pointer;
      transition: background-color .1s ease;
    }
    .sx-dd-item:hover { background: #f8fafc; color: #0b1220; }
    .sx-dd-item.is-active {
      background: #eff4ff;
      color: #1d4ed8;
      font-weight: 800;
    }
    .sx-dd-count {
      font-size: 0.6875rem; font-weight: 700;
      color: #94a3b8;
      background: #f1f5f9;
      padding: 0.125rem 0.4rem;
      border-radius: 999px;
    }
    .sx-dd-item.is-active .sx-dd-count { background: #c7d7fe; color: #1d4ed8; }

    .sx-reset {
      margin-left: auto;
      padding: 0.5rem 0.75rem;
      border: 0; background: transparent;
      color: #1d4ed8;
      font-family: inherit;
      font-size: 0.8125rem;
      font-weight: 700;
      cursor: pointer;
    }
    .sx-reset:hover { text-decoration: underline; }

    /* Mobile filter button */
    .sx-mobile-filter {
      display: inline-flex; align-items: center; gap: 0.5rem;
      padding: 0.625rem 1rem;
      border: 1px solid #e5e9f0;
      border-radius: 10px;
      background: #ffffff;
      color: #0b1220;
      font-family: inherit;
      font-size: 0.8125rem;
      font-weight: 700;
      cursor: pointer;
      transition: all .15s ease;
    }
    .sx-mobile-filter:hover { border-color: #c7d7fe; background: #fafbff; }
    @media (min-width: 768px) { .sx-mobile-filter { display: none; } }

    .sx-mobile-count {
      display: inline-flex; align-items: center; justify-content: center;
      min-width: 1.25rem; height: 1.25rem;
      padding: 0 0.375rem;
      background: #1d4ed8; color: #ffffff;
      border-radius: 999px;
      font-size: 0.6875rem; font-weight: 800;
    }

    /* ═══ Status ═══ */
    .sx-status {
      margin: 1.5rem 0 1rem;
      font-size: 0.8125rem;
      font-weight: 700;
      letter-spacing: 0.02em;
      color: #64748b;
    }

    /* ═══ Results ═══ */
    .sx-group { margin-bottom: 2rem; }
    .sx-group-head {
      display: flex; align-items: baseline; gap: 0.5rem;
      margin-bottom: 0.75rem; padding-bottom: 0.5rem;
      border-bottom: 1px solid #e5e9f0;
    }
    .sx-group-title {
      font-size: 0.75rem; font-weight: 800;
      letter-spacing: 0.1em; text-transform: uppercase;
      color: #0b1220;
    }
    .sx-group-count {
      font-size: 0.6875rem; font-weight: 700; color: #94a3b8;
    }
    .sx-group-list { display: flex; flex-direction: column; gap: 0.5rem; }

    .sx-result {
      display: flex; align-items: center; gap: 1rem;
      padding: 0.875rem 1rem;
      background: #ffffff;
      border: 1px solid #e5e9f0;
      border-radius: 12px;
      text-decoration: none;
      transition: border-color .15s ease, background-color .15s ease;
    }
    .sx-result:hover, .sx-result.is-focused {
      border-color: #1d4ed8;
      background: #fafbff;
    }
    .sx-result-body { flex: 1; min-width: 0; }
    .sx-result-title {
      font-size: 0.9375rem; font-weight: 800;
      letter-spacing: -0.02em; color: #0b1220;
      line-height: 1.35;
    }
    .sx-result:hover .sx-result-title,
    .sx-result.is-focused .sx-result-title { color: #1d4ed8; }
    .sx-result-meta { margin-top: 0.375rem; display: flex; flex-wrap: wrap; gap: 0.375rem; }
    .sx-badge {
      font-size: 0.6875rem; font-weight: 700;
      letter-spacing: 0.03em; text-transform: uppercase;
      padding: 0.15rem 0.5rem;
      border-radius: 5px;
      background: #f1f5f9; color: #475569;
    }
    .sx-badge-blue { background: #eff4ff; color: #1d4ed8; }
    .sx-badge-purple { background: #f5f3ff; color: #6d28d9; }
    .sx-badge-muted { background: #f1f5f9; color: #64748b; }
    .sx-result-arrow { flex-shrink: 0; color: #cbd5e1; transition: color .15s ease; }
    .sx-result:hover .sx-result-arrow,
    .sx-result.is-focused .sx-result-arrow { color: #1d4ed8; }

    mark {
      background: #fffbeb; color: #92400e;
      padding: 0 0.15em; border-radius: 3px; font-weight: 800;
    }

    /* ═══ Empty state ═══ */
    .sx-empty { margin-top: 2rem; }
    .sx-empty-section { margin-bottom: 2.5rem; }
    .sx-empty-head {
      font-size: 0.75rem; font-weight: 800;
      letter-spacing: 0.1em; text-transform: uppercase;
      color: #94a3b8;
      margin-bottom: 0.875rem;
    }
    .sx-popular { display: flex; flex-wrap: wrap; gap: 0.5rem; }
    .sx-popular-chip {
      padding: 0.5rem 0.875rem;
      font-size: 0.8125rem; font-weight: 700;
      color: #334155;
      background: #f8fafc;
      border: 1px solid #e5e9f0;
      border-radius: 999px;
      cursor: pointer;
      font-family: inherit;
      transition: all .15s ease;
    }
    .sx-popular-chip:hover {
      color: #1d4ed8; background: #ffffff; border-color: #1d4ed8;
    }
    .sx-browse-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 0.5rem;
    }
    @media (min-width: 640px) { .sx-browse-grid { grid-template-columns: repeat(3, 1fr); } }
    .sx-browse-link {
      display: flex; align-items: center; justify-content: space-between;
      gap: 0.5rem;
      padding: 0.875rem 1rem;
      font-size: 0.875rem; font-weight: 700;
      color: #0b1220;
      background: #ffffff;
      border: 1px solid #e5e9f0;
      border-radius: 10px;
      text-decoration: none;
      transition: all .15s ease;
    }
    .sx-browse-link svg { color: #cbd5e1; }
    .sx-browse-link:hover { border-color: #1d4ed8; color: #1d4ed8; }
    .sx-browse-link:hover svg { color: #1d4ed8; }

    .sx-no-results {
      padding: 3rem 1.5rem; text-align: center;
      border: 1px dashed #cbd5e1; border-radius: 14px;
      background: #ffffff;
    }
    .sx-no-results-title { font-size: 1rem; font-weight: 800; color: #0b1220; }
    .sx-no-results-sub { margin-top: 0.5rem; font-size: 0.875rem; color: #64748b; }

    /* ═══ Mobile filter sheet ═══ */
    .sx-sheet-wrap {
      position: fixed; inset: 0; z-index: 200;
      display: flex; align-items: flex-end; justify-content: center;
    }
    .sx-sheet-wrap[hidden] { display: none; }
    .sx-sheet-backdrop {
      position: absolute; inset: 0;
      background: rgba(15, 23, 42, 0.5);
      opacity: 0;
      transition: opacity .25s ease;
    }
    .sx-sheet-wrap.is-open .sx-sheet-backdrop { opacity: 1; }
    .sx-sheet {
      position: relative;
      width: 100%;
      max-width: 640px;
      max-height: 85vh;
      background: #ffffff;
      border-top-left-radius: 20px;
      border-top-right-radius: 20px;
      transform: translateY(100%);
      transition: transform .3s cubic-bezier(.16,1,.3,1);
      display: flex; flex-direction: column;
      overflow: hidden;
    }
    .sx-sheet-wrap.is-open .sx-sheet { transform: translateY(0); }
    .sx-sheet-handle {
      width: 40px; height: 4px;
      background: #cbd5e1;
      border-radius: 999px;
      margin: 0.75rem auto 0.25rem;
    }
    .sx-sheet-head {
      display: flex; align-items: center; justify-content: space-between;
      padding: 1rem 1.25rem;
      border-bottom: 1px solid #e5e9f0;
    }
    .sx-sheet-title {
      font-size: 1rem; font-weight: 800;
      letter-spacing: -0.02em; color: #0b1220;
    }
    .sx-sheet-close {
      display: grid; place-items: center;
      width: 2rem; height: 2rem;
      border: 0; border-radius: 8px;
      background: transparent; color: #64748b;
      cursor: pointer;
    }
    .sx-sheet-close:hover { background: #f1f5f9; }
    .sx-sheet-body {
      flex: 1; overflow-y: auto;
      padding: 1.25rem;
      display: flex; flex-direction: column; gap: 1.5rem;
    }
    .sx-sheet-facet { display: flex; flex-direction: column; gap: 0.625rem; }
    .sx-sheet-label {
      font-size: 0.6875rem; font-weight: 800;
      letter-spacing: 0.1em; text-transform: uppercase;
      color: #94a3b8;
    }
    .sx-sheet-chips { display: flex; flex-wrap: wrap; gap: 0.375rem; }
    .sx-sheet-chip {
      padding: 0.5rem 0.875rem;
      font-size: 0.8125rem; font-weight: 700;
      color: #334155;
      background: #ffffff;
      border: 1px solid #e5e9f0;
      border-radius: 999px;
      cursor: pointer;
      font-family: inherit;
      transition: all .15s ease;
    }
    .sx-sheet-chip:hover { border-color: #1d4ed8; color: #1d4ed8; }
    .sx-sheet-chip.is-active {
      background: #1d4ed8; border-color: #1d4ed8;
      color: #ffffff !important;
    }
    .sx-sheet-foot {
      display: flex; gap: 0.75rem;
      padding: 1rem 1.25rem calc(1rem + env(safe-area-inset-bottom, 0px));
      border-top: 1px solid #e5e9f0;
      background: #ffffff;
    }
    .sx-sheet-clear {
      flex: 1;
      padding: 0.875rem 1rem;
      border: 1px solid #e5e9f0;
      border-radius: 12px;
      background: #ffffff;
      color: #334155;
      font-family: inherit;
      font-size: 0.875rem;
      font-weight: 700;
      cursor: pointer;
    }
    .sx-sheet-clear:hover { border-color: #cbd5e1; }
    .sx-sheet-apply {
      flex: 2;
      padding: 0.875rem 1rem;
      border: 1px solid #1d4ed8;
      border-radius: 12px;
      background: #1d4ed8;
      color: #ffffff;
      font-family: inherit;
      font-size: 0.875rem;
      font-weight: 700;
      cursor: pointer;
    }
    .sx-sheet-apply:hover { background: #1e3a8a; border-color: #1e3a8a; }
  </style>
</BaseLayout>
ASTRO

echo "  ✓ search.astro rebuilt"

echo ""
echo "Rebuilding (4-6 min)..."
rm -rf dist .astro node_modules/.vite
npm run build 2>&1 | tail -8

echo ""
echo "════════════════════════════════════════════════════"
echo "  DONE"
echo ""
echo "  Preview:"
echo "    bash start-server.sh"
echo ""
echo "  Open: http://localhost:4321/My-edu-site/search/"
echo ""
echo "  New design:"
echo "    · Desktop: 5 compact dropdowns in a single row"
echo "      Each dropdown shows a count badge per option"
echo "      Active filters turn the button blue"
echo "    · Mobile: single 'Filters' button with active count badge"
echo "      Tapping opens a bottom sheet (slides up from bottom)"
echo "      Sheet has all 5 filter groups with chips"
echo "      Apply button + Clear all button at bottom"
echo "    · Reset button appears only when filters are active"
echo ""
echo "  Push when happy:"
echo "    git add ."
echo "    git commit -m 'Search UI v3: dropdowns + mobile filter sheet'"
echo "    git push"
echo ""
echo "  Revert:"
echo "    git checkout backup-pre-srch2"
echo "════════════════════════════════════════════════════"