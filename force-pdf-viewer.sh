#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Forcing PdfViewer into all detail pages"
echo "════════════════════════════════════════════"
echo ""

python3 - <<'PY'
import pathlib, re

# Every detail page + its variable for the item
pages = {
    "src/pages/notes/[...slug].astro":           ("note",    "note.data.title"),
    "src/pages/books/[...slug].astro":           ("book",    "book.data.title"),
    "src/pages/gazettes/[...slug].astro":        ("gazette", "gazette.data.title"),
    "src/pages/past-papers/[...slug].astro":     ("paper",   "d.title"),
    "src/pages/guess-papers/[...slug].astro":    ("paper",   "d.title"),
    "src/pages/pairing-schemes/[...slug].astro": ("scheme",  "d.title"),
}

for path, (var, title_expr) in pages.items():
    p = pathlib.Path(path)
    if not p.exists():
        print(f"  skip (missing): {path}")
        continue

    s = p.read_text()
    orig = s

    # Skip if already using PdfViewer
    if "PdfViewer" in s and "<PdfViewer" in s:
        print(f"  already has PdfViewer: {path}")
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

    # CRITICAL: figure out the pdfUrl expression for this page
    # var is like "note", and pdfUrl is var.data.pdfUrl (except for past-papers/guess-papers/pairing where it's d.pdfUrl)
    if var in ("paper", "scheme"):
        pdf_expr = "d.pdfUrl"
    else:
        pdf_expr = f"{var}.data.pdfUrl"

    # Strategy: find the whole pdfUrl conditional block or anchor
    # Patterns to try, in order of specificity

    # Pattern A: {X.pdfUrl && (<a ...>...</a>)}
    pat_a = re.compile(
        r'\{\s*' + re.escape(pdf_expr) + r'\s*&&\s*\(\s*'
        r'<a[\s\S]*?href=\{url\(' + re.escape(pdf_expr) + r'\)\}[\s\S]*?</a>\s*\)\s*\}',
        re.DOTALL
    )

    # Pattern B: {X.pdfUrl && <a ...>...</a>}
    pat_b = re.compile(
        r'\{\s*' + re.escape(pdf_expr) + r'\s*&&\s*'
        r'<a[\s\S]*?href=\{url\(' + re.escape(pdf_expr) + r'\)\}[\s\S]*?</a>\s*\}',
        re.DOTALL
    )

    # Pattern C: bare <a href={url(X.pdfUrl)}>...</a>
    pat_c = re.compile(
        r'<a[^>]*?href=\{url\(' + re.escape(pdf_expr) + r'\)\}[\s\S]*?</a>',
        re.DOTALL
    )

    replacement = "{ " + pdf_expr + " && <PdfViewer url={url(" + pdf_expr + ")} title={" + title_expr + "} /> }"

    matched = False
    for name, pat in [("A", pat_a), ("B", pat_b), ("C", pat_c)]:
        new_s, n = pat.subn(replacement, s)
        if n > 0:
            s = new_s
            print(f"  {path} — replaced with pattern {name} ({n}x)")
            matched = True
            break

    if not matched:
        print(f"  {path} — NO MATCH (manual wiring needed)")
        # Print a snippet to help debug
        # Find the pdfUrl reference and print surrounding 200 chars
        idx = s.find(pdf_expr)
        if idx > 0:
            print(f"     context: ...{s[max(0,idx-100):idx+300]}...")

    if s != orig:
        p.write_text(s)

print("\n  Done")
PY

# ═══════════════════════════════════════════════
#  Rebuild
# ═══════════════════════════════════════════════
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -12

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Push:"
echo ""
echo "    git add ."
echo "    git commit -m 'Force PdfViewer into detail pages'"
echo "    git push"
echo ""
echo "  Then clear cache & test:"
echo ""
echo "    /notes/english-9-essays/"
echo "    /books/physics-9/"
echo "    /gazettes/bise-karachi-9-2024/"
echo "    /past-papers/physics-9-punjab-2024/"
echo "════════════════════════════════════════════"