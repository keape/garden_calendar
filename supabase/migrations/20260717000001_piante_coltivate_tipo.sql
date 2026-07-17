-- Categoria della pianta coltivata: distingue piante da orto (con ciclo di
-- crescita verso un raccolto) da piante ornamentali/appartamento (perenni,
-- senza raccolto, con cure ricorrenti). Default 'raccolto' per retro-compatibilità
-- con le piante esistenti.
alter table public.piante_coltivate
  add column if not exists tipo text not null default 'raccolto'
  check (tipo in ('raccolto', 'ornamentale'));
