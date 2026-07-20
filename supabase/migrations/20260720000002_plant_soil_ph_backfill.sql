-- Backfill retroattivo: campo terriccio (nuova colonna) per tutte le 230 piante,
-- + completamento ph_min/ph_max mancante (alberi e piante d'appartamento, 101 righe).
-- Idempotente: ADD COLUMN IF NOT EXISTS + UPDATE condizionati.

ALTER TABLE plant_knowledge
  ADD COLUMN IF NOT EXISTS terriccio text;

-- =========================================================================
-- 1. TERRICCIO -- ORTAGGIO (57)
-- =========================================================================

-- radice/bulbo: sciolto, sabbioso, senza sassi
UPDATE plant_knowledge SET terriccio = 'Terreno sciolto, sabbioso-limoso, profondo e privo di sassi, per non ostacolare lo sviluppo di radice o bulbo.'
WHERE slug IN ('aglio','asparago','barbabietola-rossa','carota','cipolla-dorata','finocchio','porro','prezzemolo-radice','rapa','ravanelli','scalogno','topinambur','zenzero');

-- cucurbitacee/fruttiferi esigenti: molto fertile, ricco, trattiene umidita
UPDATE plant_knowledge SET terriccio = 'Terreno molto fertile, ricco di sostanza organica, profondo e ben drenato, con buona capacita di trattenere l''umidita.'
WHERE slug IN ('anguria','cetriolino-sottaceto','cetriolo','mais-dolce','melanzane-violetta','melone-retato','okra','peperoncino-habanero','peperoncino-piccante','peperone-friggitello','peperone-lungo-rosso','peperone-quadrato','peperoni-corno','pomodorino-ciliegino','pomodoro-cuore-di-bue','pomodoro-datterino','pomodoro-san-marzano','sedano','spinacio','zucca-mantovana','zucca-violina','zucchina-tonda','zucchina-trombetta','zucchine-romanesco','carciofo','cardo');

-- patata: sciolto, leggermente acido
UPDATE plant_knowledge SET terriccio = 'Terreno sciolto, sabbioso, leggermente acido, ben drenato, arricchito con sostanza organica matura.'
WHERE slug = 'patata';

-- default orto: soffice, ben drenato, medio impasto
UPDATE plant_knowledge SET terriccio = 'Terreno soffice e ben drenato, ricco di sostanza organica, tessitura medio-impastata (franco).'
WHERE slug IN ('bietola','broccolo','cavolfiore','cavolo-cappuccio','cavolo-nero','cavolo-rapa','cicoria-catalogna','fagiolini-rampicanti','fagiolo-borlotto','fagiolo-cannellino','fava','indivia-riccia','lattuga-canasta','lattuga-gentile','pisello','radicchio-rosso','rucola');

-- =========================================================================
-- 2. TERRICCIO -- FRUTTO (26)
-- =========================================================================

UPDATE plant_knowledge SET terriccio = 'Terriccio acido specifico per ericacee (a base di torba, pH acido), ben drenato.'
WHERE slug = 'mirtillo';

UPDATE plant_knowledge SET terriccio = 'Terreno ricco di humus, fresco, ben drenato, leggermente acido.'
WHERE slug IN ('fragola','lampone','more','ribes-rosso','uva-spina');

UPDATE plant_knowledge SET terriccio = 'Terreno drenante, leggermente sabbioso, ricco di sostanza organica; teme i ristagni idrici.'
WHERE slug IN ('arancio','lime','limone','mandarino');

UPDATE plant_knowledge SET terriccio = 'Terreno profondo, fertile, ben drenato, di medio impasto.'
WHERE slug IN ('albicocco','cachi','ciliegio','fico','gelso','kiwi','melo','melograno','nespolo','nocciolo','noce','pero','pesco','susino','uva-da-tavola','uva-fragola');

-- =========================================================================
-- 3. TERRICCIO -- AROMATICA (25)
-- =========================================================================

UPDATE plant_knowledge SET terriccio = 'Terreno drenante, anche povero e sassoso; non deve mai ristagnare acqua.'
WHERE slug IN ('issopo','lavanda','maggiorana','origano','rosmarino','salvia','santoreggia','timo');

UPDATE plant_knowledge SET terriccio = 'Terreno fertile, ricco di humus, fresco e ben drenato.'
WHERE slug IN ('aneto','anice-verde','basilico-genovese','basilico-thai','basilico-viola','borragine','camomilla','cerfoglio','cumino-dei-prati','dragoncello','erba-cipollina','finocchietto-selvatico','levistico','melissa','menta','prezzemolo-riccio','stevia');

-- =========================================================================
-- 4. TERRICCIO -- FIORE (19)
-- =========================================================================

UPDATE plant_knowledge SET terriccio = 'Terriccio acido per ericacee, ricco di humus, ben drenato (il pH influenza il colore dei fiori).'
WHERE slug = 'ortensia';

UPDATE plant_knowledge SET terriccio = 'Terreno ben drenato, di medio impasto, arricchito con sostanza organica; teme i ristagni.'
WHERE slug IN ('iris','tulipano','dalia','lilium');

UPDATE plant_knowledge SET terriccio = 'Terreno ricco di humus, fresco, in posizione ombreggiata.'
WHERE slug IN ('hosta','mughetto');

UPDATE plant_knowledge SET terriccio = 'Terriccio leggero, ben drenato, ricco di sostanza organica.'
WHERE slug IN ('ciclamino','petunia');

UPDATE plant_knowledge SET terriccio = 'Terreno fertile, ben drenato, ricco di sostanza organica.'
WHERE slug IN ('calendula','geranio','girasole','lantana','margherita','nasturzio','peonia','rosa','viola-del-pensiero','zinnia');

-- =========================================================================
-- 5. TERRICCIO -- ALBERO (52)
-- =========================================================================

UPDATE plant_knowledge SET terriccio = 'Terreno acido, privo di calcare, fresco e ben drenato.'
WHERE slug IN ('abete_bianco','abete_rosso','larice','castagno','sughera','corbezzolo','mimosa','magnolia','ontano_nero');

UPDATE plant_knowledge SET terriccio = 'Terreno ben drenato, anche povero o sassoso; tollera bene la siccita una volta attecchito.'
WHERE slug IN ('cipresso_comune','ginepro_comune','tasso','sequoia','cedro_libano','douglasia','pino_silvestre','pino_marittimo','pino_domestico');

UPDATE plant_knowledge SET terriccio = 'Terreno fresco, anche pesante o umido, tollera bene i ristagni idrici occasionali.'
WHERE slug IN ('salice_bianco','salice_piangente','pioppo','ontano_bianco','betulla');

UPDATE plant_knowledge SET terriccio = 'Terreno anche calcareo e roccioso, ben drenato; specie rustica poco esigente.'
WHERE slug IN ('carpino_nero','roverella','bagolaro','frassino_ornello','carrubo','ailanto','leccio');

UPDATE plant_knowledge SET terriccio = 'Terreno ben drenato, tollerante alla siccita, non esigente in fertilita.'
WHERE slug IN ('eucalipto','palma_canarie','jacaranda','ginkgo');

UPDATE plant_knowledge SET terriccio = 'Terreno anche sabbioso e salino, ben drenato; specie molto rustica e tollerante.'
WHERE slug = 'tamerice';

UPDATE plant_knowledge SET terriccio = 'Terreno di medio impasto, profondo, fresco e ben drenato, ricco di sostanza organica.'
WHERE slug IN ('acero_campestre','acero_negundo','acero_riccio','acero_rosso','carpino_bianco','cerro','faggio','frassino_maggiore','ippocastano','noce_comune','olmo_campestre','olmo_montano','platano','quercia','robinia','tiglio','tiglio_argenteo');

-- =========================================================================
-- 6. TERRICCIO -- APPARTAMENTO (49)
-- =========================================================================

UPDATE plant_knowledge SET terriccio = 'Terriccio per piante grasse/cactacee, sabbioso e molto drenante, senza ristagni.'
WHERE slug IN ('aloe_vera','crassula_ovata','echeveria','echinocactus','euphorbia_trigona','haworthia','kalanchoe','opuntia_microdasys','sedum_morganianum','beaucarnea','cycas');

UPDATE plant_knowledge SET terriccio = 'Substrato speciale per orchidee (corteccia di pino, non terriccio tradizionale), molto drenante e aerato.'
WHERE slug = 'orchidea_phalaenopsis';

UPDATE plant_knowledge SET terriccio = 'Terriccio ricco di humus, mantenuto costantemente umido, ben drenato.'
WHERE slug IN ('felce_boston','felce_nido');

UPDATE plant_knowledge SET terriccio = 'Non richiede terriccio: specie epifita, si nutre tramite le foglie e le radici aeree.'
WHERE slug = 'tillandsia';

UPDATE plant_knowledge SET terriccio = 'Terriccio aerato e drenante, arricchito con corteccia e perlite, ricco di sostanza organica.'
WHERE slug IN ('anthurium','monstera','filodendro','pothos','syngonium','alocasia','aglaonema');

UPDATE plant_knowledge SET terriccio = 'Terriccio universale fertile e ben drenante.'
WHERE slug IN ('palma_areca','palma_kentia');

UPDATE plant_knowledge SET terriccio = 'Terriccio universale ben drenato, con aggiunta di sabbia o perlite per evitare ristagni.'
WHERE slug IN ('sansevieria','sansevieria_cylindrica','zamioculcas','yucca','dracena_marginata','cordyline','tronchetto_felicita','strelitzia','schefflera','croton');

UPDATE plant_knowledge SET terriccio = 'Terriccio universale ricco di humus, che mantenga una leggera umidita costante ma ben drenato.'
WHERE slug IN ('calathea_orbifolia','maranta','fittonia','begonia_maculata','peperomia','pilea','nastrino','spatifillo','hoya','rhipsalis','ficus_benjamin','ficus_elastica','ficus_lyrata','ficus_pumila','tradescantia');

-- =========================================================================
-- 7. TERRICCIO -- ALTRO (2)
-- =========================================================================

UPDATE plant_knowledge SET terriccio = 'Terreno di medio impasto, anche povero, ben drenato; pianta rustica poco esigente.'
WHERE slug = 'edera';

UPDATE plant_knowledge SET terriccio = 'Terriccio ricco di humus, mantenuto costantemente umido, ben drenato.'
WHERE slug = 'felce';

-- =========================================================================
-- 8. PH -- backfill dei mancanti (solo dove ph_min IS NULL)
-- =========================================================================

-- ALBERI acidofili
UPDATE plant_knowledge SET ph_min = 5.5, ph_max = 6.5 WHERE slug = 'abete_bianco' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 5.0, ph_max = 6.0 WHERE slug = 'abete_rosso' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 5.0, ph_max = 6.5 WHERE slug = 'larice' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 5.0, ph_max = 6.5 WHERE slug = 'castagno' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 4.5, ph_max = 6.5 WHERE slug = 'sughera' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 4.5, ph_max = 6.5 WHERE slug = 'corbezzolo' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 5.5, ph_max = 6.5 WHERE slug = 'mimosa' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 5.0, ph_max = 6.5 WHERE slug = 'magnolia' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 5.0, ph_max = 6.5 WHERE slug = 'ontano_nero' AND ph_min IS NULL;

-- ALBERI conifere tolleranti
UPDATE plant_knowledge SET ph_min = 6.0, ph_max = 8.0 WHERE slug = 'cipresso_comune' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 5.5, ph_max = 7.5 WHERE slug = 'ginepro_comune' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 6.0, ph_max = 7.5 WHERE slug = 'tasso' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 5.5, ph_max = 6.5 WHERE slug = 'sequoia' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 6.0, ph_max = 7.5 WHERE slug = 'cedro_libano' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 5.5, ph_max = 6.5 WHERE slug = 'douglasia' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 5.0, ph_max = 6.5 WHERE slug = 'pino_silvestre' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 5.0, ph_max = 6.5 WHERE slug = 'pino_marittimo' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 6.0, ph_max = 7.5 WHERE slug = 'pino_domestico' AND ph_min IS NULL;

-- ALBERI ripariali
UPDATE plant_knowledge SET ph_min = 5.5, ph_max = 7.5 WHERE slug = 'salice_bianco' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 5.5, ph_max = 7.5 WHERE slug = 'salice_piangente' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 6.0, ph_max = 7.5 WHERE slug = 'pioppo' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 5.5, ph_max = 7.0 WHERE slug = 'ontano_bianco' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 5.0, ph_max = 6.5 WHERE slug = 'betulla' AND ph_min IS NULL;

-- ALBERI calcicoli
UPDATE plant_knowledge SET ph_min = 6.5, ph_max = 8.0 WHERE slug = 'carpino_nero' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 6.5, ph_max = 8.0 WHERE slug = 'roverella' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 6.5, ph_max = 8.0 WHERE slug = 'bagolaro' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 6.5, ph_max = 8.0 WHERE slug = 'frassino_ornello' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 7.0, ph_max = 8.5 WHERE slug = 'carrubo' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 6.0, ph_max = 8.0 WHERE slug = 'ailanto' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 6.0, ph_max = 8.0 WHERE slug = 'leccio' AND ph_min IS NULL;

-- ALBERI mediterraneo/xerofilo
UPDATE plant_knowledge SET ph_min = 5.5, ph_max = 7.0 WHERE slug = 'eucalipto' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 6.0, ph_max = 7.5 WHERE slug = 'palma_canarie' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 6.0, ph_max = 7.5 WHERE slug = 'jacaranda' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 5.5, ph_max = 7.0 WHERE slug = 'ginkgo' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 6.5, ph_max = 8.0 WHERE slug = 'tamerice' AND ph_min IS NULL;

-- ALBERI default medio impasto
UPDATE plant_knowledge SET ph_min = 6.0, ph_max = 7.5 WHERE slug IN ('acero_campestre','acero_negundo','acero_riccio','olmo_campestre','olmo_montano','frassino_maggiore','ippocastano','noce_comune','platano','quercia','robinia','tiglio','tiglio_argenteo') AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 5.0, ph_max = 6.5 WHERE slug = 'acero_rosso' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 6.0, ph_max = 7.5 WHERE slug = 'carpino_bianco' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 5.5, ph_max = 7.0 WHERE slug = 'cerro' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 5.0, ph_max = 6.5 WHERE slug = 'faggio' AND ph_min IS NULL;

-- APPARTAMENTO (piante da interno)
UPDATE plant_knowledge SET ph_min = 5.5, ph_max = 6.5 WHERE slug IN ('aglaonema','alocasia','anthurium','begonia_maculata','calathea_orbifolia','filodendro','fittonia','maranta','monstera','spatifillo','syngonium') AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 6.0, ph_max = 7.0 WHERE slug IN ('aloe_vera','crassula_ovata','echeveria','echinocactus','euphorbia_trigona','haworthia','rhipsalis','sansevieria','sansevieria_cylindrica','sedum_morganianum','zamioculcas','beaucarnea','cycas') AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 6.0, ph_max = 6.5 WHERE slug IN ('cordyline','croton','dracena_marginata','ficus_benjamin','ficus_elastica','ficus_lyrata','ficus_pumila','hoya','kalanchoe','nastrino','palma_areca','palma_kentia','peperomia','pilea','pothos','schefflera','strelitzia','tradescantia','tronchetto_felicita') AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 5.0, ph_max = 5.5 WHERE slug = 'felce_boston' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 5.5, ph_max = 6.5 WHERE slug = 'felce_nido' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 5.5, ph_max = 6.5 WHERE slug = 'orchidea_phalaenopsis' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 5.0, ph_max = 6.0 WHERE slug = 'tillandsia' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 6.0, ph_max = 7.0 WHERE slug = 'yucca' AND ph_min IS NULL;
UPDATE plant_knowledge SET ph_min = 6.0, ph_max = 7.0 WHERE slug = 'opuntia_microdasys' AND ph_min IS NULL;
