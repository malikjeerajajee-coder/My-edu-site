#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Force-removing every PdfViewer reference"
echo "════════════════════════════════════════════"
echo ""

# Show current state first
echo "Current PdfViewer references:"
grep -rn "PdfViewer" src/ 2>/dev/null | head -30 || echo "  (none)"
echo ""

python3 - <<'PY'
import pathlib, re

# Anywhere in src/*.astro, remove:
#   1. import PdfViewer
#   2. { X.pdfUrl && <PdfViewer ... /> }
#   3. <PdfViewer ... /> (bare)
#   4. leftover { X.pdfUrl && }  or  } fragments
# And ensure a plain <a> Open PDF button exists where the viewer was.

# Pattern for the entire { ... && <PdfViewer ... /> } block
cond_viewer = re.compile(
    r'\{\s*([a-zA-Z_.]+(?:\.data)?\.pdfUrl)\s*&&\s*<PdfViewer\b[^>]*?/>\s*\}',
    re.DOTALL
)
# Pattern for bare <PdfViewer ... />
bare_viewer = re.compile(
    r'<PdfViewer\b[^>]*?/>',
    re.DOTALL
)

count_files = 0
count_repl = 0

for astro in pathlib.Path('src').rglob('*.astro'):
    s = astro.read_text()
    orig = s

    # 1. Replace conditional-viewer blocks with a plain anchor
    def make_anchor(m):
        global count_repl
        count_repl += 1
        expr = m.group(1)
        return (
            '<a href={' + expr + '} target="_blank" rel="noopener" '
            'class="mt-5 flex w-full items-center justify-center gap-2 rounded-xl bg-[#0620ed] px-5 py-3.5 text-sm font-bold !text-white transition-colors hover:bg-[#110176]">'
            '<Icon name="download" size={18} strokeWidth={2.4} /> Open PDF'
            '</a>'
        )

    s = cond_viewer.sub(make_anchor, s)

    # 2. Bare viewer → also becomes an anchor (uses fallback title)
    def bare_anchor(m):
        global count_repl
        count_repl += 1
        return (
            '<a href="#" target="_blank" rel="noopener" '
            'class="mt-5 flex w-full items-center justify-center gap-2 rounded-xl bg-[#0620ed] px-5 py-3.5 text-sm font-bold !text-white transition-colors hover:bg-[#110176]">'
            '<Icon name="download" size={18} strokeWidth={2.4} /> Open PDF'
            '</a>'
        )

    s = bare_viewer.sub(bare_anchor, s)

    # 3. Remove the import line
    s = re.sub(r"^import PdfViewer[^\n]*\n", "", s, flags=re.MULTILINE)

    # 4. Clean up empty { } or double-brace artifacts left behind
    s = re.sub(r'\{\s*\}\s*\n', '', s)
    s = s.replace('\n\n\n\n', '\n\n')

    if s != orig:
        astro.write_text(s)
        count_files += 1
        print(f'  cleaned: {astro.relative_to("src")}')

print(f'\n  {count_files} files modified, {count_repl} viewer blocks replaced')
PY

# Delete component and helper
rm -f src/components/PdfViewer.astro src/lib/pdfUrl.ts

# ═══════════════════════════════════════════════
#  Verify nothing remains
# ═══════════════════════════════════════════════
echo ""
echo "Verifying cleanup..."
REMAINING=$(grep -rn "PdfViewer" src/ 2>/dev/null || true)
if [ -z "$REMAINING" ]; then
    echo "  ✓ No PdfViewer references remain"
else
    echo "  ✗ Still found:"
    echo "$REMAINING" | sed 's/^/    /'
fi

# ═══════════════════════════════════════════════
#  Rebuild
# ═══════════════════════════════════════════════
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -8

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Push:"
echo ""
echo "    git add ."
echo "    git commit -m 'Force-remove PDF viewer'"
echo "    git push"
echo ""
echo "  Then CLEAR CACHE in browser:"
echo "    Chrome: ⋮ → History → Clear browsing data →"
echo "            Cached images and files → Clear"
echo ""
echo "  Or open in Incognito once to verify."
echo "════════════════════════════════════════════"