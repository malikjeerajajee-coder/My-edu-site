const fs = require('fs');
const file = 'src/layouts/BaseLayout.astro';
let code = fs.readFileSync(file, 'utf8');

if (!code.includes('import Sidebar')) {
  // Inject right after the first ---
  code = code.replace(/---\r?\n/, '---\nimport Sidebar from \'../components/Sidebar.astro\';\n');
  fs.writeFileSync(file, code);
  console.log('✅ Added Sidebar import to BaseLayout.astro');
} else {
  console.log('ℹ️ Sidebar import already exists in the file.');
}

// Verify Sidebar component exists
if (!fs.existsSync('src/components/Sidebar.astro')) {
  console.log('❌ WARNING: src/components/Sidebar.astro is missing!');
} else {
  console.log('✅ src/components/Sidebar.astro exists.');
}