# Astro + Supabase Blog Starter

Welcome to your **Astro + Supabase blog starter**! This repository contains a minimal yet scalable template for creating a content‑driven site with Astro, Tailwind CSS, React islands, and Supabase as the data source.  It is designed to be hosted on **GitHub Pages** with CI/CD powered by GitHub Actions.

## 🎯 Features

- **Astro v5** configured for a static build (`output: 'static'`) and optimized for GitHub Pages.
- **React islands architecture**—only interactive components (like the blog list and login widget) are hydrated on the client.
- **Tailwind CSS** integrated via `@astrojs/tailwind` and ready for custom styling.
- **Supabase client** initialized in `src/lib/supabase.ts` with environment variables for URL and anon key.
- **Simple email magic‑link authentication** (`AuthPanel.tsx`) for admin login.
- **Blog** page with dynamic routes (`src/pages/blog/[slug].astro`) and client‑side data fetching via Supabase.
- **GitHub Actions workflow** to automatically build and deploy the site to GitHub Pages.
- **Template‐ready**: you can mark this repo as a template in GitHub settings and use it for future projects.

## 🧑‍💻 Getting Started

1. **Clone or import the repository.**  Click the **“Use this template”** button on GitHub after you mark it as a template, or manually clone the repo.
2. **Rename `.env.example` to `.env`** and fill in your Supabase credentials:

   ```bash
   SUPABASE_URL=https://<your-project>.supabase.co
   SUPABASE_ANON_KEY=<your-anon-key>
   ```

   Supabase credentials are safe to publish; they’re public environment variables used for client‑side access.

3. **Install dependencies** (requires Node 18+ and `pnpm` or `npm`):

   ```bash
   pnpm install
   pnpm run dev
   ```

   The site runs locally at http://localhost:4321.

4. **Customize `astro.config.mjs`.** Set `site` to your GitHub Pages URL and `base` to your repository name if using a `<username>.github.io/<repo>` sub‑directory.  When deploying to a custom domain, remove `base` and update `site` accordingly.

5. **Push to GitHub.**  The included workflow file `.github/workflows/deploy.yml` will build and deploy your site automatically using the official Astro GitHub Action.  Add your Supabase credentials as repository secrets (`SUPABASE_URL` and `SUPABASE_ANON_KEY`) if you prefer not to commit them.

6. **(Optional) Configure a custom domain.**  Add your domain to `public/CNAME`, update `site` in `astro.config.mjs`, and point your DNS records to GitHub Pages.

## 🧱 Supabase Setup

Create a Supabase table named `posts` in the SQL editor:

```sql
create table if not exists posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid references auth.users(id),
  title text not null,
  slug text unique not null,
  content text not null,
  cover_url text,
  published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

Enable [**row‑level security** (RLS)](https://supabase.com/docs/guides/database/postgres/row-level-security) and add policies so published posts are readable by anyone while drafts are only visible to their authors:

```sql
alter table posts enable row level security;

create policy "read_published" on posts
  for select using (published = true);

create policy "author_select" on posts
  for select using (auth.uid() = author_id);

create policy "author_insert" on posts
  for insert with check (auth.uid() = author_id);

create policy "author_update" on posts
  for update using (auth.uid() = author_id);

create policy "author_delete" on posts
  for delete using (auth.uid() = author_id);
```

Once these policies are in place, your blog can safely read and write posts from the browser without exposing unpublished drafts to everyone.

## 🏗️ Extending This Starter

- **Add Markdown rendering.** Store Markdown in `content` and render it using MDX or a parser of your choice.
- **Create admin UI.** Add routes under `src/pages/admin` with React components to edit and publish posts.
- **Use Supabase Storage.** Upload images or videos to Supabase Storage buckets and reference them in your posts.
- **Analytics and SEO.** Integrate Umami or Plausible for analytics and set meta tags in `Base.astro` for better SEO.

## 📌 Marking as a Template

To make this repository a template on GitHub:

1. Go to your repository’s **Settings**.
2. Scroll down to **Features** → **Template repository** and tick the checkbox.
3. Now other repositories can click **“Use this template”** to start with the same structure.

## 💡 References

This starter follows best practices recommended in the official Astro and Supabase documentation:

- [Deploying Astro to GitHub Pages via GitHub Actions.](https://docs.astro.build/en/guides/deploy/github/)
- [Using environment variables and initializing the Supabase client in Astro.](https://docs.astro.build/en/guides/backend/supabase/)
- [Enabling row‑level security in Supabase to secure public tables.](https://supabase.com/docs/guides/database/postgres/row-level-security)

We hope this template helps you build a fast, scalable, and maintainable blog.  Happy building!
