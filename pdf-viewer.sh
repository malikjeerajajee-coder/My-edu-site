#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Adding universal PDF viewer"
echo "════════════════════════════════════════════"
echo ""

mkdir -p src/lib src/components

# ═══════════════════════════════════════════════
#  1. URL normalizer — handles Drive, Dropbox, R2, direct
# ═══════════════════════════════════════════════
cat > src/lib/pdfUrl.ts <<'EOF'
/**
 * Normalizes any PDF URL into a form that works inside an <iframe>.
 * Supports: direct URLs, Google Drive, Dropbox, Cloudflare R2, and generic hosts.
 */

export interface NormalizedPdf {
  preview: string;    // URL for embedding in an iframe
  download: string;   // URL that triggers a file download
  embeddable: boolean; // whether iframe preview is likely to work
}

export function normalizePdfUrl(raw: string): NormalizedPdf {
  if (!raw) return { preview: '', download: '', embeddable: false };

  // Google Drive: /file/d/{ID}/view   or   open?id={ID}
  const driveMatch1 = raw.match(/drive\.google\.com\/file\/d\/([^/?#]+)/);
  const driveMatch2 = raw.match(/drive\.google\.com\/open\?id=([^&]+)/);
  const driveMatch3 = raw.match(/drive\.google\.com\/uc\?.*id=([^&]+)/);
  const driveId = driveMatch1?.[1] || driveMatch2?.[1] || driveMatch3?.[1];
  if (driveId) {
    return {
      preview: `https://drive.google.com/file/d/${driveId}/preview`,
      download: `https://drive.google.com/uc?export=download&id=${driveId}`,
      embeddable: true,
    };
  }

  // Dropbox: convert ?dl=0 to ?raw=1 for direct preview
  if (raw.includes('dropbox.com')) {
    const cleaned = raw.replace(/([?&])dl=0/, '$1raw=1').replace(/([?&])dl=1/, '$1raw=1');
    return {
      preview: cleaned,
      download: raw.replace(/([?&])dl=0/, '$1dl=1'),
      embeddable: true,
    };
  }

  // Any other URL — direct or Cloudflare R2 or S3
  return {
    preview: raw,
    download: raw,
    embeddable: true,
  };
}

export function isExternalUrl(url: string): boolean {
  return /^https?:\/\//i.test(url || '');
}
EOF
echo "  pdfUrl.ts created"

# ═══════════════════════════════════════════════
#  2. Add 'expand' and 'external-link' icons
# ═══════════════════════════════════════════════
python3 - <<'PY'
import pathlib
p = pathlib.Path("src/components/Icon.astro")
s = p.read_text()

new_icons = """  expand: '<path d="M15 3h6v6"/><path d="M9 21H3v-6"/><path d="M21 3l-7 7"/><path d="M3 21l7-7"/>',
  'external-link': '<path d="M15 3h6v6"/><path d="M10 14 21 3"/><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/>',
  'file-pdf': '<path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"/><path d="M14 2v4a2 2 0 0 0 2 2h4"/><path d="M9 13h1a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1H9"/><path d="M15 13h-1v5h1a2 2 0 0 0 2-2v-1a2 2 0 0 0-2-2Z"/>',
"""

marker = "};"
idx = s.rfind(marker)
if idx == -1:
    print("  ERROR: cannot find icons object")
    raise SystemExit(1)

if "'expand':" not in s:
    s = s[:idx] + new_icons + s[idx:]
    p.write_text(s)
    print("  icons added: expand, external-link, file-pdf")
else:
    print("  icons already present")
PY

# ═══════════════════════════════════════════════
#  3. PdfViewer component
# ═══════════════════════════════════════════════
cat > src/components/PdfViewer.astro <<'ASTRO'
---
import Icon from './Icon.astro';
import { normalizePdfUrl } from '../lib/pdfUrl';

interface Props {
  url: string;
  title?: string;
  height?: number;         // desktop height in px
  downloadLabel?: string;
}

const {
  url: rawUrl,
  title = 'Document',
  height = 780,
  downloadLabel = 'Download PDF',
} = Astro.props;

const { preview, download, embeddable } = normalizePdfUrl(rawUrl);
const uid = Math.random().toString(36).slice(2, 9);
---
<div class="overflow-hidden rounded-2xl border border-neutral-200 bg-white">
  <!-- Toolbar -->
  <div class="flex flex-wrap items-center gap-3 border-b border-neutral-200 bg-neutral-50 px-4 py-3">
    <span class="grid h-9 w-9 shrink-0 place-items-center rounded-lg bg-[#eef2fe] text-[#0620ed]">
      <Icon name="file-pdf" size={18} strokeWidth={2.2} />
    </span>
    <div class="min-w-0 flex-1">
      <div class="truncate text-sm font-bold text-neutral-900">{title}</div>
      <div class="text-xs text-neutral-500">PDF preview</div>
    </div>

    <div class="flex items-center gap-2">
      <a
        href={preview}
        target="_blank"
        rel="noopener"
        class="hidden items-center gap-1.5 rounded-lg border border-neutral-200 bg-white px-3 py-2 text-xs font-bold text-neutral-700 transition-colors hover:border-[#0620ed] hover:text-[#0620ed] sm:inline-flex"
        aria-label="Open in new tab"
      >
        <Icon name="external-link" size={13} strokeWidth={2.4} />
        <span>Open</span>
      </a>
      <a
        href={download}
        target="_blank"
        rel="noopener"
        download
        class="inline-flex items-center gap-1.5 rounded-lg bg-[#0620ed] px-3 py-2 text-xs font-bold text-white transition-colors hover:bg-[#110176]"
      >
        <Icon name="download" size={13} strokeWidth={2.4} />
        <span>{downloadLabel}</span>
      </a>
    </div>
  </div>

  <!-- Preview area -->
  <div class="relative w-full bg-neutral-100">
    {embeddable ? (
      <iframe
        id={`pdf-${uid}`}
        src={preview}
        title={title}
        loading="lazy"
        allow="autoplay"
        referrerpolicy="no-referrer"
        class="block w-full border-0"
        style={`height: ${height}px; max-height: 85vh;`}
      ></iframe>
    ) : (
      <div class="flex flex-col items-center justify-center gap-3 p-12 text-center" style={`min-height: ${height}px;`}>
        <span class="grid h-14 w-14 place-items-center rounded-2xl bg-[#eef2fe] text-[#0620ed]">
          <Icon name="file-pdf" size={26} strokeWidth={2.2} />
        </span>
        <div class="text-base font-bold text-neutral-900">Preview not available</div>
        <p class="max-w-sm text-sm text-neutral-500">
          This document can't be previewed inline. Use the download button above to view it.
        </p>
      </div>
    )}
  </div>
</div>

<!-- Mobile: full-screen preview button (in case iframe is cramped) -->
<div class="mt-3 flex justify-center sm:hidden">
  <a
    href={preview}
    target="_blank"
    rel="noopener"
    class="inline-flex items-center gap-1.5 rounded-lg border border-neutral-200 bg-white px-4 py-2.5 text-xs font-bold text-neutral-700 transition-colors hover:border-[#0620ed] hover:text-[#0620ed]"
  >
    <Icon name="expand" size={13} strokeWidth={2.4} />
    Open full screen
  </a>
</div>
ASTRO
echo "  PdfViewer.astro created"

# ═══════════════════════════════════════════════
#  4. Wire into detail pages
# ═══════════════════════════════════════════════
python3 - <<'PY'
import pathlib, re

# Pages that currently show a plain download button
pages = [
    ("src/pages/notes/[...slug].astro", "pdfUrl", "note.data"),
    ("src/pages/books/[...slug].astro", "pdfUrl", "book.data"),
    ("src/pages/gazettes/[...slug].astro", "pdfUrl", "gazette.data"),
    ("src/pages/past-papers/[...slug].astro", "pdfUrl", "d"),
    ("src/pages/guess-papers/[...slug].astro", "pdfUrl", "d"),
    ("src/pages/pairing-schemes/[...slug].astro", "pdfUrl", "d"),
]

# Find the plain download button pattern (an <a> with class containing bg-[#0620ed] or bg-rose-600 etc,
# and href={url(X.pdfUrl)})
button_pattern = re.compile(
    r'\{?[a-zA-Z_.]*(?:data)?\.pdfUrl\s*&&\s*\(?\s*'
    r'<a[^>]*?href=\{url\([a-zA-Z_.]*(?:data)?\.pdfUrl\)\}[^>]*?>[\s\S]*?</a>\s*\)?\s*\}?',
    re.DOTALL,
)

# Simpler: match <a href={url(X.pdfUrl)} ...>...</a> directly
simple_pattern = re.compile(
    r'<a\s+href=\{url\(([a-zA-Z_.]*(?:data)?\.pdfUrl)\)\}[^>]*?>\s*'
    r'(?:<Icon[^>]*/>)?\s*[^<]*</a>',
    re.DOTALL,
)

count = 0
for path, _, varpath in pages:
    p = pathlib.Path(path)
    if not p.exists():
        print(f'  skip (missing): {path}')
        continue

    s = p.read_text()
    orig = s

    # 1. Replace the plain download anchor with a PdfViewer
    def repl(m):
        url_expr = m.group(1)  # e.g. note.data.pdfUrl
        # figure out the title expr
        base = url_expr.rsplit('.', 1)[0]  # note.data
        return f'<PdfViewer url={{url({url_expr})}} title={{{base}.title}} />'

    s2 = simple_pattern.sub(repl, s)

    if s2 != s:
        # Ensure the PdfViewer import exists
        if "import PdfViewer" not in s2:
            # Find the last import line and append after it
            lines = s2.split('\n')
            last_import = -1
            for i, ln in enumerate(lines):
                if ln.strip().startswith('import '):
                    last_import = i
            if last_import >= 0:
                lines.insert(last_import + 1, "import PdfViewer from '../../components/PdfViewer.astro';")
            s2 = '\n'.join(lines)
        s = s2

    if s != orig:
        p.write_text(s)
        count += 1
        print(f'  wired: {path}')

print(f'  {count} pages now use PdfViewer')
PY

# ═══════════════════════════════════════════════
#  5. Rebuild
# ═══════════════════════════════════════════════
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -12

echo ""
echo "════════════════════════════════════════════"
echo "  Done."
echo ""
echo "  Push:"
echo "    git add ."
echo "    git commit -m 'Add universal PDF viewer'"
echo "    git push"
echo ""
echo "  What works:"
echo "    - Direct PDF URLs (Cloudflare R2, S3, any host)"
echo "    - Google Drive links (auto-converts to preview)"
echo "    - Dropbox links (auto-converts to raw)"
echo "    - Fallback download + open-in-new-tab buttons"
echo "    - Full-screen preview on mobile"
echo ""
echo "  Test:"
echo "    /past-papers/physics-9-punjab-2024   (rich paper)"
echo "    /notes/english-9-essays              (note detail)"
echo "    /gazettes/bise-karachi-9-2024        (gazette)"
echo "════════════════════════════════════════════"