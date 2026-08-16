-- BazaarHub secure marketplace schema
-- Run this once in Supabase Dashboard > SQL Editor.

create extension if not exists pgcrypto;

create type public.product_condition as enum ('new', 'used');
create type public.order_status as enum (
  'pending', 'confirmed', 'shipped', 'delivered', 'cancelled'
);

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null check (char_length(full_name) between 2 and 80),
  email text not null,
  phone text not null default '',
  address text not null default '',
  avatar_url text not null default '',
  role text not null default 'user' check (role in ('user', 'admin')),
  created_at timestamptz not null default now()
);

-- Public seller identity is separated from private contact/address data.
create table public.seller_profiles (
  id uuid primary key references public.profiles(id) on delete cascade,
  full_name text not null check (char_length(full_name) between 2 and 80),
  is_verified boolean not null default false
);

create table public.products (
  id uuid primary key default gen_random_uuid(),
  seller_id uuid not null references public.seller_profiles(id) on delete cascade,
  title text not null check (char_length(title) between 3 and 120),
  description text not null check (char_length(description) between 10 and 2000),
  category text not null check (char_length(category) between 2 and 50),
  price numeric(12,2) not null check (price > 0),
  image_url text not null default '',
  condition public.product_condition not null default 'new',
  stock integer not null default 1 check (stock >= 0 and stock <= 100000),
  is_active boolean not null default true,
  is_featured boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.favorites (
  user_id uuid not null references public.profiles(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, product_id)
);

create table public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_id uuid not null references public.profiles(id),
  total numeric(12,2) not null check (total >= 0),
  status public.order_status not null default 'pending',
  payment_method text not null check (
    payment_method in ('Cash on Delivery', 'Demo Card Payment')
  ),
  payment_status text not null default 'pending' check (
    payment_status in ('pending', 'paid', 'failed', 'refunded')
  ),
  shipping_address text not null check (char_length(shipping_address) between 10 and 500),
  created_at timestamptz not null default now()
);

create table public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid not null references public.products(id),
  seller_id uuid not null references public.profiles(id),
  product_title text not null,
  unit_price numeric(12,2) not null check (unit_price > 0),
  quantity integer not null check (quantity > 0),
  line_total numeric(12,2) generated always as (unit_price * quantity) stored
);

create table public.reviews (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  user_id uuid not null references public.seller_profiles(id) on delete cascade,
  rating integer not null check (rating between 1 and 5),
  comment text not null check (char_length(comment) between 3 and 800),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (product_id, user_id)
);

create index products_active_created_idx
  on public.products (is_active, created_at desc);
create index products_seller_idx on public.products (seller_id);
create index orders_buyer_idx on public.orders (buyer_id, created_at desc);
create index order_items_seller_idx on public.order_items (seller_id, order_id);
create index reviews_product_created_idx
  on public.reviews (product_id, created_at desc);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name, email)
  values (
    new.id,
    coalesce(nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''), 'BazaarHub User'),
    coalesce(new.email, '')
  );
  insert into public.seller_profiles (id, full_name)
  values (
    new.id,
    coalesce(nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''), 'BazaarHub User')
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

create or replace function public.create_marketplace_order(
  p_shipping_address text,
  p_payment_method text,
  p_items jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_order_id uuid;
  v_order_number text;
  v_total numeric(12,2) := 0;
  v_item jsonb;
  v_product public.products%rowtype;
  v_quantity integer;
begin
  if v_user_id is null then
    raise exception 'Authentication required';
  end if;
  if char_length(trim(p_shipping_address)) < 10 then
    raise exception 'Complete shipping address required';
  end if;
  if p_payment_method not in ('Cash on Delivery', 'Demo Card Payment') then
    raise exception 'Unsupported payment method';
  end if;
  if jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then
    raise exception 'Cart is empty';
  end if;

  -- Lock products and calculate totals from trusted database prices.
  for v_item in select * from jsonb_array_elements(p_items)
  loop
    v_quantity := (v_item ->> 'quantity')::integer;
    if v_quantity < 1 then raise exception 'Invalid quantity'; end if;

    select * into v_product
    from public.products
    where id = (v_item ->> 'product_id')::uuid and is_active = true
    for update;

    if not found then raise exception 'Product unavailable'; end if;
    if v_product.stock < v_quantity then
      raise exception 'Not enough stock for %', v_product.title;
    end if;
    v_total := v_total + (v_product.price * v_quantity);
  end loop;

  v_order_number := 'BH-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 10));
  insert into public.orders (
    order_number, buyer_id, total, status, payment_method,
    payment_status, shipping_address
  ) values (
    v_order_number, v_user_id, v_total, 'confirmed', p_payment_method,
    case when p_payment_method = 'Demo Card Payment' then 'paid' else 'pending' end,
    trim(p_shipping_address)
  ) returning id into v_order_id;

  for v_item in select * from jsonb_array_elements(p_items)
  loop
    v_quantity := (v_item ->> 'quantity')::integer;
    select * into v_product
    from public.products
    where id = (v_item ->> 'product_id')::uuid
    for update;

    insert into public.order_items (
      order_id, product_id, seller_id, product_title, unit_price, quantity
    ) values (
      v_order_id, v_product.id, v_product.seller_id,
      v_product.title, v_product.price, v_quantity
    );
    update public.products
    set stock = stock - v_quantity, updated_at = now()
    where id = v_product.id;
  end loop;

  return jsonb_build_object(
    'id', v_order_id,
    'order_number', v_order_number,
    'total', v_total
  );
end;
$$;

revoke all on function public.create_marketplace_order(text, text, jsonb) from public;
grant execute on function public.create_marketplace_order(text, text, jsonb) to authenticated;

alter table public.profiles enable row level security;
alter table public.seller_profiles enable row level security;
alter table public.products enable row level security;
alter table public.favorites enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.reviews enable row level security;

create policy "Users read their own private profile"
  on public.profiles for select to authenticated using (auth.uid() = id);
create policy "Users update their own profile"
  on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);

create policy "Seller names are publicly readable"
  on public.seller_profiles for select using (true);

create policy "Active products are publicly readable"
  on public.products for select using (is_active = true or auth.uid() = seller_id);
create policy "Authenticated users create their products"
  on public.products for insert to authenticated with check (auth.uid() = seller_id);
create policy "Sellers update their products"
  on public.products for update to authenticated
  using (auth.uid() = seller_id) with check (auth.uid() = seller_id);
create policy "Sellers delete their products"
  on public.products for delete to authenticated using (auth.uid() = seller_id);

create policy "Users read their favorites"
  on public.favorites for select to authenticated using (auth.uid() = user_id);
create policy "Users add their favorites"
  on public.favorites for insert to authenticated with check (auth.uid() = user_id);
create policy "Users remove their favorites"
  on public.favorites for delete to authenticated using (auth.uid() = user_id);

create policy "Buyers read their orders"
  on public.orders for select to authenticated using (auth.uid() = buyer_id);
create policy "Order parties read line items"
  on public.order_items for select to authenticated using (
    auth.uid() = seller_id or exists (
      select 1 from public.orders o
      where o.id = order_id and o.buyer_id = auth.uid()
    )
  );

create policy "Anyone reads product reviews"
  on public.reviews for select using (true);
create policy "Users create their own reviews"
  on public.reviews for insert to authenticated
  with check (auth.uid() = user_id);
create policy "Users update their own reviews"
  on public.reviews for update to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Users delete their own reviews"
  on public.reviews for delete to authenticated using (auth.uid() = user_id);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'product-images', 'product-images', true, 5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create policy "Public can view product images"
  on storage.objects for select using (bucket_id = 'product-images');
create policy "Users upload into their own folder"
  on storage.objects for insert to authenticated with check (
    bucket_id = 'product-images'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
create policy "Users manage their own product images"
  on storage.objects for update to authenticated using (
    bucket_id = 'product-images'
    and owner_id = auth.uid()::text
  );
create policy "Users delete their own product images"
  on storage.objects for delete to authenticated using (
    bucket_id = 'product-images'
    and owner_id = auth.uid()::text
  );

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'avatars', 'avatars', true, 5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create policy "Public can view avatars"
  on storage.objects for select using (bucket_id = 'avatars');
create policy "Users upload their own avatars"
  on storage.objects for insert to authenticated with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
create policy "Users update their own avatars"
  on storage.objects for update to authenticated using (
    bucket_id = 'avatars' and owner_id = auth.uid()::text
  );
create policy "Users delete their own avatars"
  on storage.objects for delete to authenticated using (
    bucket_id = 'avatars' and owner_id = auth.uid()::text
  );
