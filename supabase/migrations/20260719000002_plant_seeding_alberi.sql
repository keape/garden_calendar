-- Migration: plant_seeding_alberi
-- Aggiunge sezione "Albero" al catalogo: querce, tigli, pioppi

INSERT INTO plant_knowledge (slug, specie_nome, growth_days, semina_mesi_esterno, semina_mesi_interno, specie_nome_scientifico, descrizione, annaffiatura, esposizione, tipo, difficolta, mesi_raccolta, piante_compagne, piante_incompatibili, attivita_suggerite)
VALUES

-- 1. Quercia
('quercia', 'Quercia', 3650, '{10,11,3,4}', '{}', 'Quercus robur',
 'Albero maestoso a foglia caduca, longevo (centinaia di anni). Radice fittonante profonda, richiede ampio spazio. Cresce lentamente nei primi anni.',
 'ogni 10-14 giorni nel primo anno, poi autosufficiente con le piogge', 'Pieno sole',
 'albero', 'Medio', '{}',
 '{}', '{}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 12, "color": "blue"}, {"nome": "Potatura formazione", "offset_days": 365, "recurrence_days": 365, "color": "purple"}]'::jsonb),

-- 2. Tiglio
('tiglio', 'Tiglio', 2555, '{10,11,3,4}', '{}', 'Tilia platyphyllos',
 'Albero ornamentale e mellifero a foglia caduca, chioma ampia e ombreggiante. Fiori profumati usati per tisane. Buona resistenza all inquinamento urbano.',
 'ogni 7-10 giorni nel primo anno, poi occasionale nei periodi siccitosi', 'Pieno sole o mezza ombra',
 'albero', 'Facile', '{}',
 '{}', '{}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 8, "color": "blue"}, {"nome": "Raccolta fiori", "offset_days": 730, "recurrence_days": 365, "color": "orange"}, {"nome": "Potatura", "offset_days": 365, "recurrence_days": 365, "color": "purple"}]'::jsonb),

-- 3. Pioppo
('pioppo', 'Pioppo', 1825, '{11,12,2,3}', '{}', 'Populus nigra',
 'Albero a crescita rapida, ideale per filari e frangivento. Richiede terreno fresco e umido, spesso vicino a corsi d acqua. Radici superficiali ed espansive.',
 'ogni 5-7 giorni nel primo anno, poi abbondante in estate se il terreno è asciutto', 'Pieno sole',
 'albero', 'Facile', '{}',
 '{}', '{}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 6, "color": "blue"}, {"nome": "Potatura", "offset_days": 365, "recurrence_days": 365, "color": "purple"}]'::jsonb)

ON CONFLICT (slug) DO NOTHING;
