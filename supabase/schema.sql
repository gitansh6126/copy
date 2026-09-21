-- Copy Portal — Supabase schema
-- Run this in: Supabase Dashboard -> SQL Editor -> New query -> Run
-- (or: supabase db push with the Supabase CLI)

-- Snippets table: every row is owned by the signed-in Google user.
create table if not exists public.snippets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  content text not null,
  folder text,
  tags text[] not null default '{}',
  favorite boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Useful for the "All Snippets, newest first" listing
create index if not exists snippets_user_updated_idx
  on public.snippets (user_id, updated_at desc);

-- Enable Row Level Security (data belongs to the signed-in user only)
alter table public.snippets enable row level security;

-- RLS policies: users can only touch their own rows
drop policy if exists "Users can read their own snippets" on public.snippets;
create policy "Users can read their own snippets"
  on public.snippets for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert their own snippets" on public.snippets;
create policy "Users can insert their own snippets"
  on public.snippets for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users can update their own snippets" on public.snippets;
create policy "Users can update their own snippets"
  on public.snippets for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users can delete their own snippets" on public.snippets;
create policy "Users can delete their own snippets"
  on public.snippets for delete
  using (auth.uid() = user_id);