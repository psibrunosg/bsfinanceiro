create type public.payslip_document_import_status as enum (
  'pending', 'processing', 'pending_review', 'imported', 'failed', 'discarded'
);
