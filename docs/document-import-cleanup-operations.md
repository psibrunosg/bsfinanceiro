# Document import cleanup operations

Before applying `20260811000007_schedule_document_import_cleanup.sql`, store `project_url` and `service_role_key` in the project Vault. The migration reads both at execution time, so no credential is committed to Git.

The scheduled jobs are `cleanup-credit-card-statement-imports-hourly` and `cleanup-payslip-document-imports-hourly`. Confirm they are active in `cron.job`; inspect delivery and failures in `cron.job_run_details`.
