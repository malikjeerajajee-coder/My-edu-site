import { readFileSync, writeFileSync, readdirSync, statSync } from 'fs';
import { join } from 'path';

const BASE = '/My-edu-site';
const DIST = './dist';

function walk(dir) {
  for (const f of readdirSync(dir)) {
    const p = join(dir, f);
    if (statSync(p).isDirectory()) walk(p);
    else if (p.endsWith('.html')) fix(p);
  }
}

function fix(file) {
  let h = readFileSync(file, 'utf8');
  h = h.replace(/href="\/(?!My-edu-site\/)([^"]*)"/g, (m, p) => `href="${BASE}/${p}"`);
  h = h.replace(/src="\/(?!My-edu-site\/)([^"]*)"/g,  (m, p) => `src="${BASE}/${p}"`);
  h = h.replace(/action="\/(?!My-edu-site\/)([^"]*)"/g, (m, p) => `action="${BASE}/${p}"`);
  h = h.replace(new RegExp(BASE + BASE, 'g'), BASE);
  writeFileSync(file, h);
}

if (statSync(DIST).isDirectory()) {
  walk(DIST);
  console.log('  all internal links rewritten');
} else {
  console.log('  dist/ not found — run astro build first');
}
