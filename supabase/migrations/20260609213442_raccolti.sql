-- TABELLA: Raccolti (storico raccolti per pianta: quantità, unità, note)
create table raccolti (
    id uuid primary key default gen_random_uuid(),
    pianta_id uuid not null references piante_coltivate(id) on delete cascade,
    data date not null default current_date,
    quantita numeric not null check (quantita > 0),
    unita text not null default 'kg',
    note text,
    created_at timestamptz not null default now()
);

alter table raccolti enable row level security;

create policy "Users can view harvests for their plants"
    on raccolti for select
    using (
        exists (
            select 1 from piante_coltivate
            join orti on orti.id = piante_coltivate.orto_id
            where piante_coltivate.id = raccolti.pianta_id
            and orti.user_id = auth.uid()
        )
    );

create policy "Users can create harvests for their plants"
    on raccolti for insert
    with check (
        exists (
            select 1 from piante_coltivate
            join orti on orti.id = piante_coltivate.orto_id
            where piante_coltivate.id = raccolti.pianta_id
            and orti.user_id = auth.uid()
        )
    );

create policy "Users can update harvests for their plants"
    on raccolti for update
    using (
        exists (
            select 1 from piante_coltivate
            join orti on orti.id = piante_coltivate.orto_id
            where piante_coltivate.id = raccolti.pianta_id
            and orti.user_id = auth.uid()
        )
    );

create policy "Users can delete harvests for their plants"
    on raccolti for delete
    using (
        exists (
            select 1 from piante_coltivate
            join orti on orti.id = piante_coltivate.orto_id
            where piante_coltivate.id = raccolti.pianta_id
            and orti.user_id = auth.uid()
        )
    );

create index idx_raccolti_pianta_id on raccolti(pianta_id);
create index idx_raccolti_data on raccolti(data);
