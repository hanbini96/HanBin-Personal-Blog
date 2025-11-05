-- Enable RLS
alter table public.users    enable row level security;
alter table public.posts    enable row level security;
alter table public.comments enable row level security;

-- USERS policies
create policy users_read_public
  on public.users for select using (true);

create policy users_update_self
  on public.users for update using (auth.uid() = id);

-- POSTS policies
create policy posts_read_published
  on public.posts for select
  using (published = true and deleted_at is null);

create policy posts_read_own_drafts
  on public.posts for select
  using (auth.uid() = author_id);

create policy posts_insert_own
  on public.posts for insert
  with check (auth.uid() = author_id);

create policy posts_update_own
  on public.posts for update
  using (auth.uid() = author_id);

create policy posts_delete_own
  on public.posts for delete
  using (auth.uid() = author_id);

-- COMMENTS policies
create policy comments_read_public
  on public.comments for select
  using (
    deleted_at is null and
    exists (
      select 1 from public.posts p
       where p.id = comments.post_id
         and p.published = true
         and p.deleted_at is null
    )
  );

create policy comments_read_own
  on public.comments for select
  using (auth.uid() = author_id);

create policy comments_insert_own
  on public.comments for insert
  with check (auth.uid() = author_id);

create policy comments_update_own
  on public.comments for update
  using (auth.uid() = author_id);

create policy comments_delete_own
  on public.comments for delete
  using (auth.uid() = author_id);

-- Grants (roles are auto-managed by Supabase)
grant usage on schema public to anon, authenticated;
grant select on all tables in schema public to anon, authenticated;
alter default privileges in schema public grant select on tables to anon, authenticated;
