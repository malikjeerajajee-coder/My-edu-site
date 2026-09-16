import { readFileSync, writeFileSync, readdirSync, statSync } from 'fs';
import { join } from 'path';

const DIST = './dist';
const BASE = '/My-edu-site';

function walk(dir) {
  for (const f of readdirSync(dir)) {
    const p = join(dir, f);
    if (statSync(p).isDirectory()) walk(p);
    else if (p.endsWith('.html')) fixFile(p);
  }
}

function fixFile(file) {
  let html = readFileSync(file, 'utf8');
  // href="/x"  → href="/My-edu-site/x"  (skip if already has base)
  html = html.replace(/href="\/(?!My-edu-site\/)([^"]*)"/g, (m, p) => `href="${BASE}/${p}"`);
  // src="/x"   → src="/My-edu-site/x"
  html = html.replace(/src="\/(?!My-edu-site\/)([^"]*)"/g, (m, p) => `src="${BASE}/${p}"`);
  // action="/x" → action="/My-edu-site/x" (for forms)
  html = html.replace(/action="\/(?!My-edu-site\/)([^"]*)"/g, (m, p) => `action="${BASE}/${p}"`);
  // Fix double-base if any: /My-edu-site/My-edu-site/ → /My-edu-site/
  html = html.replace(new RegExp(`${BASE}${BASE}`, 'g'), BASE);
  writeFileSync(file, html);
}

walk(DIST);
console.log('All internal links rewritten with base path.');
