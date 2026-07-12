-- Bucket pubblico per le foto delle piante.
-- Path convenzione: {auth.uid()}/{piantaId}.jpg
-- Lettura pubblica (le immagini sono mostrate via URL pubblico nell'app);
-- scrittura/aggiornamento/cancellazione solo nella propria cartella.

insert into storage.buckets (id, name, public)
values ('plant-photos', 'plant-photos', true)
on conflict (id) do nothing;

-- Lettura pubblica delle foto.
create policy "plant-photos public read"
  on storage.objects for select
  using (bucket_id = 'plant-photos');

-- Upload solo nella cartella del proprio uid.
create policy "plant-photos owner insert"
  on storage.objects for insert
  with check (
    bucket_id = 'plant-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Aggiornamento (upsert) solo nella cartella del proprio uid.
create policy "plant-photos owner update"
  on storage.objects for update
  using (
    bucket_id = 'plant-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Cancellazione solo nella cartella del proprio uid.
create policy "plant-photos owner delete"
  on storage.objects for delete
  using (
    bucket_id = 'plant-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
