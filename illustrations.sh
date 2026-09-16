#!/bin/bash
set -e

mkdir -p src/components

# ═══════════════════════════════════════════════════════════
#  ILLUSTRATION COMPONENT (inline SVG, no dependencies)
# ═══════════════════════════════════════════════════════════
cat > src/components/Illustration.astro <<'EOF'
---
interface Props {
  name: 'student' | 'studying' | 'reading' | 'graduation' | 'desk';
  class?: string;
}
const { name, class: className = '' } = Astro.props;
---
{name === 'student' && (
<svg viewBox="0 0 400 400" fill="none" xmlns="http://www.w3.org/2000/svg" class={className} aria-hidden="true">
  <!-- Background blobs -->
  <circle cx="320" cy="80" r="55" fill="#eef2fe"/>
  <circle cx="60" cy="330" r="40" fill="#fef3c7"/>
  <circle cx="340" cy="330" r="25" fill="#fee2e2"/>
  <circle cx="80" cy="70" r="10" fill="#0620ed" opacity="0.15"/>
  <circle cx="300" cy="240" r="8" fill="#0620ed" opacity="0.15"/>

  <!-- Shadow -->
  <ellipse cx="200" cy="365" rx="90" ry="10" fill="#0620ed" opacity="0.08"/>

  <!-- Legs -->
  <rect x="160" y="270" width="22" height="90" rx="11" fill="#1e293b"/>
  <rect x="218" y="270" width="22" height="90" rx="11" fill="#1e293b"/>

  <!-- Shoes -->
  <path d="M155 355 h35 a8 8 0 0 1 0 16 h-35 z" fill="#0620ed"/>
  <path d="M213 355 h35 a8 8 0 0 1 0 16 h-35 z" fill="#0620ed"/>

  <!-- Body / Torso (shirt) -->
  <path d="M150 165 Q150 145 175 145 L225 145 Q250 145 250 165 L250 280 Q250 295 235 295 L165 295 Q150 295 150 280 Z" fill="#0620ed"/>

  <!-- Collar / white detail -->
  <path d="M185 145 L200 165 L215 145" stroke="#ffffff" stroke-width="3" fill="none" stroke-linecap="round"/>

  <!-- Backpack straps -->
  <path d="M165 160 Q175 200 175 240" stroke="#110176" stroke-width="4" fill="none" stroke-linecap="round"/>
  <path d="M235 160 Q225 200 225 240" stroke="#110176" stroke-width="4" fill="none" stroke-linecap="round"/>

  <!-- Backpack -->
  <rect x="135" y="180" width="30" height="70" rx="10" fill="#110176"/>
  <rect x="140" y="200" width="20" height="8" rx="3" fill="#5c84f8"/>

  <!-- Arms -->
  <path d="M150 175 Q120 190 115 235 Q113 250 128 252 Q140 252 142 240 L155 200" fill="#0620ed"/>
  <path d="M250 175 Q280 190 285 235 Q287 250 272 252 Q260 252 258 240 L245 200" fill="#0620ed"/>

  <!-- Hands (skin) -->
  <circle cx="125" cy="248" r="12" fill="#fcd9b8"/>
  <circle cx="275" cy="248" r="12" fill="#fcd9b8"/>

  <!-- Book in left hand -->
  <rect x="95" y="235" width="50" height="34" rx="3" fill="#ffffff" transform="rotate(-15 95 235)"/>
  <rect x="95" y="235" width="50" height="34" rx="3" stroke="#0620ed" stroke-width="2" transform="rotate(-15 95 235)"/>
  <line x1="120" y1="238" x2="120" y2="266" stroke="#0620ed" stroke-width="1.5" transform="rotate(-15 95 235)"/>

  <!-- Neck -->
  <rect x="188" y="122" width="24" height="26" rx="12" fill="#fcd9b8"/>

  <!-- Head -->
  <circle cx="200" cy="95" r="42" fill="#fcd9b8"/>

  <!-- Hair -->
  <path d="M158 92 Q158 48 200 48 Q242 48 242 92 Q242 82 235 78 Q230 70 218 68 Q210 60 200 62 Q190 60 182 68 Q170 70 165 78 Q158 82 158 92 Z" fill="#1e293b"/>

  <!-- Eyes -->
  <circle cx="185" cy="97" r="3" fill="#1e293b"/>
  <circle cx="215" cy="97" r="3" fill="#1e293b"/>

  <!-- Smile -->
  <path d="M188 112 Q200 122 212 112" stroke="#1e293b" stroke-width="2.5" fill="none" stroke-linecap="round"/>

  <!-- Cheeks -->
  <circle cx="176" cy="110" r="5" fill="#f9a8d4" opacity="0.6"/>
  <circle cx="224" cy="110" r="5" fill="#f9a8d4" opacity="0.6"/>
</svg>
)}

{name === 'studying' && (
<svg viewBox="0 0 400 400" fill="none" xmlns="http://www.w3.org/2000/svg" class={className} aria-hidden="true">
  <!-- Background -->
  <circle cx="80" cy="90" r="50" fill="#eef2fe"/>
  <circle cx="330" cy="120" r="30" fill="#fef3c7"/>
  <circle cx="320" cy="330" r="45" fill="#fee2e2"/>

  <!-- Shadow -->
  <ellipse cx="200" cy="355" rx="110" ry="10" fill="#0620ed" opacity="0.08"/>

  <!-- Desk -->
  <rect x="60" y="270" width="280" height="14" rx="4" fill="#a3a3a3"/>
  <rect x="90" y="284" width="10" height="70" rx="3" fill="#737373"/>
  <rect x="300" y="284" width="10" height="70" rx="3" fill="#737373"/>

  <!-- Laptop -->
  <rect x="150" y="200" width="100" height="68" rx="4" fill="#1e293b"/>
  <rect x="155" y="205" width="90" height="56" rx="2" fill="#eef2fe"/>
  <rect x="160" y="210" width="80" height="6" rx="2" fill="#0620ed"/>
  <rect x="160" y="222" width="60" height="4" rx="2" fill="#93adfb"/>
  <rect x="160" y="231" width="70" height="4" rx="2" fill="#93adfb"/>
  <rect x="160" y="240" width="50" height="4" rx="2" fill="#93adfb"/>
  <path d="M140 268 L260 268 L268 280 L132 280 Z" fill="#374151"/>

  <!-- Chair back -->
  <rect x="120" y="180" width="20" height="100" rx="8" fill="#a3a3a3"/>

  <!-- Girl body -->
  <path d="M155 150 Q155 130 175 130 L225 130 Q245 130 245 150 L245 270 Q245 285 230 285 L170 285 Q155 285 155 270 Z" fill="#f9a8d4"/>

  <!-- Girl hair (long, behind) -->
  <path d="M145 100 Q145 55 200 55 Q255 55 255 100 L255 180 Q250 200 240 200 L240 140 Q235 110 200 108 Q165 110 160 140 L160 200 Q150 200 145 180 Z" fill="#78350f"/>

  <!-- Neck -->
  <rect x="188" y="118" width="24" height="24" rx="12" fill="#fcd9b8"/>

  <!-- Head -->
  <circle cx="200" cy="95" r="40" fill="#fcd9b8"/>

  <!-- Hair front -->
  <path d="M160 90 Q160 52 200 52 Q240 52 240 90 Q235 72 220 68 Q210 62 200 62 Q190 62 180 68 Q165 72 160 90 Z" fill="#78350f"/>

  <!-- Eyes -->
  <circle cx="186" cy="97" r="3" fill="#1e293b"/>
  <circle cx="214" cy="97" r="3" fill="#1e293b"/>

  <!-- Smile -->
  <path d="M190 111 Q200 119 210 111" stroke="#1e293b" stroke-width="2.2" fill="none" stroke-linecap="round"/>

  <!-- Cheeks -->
  <circle cx="178" cy="108" r="5" fill="#f472b6" opacity="0.5"/>
  <circle cx="222" cy="108" r="5" fill="#f472b6" opacity="0.5"/>

  <!-- Arms reaching to laptop -->
  <path d="M160 170 Q140 200 155 240 Q158 250 168 248 Q175 245 175 235 L172 200" fill="#f9a8d4"/>
  <path d="M240 170 Q260 200 245 240 Q242 250 232 248 Q225 245 225 235 L228 200" fill="#f9a8d4"/>

  <!-- Hands -->
  <circle cx="168" cy="248" r="10" fill="#fcd9b8"/>
  <circle cx="232" cy="248" r="10" fill="#fcd9b8"/>

  <!-- Book on desk -->
  <rect x="80" y="252" width="55" height="18" rx="2" fill="#ffffff"/>
  <rect x="80" y="252" width="55" height="18" rx="2" stroke="#fbbf24" stroke-width="2"/>
  <line x1="107" y1="254" x2="107" y2="270" stroke="#fbbf24" stroke-width="1.5"/>

  <!-- Coffee cup -->
  <rect x="270" y="248" width="22" height="24" rx="3" fill="#ffffff" stroke="#737373" stroke-width="1.5"/>
  <path d="M292 254 Q300 258 292 264" stroke="#737373" stroke-width="1.5" fill="none"/>
  <ellipse cx="281" cy="250" rx="11" ry="3" fill="#78350f" opacity="0.7"/>
</svg>
)}

{name === 'reading' && (
<svg viewBox="0 0 400 400" fill="none" xmlns="http://www.w3.org/2000/svg" class={className} aria-hidden="true">
  <!-- Background -->
  <circle cx="80" cy="80" r="45" fill="#fef3c7"/>
  <circle cx="330" cy="90" r="35" fill="#eef2fe"/>
  <circle cx="330" cy="340" r="40" fill="#dcfce7"/>

  <!-- Shadow -->
  <ellipse cx="200" cy="360" rx="100" ry="8" fill="#0620ed" opacity="0.08"/>

  <!-- Bean bag / seat -->
  <path d="M110 260 Q110 340 200 340 Q290 340 290 260 Q290 240 270 240 L130 240 Q110 240 110 260 Z" fill="#a5b4fc"/>

  <!-- Legs -->
  <path d="M165 330 Q160 360 155 365 L185 365 Q190 355 195 330 Z" fill="#1e293b"/>
  <path d="M235 330 Q240 360 245 365 L215 365 Q210 355 205 330 Z" fill="#1e293b"/>
  <path d="M150 360 h40 a6 6 0 0 1 0 12 h-40 z" fill="#0620ed"/>
  <path d="M210 360 h40 a6 6 0 0 1 0 12 h-40 z" fill="#0620ed"/>

  <!-- Body -->
  <path d="M155 150 Q155 130 175 130 L225 130 Q245 130 245 150 L245 275 Q245 290 230 290 L170 290 Q155 290 155 275 Z" fill="#fbbf24"/>

  <!-- Book held in lap -->
  <rect x="140" y="215" width="120" height="55" rx="3" fill="#ffffff"/>
  <rect x="140" y="215" width="120" height="55" rx="3" stroke="#0620ed" stroke-width="2"/>
  <line x1="200" y1="218" x2="200" y2="267" stroke="#0620ed" stroke-width="2"/>
  <line x1="155" y1="228" x2="192" y2="228" stroke="#93adfb" stroke-width="2" stroke-linecap="round"/>
  <line x1="155" y1="236" x2="192" y2="236" stroke="#93adfb" stroke-width="2" stroke-linecap="round"/>
  <line x1="155" y1="244" x2="185" y2="244" stroke="#93adfb" stroke-width="2" stroke-linecap="round"/>
  <line x1="208" y1="228" x2="245" y2="228" stroke="#93adfb" stroke-width="2" stroke-linecap="round"/>
  <line x1="208" y1="236" x2="245" y2="236" stroke="#93adfb" stroke-width="2" stroke-linecap="round"/>
  <line x1="208" y1="244" x2="240" y2="244" stroke="#93adfb" stroke-width="2" stroke-linecap="round"/>

  <!-- Arms holding book -->
  <path d="M155 170 Q130 200 140 235 L155 235" fill="#fbbf24"/>
  <path d="M245 170 Q270 200 260 235 L245 235" fill="#fbbf24"/>
  <circle cx="148" cy="238" r="10" fill="#fcd9b8"/>
  <circle cx="252" cy="238" r="10" fill="#fcd9b8"/>

  <!-- Neck -->
  <rect x="188" y="118" width="24" height="24" rx="12" fill="#fcd9b8"/>

  <!-- Head -->
  <circle cx="200" cy="95" r="40" fill="#fcd9b8"/>

  <!-- Hair -->
  <path d="M160 88 Q160 50 200 50 Q240 50 240 88 Q230 68 200 66 Q170 68 160 88 Z" fill="#1e293b"/>
  <path d="M240 88 Q248 92 250 100 Q246 94 240 92 Z" fill="#1e293b"/>

  <!-- Eyes looking down (reading) -->
  <path d="M182 100 Q186 105 190 100" stroke="#1e293b" stroke-width="2.5" fill="none" stroke-linecap="round"/>
  <path d="M210 100 Q214 105 218 100" stroke="#1e293b" stroke-width="2.5" fill="none" stroke-linecap="round"/>

  <!-- Smile -->
  <path d="M190 114 Q200 122 210 114" stroke="#1e293b" stroke-width="2.2" fill="none" stroke-linecap="round"/>

  <!-- Cheeks -->
  <circle cx="178" cy="110" r="5" fill="#f9a8d4" opacity="0.5"/>
  <circle cx="222" cy="110" r="5" fill="#f9a8d4" opacity="0.5"/>
</svg>
)}

{name === 'graduation' && (
<svg viewBox="0 0 400 400" fill="none" xmlns="http://www.w3.org/2000/svg" class={className} aria-hidden="true">
  <circle cx="80" cy="90" r="45" fill="#eef2fe"/>
  <circle cx="330" cy="100" r="40" fill="#fef3c7"/>
  <circle cx="70" cy="330" r="35" fill="#dcfce7"/>
  <circle cx="330" cy="340" r="30" fill="#fee2e2"/>

  <ellipse cx="200" cy="370" rx="110" ry="10" fill="#0620ed" opacity="0.08"/>

  <!-- Legs -->
  <rect x="170" y="270" width="22" height="90" rx="11" fill="#1e293b"/>
  <rect x="208" y="270" width="22" height="90" rx="11" fill="#1e293b"/>
  <path d="M165 358 h35 a7 7 0 0 1 0 14 h-35 z" fill="#0620ed"/>
  <path d="M200 358 h35 a7 7 0 0 1 0 14 h-35 z" fill="#0620ed"/>

  <!-- Gown body -->
  <path d="M150 160 Q150 140 175 140 L225 140 Q250 140 250 160 L250 285 Q250 295 240 295 L160 295 Q150 295 150 285 Z" fill="#1e293b"/>

  <!-- Gown V -->
  <path d="M180 140 L200 195 L220 140" fill="#fcd9b8"/>

  <!-- Arms -->
  <path d="M155 175 Q125 200 120 240 Q118 255 133 257 Q145 257 147 245 L155 205" fill="#1e293b"/>
  <path d="M245 175 Q275 200 280 240 Q282 255 267 257 Q255 257 253 245 L245 205" fill="#1e293b"/>
  <circle cx="130" cy="252" r="11" fill="#fcd9b8"/>
  <circle cx="270" cy="252" r="11" fill="#fcd9b8"/>

  <!-- Diploma scroll in hand -->
  <rect x="248" y="238" width="45" height="14" rx="7" fill="#fbbf24" transform="rotate(20 248 238)"/>
  <rect x="248" y="238" width="45" height="14" rx="7" stroke="#b45309" stroke-width="1.5" transform="rotate(20 248 238)"/>
  <circle cx="293" cy="250" r="6" fill="#0620ed"/>

  <!-- Neck -->
  <rect x="188" y="118" width="24" height="26" rx="12" fill="#fcd9b8"/>

  <!-- Head -->
  <circle cx="200" cy="95" r="42" fill="#fcd9b8"/>

  <!-- Hair -->
  <path d="M158 90 Q158 46 200 46 Q242 46 242 90 Q242 76 230 72 Q220 66 200 66 Q180 66 170 72 Q158 76 158 90 Z" fill="#78350f"/>

  <!-- Eyes -->
  <circle cx="186" cy="96" r="3" fill="#1e293b"/>
  <circle cx="214" cy="96" r="3" fill="#1e293b"/>

  <!-- Big smile -->
  <path d="M185 112 Q200 124 215 112" stroke="#1e293b" stroke-width="2.5" fill="none" stroke-linecap="round"/>

  <!-- Cheeks -->
  <circle cx="176" cy="108" r="6" fill="#f9a8d4" opacity="0.6"/>
  <circle cx="224" cy="108" r="6" fill="#f9a8d4" opacity="0.6"/>

  <!-- Graduation cap -->
  <rect x="170" y="55" width="60" height="6" rx="2" fill="#1e293b"/>
  <path d="M155 60 L200 42 L245 60 L200 78 Z" fill="#1e293b"/>
  <path d="M200 42 L200 78" stroke="#0f172a" stroke-width="1.5"/>
  <line x1="245" y1="60" x2="258" y2="95" stroke="#fbbf24" stroke-width="3" stroke-linecap="round"/>
  <circle cx="258" cy="98" r="5" fill="#fbbf24"/>

  <!-- Confetti -->
  <rect x="90" y="140" width="8" height="8" rx="1" fill="#0620ed" transform="rotate(25 90 140)"/>
  <rect x="310" y="150" width="8" height="8" rx="1" fill="#fbbf24" transform="rotate(-15 310 150)"/>
  <circle cx="320" cy="200" r="4" fill="#f9a8d4"/>
  <circle cx="75" cy="220" r="4" fill="#34d399"/>
</svg>
)}

{name === 'desk' && (
<svg viewBox="0 0 400 300" fill="none" xmlns="http://www.w3.org/2000/svg" class={className} aria-hidden="true">
  <ellipse cx="200" cy="270" rx="150" ry="12" fill="#0620ed" opacity="0.06"/>

  <!-- Desk top -->
  <rect x="40" y="200" width="320" height="18" rx="4" fill="#a3a3a3"/>
  <rect x="70" y="218" width="12" height="60" rx="3" fill="#737373"/>
  <rect x="318" y="218" width="12" height="60" rx="3" fill="#737373"/>

  <!-- Monitor -->
  <rect x="140" y="90" width="120" height="90" rx="6" fill="#1e293b"/>
  <rect x="146" y="96" width="108" height="78" rx="3" fill="#eef2fe"/>
  <rect x="155" y="105" width="60" height="6" rx="2" fill="#0620ed"/>
  <rect x="155" y="118" width="90" height="4" rx="2" fill="#93adfb"/>
  <rect x="155" y="127" width="80" height="4" rx="2" fill="#93adfb"/>
  <rect x="155" y="136" width="50" height="4" rx="2" fill="#93adfb"/>
  <rect x="180" y="180" width="40" height="10" rx="2" fill="#374151"/>
  <rect x="160" y="190" width="80" height="10" rx="3" fill="#374151"/>

  <!-- Stack of books -->
  <rect x="60" y="180" width="60" height="10" rx="2" fill="#0620ed"/>
  <rect x="65" y="170" width="55" height="10" rx="2" fill="#fbbf24"/>
  <rect x="70" y="160" width="50" height="10" rx="2" fill="#f9a8d4"/>

  <!-- Pencil cup -->
  <rect x="280" y="170" width="26" height="30" rx="4" fill="#ffffff" stroke="#737373" stroke-width="1.5"/>
  <line x1="288" y1="148" x2="290" y2="172" stroke="#0620ed" stroke-width="3" stroke-linecap="round"/>
  <line x1="296" y1="145" x2="296" y2="172" stroke="#fbbf24" stroke-width="3" stroke-linecap="round"/>
  <line x1="302" y1="150" x2="300" y2="172" stroke="#f9a8d4" stroke-width="3" stroke-linecap="round"/>
</svg>
)}
EOF

# ═══════════════════════════════════════════════════════════
#  PATCH HOME: add illustrations
# ═══════════════════════════════════════════════════════════
python3 - <<'PY'
import pathlib, re

p = pathlib.Path("src/pages/index.astro")
s = p.read_text()

# 1. Add Illustration import
if "Illustration" not in s:
    s = s.replace(
        "import Icon from '../components/Icon.astro';",
        "import Icon from '../components/Icon.astro';\nimport Illustration from '../components/Illustration.astro';",
        1
    )

# 2. Replace the hero content — turn the single-column hero into a 2-column layout with illustration
old_hero_start = '      <div class="max-w-3xl">'
old_hero_end = '      </div>\n    </div>\n  </section>'

# We'll replace the section markup between <section class="border-b ..."> and </section> for hero
hero_pattern = re.compile(
    r'<!-- HERO -->\s*<section class="border-b border-neutral-200 bg-neutral-50">.*?</section>',
    re.DOTALL
)

new_hero = '''<!-- HERO -->
  <section class="border-b border-neutral-200 bg-neutral-50">
    <div class="mx-auto max-w-[1320px] px-4 py-16 lg:px-8 lg:py-24">
      <div class="grid items-center gap-12 lg:grid-cols-12 lg:gap-16">
        <div class="lg:col-span-7">
          <div class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-[#0620ed]">
            <span class="h-1.5 w-1.5 rounded-full bg-[#0620ed]"></span>
            Trusted by students across Pakistan
          </div>
          <h1 class="mt-5 text-[2.5rem] font-extrabold leading-[1.08] tracking-[-0.035em] text-neutral-900 sm:text-6xl">
            Exam-specific revision,<br />
            made simple.
          </h1>
          <p class="mt-6 max-w-xl text-base leading-relaxed text-neutral-500 sm:text-lg">
            Notes, interactive quizzes, textbooks and result gazettes — organised by class and subject, all completely free.
          </p>

          <form action="/search" method="get" role="search" class="mt-8 flex max-w-lg items-center gap-2 rounded-2xl border border-neutral-200 bg-white p-1.5 pl-4 focus-within:border-[#0620ed]">
            <Icon name="search" size={18} strokeWidth={2.4} class="shrink-0 text-neutral-400" />
            <input type="search" name="q" placeholder="Search notes, books, past papers..." class="min-w-0 flex-1 bg-transparent py-2.5 text-sm text-neutral-900 outline-none placeholder:text-neutral-400" />
            <button type="submit" class="rounded-xl bg-[#0620ed] px-4 py-2.5 text-sm font-bold text-white transition-colors hover:bg-[#110176]">Search</button>
          </form>

          <div class="mt-6 flex flex-wrap items-center gap-x-5 gap-y-2 text-sm font-medium text-neutral-500">
            <span class="flex items-center gap-1.5"><Icon name="zap" size={14} strokeWidth={2.4} class="text-[#0620ed]" /> Instant answers</span>
            <span class="h-1 w-1 rounded-full bg-neutral-300"></span>
            <span class="flex items-center gap-1.5"><Icon name="download" size={14} strokeWidth={2.4} class="text-[#0620ed]" /> Free PDFs</span>
            <span class="h-1 w-1 rounded-full bg-neutral-300"></span>
            <span class="flex items-center gap-1.5"><Icon name="check" size={14} strokeWidth={2.6} class="text-[#0620ed]" /> All boards</span>
          </div>
        </div>

        <div class="lg:col-span-5">
          <div class="mx-auto w-full max-w-md lg:max-w-none">
            <Illustration name="student" class="h-auto w-full" />
          </div>
        </div>
      </div>
    </div>
  </section>'''

if hero_pattern.search(s):
    s = hero_pattern.sub(new_hero, s, count=1)
    print("  Hero patched with illustration")
else:
    print("  WARNING: hero pattern not found")

# 3. Add illustration to "Browse by class" section — replace the grid with a 2-col (illustration + cards)
# Actually simpler: add a small illustration next to the Browse by class heading
# Let's add a class-picker illustration after Browse by class section title
if 'Illustration name="reading"' not in s:
    # Insert a decorative illustration floating to the right of the classes grid
    pass

p.write_text(s)
PY

# Also add a "Why TaleemHub" section with the studying illustration below the classes section
python3 - <<'PY'
import pathlib, re

p = pathlib.Path("src/pages/index.astro")
s = p.read_text()

if 'Why TaleemHub' not in s and 'Illustration name="studying"' not in s:
    insert_after = re.search(
        r'(<!-- BROWSE BY SUBJECT -->.*?</section>)',
        s, re.DOTALL
    )
    block = '''
  <!-- WHY TALEEMHUB -->
  <section class="border-y border-neutral-200 bg-neutral-50">
    <div class="mx-auto max-w-[1320px] px-4 py-16 lg:px-8 lg:py-20">
      <div class="grid items-center gap-12 lg:grid-cols-12 lg:gap-16">
        <div class="order-2 lg:order-1 lg:col-span-5">
          <div class="mx-auto w-full max-w-md lg:max-w-none">
            <Illustration name="studying" class="h-auto w-full" />
          </div>
        </div>
        <div class="order-1 lg:order-2 lg:col-span-7">
          <div class="flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.14em] text-[#0620ed]">
            <span class="h-1.5 w-1.5 rounded-full bg-[#0620ed]"></span>
            Why TaleemHub
          </div>
          <h2 class="mt-5 text-2xl font-extrabold tracking-tight text-neutral-900 sm:text-3xl">
            Built for the way students actually study.
          </h2>
          <p class="mt-4 max-w-lg text-base leading-relaxed text-neutral-500">
            Everything is organised the way you think — by your class first, then by subject. No hunting, no clutter, no sign-up.
          </p>
          <ul class="mt-7 grid gap-4 sm:grid-cols-2">
            <li class="flex gap-3">
              <span class="mt-0.5 grid h-6 w-6 shrink-0 place-items-center rounded-full bg-[#eef2fe] text-[#0620ed]">
                <Icon name="check" size={13} strokeWidth={3} />
              </span>
              <div>
                <div class="text-sm font-bold text-neutral-900">Class-first navigation</div>
                <div class="mt-1 text-sm text-neutral-500">Jump straight to your class and subject.</div>
              </div>
            </li>
            <li class="flex gap-3">
              <span class="mt-0.5 grid h-6 w-6 shrink-0 place-items-center rounded-full bg-[#eef2fe] text-[#0620ed]">
                <Icon name="check" size={13} strokeWidth={3} />
              </span>
              <div>
                <div class="text-sm font-bold text-neutral-900">Interactive quizzes</div>
                <div class="mt-1 text-sm text-neutral-500">Instant feedback and a score at the end.</div>
              </div>
            </li>
            <li class="flex gap-3">
              <span class="mt-0.5 grid h-6 w-6 shrink-0 place-items-center rounded-full bg-[#eef2fe] text-[#0620ed]">
                <Icon name="check" size={13} strokeWidth={3} />
              </span>
              <div>
                <div class="text-sm font-bold text-neutral-900">Every board covered</div>
                <div class="mt-1 text-sm text-neutral-500">Punjab, Federal, KPK, Sindh, Balochistan.</div>
              </div>
            </li>
            <li class="flex gap-3">
              <span class="mt-0.5 grid h-6 w-6 shrink-0 place-items-center rounded-full bg-[#eef2fe] text-[#0620ed]">
                <Icon name="check" size={13} strokeWidth={3} />
              </span>
              <div>
                <div class="text-sm font-bold text-neutral-900">100% free forever</div>
                <div class="mt-1 text-sm text-neutral-500">No ads. No paywalls. No sign-up required.</div>
              </div>
            </li>
          </ul>
        </div>
      </div>
    </div>
  </section>
'''
    if insert_after:
        s = s[:insert_after.end()] + block + s[insert_after.end():]
        p.write_text(s)
        print("  Why TaleemHub section added")
PY

# ═══════════════════════════════════════════════════════════
#  CLEAR CACHES
# ═══════════════════════════════════════════════════════════
rm -rf .astro node_modules/.vite node_modules/.astro dist

echo ""
echo "════════════════════════════════════════════"
echo "  Illustrations added"
echo "════════════════════════════════════════════"
echo ""
echo "  New component: src/components/Illustration.astro"
echo "  Available illustrations:"
echo "    - student     (student with book & backpack)"
echo "    - studying    (girl at desk with laptop)"
echo "    - reading     (student reading a book)"
echo "    - graduation  (student with cap & diploma)"
echo "    - desk        (study desk scene)"
echo ""
echo "  Placement:"
echo "    - Home hero       → 'student' illustration"
echo "    - Why section     → 'studying' illustration"
echo ""
echo "  Run:  npm run dev"