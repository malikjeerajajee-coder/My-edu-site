#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Removing duplicate filter bars"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  /notes — remove old top-of-page filter
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re

# ── NOTES ──
p = pathlib.Path('src/pages/notes/index.astro')
if p.exists():
    s = p.read_text()
    # Remove the old class-chips block
    old_block = re.compile(
        r'\s*<div class="mb-6">\s*<div class="text-\[10px\][^>]*>Class</div>\s*<div class="chip-row" id="class-chips">[\s\S]*?</div>\s*</div>\s*',
        re.DOTALL
    )
    s = old_block.sub('\n', s)

    # Remove old script that toggles sections by class-chips
    old_script = re.compile(
        r'<script is:inline>\s*\(function \(\) \{\s*var chips = document\.querySelectorAll\(\'#class-chips \.chip\'\);[\s\S]*?</script>\s*',
        re.DOTALL
    )
    s = old_script.sub('', s)

    # Add data attributes to sections for filter
    if 'data-filter-section' not in s:
        s = s.replace(
            '<section data-class={cls}>',
            '<section data-class={cls} data-filter-section>'
        )
    p.write_text(s)
    print('  ✓ /notes — old filter removed')
PY

# ── QUIZZES ──
python3 - <<'PY'
import pathlib, re
p = pathlib.Path('src/pages/quizzes/index.astro')
if p.exists():
    s = p.read_text()
    old_block = re.compile(
        r'\s*<div class="mb-6">\s*<div class="text-\[10px\][^>]*>Class</div>\s*<div class="chip-row" id="class-chips">[\s\S]*?</div>\s*</div>\s*',
        re.DOTALL
    )
    s = old_block.sub('\n', s)
    old_script = re.compile(
        r'<script is:inline>\s*\(function \(\) \{\s*var chips = document\.querySelectorAll\(\'#class-chips \.chip\'\);[\s\S]*?</script>\s*',
        re.DOTALL
    )
    s = old_script.sub('', s)
    if 'data-filter-section' not in s:
        s = s.replace(
            '<section data-class={cls}>',
            '<section data-class={cls} data-filter-section>'
        )
    p.write_text(s)
    print('  ✓ /quizzes — old filter removed')
PY

# ── BOOKS ──
python3 - <<'PY'
import pathlib, re
p = pathlib.Path('src/pages/books/index.astro')
if p.exists():
    s = p.read_text()
    # Remove both board and class chip rows
    old_block = re.compile(
        r'\s*<div class="mb-3">\s*<div class="text-\[10px\][^>]*>Board</div>[\s\S]*?</div>\s*<div class="mb-6">\s*<div class="text-\[10px\][^>]*>Class</div>[\s\S]*?</div>\s*',
        re.DOTALL
    )
    s = old_block.sub('\n', s)
    # Remove the whole old filter script
    old_script = re.compile(
        r'<script is:inline>\s*\(function \(\) \{\s*var activeBoard = [\s\S]*?</script>\s*',
        re.DOTALL
    )
    s = old_script.sub('', s)
    if 'data-filter-section' not in s:
        s = s.replace(
            '<section data-class={cls}>',
            '<section data-class={cls} data-filter-section>'
        )
    p.write_text(s)
    print('  ✓ /books — old filter removed')
PY

# ─────────────────────────────────────────────
#  Also update the PageFilter script to be more robust
#  (stop relying on "last element in DOM" hack)
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib
p = pathlib.Path('src/components/PageFilter.astro')
s = p.read_text()

# Replace the whole script with a self-contained version
new_script = '''<script is:inline>
  (function () {
    // Find all .pf-wrap blocks that haven't been initialized yet
    document.querySelectorAll('.pf-wrap:not([data-pf-ready])').forEach(function (wrap) {
      wrap.setAttribute('data-pf-ready', '1');
      init(wrap);
    });

    function init(wrap) {
      var input   = wrap.querySelector('[data-pf-input]');
      var clear   = wrap.querySelector('[data-pf-clear]');
      var countEl = wrap.querySelector('[data-pf-count]');
      var empty   = wrap.parentElement.querySelector('.pf-empty') ||
                    wrap.nextElementSibling;

      if (empty) empty.style.display = 'none';

      var active = {};
      var params = new URLSearchParams(location.search);
      if (params.get('q')) input.value = params.get('q');

      wrap.querySelectorAll('[data-pf-chips]').forEach(function (group) {
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

      apply();
    }
  })();
</script>
'''

import re
s = re.sub(r'<script is:inline>[\s\S]*?</script>', new_script, s, count=1)
p.write_text(s)
print('  ✓ PageFilter script rewritten (safer init)')
PY

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
echo "    · Removed old class-chips filter from /notes, /quizzes, /books"
echo "    · Only PageFilter remains — single, unified filter bar"
echo "    · Empty state hidden on page load"
echo "    · Filter bar contains: search + chip filters + result count"
echo "════════════════════════════════════════════"