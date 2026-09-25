#!/bin/bash
# sidebar-v3.sh — Save My Exams-style tree sidebar (marker-based, robust)
cd ~/my-edu-site

echo "▶ Backing up"
cp src/layouts/BaseLayout.astro src/layouts/BaseLayout.astro.v3bak

echo "▶ Applying sidebar v3"
python3 << 'PYEOF'
path = 'src/layouts/BaseLayout.astro'
c = open(path).read()

# ═══════════ 1. FRONTMATTER ═══════════
a = c.index('// Nav data')
b = c.index('// Shared sidebar markup')
b = c.index('\n', b) + 1  # include that comment line

new_fm = '''// Nav tree (Save My Exams style)
const CLASS_NUMS = ['9', '10', '11', '12'];

const navTree: any[] = [
  {
    label: 'Browse',
    items: [
      { href: '/',       label: 'Home',       icon: 'home' },
      { href: '/boards', label: 'All boards', icon: 'graduation-cap' },
      { href: '/books',  label: 'Textbooks',  icon: 'book-marked' },
    ],
  },
  {
    label: 'By class',
    items: CLASS_NUMS.map((n: string) => ({
      href: `/class/${n}`,
      label: `Class ${n}`,
      children: [
        { href: `/class/${n}`,             label: 'Overview' },
        { href: `/class/${n}/notes`,       label: 'Notes' },
        { href: `/class/${n}/past-papers`, label: 'Past papers' },
        { href: `/class/${n}/quizzes`,     label: 'Quizzes' },
        { href: `/class/${n}/books`,       label: 'Textbooks' },
      ],
    })),
  },
  {
    label: 'By board',
    items: ([
      { slug: 'punjab',      name: 'Punjab' },
      { slug: 'federal',     name: 'Federal' },
      { slug: 'sindh',       name: 'Sindh' },
      { slug: 'kpk',         name: 'KPK' },
      { slug: 'balochistan', name: 'Balochistan' },
      { slug: 'ajk',         name: 'AJK' },
    ] as { slug: string; name: string }[]).map(bd => ({
      href: `/board/${bd.slug}`,
      label: bd.name,
      children: CLASS_NUMS.map((n: string) => ({
        href: `/board/${bd.slug}/class-${n}`,
        label: `Class ${n}`,
      })),
    })),
  },
  {
    label: 'Exam prep',
    items: [
      { href: '/past-papers',     label: 'Past papers',     icon: 'scroll-text' },
      { href: '/guess-papers',    label: 'Guess papers',    icon: 'sparkles' },
      { href: '/pairing-schemes', label: 'Pairing schemes', icon: 'list' },
      { href: '/gazettes',        label: 'Result gazettes', icon: 'newspaper' },
    ],
  },
];

const isActive = (href: string) => {
  if (href === '/') return pathname === '/' || pathname === '';
  const h = href.replace(/\\/$/, '');
  const p = pathname.replace(/\\/$/, '');
  return p === h || p.startsWith(h + '/');
};

const branchActive = (item: any): boolean =>
  isActive(item.href) || (item.children || []).some((ch: any) => isActive(ch.href));

'''
c = c[:a] + new_fm + c[b:]

# ═══════════ 2. NAV MARKUP (shared string, inserted twice) ═══════════
NAV = '''<nav class="flex-1 overflow-y-auto px-2 py-3">
        {navTree.map(sec => (
          <div class="mb-5">
            <div class="mb-1 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-slate-400">
              {sec.label}
            </div>
            <ul class="space-y-px">
              {sec.items.map(item => (
                item.children ? (
                  <li>
                    <details class="group/d" open={branchActive(item)}>
                      <summary
                        class:list={[
                          "flex cursor-pointer select-none list-none items-center gap-2 rounded-lg px-3 py-[7px] text-[13px] font-semibold transition-colors",
                          isActive(item.href)
                            ? "text-[#1d4ed8]"
                            : "text-slate-700 hover:bg-slate-100 hover:text-slate-900",
                        ]}
                      >
                        <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round" class="shrink-0 text-slate-400 transition-transform duration-150"><path d="m9 18 6-6-6-6"/></svg>
                        <span class="truncate">{item.label}</span>
                      </summary>
                      <ul class="ml-[19px] mt-0.5 space-y-px border-l border-slate-200 pl-2">
                        {item.children.map(child => (
                          <li>
                            <a
                              href={url(child.href)}
                              aria-current={isActive(child.href) ? 'page' : undefined}
                              class:list={[
                                "flex items-center rounded-md px-2.5 py-[6px] text-[12.5px] transition-colors",
                                isActive(child.href)
                                  ? "bg-[#eff4ff] font-semibold text-[#1d4ed8]"
                                  : "font-medium text-slate-500 hover:bg-slate-50 hover:text-slate-800",
                              ]}
                            >
                              <span class="truncate">{child.label}</span>
                            </a>
                          </li>
                        ))}
                      </ul>
                    </details>
                  </li>
                ) : (
                  <li>
                    <a
                      href={url(item.href)}
                      aria-current={isActive(item.href) ? 'page' : undefined}
                      class:list={[
                        "flex items-center gap-2.5 rounded-lg px-3 py-2 text-[13px] font-semibold transition-colors",
                        isActive(item.href)
                          ? "bg-[#eff4ff] text-[#1d4ed8]"
                          : "text-slate-600 hover:bg-slate-100 hover:text-slate-900",
                      ]}
                    >
                      {item.icon && <Icon name={item.icon} size={15} strokeWidth={2.1} class="shrink-0" />}
                      <span class="truncate">{item.label}</span>
                    </a>
                  </li>
                )
              ))}
            </ul>
          </div>
        ))}
      </nav>'''

# ═══════════ 3. DESKTOP SIDEBAR ═══════════
a = c.index('<!-- ═══════ DESKTOP SIDEBAR ═══════ -->')
b = c.index('<!-- ═══════ MOBILE HEADER ═══════ -->')

NEW_DESKTOP = '''<!-- ═══════ DESKTOP SIDEBAR ═══════ -->
    <aside class="fixed top-0 bottom-0 left-0 z-40 hidden w-[260px] flex-col border-r border-slate-200 bg-white lg:flex">
      <div class="flex h-[68px] shrink-0 items-center gap-2.5 border-b border-slate-200 px-5">
        <a href={url('/')} class="flex min-w-0 flex-1 items-center gap-2.5">
          <img src={url('/logo-icon-64.png')} alt="Parhayi" width="32" height="32" style="border-radius: 8px; display: block; flex-shrink: 0;" />
          <span class="truncate font-display text-[17px] font-extrabold tracking-tight text-slate-900">Parhayi</span>
        </a>
      </div>

      <div class="shrink-0 border-b border-slate-200 px-3 py-3">
        <form action={url('/search')} method="get" role="search" class="flex items-center gap-2 rounded-lg border border-slate-200 bg-slate-50 px-3 py-2 transition-colors focus-within:border-[#1d4ed8] focus-within:bg-white">
          <Icon name="search" size={13} strokeWidth={2.3} class="shrink-0 text-slate-400" />
          <input type="search" name="q" placeholder="Search library…" class="min-w-0 flex-1 bg-transparent text-[12.5px] font-medium text-slate-900 outline-none placeholder:text-slate-400" />
        </form>
      </div>

      ''' + NAV + '''

      <div class="shrink-0 border-t border-slate-200 px-3 py-3">
        <div class="flex items-center justify-center gap-2 text-[10.5px] font-medium text-slate-400">
          <a href={url('/about')} class="hover:text-slate-700">About</a>
          <span class="text-slate-300">·</span>
          <a href={url('/contact')} class="hover:text-slate-700">Contact</a>
          <span class="text-slate-300">·</span>
          <a href={url('/privacy')} class="hover:text-slate-700">Privacy</a>
        </div>
      </div>
    </aside>

    '''
c = c[:a] + NEW_DESKTOP + c[b:]

# ═══════════ 4. MOBILE DRAWER ═══════════
a = c.index('<!-- ═══════ MOBILE DRAWER ═══════ -->')
b = c.index('<!-- ═══════ CONTENT ═══════ -->')

NEW_MOBILE = '''<!-- ═══════ MOBILE DRAWER ═══════ -->
    <div id="mobile-drawer" class="fixed inset-0 z-50 hidden lg:hidden">
      <div id="mobile-drawer-backdrop" class="absolute inset-0 bg-slate-900/50 opacity-0 transition-opacity duration-300"></div>

      <aside
        id="mobile-drawer-panel"
        class="absolute top-0 bottom-0 left-0 flex w-[288px] flex-col border-r border-slate-200 bg-white"
        style="transform: translateX(-100%); transition: transform .3s cubic-bezier(0.16, 1, 0.3, 1);"
      >
        <div class="flex h-[68px] shrink-0 items-center gap-2.5 border-b border-slate-200 px-5">
          <a href={url('/')} class="flex min-w-0 flex-1 items-center gap-2.5">
            <img src={url('/logo-icon-64.png')} alt="Parhayi" width="32" height="32" style="border-radius: 8px; display: block; flex-shrink: 0;" />
            <span class="truncate font-display text-[17px] font-extrabold tracking-tight text-slate-900">Parhayi</span>
          </a>
          <button
            type="button"
            id="close-sidebar"
            aria-label="Close menu"
            class="grid h-8 w-8 shrink-0 place-items-center rounded-md text-slate-500 transition-colors hover:bg-slate-100"
          >
            <Icon name="x" size={16} strokeWidth={2.4} />
          </button>
        </div>

        <div class="shrink-0 border-b border-slate-200 px-3 py-3">
          <form action={url('/search')} method="get" role="search" class="flex items-center gap-2 rounded-lg border border-slate-200 bg-slate-50 px-3 py-2">
            <Icon name="search" size={13} strokeWidth={2.3} class="shrink-0 text-slate-400" />
            <input type="search" name="q" placeholder="Search library…" class="min-w-0 flex-1 bg-transparent text-[12.5px] font-medium text-slate-900 outline-none placeholder:text-slate-400" />
          </form>
        </div>

        ''' + NAV + '''

        <div class="shrink-0 border-t border-slate-200 px-3 py-3">
          <div class="flex items-center justify-center gap-2 text-[10.5px] font-medium text-slate-400">
            <a href={url('/about')} class="hover:text-slate-700">About</a>
            <span class="text-slate-300">·</span>
            <a href={url('/contact')} class="hover:text-slate-700">Contact</a>
            <span class="text-slate-300">·</span>
            <a href={url('/privacy')} class="hover:text-slate-700">Privacy</a>
          </div>
        </div>
      </aside>
    </div>

    '''
c = c[:a] + NEW_MOBILE + c[b:]

# ═══════════ 5. GLOBAL STYLE for <summary> markers ═══════════
if 'summary::-webkit-details-marker' not in c:
    c = c.replace(
        '</head>',
        '''  <style is:global>
    summary::-webkit-details-marker { display: none; }
    summary { list-style: none; cursor: pointer; }
    details[open] > summary svg { transform: rotate(90deg); }
  </style>
</head>''',
        1,
    )

open(path, 'w').write(c)

# Sanity check
assert 'navTree' in c, 'navTree not written'
assert 'navSections' not in c, 'old navSections still present'
print('✓ BaseLayout.astro fully rewritten')
PYEOF

echo ""
echo "▶ Verifying edits landed"
grep -c "navTree" src/layouts/BaseLayout.astro && echo "  navTree present"
grep -c "navSections" src/layouts/BaseLayout.astro || echo "  navSections gone (expected)"

echo ""
echo "▶ Building (5–8 min) — capturing errors"
if npm run build 2>&1 | tee /tmp/build.log; then
  echo ""
  echo "════════════════════════════════════════"
  echo "  ✓ BUILD SUCCEEDED"
  echo "════════════════════════════════════════"
  echo ""
  echo "Preview:  bash preview.sh"
  echo "Push:     git add . && git commit -m 'Sidebar v3 — tree nav' && git push"
else
  echo ""
  echo "════════════════════════════════════════"
  echo "  ✗ BUILD FAILED — last 40 lines:"
  echo "════════════════════════════════════════"
  tail -40 /tmp/build.log
  echo ""
  echo "▶ Restoring backup"
  cp src/layouts/BaseLayout.astro.v3bak src/layouts/BaseLayout.astro
  echo "▶ Restored. Paste the error above."
  exit 1
fi