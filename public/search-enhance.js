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
