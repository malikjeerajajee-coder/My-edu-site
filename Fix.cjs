const fs = require('fs');
const path = require('path');

console.log('🔧 Fixing Sidebar integration...\n');

// 1. Ensure Sidebar.astro exists
const sidebarPath = path.join('src', 'components', 'Sidebar.astro');
if (!fs.existsSync(sidebarPath)) {
  console.log('❌ Sidebar.astro does not exist! Creating it...');
  
  const sidebarCode = `---
import Icon from './Icon.astro';
import { url } from '../lib/url';

const path = Astro.url.pathname;

const current = {
  isBoards: path.startsWith(url('/board/')),
  isClasses: path.startsWith(url('/class/')),
  isNotes: path.startsWith(url('/note')) || path.startsWith(url('/notes')),
  isPapers: path.startsWith(url('/past-papers')),
  isBooks: path.startsWith(url('/textbook')) || path.startsWith(url('/books')),
  isQuizzes: path.startsWith(url('/quiz')) || path.startsWith(url('/quizzes')),
  isGuess: path.startsWith(url('/guess-papers')),
  isPairing: path.startsWith(url('/pairing-schemes')),
  isGazettes: path.startsWith(url('/gazettes')),
};

const boards = [
  { slug: 'punjab', name: 'Punjab' }, { slug: 'federal', name: 'Federal' },
  { slug: 'sindh', name: 'Sindh' }, { slug: 'kpk', name: 'KPK' },
  { slug: 'balochistan', name: 'Balochistan' }, { slug: 'ajk', name: 'AJK' },
];

const classes = Array.from({ length: 12 }, (_, i) => ({ num: String(i + 1) }));

const isActive = (href) => {
  const t = url(href);
  if (href === '/') return path === t || path === t + '/';
  return path.startsWith(t);
};
---

<div class="smx-topbar">
  <button type="button" class="smx-menu-btn" id="smx-menu-btn" aria-label="Open menu">
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 6h16M4 12h16M4 18h16"/></svg>
  </button>
  <a href={url('/')} class="smx-topbar-brand">
    <img src={url('/logo-icon-64.png')} alt="Parhayi" width="28" height="28" style="border-radius:6px" />
    <span>Parhayi</span>
  </a>
  <a href={url('/search')} class="smx-topbar-search" aria-label="Search">
    <Icon name="search" size={18} strokeWidth={2.2} />
  </a>
</div>

<div class="smx-overlay" id="smx-overlay"></div>

<aside class="smx-sidebar" id="smx-sidebar" aria-label="Main navigation">
  <div class="smx-brand">
    <a href={url('/')} class="smx-brand-link">
      <img src={url('/logo-icon-64.png')} alt="Parhayi" width="34" height="34" style="border-radius: 8px;" />
      <div class="smx-brand-text">
        <span class="smx-brand-name">Parhayi</span>
        <span class="smx-brand-tag">Free study resources</span>
      </div>
    </a>
    <button type="button" class="smx-close-btn" id="smx-close-btn" aria-label="Close menu">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
    </button>
  </div>

  <div class="smx-search">
    <a href={url('/search')} class="smx-search-btn">
      <Icon name="search" size={16} strokeWidth={2.2} />
      <span>Search library…</span>
      <kbd>/</kbd>
    </a>
  </div>

  <nav class="smx-nav">
    <div class="smx-section">
      <div class="smx-section-title">Main</div>
      <a href={url('/')} class:list={['smx-item', isActive('/') && 'active']}>
        <span class="smx-icon"><Icon name="home" size={17} strokeWidth={2.2} /></span>
        <span class="smx-label">Home</span>
      </a>
    </div>

    <div class="smx-section">
      <button type="button" class:list={['smx-group-toggle', current.isBoards && 'open']} data-group="boards">
        <span class="smx-icon"><Icon name="graduation-cap" size={17} strokeWidth={2.2} /></span>
        <span class="smx-label">Boards</span>
        <svg class="smx-chevron" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>
      </button>
      <div class:list={['smx-group-body', current.isBoards && 'open']} data-group="boards">
        <div class="smx-group-grid">
          {boards.map(b => (
            <a href={url('/board/' + b.slug)} class:list={['smx-subitem', isActive('/board/' + b.slug) && 'active']}>{b.name}</a>
          ))}
        </div>
        <a href={url('/boards')} class="smx-group-all">View all boards <Icon name="arrow-right" size={13} strokeWidth={2.4} /></a>
      </div>
    </div>

    <div class="smx-section">
      <button type="button" class:list={['smx-group-toggle', current.isClasses && 'open']} data-group="classes">
        <span class="smx-icon"><Icon name="layers" size={17} strokeWidth={2.2} /></span>
        <span class="smx-label">Classes</span>
        <svg class="smx-chevron" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>
      </button>
      <div class:list={['smx-group-body', current.isClasses && 'open']} data-group="classes">
        <div class="smx-group-grid smx-group-grid-4">
          {classes.map(c => (
            <a href={url('/class/' + c.num)} class:list={['smx-subitem smx-subitem-num', isActive('/class/' + c.num) && 'active']}>{c.num}</a>
          ))}
        </div>
      </div>
    </div>

    <div class="smx-section">
      <div class="smx-section-title">Study Resources</div>
      <a href={url('/notes')} class:list={['smx-item', current.isNotes && 'active']}><span class="smx-icon"><Icon name="file-text" size={17} strokeWidth={2.2} /></span><span class="smx-label">Notes</span></a>
      <a href={url('/quizzes')} class:list={['smx-item', current.isQuizzes && 'active']}><span class="smx-icon"><Icon name="circle-help" size={17} strokeWidth={2.2} /></span><span class="smx-label">Quizzes</span></a>
      <a href={url('/books')} class:list={['smx-item', current.isBooks && 'active']}><span class="smx-icon"><Icon name="book-marked" size={17} strokeWidth={2.2} /></span><span class="smx-label">Textbooks</span></a>
    </div>

    <div class="smx-section">
      <div class="smx-section-title">Exam Preparation</div>
      <a href={url('/past-papers')} class:list={['smx-item', current.isPapers && 'active']}><span class="smx-icon"><Icon name="scroll-text" size={17} strokeWidth={2.2} /></span><span class="smx-label">Past Papers</span></a>
      <a href={url('/guess-papers')} class:list={['smx-item', current.isGuess && 'active']}><span class="smx-icon"><Icon name="sparkles" size={17} strokeWidth={2.2} /></span><span class="smx-label">Guess Papers</span></a>
      <a href={url('/pairing-schemes')} class:list={['smx-item', current.isPairing && 'active']}><span class="smx-icon"><Icon name="list" size={17} strokeWidth={2.2} /></span><span class="smx-label">Pairing Schemes</span></a>
      <a href={url('/gazettes')} class:list={['smx-item', current.isGazettes && 'active']}><span class="smx-icon"><Icon name="newspaper" size={17} strokeWidth={2.2} /></span><span class="smx-label">Result Gazettes</span></a>
    </div>

    <div class="smx-section">
      <div class="smx-section-title">Info</div>
      <a href={url('/about')} class:list={['smx-item', isActive('/about') && 'active']}><span class="smx-icon"><Icon name="info" size={17} strokeWidth={2.2} /></span><span class="smx-label">About</span></a>
      <a href={url('/contact')} class:list={['smx-item', isActive('/contact') && 'active']}><span class="smx-icon"><Icon name="mail" size={17} strokeWidth={2.2} /></span><span class="smx-label">Contact</span></a>
    </div>
  </nav>
</aside>

<script is:inline>
(function () {
  var sidebar = document.getElementById('smx-sidebar');
  var overlay = document.getElementById('smx-overlay');
  var openBtn = document.getElementById('smx-menu-btn');
  var closeBtn = document.getElementById('smx-close-btn');

  function open() { sidebar.classList.add('open'); overlay.classList.add('open'); document.body.style.overflow = 'hidden'; }
  function close() { sidebar.classList.remove('open'); overlay.classList.remove('open'); document.body.style.overflow = ''; }

  if (openBtn) openBtn.addEventListener('click', open);
  if (closeBtn) closeBtn.addEventListener('click', close);
  if (overlay) overlay.addEventListener('click', close);
  document.addEventListener('keydown', function(e) { if (e.key === 'Escape') close(); });

  document.querySelectorAll('.smx-group-toggle').forEach(function(btn) {
    btn.addEventListener('click', function() {
      var g = btn.getAttribute('data-group');
      var body = document.querySelector('.smx-group-body[data-group="' + g + '"]');
      var isOpen = btn.classList.toggle('open');
      if (body) body.classList.toggle('open', isOpen);
    });
  });
})();
</script>

<style is:global>
:root { --smx-w: 272px; --smx-brand: #1d4ed8; --smx-bg: #ffffff; --smx-border: #e5e9f0; --smx-text: #0f172a; --smx-muted: #64748b; --smx-hover: #f8fafc; --smx-active-bg: #eff4ff; }
.smx-topbar { position: sticky; top: 0; z-index: 30; display: flex; align-items: center; gap: 0.75rem; padding: 0.75rem 1rem; background: var(--smx-bg); border-bottom: 1px solid var(--smx-border); }
@media (min-width: 1024px) { .smx-topbar { display: none; } }
.smx-menu-btn { display: inline-flex; align-items: center; justify-content: center; width: 40px; height: 40px; border-radius: 10px; color: var(--smx-text); background: transparent; border: none; cursor: pointer; }
.smx-topbar-brand { flex: 1; display: flex; align-items: center; gap: 0.625rem; font-weight: 800; font-size: 1.0625rem; color: var(--smx-text); text-decoration: none; }
.smx-topbar-search { display: inline-flex; align-items: center; justify-content: center; width: 40px; height: 40px; border-radius: 10px; color: var(--smx-muted); }
.smx-overlay { position: fixed; inset: 0; z-index: 40; background: rgba(15, 23, 42, 0.4); opacity: 0; pointer-events: none; transition: opacity 0.2s; }
.smx-overlay.open { opacity: 1; pointer-events: auto; }
@media (min-width: 1024px) { .smx-overlay { display: none; } }
.smx-sidebar { position: fixed; inset-y: 0; left: 0; z-index: 50; width: var(--smx-w); background: var(--smx-bg); border-right: 1px solid var(--smx-border); display: flex; flex-direction: column; transform: translateX(-100%); transition: transform 0.25s ease; }
.smx-sidebar.open { transform: translateX(0); }
@media (min-width: 1024px) { .smx-sidebar { transform: translateX(0); z-index: 40; } }
.smx-brand { display: flex; align-items: center; justify-content: space-between; padding: 1.125rem 1.25rem 1rem; border-bottom: 1px solid var(--smx-border); }
.smx-brand-link { display: flex; align-items: center; gap: 0.75rem; text-decoration: none; }
.smx-brand-name { font-size: 1.0625rem; font-weight: 800; color: var(--smx-text); }
.smx-brand-tag { font-size: 0.6875rem; color: var(--smx-muted); font-weight: 500; }
.smx-close-btn { display: inline-flex; align-items: center; justify-content: center; width: 32px; height: 32px; border-radius: 8px; color: var(--smx-muted); background: transparent; border: none; cursor: pointer; }
@media (min-width: 1024px) { .smx-close-btn { display: none; } }
.smx-search { padding: 0.875rem 1rem 0.5rem; }
.smx-search-btn { display: flex; align-items: center; gap: 0.625rem; width: 100%; padding: 0.625rem 0.875rem; border-radius: 10px; background: #f8fafc; border: 1px solid var(--smx-border); color: var(--smx-muted); font-size: 0.8125rem; text-decoration: none; }
.smx-search-btn kbd { margin-left: auto; padding: 0.125rem 0.5rem; border-radius: 6px; background: #ffffff; border: 1px solid var(--smx-border); font-size: 0.6875rem; font-weight: 700; color: var(--smx-muted); }
.smx-nav { flex: 1; overflow-y: auto; padding: 0.5rem 0.5rem 1rem; }
.smx-section { margin-top: 0.5rem; }
.smx-section-title { padding: 0.875rem 0.875rem 0.375rem; font-size: 0.6875rem; font-weight: 800; letter-spacing: 0.1em; text-transform: uppercase; color: var(--smx-muted); }
.smx-item { display: flex; align-items: center; gap: 0.75rem; padding: 0.625rem 0.875rem; margin: 1px 0; border-radius: 9px; color: var(--smx-text); font-size: 0.875rem; font-weight: 600; position: relative; text-decoration: none; }
.smx-item:hover { background: var(--smx-hover); }
.smx-item.active { background: var(--smx-active-bg); color: var(--smx-brand); font-weight: 700; }
.smx-item.active::before { content: ''; position: absolute; left: 0; top: 50%; transform: translateY(-50%); width: 3px; height: 18px; border-radius: 0 3px 3px 0; background: var(--smx-brand); }
.smx-icon { display: inline-flex; align-items: center; justify-content: center; width: 20px; height: 20px; color: var(--smx-muted); flex-shrink: 0; }
.smx-item.active .smx-icon, .smx-item:hover .smx-icon { color: var(--smx-brand); }
.smx-group-toggle { display: flex; align-items: center; gap: 0.75rem; width: 100%; padding: 0.625rem 0.875rem; margin: 1px 0; border-radius: 9px; color: var(--smx-text); font-size: 0.875rem; font-weight: 600; text-align: left; background: transparent; border: none; cursor: pointer; }
.smx-group-toggle:hover { background: var(--smx-hover); }
.smx-group-toggle.open { color: var(--smx-brand); }
.smx-group-toggle.open .smx-icon { color: var(--smx-brand); }
.smx-chevron { margin-left: auto; color: var(--smx-muted); transition: transform 0.2s ease; flex-shrink: 0; }
.smx-group-toggle.open .smx-chevron { transform: rotate(90deg); color: var(--smx-brand); }
.smx-group-body { display: grid; grid-template-rows: 0fr; transition: grid-template-rows 0.22s ease; }
.smx-group-body.open { grid-template-rows: 1fr; }
.smx-group-body > * { min-height: 0; overflow: hidden; }
.smx-group-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 4px; padding: 0.5rem 0.5rem 0.5rem 0.75rem; }
.smx-group-grid-4 { grid-template-columns: repeat(4, 1fr); }
.smx-subitem { display: flex; align-items: center; justify-content: center; padding: 0.5rem 0.25rem; border-radius: 7px; background: #f8fafc; border: 1px solid var(--smx-border); color: var(--smx-text); font-size: 0.75rem; font-weight: 600; text-decoration: none; }
.smx-subitem:hover { border-color: var(--smx-brand); color: var(--smx-brand); background: var(--smx-active-bg); }
.smx-subitem.active { background: var(--smx-brand); border-color: var(--smx-brand); color: #ffffff; font-weight: 700; }
.smx-group-all { display: flex; align-items: center; justify-content: center; gap: 0.375rem; margin: 0.25rem 0.5rem 0.5rem 0.75rem; padding: 0.5rem; border-radius: 7px; color: var(--smx-brand); font-size: 0.75rem; font-weight: 700; text-decoration: none; }
</style>`;

  fs.writeFileSync(sidebarPath, sidebarCode);
  console.log('✅ Created src/components/Sidebar.astro');
} else {
  console.log('✅ Sidebar.astro already exists');
}

// 2. Fix BaseLayout.astro
const layoutPath = path.join('src', 'layouts', 'BaseLayout.astro');
let layout = fs.readFileSync(layoutPath, 'utf8');
let changed = false;

// Add import if missing
if (!layout.includes("import Sidebar from '../components/Sidebar.astro';")) {
  layout = layout.replace(
    /(---\n)/,
    "$1import Sidebar from '../components/Sidebar.astro';\n"
  );
  console.log('✅ Added Sidebar import to BaseLayout.astro');
  changed = true;
} else {
  console.log('✅ Sidebar import already exists');
}

// Check if <Sidebar /> is in the template
if (!layout.includes('<Sidebar />')) {
  // Remove old desktop sidebar
  layout = layout.replace(
    /<!-- ═══ DESKTOP SIDEBAR ═══ -->[\s\S]*?<\/aside>\n/,
    ''
  );
  
  // Remove old mobile top bar
  layout = layout.replace(
    /<!-- ═══ MOBILE TOP BAR ═══ -->[\s\S]*?<\/header>\n/,
    ''
  );
  
  // Remove old mobile drawer
  layout = layout.replace(
    /<!-- ═══ MOBILE DRAWER ═══ -->[\s\S]*?<\/div>\n/,
    ''
  );
  
  // Remove old drawer script
  layout = layout.replace(
    /<script is:inline>\s*\(function \(\) \{\s*var drawer = document\.getElementById\('drawer'\);[\s\S]*?\}\)\(\);\s*<\/script>/,
    ''
  );
  
  // Add <Sidebar /> before content div
  layout = layout.replace(
    /<!-- ═══ CONTENT ═══ -->\n<div class="lg:pl-\[250px\]">/,
    '<Sidebar />\n  <!-- ═══ CONTENT ═══ -->\n  <div class="lg:pl-[272px]">'
  );
  
  console.log('✅ Replaced old sidebars with <Sidebar />');
  changed = true;
} else {
  console.log('✅ <Sidebar /> already in template');
}

if (changed) {
  fs.writeFileSync(layoutPath, layout);
  console.log('✅ BaseLayout.astro updated');
}

console.log('\n🎉 Done! Now run: npm run build');