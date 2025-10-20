import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';
import react from '@astrojs/react';

// Astro configuration for a static site hosted on GitHub Pages.
// Set `site` to your GitHub Pages URL (e.g. https://username.github.io/repository).
// Set `base` to your repository name prefixed with a slash when using the
// <username>.github.io/<repo> pattern. Remove `base` when deploying to a
// custom domain or <username>.github.io root repository.
export default defineConfig({
  site: 'https://your-username.github.io/your-repo',
  base: '/your-repo',
  output: 'static',
  integrations: [react(), tailwind()]
});