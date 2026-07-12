-- Foto del giardino, gestita nelle impostazioni dell'orto.
-- Le immagini vivono nel bucket esistente `plant-photos`
-- (path {auth.uid()}/orto-{ortoId}.jpg), quindi nessuna nuova policy storage:
-- le policy owner di `plant-photos` coprono già la cartella dell'utente.
alter table public.orti add column if not exists foto_url text;
