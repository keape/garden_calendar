# Feature foto giardino nelle impostazioni orto

**Data:** 2026-06-21
**Progetto:** garden-calendar-ios
**Durata:** media
**Tipo:** feature
**Status:** complete
**Tags:** supabase, storage, rls, swiftui, migration

## Cosa abbiamo fatto

- Aggiunta feature foto del giardino, gestita in `OrtoDetailView` (sheet modifica).
- Migration `20260621000001_orti_foto_url.sql` → colonna `foto_url text` su `orti`. Applicata con `supabase db push --linked`, colonna verificata.
- Riuso bucket esistente `plant-photos` (nessuna nuova policy storage). Path `{uid}/orto-{ortoId}.jpg` minuscolo, coerente con policy RLS `auth.uid()::text`.
- Repository: `uploadOrtoPhoto(ortoId:data:)` (gemello di `uploadPlantPhoto`).
- Model `Orto`: campo `fotoUrl` + decoder; `Orto.Update.fotoUrl` con CodingKey `foto_url`.
- UI: foto in header (cerchio) al posto icona albero; sezione "Foto del giardino" con `PhotosPicker` → upload + salvataggio `foto_url`.
- l10n `garden.photoSection` IT/EN; riusate `plants.addPhotoButton/changePhotoButton` (prima orfane).
- Build OK + test REST e2e con token reale: createOrto 201 → uploadOrtoPhoto 200 (no 403 RLS) → update foto_url 200 (nome preservato) → publicRead 200 → cleanup 204.

## Decisioni prese

- Riuso bucket `plant-photos` invece di crearne uno nuovo `garden-photos` → evita nuove policy storage, le policy owner-folder esistenti coprono già la cartella utente.
- PATCH manda solo `foto_url`: Swift sintetizza `encodeIfPresent` per gli optional → i nil sono omessi, `nome` non viene azzerato.

## Prossimi passi

- Non committato — attendere richiesta utente.
- 1 orto diagnostico orfano (`29fe38c0…`, user `e1f861be…`) + oggetto storage da run test abortito; rimovibile solo con service_role key (limite noto).

## Contesto tecnico rilevante

- File: `Models/Orto.swift`, `Services/SupabaseRepository.swift`, `Views/Orto/OrtoDetailView.swift`, `Localization/Strings.swift`, `supabase/migrations/20260621000001_orti_foto_url.sql`.
- Test: `/tmp/test_orto_photo.py`.
