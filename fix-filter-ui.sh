#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Fixing filter UI + empty state bug"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  1. Rebuild PageFilter component — clean
# ─────────────────────────────────────────────
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
const uid = Math.random().toString(36).slice(2, 8);
---
<div class="pf-wrap" id={`pf-${uid}`}>
  <!-- Search -->
  <div class="pf-search">
    <span class="pf-search-icon" aria-hidden="true">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
    </span>
    <input
      type="search"
      class="pf-input"
      data-pf-input
      placeholder={placeholder}
      autocomplete="off"
      spellcheck="false"
    />
    <button type="button" class="pf-clear" data-pf-clear aria-label="Clear">
      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
    </button>
  </div>

  <!-- Filters -->
  {filters.map(f => (
    <div class="pf-group">
      <div class="pf-label">{f.label}</div>
      <div class="pf-chips" data-pf-chips data-key={f.key}>
        <button type="button" class="pf-chip is-active" data-pf-chip data-value="all">All</button>
        {f.options.map(o => (
          <button type="button" class="pf-chip" data-pf-chip data-value={o}>{o}</button>
        ))}
      </div>
    </div>
  ))}

  <!-- Results count -->
  <div class="pf-count" data-pf-count></div>
</div>

<div class="pf-empty" data-pf-empty>
  <div class="pf-empty-title">No matches</div>
  <div class="pf-empty-sub">Try a different keyword or clear the filters.</div>
</div>

<script is:inline>
  (function () {
    // Each PageFilter instance on the page needs a unique scope
    var uid = document.currentScript.closest('[data-pf-instance]')?.dataset.pfInstance;
    if (!uid) {
      var all = document.querySelectorAll('[data-pf-instance]');
      if (all.length) uid = all[all.length - 1].dataset.pfInstance;
    }
    // Fallback — script just attached, use the last inserted block
    var scripts = document.querySelectorAll('script');
    // Find last pf-wrap in DOM (which is the one we just rendered)
    var wraps = document.querySelectorAll('.pf-wrap');
    if (!wraps.length) return;
    var wrap = wraps[wraps.length - 1];

    var input = wrap.querySelector('[data-pf-input]');
    var clear = wrap.querySelector('[data-pf-clear]');
    var countEl = wrap.querySelector('[data-pf-count]');
    var chipGroups = wrap.querySelectorAll('[data-pf-chips]');
    var emptyEl = document.querySelectorAll('[data-pf-empty]');
    var empty = emptyEl[emptyEl.length - 1];

    // Hide empty by default (belt + braces)
    if (empty) empty.style.display = 'none';

    var active = {};

    var params = new URLSearchParams(location.search);
    if (params.get('q')) input.value = params.get('q');

    chipGroups.forEach(function (group) {
      var key = group.getAttribute('data-key');
      group.querySelectorAll('[data-pf-chip]').forEach(function (chip) {
        var val = chip.getAttribute('data-value');
        if (params.get(key) && params.get(key) === val && val !== 'all') {
          group.querySelectorAll('[data-pf-chip]').forEach(function (c) { c.classList.remove('is-active'); });
          chip.classList.add('is-active');
          active[key] = val;
        }
        chip.addEventListener('click', function () {
          group.querySelectorAll('[data-pf-chip]').forEach(function (c) { c.classList.remove('is-active'); });
          chip.classList.add('is-active');
          if (val === 'all') delete active[key];
          else active[key] = val;
          apply();
        });
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
          for (var k in active) {
            var target = (el.getAttribute('data-' + k) || '').toLowerCase();
            if (target !== String(active[k]).toLowerCase()) { matches = false; break; }
          }
        }

        if (matches) { el.style.display = ''; visible++; }
        else { el.style.display = 'none'; }
      });

      // Hide section headers with no visible rows
      document.querySelectorAll('[data-filter-section]').forEach(function (sec) {
        var rows = sec.querySelectorAll('[data-filterable]');
        var anyVisible = false;
        rows.forEach(function (r) { if (r.style.display !== 'none') anyVisible = true; });
        sec.style.display = anyVisible ? '' : 'none';
      });

      var hasFilter = q || Object.keys(active).length > 0;
      if (hasFilter) {
        countEl.textContent = visible + ' result' + (visible === 1 ? '' : 's');
      } else {
        countEl.textContent = '';
      }

      if (input.value) clear.classList.add('is-visible');
      else clear.classList.remove('is-visible');

      // Empty state — only show if no results AND at least one filter is active
      if (empty) {
        if (visible === 0 && hasFilter) empty.style.display = 'block';
        else empty.style.display = 'none';
      }
    }

    var t;
    input.addEventListener('input', function () {
      clearTimeout(t);
      t = setTimeout(apply, 50);
      var u = new URL(location.href);
      if (input.value) u.searchParams.set('q', input.value);
      else u.searchParams.delete('q');
      history.replaceState(null, '', u);
    });

    clear.addEventListener('click', function () {
      input.value = '';
      input.focus();
      apply();
    });

    // Run once on load to hide stale empty state
    apply();
  })();
</script>
ASTRO

# ─────────────────────────────────────────────
#  2. Add cleaner filter CSS
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re
p = pathlib.Path('src/styles/global.css')
s = p.read_text()

# Remove old filter CSS block
s = re.sub(r'/\* ═══ On-page search \+ filter bar ═══ \*/[\s\S]*?(?=/\* ═══|\Z)', '', s, count=1)

# Add new, cleaner CSS
s = s.rstrip() + '''

/* ═══ Page filter component ═══ */
.pf-wrap {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  padding: 1.125rem;
  border: 1px solid #e5e9f0;
  border-radius: 14px;
  background: #ffffff;
  margin-bottom: 1.5rem;
}

.pf-search {
  position: relative;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  height: 3rem;
  padding: 0 0.5rem 0 0.875rem;
  border: 1px solid #e5e9f0;
  border-radius: 12px;
  background: #f8fafc;
  transition: border-color .15s ease, background-color .15s ease;
}
.pf-search:focus-within {
  border-color: #1d4ed8;
  background: #ffffff;
}
.pf-search-icon {
  display: inline-flex;
  color: #94a3b8;
  flex-shrink: 0;
}
.pf-input {
  flex: 1;
  min-width: 0;
  height: 100%;
  border: 0;
  outline: none;
  background: transparent;
  font-size: 0.9375rem;
  font-weight: 500;
  color: #0b1220;
}
.pf-input::placeholder { color: #94a3b8; font-weight: 500; }
.pf-clear {
  display: none;
  align-items: center;
  justify-content: center;
  width: 2rem;
  height: 2rem;
  border: 0;
  border-radius: 8px;
  background: transparent;
  color: #64748b;
  cursor: pointer;
  flex-shrink: 0;
}
.pf-clear:hover { background: #e5e9f0; }
.pf-clear.is-visible { display: inline-flex; }

.pf-group { display: flex; flex-direction: column; gap: 0.5rem; }
.pf-label {
  font-size: 0.6875rem;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: #94a3b8;
}
.pf-chips {
  display: flex;
  gap: 0.5rem;
  overflow-x: auto;
  margin: 0 -1.125rem;
  padding: 0 1.125rem;
  scrollbar-width: none;
  -webkit-overflow-scrolling: touch;
  scroll-behavior: smooth;
}
.pf-chips::-webkit-scrollbar { display: none; }

/* Fade hint on the right so users know there's more to scroll */
.pf-group { position: relative; }
.pf-group::after {
  content: '';
  position: absolute;
  right: -1px;
  bottom: 0;
  width: 2.5rem;
  height: 2.25rem;
  pointer-events: none;
  background: linear-gradient(to left, #ffffff 30%, transparent);
}
@media (min-width: 640px) {
  .pf-group::after { display: none; }
}

.pf-chip {
  flex-shrink: 0;
  padding: 0.4375rem 0.875rem;
  border-radius: 999px;
  border: 1px solid #e5e9f0;
  background: #ffffff;
  color: #334155;
  font-size: 0.8125rem;
  font-weight: 700;
  white-space: nowrap;
  cursor: pointer;
  transition: background-color .15s ease, border-color .15s ease, color .15s ease;
}
.pf-chip:hover { border-color: #1d4ed8; color: #1d4ed8; }
.pf-chip.is-active {
  background: #1d4ed8;
  border-color: #1d4ed8;
  color: #ffffff !important;
}

.pf-count {
  font-size: 0.75rem;
  font-weight: 700;
  color: #64748b;
  letter-spacing: 0.02em;
  min-height: 1rem;
}

.pf-empty {
  display: none;
  padding: 3rem 1.5rem;
  text-align: center;
  border: 1px dashed #cbd5e1;
  border-radius: 14px;
  background: #ffffff;
  margin-bottom: 1.5rem;
}
.pf-empty-title {
  font-size: 0.9375rem;
  font-weight: 800;
  color: #0b1220;
}
.pf-empty-sub {
  margin-top: 0.5rem;
  font-size: 0.8125rem;
  color: #64748b;
}
'''
p.write_text(s)
print('  ✓ filter CSS rewritten')
PY

# ─────────────────────────────────────────────
#  3. Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -6

echo ""
echo "════════════════════════════════════════════"
echo "  Done."
echo ""
echo "  Restart dev:"
echo "    pkill -f 'astro dev' || true"
echo "    npm run dev"
echo ""
echo "  What changed:"
echo "    · Empty state — hidden by default with inline style,"
echo "      only shows when a filter is active AND no results match"
echo "    · Search input — cleaner flex layout, no hacked margin"
echo "    · Chips — full-width scroll with fade hint on mobile"
echo "    · Chip row now scrolls edge-to-edge for better UX"
echo "    · Result count styled and shows only when filtering"
echo "    · Clear button positioned properly"
echo "════════════════════════════════════════════"