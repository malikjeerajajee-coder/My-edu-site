#!/bin/bash
set -e

echo "════════════════════════════════════════════"
echo "  Adding test PDF with Google Drive link"
echo "════════════════════════════════════════════"
echo ""

DRIVE_URL="https://drive.google.com/file/d/1htcHiKXe50EGxjPTjYnA6fev74toRpHB/view"

# ═══════════════════════════════════════════════
#  1. Update English essays note with the Drive PDF
# ═══════════════════════════════════════════════
python3 - "$DRIVE_URL" <<'PY'
import sys, pathlib, re

drive_url = sys.argv[1]
p = pathlib.Path("src/content/notes/english-9-essays.md")
s = p.read_text()

# Replace pdfUrl line
s = re.sub(
    r'^pdfUrl:.*$',
    f'pdfUrl: "{drive_url}"',
    s,
    flags=re.MULTILINE
)
p.write_text(s)
print(f"  Updated english-9-essays.md → pdfUrl = {drive_url}")
PY

# ═══════════════════════════════════════════════
#  2. Ensure PdfViewer exists and is wired into notes page
# ═══════════════════════════════════════════════
if [ ! -f src/components/PdfViewer.astro ]; then
    echo "  PdfViewer.astro missing — creating..."

    cat > src/components/PdfViewer.astro <<'ASTRO'
---
import Icon from './Icon.astro';
import { normalizePdfUrl } from '../lib/pdfUrl';

interface Props {
  url: string;
  title?: string;
  height?: number;
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
  <div class="flex flex-wrap items-center gap-3 border-b border-neutral-200 bg-neutral-50 px-4 py-3">
    <span class="grid h-9 w-9 shrink-0 place-items-center rounded-lg bg-[#eef2fe] text-[#0620ed]">
      <Icon name="file-pdf" size={18} strokeWidth={2.2} />
    </span>
    <div class="min-w-0 flex-1">
      <div class="truncate text-sm font-bold text-neutral-900">{title}</div>
      <div class="text-xs text-neutral-500">PDF preview</div>
    </div>

    <div class="flex items-center gap-2">
      <a href={preview} target="_blank" rel="noopener"
         class="hidden items-center gap-1.5 rounded-lg border border-neutral-200 bg-white px-3 py-2 text-xs font-bold text-neutral-700 transition-colors hover:border-[#0620ed] hover:text-[#0620ed] sm:inline-flex">
        <Icon name="external-link" size={13} strokeWidth={2.4} />
        <span>Open</span>
      </a>
      <a href={download} target="_blank" rel="noopener" download
         class="inline-flex items-center gap-1.5 rounded-lg bg-[#0620ed] px-3 py-2 text-xs font-bold !text-white transition-colors hover:bg-[#110176]">
        <Icon name="download" size={13} strokeWidth={2.4} />
        <span>{downloadLabel}</span>
      </a>
    </div>
  </div>

  <div class="relative w-full bg-neutral-100">
    {embeddable ? (
      <iframe id={`pdf-${uid}`} src={preview} title={title} loading="lazy"
        referrerpolicy="no-referrer" class="block w-full border-0"
        style={`height: ${height}px; max-height: 85vh;`}></iframe>
    ) : (
      <div class="flex flex-col items-center justify-center gap-3 p-12 text-center" style={`min-height: ${height}px;`}>
        <span class="grid h-14 w-14 place-items-center rounded-2xl bg-[#eef2fe] text-[#0620ed]">
          <Icon name="file-pdf" size={26} strokeWidth={2.2} />
        </span>
        <div class="text-base font-bold text-neutral-900">Preview not available</div>
        <p class="max-w-sm text-sm text-neutral-500">Use the download button above to view this document.</p>
      </div>
    )}
  </div>
</div>

<div class="mt-3 flex justify-center sm:hidden">
  <a href={preview} target="_blank" rel="noopener"
     class="inline-flex items-center gap-1.5 rounded-lg border border-neutral-200 bg-white px-4 py-2.5 text-xs font-bold text-neutral-700 transition-colors hover:border-[#0620ed] hover:text-[#0620ed]">
    <Icon name="expand" size={13} strokeWidth={2.4} />
    Open full screen
  </a>
</div>
ASTRO
    echo "  PdfViewer.astro created"
fi

# ═══════════════════════════════════════════════
#  3. Ensure pdfUrl.ts exists
# ═══════════════════════════════════════════════
if [ ! -f src/lib/pdfUrl.ts ]; then
    cat > src/lib/pdfUrl.ts <<'EOF'
export interface NormalizedPdf {
  preview: string;
  download: string;
  embeddable: boolean;
}

export function normalizePdfUrl(raw: string): NormalizedPdf {
  if (!raw) return { preview: '', download: '', embeddable: false };

  const drive1 = raw.match(/drive\.google\.com\/file\/d\/([^/?#]+)/);
  const drive2 = raw.match(/drive\.google\.com\/open\?id=([^&]+)/);
  const drive3 = raw.match(/drive\.google\.com\/uc\?.*id=([^&]+)/);
  const driveId = drive1?.[1] || drive2?.[1] || drive3?.[1];
  if (driveId) {
    return {
      preview: `https://drive.google.com/file/d/${driveId}/preview`,
      download: `https://drive.google.com/uc?export=download&id=${driveId}`,
      embeddable: true,
    };
  }

  if (raw.includes('dropbox.com')) {
    const cleaned = raw.replace(/([?&])dl=0/, '$1raw=1').replace(/([?&])dl=1/, '$1raw=1');
    return {
      preview: cleaned,
      download: raw.replace(/([?&])dl=0/, '$1dl=1'),
      embeddable: true,
    };
  }

  return { preview: raw, download: raw, embeddable: true };
}
EOF
    echo "  pdfUrl.ts created"
fi

# ═══════════════════════════════════════════════
#  4. Wire PdfViewer into notes detail page
# ═══════════════════════════════════════════════
python3 - <<'PY'
import pathlib, re

p = pathlib.Path("src/pages/notes/[...slug].astro")
if not p.exists():
    print("  notes detail page not found")
    raise SystemExit(1)

s = p.read_text()

# Ensure PdfViewer import
if "import PdfViewer" not in s:
    # Insert after the last import
    lines = s.split('\n')
    last = -1
    for i, ln in enumerate(lines):
        if ln.strip().startswith('import '):
            last = i
    lines.insert(last + 1, "import PdfViewer from '../../components/PdfViewer.astro';")
    s = '\n'.join(lines)

# Replace existing plain download link with PdfViewer
pattern = re.compile(
    r'\{?[a-zA-Z_.]*(?:data)?\.pdfUrl\s*&&\s*\(?\s*'
    r'<a[^>]*?href=\{url\([a-zA-Z_.]*(?:data)?\.pdfUrl\)\}[^>]*?>[\s\S]*?</a>\s*\)?\s*\}?',
    re.DOTALL,
)

replacement = "<PdfViewer url={url(note.data.pdfUrl)} title={note.data.title} />"

new_s, n = pattern.subn(replacement, s)

# If pattern didn't match, try simpler match
if n == 0:
    simple = re.compile(
        r'<a\s+href=\{url\(note\.data\.pdfUrl\)\}[^>]*?>[\s\S]*?</a>',
        re.DOTALL
    )
    new_s, n = simple.subn(replacement, s)

if n > 0:
    p.write_text(new_s)
    print(f"  notes detail: PdfViewer wired in ({n} replacement)")
else:
    # Fallback: append PdfViewer before the prose article
    if "PdfViewer" not in s:
        s = s.replace(
            '<article',
            '{note.data.pdfUrl && <PdfViewer url={url(note.data.pdfUrl)} title={note.data.title} />}\n    <article',
            1
        )
        p.write_text(s)
        print("  notes detail: PdfViewer inserted before prose")
    else:
        print("  notes detail: PdfViewer already present")
PY

# ═══════════════════════════════════════════════
#  5. Also ensure url() helper exists
# ═══════════════════════════════════════════════
if [ ! -f src/lib/url.ts ]; then
    cat > src/lib/url.ts <<'EOF'
const RAW_BASE = import.meta.env.BASE_URL || '/';
const BASE = RAW_BASE.endsWith('/') ? RAW_BASE.slice(0, -1) : RAW_BASE;

export function url(path: string): string {
  if (!path) return BASE || '/';
  if (/^https?:\/\//i.test(path)) return path;
  if (path.startsWith('#') || path.startsWith('mailto:') || path.startsWith('tel:')) return path;
  if (path === '/') return BASE ? BASE + '/' : '/';
  const clean = path.startsWith('/') ? path : '/' + path;
  return BASE + clean;
}
EOF
    echo "  url.ts created"
fi

# ═══════════════════════════════════════════════
#  6. Rebuild
# ═══════════════════════════════════════════════
echo ""
echo "Rebuilding..."
npm run build 2>&1 | tail -12

echo ""
echo "════════════════════════════════════════════"
echo "  Done. Push:"
echo ""
echo "    git add ."
echo "    git commit -m 'Test Google Drive PDF in viewer'"
echo "    git push"
echo ""
echo "  Then open (clear cache first):"
echo ""
echo "    https://malikjeerajajee-coder.github.io/My-edu-site/notes/english-9-essays/"
echo ""
echo "  You should see:"
echo "    - Toolbar with title + Open + Download buttons"
echo "    - PDF preview embedded below"
echo "    - Auto-converts Drive link to /preview URL"
echo "════════════════════════════════════════════"