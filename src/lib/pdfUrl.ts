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
