#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Fixing search input + rebuilding search page"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  1. Fix the double focus ring
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib
p = pathlib.Path('src/styles/global.css')
s = p.read_text()

old = '''input:focus-visible, button:focus-visible, a:focus-visible, [tabindex]:focus-visible {
  outline: 2px solid var(--brand);
  outline-offset: 2px;
}'''

new = '''button:focus-visible, a:focus-visible, [tabindex]:focus-visible {
  outline: 2px solid var(--brand);
  outline-offset: 2px;
}

/* Inputs: no outline — the wrapping form handles focus via :focus-within */
input {
  outline: none;
}
input:focus, input:focus-visible {
  outline: none;
  box-shadow: none;
}

/* Standalone input that has no wrapping form (e.g. minimal pages) */
.input-standalone:focus-visible {
  outline: 2px solid var(--brand);
  outline-offset: 2px;
}'''

if old in s:
    s = s.replace(old, new)
    print('  ✓ focus ring — input no longer doubles up')

p.write_text(s)
PY

# ─────────────────────────────────────────────
#  2. Fix the homepage search form
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re
p = pathlib.Path('src/pages/index.astro')
s = p.read_text()

old_form = re.compile(
    r'<form action=\{url\(.\/search.\)\} method="get" role="search"[^>]*?>[\s\S]*?</form>',
    re.DOTALL
)

new_form = '''<form action={url('/search')} method="get" role="search" class="mx-auto mt-9 flex max-w-xl items-stretch overflow-hidden rounded-xl border border-slate-300 bg-white transition-colors focus-within:border-[#1d4ed8]">
          <span class="grid w-12 shrink-0 place-items-center text-slate-400">
            <Icon name="search" size={18} strokeWidth={2.4} />
          </span>
          <input type="search" name="q" placeholder="Search notes, past papers, books..." class="min-w-0 flex-1 bg-transparent py-3.5 pr-3 text-sm text-slate-900 outline-none placeholder:text-slate-400" />
          <button type="submit" class="m-1.5 rounded-lg bg-[#1d4ed8] px-5 text-sm font-bold text-white transition-colors hover:bg-[#1e3a8a]">Search</button>
        </form>'''

if old_form.search(s):
    s = old_form.sub(new_form, s, count=1)
    p.write_text(s)
    print('  ✓ homepage search form — cleaner, no inner ring')
else:
    print('  · homepage search form pattern not found')
PY

# ─────────────────────────────────────────────
#  3. Rebuild the search page — clean, SME-style
# ─────────────────────────────────────────────
cat > src/pages/search.astro <<'ASTRO'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { url } from '../lib/url';
---
<BaseLayout title="Search — TaleemHub" description="Search notes, past papers, guess papers, quizzes, books and result gazettes across all Pakistani boards.">
  <!-- Header band -->
  <div class="border-b border-slate-200 bg-slate-50">
    <div class="mx-auto max-w-[900px] px-5 pt-12 pb-10 sm:px-7 lg:pt-16 lg:pb-12">
      <nav class="mb-5 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
        <a href={url('/')} class="hover:text-[#1d4ed8]">Home</a>
        <span>/</span>
        <span class="text-slate-500">Search</span>
      </nav>
      <h1 class="text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">Search the library</h1>
      <p class="mt-3 text-base text-slate-600">Notes, past papers, guess papers, quizzes, books and gazettes — all in one place.</p>

      <!-- Search bar -->
      <div class="mt-7 flex items-stretch overflow-hidden rounded-xl border border-slate-300 bg-white transition-colors focus-within:border-[#1d4ed8]">
        <span class="grid w-12 shrink-0 place-items-center text-slate-400">
          <Icon name="search" size={20} strokeWidth={2.4} />
        </span>
        <input
          id="q"
          type="search"
          placeholder="Search by subject, class, board or keyword…"
          aria-label="Search library"
          autocomplete="off"
          autocapitalize="off"
          spellcheck="false"
          class="min-w-0 flex-1 bg-transparent py-4 pr-3 text-base text-slate-900 outline-none placeholder:text-slate-400"
        />
        <button
          id="clear"
          type="button"
          aria-label="Clear search"
          class="my-2 mr-2 hidden w-9 shrink-0 place-items-center rounded-lg text-slate-400 transition-colors hover:bg-slate-100 hover:text-slate-700"
        >
          <Icon name="x" size={17} strokeWidth={2.4} />
        </button>
      </div>
    </div>
  </div>

  <!-- Filter chips + results -->
  <div class="mx-auto max-w-[900px] px-5 py-8 sm:px-7 lg:py-10">
    <!-- Chips -->
    <div id="chips" class="flex flex-wrap gap-2"></div>

    <!-- Status -->
    <div id="status" class="mt-6 text-sm font-semibold text-slate-500">
      Loading library…
    </div>

    <!-- Results -->
    <div id="results" class="mt-5 space-y-2.5 pb-16"></div>
  </div>

  <script is:inline>
    (function () {
      var INDEX = [];
      var READY = false;
      var ACTIVE = 'all';

      var input     = document.getElementById('q');
      var clearBtn  = document.getElementById('clear');
      var chipsEl   = document.getElementById('chips');
      var statusEl  = document.getElementById('status');
      var resultsEl = document.getElementById('results');

      var BASE = '/My-edu-site';
      var sitemap = document.querySelector('link[rel="sitemap"]');
      if (sitemap) {
        var href = sitemap.getAttribute('href') || '';
        var idx = href.indexOf('/sitemap-index.xml');
        if (idx > 0) BASE = href.slice(0, idx);
      }

      var ORDER = ['all','note','quiz','book','past-paper','guess-paper','pairing-scheme','gazette'];
      var LABELS = {
        all: 'All',
        note: 'Notes',
        quiz: 'Quizzes',
        book: 'Books',
        'past-paper': 'Past Papers',
        'guess-paper': 'Guess Papers',
        'pairing-scheme': 'Pairing Schemes',
        gazette: 'Result Gazettes'
      };
      var TAG_LABELS = {
        note: 'Note',
        quiz: 'Quiz',
        book: 'Book',
        'past-paper': 'Past Paper',
        'guess-paper': 'Guess Paper',
        'pairing-scheme': 'Scheme',
        gazette: 'Gazette'
      };
      var TAG_STYLE = {
        note: 'background:#eff4ff;color:#1e3a8a;border-color:#c7d7fe',
        quiz: 'background:#f0f9ff;color:#0369a1;border-color:#bae6fd',
        book: 'background:#fffbeb;color:#b45309;border-color:#fde68a',
        'past-paper': 'background:#f5f3ff;color:#6d28d9;border-color:#ddd6fe',
        'guess-paper': 'background:#fdf4ff;color:#a21caf;border-color:#f5d0fe',
        'pairing-scheme': 'background:#ecfdf5;color:#047857;border-color:#a7f3d0',
        gazette: 'background:#fff1f2;color:#be123c;border-color:#fecdd3'
      };

      function esc(s) {
        return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
          return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
        });
      }

      function hl(text, terms) {
        if (!terms.length || !text) return esc(text);
        var safe = esc(text);
        terms.forEach(function (t) {
          if (!t) return;
          var re = new RegExp('(' + t.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + ')', 'gi');
          safe = safe.replace(re, '<mark style="background:#eff4ff;color:#1e3a8a;padding:0 .15em;border-radius:3px">$1</mark>');
        });
        return safe;
      }

      function counts() {
        var c = { all: INDEX.length };
        INDEX.forEach(function (x) { c[x.type] = (c[x.type] || 0) + 1; });
        return c;
      }

      function renderChips() {
        var c = counts();
        chipsEl.innerHTML = ORDER.map(function (t) {
          var n = c[t] || 0;
          if (t !== 'all' && n === 0) return '';
          var active = (t === ACTIVE);
          var style = active
            ? 'background:#1d4ed8;border-color:#1d4ed8;color:#fff'
            : 'background:#fff;border-color:#e5e9f0;color:#334155';
          return '<button type="button" data-type="' + t + '" ' +
            'class="inline-flex items-center gap-1.5 rounded-full border px-3 py-1.5 text-[13px] font-bold transition-colors" ' +
            'style="' + style + '">' +
            esc(LABELS[t]) +
            (n ? ' <span style="' + (active ? 'background:rgba(255,255,255,.22);color:#fff' : 'background:#f1f5f9;color:#64748b') + ';border-radius:999px;padding:0 .45rem;font-size:11px;font-weight:800;min-width:20px;text-align:center;display:inline-block">' + n + '</span>' : '') +
          '</button>';
        }).join('');
        Array.prototype.forEach.call(chipsEl.querySelectorAll('button'), function (b) {
          b.addEventListener('click', function () {
            ACTIVE = b.getAttribute('data-type');
            render();
          });
        });
      }

      function filter(query) {
        var q = query.trim().toLowerCase();
        var terms = q ? q.split(/\s+/).filter(Boolean) : [];
        var pool = ACTIVE === 'all' ? INDEX : INDEX.filter(function (x) { return x.type === ACTIVE; });
        if (!terms.length) return pool.slice(0, 80);

        var scored = [];
        pool.forEach(function (it) {
          var T = (it.title   || '').toLowerCase();
          var S = (it.subject || '').toLowerCase();
          var C = String(it.class || '').toLowerCase();
          var K = (it.type    || '').toLowerCase();
          var total = 0;
          var all = true;
          terms.forEach(function (t) {
            var m = 0;
            if (T.indexOf(t) === 0) m += 22;
            else if (T.indexOf(t) !== -1) m += 12;
            if (S.indexOf(t) === 0) m += 10;
            else if (S.indexOf(t) !== -1) m += 6;
            if (C === t) m += 10;
            else if (C.indexOf(t) !== -1) m += 4;
            if (K.indexOf(t) !== -1) m += 3;
            if (!m) all = false;
            total += m;
          });
          if (all) scored.push([total, it]);
        });
        scored.sort(function (a, b) { return b[0] - a[0]; });
        return scored.map(function (x) { return x[1]; }).slice(0, 80);
      }

      var lastSel = -1;
      var lastList = [];

      function render() {
        var q = input.value;
        if (q) { clearBtn.classList.remove('hidden'); clearBtn.classList.add('grid'); }
        else { clearBtn.classList.add('hidden'); clearBtn.classList.remove('grid'); }

        renderChips();

        if (!READY) {
          statusEl.textContent = 'Loading library…';
          resultsEl.innerHTML = '';
          return;
        }

        var list = filter(q);
        lastList = list;
        lastSel = -1;

        var label;
        if (ACTIVE === 'all') {
          label = q ? (list.length + ' result' + (list.length === 1 ? '' : 's') + ' for "' + q + '"') : (INDEX.length + ' items in library');
        } else {
          label = list.length + ' ' + LABELS[ACTIVE].toLowerCase() + (q ? ' matching "' + q + '"' : '');
        }
        statusEl.textContent = label;

        if (!list.length) {
          resultsEl.innerHTML =
            '<div class="rounded-xl border border-dashed border-slate-300 bg-white p-12 text-center">' +
              '<div class="text-base font-extrabold text-slate-900">No results found</div>' +
              '<div class="mt-2 text-sm text-slate-500">Try a shorter keyword or browse by board and class.</div>' +
              '<div class="mt-5 flex flex-wrap justify-center gap-2">' +
                '<a href="' + BASE + '/boards" class="inline-flex items-center gap-1.5 rounded-lg border border-slate-300 bg-white px-4 py-2 text-xs font-bold text-slate-700 hover:border-[#1d4ed8] hover:text-[#1d4ed8]">Browse boards</a>' +
                '<a href="' + BASE + '/notes" class="inline-flex items-center gap-1.5 rounded-lg border border-slate-300 bg-white px-4 py-2 text-xs font-bold text-slate-700 hover:border-[#1d4ed8] hover:text-[#1d4ed8]">All notes</a>' +
                '<a href="' + BASE + '/past-papers" class="inline-flex items-center gap-1.5 rounded-lg border border-slate-300 bg-white px-4 py-2 text-xs font-bold text-slate-700 hover:border-[#1d4ed8] hover:text-[#1d4ed8]">Past papers</a>' +
              '</div>' +
            '</div>';
          return;
        }

        var terms = q.trim().toLowerCase().split(/\s+/).filter(Boolean);
        resultsEl.innerHTML = list.map(function (it, i) {
          var tag = TAG_LABELS[it.type] || it.type;
          var tagStyle = TAG_STYLE[it.type] || 'background:#f1f5f9;color:#475569;border-color:#e2e8f0';
          var badges = '';
          if (it.subject) badges += '<span class="inline-flex items-center rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate-600">' + esc(it.subject) + '</span>';
          if (it.class)   badges += '<span class="ml-1.5 inline-flex items-center rounded bg-[#eff4ff] px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-[#1d4ed8]">Class ' + esc(it.class) + '</span>';
          return '<a href="' + esc(it.url) + '" class="group flex items-center gap-4 rounded-xl border border-slate-200 bg-white py-3.5 pl-3.5 pr-5 transition-colors hover:border-[#1d4ed8]">' +
            '<span class="grid h-10 w-10 shrink-0 place-items-center rounded-lg border text-[10px] font-extrabold uppercase tracking-wide" style="' + tagStyle + '">' + esc(tag) + '</span>' +
            '<div class="min-w-0 flex-1">' +
              '<div class="truncate text-[14.5px] font-extrabold tracking-tight text-slate-900">' + hl(it.title, terms) + '</div>' +
              (badges ? '<div class="mt-1.5 flex flex-wrap">' + badges + '</div>' : '') +
            '</div>' +
            '<svg class="shrink-0 text-slate-300 transition-transform group-hover:translate-x-0.5 group-hover:text-[#1d4ed8]" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>' +
          '</a>';
        }).join('');
      }

      function moveSel(dir) {
        if (!lastList.length) return;
        lastSel = Math.max(0, Math.min(lastList.length - 1, lastSel + dir));
        var nodes = resultsEl.querySelectorAll('a');
        Array.prototype.forEach.call(nodes, function (n, i) {
          n.classList.toggle('border-[#1d4ed8]', i === lastSel);
          n.classList.toggle('bg-[#eff4ff]', i === lastSel);
        });
        var s = nodes[lastSel];
        if (s) s.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
      }

      input.addEventListener('keydown', function (e) {
        if (e.key === 'ArrowDown') { e.preventDefault(); moveSel(1); }
        else if (e.key === 'ArrowUp') { e.preventDefault(); moveSel(-1); }
        else if (e.key === 'Enter' && lastSel >= 0 && lastList[lastSel]) {
          location.href = lastList[lastSel].url;
        } else if (e.key === 'Escape' && input.value) {
          input.value = ''; render();
        }
      });

      document.addEventListener('keydown', function (e) {
        if (e.key === '/' && document.activeElement !== input && !/INPUT|TEXTAREA/.test(document.activeElement.tagName)) {
          e.preventDefault(); input.focus(); input.select();
        }
      });

      clearBtn.addEventListener('click', function () {
        input.value = ''; input.focus(); render();
      });

      var t;
      input.addEventListener('input', function () {
        clearTimeout(t); t = setTimeout(render, 60);
      });

      var params = new URLSearchParams(location.search);
      var initial = params.get('q') || '';
      if (initial) input.value = initial;

      fetch(BASE + '/search.json')
        .then(function (r) { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
        .then(function (data) {
          INDEX = (data || []).map(function (x) {
            var t = (x.type || 'note').toLowerCase();
            if (t === 'pastpapers') t = 'past-paper';
            if (t === 'guesspapers') t = 'guess-paper';
            if (t === 'pairingschemes') t = 'pairing-scheme';
            return Object.assign({}, x, { type: t });
          });
          READY = true;
          render();
        })
        .catch(function (err) {
          console.error('Search index failed:', err);
          statusEl.textContent = 'Could not load library.';
          resultsEl.innerHTML = '<div class="rounded-xl border border-dashed border-slate-300 bg-white p-12 text-center"><div class="text-base font-extrabold text-slate-900">Search unavailable</div><div class="mt-2 text-sm text-slate-500">Please refresh the page.</div></div>';
        });
    })();
  </script>
</BaseLayout>
ASTRO

echo "  ✓ search page rebuilt"

# ─────────────────────────────────────────────
#  4. Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -6

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Push:"
echo ""
echo "    git add ."
echo "    git commit -m 'Clean search input + rebuilt search page'"
echo "    git push"
echo ""
echo "  Then CLEAR CACHE and open in Incognito."
echo ""
echo "  Fixes:"
echo "    · Search input no longer has double blue ring"
echo "    · Only the wrapping form shows the blue border on focus"
echo "    · Homepage search form redesigned (unified input+button)"
echo "    · Search page rebuilt with:"
echo "        - Header band (breadcrumbs + title + clean search bar)"
echo "        - Filter chips with live counts"
echo "        - Colored type tags per result"
echo "        - Query terms highlighted in titles"
echo "        - Keyboard nav (↓ ↑ Enter Esc, / shortcut)"
echo "        - Better empty state"
echo "════════════════════════════════════════════"