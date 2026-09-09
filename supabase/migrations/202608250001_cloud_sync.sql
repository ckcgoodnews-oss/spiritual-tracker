create extension if not exists pgcrypto;

create table if not exists public.households (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null default 'My Household',
  icon text not null default '📖',
  currency text not null default 'USD',
  theme text not null default 'navy-slate',
  config jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (owner_id)
);

create table if not exists public.app_snapshots (
  household_id uuid primary key references public.households(id) on delete cascade,
  schema_version integer not null default 1 check (schema_version > 0),
  state jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.households enable row level security;
alter table public.app_snapshots enable row level security;

drop policy if exists "Owners manage own household" on public.households;
create policy "Owners manage own household"
on public.households for all
to authenticated
using (owner_id = (select auth.uid()))
with check (owner_id = (select auth.uid()));

drop policy if exists "Owners manage own snapshot" on public.app_snapshots;
create policy "Owners manage own snapshot"
on public.app_snapshots for all
to authenticated
using (
  exists (
    select 1 from public.households h
    where h.id = app_snapshots.household_id
      and h.owner_id = (select auth.uid())
  )
)
with check (
  exists (
    select 1 from public.households h
    where h.id = app_snapshots.household_id
      and h.owner_id = (select auth.uid())
  )
);

revoke all on public.households from anon;
revoke all on public.app_snapshots from anon;
grant select, insert, update, delete on public.households to authenticated;
grant select, insert, update, delete on public.app_snapshots to authenticated;
