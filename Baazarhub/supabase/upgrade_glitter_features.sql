-- Run this once in Supabase SQL Editor for an existing BazaarHub database.
-- Adds profile photos and product reviews without removing existing data.

alter table public.profiles
  add column if not exists avatar_url text not null default '';

create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  user_id uuid not null references public.seller_profiles(id) on delete cascade,
  rating integer not null check (rating between 1 and 5),
  comment text not null check (char_length(comment) between 3 and 800),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (product_id, user_id)
);

create index if not exists reviews_product_created_idx
  on public.reviews (product_id, created_at desc);

alter table public.reviews enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'reviews'
      and policyname = 'Anyone reads product reviews'
  ) then
    create policy "Anyone reads product reviews"
      on public.reviews for select using (true);
  end if;
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'reviews'
      and policyname = 'Users create their own reviews'
  ) then
    create policy "Users create their own reviews"
      on public.reviews for insert to authenticated
      with check (auth.uid() = user_id);
  end if;
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'reviews'
      and policyname = 'Users update their own reviews'
  ) then
    create policy "Users update their own reviews"
      on public.reviews for update to authenticated
      using (auth.uid() = user_id) with check (auth.uid() = user_id);
  end if;
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'reviews'
      and policyname = 'Users delete their own reviews'
  ) then
    create policy "Users delete their own reviews"
      on public.reviews for delete to authenticated
      using (auth.uid() = user_id);
  end if;
end
$$;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'avatars', 'avatars', true, 5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'storage' and tablename = 'objects'
      and policyname = 'Public can view avatars'
  ) then
    create policy "Public can view avatars"
      on storage.objects for select using (bucket_id = 'avatars');
  end if;
  if not exists (
    select 1 from pg_policies
    where schemaname = 'storage' and tablename = 'objects'
      and policyname = 'Users upload their own avatars'
  ) then
    create policy "Users upload their own avatars"
      on storage.objects for insert to authenticated with check (
        bucket_id = 'avatars'
        and (storage.foldername(name))[1] = auth.uid()::text
      );
  end if;
  if not exists (
    select 1 from pg_policies
    where schemaname = 'storage' and tablename = 'objects'
      and policyname = 'Users update their own avatars'
  ) then
    create policy "Users update their own avatars"
      on storage.objects for update to authenticated using (
        bucket_id = 'avatars' and owner_id = auth.uid()::text
      );
  end if;
  if not exists (
    select 1 from pg_policies
    where schemaname = 'storage' and tablename = 'objects'
      and policyname = 'Users delete their own avatars'
  ) then
    create policy "Users delete their own avatars"
      on storage.objects for delete to authenticated using (
        bucket_id = 'avatars' and owner_id = auth.uid()::text
      );
  end if;
end
$$;
