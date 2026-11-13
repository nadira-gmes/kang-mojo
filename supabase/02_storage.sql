-- Run this SECOND (after 01_tables.sql): new query -> paste -> Run.
-- If a policy line errors, create the same policies in Storage -> Policies in the dashboard (see README).

-- 3) Storage bucket for the community recordings (public to play, admin-only to upload)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('recordings','recordings', true, 5242880,
  array['audio/webm','audio/ogg','audio/mpeg','audio/mp4','audio/wav','audio/aac','audio/m4a'])
on conflict (id) do nothing;

drop policy if exists "recordings readable by everyone" on storage.objects;
create policy "recordings readable by everyone" on storage.objects for select using (bucket_id = 'recordings');
drop policy if exists "admin uploads recordings" on storage.objects;
create policy "admin uploads recordings" on storage.objects for insert to authenticated with check (bucket_id = 'recordings');
drop policy if exists "admin replaces recordings" on storage.objects;
create policy "admin replaces recordings" on storage.objects for update to authenticated using (bucket_id = 'recordings');
drop policy if exists "admin deletes recordings" on storage.objects;
create policy "admin deletes recordings" on storage.objects for delete to authenticated using (bucket_id = 'recordings');

