-- Mesi di semina consigliati per specie (1-12, emisfero nord / Italia).
-- semina_mesi_esterno: semina in piena terra / esterno.
-- semina_mesi_interno: semina protetta / interno (semenzaio, davanzale).
-- L'app sfasa di 6 mesi per l'emisfero sud e usa l'array "interno" per i giardini interni.
alter table plant_knowledge
  add column if not exists semina_mesi_esterno smallint[] not null default '{}',
  add column if not exists semina_mesi_interno smallint[] not null default '{}';

update plant_knowledge set semina_mesi_interno = '{2,3}',   semina_mesi_esterno = '{4,5}'        where lower(specie_nome) = 'pomodoro';
update plant_knowledge set semina_mesi_interno = '{2,3}',   semina_mesi_esterno = '{4,5,6}'      where lower(specie_nome) = 'basilico';
update plant_knowledge set semina_mesi_interno = '{1,2}',   semina_mesi_esterno = '{3,4,5,8,9}'  where lower(specie_nome) = 'lattuga';
update plant_knowledge set semina_mesi_interno = '{3}',     semina_mesi_esterno = '{4,5}'        where lower(specie_nome) = 'zucchina';
update plant_knowledge set semina_mesi_interno = '{2,3}',   semina_mesi_esterno = '{5}'          where lower(specie_nome) = 'melanzana';
update plant_knowledge set semina_mesi_interno = '{2,3}',   semina_mesi_esterno = '{5}'          where lower(specie_nome) = 'peperone';
update plant_knowledge set semina_mesi_interno = '{}',      semina_mesi_esterno = '{3,4,5,6,7}'  where lower(specie_nome) = 'carota';
update plant_knowledge set semina_mesi_interno = '{}',      semina_mesi_esterno = '{2,3,9,10}'   where lower(specie_nome) = 'cipolla';
update plant_knowledge set semina_mesi_interno = '{}',      semina_mesi_esterno = '{10,11}'      where lower(specie_nome) = 'aglio';
update plant_knowledge set semina_mesi_interno = '{}',      semina_mesi_esterno = '{3,8,9}'      where lower(specie_nome) = 'spinacio';
update plant_knowledge set semina_mesi_interno = '{}',      semina_mesi_esterno = '{4,5,6}'      where lower(specie_nome) = 'fagiolo';
update plant_knowledge set semina_mesi_interno = '{}',      semina_mesi_esterno = '{2,3,10,11}'  where lower(specie_nome) = 'pisello';
update plant_knowledge set semina_mesi_interno = '{}',      semina_mesi_esterno = '{3,4,9}'      where lower(specie_nome) = 'fragola';
update plant_knowledge set semina_mesi_interno = '{2}',     semina_mesi_esterno = '{3,4,5}'      where lower(specie_nome) = 'prezzemolo';
update plant_knowledge set semina_mesi_interno = '{}',      semina_mesi_esterno = '{3,4,5,8,9}'  where lower(specie_nome) = 'rucola';
update plant_knowledge set semina_mesi_interno = '{3}',     semina_mesi_esterno = '{4,5}'        where lower(specie_nome) = 'cetriolo';
update plant_knowledge set semina_mesi_interno = '{}',      semina_mesi_esterno = '{4,5}'        where lower(specie_nome) = 'girasole';
update plant_knowledge set semina_mesi_interno = '{2,3}',   semina_mesi_esterno = '{4,5}'        where lower(specie_nome) = 'menta';
update plant_knowledge set semina_mesi_interno = '{2,3}',   semina_mesi_esterno = '{4,5}'        where lower(specie_nome) = 'salvia';
update plant_knowledge set semina_mesi_interno = '{2,3}',   semina_mesi_esterno = '{4,5,6}'      where lower(specie_nome) = 'rosmarino';
