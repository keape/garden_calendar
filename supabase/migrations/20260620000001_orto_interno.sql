-- Flag giardino interno/esterno.
-- Gli orti esistenti diventano esterni (default false).
-- I giardini interni disattivano la riprogrammazione irrigazione in base alla pioggia (lato app).
alter table orti
  add column if not exists interno boolean not null default false;
