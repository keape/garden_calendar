-- ============================================================
-- Garden Calendar iOS — Database Schema
-- Supabase PostgreSQL Migration
-- ============================================================

-- 1. TABELLA: Orti (Giardini / Orti di un utente)
create table orti (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    nome text not null,
    luogo text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- Ogni utente vede solo i suoi orti
alter table orti enable row level security;

create policy "Users can view their own gardens"
    on orti for select
    using (auth.uid() = user_id);

create policy "Users can create their own gardens"
    on orti for insert
    with check (auth.uid() = user_id);

create policy "Users can update their own gardens"
    on orti for update
    using (auth.uid() = user_id);

create policy "Users can delete their own gardens"
    on orti for delete
    using (auth.uid() = user_id);

create index idx_orti_user_id on orti(user_id);


-- 2. TABELLA: Plant Knowledge (Catalogo admin — globale, leggibile da tutti)
create table plant_knowledge (
    id uuid primary key default gen_random_uuid(),
    slug text not null unique,
    specie_nome text not null,
    growth_days integer not null default 90,
    -- JSONB: [{ "nome": "Irrigazione", "offset_days": 0, "recurrence_days": 3, "color": "blue" }, ...]
    attivita_suggerite jsonb not null default '[]'::jsonb,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- Admin users (is_admin=true in user_metadata) can write; all authenticated can read
alter table plant_knowledge enable row level security;

create policy "Anyone can read plant knowledge"
    on plant_knowledge for select
    using (true);

create policy "Admin can insert plant knowledge"
    on plant_knowledge for insert
    with check (auth.jwt() -> 'user_metadata' ->> 'is_admin' = 'true');

create policy "Admin can update plant knowledge"
    on plant_knowledge for update
    using (auth.jwt() -> 'user_metadata' ->> 'is_admin' = 'true');

create policy "Admin can delete plant knowledge"
    on plant_knowledge for delete
    using (auth.jwt() -> 'user_metadata' ->> 'is_admin' = 'true');

create index idx_plant_knowledge_slug on plant_knowledge(slug);
create index idx_plant_knowledge_search on plant_knowledge using gin(to_tsvector('italian', specie_nome));


-- 3. TABELLA: Wiki Notes (dove l'admin scrive il markdown, triggera LLM extraction)
create table wiki_notes (
    id uuid primary key default gen_random_uuid(),
    slug text not null unique,
    title text not null,
    markdown_content text not null default '',
    processed boolean not null default false,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table wiki_notes enable row level security;

create policy "Admin can manage wiki notes"
    on wiki_notes for all
    using (auth.jwt() -> 'user_metadata' ->> 'is_admin' = 'true');

create index idx_wiki_notes_slug on wiki_notes(slug);


-- 4. TABELLA: Piante Coltivate (le piante che un utente ha nel suo orto)
create table piante_coltivate (
    id uuid primary key default gen_random_uuid(),
    orto_id uuid not null references orti(id) on delete cascade,
    specie_id uuid references plant_knowledge(id) on delete set null,
    nome_personalizzato text not null,
    data_semina date not null default current_date,
    growth_days integer not null default 90,
    note text,
    foto_url text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table piante_coltivate enable row level security;

create policy "Users can view their own plants"
    on piante_coltivate for select
    using (
        exists (
            select 1 from orti
            where orti.id = piante_coltivate.orto_id
            and orti.user_id = auth.uid()
        )
    );

create policy "Users can create plants in their gardens"
    on piante_coltivate for insert
    with check (
        exists (
            select 1 from orti
            where orti.id = piante_coltivate.orto_id
            and orti.user_id = auth.uid()
        )
    );

create policy "Users can update their own plants"
    on piante_coltivate for update
    using (
        exists (
            select 1 from orti
            where orti.id = piante_coltivate.orto_id
            and orti.user_id = auth.uid()
        )
    );

create policy "Users can delete their own plants"
    on piante_coltivate for delete
    using (
        exists (
            select 1 from orti
            where orti.id = piante_coltivate.orto_id
            and orti.user_id = auth.uid()
        )
    );

create index idx_piante_coltivate_orto_id on piante_coltivate(orto_id);


-- 5. TABELLA: Attività (eventi nel calendario: journal + AI suggerite)
create table attivita (
    id uuid primary key default gen_random_uuid(),
    pianta_id uuid not null references piante_coltivate(id) on delete cascade,
    nome text not null,
    data date not null,
    done boolean not null default false,
    rain_adjusted boolean not null default false,
    rain_rescheduled boolean not null default false,
    user_event boolean not null default false,
    source_action text,
    note text,
    color text not null default 'green',
    recurrence_days integer,
    created_at timestamptz not null default now()
);

alter table attivita enable row level security;

create policy "Users can view activities for their plants"
    on attivita for select
    using (
        exists (
            select 1 from piante_coltivate
            join orti on orti.id = piante_coltivate.orto_id
            where piante_coltivate.id = attivita.pianta_id
            and orti.user_id = auth.uid()
        )
    );

create policy "Users can create activities for their plants"
    on attivita for insert
    with check (
        exists (
            select 1 from piante_coltivate
            join orti on orti.id = piante_coltivate.orto_id
            where piante_coltivate.id = attivita.pianta_id
            and orti.user_id = auth.uid()
        )
    );

create policy "Users can update activities for their plants"
    on attivita for update
    using (
        exists (
            select 1 from piante_coltivate
            join orti on orti.id = piante_coltivate.orto_id
            where piante_coltivate.id = attivita.pianta_id
            and orti.user_id = auth.uid()
        )
    );

create policy "Users can delete activities for their plants"
    on attivita for delete
    using (
        exists (
            select 1 from piante_coltivate
            join orti on orti.id = piante_coltivate.orto_id
            where piante_coltivate.id = attivita.pianta_id
            and orti.user_id = auth.uid()
        )
    );

create index idx_attivita_pianta_id on attivita(pianta_id);
create index idx_attivita_data on attivita(data);
create index idx_attivita_done on attivita(done);


-- 6. TABELLA: Impostazioni utente (luogo, soglia pioggia, tema)
create table impostazioni_utente (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade unique,
    luogo text,
    latitudine double precision,
    longitudine double precision,
    soglia_pioggia_mm double precision not null default 2.0,
    tema text not null default 'automatico',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table impostazioni_utente enable row level security;

create policy "Users can view their own settings"
    on impostazioni_utente for select
    using (auth.uid() = user_id);

create policy "Users can upsert their own settings"
    on impostazioni_utente for insert
    with check (auth.uid() = user_id);

create policy "Users can update their own settings"
    on impostazioni_utente for update
    using (auth.uid() = user_id);

create index idx_impostazioni_utente_user_id on impostazioni_utente(user_id);


-- 7. FUNCTION: Aggiornamento automatico updated_at
create or replace function update_updated_at_column()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

create trigger update_orti_updated_at
    before update on orti
    for each row execute function update_updated_at_column();

create trigger update_plant_knowledge_updated_at
    before update on plant_knowledge
    for each row execute function update_updated_at_column();

create trigger update_wiki_notes_updated_at
    before update on wiki_notes
    for each row execute function update_updated_at_column();

create trigger update_piante_coltivate_updated_at
    before update on piante_coltivate
    for each row execute function update_updated_at_column();

create trigger update_impostazioni_utente_updated_at
    before update on impostazioni_utente
    for each row execute function update_updated_at_column();


-- 8. SEED: Piante di base nel catalogo (admin knowledge)
-- Queste sono le piante base. L'admin potrà aggiungerne altre via dashboard.
insert into plant_knowledge (slug, specie_nome, growth_days, attivita_suggerite) values
('pomodoro-san-marzano', 'Pomodoro San Marzano', 80,
  '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 3, "color": "blue"}, {"nome": "Concimazione", "offset_days": 15, "recurrence_days": 20, "color": "green"}, {"nome": "Sarchiatura", "offset_days": 20, "recurrence_days": 30, "color": "gray"}, {"nome": "Trattamento antiparassitario", "offset_days": 30, "recurrence_days": null, "color": "red"}, {"nome": "Raccolta", "offset_days": 80, "recurrence_days": null, "color": "orange"}]'::jsonb),
('basilico-genovese', 'Basilico Genovese', 60,
  '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 2, "color": "blue"}, {"nome": "Cimatura", "offset_days": 20, "recurrence_days": 15, "color": "gray"}, {"nome": "Raccolta", "offset_days": 45, "recurrence_days": null, "color": "orange"}]'::jsonb),
('zucchine-romanesco', 'Zucchine Romanesco', 70,
  '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 3, "color": "blue"}, {"nome": "Concimazione", "offset_days": 20, "recurrence_days": 20, "color": "green"}, {"nome": "Raccolta", "offset_days": 50, "recurrence_days": 3, "color": "orange"}]'::jsonb),
('lattuga-canasta', 'Lattuga Canasta', 60,
  '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 2, "color": "blue"}, {"nome": "Raccolta", "offset_days": 50, "recurrence_days": null, "color": "orange"}]'::jsonb),
('ravanelli', 'Ravanelli', 30,
  '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 2, "color": "blue"}, {"nome": "Raccolta", "offset_days": 25, "recurrence_days": null, "color": "orange"}]'::jsonb),
('fagiolini-rampicanti', 'Fagiolini Rampicanti', 70,
  '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 3, "color": "blue"}, {"nome": "Rincalzatura", "offset_days": 20, "recurrence_days": null, "color": "gray"}, {"nome": "Raccolta", "offset_days": 55, "recurrence_days": 3, "color": "orange"}]'::jsonb),
('peperoni-corno', 'Peperoni Corno', 90,
  '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 3, "color": "blue"}, {"nome": "Concimazione", "offset_days": 20, "recurrence_days": 25, "color": "green"}, {"nome": "Raccolta", "offset_days": 80, "recurrence_days": null, "color": "orange"}]'::jsonb),
('melanzane-violetta', 'Melanzane Violetta', 85,
  '[{"nome": "Irrigazione", "offset_days": 0, "recurrence_days": 3, "color": "blue"}, {"nome": "Concimazione", "offset_days": 20, "recurrence_days": 25, "color": "green"}, {"nome": "Raccolta", "offset_days": 75, "recurrence_days": null, "color": "orange"}]'::jsonb);
