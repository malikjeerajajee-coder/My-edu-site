#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Compacting cards + tightening rows"
echo "════════════════════════════════════════════"
echo ""

python3 - <<'PY'
import pathlib
p = pathlib.Path('src/styles/global.css')
s = p.read_text()

# ── Find and replace the entire .sq-card block with a compact version ──
start = s.find('/* ═══ Square card')
if start == -1:
    start = s.find('.sq-card {')

if start != -1:
    # find where the sq-card section ends (next /* after start, or EOF)
    next_block = s.find('\n/*', start + 10)
    if next_block == -1:
        next_block = len(s)

    new_block = '''/* ═══ Compact resource card — 2-col mobile grid ═══ */
.sq-card {
  display: flex;
  align-items: center;
  gap: 0.875rem;
  padding: 1rem;
  background: var(--surface);
  border: 1px solid #e8ebf1;
  border-radius: 14px;
  min-height: 5rem;
  transition: border-color .15s ease;
}
@media (hover: hover) {
  .sq-card:hover { border-color: var(--brand); }
}

.sq-card-icon {
  display: grid;
  place-items: center;
  width: 2.75rem;
  height: 2.75rem;
  border-radius: 11px;
  background: var(--brand-tint);
  color: var(--brand);
  flex-shrink: 0;
  transition: background-color .15s ease, color .15s ease;
}
@media (hover: hover) {
  .sq-card:hover .sq-card-icon {
    background: var(--brand);
    color: #ffffff;
  }
}

.sq-card-body {
  display: flex;
  flex-direction: column;
  gap: 0.125rem;
  min-width: 0;
}
.sq-card-label {
  font-size: 0.9375rem;
  font-weight: 800;
  letter-spacing: -0.02em;
  color: var(--ink);
  line-height: 1.2;
}
.sq-card-sub {
  font-size: 0.6875rem;
  font-weight: 600;
  color: var(--muted);
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

/* Blue tint variant — All Boards */
.sq-card-tint {
  background: var(--brand-tint);
  border-color: var(--brand-line);
}
.sq-card-tint .sq-card-icon {
  background: #ffffff;
}
.sq-card-tint .sq-card-label { color: var(--brand-deep); }
.sq-card-tint .sq-card-sub   { color: var(--brand); }
'''

    s = s[:start] + new_block + s[next_block:]
    print('  ✓ .sq-card — compact horizontal layout')

# ── Tighten the .row padding ──
s = s.replace(
    '''.row {
  display: flex;
  align-items: center;
  gap: 0.875rem;
  padding: 1rem 1.25rem 1rem 1rem;
  background: var(--surface);
  border: 1px solid #e8ebf1;
  border-radius: 14px;
  transition: border-color .15s ease, background-color .15s ease;
  min-width: 0;
}''',
    '''.row {
  display: flex;
  align-items: center;
  gap: 0.875rem;
  padding: 0.875rem 1rem;
  background: var(--surface);
  border: 1px solid #e8ebf1;
  border-radius: 14px;
  transition: border-color .15s ease, background-color .15s ease;
  min-width: 0;
}'''
)

p.write_text(s)
print('  ✓ .row — tighter padding')
PY

# ─────────────────────────────────────────────
#  Update homepage markup to match new structure
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re

p = pathlib.Path('src/pages/index.astro')
s = p.read_text()

# Replace the resource cards markup
old = re.compile(
    r'\{resources\.map\(r => \([\s\S]*?<\/a>\s*\)\)\}',
    re.DOTALL
)

new = '''{resources.map(r => (
          <a href={url(r.href)} class:list={["sq-card group", r.tint && "sq-card-tint"]}>
            <span class="sq-card-icon">
              <Icon name={r.icon} size={20} strokeWidth={2.2} />
            </span>
            <div class="sq-card-body">
              <span class="sq-card-label">{r.label}</span>
            </div>
          </a>
        ))}'''

if old.search(s):
    s = old.sub(new, s, count=1)
    p.write_text(s)
    print('  ✓ homepage resource cards — updated')
else:
    print('  · homepage resources pattern not found')
PY

# ─────────────────────────────────────────────
#  Also update /boards page
# ─────────────────────────────────────────────
python3 - <<'PY'
import pathlib, re

p = pathlib.Path('src/pages/boards.astro')
s = p.read_text()

old = re.compile(
    r'\{BOARDS\.map\(b => \([\s\S]*?<\/a>\s*\)\)\}',
    re.DOTALL
)

new = '''{BOARDS.map(b => (
        <a href={url(`/board/${b.slug}`)} class="sq-card group">
          <span class="sq-card-icon">
            <Icon name="graduation-cap" size={20} strokeWidth={2.2} />
          </span>
          <div class="sq-card-body">
            <span class="sq-card-label">{b.name}</span>
          </div>
        </a>
      ))}'''

if old.search(s):
    s = old.sub(new, s, count=1)
    p.write_text(s)
    print('  ✓ /boards cards — updated')
else:
    print('  · /boards pattern not found')
PY

# ─────────────────────────────────────────────
#  Rebuild
# ─────────────────────────────────────────────
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -6

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Push:"
echo ""
echo "    git add ."
echo "    git commit -m 'Compact resource cards + tighter rows'"
echo "    git push"
echo ""
echo "  What changed:"
echo ""
echo "  Square cards → compact horizontal tile:"
echo "    Before: aspect-ratio 1/1 (180×180 on mobile)"
echo "            icon top-left, label bottom-left, empty middle"
echo "    After:  ~80px tall, icon + label side by side"
echo ""
echo "  Board rows →"
echo "    Before: 1rem vertical padding"
echo "    After:  0.875rem — tighter, still comfortable"
echo ""
echo "  Result: each resource tile takes ~50% less vertical space"
echo "  The whole grid fits in one screen on mobile"
echo "════════════════════════════════════════════"