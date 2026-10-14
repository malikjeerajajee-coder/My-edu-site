# TaleemMarkaz Design System

**The single source of truth for every page on taleemmarkaz.com.**
Read this before creating or editing any page. If a page violates this, fix it.

---

## Principle

Minimal. White. Slate. One blue accent. Generous whitespace.
The homepage is the reference. Every other page must look like it belongs to the same site.

---

## Colors

| Token | Value | Used for |
|---|---|---|
| Background | `bg-white` | Default |
| Tinted section | `bg-slate-50` | Alternating sections |
| Border | `border-slate-200` | All dividers, cards |
| Primary text | `text-slate-900` | Headings, primary content |
| Secondary text | `text-slate-600` | Body paragraphs |
| Muted text | `text-slate-400` / `text-slate-500` | Labels, micro copy |
| **Accent** | `#1d4ed8` | Dot, primary button, link hover — nowhere else |

**Never use:** gradients, red/green/orange accents, colored card borders, more than one shade of blue.

---

## Typography

Font: `font-display` (Plus Jakarta Sans). Apply to H1, H2, H3, stats, big numbers.

| Element | Classes |
|---|---|
| H1 | `text-4xl sm:text-5xl lg:text-6xl font-extrabold leading-[1.05] tracking-tight text-slate-900` |
| H2 (section) | `text-2xl font-extrabold tracking-tight text-slate-900` |
| H2 (long-form) | `text-3xl sm:text-4xl font-extrabold tracking-tight text-slate-900` |
| H3 | `text-lg font-extrabold text-slate-900` |
| Body | `text-base leading-relaxed text-slate-600 sm:text-lg` |
| Small body | `text-sm leading-relaxed text-slate-500` |
| Micro label | `text-[10px] sm:text-[11px] font-bold uppercase tracking-[0.14em] text-slate-400` |

---

## Layout

**Standard container:**