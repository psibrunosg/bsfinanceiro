alter table public.credit_card_statement_imports
  add constraint credit_card_statement_imports_id_workspace_owner_unique unique (id, workspace_id, owner_id),
  add column parser_name text,
  add column parser_version text,
  add column closing_date date,
  add column due_date date,
  add column declared_total_cents bigint,
  add column applied_items_hash text;

alter table public.credit_card_statement_imports
  drop constraint credit_card_statement_imports_check,
  add constraint credit_card_statement_imports_review_state_check check (
    (status = 'pending' and started_at is null and completed_at is null and error_code is null and result_purchase_id is null)
    or (status = 'processing' and started_at is not null and completed_at is null and error_code is null and result_purchase_id is null)
    or (status = 'pending_review' and started_at is not null and completed_at is not null and error_code is null and result_purchase_id is null
      and parser_name is not null and parser_version is not null and closing_date is not null and due_date is not null and declared_total_cents is not null)
    or (status = 'imported' and started_at is not null and completed_at is not null and error_code is null and result_purchase_id is not null and applied_items_hash is not null)
    or (status = 'failed' and started_at is not null and completed_at is not null and error_code is not null and result_purchase_id is null)
  );

create table public.credit_card_statement_import_items (
  id uuid primary key default gen_random_uuid(), import_id uuid not null, workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete cascade, ordinal smallint not null check (ordinal between 1 and 500),
  purchased_on date not null, description text not null check (char_length(btrim(description)) between 1 and 160),
  installment_amount_cents bigint not null check (installment_amount_cents between 1 and 999999999999),
  installment_number smallint not null check (installment_number between 1 and 120), installment_count smallint not null check (installment_count between 1 and 120),
  total_amount_cents bigint check (total_amount_cents between 1 and 999999999999), needs_review boolean not null default false,
  source_fingerprint text not null check (source_fingerprint ~ '^[a-f0-9]{64}$'), applied_purchase_id uuid, created_at timestamptz not null default now(),
  unique (import_id, ordinal), unique (import_id, source_fingerprint),
  foreign key (import_id, workspace_id, owner_id) references public.credit_card_statement_imports(id, workspace_id, owner_id) on delete cascade,
  foreign key (applied_purchase_id, workspace_id, owner_id) references public.credit_card_purchases(id, workspace_id, owner_id) on delete restrict,
  check (installment_number <= installment_count),
  check ((installment_count = 1 and total_amount_cents = installment_amount_cents and not needs_review)
    or (installment_count > 1 and (total_amount_cents is null or total_amount_cents >= installment_amount_cents)))
);
alter table public.credit_card_statement_import_items enable row level security;
create policy "credit_card_statement_import_items_own" on public.credit_card_statement_import_items for select to authenticated using ((select auth.uid()) = owner_id);
revoke all on table public.credit_card_statement_import_items from public, anon;
grant select on table public.credit_card_statement_import_items to authenticated;

create or replace function public.finish_credit_card_statement_import_review(
  p_import_id uuid, p_parser_name text, p_parser_version text, p_closing_date date, p_due_date date, p_declared_total_cents bigint, p_items jsonb
) returns void language plpgsql security definer set search_path = '' as $$
declare v_item jsonb;
begin
  if (select auth.role()) <> 'service_role' then raise exception 'service role required' using errcode = '28000'; end if;
  if p_parser_name <> 'santander' or char_length(coalesce(p_parser_version, '')) not between 1 and 32 or p_closing_date is null or p_due_date is null or p_due_date < p_closing_date or p_declared_total_cents not between 1 and 999999999999 or jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) not between 1 and 500 then raise exception 'invalid review candidates' using errcode = '22023'; end if;
  delete from public.credit_card_statement_import_items where import_id = p_import_id;
  for v_item in select value from jsonb_array_elements(p_items) loop
    insert into public.credit_card_statement_import_items (import_id,workspace_id,owner_id,ordinal,purchased_on,description,installment_amount_cents,installment_number,installment_count,total_amount_cents,needs_review,source_fingerprint)
    select i.id,i.workspace_id,i.owner_id,(v_item->>'ordinal')::smallint,(v_item->>'purchasedOn')::date,btrim(v_item->>'description'),(v_item->>'installmentAmountCents')::bigint,(v_item->>'installmentNumber')::smallint,(v_item->>'installmentCount')::smallint,nullif(v_item->>'totalAmountCents','')::bigint,coalesce((v_item->>'needsReview')::boolean,false),v_item->>'sourceFingerprint'
    from public.credit_card_statement_imports i where i.id = p_import_id and i.status = 'processing';
  end loop;
  if (select count(*) from public.credit_card_statement_import_items where import_id = p_import_id) <> jsonb_array_length(p_items) then raise exception 'invalid review candidates' using errcode = '22023'; end if;
  update public.credit_card_statement_imports set status = 'pending_review',parser_name = p_parser_name,parser_version = p_parser_version,closing_date = p_closing_date,due_date = p_due_date,declared_total_cents = p_declared_total_cents,completed_at = now(),error_code = null,result_purchase_id = null where id = p_import_id and status = 'processing';
  if not found then raise exception 'processing import not found' using errcode = 'P0002'; end if;
end; $$;

create or replace function public.apply_credit_card_statement_import(p_import_id uuid, p_items jsonb)
returns uuid[] language plpgsql security definer set search_path = '' as $$
declare
  v_user_id uuid := (select auth.uid()); v_import public.credit_card_statement_imports%rowtype; v_card public.credit_cards%rowtype;
  v_invoice public.credit_card_invoices%rowtype; v_item public.credit_card_statement_import_items%rowtype; v_payload jsonb;
  v_hash text; v_period_start date; v_purchase_id uuid; v_ids uuid[] := '{}'; v_total bigint := 0;
  v_payload_date date; v_payload_amount_cents bigint; v_payload_total_cents bigint; v_payload_installment_number integer; v_payload_installment_count integer;
begin
  if v_user_id is null then raise exception 'authentication required' using errcode = '28000'; end if;
  if jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) not between 1 and 500 then raise exception 'invalid item batch' using errcode = '22023'; end if;
  v_hash := md5(p_items::text);
  select * into v_import from public.credit_card_statement_imports where id = p_import_id and owner_id = v_user_id for update;
  if not found then raise exception 'import not found' using errcode = 'P0002'; end if;
  if v_import.status = 'imported' then
    if v_import.applied_items_hash <> v_hash then raise exception 'import already applied with different items' using errcode = '23505'; end if;
    select coalesce(array_agg(applied_purchase_id order by ordinal), '{}') into v_ids from public.credit_card_statement_import_items where import_id = v_import.id;
    return v_ids;
  end if;
  if v_import.status <> 'pending_review' or jsonb_array_length(p_items) <> (select count(*) from public.credit_card_statement_import_items where import_id = v_import.id) then raise exception 'import is not ready for review' using errcode = '22023'; end if;
  select * into v_card from public.credit_cards where id = v_import.credit_card_id and workspace_id = v_import.workspace_id and owner_id = v_user_id and active for update;
  if not found then raise exception 'active credit card not found' using errcode = 'P0002'; end if;
  v_period_start := (date_trunc('month',v_import.closing_date)::date - interval '1 month')::date + (least(v_card.closing_day,extract(day from (date_trunc('month',v_import.closing_date)::date - interval '1 day'))::integer) - 1) + 1;
  for v_item in select * from public.credit_card_statement_import_items where import_id = v_import.id order by ordinal loop
    select value into v_payload from jsonb_array_elements(p_items) where value->>'ordinal' = v_item.ordinal::text;
    if v_payload is null or v_payload->>'sourceFingerprint' <> v_item.source_fingerprint or (v_payload->>'purchasedOn') !~ '^\d{4}-\d{2}-\d{2}$' or char_length(btrim(coalesce(v_payload->>'description',''))) not between 1 and 160 or (v_payload->>'installmentAmountCents') !~ '^\d+$' or (v_payload->>'installmentNumber') !~ '^\d+$' or (v_payload->>'installmentCount') !~ '^\d+$' or (v_payload->>'totalAmountCents') !~ '^\d+$' then raise exception 'invalid corrected item' using errcode = '22023'; end if;
    v_payload_date := (v_payload->>'purchasedOn')::date; v_payload_amount_cents := (v_payload->>'installmentAmountCents')::bigint; v_payload_total_cents := (v_payload->>'totalAmountCents')::bigint; v_payload_installment_number := (v_payload->>'installmentNumber')::integer; v_payload_installment_count := (v_payload->>'installmentCount')::integer;
    if v_payload_date < v_period_start or v_payload_date > v_import.closing_date or v_payload_amount_cents not between 1 and 999999999999 or v_payload_total_cents not between v_payload_amount_cents and 999999999999 or v_payload_installment_number not between 1 and 120 or v_payload_installment_count not between 1 and 120 or v_payload_installment_number > v_payload_installment_count then raise exception 'invalid corrected item' using errcode = '22023'; end if;
    if v_payload_installment_count = 1 and v_payload_total_cents <> v_payload_amount_cents then raise exception 'invalid corrected item' using errcode = '22023'; end if;
    if v_item.needs_review and v_payload_total_cents is null then raise exception 'corrected total amount required' using errcode = '22023'; end if;
    v_total := v_total + v_payload_amount_cents;
  end loop;
  if v_total <> v_import.declared_total_cents then raise exception 'statement_total_mismatch' using errcode = '22023'; end if;
  select * into v_invoice from public.credit_card_invoices where credit_card_id = v_card.id and period_start = v_period_start for update;
  if found then
    if v_invoice.period_end <> v_import.closing_date or v_invoice.closing_date <> v_import.closing_date or v_invoice.due_date <> v_import.due_date then raise exception 'invoice dates do not match statement' using errcode = '22023'; end if;
    if v_invoice.status in ('paid','cancelled') then raise exception 'paid or cancelled invoice cannot accept statement items' using errcode = '22023'; end if;
  else
    insert into public.credit_card_invoices (workspace_id,owner_id,credit_card_id,period_start,period_end,closing_date,due_date) values (v_import.workspace_id,v_user_id,v_card.id,v_period_start,v_import.closing_date,v_import.closing_date,v_import.due_date) returning * into v_invoice;
  end if;
  for v_item in select * from public.credit_card_statement_import_items where import_id = v_import.id order by ordinal loop
    select value into v_payload from jsonb_array_elements(p_items) where value->>'ordinal' = v_item.ordinal::text;
    insert into public.credit_card_purchases (workspace_id,owner_id,credit_card_id,description,total_amount,purchased_on,installment_count,idempotency_key) values (v_import.workspace_id,v_user_id,v_card.id,btrim(v_payload->>'description'),((v_payload->>'totalAmountCents')::numeric/100),(v_payload->>'purchasedOn')::date,(v_payload->>'installmentCount')::smallint,md5('credit-card-statement:' || v_import.owner_id::text || ':' || v_import.credit_card_id::text || ':' || v_import.sha256 || ':' || v_item.source_fingerprint)::uuid) on conflict (owner_id,idempotency_key) do nothing;
    select id into v_purchase_id from public.credit_card_purchases where owner_id = v_user_id and idempotency_key = md5('credit-card-statement:' || v_import.owner_id::text || ':' || v_import.credit_card_id::text || ':' || v_import.sha256 || ':' || v_item.source_fingerprint)::uuid;
    insert into public.credit_card_installments (workspace_id,owner_id,credit_card_id,purchase_id,invoice_id,installment_number,amount,competence_date) values (v_import.workspace_id,v_user_id,v_card.id,v_purchase_id,v_invoice.id,(v_payload->>'installmentNumber')::smallint,((v_payload->>'installmentAmountCents')::numeric/100),v_import.due_date) on conflict (purchase_id,installment_number) do update set invoice_id = excluded.invoice_id,amount = excluded.amount,competence_date = excluded.competence_date;
    update public.credit_card_statement_import_items set applied_purchase_id = v_purchase_id where id = v_item.id;
    v_ids := array_append(v_ids,v_purchase_id);
  end loop;
  update public.credit_card_statement_imports set status = 'imported',result_purchase_id = v_ids[1],applied_items_hash = v_hash,completed_at = now() where id = v_import.id;
  return v_ids;
end; $$;

revoke all on function public.finish_credit_card_statement_import_review(uuid,text,text,date,date,bigint,jsonb) from public,anon,authenticated;
grant execute on function public.finish_credit_card_statement_import_review(uuid,text,text,date,date,bigint,jsonb) to service_role;
revoke all on function public.apply_credit_card_statement_import(uuid,jsonb) from public,anon;
grant execute on function public.apply_credit_card_statement_import(uuid,jsonb) to authenticated;
