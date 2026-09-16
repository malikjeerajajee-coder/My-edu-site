#!/bin/bash
set -e
echo "🎨 TaleemHub Upgrade v2 — search, colors, polish"

# ---------- Detect project mode ----------
if [ -d "src" ] && [ -f "package.json" ]; then MODE="astro"; else MODE="static"; fi
echo "Mode detected: $MODE"

# ---------- 1) COLOR REFRESH: replace harsh #0620ed with refined blue ----------
find . -type f \( -name '*.astro' -o -name '*.html' -o -name '*.css' -o -name '*.js' -o -name '*.ts' -o -name '*.json' \) \
  -not -path './.git/*' -not -path './node_modules/*' \
  -exec sed -i 's/#0620ed/#2563eb/g' {} +
# Gradient accent on the hero headline
find . -type f \( -name '*.astro' -o -name '*.html' \) -not -path './.git/*' -not -path './node_modules/*' \
  -exec sed -i 's|class="text-\[#2563eb\]">exam prep library|class="bg-gradient-to-r from-[#2563eb] via-[#4f46e5] to-[#7c3aed] bg-clip-text text-transparent">exam prep library|' {} +
echo "✅ Palette updated (#2563eb + gradient hero accent)"

# ---------- 2) GLOBAL POLISH STYLESHEET ----------
if [ "$MODE" = "astro" ]; then ASSET_DIR="public"; mkdir -p public scripts; else ASSET_DIR="."; mkdir -p scripts; fi
cat << 'EOF' > "$ASSET_DIR/polish.css"
:root{--brand:#2563eb;--brand-dark:#1d4ed8;--brand-ink:#1e3a8a;--brand-soft:#eff6ff}
html{scroll-behavior:smooth}
body{-webkit-font-smoothing:antialiased;text-rendering:optimizeLegibility}
::selection{background:#bfdbfe;color:#1e3a8a}
::-webkit-scrollbar{width:10px;height:10px}
::-webkit-scrollbar-thumb{background:#cbd5e1;border-radius:8px}
::-webkit-scrollbar-thumb:hover{background:#94a3b8}
header.sticky{backdrop-filter:saturate(180%) blur(12px);background:rgba(255,255,255,.86)}
main>section:first-of-type{background:radial-gradient(56rem 28rem at 88% -12%,rgba(37,99,235,.10),transparent 60%),radial-gradient(40rem 22rem at -8% 18%,rgba(124,58,237,.07),transparent 60%)}
.card-link,a.group{transition:transform .22s ease,box-shadow .22s ease,border-color .22s ease}
.card-link:hover,a.group:hover{transform:translateY(-2px);box-shadow:0 14px 34px -16px rgba(37,99,235,.28);border-color:rgba(37,99,235,.4)}
a:focus-visible,button:focus-visible,input:focus-visible{outline:2px solid var(--brand);outline-offset:2px;border-radius:8px}
mark{background:#dbeafe;color:#1e40af;padding:0 .15em;border-radius:.25em}
.th-dd{position:absolute;left:0;right:0;top:calc(100% + 6px);background:#fff;border:1px solid #e5e5e5;border-radius:14px;box-shadow:0 18px 44px -18px rgba(2,6,23,.25);padding:6px;z-index:60;max-height:340px;overflow:auto}
.th-item{display:flex;align-items:center;gap:10px;width:100%;text-align:left;padding:9px 10px;border-radius:10px;font-size:14px;color:#171717;background:none;border:0;cursor:pointer}
.th-item:hover,.th-item.th-sel{background:#eff6ff}
.th-badge{flex:none;font-size:10px;font-weight:700;letter-spacing:.06em;text-transform:uppercase;color:#1d4ed8;background:#dbeafe;border-radius:999px;padding:3px 8px}
.th-title{min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.th-label{font-size:10px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:#a3a3a3;padding:6px 10px 4px}
.th-kbd{position:absolute;right:12px;top:50%;transform:translateY(-50%);font:600 11px/1 ui-monospace,monospace;color:#737373;background:#f5f5f5;border:1px solid #e5e5e5;border-bottom-width:2px;border-radius:6px;padding:3px 6px;pointer-events:none}
@media(max-width:640px){.th-kbd{display:none}}
.th-empty{max-width:640px;margin:24px auto;padding:20px;border:1px dashed #cbd5e1;border-radius:14px;background:#f8fafc;text-align:center}
.th-empty a{color:#1d4ed8;font-weight:600}
EOF

# ---------- 3) INSTANT SEARCH ENGINE (client-side) ----------
cat << 'EOF' > "$ASSET_DIR/search-enhance.js"
(function(){
var BASE='/My-edu-site',INDEX=null;
function load(){if(INDEX)return Promise.resolve(INDEX);return fetch(BASE+'/search-index.json').then(function(r){if(!r.ok)throw 0;return r.json()}).then(function(j){INDEX=j;return j}).catch(function(){INDEX=[];return[]})}
function esc(s){return String(s).replace(/[&<>"]/g,function(c){return{'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]})}
function hl(t,q){var i=String(t).toLowerCase().indexOf(q.toLowerCase());if(i<0||!q)return esc(t);return esc(t.slice(0,i))+'<mark>'+esc(t.slice(i,i+q.length))+'</mark>'+esc(t.slice(i+q.length))}
function score(it,toks){var s=0,T=(it.t||'').toLowerCase(),H=(it.h||'').toLowerCase(),D=(it.d||'').toLowerCase(),K=(it.k||'').toLowerCase();
for(var i=0;i<toks.length;i++){var t=toks[i],m=0;if(T.indexOf(t)>=0)m+=10;if(T.indexOf(t)===0)m+=4;if(H.indexOf(t)>=0)m+=4;if(K.indexOf(t)>=0)m+=3;if(D.indexOf(t)>=0)m+=2;if(!m)return 0;s+=m}return s}
function search(q,n){var toks=q.toLowerCase().split(/\s+/).filter(Boolean);if(!toks.length)return Promise.resolve([]);
return load().then(function(idx){var out=[];for(var i=0;i<idx.length;i++){var sc=score(idx[i],toks);if(sc>0)out.push([sc,idx[i]])}out.sort(function(a,b){return b[0]-a[0]});return out.slice(0,n||8).map(function(x){return x[1]})})}
function getRecent(){try{return JSON.parse(localStorage.getItem('th-recent')||'[]')}catch(e){return[]}}
function addRecent(q){if(!q)return;var r=getRecent().filter(function(x){return x!==q});r.unshift(q);localStorage.setItem('th-recent',JSON.stringify(r.slice(0,6)))}
function attach(input){
var form=input.closest('form');if(!form||form.dataset.thDone)return;form.dataset.thDone='1';form.style.position='relative';
input.placeholder='Search notes, past papers, books…';
var dd=document.createElement('div');dd.className='th-dd';dd.hidden=true;form.appendChild(dd);
var kbd=document.createElement('kbd');kbd.className='th-kbd';kbd.textContent='/';form.appendChild(kbd);
var sel=-1;
function open(h){dd.innerHTML=h;dd.hidden=false}
function close(){dd.hidden=true;sel=-1}
function renderRecent(){var r=getRecent();if(!r.length){close();return}
open('<div class="th-label">Recent searches</div>'+r.map(function(q){return '<button type="button" class="th-item th-recent" data-q="'+esc(q)+'">🕘 '+esc(q)+'</button>'}).join(''))}
function renderList(list,q){if(!list.length){close();return}
open(list.map(function(it){return '<a class="th-item" href="'+it.u+'"><span class="th-badge">'+esc(it.k||'Page')+'</span><span class="th-title">'+hl(it.t,q)+'</span></a>'}).join(''))}
var timer;
input.addEventListener('input',function(){var q=input.value.trim();clearTimeout(timer);if(!q){renderRecent();return}
timer=setTimeout(function(){search(q,8).then(function(l){renderList(l,q)})},120)});
input.addEventListener('focus',function(){if(!input.value.trim())renderRecent()});
dd.addEventListener('mousedown',function(e){var b=e.target.closest('.th-recent');if(b){e.preventDefault();input.value=b.getAttribute('data-q');input.dispatchEvent(new Event('input'));input.focus()}});
input.addEventListener('keydown',function(e){var links=dd.querySelectorAll('a.th-item');
if(e.key==='ArrowDown'||e.key==='ArrowUp'){if(dd.hidden)return;e.preventDefault();sel=e.key==='ArrowDown'?Math.min(sel+1,links.length-1):Math.max(sel-1,0);Array.prototype.forEach.call(links,function(l,i){l.classList.toggle('th-sel',i===sel)})}
else if(e.key==='Enter'){addRecent(input.value.trim());if(sel>=0&&links[sel]){e.preventDefault();location.href=links[sel].getAttribute('href')}}
else if(e.key==='Escape'){close()}});
document.addEventListener('click',function(e){if(!form.contains(e.target))close()})}
document.addEventListener('keydown',function(e){if((e.key==='/'||((e.ctrlKey||e.metaKey)&&(e.key==='k'||e.key==='K')))&&!/INPUT|TEXTAREA/.test(document.activeElement.tagName)){var inp=document.querySelector('input[name="q"],input[type="search"]');if(inp){e.preventDefault();inp.focus();inp.select()}}});
function enhanceResults(){if(!/\/search\/?$/.test(location.pathname))return;
var q=new URLSearchParams(location.search).get('q')||'';var main=document.querySelector('main')||document.body;
if(q){var w=document.createTreeWalker(main,NodeFilter.SHOW_TEXT),nodes=[];while(w.nextNode())nodes.push(w.currentNode);
nodes.forEach(function(n){var i=n.nodeValue.toLowerCase().indexOf(q.toLowerCase());if(i>=0&&n.parentNode.tagName!=='MARK'&&n.parentNode.tagName!=='SCRIPT'){var sp=document.createElement('span');sp.innerHTML=esc(n.nodeValue.slice(0,i))+'<mark>'+esc(n.nodeValue.slice(i,i+q.length))+'</mark>'+esc(n.nodeValue.slice(i+q.length));n.parentNode.replaceChild(sp,n)}})}
if(q&&/0 results|no results/i.test(main.textContent)){var box=document.createElement('div');box.className='th-empty';box.innerHTML='<strong>No exact matches for “'+esc(q)+'”</strong><p>Try: <a href="'+BASE+'/search?q=physics">physics</a> · <a href="'+BASE+'/search?q=math">math</a> · <a href="'+BASE+'/notes">browse notes</a> · <a href="'+BASE+'/boards">browse boards</a></p>';main.appendChild(box)}}
function init(){Array.prototype.forEach.call(document.querySelectorAll('input[name="q"],input[type="search"]'),attach);enhanceResults()}
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',init);else init()})();
EOF

# ---------- 4) SEARCH INDEX BUILDER (pure bash, no node/python needed) ----------
cat << 'EOF' > scripts/build-search-index.sh
#!/bin/bash
SCAN_DIR="${1:-.}"; OUT="${2:-search-index.json}"; BASE="/My-edu-site"
tmp=$(mktemp); echo "[" > "$tmp"; first=1
while IFS= read -r file; do
  rel="${file#./}"
  if [ "$rel" = "index.html" ]; then url="$BASE/"; else url="$BASE/${rel%.html}"; case "$url" in */index) url="${url%/index}/";; esac; fi
  title=$(grep -o '<title[^>]*>[^<]*</title>' "$file" 2>/dev/null | head -1 | sed -e 's/<[^>]*>//g')
  [ -z "$title" ] && continue
  desc=$(grep -o '<meta name="description" content="[^"]*"' "$file" 2>/dev/null | head -1 | sed -e 's/.*content="//' -e 's/"$//')
  h1=$(grep -o '<h1[^>]*>[^<]*' "$file" 2>/dev/null | head -1 | sed -e 's/<[^>]*>//g')
  case "$url" in
    *notes*) type="Note";; *past-papers*) type="Past Paper";; *guess-papers*) type="Guess Paper";;
    *pairing-schemes*) type="Pairing Scheme";; *quizzes*) type="Quiz";; *books*) type="Book";;
    *gazettes*) type="Gazette";; *board*) type="Board";; *) type="Page";;
  esac
  esc(){ printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | tr '\n' ' '; }
  [ $first -eq 1 ] && first=0 || echo "," >> "$tmp"
  printf '{"t":"%s","u":"%s","d":"%s","h":"%s","k":"%s"}' "$(esc "$title")" "$(esc "$url")" "$(esc "$desc")" "$(esc "$h1")" "$type" >> "$tmp"
done < <(find "$SCAN_DIR" -name '*.html' -not -path '*/.git/*' -not -path '*/node_modules/*' -not -name '404.html' | sort)
echo "]" >> "$tmp"; mv "$tmp" "$OUT"
echo "✅ Search index built: $(grep -o '"u":' "$OUT" | wc -l) pages -> $OUT"
EOF
chmod +x scripts/build-search-index.sh

# ---------- 5) WIRE ASSETS INTO PAGES ----------
TAGS='<link rel="stylesheet" href="/My-edu-site/polish.css">\n<script src="/My-edu-site/search-enhance.js" defer></script>'
if [ "$MODE" = "astro" ]; then
  LAYOUT=$(grep -rl '</head>' src/layouts src/components 2>/dev/null | head -1)
  if [ -n "$LAYOUT" ]; then sed -i "s|</head>|$TAGS</head>|" "$LAYOUT"; echo "✅ Tags injected into $LAYOUT"; fi
  sed -i 's|"build": "astro build"|"build": "astro build \&\& bash scripts/build-search-index.sh dist"|' package.json
  sed -i 's|"build":"astro build"|"build":"astro build \&\& bash scripts/build-search-index.sh dist"|' package.json
  echo "✅ Build hook added (index regenerates on every build)"
else
  find . -name '*.html' -not -path './.git/*' -exec sed -i "s|</head>|$TAGS</head>|" {} +
  bash scripts/build-search-index.sh . search-index.json
  echo "✅ Static mode: tags injected + index built now"
fi

echo ""
echo " UPGRADE COMPLETE!"
if [ "$MODE" = "astro" ]; then echo "Next: npm run build   (regenerates site + full search index)"; fi
echo "Then:  git add -A && git commit -m 'feat: instant search, new palette, UI polish' && git push"