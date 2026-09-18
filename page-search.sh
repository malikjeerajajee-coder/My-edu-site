#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Adding on-page search + filters"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  1. Reusable filter CSS + JS
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib
p = pathlib.Path('src/styles/global.css')
s = p.read_text()

if '.filter-bar' not in s:
    s = s.rstrip() + '''

/* ═══ On-page search + filter bar ═══ */
.filter-bar {
  display: flex;
  flex-direction: column;
  gap: 0.875rem;
  padding: 1.125rem;
  border: 1px solid #e5e9f0;
  border-radius: 14px;
  background: #ffffff;
  margin-bottom: 1.5rem;
}
.filter-search {
  display: flex;
  align-items: stretch;
  gap: 0.5rem;
  border: 1px solid #e5e9f0;
  border-radius: 10px;
  background: #f8fafc;
  padding: 0.25rem 0.25rem 0.25rem 0.875rem;
  transition: border-color .15s ease;
}
.filter-search:focus-within {
  border-color: #1d4ed8;
  background: #ffffff;
}
.filter-search svg { color: #94a3b8; }
.filter-search input {
  flex: 1;
  min-width: 0;
  padding: 0.6rem 0.25rem;
  background: transparent;
  border: 0;
  outline: none;
  font-size: 0.9375rem;
  font-weight: 500;
  color: #0b1220;
}
.filter-search input::placeholder { color: #94a3b8; font-weight: 500; }
.filter-search-clear {
  display: none;
  align-items: center;
  justify-content: center;
  width: 2rem;
  border: 0;
  border-radius: 8px;
  background: transparent;
  color: #64748b;
  cursor: pointer;
}
.filter-search-clear:hover { background: #e5e9f0; }
.filter-search-clear.visible { display: inline-flex; }

.filter-chips-row {
  display: flex;
  gap: 0.5rem;
  overflow-x: auto;
  padding-bottom: 0.25rem;
  scrollbar-width: none;
  -webkit-overflow-scrolling: touch;
}
.filter-chips-row::-webkit-scrollbar { display: none; }

.filter-chip {
  flex-shrink: 0;
  padding: 0.375rem 0.75rem;
  border-radius: 999px;
  border: 1px solid #e5e9f0;
  background: #ffffff;
  color: #334155;
  font-size: 0.75rem;
  font-weight: 700;
  white-space: nowrap;
  cursor: pointer;
  transition: all .15s ease;
}
.filter-chip:hover { border-color: #1d4ed8; color: #1d4ed8; }
.filter-chip.active {
  background: #1d4ed8;
  border-color: #1d4ed8;
  color: #ffffff !important;
}
.filter-label {
  display: block;
  font-size: 0.6875rem;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: #94a3b8;
  margin-bottom: 0.5rem;
}

.filter-results-count {
  font-size: 0.75rem;
  font-weight: 700;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.filter-empty {
  display: none;
  padding: 3rem 1rem;
  text-align: center;
  border: 1px dashed #cbd5e1;
  border-radius: 14px;
  background: #ffffff;
}
.filter-empty.visible { display: block; }
.filter-empty-title {
  font-size: 0.9375rem;
  font-weight: 800;
  color: #0b1220;
}
.filter-empty-sub {
  margin-top: 0.5rem;
  font-size: 0.8125rem;
  color: #64748b;
}
'''
    p.write_text(s)
    print('  ✓ filter CSS added')
else:
    print('  · filter CSS already present')
PY

# ─────────────────────────────────────────────
#  2. Reusable PageFilter component
# ─────────────────────────────────────────────
mkdir -p src/components
cat > src/components/PageFilter.astro <<'ASTRO'
---
interface Props {
  placeholder?: string;
  filters?: {
    label: string;
    key: string;
    options: string[];
  }[];
}
const { placeholder = 'Search on this page…', filters = [] } = Astro.props;
---
<div class="filter-bar" id="page-filter">
  <div class="filter-search">
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" style="margin-top: 10px;"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
    <input type="search" id="filter-q" placeholder={placeholder} autocomplete="off" />
    <button type="button" class="filter-search-clear" id="filter-clear" aria-label="Clear search">
      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
    </button>
  </div>

  {filters.map(f => (
    <div data-filter-group={f.key}>
      <div class="filter-label">{f.label}</div>
      <div class="filter-chips-row">
        <button type="button" class="filter-chip active" data-key={f.key} data-value="all">All</button>
        {f.options.map(o => (
          <button type="button" class="filter-chip" data-key={f.key} data-value={o}>{o}</button>
        ))}
      </div>
    </div>
  ))}

  <div class="filter-results-count" id="filter-count"></div>
</div>

<div class="filter-empty" id="filter-empty">
  <div class="filter-empty-title">No matches</div>
  <div class="filter-empty-sub">Try a different keyword or clear the filters.</div>
</div>

<script is:inline>
  (function () {
    var bar = document.getElementById('page-filter');
    var empty = document.getElementById('filter-empty');
    if (!bar) return;

    var input = document.getElementById('filter-q');
    var clear = document.getElementById('filter-clear');
    var count = document.getElementById('filter-count');

    // Read filters from URL on load
    var params = new URLSearchParams(location.search);
    if (params.get('q')) input.value = params.get('q');

    var activeFilters = {};
    bar.querySelectorAll('.filter-chip').forEach(function (btn) {
      var key = btn.getAttribute('data-key');
      var value = btn.getAttribute('data-value');
      if (params.get(key)) {
        var urlValue = params.get(key);
        if (urlValue === value) {
          btn.parentElement.querySelectorAll('.filter-chip').forEach(function (b) { b.classList.remove('active'); });
          btn.classList.add('active');
          activeFilters[key] = value;
        }
      }
      btn.addEventListener('click', function () {
        btn.parentElement.querySelectorAll('.filter-chip').forEach(function (b) { b.classList.remove('active'); });
        btn.classList.add('active');
        if (value === 'all') delete activeFilters[key];
        else activeFilters[key] = value;
        apply();
      });
    });

    function apply() {
      var q = input.value.trim().toLowerCase();
      var items = document.querySelectorAll('[data-filterable]');
      var visible = 0;

      items.forEach(function (el) {
        var haystack = (el.getAttribute('data-search') || '').toLowerCase();
        var matches = !q || haystack.indexOf(q) !== -1;

        if (matches) {
          for (var k in activeFilters) {
            var target = (el.getAttribute('data-' + k) || '').toLowerCase();
            if (target !== String(activeFilters[k]).toLowerCase()) { matches = false; break; }
          }
        }

        if (matches) { el.style.display = ''; visible++; }
        else { el.style.display = 'none'; }
      });

      // Hide empty section headers
      document.querySelectorAll('[data-filter-section]').forEach(function (sec) {
        var rows = sec.querySelectorAll('[data-filterable]');
        var anyVisible = false;
        rows.forEach(function (r) { if (r.style.display !== 'none') anyVisible = true; });
        sec.style.display = anyVisible ? '' : 'none';
      });

      // Update count
      if (q || Object.keys(activeFilters).length) {
        count.textContent = visible + ' result' + (visible === 1 ? '' : 's');
      } else {
        count.textContent = '';
      }

      // Show/hide clear button
      if (input.value) clear.classList.add('visible');
      else clear.classList.remove('visible');

      // Show/hide empty state
      if (visible === 0) empty.classList.add('visible');
      else empty.classList.remove('visible');
    }

    var t;
    input.addEventListener('input', function () {
      clearTimeout(t);
      t = setTimeout(apply, 50);
    });

    clear.addEventListener('click', function () {
      input.value = '';
      input.focus();
      apply();
    });

    // URL sync (nice for sharing filtered views)
    input.addEventListener('input', function () {
      var u = new URL(location.href);
      if (input.value) u.searchParams.set('q', input.value);
      else u.searchParams.delete('q');
      history.replaceState(null, '', u);
    });

    apply();
  })();
</script>
ASTRO
echo "  ✓ PageFilter.astro"

echo ""
echo "  Done."
echo ""
echo "  Now apply to list pages:"
echo "    1. /board/[board]/[bise]/[class]/[type].astro  (past-papers / gazettes)"
echo "    2. /board/[board]/[class]/[subject].astro      (subject lists)"
echo "    3. /notes, /quizzes, /books index pages"
echo ""
echo "  Test with: npm run dev"