-- Vault must contain project_url and service_role_key before this migration runs.
-- Observe with: select jobid, jobname, schedule, active from cron.job where jobname in ('cleanup-credit-card-statement-imports-hourly', 'cleanup-payslip-document-imports-hourly');
create extension if not exists pg_net with schema extensions;
create extension if not exists pg_cron with schema extensions;
select cron.unschedule(jobid) from cron.job where jobname in ('cleanup-credit-card-statement-imports-hourly', 'cleanup-payslip-document-imports-hourly');
select cron.schedule('cleanup-credit-card-statement-imports-hourly', '0 * * * *', $$
  select net.http_post(url := (select decrypted_secret from vault.decrypted_secrets where name = 'project_url' limit 1) || '/functions/v1/cleanup-credit-card-statement-imports', headers := jsonb_build_object('Content-Type', 'application/json', 'Authorization', 'Bearer ' || (select decrypted_secret from vault.decrypted_secrets where name = 'service_role_key' limit 1), 'apikey', (select decrypted_secret from vault.decrypted_secrets where name = 'service_role_key' limit 1)), body := '{}'::jsonb);
$$);
select cron.schedule('cleanup-payslip-document-imports-hourly', '5 * * * *', $$
  select net.http_post(url := (select decrypted_secret from vault.decrypted_secrets where name = 'project_url' limit 1) || '/functions/v1/cleanup-payslip-document-imports', headers := jsonb_build_object('Content-Type', 'application/json', 'Authorization', 'Bearer ' || (select decrypted_secret from vault.decrypted_secrets where name = 'service_role_key' limit 1), 'apikey', (select decrypted_secret from vault.decrypted_secrets where name = 'service_role_key' limit 1)), body := '{}'::jsonb);
$$);
