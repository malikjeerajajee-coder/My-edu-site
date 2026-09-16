#!/bin/bash
set -e

echo "🚀 Creating TaleemHub content & UI..."

# ============ DIRECTORIES ============
mkdir -p src/content/notes src/content/quizzes src/content/books src/content/gazettes
mkdir -p src/layouts src/pages/notes src/pages/quizzes src/pages/books src/pages/gazettes
mkdir -p src/styles public/pdfs

# ============ GLOBAL CSS ============
cat > src/styles/global.css <<'EOF'
* { margin: 0; padding: 0; box-sizing: border-box; }

:root {
  --primary: #059669;
  --primary-light: #10b981;
  --primary-dark: #047857;
  --primary-soft: #ecfdf5;
  --bg: #f1f5f9;
  --surface: #ffffff;
  --text: #0f172a;
  --text-muted: #64748b;
  --border: #e2e8f0;
  --radius: 16px;
  --radius-lg: 24px;
  --shadow-sm: 0 1px 2px rgba(15,23,42,0.04);
  --shadow: 0 2px 8px rgba(15,23,42,0.06);
}

html { -webkit-text-size-adjust: 100%; scroll-behavior: smooth; }
body {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  background: var(--bg);
  color: var(--text);
  line-height: 1.6;
  -webkit-font-smoothing: antialiased;
}
a { color: inherit; text-decoration: none; }
img { max-width: 100%; display: block; }

.app {
  max-width: 720px;
  margin: 0 auto;
  min-height: 100vh;
  padding-bottom: calc(88px + env(safe-area-inset-bottom));
  position: relative;
}

.app-header {
  position: sticky; top: 0; z-index: 50;
  background: rgba(241,245,249,0.85);
  backdrop-filter: saturate(180%) blur(20px);
  -webkit-backdrop-filter: saturate(180%) blur(20px);
  border-bottom: 1px solid var(--border);
  padding: 14px 20px;
  display: flex; align-items: center; justify-content: space-between;
}
.brand { display: flex; align-items: center; gap: 10px; font-weight: 800; font-size: 1.05rem; letter-spacing: -0.02em; }
.brand-logo {
  width: 36px; height: 36px; border-radius: 11px;
  background: linear-gradient(135deg, var(--primary), var(--primary-light));
  display: grid; place-items: center; font-size: 1rem;
  box-shadow: 0 4px 12px rgba(5,150,105,0.3);
}
.header-btn {
  width: 40px; height: 40px; border-radius: 12px;
  background: var(--surface); border: 1px solid var(--border);
  display: grid; place-items: center; cursor: pointer;
  color: var(--text-muted); transition: transform .15s;
}
.header-btn:active { transform: scale(0.94); }

.hero {
  margin: 16px 20px 0; padding: 24px;
  border-radius: var(--radius-lg);
  background: linear-gradient(135deg, #059669 0%, #10b981 55%, #34d399 100%);
  color: white; position: relative; overflow: hidden;
  box-shadow: 0 12px 32px rgba(5,150,105,0.28);
}
.hero::before {
  content: ''; position: absolute; top: -60px; right: -60px;
  width: 180px; height: 180px; border-radius: 50%;
  background: rgba(255,255,255,0.12);
}
.hero::after {
  content: ''; position: absolute; bottom: -80px; left: -40px;
  width: 160px; height: 160px; border-radius: 50%;
  background: rgba(255,255,255,0.08);
}
.hero-content { position: relative; z-index: 1; }
.hero h1 { font-size: 1.5rem; font-weight: 800; letter-spacing: -0.02em; line-height: 1.25; }
.hero p { font-size: 0.9rem; opacity: 0.92; margin-top: 6px; }

.search {
  margin-top: 16px; display: flex; align-items: center; gap: 10px;
  background: rgba(255,255,255,0.95); border-radius: 14px;
  padding: 12px 14px; color: var(--text-muted);
}
.search input {
  flex: 1; border: none; outline: none; background: transparent;
  font-size: 0.9rem; color: var(--text); font-family: inherit;
}

.section { padding: 24px 20px 0; }
.section-head { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.section-head h2 { font-size: 1.05rem; font-weight: 800; letter-spacing: -0.02em; }
.section-head a { font-size: 0.8rem; color: var(--primary); font-weight: 700; }

.cat-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 12px; }
.cat-card {
  background: var(--surface); border-radius: var(--radius);
  padding: 18px; border: 1px solid var(--border);
  box-shadow: var(--shadow-sm);
  transition: transform .15s, box-shadow .15s;
  display: flex; flex-direction: column; gap: 10px;
}
.cat-card:active { transform: scale(0.97); box-shadow: var(--shadow); }
.cat-icon {
  width: 44px; height: 44px; border-radius: 13px;
  display: grid; place-items: center; font-size: 1.25rem;
}
.cat-icon.notes { background: #ecfdf5; }
.cat-icon.quizzes { background: #eff6ff; }
.cat-icon.books { background: #fef3c7; }
.cat-icon.gazettes { background: #fce7f3; }
.cat-card h3 { font-size: 0.95rem; font-weight: 800; letter-spacing: -0.01em; }
.cat-card span { font-size: 0.75rem; color: var(--text-muted); font-weight: 500; }

.list { display: flex; flex-direction: column; gap: 10px; }
.card {
  background: var(--surface); border-radius: var(--radius);
  border: 1px solid var(--border); padding: 16px;
  display: flex; align-items: center; gap: 14px;
  box-shadow: var(--shadow-sm);
  transition: transform .15s, box-shadow .15s;
}
.card:active { transform: scale(0.99); box-shadow: var(--shadow); }
.card-body { flex: 1; min-width: 0; }
.card-body h3 {
  font-size: 0.92rem; font-weight: 700; letter-spacing: -0.01em;
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}
.card-meta { display: flex; gap: 6px; margin-top: 6px; flex-wrap: wrap; }
.badge {
  font-size: 0.68rem; font-weight: 700;
  padding: 3px 8px; border-radius: 6px;
  background: var(--primary-soft); color: var(--primary-dark);
}
.badge.blue { background: #eff6ff; color: #1d4ed8; }
.badge.amber { background: #fef3c7; color: #b45309; }
.badge.pink { background: #fce7f3; color: #be185d; }

.card-icon {
  width: 46px; height: 46px; border-radius: 13px;
  background: var(--primary-soft); color: var(--primary);
  display: grid; place-items: center; font-size: 1.2rem; flex-shrink: 0;
}

.bottom-nav {
  position: fixed; bottom: 0; left: 0; right: 0; z-index: 100;
  background: rgba(255,255,255,0.92);
  backdrop-filter: saturate(180%) blur(20px);
  -webkit-backdrop-filter: saturate(180%) blur(20px);
  border-top: 1px solid var(--border);
  padding: 8px 0 calc(8px + env(safe-area-inset-bottom));
  display: flex; justify-content: space-around;
  max-width: 720px; margin: 0 auto;
}
.nav-item {
  display: flex; flex-direction: column; align-items: center; gap: 3px;
  padding: 6px 12px; color: var(--text-muted);
  font-size: 0.65rem; font-weight: 700;
  transition: color .15s; border-radius: 10px; min-width: 56px;
}
.nav-item svg { width: 22px; height: 22px; }
.nav-item.active { color: var(--primary); }
.nav-item.active svg { filter: drop-shadow(0 2px 6px rgba(5,150,105,0.35)); }

.detail { padding: 20px; }
.detail-header {
  background: linear-gradient(135deg, #059669, #10b981);
  color: white; padding: 24px;
  border-radius: var(--radius-lg); margin-bottom: 20px;
  box-shadow: 0 12px 32px rgba(5,150,105,0.25);
  position: relative; overflow: hidden;
}
.detail-header::before {
  content: ''; position: absolute; top: -50px; right: -50px;
  width: 140px; height: 140px; border-radius: 50%;
  background: rgba(255,255,255,0.1);
}
.detail-header h1 { font-size: 1.35rem; font-weight: 800; letter-spacing: -0.02em; position: relative; }
.detail-header .badges { display: flex; gap: 6px; margin-top: 12px; flex-wrap: wrap; position: relative; }
.detail-header .badge { background: rgba(255,255,255,0.22); color: white; }

.prose {
  background: var(--surface); padding: 20px;
  border-radius: var(--radius); border: 1px solid var(--border);
  box-shadow: var(--shadow-sm); font-size: 0.94rem; line-height: 1.75;
}
.prose h2 { font-size: 1.1rem; margin: 20px 0 10px; font-weight: 800; letter-spacing: -0.01em; }
.prose h3 { font-size: 1rem; margin: 16px 0 8px; font-weight: 700; }
.prose p { margin-bottom: 12px; }
.prose ul, .prose ol { padding-left: 20px; margin-bottom: 12px; }
.prose li { margin-bottom: 6px; }
.prose code { background: var(--bg); padding: 2px 6px; border-radius: 6px; font-size: 0.85em; }
.prose strong { font-weight: 700; }

.btn {
  display: inline-flex; align-items: center; gap: 8px;
  padding: 13px 20px; border-radius: 13px;
  background: var(--primary); color: white;
  font-weight: 700; font-size: 0.9rem; border: none; cursor: pointer;
  box-shadow: 0 4px 14px rgba(5,150,105,0.3);
  transition: transform .15s;
}
.btn:active { transform: scale(0.97); }
.btn.full { width: 100%; justify-content: center; }

.question {
  background: var(--surface); border: 1px solid var(--border);
  border-radius: var(--radius); padding: 16px; margin-bottom: 12px;
  box-shadow: var(--shadow-sm);
}
.question h4 { font-size: 0.95rem; margin-bottom: 12px; font-weight: 700; line-height: 1.5; }
.options { display: flex; flex-direction: column; gap: 8px; }
.option {
  padding: 11px 14px; border-radius: 10px;
  background: var(--bg); font-size: 0.88rem;
  border: 1px solid transparent;
}
details.answer { margin-top: 12px; }
details.answer summary {
  cursor: pointer; font-size: 0.82rem; font-weight: 700;
  color: var(--primary); list-style: none;
}
details.answer summary::-webkit-details-marker { display: none; }
details.answer[open] summary { margin-bottom: 8px; }
details.answer .ans {
  padding: 10px 14px; background: var(--primary-soft);
  border-radius: 10px; font-size: 0.85rem;
  color: var(--primary-dark); font-weight: 700;
}

.page-title { padding: 24px 20px 4px; }
.page-title h1 { font-size: 1.7rem; font-weight: 800; letter-spacing: -0.03em; }
.page-title p { font-size: 0.85rem; color: var(--text-muted); margin-top: 4px; font-weight: 500; }

@media (min-width: 640px) {
  .cat-grid { grid-template-columns: repeat(4, 1fr); }
}
EOF

# ============ LAYOUT ============
cat > src/layouts/BaseLayout.astro <<'EOF'
---
import '../styles/global.css';

interface Props {
  title: string;
  description?: string;
}

const {
  title,
  description = 'Free notes, quizzes, books, and result gazettes for Pakistani students.',
} = Astro.props;

const path = Astro.url.pathname;

const navItems = [
  { href: '/', label: 'Home', path: '<path d="M3 10.5 12 3l9 7.5V21a1 1 0 0 1-1 1h-5v-7h-6v7H4a1 1 0 0 1-1-1V10.5z"/>' },
  { href: '/notes', label: 'Notes', path: '<path d="M6 2h9l5 5v13a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2z"/><path d="M14 2v6h6"/>' },
  { href: '/quizzes', label: 'Quizzes', path: '<circle cx="12" cy="12" r="9"/><path d="M9.5 9a2.5 2.5 0 1 1 3.5 2.3c-.8.4-1 .9-1 1.7"/><circle cx="12" cy="17" r="1"/>' },
  { href: '/books', label: 'Books', path: '<path d="M4 4a2 2 0 0 1 2-2h12v18H6a2 2 0 0 0-2 2V4z"/><path d="M8 7h8M8 11h8"/>' },
  { href: '/gazettes', label: 'Gazettes', path: '<rect x="3" y="4" width="18" height="16" rx="2"/><path d="M7 8h10M7 12h10M7 16h6"/>' },
];
---
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
  <meta name="theme-color" content="#059669" />
  <title>{title}</title>
  <meta name="description" content={description} />
  <meta property="og:title" content={title} />
  <meta property="og:description" content={description} />
  <meta property="og:type" content="website" />
  <link rel="sitemap" href="/sitemap-index.xml" />
</head>
<body>
  <div class="app">
    <header class="app-header">
      <a href="/" class="brand">
        <span class="brand-logo">🎓</span>
        <span>TaleemHub</span>
      </a>
      <button class="header-btn" aria-label="Search">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>
      </button>
    </header>

    <main>
      <slot />
    </main>

    <nav class="bottom-nav">
      {navItems.map(item => {
        const active = item.href === '/' ? path === '/' : path.startsWith(item.href);
        return (
          <a href={item.href} class={`nav-item ${active ? 'active' : ''}`}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" set:html={item.path} />
            <span>{item.label}</span>
          </a>
        );
      })}
    </nav>
  </div>
</body>
</html>
EOF

# ============ HOME ============
cat > src/pages/index.astro <<'EOF'
---
import BaseLayout from '../layouts/BaseLayout.astro';
import { getCollection } from 'astro:content';

const notes = await getCollection('notes');
const quizzes = await getCollection('quizzes');
const books = await getCollection('books');
const gazettes = await getCollection('gazettes');

const categories = [
  { href: '/notes', title: 'Notes', count: notes.length, icon: '📝', cls: 'notes' },
  { href: '/quizzes', title: 'Quizzes', count: quizzes.length, icon: '❓', cls: 'quizzes' },
  { href: '/books', title: 'Books', count: books.length, icon: '📚', cls: 'books' },
  { href: '/gazettes', title: 'Gazettes', count: gazettes.length, icon: '📰', cls: 'gazettes' },
];

const recent = [...notes].slice(0, 4);
---
<BaseLayout title="TaleemHub — Notes, Quizzes & Books for Pakistani Students">
  <section class="hero">
    <div class="hero-content">
      <h1>Assalam-o-Alaikum 👋</h1>
      <p>Your study companion for notes, quizzes, books & gazettes.</p>
      <div class="search">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>
        <input type="text" placeholder="Search notes, books, past papers..." />
      </div>
    </div>
  </section>

  <section class="section">
    <div class="section-head"><h2>Browse</h2></div>
    <div class="cat-grid">
      {categories.map(c => (
        <a href={c.href} class="cat-card">
          <div class={`cat-icon ${c.cls}`}>{c.icon}</div>
          <div>
            <h3>{c.title}</h3>
            <span>{c.count} items</span>
          </div>
        </a>
      ))}
    </div>
  </section>

  <section class="section">
    <div class="section-head">
      <h2>Recent Notes</h2>
      <a href="/notes">See all</a>
    </div>
    <div class="list">
      {recent.map(n => (
        <a href={`/notes/${n.id}`} class="card">
          <div class="card-icon">📝</div>
          <div class="card-body">
            <h3>{n.data.title}</h3>
            <div class="card-meta">
              <span class="badge">{n.data.subject}</span>
              <span class="badge blue">Class {n.data.class}</span>
            </div>
          </div>
        </a>
      ))}
    </div>
  </section>
</BaseLayout>
EOF

# ============ NOTES PAGES ============
cat > src/pages/notes/index.astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import { getCollection } from 'astro:content';

const notes = (await getCollection('notes')).sort((a, b) => a.data.title.localeCompare(b.data.title));
---
<BaseLayout title="Notes — TaleemHub" description="Subject-wise notes for Pakistani students.">
  <div class="page-title">
    <h1>Notes</h1>
    <p>{notes.length} notes across subjects and classes</p>
  </div>
  <section class="section">
    <div class="list">
      {notes.map(n => (
        <a href={`/notes/${n.id}`} class="card">
          <div class="card-icon">📝</div>
          <div class="card-body">
            <h3>{n.data.title}</h3>
            <div class="card-meta">
              <span class="badge">{n.data.subject}</span>
              <span class="badge blue">Class {n.data.class}</span>
              {n.data.board && <span class="badge amber">{n.data.board}</span>}
            </div>
          </div>
        </a>
      ))}
    </div>
  </section>
</BaseLayout>
EOF

cat > src/pages/notes/[...slug].astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import { getCollection, render } from 'astro:content';

export async function getStaticPaths() {
  const notes = await getCollection('notes');
  return notes.map(note => ({ params: { slug: note.id }, props: { note } }));
}

const { note } = Astro.props;
const { Content } = await render(note);
---
<BaseLayout title={`${note.data.title} — TaleemHub`} description={`${note.data.subject} notes for Class ${note.data.class}.`}>
  <div class="detail">
    <div class="detail-header">
      <h1>{note.data.title}</h1>
      <div class="badges">
        <span class="badge">{note.data.subject}</span>
        <span class="badge">Class {note.data.class}</span>
        {note.data.board && <span class="badge">{note.data.board}</span>}
      </div>
    </div>
    {note.data.pdfUrl && (
      <a href={note.data.pdfUrl} class="btn full" style="margin-bottom:20px;">📄 Download PDF</a>
    )}
    <article class="prose">
      <Content />
    </article>
  </div>
</BaseLayout>
EOF

# ============ QUIZZES PAGES ============
cat > src/pages/quizzes/index.astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import { getCollection } from 'astro:content';

const quizzes = await getCollection('quizzes');
---
<BaseLayout title="Quizzes — TaleemHub" description="Practice MCQs for Pakistani students.">
  <div class="page-title">
    <h1>Quizzes</h1>
    <p>{quizzes.length} interactive MCQ quizzes</p>
  </div>
  <section class="section">
    <div class="list">
      {quizzes.map(q => (
        <a href={`/quizzes/${q.id}`} class="card">
          <div class="card-icon">❓</div>
          <div class="card-body">
            <h3>{q.data.title}</h3>
            <div class="card-meta">
              <span class="badge">{q.data.subject}</span>
              <span class="badge blue">Class {q.data.class}</span>
              <span class="badge amber">{q.data.questions.length} MCQs</span>
            </div>
          </div>
        </a>
      ))}
    </div>
  </section>
</BaseLayout>
EOF

cat > src/pages/quizzes/[...slug].astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import { getCollection, render } from 'astro:content';

export async function getStaticPaths() {
  const quizzes = await getCollection('quizzes');
  return quizzes.map(quiz => ({ params: { slug: quiz.id }, props: { quiz } }));
}

const { quiz } = Astro.props;
const { Content } = await render(quiz);
---
<BaseLayout title={`${quiz.data.title} — TaleemHub`} description={`Practice MCQs for ${quiz.data.subject} Class ${quiz.data.class}.`}>
  <div class="detail">
    <div class="detail-header">
      <h1>{quiz.data.title}</h1>
      <div class="badges">
        <span class="badge">{quiz.data.subject}</span>
        <span class="badge">Class {quiz.data.class}</span>
        <span class="badge">{quiz.data.questions.length} MCQs</span>
      </div>
    </div>
    {quiz.data.questions.map((q, i) => (
      <div class="question">
        <h4>Q{i + 1}. {q.question}</h4>
        <div class="options">
          {q.options.map((opt, j) => (
            <div class="option">{String.fromCharCode(65 + j)}. {opt}</div>
          ))}
        </div>
        <details class="answer">
          <summary>Show Answer →</summary>
          <div class="ans">✅ Correct: {String.fromCharCode(65 + q.answer)}. {q.options[q.answer]}</div>
        </details>
      </div>
    ))}
    <article class="prose" style="margin-top:20px;">
      <Content />
    </article>
  </div>
</BaseLayout>
EOF

# ============ BOOKS PAGES ============
cat > src/pages/books/index.astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import { getCollection } from 'astro:content';

const books = await getCollection('books');
---
<BaseLayout title="Textbooks — TaleemHub" description="Free textbooks for Pakistani students.">
  <div class="page-title">
    <h1>Textbooks</h1>
    <p>{books.length} textbooks available for download</p>
  </div>
  <section class="section">
    <div class="list">
      {books.map(b => (
        <a href={`/books/${b.id}`} class="card">
          <div class="card-icon">📚</div>
          <div class="card-body">
            <h3>{b.data.title}</h3>
            <div class="card-meta">
              <span class="badge">{b.data.subject}</span>
              <span class="badge blue">Class {b.data.class}</span>
              {b.data.author && <span class="badge amber">{b.data.author}</span>}
            </div>
          </div>
        </a>
      ))}
    </div>
  </section>
</BaseLayout>
EOF

cat > src/pages/books/[...slug].astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const books = await getCollection('books');
  return books.map(book => ({ params: { slug: book.id }, props: { book } }));
}

const { book } = Astro.props;
---
<BaseLayout title={`${book.data.title} — TaleemHub`} description={`Download ${book.data.title} PDF for Class ${book.data.class}.`}>
  <div class="detail">
    <div class="detail-header">
      <h1>{book.data.title}</h1>
      <div class="badges">
        <span class="badge">{book.data.subject}</span>
        <span class="badge">Class {book.data.class}</span>
        {book.data.author && <span class="badge">{book.data.author}</span>}
      </div>
    </div>
    <a href={book.data.pdfUrl} target="_blank" rel="noopener" class="btn full">📥 Download PDF</a>
  </div>
</BaseLayout>
EOF

# ============ GAZETTES PAGES ============
cat > src/pages/gazettes/index.astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import { getCollection } from 'astro:content';

const gazettes = await getCollection('gazettes');
---
<BaseLayout title="Result Gazettes — TaleemHub" description="Board result gazettes for Pakistani students.">
  <div class="page-title">
    <h1>Result Gazettes</h1>
    <p>{gazettes.length} gazettes from Pakistani boards</p>
  </div>
  <section class="section">
    <div class="list">
      {gazettes.map(g => (
        <a href={`/gazettes/${g.id}`} class="card">
          <div class="card-icon">📰</div>
          <div class="card-body">
            <h3>{g.data.title}</h3>
            <div class="card-meta">
              <span class="badge pink">{g.data.board}</span>
              <span class="badge blue">Class {g.data.class}</span>
              <span class="badge amber">{g.data.year}</span>
            </div>
          </div>
        </a>
      ))}
    </div>
  </section>
</BaseLayout>
EOF

cat > src/pages/gazettes/[...slug].astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const gazettes = await getCollection('gazettes');
  return gazettes.map(g => ({ params: { slug: g.id }, props: { gazette: g } }));
}

const { gazette } = Astro.props;
---
<BaseLayout title={`${gazette.data.title} — TaleemHub`} description={`${gazette.data.board} result gazette for Class ${gazette.data.class}, ${gazette.data.year}.`}>
  <div class="detail">
    <div class="detail-header">
      <h1>{gazette.data.title}</h1>
      <div class="badges">
        <span class="badge">{gazette.data.board}</span>
        <span class="badge">Class {gazette.data.class}</span>
        <span class="badge">{gazette.data.year}</span>
      </div>
    </div>
    <a href={gazette.data.pdfUrl} target="_blank" rel="noopener" class="btn full">📥 Download Gazette PDF</a>
  </div>
</BaseLayout>
EOF

# ============ CONTENT: NOTES ============
cat > src/content/notes/math-10-ch1.md <<'EOF'
---
title: "Math — Chapter 1: Quadratic Equations"
subject: "Mathematics"
class: "10"
board: "Punjab"
pdfUrl: "/pdfs/math-10-ch1.pdf"
date: 2026-01-15
---

## Introduction

A **quadratic equation** is a second-degree polynomial equation in a single variable, written in the standard form:

**ax² + bx + c = 0**, where a ≠ 0.

## Key Concepts

### 1. Methods of Solving
- **Factorization** — quick when roots are integers.
- **Completing the Square** — useful for deriving the quadratic formula.
- **Quadratic Formula** — works for all equations:
  x = (-b ± √(b² - 4ac)) / 2a

### 2. Discriminant (D = b² - 4ac)
- D > 0 → two distinct real roots
- D = 0 → two equal real roots
- D < 0 → no real roots (complex roots)

## Worked Example

Solve: **x² - 5x + 6 = 0**

Using factorization: (x - 2)(x - 3) = 0 → **x = 2 or x = 3**

## Important Formulas
- Sum of roots = -b/a
- Product of roots = c/a
EOF

cat > src/content/notes/physics-9-ch1.md <<'EOF'
---
title: "Physics — Chapter 1: Physical Quantities & Measurement"
subject: "Physics"
class: "9"
board: "Federal"
pdfUrl: "/pdfs/physics-9-ch1.pdf"
date: 2026-01-15
---

## What Are Physical Quantities?

A **physical quantity** is anything that can be measured. Examples: length, mass, time, temperature, current.

## Base vs Derived Quantities

| Type | Example | Unit |
|------|---------|------|
| Base | Length | metre (m) |
| Base | Mass | kilogram (kg) |
| Base | Time | second (s) |
| Derived | Speed | m/s |
| Derived | Force | newton (N) |

## Prefixes You Must Know
- **kilo (k)** = 10³
- **mega (M)** = 10⁶
- **milli (m)** = 10⁻³
- **micro (µ)** = 10⁻⁶

## Scientific Notation

Numbers are written as **N × 10ⁿ** where 1 ≤ N < 10.
Example: 384,000,000 m = **3.84 × 10⁸ m**

## Measuring Instruments
- **Vernier Callipers** — least count 0.01 cm
- **Screw Gauge** — least count 0.001 cm
- **Physical Balance** — measures mass
EOF

cat > src/content/notes/chemistry-10-ch1.md <<'EOF'
---
title: "Chemistry — Chapter 1: Chemical Equilibrium"
subject: "Chemistry"
class: "10"
board: "Punjab"
pdfUrl: "/pdfs/chemistry-10-ch1.pdf"
date: 2026-01-15
---

## Reversible Reactions

A **reversible reaction** can proceed in both forward and backward directions. It reaches **dynamic equilibrium** when the rate of the forward reaction equals the rate of the reverse reaction.

## Law of Mass Action

For a general reaction:
**aA + bB ⇌ cC + dD**

The equilibrium constant is:
**Kc = [C]ᶜ [D]ᵈ / [A]ᵃ [B]ᵇ**

## Le Chatelier's Principle

If a system at equilibrium is disturbed, the system shifts to counteract the disturbance.

- **Increase pressure** → shifts to side with fewer moles of gas
- **Increase temperature** → shifts in endothermic direction
- **Add reactant** → shifts forward

## Industrial Applications
- **Haber Process** — synthesis of ammonia (N₂ + 3H₂ ⇌ 2NH₃)
- **Contact Process** — synthesis of sulfuric acid
EOF

cat > src/content/notes/biology-11-ch1.md <<'EOF'
---
title: "Biology — Chapter 1: Cell Biology"
subject: "Biology"
class: "11"
board: "Federal"
pdfUrl: "/pdfs/biology-11-ch1.pdf"
date: 2026-01-15
---

## The Cell — Basic Unit of Life

The **cell** is the smallest structural and functional unit of living organisms. Discovered by **Robert Hooke** in 1665.

## Cell Theory
1. All living things are made of cells.
2. The cell is the basic unit of life.
3. All cells come from pre-existing cells.

## Prokaryotic vs Eukaryotic

| Feature | Prokaryotic | Eukaryotic |
|---------|-------------|------------|
| Nucleus | Absent | Present |
| Size | 1–10 µm | 10–100 µm |
| Example | Bacteria | Plant/Animal |

## Key Organelles
- **Mitochondria** — powerhouse, ATP production
- **Ribosomes** — protein synthesis
- **Chloroplast** — photosynthesis (plants only)
- **Golgi apparatus** — packaging & secretion
EOF

cat > src/content/notes/english-9-essays.md <<'EOF'
---
title: "English — Important Essays for Class 9"
subject: "English"
class: "9"
board: "All Boards"
pdfUrl: "/pdfs/english-9-essays.pdf"
date: 2026-01-15
---

## 1. My Country Pakistan

Pakistan came into being on **14 August 1947** after the untiring efforts of Quaid-e-Azam Muhammad Ali Jinnah. It is rich in culture, natural resources, and brave people. We must work together to make it prosperous.

## 2. The Role of Students in Nation Building

Students are the future of any nation. They must focus on education, develop good character, and participate in constructive activities. A disciplined student body can bring positive change.

## 3. Importance of Education

Education is the key to success. It enlightens minds, creates awareness, and empowers people. An educated nation can progress in every field — science, technology, economy, and defence.

## 4. Sports and Their Importance

Sports keep us healthy, teach teamwork, and build discipline. Cricket, hockey, and football are popular in Pakistan. Every student should play at least one sport regularly.

## 5. My Ambition in Life

Having a clear ambition gives direction. I want to become a **[doctor/engineer/teacher]** to serve my country. I will work hard, stay focused, and achieve my goal.
EOF

# ============ CONTENT: QUIZZES ============
cat > src/content/quizzes/math-10-ch1-quiz.md <<'EOF'
---
title: "Math Class 10 — Chapter 1 Quiz"
subject: "Mathematics"
class: "10"
questions:
  - question: "What is the standard form of a quadratic equation?"
    options:
      - "ax + b = 0"
      - "ax² + bx + c = 0"
      - "ax³ + bx² + c = 0"
      - "a/x + b = 0"
    answer: 1
  - question: "The discriminant of a quadratic equation is given by:"
    options:
      - "b² + 4ac"
      - "b² - 4ac"
      - "4ac - b²"
      - "2a + b"
    answer: 1
  - question: "If D = 0, the roots are:"
    options:
      - "Distinct real"
      - "Equal real"
      - "Imaginary"
      - "Undefined"
    answer: 1
  - question: "Sum of roots of ax² + bx + c = 0 is:"
    options:
      - "c/a"
      - "-b/a"
      - "b/a"
      - "-c/a"
    answer: 1
  - question: "Solve x² - 5x + 6 = 0. The roots are:"
    options:
      - "1 and 6"
      - "2 and 3"
      - "-2 and -3"
      - "0 and 6"
    answer: 1
---

Practice these MCQs to master quadratic equations for your board exam.
EOF

cat > src/content/quizzes/physics-9-ch1-quiz.md <<'EOF'
---
title: "Physics Class 9 — Chapter 1 Quiz"
subject: "Physics"
class: "9"
questions:
  - question: "Which of the following is a base quantity?"
    options:
      - "Speed"
      - "Force"
      - "Length"
      - "Pressure"
    answer: 2
  - question: "The least count of a Vernier Callipers is:"
    options:
      - "0.1 cm"
      - "0.01 cm"
      - "0.001 cm"
      - "1 cm"
    answer: 1
  - question: "1 kilometre equals:"
    options:
      - "10 metres"
      - "100 metres"
      - "1000 metres"
      - "10000 metres"
    answer: 2
  - question: "The SI unit of force is:"
    options:
      - "joule"
      - "newton"
      - "watt"
      - "pascal"
    answer: 1
---

Test your understanding of base quantities and measurement tools.
EOF

cat > src/content/quizzes/chemistry-10-ch1-quiz.md <<'EOF'
---
title: "Chemistry Class 10 — Chemical Equilibrium Quiz"
subject: "Chemistry"
class: "10"
questions:
  - question: "At equilibrium, the rate of forward reaction is:"
    options:
      - "Greater than reverse"
      - "Less than reverse"
      - "Equal to reverse"
      - "Zero"
    answer: 2
  - question: "Le Chatelier's Principle applies to:"
    options:
      - "Only irreversible reactions"
      - "Systems at equilibrium"
      - "Only gas reactions"
      - "Nuclear reactions"
    answer: 1
  - question: "In the Haber process, ammonia is formed from:"
    options:
      - "N₂ + O₂"
      - "N₂ + H₂"
      - "NO + H₂"
      - "NH₄ + H₂"
    answer: 1
  - question: "Increasing pressure shifts equilibrium towards:"
    options:
      - "Side with more gas moles"
      - "Side with fewer gas moles"
      - "No change"
      - "Always forward"
    answer: 1
---

Master the concept of dynamic equilibrium and Le Chatelier's Principle.
EOF

# ============ CONTENT: BOOKS (JSON) ============
cat > src/content/books/physics-9.json <<'EOF'
{
  "title": "Physics Textbook for Class 9",
  "author": "Punjab Textbook Board",
  "class": "9",
  "subject": "Physics",
  "pdfUrl": "/pdfs/physics-9-textbook.pdf"
}
EOF

cat > src/content/books/math-10.json <<'EOF'
{
  "title": "Mathematics Textbook for Class 10",
  "author": "Punjab Textbook Board",
  "class": "10",
  "subject": "Mathematics",
  "pdfUrl": "/pdfs/math-10-textbook.pdf"
}
EOF

cat > src/content/books/chemistry-10.json <<'EOF'
{
  "title": "Chemistry Textbook for Class 10",
  "author": "Federal Board",
  "class": "10",
  "subject": "Chemistry",
  "pdfUrl": "/pdfs/chemistry-10-textbook.pdf"
}
EOF

cat > src/content/books/biology-11.json <<'EOF'
{
  "title": "Biology Textbook for Class 11",
  "author": "KPK Textbook Board",
  "class": "11",
  "subject": "Biology",
  "pdfUrl": "/pdfs/biology-11-textbook.pdf"
}
EOF

# ============ CONTENT: GAZETTES (JSON) ============
cat > src/content/gazettes/bise-lahore-10-2025.json <<'EOF'
{
  "title": "BISE Lahore Class 10 Result Gazette 2025",
  "year": 2025,
  "board": "BISE Lahore",
  "class": "10",
  "pdfUrl": "/pdfs/bise-lahore-10-2025.pdf"
}
EOF

cat > src/content/gazettes/bise-karachi-9-2024.json <<'EOF'
{
  "title": "BISE Karachi Class 9 Result Gazette 2024",
  "year": 2024,
  "board": "BISE Karachi",
  "class": "9",
  "pdfUrl": "/pdfs/bise-karachi-9-2024.pdf"
}
EOF

cat > src/content/gazettes/bise-rawalpindi-10-2024.json <<'EOF'
{
  "title": "BISE Rawalpindi Class 10 Result Gazette 2024",
  "year": 2024,
  "board": "BISE Rawalpindi",
  "class": "10",
  "pdfUrl": "/pdfs/bise-rawalpindi-10-2024.pdf"
}
EOF

# ============ PLACEHOLDER PDFs ============
# Create empty placeholder files so links don't 404 during preview
touch public/pdfs/math-10-ch1.pdf \
      public/pdfs/physics-9-ch1.pdf \
      public/pdfs/chemistry-10-ch1.pdf \
      public/pdfs/biology-11-ch1.pdf \
      public/pdfs/english-9-essays.pdf \
      public/pdfs/physics-9-textbook.pdf \
      public/pdfs/math-10-textbook.pdf \
      public/pdfs/chemistry-10-textbook.pdf \
      public/pdfs/biology-11-textbook.pdf \
      public/pdfs/bise-lahore-10-2025.pdf \
      public/pdfs/bise-karachi-9-2024.pdf \
      public/pdfs/bise-rawalpindi-10-2024.pdf

echo ""
echo "✅ Done! Content and UI created."
echo ""
echo "📁 Structure:"
echo "   src/styles/global.css"
echo "   src/layouts/BaseLayout.astro"
echo "   src/pages/*  (9 pages)"
echo "   src/content/notes/* (5 files)"
echo "   src/content/quizzes/* (3 files)"
echo "   src/content/books/* (4 files)"
echo "   src/content/gazettes/* (3 files)"
echo ""
echo "▶️  Next: run 'npm run dev' and open http://localhost:4321"