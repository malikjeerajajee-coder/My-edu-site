import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  // TODO: change to https://parhayi.com when your custom domain is live.
  // For now, this matches the Cloudflare Pages project name.
  site: 'https://malikjeerajajee-coder.github.io',
  base: '/My-edu-site',
  trailingSlash: 'ignore',
  vite: {
    plugins: [tailwindcss()],
    server: {
      watch: {
        ignored: ['**/src/content/**', '**/dist/**', '**/.astro/**', '**/node_modules/**'],
      },
    },
  },
  integrations: [
    sitemap({
      serialize(item) {
        const u = item.url;
        // Exclude search page (it's noindex)
        if (/\/search\/?$/.test(u)) return undefined;
        // Homepage
        if (/^https?:\/\/[^/]+\/?$/.test(u)) return { ...item, priority: 1.0, changefreq: 'weekly' };
        // Board hubs (Punjab, Federal, etc.)
        if (/\/board\/[^/]+\/?$/.test(u)) return { ...item, priority: 0.9, changefreq: 'weekly' };
        // Punjab BISE hubs
        if (/\/board\/[^/]+\/[^/]+\/?$/.test(u)) return { ...item, priority: 0.85, changefreq: 'monthly' };
        // Class hubs
        if (/\/board\/[^/]+\/class-[0-9]+\/?$/.test(u)) return { ...item, priority: 0.8, changefreq: 'monthly' };
        // BISE + Class
        if (/\/board\/[^/]+\/[^/]+\/class-[0-9]+\/?$/.test(u)) return { ...item, priority: 0.75, changefreq: 'monthly' };
        // Subject / type hub
        if (/\/board\/[^/]+\/class-[0-9]+\/[^/]+\/?$/.test(u)) return { ...item, priority: 0.7, changefreq: 'monthly' };
        // Type index pages (notes, quizzes, books, past-papers...)
        if (/\/(notes|quizzes|books|past-papers|guess-papers|pairing-schemes|gazettes|classes|subjects)\/?$/.test(u))
          return { ...item, priority: 0.7, changefreq: 'weekly' };
        // Boards listing
        if (/\/boards\/?$/.test(u)) return { ...item, priority: 0.8, changefreq: 'weekly' };
        // Class-first routes
        if (/\/class\/[0-9]+\/?$/.test(u)) return { ...item, priority: 0.75, changefreq: 'monthly' };
        // Type hub for class
        if (/\/class\/[0-9]+\/[^/]+\/?$/.test(u)) return { ...item, priority: 0.7, changefreq: 'monthly' };
        // Detail pages (individual items)
        if (/\/(past-papers|gazettes|note|quiz|books|guess-papers|pairing-schemes|textbook)\/[^/]+\/?$/.test(u))
          return { ...item, priority: 0.6, changefreq: 'yearly' };
        return { ...item, priority: 0.5, changefreq: 'monthly' };
      },
    }),
  ],
  prefetch: { prefetchAll: false, defaultStrategy: 'hover' },
});
