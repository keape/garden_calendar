-- Migration: plant_library
-- Aggiunge campi arricchiti a plant_knowledge per la libreria piante v1

-- Campi semina (potrebbero già esistere da migration precedente)
ALTER TABLE plant_knowledge
  ADD COLUMN IF NOT EXISTS semina_mesi_esterno integer[] NOT NULL DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS semina_mesi_interno integer[] NOT NULL DEFAULT '{}';

-- Nuovi campi arricchiti (tutti nullable — le 8 piante esistenti rimangono valide)
ALTER TABLE plant_knowledge
  ADD COLUMN IF NOT EXISTS specie_nome_scientifico text,
  ADD COLUMN IF NOT EXISTS descrizione text,
  ADD COLUMN IF NOT EXISTS annaffiatura text,
  ADD COLUMN IF NOT EXISTS esposizione text,
  ADD COLUMN IF NOT EXISTS tipo text,
  ADD COLUMN IF NOT EXISTS difficolta text,
  ADD COLUMN IF NOT EXISTS image_url text,
  ADD COLUMN IF NOT EXISTS mesi_raccolta integer[],
  ADD COLUMN IF NOT EXISTS piante_compagne text[],
  ADD COLUMN IF NOT EXISTS piante_incompatibili text[];

-- Index full-text search italiano (potrebbe già esistere)
CREATE INDEX IF NOT EXISTS idx_plant_knowledge_search
  ON plant_knowledge USING gin(to_tsvector('italian', specie_nome));

-- Aggiorna le 8 piante esistenti con dati arricchiti (UPDATE)
UPDATE plant_knowledge SET
  semina_mesi_esterno = '{4,5}',
  semina_mesi_interno = '{2,3}',
  specie_nome_scientifico = 'Solanum lycopersicum',
  descrizione = 'Ortaggio estivo molto diffuso. Richiede sostegno con tutori e pinzatura dei polloni per produzioni abbondanti.',
  annaffiatura = 'ogni 3-4 giorni, evitare ristagni',
  esposizione = 'Pieno sole (6+ ore)',
  tipo = 'ortaggio',
  difficolta = 'Medio',
  mesi_raccolta = '{7,8,9}',
  piante_compagne = '{Basilico,Carota,Prezzemolo}',
  piante_incompatibili = '{Finocchio,Cavolo}'
WHERE slug = 'pomodoro-san-marzano';

UPDATE plant_knowledge SET
  semina_mesi_esterno = '{4,5,6}',
  semina_mesi_interno = '{3,4}',
  specie_nome_scientifico = 'Ocimum basilicum',
  descrizione = 'Aromatica estiva sensibile al freddo. Teme il vento e le temperature sotto 10°C. Ottimo compagno del pomodoro.',
  annaffiatura = 'ogni 2-3 giorni, terreno umido non saturo',
  esposizione = 'Pieno sole o mezza ombra',
  tipo = 'aromatica',
  difficolta = 'Facile',
  mesi_raccolta = '{6,7,8,9}',
  piante_compagne = '{Pomodoro,Peperone,Zucchina}',
  piante_incompatibili = '{Salvia,Rosmarino}'
WHERE slug = 'basilico-genovese';

UPDATE plant_knowledge SET
  semina_mesi_esterno = '{4,5}',
  semina_mesi_interno = '{3}',
  specie_nome_scientifico = 'Cucurbita pepo',
  descrizione = 'Ortaggio vigoroso a rapida crescita. Necessita di molto spazio (min. 1m²) e impollinazione incrociata.',
  annaffiatura = 'ogni 3-4 giorni, abbondante in estate',
  esposizione = 'Pieno sole',
  tipo = 'ortaggio',
  difficolta = 'Facile',
  mesi_raccolta = '{6,7,8,9}',
  piante_compagne = '{Basilico,Fagiolo,Mais}',
  piante_incompatibili = '{Patata,Finocchio}'
WHERE slug = 'zucchine-romanesco';

UPDATE plant_knowledge SET
  semina_mesi_esterno = '{3,4,8,9}',
  semina_mesi_interno = '{2,3}',
  specie_nome_scientifico = 'Lactuca sativa',
  descrizione = 'Ortaggio a foglia di rapida crescita. Preferisce temperature fresche; va in fiore con il caldo estivo.',
  annaffiatura = 'ogni 2 giorni, costante',
  esposizione = 'Sole o mezza ombra',
  tipo = 'ortaggio',
  difficolta = 'Facile',
  mesi_raccolta = '{4,5,6,9,10}',
  piante_compagne = '{Carota,Ravanello,Cipolla}',
  piante_incompatibili = '{Sedano,Prezzemolo}'
WHERE slug = 'lattuga-canasta';

UPDATE plant_knowledge SET
  semina_mesi_esterno = '{3,4,8,9}',
  semina_mesi_interno = '{}',
  specie_nome_scientifico = 'Raphanus sativus',
  descrizione = 'Radice a crescita molto rapida, ideale per riempire spazi vuoti nell orto. Ottimo indicatore della salute del suolo.',
  annaffiatura = 'ogni 2 giorni, regolare',
  esposizione = 'Sole o mezza ombra',
  tipo = 'ortaggio',
  difficolta = 'Facile',
  mesi_raccolta = '{4,5,9,10}',
  piante_compagne = '{Lattuga,Carota,Spinacio}',
  piante_incompatibili = '{Cavolo}'
WHERE slug = 'ravanelli';

UPDATE plant_knowledge SET
  semina_mesi_esterno = '{4,5}',
  semina_mesi_interno = '{3}',
  specie_nome_scientifico = 'Phaseolus vulgaris',
  descrizione = 'Legume rampicante che fissa l azoto nel suolo. Necessita di sostegno (rete o paletti da 1.5m).',
  annaffiatura = 'ogni 3-4 giorni, evitare bagnare i fiori',
  esposizione = 'Pieno sole',
  tipo = 'ortaggio',
  difficolta = 'Facile',
  mesi_raccolta = '{7,8,9}',
  piante_compagne = '{Carota,Cetriolo,Mais}',
  piante_incompatibili = '{Cipolla,Aglio,Finocchio}'
WHERE slug = 'fagiolini-rampicanti';

UPDATE plant_knowledge SET
  semina_mesi_esterno = '{4,5}',
  semina_mesi_interno = '{2,3}',
  specie_nome_scientifico = 'Capsicum annuum',
  descrizione = 'Ortaggio termofilo che richiede temperature costanti >15°C. Sensibile agli sbalzi termici, beneficia di pacciamatura.',
  annaffiatura = 'ogni 3 giorni, costante',
  esposizione = 'Pieno sole',
  tipo = 'ortaggio',
  difficolta = 'Medio',
  mesi_raccolta = '{7,8,9,10}',
  piante_compagne = '{Basilico,Carota,Cipolla}',
  piante_incompatibili = '{Finocchio,Cavolo}'
WHERE slug = 'peperoni-corno';

UPDATE plant_knowledge SET
  semina_mesi_esterno = '{4,5}',
  semina_mesi_interno = '{2,3}',
  specie_nome_scientifico = 'Solanum melongena',
  descrizione = 'Ortaggio estivo che ama il calore. Richiede potatura delle cime per produzione abbondante. Sensibile agli afidi.',
  annaffiatura = 'ogni 3 giorni, costante',
  esposizione = 'Pieno sole',
  tipo = 'ortaggio',
  difficolta = 'Medio',
  mesi_raccolta = '{7,8,9,10}',
  piante_compagne = '{Basilico,Peperone,Fagiolo}',
  piante_incompatibili = '{Finocchio,Patata}'
WHERE slug = 'melanzane-violetta';
