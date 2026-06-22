-- Migration: plant_seeding
-- Inserisce 22 piante nel catalogo (le 8 esistenti non vengono toccate)

INSERT INTO plant_knowledge (slug, specie_nome, growth_days, semina_mesi_esterno, semina_mesi_interno, specie_nome_scientifico, descrizione, annaffiatura, esposizione, tipo, difficolta, mesi_raccolta, piante_compagne, piante_incompatibili, attivita_suggerite)
VALUES

-- 1. Carote
('carote', 'Carote', 90, '{3,4,8,9}', '{2,3}', 'Daucus carota',
 'Radice dolce ideale per terreni sciolti e profondi. Evitare concimazioni azotate eccessive che favoriscono lo sviluppo fogliare a scapito della radice.',
 'ogni 3-4 giorni, costante ma non eccessiva', 'Pieno sole o mezza ombra',
 'ortaggio', 'Facile', '{7,8,9,10}',
 '{Cipolla,Prezzemolo,Lattuga}', '{Aneto,Finocchio}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 4, "color": "blue"}, {"nome": "Raccolta", "offset_days": 80, "recurrence_days": null, "color": "orange"}]'::jsonb),

-- 2. Cipolle
('cipolle', 'Cipolle', 150, '{2,3,4}', '{1,2}', 'Allium cepa',
 'Bulbo che richiede terreno ben drenato. La maturazione è segnalata dall ingiallimento e caduta del fogliame.',
 'ogni 5-7 giorni, ridurre prima della raccolta', 'Pieno sole',
 'ortaggio', 'Facile', '{7,8}',
 '{Carota,Lattuga,Pomodoro}', '{Fagiolo,Pisello}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 6, "color": "blue"}, {"nome": "Concimazione", "offset_days": 30, "recurrence_days": 30, "color": "red"}, {"nome": "Raccolta", "offset_days": 140, "recurrence_days": null, "color": "orange"}]'::jsonb),

-- 3. Aglio
('aglio', 'Aglio', 240, '{10,11}', '{}', 'Allium sativum',
 'Bulbo piantato autunnale e raccolto in estate. I bulbi si dividono in spicchi prima della messa a dimora.',
 'ogni 7-10 giorni, ridurre drasticamente a maggio', 'Pieno sole',
 'ortaggio', 'Facile', '{6,7}',
 '{Pomodoro,Carota,Rosa}', '{Fagiolo,Pisello,Cipolla}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 8, "color": "blue"}, {"nome": "Raccolta", "offset_days": 220, "recurrence_days": null, "color": "orange"}]'::jsonb),

-- 4. Prezzemolo
('prezzemolo', 'Prezzemolo', 70, '{3,4,5,8,9}', '{2,3}', 'Petroselinum crispum',
 'Aromatica biennale dalla germinazione lenta (2-4 settimane). Immergere i semi in acqua tiepida 24h prima della semina per accelerare la germinazione.',
 'ogni 2-3 giorni, terreno sempre umido', 'Sole o mezza ombra',
 'aromatica', 'Facile', '{5,6,7,8,9,10}',
 '{Pomodoro,Carota,Asparago}', '{Lattuga}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 3, "color": "blue"}, {"nome": "Raccolta foglie", "offset_days": 60, "recurrence_days": 14, "color": "orange"}]'::jsonb),

-- 5. Sedano
('sedano', 'Sedano', 120, '{3,4}', '{1,2,3}', 'Apium graveolens',
 'Ortaggio esigente in fatto di umidità e nutrienti. Richiede lunghi tempi di coltivazione e condizioni regolari.',
 'ogni 2 giorni, abbondante e costante', 'Sole o mezza ombra',
 'ortaggio', 'Difficile', '{9,10,11}',
 '{Cavolo,Pomodoro,Fagiolo}', '{Mais,Patata}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 2, "color": "blue"}, {"nome": "Concimazione", "offset_days": 30, "recurrence_days": 21, "color": "red"}, {"nome": "Raccolta", "offset_days": 110, "recurrence_days": null, "color": "orange"}]'::jsonb),

-- 6. Cavolo
('cavolo', 'Cavolo', 90, '{3,4,7,8}', '{2,3,6,7}', 'Brassica oleracea var. capitata',
 'Ortaggio resistente al freddo, adatto alle coltivazioni autunnali e invernali. Teme il caldo estivo intenso.',
 'ogni 3-4 giorni, costante', 'Pieno sole o mezza ombra',
 'ortaggio', 'Medio', '{10,11,12,1}',
 '{Sedano,Menta,Aneto}', '{Pomodoro,Fragola,Ravanello}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 4, "color": "blue"}, {"nome": "Concimazione azotata", "offset_days": 21, "recurrence_days": 21, "color": "red"}, {"nome": "Raccolta", "offset_days": 80, "recurrence_days": null, "color": "orange"}]'::jsonb),

-- 7. Broccoli
('broccoli', 'Broccoli', 90, '{3,4,7,8}', '{2,3,6,7}', 'Brassica oleracea var. italica',
 'Crocifere produttive in climi temperati. Dopo la raccolta della testa centrale produce germogli laterali per settimane.',
 'ogni 3-4 giorni', 'Pieno sole',
 'ortaggio', 'Facile', '{9,10,11}',
 '{Sedano,Cipolla,Patata}', '{Pomodoro,Peperone}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 4, "color": "blue"}, {"nome": "Raccolta testa", "offset_days": 80, "recurrence_days": null, "color": "orange"}, {"nome": "Raccolta laterali", "offset_days": 90, "recurrence_days": 10, "color": "orange"}]'::jsonb),

-- 8. Spinaci
('spinaci', 'Spinaci', 50, '{2,3,9,10}', '{1,2,9}', 'Spinacia oleracea',
 'Ortaggio a foglia invernale che va in fiore con l arrivo del caldo. Varietà resistenti al freddo fino a -8°C.',
 'ogni 2-3 giorni, costante', 'Sole o mezza ombra',
 'ortaggio', 'Facile', '{4,5,11,12}',
 '{Lattuga,Fragola,Ravanello}', '{Barbabietola}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 3, "color": "blue"}, {"nome": "Raccolta foglie", "offset_days": 40, "recurrence_days": 10, "color": "orange"}]'::jsonb),

-- 9. Piselli
('piselli', 'Piselli', 70, '{2,3,10,11}', '{}', 'Pisum sativum',
 'Legume rampicante che fissa l azoto. Predilige temperature fresche; con il caldo estivo la produzione si esaurisce.',
 'ogni 4-5 giorni, moderata', 'Pieno sole',
 'ortaggio', 'Facile', '{5,6}',
 '{Carota,Ravanello,Spinacio}', '{Cipolla,Aglio,Scalogno}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 5, "color": "blue"}, {"nome": "Raccolta", "offset_days": 60, "recurrence_days": 7, "color": "orange"}]'::jsonb),

-- 10. Cetrioli
('cetrioli', 'Cetrioli', 60, '{4,5,6}', '{3,4}', 'Cucumis sativus',
 'Ortaggio estivo rampicante o strisciante. La raccolta frequente stimola la produzione. Sensibile al freddo e al ristagno.',
 'ogni 2-3 giorni, abbondante in estate', 'Pieno sole',
 'ortaggio', 'Facile', '{6,7,8,9}',
 '{Fagiolo,Pisello,Mais}', '{Salvia,Patata}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 3, "color": "blue"}, {"nome": "Raccolta", "offset_days": 50, "recurrence_days": 5, "color": "orange"}]'::jsonb),

-- 11. Cocomero
('cocomero', 'Cocomero', 90, '{4,5}', '{3,4}', 'Citrullus lanatus',
 'Frutto estivo che richiede molto calore e spazio (min. 2m²/pianta). La maturità si riconosce dal suono sordo alla bussatura.',
 'ogni 4-5 giorni, abbondante; ridurre a maturazione', 'Pieno sole',
 'frutto', 'Medio', '{7,8,9}',
 '{Mais,Fagiolo,Basilico}', '{Patata,Finocchio}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 5, "color": "blue"}, {"nome": "Concimazione potassio", "offset_days": 30, "recurrence_days": 21, "color": "red"}, {"nome": "Raccolta", "offset_days": 80, "recurrence_days": null, "color": "orange"}]'::jsonb),

-- 12. Melone
('melone', 'Melone', 90, '{4,5}', '{3,4}', 'Cucumis melo',
 'Frutto dolce estivo che richiede caldo e asciutto. La profumazione intensa indica la maturità. Limitare a 3-4 frutti per pianta.',
 'ogni 4-5 giorni, ridurre nell ultima settimana prima della raccolta', 'Pieno sole',
 'frutto', 'Medio', '{7,8,9}',
 '{Mais,Girasole,Basilico}', '{Patata,Zucchina}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 5, "color": "blue"}, {"nome": "Cimatura germogli", "offset_days": 30, "recurrence_days": null, "color": "purple"}, {"nome": "Raccolta", "offset_days": 80, "recurrence_days": null, "color": "orange"}]'::jsonb),

-- 13. Patate
('patate', 'Patate', 120, '{3,4}', '{}', 'Solanum tuberosum',
 'Tubero a produzione sotterranea. La rincalzatura periodica aumenta la resa. Evitare terreni con ristagno idrico.',
 'ogni 5-7 giorni, abbondante durante la fioritura', 'Pieno sole',
 'ortaggio', 'Facile', '{7,8,9}',
 '{Fagiolo,Cavolo,Mais}', '{Pomodoro,Melanzana,Finocchio}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 6, "color": "blue"}, {"nome": "Rincalzatura", "offset_days": 30, "recurrence_days": null, "color": "purple"}, {"nome": "Raccolta", "offset_days": 110, "recurrence_days": null, "color": "orange"}]'::jsonb),

-- 14. Porri
('porri', 'Porri', 150, '{2,3,4}', '{1,2}', 'Allium ampeloprasum',
 'Ortaggio alliaceo con crescita lenta ma robusta. Il blanching (interramento del fusto) migliora la tenerezza.',
 'ogni 5-7 giorni', 'Pieno sole',
 'ortaggio', 'Facile', '{10,11,12,1,2}',
 '{Carota,Sedano,Lattuga}', '{Fagiolo,Pisello}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 6, "color": "blue"}, {"nome": "Rincalzatura", "offset_days": 60, "recurrence_days": null, "color": "purple"}, {"nome": "Raccolta", "offset_days": 140, "recurrence_days": null, "color": "orange"}]'::jsonb),

-- 15. Carciofi
('carciofi', 'Carciofi', 180, '{3,4}', '{}', 'Cynara cardunculus var. scolymus',
 'Ortaggio perenne a ciclo biennale/perenne. Nel primo anno sviluppa la pianta; dal secondo anno produce i capolini. Molto rustico.',
 'ogni 5-7 giorni, abbondante in estate', 'Pieno sole',
 'ortaggio', 'Medio', '{3,4,5}',
 '{Fagiolo,Lattuga,Cipolla}', '{Patata}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 6, "color": "blue"}, {"nome": "Concimazione", "offset_days": 30, "recurrence_days": 30, "color": "red"}, {"nome": "Raccolta capolini", "offset_days": 160, "recurrence_days": 7, "color": "orange"}]'::jsonb),

-- 16. Rosmarino
('rosmarino', 'Rosmarino', 120, '{3,4,5,9}', '{2,3}', 'Salvia rosmarinus',
 'Aromatica perenne mediterranea molto resistente alla siccità. Ottimo su terreni calcarei e ben drenati. Non sopporta i ristagni.',
 'ogni 7-10 giorni, solo se non piove', 'Pieno sole',
 'aromatica', 'Facile', '{4,5,6,7,8,9,10,11}',
 '{Salvia,Lavanda,Carota}', '{Basilico,Menta}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 10, "color": "blue"}, {"nome": "Potatura", "offset_days": 60, "recurrence_days": 60, "color": "purple"}, {"nome": "Raccolta rametti", "offset_days": 90, "recurrence_days": 14, "color": "orange"}]'::jsonb),

-- 17. Timo
('timo', 'Timo', 90, '{3,4,5,9}', '{2,3}', 'Thymus vulgaris',
 'Aromatica perenne a bassa manutenzione. Ottimo per aiuole bordo-orto e copertura del suolo. Fiorisce a maggio.',
 'ogni 7-10 giorni, molto resistente alla siccità', 'Pieno sole',
 'aromatica', 'Facile', '{4,5,6,7,8,9,10}',
 '{Rosmarino,Lavanda,Cavolo}', '{Basilico}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 10, "color": "blue"}, {"nome": "Raccolta rametti", "offset_days": 80, "recurrence_days": 14, "color": "orange"}]'::jsonb),

-- 18. Menta
('menta', 'Menta', 60, '{3,4,5}', '{2,3}', 'Mentha',
 'Aromatica perenne a crescita invasiva. Coltivare in vaso o con barriere interrate per limitarne la diffusione via rizomi.',
 'ogni 3-4 giorni, terreno umido', 'Sole o mezza ombra',
 'aromatica', 'Facile', '{5,6,7,8,9,10}',
 '{Pomodoro,Cavolo,Pisello}', '{Prezzemolo,Aneto}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 4, "color": "blue"}, {"nome": "Cimatura", "offset_days": 30, "recurrence_days": 21, "color": "purple"}, {"nome": "Raccolta foglie", "offset_days": 50, "recurrence_days": 14, "color": "orange"}]'::jsonb),

-- 19. Origano
('origano', 'Origano', 90, '{3,4,5}', '{2,3}', 'Origanum vulgare',
 'Aromatica perenne essenziale della cucina mediterranea. Maggiore concentrazione di oli essenziali prima della fioritura.',
 'ogni 7-10 giorni, resistente alla siccità', 'Pieno sole',
 'aromatica', 'Facile', '{5,6,7,8,9,10}',
 '{Pomodoro,Peperone,Basilico}', '{}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 10, "color": "blue"}, {"nome": "Raccolta foglie", "offset_days": 80, "recurrence_days": 14, "color": "orange"}]'::jsonb),

-- 20. Salvia
('salvia', 'Salvia', 120, '{3,4,5}', '{2,3}', 'Salvia officinalis',
 'Aromatica perenne legnosa con proprietà antibatteriche. Evitare il ristagno idrico. Rinnovarla ogni 3-4 anni con talee.',
 'ogni 7-10 giorni, ben drenato', 'Pieno sole',
 'aromatica', 'Facile', '{4,5,6,7,8,9,10}',
 '{Rosmarino,Carota,Cavolo}', '{Basilico,Cipolla}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 10, "color": "blue"}, {"nome": "Potatura primavera", "offset_days": 60, "recurrence_days": null, "color": "purple"}, {"nome": "Raccolta foglie", "offset_days": 100, "recurrence_days": 14, "color": "orange"}]'::jsonb),

-- 21. Fagioli (borlotti)
('fagioli-borlotti', 'Fagioli', 70, '{4,5,6}', '{}', 'Phaseolus vulgaris var. borlotti',
 'Legume da granella che fissa l azoto nel suolo. Ottimo per migliorare la fertilità. Non richiedono concimazione azotata.',
 'ogni 4-5 giorni, evitare bagnare i baccelli', 'Pieno sole',
 'ortaggio', 'Facile', '{7,8,9}',
 '{Mais,Zucchina,Carota}', '{Cipolla,Aglio,Finocchio}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 5, "color": "blue"}, {"nome": "Raccolta baccelli verdi", "offset_days": 60, "recurrence_days": null, "color": "orange"}, {"nome": "Raccolta granella secca", "offset_days": 70, "recurrence_days": null, "color": "orange"}]'::jsonb),

-- 22. Rucola
('rucola', 'Rucola', 40, '{3,4,5,8,9,10}', '{2,3,9}', 'Eruca vesicaria',
 'Insalata a sapore piccante e crescita molto rapida. In estate tende ad andare in fiore rapidamente; preferire colture primaverili e autunnali.',
 'ogni 2 giorni, costante', 'Sole o mezza ombra',
 'ortaggio', 'Facile', '{4,5,6,9,10,11}',
 '{Pomodoro,Carota,Ravanello}', '{Cavolo}',
 '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 2, "color": "blue"}, {"nome": "Raccolta foglie", "offset_days": 30, "recurrence_days": 7, "color": "orange"}]'::jsonb)

ON CONFLICT (slug) DO NOTHING;
