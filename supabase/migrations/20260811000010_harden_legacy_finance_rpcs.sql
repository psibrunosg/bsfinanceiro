-- Harden legacy SECURITY DEFINER finance writers retained by the manual UI.
create or replace function public.create_credit_card(
  p_workspace_id uuid, p_owner_id uuid, p_name text, p_credit_limit numeric,
  p_closing_day integer, p_due_day integer, p_brand text default null, p_last_four text default null
) returns uuid language plpgsql security definer set search_path = '' as $$
declare v_user_id uuid := (select auth.uid()); v_workspace public.workspaces%rowtype; v_account_id uuid; v_card_id uuid;
begin
  if v_user_id is null then raise exception 'authentication required' using errcode = '28000'; end if;
  if p_owner_id is not null and p_owner_id <> v_user_id then raise exception 'owner mismatch' using errcode = '42501'; end if;
  select w.* into v_workspace from public.workspaces as w join public.profiles as p on p.id = v_user_id
  where w.id = p.active_workspace_id and w.owner_id = v_user_id and w.id = p_workspace_id;
  if not found then raise exception 'active workspace not found' using errcode = 'P0002'; end if;
  if char_length(btrim(coalesce(p_name, ''))) not between 1 and 80 or p_credit_limit <= 0 or p_closing_day not between 1 and 31 or p_due_day not between 1 and 31 then raise exception 'invalid credit card' using errcode = '22023'; end if;
  insert into public.accounts (workspace_id, owner_id, name, type, initial_balance, is_system)
  values (v_workspace.id, v_user_id, 'Conta Tecnica ' || btrim(p_name), 'credit_card', 0, true) returning id into v_account_id;
  insert into public.credit_cards (workspace_id, owner_id, account_id, name, brand, last_four, credit_limit, closing_day, due_day)
  values (v_workspace.id, v_user_id, v_account_id, btrim(p_name), nullif(btrim(p_brand), ''), nullif(btrim(p_last_four), ''), p_credit_limit, p_closing_day, p_due_day) returning id into v_card_id;
  return v_card_id;
end;
$$;

create or replace function public.receive_patient_earning(p_earning_id uuid, p_account_id uuid, p_received_date date)
returns void language plpgsql security definer set search_path = '' as $$
declare v_user_id uuid := (select auth.uid()); v_earning public.patient_earnings%rowtype; v_account public.accounts%rowtype; v_transaction_id uuid;
begin
  if v_user_id is null then raise exception 'authentication required' using errcode = '28000'; end if;
  if p_received_date is null then raise exception 'received date required' using errcode = '22023'; end if;
  select e.* into v_earning from public.patient_earnings as e where e.id = p_earning_id and e.owner_id = v_user_id for update;
  if not found then raise exception 'earning not found' using errcode = 'P0002'; end if;
  if not exists (select 1 from public.profiles as p where p.id = v_user_id and p.active_workspace_id = v_earning.workspace_id) then raise exception 'active workspace mismatch' using errcode = '42501'; end if;
  select a.* into v_account from public.accounts as a where a.id = p_account_id and a.workspace_id = v_earning.workspace_id and a.owner_id = v_user_id and a.active and a.type in ('checking', 'cash', 'savings') for update;
  if not found then raise exception 'active cash account not found' using errcode = 'P0002'; end if;
  if v_earning.status = 'received' then return; end if;
  insert into public.transactions (workspace_id, owner_id, account_id, category_id, type, amount, description, competence_date, paid_at, status, context_id)
  values (v_earning.workspace_id, v_user_id, v_account.id, null, 'income', v_earning.amount, 'Recebimento de paciente', p_received_date, p_received_date, 'paid', v_earning.context_id) returning id into v_transaction_id;
  update public.patient_earnings as e set status = 'received', transaction_id = v_transaction_id where e.id = v_earning.id and e.owner_id = v_user_id;
end;
$$;

revoke all on function public.create_credit_card(uuid,uuid,text,numeric,integer,integer,text,text) from public, anon, authenticated;
grant execute on function public.create_credit_card(uuid,uuid,text,numeric,integer,integer,text,text) to authenticated;
revoke all on function public.receive_patient_earning(uuid,uuid,date) from public, anon, authenticated;
grant execute on function public.receive_patient_earning(uuid,uuid,date) to authenticated;
