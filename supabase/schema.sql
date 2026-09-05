-- 秘Times DM 管理后台 V1
-- 在 Supabase SQL Editor 中完整执行一次。

create extension if not exists pgcrypto;

create table if not exists public.dm_profiles (
  id text primary key default encode(gen_random_bytes(8), 'hex'),
  name text not null,
  avatar text,
  gender text not null check (gender in ('男', '女')),
  years integer not null default 0 check (years >= 0),
  games_count integer not null default 0 check (games_count >= 0),
  intro text not null check (char_length(intro) between 10 and 20),
  tags text[] not null default '{}',
  script_types text[] not null default '{}',
  works text[] not null default '{}',
  suitable_players text not null default '',
  status text not null default 'hidden' check (status in ('published', 'unpublished', 'hidden')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint dm_tags_limit check (cardinality(tags) <= 5),
  constraint dm_works_limit check (cardinality(works) <= 3)
);

create or replace function public.set_dm_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists dm_profiles_updated_at on public.dm_profiles;
create trigger dm_profiles_updated_at
before update on public.dm_profiles
for each row execute procedure public.set_dm_updated_at();

do $$
begin
  alter publication supabase_realtime add table public.dm_profiles;
exception when duplicate_object then
  null;
end;
$$;

alter table public.dm_profiles enable row level security;

drop policy if exists "Public can read published DMs" on public.dm_profiles;
create policy "Public can read published DMs"
on public.dm_profiles for select
to anon, authenticated
using (status = 'published');

drop policy if exists "Admins can read all DMs" on public.dm_profiles;
create policy "Admins can read all DMs"
on public.dm_profiles for select
to authenticated
using (true);

drop policy if exists "Admins can insert DMs" on public.dm_profiles;
create policy "Admins can insert DMs"
on public.dm_profiles for insert
to authenticated
with check (true);

drop policy if exists "Admins can update DMs" on public.dm_profiles;
create policy "Admins can update DMs"
on public.dm_profiles for update
to authenticated
using (true)
with check (true);

drop policy if exists "Admins can delete DMs" on public.dm_profiles;
create policy "Admins can delete DMs"
on public.dm_profiles for delete
to authenticated
using (true);

insert into storage.buckets (id, name, public)
values ('dm-avatars', 'dm-avatars', true)
on conflict (id) do update set public = true;

drop policy if exists "Public can view DM avatars" on storage.objects;
create policy "Public can view DM avatars"
on storage.objects for select
to public
using (bucket_id = 'dm-avatars');

drop policy if exists "Admins can upload DM avatars" on storage.objects;
create policy "Admins can upload DM avatars"
on storage.objects for insert
to authenticated
with check (bucket_id = 'dm-avatars');

drop policy if exists "Admins can update DM avatars" on storage.objects;
create policy "Admins can update DM avatars"
on storage.objects for update
to authenticated
using (bucket_id = 'dm-avatars')
with check (bucket_id = 'dm-avatars');

drop policy if exists "Admins can delete DM avatars" on storage.objects;
create policy "Admins can delete DM avatars"
on storage.objects for delete
to authenticated
using (bucket_id = 'dm-avatars');

-- 后台只需一个管理员账号：在 Authentication > Users 中手动创建 Email/Password 用户。
-- 不要开启公开注册；如需关闭注册，在 Authentication > Providers > Email 中关闭 Allow new users。
