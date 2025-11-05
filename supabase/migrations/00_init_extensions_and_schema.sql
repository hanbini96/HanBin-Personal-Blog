-- Extensions
create extension if not exists "pgcrypto";
create extension if not exists "pg_trgm";
create extension if not exists "uuid-ossp";

-- Public.users (profile shadow of auth.users)
create table if not exists public.users (
  id uuid primary key,
  email text,
  display_name text,
  avatar_url text,
  bio text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists users_display_name_idx
  on public.users using gin (display_name gin_trgm_ops);

-- Public.posts
create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid references public.users(id) on delete set null,
  title text not null,
  slug text not null unique,
  content text not null,
  cover_url text,
  published boolean not null default false,
  published_at timestamptz,
  views integer not null default 0,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists posts_author_idx on public.posts (author_id);
create index if not exists posts_published_idx on public.posts (published, published_at desc);
create index if not exists posts_slug_trgm_idx on public.posts using gin (slug gin_trgm_ops);

-- Public.comments
create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  author_id uuid references public.users(id) on delete set null,
  body text not null,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists comments_post_idx on public.comments (post_id, created_at desc);
