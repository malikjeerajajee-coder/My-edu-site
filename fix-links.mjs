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
  // Rewrite href="/xxx" → href="/My-edu-site/xxx" (skip if already has base)
  html = html.replace(/href="\/(?!My-edu-site\/)([^"]*)"/g, (m, p) => `href="${BASE}/${p}"`);
  // Rewrite src="/xxx" → src="/My-edu-site/xxx"
  html = html.replace(/src="\/(?!My-edu-site\/)([^"]*)"/g, (m, p) => `src="${BASE}/${p}"`);
  writeFileSync(file, html);
  console.log('  fixed:', file);
}

walk(DIST);
console.log('Done.');
