#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Removing PDF viewer, restoring buttons"
echo "════════════════════════════════════════════"
echo ""

python3 - <<'PY'
import pathlib, re

pages = [
    ("src/pages/notes/[...slug].astro",        "note.data.pdfUrl",    "note.data.title"),
    ("src/pages/books/[...slug].astro",        "book.data.pdfUrl",    "book.data.title"),
    ("src/pages/gazettes/[...slug].astro",     "gazette.data.pdfUrl", "gazette.data.title"),
    ("src/pages/past-papers/[...slug].astro",  "d.pdfUrl",            "d.title"),
    ("src/pages/guess-papers/[...slug].astro", "d.pdfUrl",            "d.title"),
    ("src/pages/pairing-schemes/[...slug].astro", "d.pdfUrl",         "d.title"),
]

for path, pdf_expr, _ in pages:
    p = pathlib.Path(path)
    if not p.exists():
        print(f"  skip: {path}")
        continue

    s = p.read_text()
    orig = s

    # 1. Replace any { X.pdfUrl && <PdfViewer ... /> } with a plain anchor
    pattern = re.compile(
        r'\{\s*' + re.escape(pdf_expr) + r'\s*&&\s*<PdfViewer[^/]*/>\s*\}',
        re.DOTALL
    )
    replacement = (
        '<a href={' + pdf_expr + '} target="_blank" rel="noopener" '
        'class="mt-5 flex w-full items-center justify-center gap-2 rounded-xl bg-[#0620ed] px-5 py-3.5 text-sm font-bold !text-white transition-colors hover:bg-[#110176]">'
        '<Icon name="download" size={18} strokeWidth={2.4} /> Open PDF'
        '</a>'
    )
    s = pattern.sub(replacement, s)

    # 2. Remove the PdfViewer import
    s = re.sub(r"^import PdfViewer[^\n]*\n", "", s, flags=re.MULTILINE)

    if s != orig:
        p.write_text(s)
        print(f"  {path} — reverted")

print()
PY

# Delete the viewer component and its helper
rm -f src/components/PdfViewer.astro
rm -f src/lib/pdfUrl.ts
echo "  Deleted PdfViewer.astro and pdfUrl.ts"

# ═══════════════════════════════════════════════
#  Rebuild
# ═══════════════════════════════════════════════
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -8

echo ""
echo "════════════════════════════════════════════"
echo "  Done."
echo ""
echo "  Push:"
echo "    git add ."
echo "    git commit -m 'Remove PDF viewer, use open-in-new-tab'"
echo "    git push"
echo ""
echo "  Detail pages now show a single blue button:"
echo "    Open PDF  →  opens in new tab (Drive, R2, direct)"
echo ""
echo "  Google Drive links will open in the Drive viewer."
echo "  Direct URLs will open in the browser's built-in PDF viewer."
echo "════════════════════════════════════════════"