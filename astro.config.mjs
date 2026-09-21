import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  site: 'https://malikjeerajajee-coder.github.io',
  base: '/My-edu-site',
  trailingSlash: 'ignore',
  integrations: [
    sitemap({
      serialize(item) {
        const u = item.url;
        // Exclude search page (it's noindex)
        if (/\/search\/?$/.test(u)) return undefined;
        // Homepage — highest priority
        if (u.match(/My-edu-site\/?$/)) return { ...item, priority: 1.0, changefreq: 'weekly' };
        // Board hubs (Punjab, Federal, KPK...)
        if (/\/board\/[^/]+\/?$/.test(u)) return { ...item, priority: 0.9, changefreq: 'weekly' };
        // Punjab BISE hubs
        if (/\/board\/punjab\/[^/]+\/?$/.test(u)) return { ...item, priority: 0.85, changefreq: 'monthly' };
        // Class hubs (board/class-N)
        if (/\/board\/[^/]+\/class-[0-9]+\/?$/.test(u)) return { ...item, priority: 0.8, changefreq: 'monthly' };
        // BISE + Class hub
        if (/\/board\/punjab\/[^/]+\/class-[0-9]+\/?$/.test(u)) return { ...item, priority: 0.75, changefreq: 'monthly' };
        // Subject or type hub
        if (/\/board\/[^/]+\/class-[0-9]+\/[^/]+\/?$/.test(u)) return { ...item, priority: 0.7, changefreq: 'monthly' };
        // BISE + Class + Subject
        if (/\/board\/punjab\/[^/]+\/class-[0-9]+\/[^/]+\/?$/.test(u)) return { ...item, priority: 0.65, changefreq: 'monthly' };
        // Notes / Quizzes index
        if (/\/(notes|quizzes|books|past-papers|guess-papers|pairing-schemes|gazettes)\/?$/.test(u))
          return { ...item, priority: 0.7, changefreq: 'weekly' };
        // Board listing
        if (/\/boards\/?$/.test(u)) return { ...item, priority: 0.8, changefreq: 'weekly' };
        // Individual papers / items
        if (/\/(past-papers|gazettes|notes|quizzes|books|guess-papers|pairing-schemes)\/[^/]+\/?$/.test(u))
          return { ...item, priority: 0.6, changefreq: 'yearly' };
        return { ...item, priority: 0.5, changefreq: 'monthly' };
      },
    }),
  ],
  vite: {
    server: {
      watch: {
        ignored: ['**/src/content/**', '**/dist/**', '**/.astro/**', '**/node_modules/**'],
      },
    }, plugins: [tailwindcss()] },
  prefetch: { prefetchAll: false, defaultStrategy: 'hover' },
});
