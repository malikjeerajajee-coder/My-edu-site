// Prepends the Astro base path to any internal link.
// In astro.config.mjs, base is '/My-edu-site'.
// import.meta.env.BASE_URL resolves to '/My-edu-site' at build time.

const RAW_BASE = import.meta.env.BASE_URL || '/';
const BASE = RAW_BASE.endsWith('/') ? RAW_BASE.slice(0, -1) : RAW_BASE;

export function url(path: string): string {
  if (!path) return BASE || '/';
  if (/^https?:\/\//i.test(path)) return path;      // external URL
  if (path.startsWith('#')) return path;            // anchor
  if (path.startsWith('mailto:') || path.startsWith('tel:')) return path;
  if (path === '/') return BASE ? BASE + '/' : '/';
  const clean = path.startsWith('/') ? path : '/' + path;
  return BASE + clean;
}
