insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('voice-refinement', 'voice-refinement', false, 10485760, array['audio/wav'])
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create policy "Users can upload voice refinement audio"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'voice-refinement'
  and (storage.foldername(name))[1] = (select auth.uid())::text
  and storage.extension(name) = 'wav'
);

create policy "Users can read their voice refinement audio"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'voice-refinement'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

create policy "Users can delete their voice refinement audio"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'voice-refinement'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);