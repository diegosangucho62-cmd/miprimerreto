-- Ejecuta este SQL en Supabase > SQL Editor.
-- Es seguro volver a ejecutarlo: las políticas se recrean y la publicación se comprueba.
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

-- Realtime es necesario para que el PC reciba los cambios del celular al instante.
do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'user_finances'
  ) then
    alter publication supabase_realtime add table public.user_finances;
  end if;
end $$;
