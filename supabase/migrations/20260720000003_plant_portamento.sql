-- Aggiunge il campo portamento (tappezzante/ricadente/rampicante/eretto/cespuglioso)
-- alla knowledge base delle piante. Testo libero, valorizzato via backfill AI
-- (Edge Function backfill-plant-portamento) e bucketizzato lato client per il filtro catalogo.
ALTER TABLE plant_knowledge
  ADD COLUMN IF NOT EXISTS portamento text;
