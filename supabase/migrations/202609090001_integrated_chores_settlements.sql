alter table public.households
  add column if not exists master_chores jsonb not null default '[]'::jsonb;

create table if not exists public.members (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  username text not null,
  display_name text not null,
  role text not null default 'readwrite' check (role in ('admin', 'readwrite', 'readonly')),
  created_at timestamptz not null default now(),
  unique (household_id, username)
);

create table if not exists public.weekly_records (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  member_id uuid not null references public.members(id) on delete cascade,
  week_start_date date not null,
  days jsonb not null default '[]'::jsonb,
  chores_completed jsonb not null default '{}'::jsonb,
  study_conduct_bonus numeric not null default 0,
  vulg_count integer not null default 0,
  warnings_count integer not null default 0,
  respect_offenses integer not null default 0,
  hiphop_count integer not null default 0,
  attitude_rating integer not null default 5,
  net_payout numeric not null default 0,
  updated_at timestamptz not null default now(),
  unique (member_id, week_start_date)
);

create table if not exists public.settlement_ledger (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  member_id uuid not null references public.members(id) on delete cascade,
  week_start_date date not null,
  participant_name text not null,
  net_payout_text text not null,
  direct_cash_text text not null,
  savings_text text not null,
  chores_summary text not null,
  finalized_at timestamptz not null default now(),
  unique (member_id, week_start_date)
);

alter table public.members enable row level security;
alter table public.weekly_records enable row level security;
alter table public.settlement_ledger enable row level security;

create or replace function public.get_my_household_ids()
returns setof uuid
language sql
security definer
set search_path = public
stable
as $$ select id from public.households where owner_id = auth.uid(); $$;

revoke all on function public.get_my_household_ids() from public;
grant execute on function public.get_my_household_ids() to authenticated;

drop policy if exists "Owners manage household members" on public.members;
create policy "Owners manage household members" on public.members for all to authenticated
using (household_id in (select public.get_my_household_ids()))
with check (household_id in (select public.get_my_household_ids()));

drop policy if exists "Owners manage weekly records" on public.weekly_records;
create policy "Owners manage weekly records" on public.weekly_records for all to authenticated
using (household_id in (select public.get_my_household_ids()))
with check (household_id in (select public.get_my_household_ids()));

drop policy if exists "Owners manage ledger" on public.settlement_ledger;
create policy "Owners manage ledger" on public.settlement_ledger for all to authenticated
using (household_id in (select public.get_my_household_ids()))
with check (household_id in (select public.get_my_household_ids()));

revoke all on public.members, public.weekly_records, public.settlement_ledger from anon;
grant select, insert, update, delete on public.members, public.weekly_records, public.settlement_ledger to authenticated;
