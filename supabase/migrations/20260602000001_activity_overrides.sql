alter table piante_coltivate
  add column if not exists activity_overrides jsonb;
