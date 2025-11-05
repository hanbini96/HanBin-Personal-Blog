-- Views
create or replace view public.v_published_posts as
select
  p.id, p.title, p.slug, p.content, p.cover_url, p.views,
  p.published, p.published_at, p.created_at, p.updated_at,
  u.id as author_id, coalesce(u.display_name, u.email) as author_name,
  u.avatar_url as author_avatar_url
from public.posts p
left join public.users u on u.id = p.author_id
where p.published = true and p.deleted_at is null;

create or replace view public.v_user_profile as
select u.id, u.email, u.display_name, u.avatar_url, u.bio, u.created_at, u.updated_at
from public.users u;

create or replace view public.v_post_with_comments as
select
  p.id as post_id, p.title, p.slug, p.content, p.cover_url, p.views,
  p.published, p.published_at, p.created_at as post_created_at,
  u.id as post_author_id, coalesce(u.display_name, u.email) as post_author_name,
  c.id as comment_id, c.body as comment_body, c.created_at as comment_created_at,
  cu.id as comment_author_id, coalesce(cu.display_name, cu.email) as comment_author_name
from public.posts p
left join public.users u  on u.id  = p.author_id
left join public.comments c on c.post_id = p.id and c.deleted_at is null
left join public.users cu on cu.id = c.author_id
where p.deleted_at is null;

-- Functions
create or replace function public.generate_unique_slug(base text)
returns text
language plpgsql
as $$
declare
  slug_base text := lower(regexp_replace(trim(base), '[^a-z0-9]+', '-', 'g'));
  slug_candidate text := slug_base;
  n int := 1;
begin
  if slug_base is null or slug_base = '' then
    slug_base := 'post';
    slug_candidate := slug_base;
  end if;

  while exists (select 1 from public.posts where slug = slug_candidate) loop
    n := n + 1;
    slug_candidate := slug_base || '-' || n::text;
  end loop;

  return slug_candidate;
end;
$$;

create or replace function public.increment_post_views(p_slug text)
returns void language sql as $$
  update public.posts
     set views = views + 1, updated_at = now()
   where slug = p_slug and published = true and deleted_at is null;
$$;

create or replace function public.publish_post(p_id uuid)
returns void language plpgsql as $$
begin
  update public.posts
     set published = true, published_at = now(), updated_at = now()
   where id = p_id and author_id = auth.uid();
end;
$$;

create or replace function public.soft_delete(table_name text, row_id uuid)
returns void language plpgsql as $$
declare sql text;
begin
  if table_name not in ('posts','comments') then
    raise exception 'soft_delete not allowed for table: %', table_name;
  end if;
  sql := format('update public.%I set deleted_at = now(), updated_at = now() where id = $1 and (author_id = auth.uid() or auth.uid() is null)', table_name);
  execute sql using row_id;
end;
$$;

-- Triggers
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_posts_updated_at on public.posts;
create trigger set_posts_updated_at
before update on public.posts for each row execute function public.set_updated_at();

drop trigger if exists set_comments_updated_at on public.comments;
create trigger set_comments_updated_at
before update on public.comments for each row execute function public.set_updated_at();

drop trigger if exists set_users_updated_at on public.users;
create trigger set_users_updated_at
before update on public.users for each row execute function public.set_updated_at();

-- Sync auth.users -> public.users
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.users (id, email, display_name, avatar_url, created_at, updated_at)
  values (new.id, new.email, coalesce(new.raw_user_meta_data->>'name', new.email),
          new.raw_user_meta_data->>'avatar_url', now(), now())
  on conflict (id) do update
    set email = excluded.email,
        display_name = excluded.display_name,
        avatar_url = excluded.avatar_url,
        updated_at = now();
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();
