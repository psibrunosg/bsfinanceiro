-- Migration: private payslip PDF bucket
-- PDF-only, 10 MB, objects isolated by owner prefix in the path.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'payslips',
  'payslips',
  false,
  10485760,
  array['application/pdf']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create policy "payslip_pdf_upload_own"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'payslips'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

create policy "payslip_pdf_read_own"
on storage.objects for select to authenticated
using (
  bucket_id = 'payslips'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

create policy "payslip_pdf_delete_own"
on storage.objects for delete to authenticated
using (
  bucket_id = 'payslips'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);
