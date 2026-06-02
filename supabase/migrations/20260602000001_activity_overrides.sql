-- Migration: aggiunge colonna activity_overrides a piante_coltivate
-- Struttura: [{"nome": "Irrigazione", "recurrence_days": 4}, {"nome": "Raccolta", "offset_days": 85}]
alter table piante_coltivate
  add column activity_overrides jsonb;
