-- Backfill migration: cattura colonne aggiunte manualmente al DB live di plant_knowledge
-- (mai tracciate in migration precedenti) e la riga 'anguria' seminata fuori dal flusso migration.
-- Idempotente: ADD COLUMN IF NOT EXISTS + INSERT ON CONFLICT DO NOTHING, no-op sul DB live attuale.

ALTER TABLE plant_knowledge
  ADD COLUMN IF NOT EXISTS ph_min numeric,
  ADD COLUMN IF NOT EXISTS ph_max numeric,
  ADD COLUMN IF NOT EXISTS temp_germ_min numeric,
  ADD COLUMN IF NOT EXISTS temp_ott_min numeric,
  ADD COLUMN IF NOT EXISTS temp_ott_max numeric,
  ADD COLUMN IF NOT EXISTS temp_toll_min numeric,
  ADD COLUMN IF NOT EXISTS mesi_fioritura integer[];

INSERT INTO plant_knowledge (
  slug, specie_nome, specie_nome_scientifico, growth_days, tipo, difficolta,
  descrizione, annaffiatura, esposizione,
  semina_mesi_esterno, semina_mesi_interno, mesi_raccolta,
  piante_compagne, piante_incompatibili,
  ph_min, ph_max, temp_germ_min, temp_ott_min, temp_ott_max, temp_toll_min,
  attivita_suggerite
) VALUES (
  'anguria', 'Anguria', 'Citrullus lanatus', 90, 'ortaggio', 'Media',
  'Frutto estivo dissetante, pianta molto espansa.', 'Abbondante, ridurre a maturazione', 'Pieno sole',
  ARRAY[5,6], ARRAY[4], ARRAY[8,9],
  ARRAY['Mais Dolce'], ARRAY['Patata'],
  6.0, 6.8, 16, 24, 30, 8,
  '[
    {"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 3, "color": "blue"},
    {"nome": "Concimazione", "offset_days": 20, "recurrence_days": 25, "color": "green"},
    {"nome": "Raccolta", "offset_days": 90, "recurrence_days": null, "color": "orange"}
  ]'::jsonb
)
ON CONFLICT (slug) DO NOTHING;
