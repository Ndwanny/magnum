-- ============================================================
-- Magnum Security — Supabase Initial Schema
-- Run via: supabase db push  OR  paste into Supabase SQL editor
-- ============================================================

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- ── User profiles (extends Supabase auth.users) ──────────────
create table public.profiles (
  id          uuid references auth.users on delete cascade primary key,
  name        text not null,
  role        text not null check (role in ('admin', 'client', 'guard')),
  badge_number text,              -- guards only
  phone       text,
  avatar_url  text,
  created_at  timestamptz default now()
);

alter table public.profiles enable row level security;

create policy "Users can read own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Admins can read all profiles"
  on public.profiles for select
  using ((select role from public.profiles where id = auth.uid()) = 'admin');

create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, name, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data->>'role', 'client')
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ── Client Sites ─────────────────────────────────────────────
create table public.client_sites (
  id              uuid default uuid_generate_v4() primary key,
  name            text not null,
  address         text,
  client_name     text not null,
  client_user_id  uuid references public.profiles(id),
  guards_deployed int  default 0,
  service_type    text,
  status          text default 'Active' check (status in ('Active', 'Inactive', 'Pending')),
  contract_start  date,
  contract_end    date,
  created_at      timestamptz default now()
);

alter table public.client_sites enable row level security;

create policy "Clients see own sites"
  on public.client_sites for select
  using (client_user_id = auth.uid() or
         (select role from public.profiles where id = auth.uid()) in ('admin', 'guard'));

-- ── Guards ───────────────────────────────────────────────────
create table public.guards (
  id              uuid default uuid_generate_v4() primary key,
  user_id         uuid references public.profiles(id),
  badge_number    text unique not null,
  name            text not null,
  phone           text,
  email           text,
  role            text default 'Unarmed' check (role in ('Armed', 'Unarmed', 'Supervisor')),
  status          text default 'Active' check (status in ('Active', 'Inactive', 'On Leave')),
  current_site    text,
  join_date       date,
  certifications  text[],
  photo_url       text,
  created_at      timestamptz default now()
);

alter table public.guards enable row level security;

create policy "Guards read own record"
  on public.guards for select
  using (user_id = auth.uid() or
         (select role from public.profiles where id = auth.uid()) = 'admin');

-- ── Incidents ────────────────────────────────────────────────
create table public.incidents (
  id            uuid default uuid_generate_v4() primary key,
  site_id       uuid references public.client_sites(id),
  title         text not null,
  description   text,
  severity      text default 'Low' check (severity in ('Low', 'Medium', 'High', 'Critical')),
  status        text default 'Open' check (status in ('Open', 'In Progress', 'Resolved', 'Closed')),
  reported_by   text,
  reported_by_id uuid references public.profiles(id),
  resolved_by   text,
  resolved_at   timestamptz,
  has_cctv      boolean default false,
  created_at    timestamptz default now()
);

alter table public.incidents enable row level security;

create policy "Clients see own site incidents"
  on public.incidents for select
  using (
    site_id in (select id from public.client_sites where client_user_id = auth.uid())
    or (select role from public.profiles where id = auth.uid()) in ('admin', 'guard')
  );

create policy "Guards and admins insert incidents"
  on public.incidents for insert
  with check ((select role from public.profiles where id = auth.uid()) in ('admin', 'guard'));

create policy "Admins update incidents"
  on public.incidents for update
  using ((select role from public.profiles where id = auth.uid()) = 'admin');

-- ── Patrol Logs ──────────────────────────────────────────────
create table public.patrol_logs (
  id            uuid default uuid_generate_v4() primary key,
  guard_id      uuid references public.guards(id),
  guard_name    text,
  guard_badge   text,
  site_id       uuid references public.client_sites(id),
  site_name     text,
  start_time    timestamptz,
  end_time      timestamptz,
  status        text default 'Ongoing' check (status in ('Ongoing', 'Completed', 'Aborted')),
  notes         text,
  created_at    timestamptz default now()
);

create table public.patrol_checkpoints (
  id              uuid default uuid_generate_v4() primary key,
  patrol_log_id   uuid references public.patrol_logs(id) on delete cascade,
  checkpoint_name text not null,
  scanned_at      timestamptz default now(),
  is_ok           boolean default true,
  notes           text
);

alter table public.patrol_logs enable row level security;
alter table public.patrol_checkpoints enable row level security;

create policy "Patrol logs visible to involved parties"
  on public.patrol_logs for select
  using (
    guard_id in (select id from public.guards where user_id = auth.uid())
    or site_id in (select id from public.client_sites where client_user_id = auth.uid())
    or (select role from public.profiles where id = auth.uid()) = 'admin'
  );

create policy "Guards insert own patrol logs"
  on public.patrol_logs for insert
  with check (guard_id in (select id from public.guards where user_id = auth.uid())
    or (select role from public.profiles where id = auth.uid()) = 'admin');

create policy "Checkpoints readable with patrol log"
  on public.patrol_checkpoints for select
  using (
    patrol_log_id in (
      select id from public.patrol_logs where
        guard_id in (select id from public.guards where user_id = auth.uid())
        or site_id in (select id from public.client_sites where client_user_id = auth.uid())
        or (select role from public.profiles where id = auth.uid()) = 'admin'
    )
  );

-- ── Attendance ───────────────────────────────────────────────
create table public.attendance_records (
  id            uuid default uuid_generate_v4() primary key,
  guard_id      uuid references public.guards(id),
  guard_name    text,
  guard_badge   text,
  site_id       uuid references public.client_sites(id),
  site_name     text,
  date          date default current_date,
  clock_in      timestamptz,
  clock_out     timestamptz,
  shift_type    text default 'Day' check (shift_type in ('Day', 'Night')),
  status        text default 'Present' check (status in ('Present', 'Late', 'Absent', 'On Leave')),
  notes         text,
  created_at    timestamptz default now()
);

alter table public.attendance_records enable row level security;

create policy "Guards see own attendance"
  on public.attendance_records for select
  using (guard_id in (select id from public.guards where user_id = auth.uid())
    or (select role from public.profiles where id = auth.uid()) = 'admin');

create policy "Guards insert own attendance"
  on public.attendance_records for insert
  with check (guard_id in (select id from public.guards where user_id = auth.uid())
    or (select role from public.profiles where id = auth.uid()) = 'admin');

create policy "Guards update own attendance clock-out"
  on public.attendance_records for update
  using (guard_id in (select id from public.guards where user_id = auth.uid())
    or (select role from public.profiles where id = auth.uid()) = 'admin');

-- ── Invoices ─────────────────────────────────────────────────
create table public.invoices (
  id              uuid default uuid_generate_v4() primary key,
  invoice_number  text unique not null,
  site_id         uuid references public.client_sites(id),
  client_name     text not null,
  client_user_id  uuid references public.profiles(id),
  amount          numeric(12,2) not null,
  currency        text default 'ZMW',
  status          text default 'Pending' check (status in ('Pending', 'Paid', 'Overdue', 'Cancelled')),
  issued_date     date default current_date,
  due_date        date,
  payment_ref     text,
  payment_method  text,
  paid_at         timestamptz,
  lenco_tx_id     text,           -- Lenco/Broadpay transaction ID
  created_at      timestamptz default now()
);

create table public.invoice_items (
  id            uuid default uuid_generate_v4() primary key,
  invoice_id    uuid references public.invoices(id) on delete cascade,
  description   text not null,
  quantity      int  default 1,
  unit_price    numeric(12,2) not null,
  total         numeric(12,2) generated always as (quantity * unit_price) stored
);

alter table public.invoices enable row level security;
alter table public.invoice_items enable row level security;

create policy "Clients see own invoices"
  on public.invoices for select
  using (client_user_id = auth.uid()
    or (select role from public.profiles where id = auth.uid()) = 'admin');

create policy "Admins manage invoices"
  on public.invoices for all
  using ((select role from public.profiles where id = auth.uid()) = 'admin');

create policy "Invoice items readable with invoice"
  on public.invoice_items for select
  using (invoice_id in (
    select id from public.invoices where
      client_user_id = auth.uid()
      or (select role from public.profiles where id = auth.uid()) = 'admin'
  ));

-- ── Payroll ──────────────────────────────────────────────────
create table public.payroll_records (
  id            uuid default uuid_generate_v4() primary key,
  guard_id      uuid references public.guards(id),
  guard_name    text,
  guard_badge   text,
  period        text not null,         -- e.g. "March 2024"
  base_salary   numeric(10,2) default 0,
  overtime      numeric(10,2) default 0,
  allowances    numeric(10,2) default 0,
  napsa         numeric(10,2) default 0,  -- 5%
  nhima         numeric(10,2) default 0,  -- 1%
  paye          numeric(10,2) default 0,
  status        text default 'Pending' check (status in ('Pending', 'Processing', 'Paid')),
  payment_ref   text,
  paid_at       timestamptz,
  created_at    timestamptz default now()
);

alter table public.payroll_records enable row level security;

create policy "Guards read own payroll"
  on public.payroll_records for select
  using (guard_id in (select id from public.guards where user_id = auth.uid())
    or (select role from public.profiles where id = auth.uid()) = 'admin');

create policy "Admins manage payroll"
  on public.payroll_records for all
  using ((select role from public.profiles where id = auth.uid()) = 'admin');

-- ── CRM Leads ────────────────────────────────────────────────
create table public.leads (
  id                uuid default uuid_generate_v4() primary key,
  company_name      text not null,
  contact_name      text,
  phone             text,
  email             text,
  service_interest  text,
  stage             text default 'New' check (stage in ('New','Contacted','Quoted','Negotiating','Won','Lost')),
  estimated_value   numeric(12,2),
  notes             text,
  follow_up_date    date,
  created_at        timestamptz default now(),
  updated_at        timestamptz default now()
);

alter table public.leads enable row level security;

create policy "Only admins manage leads"
  on public.leads for all
  using ((select role from public.profiles where id = auth.uid()) = 'admin');

-- ── Shift Schedules ──────────────────────────────────────────
create table public.shift_schedules (
  id            uuid default uuid_generate_v4() primary key,
  guard_id      uuid references public.guards(id),
  guard_badge   text,
  site_id       uuid references public.client_sites(id),
  shift_date    date not null,
  shift_type    text default 'Day' check (shift_type in ('Day', 'Night')),
  start_time    time default '06:00',
  end_time      time default '18:00',
  created_at    timestamptz default now(),
  unique(guard_id, shift_date)
);

alter table public.shift_schedules enable row level security;

create policy "Guards see own schedules"
  on public.shift_schedules for select
  using (guard_id in (select id from public.guards where user_id = auth.uid())
    or (select role from public.profiles where id = auth.uid()) = 'admin');

create policy "Admins manage schedules"
  on public.shift_schedules for all
  using ((select role from public.profiles where id = auth.uid()) = 'admin');

-- ── Messaging ────────────────────────────────────────────────
create table public.conversations (
  id          uuid default uuid_generate_v4() primary key,
  title       text not null,
  type        text default 'internal' check (type in ('internal', 'whatsapp', 'sms', 'email')),
  site_id     uuid references public.client_sites(id),
  created_at  timestamptz default now()
);

create table public.messages (
  id              uuid default uuid_generate_v4() primary key,
  conversation_id uuid references public.conversations(id) on delete cascade,
  sender_id       uuid references public.profiles(id),
  sender_name     text,
  content         text not null,
  is_read         boolean default false,
  sent_at         timestamptz default now()
);

alter table public.conversations enable row level security;
alter table public.messages enable row level security;

create policy "Admins and guards see all conversations"
  on public.conversations for select
  using ((select role from public.profiles where id = auth.uid()) in ('admin', 'guard'));

create policy "Messages readable by participants"
  on public.messages for select
  using ((select role from public.profiles where id = auth.uid()) in ('admin', 'guard')
    or sender_id = auth.uid());

-- ── Contact / Quote Submissions ──────────────────────────────
create table public.contact_submissions (
  id          uuid default uuid_generate_v4() primary key,
  name        text not null,
  email       text not null,
  phone       text,
  message     text not null,
  status      text default 'New' check (status in ('New', 'Read', 'Replied')),
  created_at  timestamptz default now()
);

create table public.quote_submissions (
  id                uuid default uuid_generate_v4() primary key,
  name              text not null,
  company           text,
  email             text not null,
  phone             text,
  service_type      text,
  guards_needed     int,
  site_address      text,
  notes             text,
  status            text default 'New' check (status in ('New', 'Contacted', 'Quoted', 'Won', 'Lost')),
  created_at        timestamptz default now()
);

alter table public.contact_submissions enable row level security;
alter table public.quote_submissions enable row level security;

-- Public can insert (anonymous submissions from website)
create policy "Anyone can submit contact form"
  on public.contact_submissions for insert
  with check (true);

create policy "Anyone can submit quote form"
  on public.quote_submissions for insert
  with check (true);

create policy "Only admins read submissions"
  on public.contact_submissions for select
  using ((select role from public.profiles where id = auth.uid()) = 'admin');

create policy "Only admins read quote submissions"
  on public.quote_submissions for select
  using ((select role from public.profiles where id = auth.uid()) = 'admin');

-- ── Payment Transactions ─────────────────────────────────────
create table public.payment_transactions (
  id              uuid default uuid_generate_v4() primary key,
  invoice_id      uuid references public.invoices(id),
  lenco_tx_id     text unique,
  amount          numeric(12,2) not null,
  currency        text default 'ZMW',
  method          text check (method in ('card', 'mtn_momo', 'airtel_money', 'bank_transfer')),
  status          text default 'pending' check (status in ('pending', 'processing', 'completed', 'failed', 'refunded')),
  phone_number    text,             -- for mobile money
  card_last4      text,             -- for card
  failure_reason  text,
  webhook_payload jsonb,
  initiated_at    timestamptz default now(),
  completed_at    timestamptz
);

alter table public.payment_transactions enable row level security;

create policy "Clients see own transactions"
  on public.payment_transactions for select
  using (invoice_id in (
    select id from public.invoices where client_user_id = auth.uid()
  ) or (select role from public.profiles where id = auth.uid()) = 'admin');

-- ── Helpful views ────────────────────────────────────────────
create view public.invoice_with_items as
  select
    i.*,
    json_agg(ii.*) as items
  from public.invoices i
  left join public.invoice_items ii on ii.invoice_id = i.id
  group by i.id;

create view public.guard_with_profile as
  select
    g.*,
    p.name as profile_name,
    p.role as profile_role
  from public.guards g
  left join public.profiles p on p.id = g.user_id;

-- ── Seed initial admin user (run after creating auth user) ───
-- Replace 'YOUR-ADMIN-UUID' with the UUID from auth.users
-- insert into public.profiles (id, name, role) values
--   ('YOUR-ADMIN-UUID', 'Admin User', 'admin');
