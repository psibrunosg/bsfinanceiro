-- Migration: expand workspace_preferences
alter table public.workspace_preferences
  add column if not exists default_context_id uuid references public.financial_contexts(id),
  add column if not exists default_period text default 'current_month' check (default_period in (\'current_month\', \'last_month\', \'current_year\', \'all_time\')),
  add column if not exists hide_values boolean not null default false,
  add column if not exists compact_mode boolean not null default false,
  add column if not exists personal_color text default '#087f5b' check (personal_color ~ '^#[0-9a-fA-F]{6}$'),
  add column if not exists clinic_color text default '#b93636' check (clinic_color ~ '^#[0-9a-fA-F]{6}$'),
  add column if not exists default_category_id uuid,
  add column if not exists default_appointment_value numeric(14,2) default 0,
  add column if not exists default_billing_deadline_days integer default 30,
  add column if not exists alert_overdue_earnings boolean not null default true,
  add column if not exists alert_stale_quotes boolean not null default true;

-- Extend theme enum to include system
alter table public.profiles
  alter column theme_preference drop default,
  alter column theme_preference set default 'system';

-- Ensure 'system' is a valid theme value
alter table public.profiles
  drop constraint if exists profiles_theme_preference_check;
alter table public.profiles
  add constraint profiles_theme_preference_check check (theme_preference in ('system','light','dark'));
