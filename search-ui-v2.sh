#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "════════════════════════════════════════════"
echo "  Search UI v2 — cleaner, faster, scannable"
echo "════════════════════════════════════════════"
echo ""

git branch -f backup-pre-search-ui-v2 2>/dev/null || true
echo "  ✓ backup-pre-search-ui-v2 created"
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
  isPartOf: { '@type': 'WebSite', name: 'Parhayi' },
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
  'Physics class 9', 'Past papers Lahore 2024', 'English essays class 10',
  'Chemistry notes', 'Mathematics class 10', 'Biology class 11',
  'Federal board papers', 'Computer science notes',
];
---
<BaseLayout
  title="Search — Parhayi"
  description="Search 6,800+ notes, past papers, guess papers, quizzes, textbooks and result gazettes for Pakistani students. Filter by board, class, subject and year."
  noindex={true}
  jsonLd={jsonLd}
>
  <div class="srch-container">
    <!-- ═══ HEADER ═══ -->
    <header class="srch-header">
      <div class="srch-eyebrow">
        <span class="srch-eyebrow-dot"></span>
        Search
      </div>
      <h1 class="srch-title">Find anything in the library</h1>
      <p class="srch-subtitle">
        Search across <strong>6,800+ items</strong> — notes, past papers, guess papers, quizzes, textbooks and result gazettes.
      </p>
    </header>

    <!-- ═══ SEARCH BAR (sticky) ═══ -->
    <div class="srch-bar-wrap" id="srch-bar-wrap">
      <div class="srch-bar">
        <span class="srch-bar-icon" aria-hidden="true">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
        </span>
        <input
          type="search"
          id="srch-input"
          class="srch-input"
          placeholder="Search notes, past papers, books…"
          autocomplete="off"
          autocapitalize="off"
          spellcheck="false"
          aria-label="Search library"
          aria-autocomplete="list"
          aria-controls="srch-results"
        />
        <button type="button" id="srch-clear" class="srch-clear" aria-label="Clear search">
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
        </button>
        <kbd class="srch-kbd">/</kbd>
      </div>

      <!-- Active filter chips -->
      <div class="srch-active" id="srch-active" aria-live="polite"></div>
    </div>

    <!-- ═══ FILTERS ═══ -->
    <section class="srch-filters" id="srch-filters">
      <div class="srch-filter" data-facet="type">
        <span class="srch-filter-label">Type</span>
        <div class="srch-chips" id="chips-type"></div>
      </div>
      <div class="srch-filter" data-facet="board">
        <span class="srch-filter-label">Board</span>
        <div class="srch-chips" id="chips-board"></div>
      </div>
      <div class="srch-filter" data-facet="class">
        <span class="srch-filter-label">Class</span>
        <div class="srch-chips" id="chips-class"></div>
      </div>
      <div class="srch-filter" data-facet="subject">
        <span class="srch-filter-label">Subject</span>
        <div class="srch-chips" id="chips-subject"></div>
      </div>
      <div class="srch-filter" data-facet="year">
        <span class="srch-filter-label">Year</span>
        <div class="srch-chips" id="chips-year"></div>
      </div>
    </section>

    <!-- ═══ STATUS ═══ -->
    <div class="srch-status-row">
      <div class="srch-status" id="srch-status" aria-live="polite">Loading library…</div>
      <button type="button" class="srch-reset" id="srch-reset" hidden>Reset filters</button>
    </div>

    <!-- ═══ RESULTS ═══ -->
    <div id="srch-results" class="srch-results"></div>

    <!-- ═══ EMPTY STATE (no query) ═══ -->
    <div id="srch-empty" class="srch-empty">
      <div class="srch-empty-section">
        <h2 class="srch-empty-heading">Popular searches</h2>
        <div class="srch-popular">
          {popularSearches.map(p => (
            <button type="button" class="srch-popular-chip" data-search={p}>{p}</button>
          ))}
        </div>
      </div>
      <div class="srch-empty-section">
        <h2 class="srch-empty-heading">Or browse by category</h2>
        <div class="srch-browse-grid">
          {browseLinks.map(c => (
            <a href={url(c.href)} class="srch-browse-link">
              <span>{c.label}</span>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>
            </a>
          ))}
        </div>
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
        docs: [],
        ready: false,
        q: '',
        filters: { type: 'all', board: 'all', class: 'all', subject: 'all', year: 'all' },
      };
      var miniSearch = null;
      var lastSelectedIndex = -1;
      var lastResults = [];

      var input    = document.getElementById('srch-input');
      var clearBtn = document.getElementById('srch-clear');
      var statusEl = document.getElementById('srch-status');
      var resultsEl= document.getElementById('srch-results');
      var activeEl = document.getElementById('srch-active');
      var emptyEl  = document.getElementById('srch-empty');
      var resetBtn = document.getElementById('srch-reset');
      var barWrap  = document.getElementById('srch-bar-wrap');

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
            fuzzy: 0.2,
            prefix: true,
            combineWith: 'AND'
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
        renderFilters();
        render();
      }

      // ── Filter chips ──
      var facetConfigs = {
        type:    { el: 'chips-type',    key: 'type',    order: ['past-paper','note','book','guess-paper','pairing-scheme','quiz','gazette'], label: function (v) { return TYPE_LABELS[v] || v; } },
        board:   { el: 'chips-board',   key: 'board',   order: null },
        class:   { el: 'chips-class',   key: 'class',   order: ['1','2','3','4','5','6','7','8','9','10','11','12'] },
        subject: { el: 'chips-subject', key: 'subject', order: null },
        year:    { el: 'chips-year',    key: 'year',    order: null }
      };

      function renderFilters() {
        Object.keys(facetConfigs).forEach(function (f) {
          var cfg = facetConfigs[f];
          var el = document.getElementById(cfg.el);
          if (!el) return;
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

          var html = '<button type="button" class="srch-chip is-active" data-facet="' + cfg.key + '" data-value="all">All</button>';
          values.forEach(function (v) {
            var label = cfg.label ? cfg.label(v) : v;
            html += '<button type="button" class="srch-chip" data-facet="' + cfg.key + '" data-value="' + esc(v) + '">' + esc(label) + '</button>';
          });
          el.innerHTML = html;
          el.querySelectorAll('.srch-chip').forEach(function (chip) {
            chip.addEventListener('click', function () {
              el.querySelectorAll('.srch-chip').forEach(function (c) { c.classList.remove('is-active'); });
              chip.classList.add('is-active');
              state.filters[cfg.key] = chip.getAttribute('data-value');
              render();
            });
          });
        });
      }

      function renderActiveChips() {
        var active = [];
        Object.keys(state.filters).forEach(function (k) {
          if (state.filters[k] !== 'all') {
            var label = facetConfigs[k].label ? facetConfigs[k].label(state.filters[k]) : state.filters[k];
            active.push({ key: k, value: state.filters[k], label: k.charAt(0).toUpperCase() + k.slice(1) + ': ' + label });
          }
        });
        if (!active.length) {
          activeEl.innerHTML = '';
          resetBtn.hidden = true;
          return;
        }
        resetBtn.hidden = false;
        activeEl.innerHTML = active.map(function (a) {
          return '<button type="button" class="srch-active-chip" data-remove="' + esc(a.key) + '">' +
            esc(a.label) +
            '<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>' +
          '</button>';
        }).join('');
        activeEl.querySelectorAll('[data-remove]').forEach(function (btn) {
          btn.addEventListener('click', function () {
            var k = btn.getAttribute('data-remove');
            state.filters[k] = 'all';
            var group = document.querySelector('[data-facet="' + k + '"]');
            if (group) {
              group.querySelectorAll('.srch-chip').forEach(function (c) {
                c.classList.toggle('is-active', c.getAttribute('data-value') === 'all');
              });
            }
            render();
          });
        });
      }

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

      function highlight(text, terms) {
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
        renderActiveChips();

        if (!state.ready) {
          statusEl.textContent = 'Loading library…';
          resultsEl.innerHTML = '';
          return;
        }

        var q = state.q.trim();
        var hasFilter = q || Object.keys(state.filters).some(function (k) { return state.filters[k] !== 'all'; });
        var results = getResults();

        // Empty state (no query, no filters)
        if (!hasFilter) {
          emptyEl.style.display = '';
          resultsEl.innerHTML = '';
          statusEl.textContent = state.docs.length.toLocaleString() + ' items in library';
          lastResults = [];
          return;
        }

        emptyEl.style.display = 'none';
        lastResults = results;

        // Status
        var statusText = results.length.toLocaleString() + ' result' + (results.length === 1 ? '' : 's');
        if (q) statusText += ' for “' + q + '”';
        statusEl.textContent = statusText;

        if (!results.length) {
          resultsEl.innerHTML =
            '<div class="srch-no-results">' +
              '<div class="srch-no-results-title">No matches found</div>' +
              '<div class="srch-no-results-sub">Try a shorter keyword, check spelling, or remove filters.</div>' +
            '</div>';
          return;
        }

        var terms = q ? q.toLowerCase().split(/\s+/).filter(Boolean) : [];
        var groups = {};
        results.forEach(function (r) {
          if (!groups[r.type]) groups[r.type] = [];
          groups[r.type].push(r);
        });
        var orderedTypes = Object.keys(groups).sort(function (a, b) {
          return TYPE_ORDER.indexOf(a) - TYPE_ORDER.indexOf(b);
        });

        var html = '';
        orderedTypes.forEach(function (t) {
          var items = groups[t];
          html += '<section class="srch-group">';
          html += '<header class="srch-group-head">';
          html += '<h2 class="srch-group-title">' + esc(TYPE_LABELS[t] || t) + '</h2>';
          html += '<span class="srch-group-count">' + items.length + '</span>';
          html += '</header>';
          html += '<div class="srch-group-list">';
          items.forEach(function (r, idx) {
            var badges = [];
            if (r.subject) badges.push('<span class="srch-badge">' + esc(r.subject) + '</span>');
            if (r.class)   badges.push('<span class="srch-badge srch-badge-blue">Class ' + esc(r.class) + '</span>');
            if (r.bise)    badges.push('<span class="srch-badge srch-badge-purple">' + esc(r.bise) + '</span>');
            else if (r.board) badges.push('<span class="srch-badge srch-badge-purple">' + esc(r.board) + '</span>');
            if (r.year)    badges.push('<span class="srch-badge srch-badge-muted">' + esc(r.year) + '</span>');

            html +=
              '<a href="' + esc(r.url) + '" class="srch-result" data-result-index="' + idx + '">' +
                '<div class="srch-result-body">' +
                  '<div class="srch-result-title">' + highlight(r.title, terms) + '</div>' +
                  (badges.length ? '<div class="srch-result-meta">' + badges.join('') + '</div>' : '') +
                '</div>' +
                '<svg class="srch-result-arrow" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>' +
              '</a>';
          });
          html += '</div></section>';
        });
        resultsEl.innerHTML = html;
      }

      // ── Keyboard navigation ──
      document.addEventListener('keydown', function (e) {
        if (e.key === '/' && document.activeElement !== input && !/INPUT|TEXTAREA/.test(document.activeElement.tagName)) {
          e.preventDefault(); input.focus(); input.select(); return;
        }
        if (!lastResults.length) return;
        var nodes = resultsEl.querySelectorAll('.srch-result');
        if (e.key === 'ArrowDown') {
          e.preventDefault();
          lastSelectedIndex = Math.min(lastSelectedIndex + 1, nodes.length - 1);
        } else if (e.key === 'ArrowUp') {
          e.preventDefault();
          lastSelectedIndex = Math.max(lastSelectedIndex - 1, 0);
        } else if (e.key === 'Enter' && lastSelectedIndex >= 0) {
          e.preventDefault();
          nodes[lastSelectedIndex].click();
          return;
        } else {
          return;
        }
        nodes.forEach(function (n, i) { n.classList.toggle('is-focused', i === lastSelectedIndex); });
        if (nodes[lastSelectedIndex]) nodes[lastSelectedIndex].scrollIntoView({ block: 'nearest' });
      });

      input.addEventListener('keydown', function (e) {
        if (e.key === 'Escape' && input.value) { input.value = ''; state.q = ''; render(); }
      });

      var t;
      input.addEventListener('input', function () {
        state.q = input.value;
        lastSelectedIndex = -1;
        clearTimeout(t);
        t = setTimeout(render, 60);
      });

      clearBtn.addEventListener('click', function () {
        input.value = ''; state.q = ''; lastSelectedIndex = -1; input.focus(); render();
      });

      resetBtn.addEventListener('click', function () {
        Object.keys(state.filters).forEach(function (k) { state.filters[k] = 'all'; });
        document.querySelectorAll('.srch-chip').forEach(function (c) {
          c.classList.toggle('is-active', c.getAttribute('data-value') === 'all');
        });
        render();
      });

      document.querySelectorAll('.srch-popular-chip').forEach(function (btn) {
        btn.addEventListener('click', function () {
          var q = btn.getAttribute('data-search');
          input.value = q; state.q = q;
          input.focus();
          render();
        });
      });

      // ── Sticky bar shadow on scroll ──
      var lastY = 0;
      window.addEventListener('scroll', function () {
        var y = window.scrollY;
        barWrap.classList.toggle('is-stuck', y > 220);
        lastY = y;
      }, { passive: true });

      // ── URL param ──
      var params = new URLSearchParams(location.search);
      if (params.get('q')) { input.value = params.get('q'); state.q = params.get('q'); }

      // ── Load ──
      var pending = 2;
      function done() {
        pending--;
        if (pending === 0) {
          state.q = input.value;
          buildIndex();
        }
      }

      fetch(INDEX_URL)
        .then(function (r) { if (!r.ok) throw new Error(r.status); return r.json(); })
        .then(function (data) {
          state.docs = (data || []).map(function (d) {
            return {
              id: d.id, type: d.type, title: d.title, url: d.url,
              subject: d.subject, class: String(d.class || ''),
              board: d.board, bise: d.bise, year: d.year
            };
          });
          done();
        })
        .catch(function (e) {
          console.error('Index load failed:', e);
          statusEl.textContent = 'Could not load library.';
          resultsEl.innerHTML = '<div class="srch-no-results"><div class="srch-no-results-title">Search unavailable</div><div class="srch-no-results-sub">Please refresh the page.</div></div>';
          pending = 0;
        });

      loadMiniSearch(done);
    })();
  </script>

  <style is:global>
    /* ═══ Container ═══ */
    .srch-container {
      max-width: 1080px;
      margin: 0 auto;
      padding: 2.5rem 1.25rem 5rem;
    }
    @media (min-width: 640px) { .srch-container { padding: 3rem 1.75rem 6rem; } }
    @media (min-width: 1024px) { .srch-container { padding: 4rem 2.5rem 8rem; } }

    /* ═══ Header ═══ */
    .srch-header { max-width: 40rem; margin-bottom: 2rem; }
    .srch-eyebrow {
      display: inline-flex;
      align-items: center;
      gap: 0.5rem;
      font-size: 0.6875rem;
      font-weight: 800;
      letter-spacing: 0.14em;
      text-transform: uppercase;
      color: #1d4ed8;
    }
    .srch-eyebrow-dot { width: 6px; height: 6px; border-radius: 50%; background: #1d4ed8; }
    .srch-title {
      margin-top: 1rem;
      font-size: clamp(1.75rem, 4vw, 2.5rem);
      font-weight: 800;
      letter-spacing: -0.035em;
      color: #0b1220;
      line-height: 1.1;
    }
    .srch-subtitle {
      margin-top: 0.75rem;
      font-size: 0.9375rem;
      line-height: 1.6;
      color: #64748b;
    }
    .srch-subtitle strong { color: #0b1220; font-weight: 800; }

    /* ═══ Search bar (sticky) ═══ */
    .srch-bar-wrap {
      position: sticky;
      top: 4rem;
      z-index: 30;
      background: #ffffff;
      padding: 0.75rem 0;
      margin: 0 -1.25rem;
      padding-left: 1.25rem;
      padding-right: 1.25rem;
      transition: box-shadow .2s ease, border-color .2s ease;
      border-bottom: 1px solid transparent;
    }
    @media (min-width: 640px) { .srch-bar-wrap { margin: 0 -1.75rem; padding-left: 1.75rem; padding-right: 1.75rem; } }
    @media (min-width: 1024px){ .srch-bar-wrap { margin: 0 -2.5rem; padding-left: 2.5rem; padding-right: 2.5rem; top: 4.5rem; } }
    .srch-bar-wrap.is-stuck {
      border-bottom-color: #e5e9f0;
    }

    .srch-bar {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      padding: 0 0.75rem 0 1.125rem;
      min-height: 3.5rem;
      border: 1px solid #e5e9f0;
      border-radius: 14px;
      background: #ffffff;
      transition: border-color .15s ease;
    }
    .srch-bar:focus-within { border-color: #1d4ed8; }
    .srch-bar-icon { display: inline-flex; color: #94a3b8; flex-shrink: 0; }
    .srch-input {
      flex: 1;
      min-width: 0;
      border: 0;
      outline: none;
      background: transparent;
      font-size: 1rem;
      font-weight: 500;
      color: #0b1220;
      font-family: inherit;
      padding: 1rem 0;
    }
    .srch-input::placeholder { color: #94a3b8; }
    .srch-kbd {
      display: none;
      flex-shrink: 0;
      font-family: ui-monospace, monospace;
      font-size: 0.6875rem;
      font-weight: 700;
      color: #94a3b8;
      padding: 0.25rem 0.5rem;
      border: 1px solid #e5e9f0;
      border-radius: 6px;
      background: #f8fafc;
    }
    @media (min-width: 640px) { .srch-kbd { display: inline-block; } }
    .srch-clear {
      display: none;
      align-items: center;
      justify-content: center;
      width: 1.75rem;
      height: 1.75rem;
      flex-shrink: 0;
      border: 0;
      border-radius: 6px;
      background: transparent;
      color: #94a3b8;
      cursor: pointer;
    }
    .srch-clear:hover { background: #f1f5f9; color: #475569; }
    .srch-clear.is-visible { display: inline-flex; }

    /* Active filter chips under search bar */
    .srch-active {
      display: flex;
      flex-wrap: wrap;
      gap: 0.375rem;
      margin-top: 0.625rem;
    }
    .srch-active-chip {
      display: inline-flex;
      align-items: center;
      gap: 0.375rem;
      padding: 0.3125rem 0.625rem;
      font-size: 0.75rem;
      font-weight: 700;
      color: #1d4ed8;
      background: #eff4ff;
      border: 1px solid #c7d7fe;
      border-radius: 999px;
      cursor: pointer;
      font-family: inherit;
    }
    .srch-active-chip:hover { background: #dbe4fd; }

    /* ═══ Filters ═══ */
    .srch-filters {
      display: flex;
      flex-direction: column;
      gap: 0.75rem;
      margin-top: 1.25rem;
      padding-bottom: 1.25rem;
      border-bottom: 1px solid #e5e9f0;
    }
    .srch-filter { display: flex; align-items: flex-start; gap: 0.75rem; }
    .srch-filter-label {
      flex-shrink: 0;
      width: 3.75rem;
      padding-top: 0.4rem;
      font-size: 0.625rem;
      font-weight: 800;
      letter-spacing: 0.1em;
      text-transform: uppercase;
      color: #94a3b8;
    }
    .srch-chips {
      display: flex;
      gap: 0.375rem;
      overflow-x: auto;
      padding-bottom: 0.25rem;
      scrollbar-width: none;
      flex: 1;
      min-width: 0;
    }
    .srch-chips::-webkit-scrollbar { display: none; }
    .srch-chip {
      flex-shrink: 0;
      padding: 0.375rem 0.75rem;
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
    .srch-chip:hover { border-color: #1d4ed8; color: #1d4ed8; }
    .srch-chip.is-active {
      background: #1d4ed8;
      border-color: #1d4ed8;
      color: #ffffff !important;
    }

    /* ═══ Status ═══ */
    .srch-status-row {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 1rem;
      margin: 1.25rem 0 1rem;
    }
    .srch-status {
      font-size: 0.8125rem;
      font-weight: 700;
      letter-spacing: 0.02em;
      color: #64748b;
    }
    .srch-reset {
      font-size: 0.75rem;
      font-weight: 700;
      color: #1d4ed8;
      background: none;
      border: 0;
      cursor: pointer;
      padding: 0;
      font-family: inherit;
    }
    .srch-reset:hover { text-decoration: underline; }

    /* ═══ Results ═══ */
    .srch-group { margin-bottom: 2rem; }
    .srch-group-head {
      display: flex;
      align-items: baseline;
      gap: 0.5rem;
      margin-bottom: 0.75rem;
      padding-bottom: 0.5rem;
      border-bottom: 1px solid #e5e9f0;
    }
    .srch-group-title {
      font-size: 0.75rem;
      font-weight: 800;
      letter-spacing: 0.1em;
      text-transform: uppercase;
      color: #0b1220;
    }
    .srch-group-count {
      font-size: 0.6875rem;
      font-weight: 700;
      color: #94a3b8;
    }
    .srch-group-list { display: flex; flex-direction: column; gap: 0.5rem; }

    .srch-result {
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
    .srch-result:hover,
    .srch-result.is-focused {
      border-color: #1d4ed8;
      background: #fafbff;
    }
    .srch-result-body { flex: 1; min-width: 0; }
    .srch-result-title {
      font-size: 0.9375rem;
      font-weight: 800;
      letter-spacing: -0.02em;
      color: #0b1220;
      line-height: 1.35;
    }
    .srch-result:hover .srch-result-title,
    .srch-result.is-focused .srch-result-title { color: #1d4ed8; }
    .srch-result-meta { margin-top: 0.375rem; display: flex; flex-wrap: wrap; gap: 0.375rem; }
    .srch-badge {
      font-size: 0.6875rem;
      font-weight: 700;
      letter-spacing: 0.03em;
      text-transform: uppercase;
      padding: 0.15rem 0.5rem;
      border-radius: 5px;
      background: #f1f5f9;
      color: #475569;
    }
    .srch-badge-blue { background: #eff4ff; color: #1d4ed8; }
    .srch-badge-purple { background: #f5f3ff; color: #6d28d9; }
    .srch-badge-muted { background: #f1f5f9; color: #64748b; }
    .srch-result-arrow { flex-shrink: 0; color: #cbd5e1; transition: color .15s ease; }
    .srch-result:hover .srch-result-arrow,
    .srch-result.is-focused .srch-result-arrow { color: #1d4ed8; }

    mark {
      background: #fffbeb;
      color: #92400e;
      padding: 0 0.15em;
      border-radius: 3px;
      font-weight: 800;
    }

    /* ═══ Empty state ═══ */
    .srch-empty { margin-top: 2rem; }
    .srch-empty-section { margin-bottom: 2.5rem; }
    .srch-empty-heading {
      font-size: 0.75rem;
      font-weight: 800;
      letter-spacing: 0.1em;
      text-transform: uppercase;
      color: #94a3b8;
      margin-bottom: 0.875rem;
    }
    .srch-popular { display: flex; flex-wrap: wrap; gap: 0.5rem; }
    .srch-popular-chip {
      padding: 0.5rem 0.875rem;
      font-size: 0.8125rem;
      font-weight: 700;
      color: #334155;
      background: #f8fafc;
      border: 1px solid #e5e9f0;
      border-radius: 999px;
      cursor: pointer;
      font-family: inherit;
      transition: all .15s ease;
    }
    .srch-popular-chip:hover {
      color: #1d4ed8;
      background: #ffffff;
      border-color: #1d4ed8;
    }
    .srch-browse-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 0.5rem;
    }
    @media (min-width: 640px) { .srch-browse-grid { grid-template-columns: repeat(3, 1fr); } }
    .srch-browse-link {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 0.5rem;
      padding: 0.875rem 1rem;
      font-size: 0.875rem;
      font-weight: 700;
      color: #0b1220;
      background: #ffffff;
      border: 1px solid #e5e9f0;
      border-radius: 10px;
      text-decoration: none;
      transition: all .15s ease;
    }
    .srch-browse-link svg { color: #cbd5e1; }
    .srch-browse-link:hover { border-color: #1d4ed8; color: #1d4ed8; }
    .srch-browse-link:hover svg { color: #1d4ed8; }

    /* ═══ No results ═══ */
    .srch-no-results {
      padding: 3rem 1.5rem;
      text-align: center;
      border: 1px dashed #cbd5e1;
      border-radius: 14px;
      background: #ffffff;
    }
    .srch-no-results-title {
      font-size: 1rem;
      font-weight: 800;
      color: #0b1220;
    }
    .srch-no-results-sub {
      margin-top: 0.5rem;
      font-size: 0.875rem;
      color: #64748b;
    }
  </style>
</BaseLayout>
ASTRO

echo "  ✓ search.astro rebuilt"

echo ""
echo "Rebuilding (4-6 min)..."
rm -rf dist .astro node_modules/.vite
npm run build 2>&1 | tail -8

echo ""
echo "════════════════════════════════════════════"
echo "  DONE"
echo ""
echo "  Preview:"
echo "    bash start-server.sh"
echo ""
echo "  Open: http://localhost:4321/My-edu-site/search/"
echo ""
echo "  What's new:"
echo "    · Sticky search bar (stays visible while scrolling)"
echo "    · Active filter chips with X to remove"
echo "    · Reset filters button appears when filters active"
echo "    · Popular searches (8 example queries)"
echo "    · Browse categories grid (6 links)"
echo "    · Keyboard nav — ↑↓ arrows, Enter to open, Esc to clear"
echo "    · aria-live on status for screen readers"
echo "    · Cleaner, tighter filter rows"
echo ""
echo "  Push when happy:"
echo "    git add ."
echo "    git commit -m 'Search UI v2: sticky bar, active chips, popular searches'"
echo "    git push"
echo "════════════════════════════════════════════"