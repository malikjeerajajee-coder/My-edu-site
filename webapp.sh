#!/bin/bash
set -e

echo "Rebuilding as responsive web app..."

mkdir -p src/components

# ============ ICON COMPONENT (Lucide) ============
cat > src/components/Icon.astro <<'EOF'
---
interface Props {
  name: string;
  size?: number;
  class?: string;
  strokeWidth?: number;
}
const { name, size = 20, class: className = '', strokeWidth = 2 } = Astro.props;

const icons: Record<string, string> = {
  home: '<path d="M3 9.5 12 3l9 6.5V20a1 1 0 0 1-1 1h-5v-7h-6v7H4a1 1 0 0 1-1-1V9.5Z"/>',
  'book-open': '<path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>',
  'circle-help': '<circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><path d="M12 17h.01"/>',
  library: '<path d="m16 6 4 14"/><path d="M12 6v14"/><path d="M8 8v12"/><path d="M4 4v16"/>',
  newspaper: '<path d="M4 22h16a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2H8a2 2 0 0 0-2 2v16a2 2 0 0 1-4 0V5"/><path d="M18 14h-8"/><path d="M15 18h-5"/><path d="M10 6h8v4h-8V6Z"/>',
  search: '<circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/>',
  x: '<path d="M18 6 6 18"/><path d="m6 6 12 12"/>',
  download: '<path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><path d="m7 10 5 5 5-5"/><path d="M12 15V3"/>',
  'chevron-right': '<path d="m9 18 6-6-6-6"/>',
  'arrow-left': '<path d="m12 19-7-7 7-7"/><path d="M19 12H5"/>',
  'arrow-right': '<path d="M5 12h14"/><path d="m12 5 7 7-7 7"/>',
  'graduation-cap': '<path d="M21.42 10.922a1 1 0 0 0-.019-1.838L12.83 5.18a2 2 0 0 0-1.66 0L2.6 9.08a1 1 0 0 0 0 1.832l8.57 3.908a2 2 0 0 0 1.66 0z"/><path d="M22 10v6"/><path d="M6 12.5V16a6 3 0 0 0 12 0v-3.5"/>',
  sparkles: '<path d="m12 3-1.9 5.8a2 2 0 0 1-1.3 1.3L3 12l5.8 1.9a2 2 0 0 1 1.3 1.3L12 21l1.9-5.8a2 2 0 0 1 1.3-1.3L21 12l-5.8-1.9a2 2 0 0 1-1.3-1.3Z"/>',
  'file-text': '<path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"/><path d="M14 2v4a2 2 0 0 0 2 2h4"/><path d="M10 9H8"/><path d="M16 13H8"/><path d="M16 17H8"/>',
  'file-question': '<path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"/><path d="M14 2v4a2 2 0 0 0 2 2h4"/><path d="M10 12.5a2 2 0 0 1 4 .5c0 1.5-2 2-2 2"/><path d="M12 18h.01"/>',
  'book-marked': '<path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20l-8-6-8 6z"/><path d="m9 9.5 2 2 4-4"/>',
  'scroll-text': '<path d="M15 12h-5"/><path d="M15 8h-5"/><path d="M19 17V5a2 2 0 0 0-2-2H4"/><path d="M8 21h12a2 2 0 0 0 2-2v-1a1 1 0 0 0-1-1H11a1 1 0 0 0-1 1v1a2 2 0 1 1-4 0V5a2 2 0 1 0-4 0v2a1 1 0 0 0 1 1h3"/>',
  zap: '<path d="M13 2 3 14h9l-1 8 10-12h-9l1-8z"/>',
};
---
<svg xmlns="http://www.w3.org/2000/svg" width={size} height={size} viewBox="0 0 24 24"
  fill="none" stroke="currentColor" stroke-width={strokeWidth}
  stroke-linecap="round" stroke-linejoin="round" class={className}
  set:html={icons[name] || ''} />
EOF

# ============ GLOBAL CSS ============
cat > src/styles/global.css <<'EOF'
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@500&display=swap');

*, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
* { box-shadow: none !important; }

:root {
  --primary: #10b981;
  --primary-dark: #047857;
  --primary-darker: #065f46;
  --primary-soft: #ecfdf5;
  --primary-line: #a7f3d0;

  --bg: #f7f9fb;
  --surface: #ffffff;
  --surface-2: #f1f5f9;

  --text: #0b1220;
  --text-2: #334155;
  --text-muted: #64748b;
  --text-subtle: #94a3b8;

  --border: #e5e9ef;
  --border-2: #cfd8e3;

  --blue: #2563eb; --blue-soft: #eff6ff; --blue-line: #bfdbfe;
  --amber: #b45309; --amber-soft: #fff7ed; --amber-line: #fed7aa;
  --rose: #be123c; --rose-soft: #fff1f2; --rose-line: #fecdd3;

  --r-xs: 6px; --r-sm: 8px; --r: 12px; --r-lg: 16px; --r-xl: 20px;

  --ease: cubic-bezier(0.16, 1, 0.3, 1);
  --ease-b: cubic-bezier(0.34, 1.56, 0.64, 1);

  --header-h: 62px;
  --container: 1200px;
}

html { -webkit-text-size-adjust: 100%; scroll-behavior: smooth; }

body {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  background: var(--bg);
  color: var(--text);
  line-height: 1.55;
  letter-spacing: -0.011em;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  min-height: 100vh;
}
a { color: inherit; text-decoration: none; }
img { max-width: 100%; display: block; }
button { font-family: inherit; cursor: pointer; }
input { font-family: inherit; }

/* ============ SHELL ============ */
.shell { min-height: 100vh; display: flex; flex-direction: column; }
.container { width: 100%; max-width: var(--container); margin: 0 auto; padding: 0 24px; }

/* ============ HEADER ============ */
.site-header {
  position: sticky; top: 0; z-index: 50;
  background: rgba(255,255,255,0.88);
  backdrop-filter: saturate(180%) blur(20px);
  -webkit-backdrop-filter: saturate(180%) blur(20px);
  border-bottom: 1px solid var(--border);
}
.header-inner {
  height: var(--header-h);
  display: flex; align-items: center; gap: 20px;
}
.brand { display: flex; align-items: center; gap: 10px; font-weight: 800; font-size: 1rem; letter-spacing: -0.03em; flex-shrink: 0; }
.brand-mark {
  width: 34px; height: 34px; border-radius: 10px;
  background: linear-gradient(135deg, var(--primary-dark), var(--primary));
  color: white; display: grid; place-items: center;
}
.brand-text { color: var(--text); }

.primary-nav { display: none; align-items: center; gap: 2px; margin-left: 8px; }
.primary-nav a {
  padding: 8px 12px; border-radius: var(--r-sm);
  font-size: 0.88rem; font-weight: 600; color: var(--text-2);
  transition: color .15s, background .15s;
  position: relative;
}
.primary-nav a:hover { color: var(--text); background: var(--surface-2); }
.primary-nav a.active { color: var(--primary-dark); background: var(--primary-soft); }

.header-spacer { flex: 1; }

.header-search {
  display: none;
  width: 260px;
  align-items: center; gap: 8px;
  padding: 0 12px; height: 38px;
  background: var(--surface-2);
  border: 1px solid var(--border);
  border-radius: var(--r-sm);
  color: var(--text-muted);
  transition: border-color .15s, background .15s;
}
.header-search:focus-within {
  border-color: var(--primary);
  background: var(--surface);
}
.header-search input {
  flex: 1; border: none; outline: none; background: transparent;
  font-size: 0.85rem; color: var(--text); min-width: 0;
}
.header-search input::placeholder { color: var(--text-subtle); }
.header-search kbd {
  font-family: 'JetBrains Mono', monospace; font-size: 0.65rem; font-weight: 700;
  padding: 2px 5px; border-radius: 4px;
  background: var(--surface); color: var(--text-muted);
  border: 1px solid var(--border);
}

.header-action {
  width: 38px; height: 38px; border-radius: var(--r-sm);
  background: var(--surface-2); border: 1px solid var(--border);
  display: grid; place-items: center; color: var(--text-2);
  transition: background .15s, color .15s, border-color .15s, transform .2s var(--ease-b);
}
.header-action:hover { background: var(--primary-soft); color: var(--primary-dark); border-color: var(--primary-line); }
.header-action:active { transform: scale(0.94); }

/* ============ MOBILE BOTTOM NAV ============ */
.bottom-nav {
  position: fixed; bottom: 0; left: 0; right: 0; z-index: 100;
  background: rgba(255,255,255,0.95);
  backdrop-filter: saturate(180%) blur(20px);
  -webkit-backdrop-filter: saturate(180%) blur(20px);
  border-top: 1px solid var(--border);
  padding: 6px 0 calc(6px + env(safe-area-inset-bottom));
  display: flex; justify-content: space-around;
}
.nav-item {
  display: flex; flex-direction: column; align-items: center; gap: 2px;
  padding: 6px 10px; min-width: 56px;
  color: var(--text-subtle); font-size: 0.62rem; font-weight: 700;
  border-radius: var(--r-sm);
  transition: color .15s, background .15s, transform .2s var(--ease-b);
}
.nav-item:active { transform: scale(0.94); }
.nav-item.active { color: var(--primary-dark); background: var(--primary-soft); }

/* ============ MAIN ============ */
.main {
  flex: 1;
  padding: 28px 0 100px;
}
@media (min-width: 768px) { .main { padding: 36px 0 60px; } }

/* ============ HERO ============ */
.hero {
  position: relative; overflow: hidden;
  border-radius: var(--r-xl);
  padding: 44px 36px;
  background: linear-gradient(135deg, #064e3b 0%, #047857 45%, #059669 100%);
  color: white;
  border: 1px solid var(--primary-darker);
}
.hero::before {
  content: ''; position: absolute; top: -120px; right: -80px;
  width: 320px; height: 320px;
  background: radial-gradient(circle, rgba(52,211,153,0.35), transparent 70%);
  pointer-events: none;
}
.hero-inner { position: relative; z-index: 1; max-width: 620px; }
.hero-eyebrow {
  display: inline-flex; align-items: center; gap: 6px;
  font-size: 0.75rem; font-weight: 700; letter-spacing: 0.02em;
  padding: 5px 10px; border-radius: 999px;
  background: rgba(255,255,255,0.1);
  border: 1px solid rgba(255,255,255,0.18);
  color: #d1fae5;
}
.hero h1 {
  font-size: 2.15rem; font-weight: 800;
  letter-spacing: -0.035em; line-height: 1.12;
  margin-top: 14px;
}
.hero h1 em { font-style: normal; color: #6ee7b7; }
.hero p.lede {
  margin-top: 12px;
  font-size: 1rem; color: rgba(255,255,255,0.8);
  max-width: 520px;
}
.hero-search {
  margin-top: 22px;
  display: flex; align-items: center; gap: 10px;
  padding: 0 16px; height: 52px;
  background: rgba(255,255,255,0.1);
  border: 1px solid rgba(255,255,255,0.2);
  border-radius: var(--r);
  color: rgba(255,255,255,0.85);
  transition: background .15s, border-color .15s;
  max-width: 520px;
}
.hero-search:focus-within {
  background: rgba(255,255,255,0.16);
  border-color: rgba(255,255,255,0.4);
}
.hero-search input {
  flex: 1; border: none; outline: none; background: transparent;
  color: white; font-size: 0.92rem; min-width: 0;
}
.hero-search input::placeholder { color: rgba(255,255,255,0.6); }
.hero-search button {
  display: inline-flex; align-items: center; gap: 6px;
  padding: 8px 14px; border-radius: var(--r-sm);
  background: white; color: var(--primary-darker);
  font-size: 0.82rem; font-weight: 700; border: none;
  transition: transform .2s var(--ease-b), background .15s;
}
.hero-search button:hover { background: #ecfdf5; }
.hero-search button:active { transform: scale(0.95); }

@media (max-width: 640px) {
  .hero { padding: 30px 22px; border-radius: var(--r-lg); }
  .hero h1 { font-size: 1.6rem; }
  .hero p.lede { font-size: 0.9rem; }
}

/* ============ SECTION ============ */
.section { margin-top: 34px; }
.section-head {
  display: flex; align-items: baseline; justify-content: space-between;
  margin-bottom: 14px; gap: 12px;
}
.section-head h2 {
  font-size: 1.15rem; font-weight: 800; letter-spacing: -0.03em;
}
.section-head .link {
  font-size: 0.8rem; font-weight: 700; color: var(--primary-dark);
  display: inline-flex; align-items: center; gap: 3px;
  transition: gap .2s var(--ease);
}
.section-head .link:hover { gap: 6px; }

/* ============ CATEGORY GRID ============ */
.cat-grid {
  display: grid; gap: 12px;
  grid-template-columns: repeat(2, 1fr);
}
@media (min-width: 720px) { .cat-grid { grid-template-columns: repeat(4, 1fr); } }

.cat-card {
  display: flex; flex-direction: column; gap: 14px;
  padding: 18px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--r-lg);
  transition: border-color .18s, background .18s, transform .25s var(--ease-b);
}
.cat-card:hover {
  border-color: var(--primary-line);
  background: var(--primary-soft);
  transform: translateY(-2px);
}
.cat-card:active { transform: translateY(0) scale(0.98); }
.cat-icon {
  width: 40px; height: 40px; border-radius: var(--r-sm);
  display: grid; place-items: center;
  background: var(--primary-soft); color: var(--primary-dark);
  border: 1px solid var(--primary-line);
}
.cat-icon.blue { background: var(--blue-soft); color: var(--blue); border-color: var(--blue-line); }
.cat-icon.amber { background: var(--amber-soft); color: var(--amber); border-color: var(--amber-line); }
.cat-icon.rose { background: var(--rose-soft); color: var(--rose); border-color: var(--rose-line); }
.cat-title { font-size: 0.98rem; font-weight: 800; letter-spacing: -0.02em; }
.cat-count { font-size: 0.78rem; color: var(--text-muted); font-weight: 600; margin-top: 2px; }

/* ============ LISTS ============ */
.list { display: grid; gap: 10px; grid-template-columns: 1fr; }
@media (min-width: 720px) { .list { grid-template-columns: repeat(2, 1fr); } }

.card {
  display: flex; align-items: center; gap: 14px;
  padding: 14px 16px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--r);
  transition: border-color .18s, background .18s, transform .22s var(--ease-b);
}
.card:hover {
  border-color: var(--primary-line);
  background: var(--primary-soft);
  transform: translateY(-1px);
}
.card:active { transform: translateY(0) scale(0.99); }

.card-icon {
  width: 40px; height: 40px; border-radius: var(--r-sm);
  display: grid; place-items: center; flex-shrink: 0;
  background: var(--primary-soft); color: var(--primary-dark);
  border: 1px solid var(--primary-line);
}
.card-icon.blue { background: var(--blue-soft); color: var(--blue); border-color: var(--blue-line); }
.card-icon.amber { background: var(--amber-soft); color: var(--amber); border-color: var(--amber-line); }
.card-icon.rose { background: var(--rose-soft); color: var(--rose); border-color: var(--rose-line); }

.card-body { flex: 1; min-width: 0; }
.card-body h3 {
  font-size: 0.9rem; font-weight: 700; letter-spacing: -0.015em;
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}
.card-meta { display: flex; gap: 6px; margin-top: 7px; flex-wrap: wrap; }

.badge {
  display: inline-block;
  font-size: 0.66rem; font-weight: 700; letter-spacing: 0.015em;
  padding: 3px 8px; border-radius: var(--r-xs);
  background: var(--primary-soft); color: var(--primary-dark);
  border: 1px solid var(--primary-line);
  text-transform: uppercase;
}
.badge.blue { background: var(--blue-soft); color: var(--blue); border-color: var(--blue-line); }
.badge.amber { background: var(--amber-soft); color: var(--amber); border-color: var(--amber-line); }
.badge.rose { background: var(--rose-soft); color: var(--rose); border-color: var(--rose-line); }

.card-arrow { color: var(--text-subtle); flex-shrink: 0; transition: transform .2s var(--ease), color .15s; }
.card:hover .card-arrow { transform: translateX(3px); color: var(--primary-dark); }

/* ============ PAGE HEAD ============ */
.page-head {
  display: flex; align-items: center; gap: 14px;
  margin-bottom: 22px;
}
.back-btn {
  width: 40px; height: 40px; border-radius: var(--r-sm);
  background: var(--surface); border: 1px solid var(--border);
  display: grid; place-items: center; color: var(--text-2); flex-shrink: 0;
  transition: background .15s, border-color .15s, color .15s, transform .2s var(--ease-b);
}
.back-btn:hover { background: var(--primary-soft); border-color: var(--primary-line); color: var(--primary-dark); }
.back-btn:active { transform: scale(0.94); }
.page-title h1 { font-size: 1.75rem; font-weight: 800; letter-spacing: -0.035em; line-height: 1.15; }
.page-title p { font-size: 0.85rem; color: var(--text-muted); margin-top: 3px; font-weight: 500; }
@media (max-width: 640px) {
  .page-title h1 { font-size: 1.45rem; }
}

/* ============ DETAIL ============ */
.detail-header {
  padding: 28px;
  border-radius: var(--r-lg);
  background: linear-gradient(135deg, #064e3b 0%, #047857 55%, #059669 100%);
  color: white;
  border: 1px solid var(--primary-darker);
  margin-bottom: 20px;
  position: relative; overflow: hidden;
}
.detail-header::before {
  content: ''; position: absolute; top: -80px; right: -60px;
  width: 220px; height: 220px;
  background: radial-gradient(circle, rgba(52,211,153,0.35), transparent 70%);
  pointer-events: none;
}
.detail-header h1 {
  font-size: 1.55rem; font-weight: 800;
  letter-spacing: -0.03em; line-height: 1.2;
  position: relative;
}
.detail-header .badges {
  display: flex; gap: 6px; margin-top: 14px; flex-wrap: wrap; position: relative;
}
.detail-header .badge {
  background: rgba(255,255,255,0.14);
  border-color: rgba(255,255,255,0.22);
  color: white;
}
@media (max-width: 640px) {
  .detail-header { padding: 22px; }
  .detail-header h1 { font-size: 1.3rem; }
}

/* ============ BUTTONS ============ */
.btn {
  display: inline-flex; align-items: center; justify-content: center; gap: 8px;
  padding: 12px 20px; border-radius: var(--r-sm);
  background: var(--primary); color: white;
  font-weight: 700; font-size: 0.88rem; letter-spacing: -0.01em;
  border: 1px solid var(--primary-dark);
  transition: background .15s, border-color .15s, transform .2s var(--ease-b);
}
.btn:hover { background: var(--primary-dark); }
.btn:active { transform: scale(0.97); }
.btn.full { width: 100%; }

/* ============ PROSE ============ */
.prose {
  background: var(--surface);
  padding: 26px;
  border: 1px solid var(--border);
  border-radius: var(--r-lg);
  font-size: 0.95rem; line-height: 1.75; color: var(--text-2);
}
.prose h2 {
  font-size: 1.15rem; font-weight: 800; letter-spacing: -0.025em;
  margin: 24px 0 10px; color: var(--text);
  padding-bottom: 6px; border-bottom: 1px solid var(--border);
}
.prose h2:first-child { margin-top: 0; }
.prose h3 { font-size: 1rem; font-weight: 700; margin: 18px 0 8px; color: var(--text); }
.prose p { margin-bottom: 12px; }
.prose ul, .prose ol { padding-left: 22px; margin-bottom: 12px; }
.prose li { margin-bottom: 6px; }
.prose li::marker { color: var(--primary); }
.prose code {
  background: var(--primary-soft); color: var(--primary-darker);
  padding: 2px 6px; border-radius: var(--r-xs); font-size: 0.85em; font-weight: 600;
  border: 1px solid var(--primary-line);
}
.prose strong { font-weight: 700; color: var(--text); }
.prose table {
  width: 100%; border-collapse: collapse; margin: 14px 0;
  font-size: 0.86rem;
  border: 1px solid var(--border); border-radius: var(--r-sm); overflow: hidden;
}
.prose th { background: var(--surface-2); font-weight: 700; text-align: left; padding: 10px 12px; color: var(--text); border-bottom: 1px solid var(--border); }
.prose td { padding: 10px 12px; border-top: 1px solid var(--border); }
@media (max-width: 640px) { .prose { padding: 20px; } }

/* ============ QUIZ ============ */
.question {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--r);
  padding: 18px;
  margin-bottom: 12px;
  transition: border-color .18s;
}
.question:hover { border-color: var(--border-2); }
.question h4 {
  font-size: 0.95rem; font-weight: 700; margin-bottom: 14px;
  line-height: 1.5; letter-spacing: -0.015em;
  display: flex; gap: 10px; align-items: flex-start;
}
.q-num {
  display: inline-grid; place-items: center;
  min-width: 26px; height: 26px; padding: 0 7px;
  background: var(--primary-soft); color: var(--primary-darker);
  border: 1px solid var(--primary-line);
  border-radius: var(--r-xs); font-size: 0.72rem; font-weight: 800;
  flex-shrink: 0;
}
.options { display: flex; flex-direction: column; gap: 8px; }
.option {
  display: flex; align-items: center; gap: 10px;
  padding: 11px 14px; border-radius: var(--r-sm);
  background: var(--surface-2);
  border: 1px solid var(--border);
  font-size: 0.88rem; font-weight: 500;
  transition: background .15s, border-color .15s;
}
.option:hover { background: var(--primary-soft); border-color: var(--primary-line); }
.opt-key {
  display: inline-grid; place-items: center;
  width: 22px; height: 22px; border-radius: var(--r-xs);
  background: var(--surface); border: 1px solid var(--border);
  font-size: 0.7rem; font-weight: 800; color: var(--text-2);
  flex-shrink: 0;
}
details.answer { margin-top: 12px; }
details.answer summary {
  cursor: pointer; list-style: none;
  display: inline-flex; align-items: center; gap: 6px;
  padding: 8px 12px; border-radius: var(--r-xs);
  font-size: 0.82rem; font-weight: 700; color: var(--primary-dark);
  transition: background .15s;
  user-select: none;
}
details.answer summary:hover { background: var(--primary-soft); }
details.answer summary::-webkit-details-marker { display: none; }
details.answer summary::before {
  content: ''; width: 12px; height: 12px;
  background: currentColor;
  -webkit-mask: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='black' stroke-width='3' stroke-linecap='round' stroke-linejoin='round'><path d='m9 18 6-6-6-6'/></svg>") center/contain no-repeat;
          mask: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='black' stroke-width='3' stroke-linecap='round' stroke-linejoin='round'><path d='m9 18 6-6-6-6'/></svg>") center/contain no-repeat;
  transition: transform .22s var(--ease);
}
details.answer[open] summary::before { transform: rotate(90deg); }
details.answer .ans {
  margin-top: 10px; padding: 12px 14px;
  background: var(--primary-soft);
  border: 1px solid var(--primary-line);
  border-radius: var(--r-sm);
  font-size: 0.86rem; color: var(--primary-darker); font-weight: 700;
  display: flex; align-items: center; gap: 8px;
  animation: fadeIn .25s var(--ease) both;
}

/* ============ SEARCH PAGE ============ */
.search-hero {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--r-lg);
  padding: 22px;
  margin-bottom: 22px;
}
.search-bar-large {
  display: flex; align-items: center; gap: 12px;
  padding: 0 18px; height: 56px;
  background: var(--surface-2);
  border: 1px solid var(--border);
  border-radius: var(--r);
  color: var(--text-muted);
  transition: border-color .15s, background .15s;
}
.search-bar-large:focus-within {
  border-color: var(--primary);
  background: var(--surface);
}
.search-bar-large input {
  flex: 1; border: none; outline: none; background: transparent;
  font-size: 1rem; color: var(--text); min-width: 0;
}
.search-bar-large input::placeholder { color: var(--text-subtle); }
.search-bar-large .clear-btn {
  width: 28px; height: 28px; border-radius: var(--r-xs);
  background: transparent; border: none; color: var(--text-muted);
  display: grid; place-items: center;
  transition: background .15s, color .15s;
}
.search-bar-large .clear-btn:hover { background: var(--surface); color: var(--text); }

.search-status {
  margin-top: 14px; font-size: 0.82rem; color: var(--text-muted); font-weight: 600;
}

.result-card {
  display: flex; align-items: center; gap: 14px;
  padding: 14px 16px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--r);
  transition: border-color .18s, background .18s, transform .22s var(--ease-b);
}
.result-card:hover {
  border-color: var(--primary-line);
  background: var(--primary-soft);
  transform: translateY(-1px);
}
.result-type {
  font-size: 0.62rem; font-weight: 800; letter-spacing: 0.04em;
  padding: 4px 8px; border-radius: var(--r-xs);
  background: var(--surface-2); color: var(--text-2);
  border: 1px solid var(--border);
  text-transform: uppercase;
  flex-shrink: 0;
}
.result-type-note { background: var(--primary-soft); color: var(--primary-dark); border-color: var(--primary-line); }
.result-type-quiz { background: var(--blue-soft); color: var(--blue); border-color: var(--blue-line); }
.result-type-book { background: var(--amber-soft); color: var(--amber); border-color: var(--amber-line); }
.result-type-gazette { background: var(--rose-soft); color: var(--rose); border-color: var(--rose-line); }
.result-body { flex: 1; min-width: 0; }
.result-body h3 {
  font-size: 0.92rem; font-weight: 700; letter-spacing: -0.015em;
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}
.result-meta { display: flex; gap: 6px; margin-top: 7px; flex-wrap: wrap; }
.result-arrow { color: var(--text-subtle); flex-shrink: 0; transition: transform .2s var(--ease), color .15s; }
.result-card:hover .result-arrow { transform: translateX(3px); color: var(--primary-dark); }

/* ============ EMPTY ============ */
.empty-state {
  padding: 60px 20px; text-align: center;
  border: 1px dashed var(--border-2);
  border-radius: var(--r-lg);
  color: var(--text-muted); font-size: 0.9rem;
}
.empty-state strong { display: block; color: var(--text); font-size: 1rem; margin-bottom: 6px; font-weight: 700; }

/* ============ ANIMATIONS ============ */
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(10px); }
  to   { opacity: 1; transform: translateY(0); }
}
@keyframes fadeIn {
  from { opacity: 0; }
  to   { opacity: 1; }
}
.animate-in { animation: fadeUp .5s var(--ease) both; }

/* ============ RESPONSIVE NAV SWITCH ============ */
@media (min-width: 768px) {
  .bottom-nav { display: none; }
  .primary-nav { display: flex; }
  .header-search { display: flex; }
  .mobile-only { display: none !important; }
  .main { padding-bottom: 60px; }
}
@media (max-width: 767px) {
  .desktop-only { display: none !important; }
  .container { padding: 0 16px; }
}
EOF

# ============ LAYOUT ============
cat > src/layouts/BaseLayout.astro <<'EOF'
---
import '../styles/global.css';
import Icon from '../components/Icon.astro';

interface Props { title: string; description?: string; }
const { title, description = 'Free notes, quizzes, books, and result gazettes for Pakistani students.' } = Astro.props;

const path = Astro.url.pathname;
const navItems = [
  { href: '/',         label: 'Home',     icon: 'home' },
  { href: '/notes',    label: 'Notes',    icon: 'book-open' },
  { href: '/quizzes',  label: 'Quizzes',  icon: 'circle-help' },
  { href: '/books',    label: 'Books',    icon: 'library' },
  { href: '/gazettes', label: 'Gazettes', icon: 'newspaper' },
];
const isActive = (href: string) => href === '/' ? path === '/' : path.startsWith(href);
---
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
  <meta name="theme-color" content="#047857" />
  <title>{title}</title>
  <meta name="description" content={description} />
  <meta property="og:title" content={title} />
  <meta property="og:description" content={description} />
  <meta property="og:type" content="website" />
  <link rel="sitemap" href="/sitemap-index.xml" />
</head>
<body>
  <div class="shell">
    <header class="site-header">
      <div class="container header-inner">
        <a href="/" class="brand">
          <span class="brand-mark"><Icon name="graduation-cap" size={18} strokeWidth={2.4} /></span>
          <span class="brand-text">TaleemHub</span>
        </a>

        <nav class="primary-nav">
          {navItems.map(item => (
            <a href={item.href} class={isActive(item.href) ? 'active' : ''}>{item.label}</a>
          ))}
        </nav>

        <div class="header-spacer"></div>

        <form class="header-search" action="/search" method="get" role="search">
          <Icon name="search" size={16} strokeWidth={2.4} />
          <input type="search" name="q" placeholder="Search library..." aria-label="Search" />
          <kbd>/</kbd>
        </form>

        <a href="/search" class="header-action mobile-only" aria-label="Search">
          <Icon name="search" size={18} strokeWidth={2.4} />
        </a>
      </div>
    </header>

    <main class="main">
      <div class="container">
        <slot />
      </div>
    </main>
  </div>

  <nav class="bottom-nav">
    {navItems.map(item => (
      <a href={item.href} class={`nav-item ${isActive(item.href) ? 'active' : ''}`}>
        <Icon name={item.icon} size={20} strokeWidth={2.2} />
        <span>{item.label}</span>
      </a>
    ))}
  </nav>

  <script is:inline>
    (function () {
      document.addEventListener('keydown', function (e) {
        var t = e.target;
        var typing = t && (t.tagName === 'INPUT' || t.tagName === 'TEXTAREA' || t.isContentEditable);
        if (e.key === '/' && !typing) {
          var input = document.querySelector('.header-search input');
          if (input) { e.preventDefault(); input.focus(); }
        }
      });
    })();
  </script>
</body>
</html>
EOF

# ============ SEARCH INDEX ENDPOINT ============
cat > src/pages/search.json.ts <<'EOF'
export const prerender = true;
import { getCollection } from 'astro:content';

export async function GET() {
  const [notes, quizzes, books, gazettes] = await Promise.all([
    getCollection('notes'),
    getCollection('quizzes'),
    getCollection('books'),
    getCollection('gazettes'),
  ]);

  const index = [
    ...notes.map(n => ({
      type: 'note',
      title: n.data.title,
      url: `/notes/${n.id}`,
      subject: n.data.subject,
      class: n.data.class,
    })),
    ...quizzes.map(q => ({
      type: 'quiz',
      title: q.data.title,
      url: `/quizzes/${q.id}`,
      subject: q.data.subject,
      class: q.data.class,
    })),
    ...books.map(b => ({
      type: 'book',
      title: b.data.title,
      url: `/books/${b.id}`,
      subject: b.data.subject,
      class: b.data.class,
    })),
    ...gazettes.map(g => ({
      type: 'gazette',
      title: g.data.title,
      url: `/gazettes/${g.id}`,
      subject: g.data.board,
      class: g.data.class,
    })),
  ];

  return new Response(JSON.stringify(index), {
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
  });
}
EOF

# ============ SEARCH PAGE ============
cat > src/pages/search.astro <<'EOF'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
---
<BaseLayout title="Search — TaleemHub" description="Search notes, quizzes, textbooks and gazettes.">
  <div class="page-head">
    <div class="page-title">
      <h1>Search</h1>
      <p>Find anything across the library</p>
    </div>
  </div>

  <div class="search-hero">
    <div class="search-bar-large">
      <Icon name="search" size={20} strokeWidth={2.4} />
      <input
        id="search-input"
        type="search"
        placeholder="Search notes, quizzes, books, gazettes..."
        aria-label="Search library"
        autocomplete="off"
        autofocus
      />
      <button id="clear-btn" class="clear-btn" type="button" aria-label="Clear" style="display:none;">
        <Icon name="x" size={16} strokeWidth={2.4} />
      </button>
    </div>
    <div id="search-status" class="search-status">Loading library...</div>
  </div>

  <div id="search-results" class="list"></div>

  <script is:inline>
    (function () {
      var input = document.getElementById('search-input');
      var results = document.getElementById('search-results');
      var status = document.getElementById('search-status');
      var clearBtn = document.getElementById('clear-btn');
      var index = [];
      var ready = false;

      var params = new URLSearchParams(window.location.search);
      var initialQ = params.get('q') || '';
      if (initialQ) input.value = initialQ;

      function esc(s) {
        return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
          return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
        });
      }

      function typeLabel(t) {
        return { note: 'Note', quiz: 'Quiz', book: 'Book', gazette: 'Gazette' }[t] || t;
      }

      function render() {
        var q = input.value.trim().toLowerCase();
        clearBtn.style.display = input.value ? 'grid' : 'none';

        if (!ready) {
          status.textContent = 'Loading library...';
          results.innerHTML = '';
          return;
        }
        if (!q) {
          status.textContent = index.length + ' items in library';
          results.innerHTML = '';
          return;
        }

        var matches = index.filter(function (it) {
          var title = (it.title || '').toLowerCase();
          var subject = (it.subject || '').toLowerCase();
          var cls = String(it.class || '').toLowerCase();
          var type = (it.type || '').toLowerCase();
          return title.indexOf(q) !== -1 || subject.indexOf(q) !== -1
              || cls.indexOf(q) !== -1 || type.indexOf(q) !== -1;
        });

        status.textContent = matches.length + ' result' + (matches.length === 1 ? '' : 's');

        if (!matches.length) {
          results.innerHTML =
            '<div class="empty-state"><strong>No results found</strong>Try a different keyword, class number, or subject.</div>';
          return;
        }

        results.innerHTML = matches.map(function (m) {
          var badges = '';
          if (m.subject) badges += '<span class="badge">' + esc(m.subject) + '</span>';
          if (m.class)   badges += '<span class="badge blue">Class ' + esc(m.class) + '</span>';
          return '<a href="' + esc(m.url) + '" class="result-card">' +
            '<span class="result-type result-type-' + esc(m.type) + '">' + esc(typeLabel(m.type)) + '</span>' +
            '<div class="result-body">' +
              '<h3>' + esc(m.title) + '</h3>' +
              '<div class="result-meta">' + badges + '</div>' +
            '</div>' +
            '<svg class="result-arrow" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>' +
          '</a>';
        }).join('');
      }

      clearBtn.addEventListener('click', function () {
        input.value = '';
        input.focus();
        render();
      });

      input.addEventListener('input', render);

      fetch('/search.json')
        .then(function (r) { if (!r.ok) throw new Error('bad response'); return r.json(); })
        .then(function (data) { index = data; ready = true; render(); })
        .catch(function () {
          status.textContent = 'Could not load library.';
          results.innerHTML = '<div class="empty-state"><strong>Search unavailable</strong>Please refresh the page.</div>';
        });
    })();
  </script>
</BaseLayout>
EOF

# ============ HOME ============
cat > src/pages/index.astro <<'EOF'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import Icon from '../components/Icon.astro';
import { getCollection } from 'astro:content';

const notes = await getCollection('notes');
const quizzes = await getCollection('quizzes');
const books = await getCollection('books');
const gazettes = await getCollection('gazettes');

const categories = [
  { href: '/notes',    title: 'Notes',    count: notes.length,    icon: 'file-text',     cls: '' },
  { href: '/quizzes',  title: 'Quizzes',  count: quizzes.length,  icon: 'file-question', cls: 'blue' },
  { href: '/books',    title: 'Books',    count: books.length,    icon: 'book-marked',   cls: 'amber' },
  { href: '/gazettes', title: 'Gazettes', count: gazettes.length, icon: 'scroll-text',   cls: 'rose' },
];
const recent = [...notes].slice(0, 6);
---
<BaseLayout title="TaleemHub — Notes, Quizzes & Books for Pakistani Students">
  <section class="hero animate-in">
    <div class="hero-inner">
      <span class="hero-eyebrow"><Icon name="sparkles" size={13} strokeWidth={2.4} /> Free for every Pakistani student</span>
      <h1>Everything you need<br />to <em>study smarter</em>.</h1>
      <p class="lede">Notes, interactive quizzes, textbooks and result gazettes — all in one place, all for free.</p>

      <form class="hero-search" action="/search" method="get" role="search">
        <Icon name="search" size={18} strokeWidth={2.4} />
        <input type="search" name="q" placeholder="Search notes, books, past papers..." aria-label="Search" />
        <button type="submit">Search</button>
      </form>
    </div>
  </section>

  <section class="section animate-in">
    <div class="section-head"><h2>Browse library</h2></div>
    <div class="cat-grid">
      {categories.map(c => (
        <a href={c.href} class="cat-card">
          <div class={`cat-icon ${c.cls}`}><Icon name={c.icon} size={20} strokeWidth={2.2} /></div>
          <div>
            <div class="cat-title">{c.title}</div>
            <div class="cat-count">{c.count} {c.count === 1 ? 'item' : 'items'}</div>
          </div>
        </a>
      ))}
    </div>
  </section>

  <section class="section animate-in">
    <div class="section-head">
      <h2>Recent notes</h2>
      <a href="/notes" class="link">View all <Icon name="arrow-right" size={14} strokeWidth={2.6} /></a>
    </div>
    <div class="list">
      {recent.map(n => (
        <a href={`/notes/${n.id}`} class="card">
          <div class="card-icon"><Icon name="file-text" size={18} strokeWidth={2.2} /></div>
          <div class="card-body">
            <h3>{n.data.title}</h3>
            <div class="card-meta">
              <span class="badge">{n.data.subject}</span>
              <span class="badge blue">Class {n.data.class}</span>
            </div>
          </div>
          <Icon name="chevron-right" size={16} strokeWidth={2.4} class="card-arrow" />
        </a>
      ))}
    </div>
  </section>
</BaseLayout>
EOF

# ============ NOTES ============
cat > src/pages/notes/index.astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { getCollection } from 'astro:content';

const notes = (await getCollection('notes')).sort((a, b) => a.data.title.localeCompare(b.data.title));
---
<BaseLayout title="Notes — TaleemHub" description="Subject-wise notes for Pakistani students.">
  <div class="page-head">
    <div class="page-title">
      <h1>Notes</h1>
      <p>{notes.length} {notes.length === 1 ? 'note' : 'notes'} across all subjects</p>
    </div>
  </div>
  <div class="list">
    {notes.map(n => (
      <a href={`/notes/${n.id}`} class="card">
        <div class="card-icon"><Icon name="file-text" size={18} strokeWidth={2.2} /></div>
        <div class="card-body">
          <h3>{n.data.title}</h3>
          <div class="card-meta">
            <span class="badge">{n.data.subject}</span>
            <span class="badge blue">Class {n.data.class}</span>
            {n.data.board && <span class="badge amber">{n.data.board}</span>}
          </div>
        </div>
        <Icon name="chevron-right" size={16} strokeWidth={2.4} class="card-arrow" />
      </a>
    ))}
  </div>
</BaseLayout>
EOF

cat > src/pages/notes/[...slug].astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { getCollection, render } from 'astro:content';

export async function getStaticPaths() {
  const notes = await getCollection('notes');
  return notes.map(note => ({ params: { slug: note.id }, props: { note } }));
}
const { note } = Astro.props;
const { Content } = await render(note);
---
<BaseLayout title={`${note.data.title} — TaleemHub`} description={`${note.data.subject} notes for Class ${note.data.class}.`}>
  <div class="page-head">
    <a href="/notes" class="back-btn" aria-label="Back"><Icon name="arrow-left" size={18} strokeWidth={2.4} /></a>
    <div class="page-title"><h1>Note</h1><p>{note.data.subject} · Class {note.data.class}</p></div>
  </div>
  <div class="detail-header animate-in">
    <h1>{note.data.title}</h1>
    <div class="badges">
      <span class="badge">{note.data.subject}</span>
      <span class="badge">Class {note.data.class}</span>
      {note.data.board && <span class="badge">{note.data.board}</span>}
    </div>
  </div>
  {note.data.pdfUrl && (
    <a href={note.data.pdfUrl} class="btn full" style="margin-bottom:16px;">
      <Icon name="download" size={18} strokeWidth={2.4} /> Download PDF
    </a>
  )}
  <article class="prose animate-in"><Content /></article>
</BaseLayout>
EOF

# ============ QUIZZES ============
cat > src/pages/quizzes/index.astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { getCollection } from 'astro:content';

const quizzes = await getCollection('quizzes');
---
<BaseLayout title="Quizzes — TaleemHub" description="Practice MCQs for Pakistani students.">
  <div class="page-head">
    <div class="page-title">
      <h1>Quizzes</h1>
      <p>{quizzes.length} interactive MCQ {quizzes.length === 1 ? 'quiz' : 'quizzes'}</p>
    </div>
  </div>
  <div class="list">
    {quizzes.map(q => (
      <a href={`/quizzes/${q.id}`} class="card">
        <div class="card-icon blue"><Icon name="file-question" size={18} strokeWidth={2.2} /></div>
        <div class="card-body">
          <h3>{q.data.title}</h3>
          <div class="card-meta">
            <span class="badge blue">{q.data.subject}</span>
            <span class="badge">Class {q.data.class}</span>
            <span class="badge amber">{q.data.questions.length} MCQs</span>
          </div>
        </div>
        <Icon name="chevron-right" size={16} strokeWidth={2.4} class="card-arrow" />
      </a>
    ))}
  </div>
</BaseLayout>
EOF

cat > src/pages/quizzes/[...slug].astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { getCollection, render } from 'astro:content';

export async function getStaticPaths() {
  const quizzes = await getCollection('quizzes');
  return quizzes.map(quiz => ({ params: { slug: quiz.id }, props: { quiz } }));
}
const { quiz } = Astro.props;
const { Content } = await render(quiz);
---
<BaseLayout title={`${quiz.data.title} — TaleemHub`} description={`Practice MCQs for ${quiz.data.subject} Class ${quiz.data.class}.`}>
  <div class="page-head">
    <a href="/quizzes" class="back-btn" aria-label="Back"><Icon name="arrow-left" size={18} strokeWidth={2.4} /></a>
    <div class="page-title"><h1>Quiz</h1><p>{quiz.data.subject} · Class {quiz.data.class}</p></div>
  </div>
  <div class="detail-header animate-in">
    <h1>{quiz.data.title}</h1>
    <div class="badges">
      <span class="badge">{quiz.data.subject}</span>
      <span class="badge">Class {quiz.data.class}</span>
      <span class="badge">{quiz.data.questions.length} MCQs</span>
    </div>
  </div>
  {quiz.data.questions.map((q, i) => (
    <div class="question">
      <h4><span class="q-num">Q{i + 1}</span> <span>{q.question}</span></h4>
      <div class="options">
        {q.options.map((opt, j) => (
          <div class="option">
            <span class="opt-key">{String.fromCharCode(65 + j)}</span>
            <span>{opt}</span>
          </div>
        ))}
      </div>
      <details class="answer">
        <summary>Show answer</summary>
        <div class="ans"><Icon name="zap" size={15} strokeWidth={2.4} />{String.fromCharCode(65 + q.answer)}. {q.options[q.answer]}</div>
      </details>
    </div>
  ))}
  <article class="prose animate-in" style="margin-top:16px;"><Content /></article>
</BaseLayout>
EOF

# ============ BOOKS ============
cat > src/pages/books/index.astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { getCollection } from 'astro:content';

const books = await getCollection('books');
---
<BaseLayout title="Textbooks — TaleemHub" description="Free textbooks for Pakistani students.">
  <div class="page-head">
    <div class="page-title">
      <h1>Textbooks</h1>
      <p>{books.length} {books.length === 1 ? 'textbook' : 'textbooks'} ready to download</p>
    </div>
  </div>
  <div class="list">
    {books.map(b => (
      <a href={`/books/${b.id}`} class="card">
        <div class="card-icon amber"><Icon name="book-marked" size={18} strokeWidth={2.2} /></div>
        <div class="card-body">
          <h3>{b.data.title}</h3>
          <div class="card-meta">
            <span class="badge amber">{b.data.subject}</span>
            <span class="badge blue">Class {b.data.class}</span>
            {b.data.author && <span class="badge">{b.data.author}</span>}
          </div>
        </div>
        <Icon name="chevron-right" size={16} strokeWidth={2.4} class="card-arrow" />
      </a>
    ))}
  </div>
</BaseLayout>
EOF

cat > src/pages/books/[...slug].astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const books = await getCollection('books');
  return books.map(book => ({ params: { slug: book.id }, props: { book } }));
}
const { book } = Astro.props;
---
<BaseLayout title={`${book.data.title} — TaleemHub`} description={`Download ${book.data.title} PDF for Class ${book.data.class}.`}>
  <div class="page-head">
    <a href="/books" class="back-btn" aria-label="Back"><Icon name="arrow-left" size={18} strokeWidth={2.4} /></a>
    <div class="page-title"><h1>Textbook</h1><p>{book.data.subject} · Class {book.data.class}</p></div>
  </div>
  <div class="detail-header animate-in">
    <h1>{book.data.title}</h1>
    <div class="badges">
      <span class="badge">{book.data.subject}</span>
      <span class="badge">Class {book.data.class}</span>
      {book.data.author && <span class="badge">{book.data.author}</span>}
    </div>
  </div>
  <a href={book.data.pdfUrl} target="_blank" rel="noopener" class="btn full">
    <Icon name="download" size={18} strokeWidth={2.4} /> Download PDF
  </a>
</BaseLayout>
EOF

# ============ GAZETTES ============
cat > src/pages/gazettes/index.astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { getCollection } from 'astro:content';

const gazettes = await getCollection('gazettes');
---
<BaseLayout title="Result Gazettes — TaleemHub" description="Board result gazettes for Pakistani students.">
  <div class="page-head">
    <div class="page-title">
      <h1>Result Gazettes</h1>
      <p>{gazettes.length} {gazettes.length === 1 ? 'gazette' : 'gazettes'} from Pakistani boards</p>
    </div>
  </div>
  <div class="list">
    {gazettes.map(g => (
      <a href={`/gazettes/${g.id}`} class="card">
        <div class="card-icon rose"><Icon name="scroll-text" size={18} strokeWidth={2.2} /></div>
        <div class="card-body">
          <h3>{g.data.title}</h3>
          <div class="card-meta">
            <span class="badge rose">{g.data.board}</span>
            <span class="badge blue">Class {g.data.class}</span>
            <span class="badge amber">{g.data.year}</span>
          </div>
        </div>
        <Icon name="chevron-right" size={16} strokeWidth={2.4} class="card-arrow" />
      </a>
    ))}
  </div>
</BaseLayout>
EOF

cat > src/pages/gazettes/[...slug].astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const gazettes = await getCollection('gazettes');
  return gazettes.map(g => ({ params: { slug: g.id }, props: { gazette: g } }));
}
const { gazette } = Astro.props;
---
<BaseLayout title={`${gazette.data.title} — TaleemHub`} description={`${gazette.data.board} result gazette for Class ${gazette.data.class}, ${gazette.data.year}.`}>
  <div class="page-head">
    <a href="/gazettes" class="back-btn" aria-label="Back"><Icon name="arrow-left" size={18} strokeWidth={2.4} /></a>
    <div class="page-title"><h1>Gazette</h1><p>{gazette.data.board} · {gazette.data.year}</p></div>
  </div>
  <div class="detail-header animate-in">
    <h1>{gazette.data.title}</h1>
    <div class="badges">
      <span class="badge">{gazette.data.board}</span>
      <span class="badge">Class {gazette.data.class}</span>
      <span class="badge">{gazette.data.year}</span>
    </div>
  </div>
  <a href={gazette.data.pdfUrl} target="_blank" rel="noopener" class="btn full">
    <Icon name="download" size={18} strokeWidth={2.4} /> Download Gazette PDF
  </a>
</BaseLayout>
EOF

echo ""
echo "==================================================="
echo "  Web app rebuild complete"
echo "==================================================="
echo ""
echo "  Responsive shell:"
echo "    - Desktop: horizontal nav in header + inline search"
echo "    - Mobile:  bottom nav + search icon"
echo "    - Container max-width 1200px, grid lists on >=720px"
echo ""
echo "  Design:"
echo "    - Zero box-shadow (enforced with !important)"
echo "    - Hierarchy via 1px borders, tints and transforms"
echo "    - Lucide icons only, no emojis"
echo ""
echo "  Search:"
echo "    - /search.json endpoint (build-time index)"
echo "    - /search page with instant client-side filtering"
echo "    - Header + hero search submit to /search?q=..."
echo "    - Press / anywhere to focus header search"
echo ""
echo "Run:  npm run dev"
echo "Then open http://localhost:4321"