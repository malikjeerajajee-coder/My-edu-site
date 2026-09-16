#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Wiring PdfViewer (correct pattern)"
echo "════════════════════════════════════════════"
echo ""

python3 - <<'PY'
import pathlib, re

pages = [
    ("src/pages/notes/[...slug].astro",        "note.data.pdfUrl",    "note.data.title"),
    ("src/pages/books/[...slug].astro",        "book.data.pdfUrl",    "book.data.title"),
    ("src/pages/gazettes/[...slug].astro",     "gazette.data.pdfUrl", "gazette.data.title"),
]

for path, pdf_expr, title_expr in pages:
    p = pathlib.Path(path)
    if not p.exists():
        print(f"  skip: {path}")
        continue

    s = p.read_text()

    if "<PdfViewer" in s:
        print(f"  already wired: {path}")
        continue

    # Ensure import
    if "import PdfViewer" not in s:
        lines = s.split('\n')
        last = -1
        for i, ln in enumerate(lines):
            if ln.strip().startswith('import '):
                last = i
        if last >= 0:
            lines.insert(last + 1, "import PdfViewer from '../../components/PdfViewer.astro';")
        s = '\n'.join(lines)

    escaped = re.escape(pdf_expr)
    replacement = "{ " + pdf_expr + " && <PdfViewer url={" + pdf_expr + "} title={" + title_expr + "} /> }"

    # Try patterns in order — most specific first

    # A) {X.pdfUrl && (<a ...href={X.pdfUrl}...>...</a>)}
    pat_a = re.compile(
        r'\{\s*' + escaped + r'\s*&&\s*\(\s*'
        r'<a[^>]*href=\{' + escaped + r'\}[\s\S]*?</a>\s*\)\s*\}',
        re.DOTALL
    )

    # B) {X.pdfUrl && <a ...href={X.pdfUrl}...>...</a>}
    pat_b = re.compile(
        r'\{\s*' + escaped + r'\s*&&\s*'
        r'<a[^>]*href=\{' + escaped + r'\}[\s\S]*?</a>\s*\}',
        re.DOTALL
    )

    # C) bare <a href={X.pdfUrl} ...>...</a>
    pat_c = re.compile(
        r'<a[^>]*href=\{' + escaped + r'\}[\s\S]*?</a>',
        re.DOTALL
    )

    done = False
    for name, pat in [("A", pat_a), ("B", pat_b), ("C", pat_c)]:
        new_s, n = pat.subn(replacement, s)
        if n > 0:
            s = new_s
            print(f"  {path} — wired via pattern {name}")
            done = True
            break

    if not done:
        print(f"  {path} — still no match")

    p.write_text(s)

print("\n  Done")
PY

echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -8

echo ""
echo "════════════════════════════════════════════"
echo "  Push:"
echo "    git add ."
echo "    git commit -m 'Wire PdfViewer into notes, books, gazettes'"
echo "    git push"
echo "════════════════════════════════════════════"