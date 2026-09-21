#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "Adding vite watcher config..."

python3 - <<'PY'
import pathlib, re

p = pathlib.Path('astro.config.mjs')
s = p.read_text()

if 'ignored:' in s:
    print('  · Already configured')
else:
    if 'vite: {' in s:
        s = re.sub(
            r'vite:\s*\{',
            """vite: {
    server: {
      watch: {
        ignored: ['**/src/content/**', '**/dist/**', '**/.astro/**', '**/node_modules/**'],
      },
    },""",
            s, count=1
        )
    else:
        s = s.replace(
            '  integrations: [',
            """  vite: {
    server: {
      watch: {
        ignored: ['**/src/content/**', '**/dist/**', '**/.astro/**', '**/node_modules/**'],
      },
    },
  },
  integrations: [""",
            1
        )
    p.write_text(s)
    print('  ✓ astro.config.mjs updated')

print()
print('  Now run:  npm run dev')
PY