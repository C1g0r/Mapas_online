-- =====================================================================
-- Mapa de Horários · Carlos Baltazar
-- Estrutura da base de dados no Supabase
-- Como usar: Supabase → SQL Editor → New query → colar tudo → Run
-- (pode correr mais do que uma vez sem estragar nada)
-- =====================================================================

-- 1) Perfis: quem pode entrar e o que pode fazer
--    papel = 'leitor'  → só consulta (colaboradores)
--    papel = 'editor'  → pode alterar (gerência)
create table if not exists public.perfis (
  id         uuid primary key references auth.users(id) on delete cascade,
  nome       text,
  papel      text not null default 'leitor' check (papel in ('leitor','editor')),
  criado_em  timestamptz not null default now()
);

-- 2) Os horários (uma única linha com todos os dados da app)
create table if not exists public.escala (
  id              int primary key default 1 check (id = 1),
  dados           jsonb not null,
  versao          int not null default 1,
  atualizado_em   timestamptz not null default now(),
  atualizado_por  text
);

-- 3) Cópias de segurança automáticas (antes de cada alteração, no máximo 1 por hora)
create table if not exists public.escala_copias (
  id          bigserial primary key,
  dados       jsonb not null,
  versao      int,
  criado_em   timestamptz not null default now(),
  criado_por  text
);

-- ---------- funções auxiliares ----------
create or replace function public.e_editor()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.perfis where id = auth.uid() and papel = 'editor');
$$;

create or replace function public.tem_acesso()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.perfis where id = auth.uid());
$$;

-- Cada utilizador novo criado no Supabase fica automaticamente como 'leitor'
create or replace function public.novo_utilizador()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.perfis (id, nome)
  values (new.id, coalesce(new.raw_user_meta_data->>'nome', split_part(new.email, '@', 1)))
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists ao_criar_utilizador on auth.users;
create trigger ao_criar_utilizador
  after insert on auth.users
  for each row execute function public.novo_utilizador();

-- Guardar cópia antes de alterar + atualizar a data
create or replace function public.antes_de_alterar_escala()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from public.escala_copias where criado_em > now() - interval '1 hour') then
    insert into public.escala_copias (dados, versao, criado_por) values (old.dados, old.versao, old.atualizado_por);
  end if;
  delete from public.escala_copias where criado_em < now() - interval '180 days';
  new.atualizado_em := now();
  return new;
end $$;

drop trigger if exists copia_antes_de_alterar on public.escala;
create trigger copia_antes_de_alterar
  before update on public.escala
  for each row execute function public.antes_de_alterar_escala();

-- ---------- segurança (Row Level Security) ----------
alter table public.perfis        enable row level security;
alter table public.escala        enable row level security;
alter table public.escala_copias enable row level security;

drop policy if exists "ver o proprio perfil"        on public.perfis;
drop policy if exists "gerencia ve todos os perfis" on public.perfis;
create policy "ver o proprio perfil"        on public.perfis for select using (id = auth.uid());
create policy "gerencia ve todos os perfis" on public.perfis for select using (public.e_editor());

drop policy if exists "quem tem acesso ve os horarios" on public.escala;
drop policy if exists "gerencia cria"                 on public.escala;
drop policy if exists "gerencia altera"               on public.escala;
create policy "quem tem acesso ve os horarios" on public.escala for select using (public.tem_acesso());
create policy "gerencia cria"                 on public.escala for insert with check (public.e_editor());
create policy "gerencia altera"               on public.escala for update using (public.e_editor()) with check (public.e_editor());

drop policy if exists "gerencia ve copias" on public.escala_copias;
create policy "gerencia ve copias" on public.escala_copias for select using (public.e_editor());

-- ---------- atualização em tempo real ----------
do $$ begin
  alter publication supabase_realtime add table public.escala;
exception when duplicate_object then null; end $$;

-- =====================================================================
-- DEPOIS de criar os utilizadores (Authentication → Users → Add user):
-- tornar alguém "gerência" (pode alterar). Troque o email:
--
--   update public.perfis set papel = 'editor'
--   where id = (select id from auth.users where email = 'email@exemplo.pt');
--
-- Mudar o nome que aparece na app:
--
--   update public.perfis set nome = 'Andreia Catalão'
--   where id = (select id from auth.users where email = 'email@exemplo.pt');
--
-- Ver quem tem acesso:
--
--   select u.email, p.nome, p.papel from public.perfis p join auth.users u on u.id = p.id order by p.papel, u.email;
-- =====================================================================
