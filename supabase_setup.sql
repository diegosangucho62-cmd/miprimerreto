-- Ejecuta este SQL una sola vez en Supabase > SQL Editor.
create table if not exists public.user_finances (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.user_finances enable row level security;

drop policy if exists "Users can read their own finance data" on public.user_finances;
create policy "Users can read their own finance data"
on public.user_finances for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "Users can insert their own finance data" on public.user_finances;
create policy "Users can insert their own finance data"
on public.user_finances for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Users can update their own finance data" on public.user_finances;
create policy "Users can update their own finance data"
on public.user_finances for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
