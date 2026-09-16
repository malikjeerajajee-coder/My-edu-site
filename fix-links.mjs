import { readFileSync, writeFileSync, readdirSync, statSync, existsSync, mkdirSync } from 'fs';
import { join } from 'path';

const BASE = '/My-edu-site';
const DIST = './dist';

// Make sure .nojekyll exists in dist
if (!existsSync(DIST)) {
  console.log('  dist/ not found — run astro build first');
  process.exit(1);
}
writeFileSync(join(DIST, '.nojekyll'), '');

function walk(dir) {
  for (const f of readdirSync(dir)) {
    const p = join(dir, f);
    if (statSync(p).isDirectory()) walk(p);
    else if (p.endsWith('.html')) fix(p);
  }
}

function fix(file) {
  let h = readFileSync(file, 'utf8');
  // Rewrite href/src/action — but SKIP anything already prefixed
  h = h.replace(/href="\/(?!My-edu-site\/|_astro\/)([^"]*)"/g, (m, p) => `href="${BASE}/${p}"`);
  h = h.replace(/src="\/(?!My-edu-site\/|_astro\/)([^"]*)"/g,  (m, p) => `src="${BASE}/${p}"`);
  h = h.replace(/action="\/(?!My-edu-site\/)([^"]*)"/g, (m, p) => `action="${BASE}/${p}"`);
  // Never double-prefix
  h = h.replace(new RegExp(BASE + BASE, 'g'), BASE);
  writeFileSync(file, h);
}

walk(DIST);
console.log('  All internal links rewritten. .nojekyll written to dist.');
