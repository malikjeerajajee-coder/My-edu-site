#!/bin/bash
set -e

echo "Building interactive quiz player + design refresh..."

mkdir -p src/components

# ============ QUIZ PLAYER COMPONENT ============
cat > src/components/QuizPlayer.astro <<'EOF'
---
interface Props {
  questions: Array<{ question: string; options: string[]; answer: number }>;
  title?: string;
}
const { questions, title = 'Quiz' } = Astro.props;
---
<div id="quiz-root" class="overflow-hidden rounded-2xl border border-slate-200 bg-white">
  <div class="border-b border-slate-200 bg-slate-50/60 px-5 py-4 sm:px-6">
    <div class="flex items-center justify-between gap-3">
      <span class="text-[11px] font-bold uppercase tracking-wider text-slate-500">
        Question <span id="q-current">1</span> of <span id="q-total">{questions.length}</span>
      </span>
      <span class="text-[11px] font-bold uppercase tracking-wider text-emerald-700">
        Score <span id="q-score">0</span>
      </span>
    </div>
    <div class="mt-3 h-1.5 overflow-hidden rounded-full bg-slate-200">
      <div id="q-progress" class="h-full rounded-full bg-emerald-500 transition-all duration-500 ease-out" style="width: 0%"></div>
    </div>
  </div>

  <div class="px-5 py-6 sm:px-8 sm:py-8">
    <div id="q-body"></div>
    <div id="q-feedback-wrap" class="mt-5"></div>
    <div id="q-result" class="hidden"></div>

    <div id="q-footer" class="mt-7 flex items-center justify-between gap-3">
      <button
        id="q-reset"
        type="button"
        class="hidden rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm font-semibold text-slate-600 transition-colors hover:border-slate-300 hover:text-slate-900"
      >
        Restart quiz
      </button>
      <button
        id="q-next"
        type="button"
        class="ml-auto hidden items-center gap-2 rounded-xl bg-emerald-600 px-5 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-emerald-700"
      >
        <span id="q-next-label">Next question</span>
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>
      </button>
    </div>
  </div>
</div>

<style is:global>
  .quiz-q-title {
    font-size: 1.125rem;
    font-weight: 700;
    line-height: 1.4;
    letter-spacing: -0.02em;
    color: #0f172a;
  }
  .quiz-options {
    margin-top: 1.5rem;
    display: flex;
    flex-direction: column;
    gap: 0.625rem;
  }
  .quiz-option {
    display: flex;
    align-items: center;
    gap: 0.875rem;
    width: 100%;
    padding: 0.9rem 1rem;
    border-radius: 0.875rem;
    border: 1.5px solid #e2e8f0;
    background: #ffffff;
    color: #0f172a;
    font-size: 0.95rem;
    font-weight: 500;
    text-align: left;
    cursor: pointer;
    transition: border-color .18s, background-color .18s, transform .18s cubic-bezier(0.16, 1, 0.3, 1);
    font-family: inherit;
  }
  .quiz-option:hover:not(:disabled) {
    border-color: #6ee7b7;
    background: #ecfdf5;
    transform: translateY(-1px);
  }
  .quiz-option:disabled { cursor: default; }
  .quiz-option.quiz-correct {
    border-color: #10b981;
    background: #ecfdf5;
  }
  .quiz-option.quiz-wrong {
    border-color: #f43f5e;
    background: #fff1f2;
  }
  .quiz-key {
    display: grid;
    place-items: center;
    width: 1.75rem;
    height: 1.75rem;
    border-radius: 0.5rem;
    background: #f1f5f9;
    color: #64748b;
    font-size: 0.72rem;
    font-weight: 800;
    flex-shrink: 0;
    transition: background-color .18s, color .18s;
  }
  .quiz-option:hover:not(:disabled) .quiz-key {
    background: #a7f3d0;
    color: #047857;
  }
  .quiz-option.quiz-correct .quiz-key {
    background: #10b981;
    color: #ffffff;
  }
  .quiz-option.quiz-wrong .quiz-key {
    background: #f43f5e;
    color: #ffffff;
  }
  .quiz-option.quiz-correct .quiz-text { color: #065f46; font-weight: 700; }
  .quiz-option.quiz-wrong .quiz-text { color: #9f1239; }

  .quiz-fb {
    display: flex;
    align-items: flex-start;
    gap: 0.625rem;
    padding: 0.875rem 1rem;
    border-radius: 0.75rem;
    font-size: 0.9rem;
    line-height: 1.5;
    animation: qzFadeUp .3s cubic-bezier(0.16, 1, 0.3, 1) both;
  }
  .quiz-fb-correct {
    background: #ecfdf5;
    border: 1px solid #a7f3d0;
    color: #065f46;
  }
  .quiz-fb-wrong {
    background: #fff1f2;
    border: 1px solid #fecdd3;
    color: #9f1239;
  }
  .quiz-fb-icon {
    width: 1.125rem;
    height: 1.125rem;
    flex-shrink: 0;
    margin-top: 0.1rem;
  }
  .quiz-fb strong { font-weight: 700; }

  .quiz-result {
    padding: 2rem 1.5rem;
    border-radius: 1rem;
    background: linear-gradient(135deg, #ecfdf5, #d1fae5);
    border: 1px solid #a7f3d0;
    text-align: center;
    animation: qzFadeUp .4s cubic-bezier(0.16, 1, 0.3, 1) both;
  }
  .quiz-result-eyebrow {
    font-size: 0.7rem;
    font-weight: 800;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: #047857;
  }
  .quiz-result-score {
    margin-top: 0.75rem;
    font-family: 'Plus Jakarta Sans', 'Inter', sans-serif;
    font-size: 3rem;
    font-weight: 800;
    letter-spacing: -0.04em;
    line-height: 1;
    color: #065f46;
  }
  .quiz-result-score span {
    font-size: 1.5rem;
    color: #059669;
  }
  .quiz-result-pct {
    margin-top: 0.5rem;
    font-size: 0.875rem;
    font-weight: 600;
    color: #047857;
  }

  @keyframes qzFadeUp {
    from { opacity: 0; transform: translateY(8px); }
    to   { opacity: 1; transform: translateY(0); }
  }
</style>

<script is:inline define:vars={{ questions }}>
  (function () {
    var root      = document.getElementById('quiz-root');
    var body      = document.getElementById('q-body');
    var fbWrap    = document.getElementById('q-feedback-wrap');
    var resultEl  = document.getElementById('q-result');
    var nextBtn   = document.getElementById('q-next');
    var nextLabel = document.getElementById('q-next-label');
    var resetBtn  = document.getElementById('q-reset');
    var progress  = document.getElementById('q-progress');
    var qCurrent  = document.getElementById('q-current');
    var qScore    = document.getElementById('q-score');

    var current = 0;
    var score = 0;
    var answered = false;

    function esc(s) {
      return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
        return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
      });
    }

    function render() {
      answered = false;
      nextBtn.classList.add('hidden');
      nextBtn.classList.remove('inline-flex');
      resetBtn.classList.add('hidden');
      resetBtn.classList.remove('inline-flex');
      resultEl.classList.add('hidden');
      resultEl.innerHTML = '';
      fbWrap.innerHTML = '';

      var q = questions[current];
      qCurrent.textContent = current + 1;
      progress.style.width = ((current) / questions.length * 100) + '%';
      qScore.textContent = score;

      var optsHtml = q.options.map(function (opt, i) {
        return '<button type="button" data-index="' + i + '" class="quiz-option">' +
          '<span class="quiz-key">' + String.fromCharCode(65 + i) + '</span>' +
          '<span class="quiz-text">' + esc(opt) + '</span>' +
        '</button>';
      }).join('');

      body.innerHTML =
        '<div class="quiz-q-title">' + esc(q.question) + '</div>' +
        '<div class="quiz-options" id="q-options">' + optsHtml + '</div>';

      Array.prototype.forEach.call(
        document.querySelectorAll('#q-options .quiz-option'),
        function (btn) {
          btn.addEventListener('click', function () {
            handleAnswer(parseInt(btn.getAttribute('data-index'), 10));
          });
        }
      );
    }

    function handleAnswer(idx) {
      if (answered) return;
      answered = true;

      var q = questions[current];
      var isCorrect = idx === q.answer;
      if (isCorrect) score++;

      var options = document.querySelectorAll('#q-options .quiz-option');
      Array.prototype.forEach.call(options, function (btn, i) {
        btn.disabled = true;
        if (i === q.answer) btn.classList.add('quiz-correct');
        else if (i === idx) btn.classList.add('quiz-wrong');
      });

      var iconOk = '<svg class="quiz-fb-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg>';
      var iconNo = '<svg class="quiz-fb-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>';

      fbWrap.innerHTML = isCorrect
        ? '<div class="quiz-fb quiz-fb-correct">' + iconOk + '<div>Correct!</div></div>'
        : '<div class="quiz-fb quiz-fb-wrong">' + iconNo +
            '<div>Not quite. The correct answer is <strong>' +
              String.fromCharCode(65 + q.answer) + '. ' + esc(q.options[q.answer]) +
            '</strong></div></div>';

      qScore.textContent = score;
      progress.style.width = ((current + 1) / questions.length * 100) + '%';

      if (current < questions.length - 1) {
        nextLabel.textContent = 'Next question';
      } else {
        nextLabel.textContent = 'See results';
      }
      nextBtn.classList.remove('hidden');
      nextBtn.classList.add('inline-flex');
    }

    function showResults() {
      body.innerHTML = '';
      fbWrap.innerHTML = '';
      nextBtn.classList.add('hidden');
      nextBtn.classList.remove('inline-flex');
      resetBtn.classList.remove('hidden');
      resetBtn.classList.add('inline-flex');
      progress.style.width = '100%';

      var pct = Math.round((score / questions.length) * 100);
      var tier = pct >= 80 ? 'Excellent' : pct >= 60 ? 'Well done' : pct >= 40 ? 'Good effort' : 'Keep practising';

      resultEl.classList.remove('hidden');
      resultEl.innerHTML =
        '<div class="quiz-result">' +
          '<div class="quiz-result-eyebrow">' + tier + '</div>' +
          '<div class="quiz-result-score">' + score + '<span>/' + questions.length + '</span></div>' +
          '<div class="quiz-result-pct">' + pct + '% correct</div>' +
        '</div>';
    }

    nextBtn.addEventListener('click', function () {
      if (current < questions.length - 1) {
        current++;
        render();
        window.scrollTo({ top: root.offsetTop - 80, behavior: 'smooth' });
      } else {
        showResults();
      }
    });

    resetBtn.addEventListener('click', function () {
      current = 0;
      score = 0;
      render();
      window.scrollTo({ top: root.offsetTop - 80, behavior: 'smooth' });
    });

    document.addEventListener('keydown', function (e) {
      if (e.target && (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA' || e.target.isContentEditable)) return;
      if (answered) {
        if (e.key === 'Enter' && !nextBtn.classList.contains('hidden')) { nextBtn.click(); }
        return;
      }
      var idx = -1;
      if (/^[1-9]$/.test(e.key)) idx = parseInt(e.key, 10) - 1;
      else if (/^[a-dA-D]$/.test(e.key)) idx = e.key.toLowerCase().charCodeAt(0) - 97;
      if (idx >= 0) {
        var btn = document.querySelector('#q-options .quiz-option[data-index="' + idx + '"]');
        if (btn) btn.click();
      }
    });

    render();
  })();
</script>
EOF

# ============ QUIZ DETAIL PAGE ============
cat > src/pages/quizzes/[...slug].astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import QuizPlayer from '../../components/QuizPlayer.astro';
import { getCollection, render } from 'astro:content';

export async function getStaticPaths() {
  const quizzes = await getCollection('quizzes');
  return quizzes.map(quiz => ({ params: { slug: quiz.id }, props: { quiz } }));
}
const { quiz } = Astro.props;
const { Content } = await render(quiz);
---
<BaseLayout title={`${quiz.data.title} — TaleemHub`} description={`Practice ${quiz.data.questions.length} MCQs for ${quiz.data.subject} Class ${quiz.data.class}.`}>
  <div class="mx-auto w-full max-w-4xl px-4 pt-8 sm:px-6 sm:pt-12 lg:px-8">
    <nav class="mb-6 flex items-center gap-1.5 text-xs font-semibold text-slate-400">
      <a href="/" class="transition-colors hover:text-emerald-700">Home</a>
      <span>/</span>
      <a href="/quizzes" class="transition-colors hover:text-emerald-700">Quizzes</a>
      <span>/</span>
      <span class="truncate text-slate-500">{quiz.data.subject}</span>
    </nav>

    <div class="relative overflow-hidden rounded-3xl border border-blue-700 bg-gradient-to-br from-blue-900 via-blue-800 to-blue-600 p-7 text-white sm:p-9">
      <div class="flex flex-wrap gap-1.5">
        <span class="rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider backdrop-blur-sm">{quiz.data.subject}</span>
        <span class="rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider backdrop-blur-sm">Class {quiz.data.class}</span>
        <span class="rounded-md border border-white/20 bg-white/10 px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider backdrop-blur-sm">{quiz.data.questions.length} questions</span>
      </div>
      <h1 class="mt-4 font-display text-2xl font-extrabold leading-tight tracking-tight sm:text-3xl">{quiz.data.title}</h1>
    </div>

    <div class="mt-5">
      <QuizPlayer questions={quiz.data.questions} title={quiz.data.title} />
    </div>

    <article class="prose mt-6 rounded-2xl border border-slate-200 bg-white p-6 sm:p-8">
      <Content />
    </article>
  </div>
</BaseLayout>
EOF

# ============ QUIZ INDEX (refreshed) ============
cat > src/pages/quizzes/index.astro <<'EOF'
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Icon from '../../components/Icon.astro';
import { getCollection } from 'astro:content';

const quizzes = await getCollection('quizzes');
---
<BaseLayout title="Quizzes — TaleemHub" description="Interactive MCQ practice for Pakistani students.">
  <div class="mx-auto w-full max-w-7xl px-4 pt-10 sm:px-6 sm:pt-14 lg:px-8">
    <div class="mb-10 max-w-2xl">
      <div class="text-[11px] font-bold uppercase tracking-widest text-blue-700">Practice</div>
      <h1 class="mt-2 font-display text-3xl font-extrabold tracking-tight text-slate-900 sm:text-4xl">Test your knowledge</h1>
      <p class="mt-3 text-slate-500">Interactive MCQs with instant feedback and a score at the end.</p>
    </div>

    {quizzes.length === 0 ? (
      <div class="rounded-2xl border border-dashed border-slate-300 bg-white p-12 text-center">
        <div class="text-base font-bold text-slate-900">No quizzes yet</div>
        <div class="mt-1 text-sm text-slate-500">Check back soon.</div>
      </div>
    ) : (
      <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
        {quizzes.map(q => (
          <a href={`/quizzes/${q.id}`} class="group relative overflow-hidden rounded-2xl border border-slate-200 bg-white p-6 transition-colors hover:border-blue-300">
            <div class="flex items-start justify-between">
              <span class="grid h-12 w-12 place-items-center rounded-xl bg-blue-100 text-blue-700">
                <Icon name="file-question" size={22} strokeWidth={2.2} />
              </span>
              <span class="rounded-md bg-slate-100 px-2 py-1 text-[11px] font-bold uppercase tracking-wider text-slate-600">
                {q.data.questions.length} questions
              </span>
            </div>
            <h3 class="mt-5 font-display text-lg font-bold leading-snug tracking-tight text-slate-900">{q.data.title}</h3>
            <div class="mt-3 flex flex-wrap gap-1.5">
              <span class="rounded-md bg-blue-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-blue-700">{q.data.subject}</span>
              <span class="rounded-md bg-emerald-50 px-2 py-0.5 text-[11px] font-bold uppercase tracking-wide text-emerald-700">Class {q.data.class}</span>
            </div>
            <div class="mt-5 flex items-center gap-1.5 text-sm font-bold text-blue-700">
              Start quiz
              <Icon name="arrow-right" size={14} strokeWidth={2.6} class="transition-transform group-hover:translate-x-1" />
            </div>
          </a>
        ))}
      </div>
    )}
  </div>
</BaseLayout>
EOF

# ============ DESIGN REFRESH: HOME HERO ============
python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/pages/index.astro")
s = p.read_text()

old_hero = re.search(
  r'<section class="relative overflow-hidden border-b border-slate-200 bg-gradient-to-b from-emerald-50/70.*?</section>',
  s, re.DOTALL
)

new_hero = '''<section class="relative overflow-hidden border-b border-slate-200 bg-gradient-to-b from-emerald-50/70 via-white to-white">
    <div class="mx-auto w-full max-w-7xl px-4 py-16 sm:px-6 sm:py-24 lg:px-8 lg:py-28">
      <div class="mx-auto max-w-3xl text-center">
        <span class="inline-flex items-center gap-1.5 rounded-full border border-emerald-200 bg-emerald-50 px-3 py-1 text-xs font-bold uppercase tracking-wider text-emerald-700">
          <Icon name="sparkles" size={13} strokeWidth={2.4} />
          Free for every Pakistani student
        </span>
        <h1 class="mt-6 font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-slate-900 sm:text-6xl">
          Learn anything.<br />
          <span class="text-emerald-600">From Class 9 to Class 12.</span>
        </h1>
        <p class="mx-auto mt-6 max-w-xl text-base leading-relaxed text-slate-600 sm:text-lg">
          Notes, interactive quizzes, textbooks and result gazettes — organised by class and subject, all completely free.
        </p>

        <form action="/search" method="get" role="search" class="mx-auto mt-8 flex max-w-lg items-center gap-2 rounded-2xl border border-slate-200 bg-white p-1.5 pl-4 transition-colors focus-within:border-emerald-400">
          <Icon name="search" size={18} strokeWidth={2.4} class="shrink-0 text-slate-400" />
          <input
            type="search"
            name="q"
            placeholder="Search notes, books, past papers..."
            class="min-w-0 flex-1 bg-transparent py-2.5 text-sm text-slate-900 outline-none placeholder:text-slate-400"
          />
          <button type="submit" class="rounded-xl bg-emerald-600 px-4 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-emerald-700">
            Search
          </button>
        </form>

        <div class="mt-6 flex flex-wrap items-center justify-center gap-x-6 gap-y-2 text-sm text-slate-500">
          <span class="flex items-center gap-1.5"><Icon name="zap" size={14} strokeWidth={2.4} class="text-emerald-600" /> Instant answers</span>
          <span class="flex items-center gap-1.5"><Icon name="download" size={14} strokeWidth={2.4} class="text-emerald-600" /> Free PDFs</span>
          <span class="flex items-center gap-1.5"><Icon name="check" size={14} strokeWidth={2.6} class="text-emerald-600" /> All boards</span>
        </div>
      </div>

      <div class="mx-auto mt-14 grid max-w-4xl grid-cols-2 gap-3 sm:grid-cols-4 sm:gap-4">
        {categories.map(cat => (
          <a href={cat.href} class="group rounded-2xl border border-slate-200 bg-white p-5 transition-colors hover:border-emerald-300">
            <span class:list={[
              "grid h-11 w-11 place-items-center rounded-xl",
              cat.tint === 'emerald' && "bg-emerald-100 text-emerald-700",
              cat.tint === 'blue'    && "bg-blue-100 text-blue-700",
              cat.tint === 'amber'   && "bg-amber-100 text-amber-700",
              cat.tint === 'rose'    && "bg-rose-100 text-rose-700",
            ]}>
              <Icon name={cat.icon} size={20} strokeWidth={2.2} />
            </span>
            <div class="mt-4 font-display text-3xl font-extrabold tracking-tight text-slate-900">{cat.count}</div>
            <div class="mt-0.5 flex items-center gap-1 text-sm font-semibold text-slate-500">
              {cat.label}
              <Icon name="arrow-up-right" size={13} strokeWidth={2.4} class="opacity-0 transition-opacity group-hover:opacity-100" />
            </div>
          </a>
        ))}
      </div>
    </div>
  </section>'''

if old_hero:
    s = s[:old_hero.start()] + new_hero + s[old_hero.end():]
    p.write_text(s)
    print("Home hero refreshed.")
else:
    print("Hero not found — skipping.")
PY

# ============ ADD BREADCRUMBS TO NOTES / BOOKS / GAZETTES DETAILS ============
python3 - <<'PY'
import pathlib, re

def inject_breadcrumb(path, crumbs):
    p = pathlib.Path(path)
    if not p.exists():
        return
    s = p.read_text()
    # Only if not already added
    if 'Home</a>' in s and 'breadcrumb' in s:
        return
    # Find the back-button anchor line and insert breadcrumb right after the outer div open
    marker = '<div class="mx-auto w-full max-w-4xl px-4 pt-8 sm:px-6 sm:pt-12 lg:px-8">'
    idx = s.find(marker)
    if idx == -1:
        return
    insert_at = idx + len(marker)
    crumb_html = '\n    <nav class="mb-6 flex items-center gap-1.5 text-xs font-semibold text-slate-400">\n'
    for i, (label, href) in enumerate(crumbs):
        if i > 0:
            crumb_html += '      <span>/</span>\n'
        if href:
            crumb_html += f'      <a href="{href}" class="transition-colors hover:text-emerald-700">{label}</a>\n'
        else:
            crumb_html += f'      <span class="truncate text-slate-500">{label}</span>\n'
    crumb_html += '    </nav>\n'
    s = s[:insert_at] + crumb_html + s[insert_at:]
    p.write_text(s)
    print(f"  Breadcrumb added: {path}")

inject_breadcrumb("src/pages/notes/[...slug].astro", [("Home", "/"), ("Notes", "/notes"), ("Note", None)])
inject_breadcrumb("src/pages/books/[...slug].astro", [("Home", "/"), ("Textbooks", "/books"), ("Textbook", None)])
inject_breadcrumb("src/pages/gazettes/[...slug].astro", [("Home", "/"), ("Gazettes", "/gazettes"), ("Gazette", None)])
PY

# ============ CLEAR CACHES ============
rm -rf .astro node_modules/.vite node_modules/.astro dist

echo ""
echo "==================================================="
echo "  Done"
echo "==================================================="
echo ""
echo "  Quiz system:"
echo "    - One question at a time"
echo "    - Click option → instant correct/wrong feedback"
echo "    - Progress bar + live score"
echo "    - Keyboard: 1-4 or A-D to answer, Enter for next"
echo "    - Results screen with score tier"
echo "    - Restart button"
echo ""
echo "  Design refresh:"
echo "    - Hero is now centered, bolder, one clear message"
echo "    - Stat cards below the fold (4-up)"
echo "    - Quiz index uses editorial 'unit' cards"
echo "    - Breadcrumbs on all detail pages"
echo ""
echo "Next:"
echo "  1. Stop dev server (Ctrl+C)"
echo "  2. Run:  npm run dev"
echo "  3. Open http://localhost:4321/quizzes and click any quiz"