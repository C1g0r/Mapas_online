# Mapa de Horários · Carlos Baltazar — versão online

Esta pasta já tem tudo pronto para publicar a app na internet em **modo privado**. O processo é o mesmo do website: **GitHub + Netlify + Supabase**.

- **Só entra quem tem conta** (email e palavra-passe). A página também não aparece no Google.
- **Gerência** (perfil `editor`): altera horários, marca férias, gera anos, etc.
- **Colaboradores** (perfil `leitor`): só consultam. Podem ver, imprimir e usar "O meu horário".
- **Dados partilhados:** todos veem os mesmos horários. Quando a gerência altera algo, quem tiver a app aberta recebe a atualização em poucos segundos.
- **Cópias de segurança automáticas** no servidor: uma por hora no máximo, guardadas durante 6 meses.

## O que está na pasta

| Ficheiro | Para que serve |
|---|---|
| `index.html` | A app |
| `config.js` | **Tem de ser preenchido** com os dados do seu projeto Supabase (passo 2) |
| `supabase/schema.sql` | Cria as tabelas e as regras de segurança no Supabase (passo 1) |
| `netlify.toml`, `robots.txt` | Configuração do Netlify e bloqueio do Google |
| `manifest.webmanifest`, `icons/` | Ícone para "Adicionar ao ecrã principal" no telemóvel |

---

## Passo 1 — Supabase (base de dados e contas)

1. Entre em supabase.com e crie um **novo projeto**. Sugestão de nome: `horarios-carlos-baltazar`. Região: **West EU (Ireland)** ou **Central EU (Frankfurt)**.
2. Abra **SQL Editor → New query**, cole todo o conteúdo de `supabase/schema.sql` e clique em **Run**.
3. Vá a **Authentication → Sign In / Providers**:
   - O **Email** deve estar ativo.
   - **Desligue "Allow new users to sign up"**. Assim só a gerência cria contas.
4. Vá a **Authentication → Users → Add user → Create new user**:
   - Coloque o email e uma palavra-passe.
   - Marque **Auto Confirm User**.
   - Crie primeiro a sua conta, depois as dos colaboradores. Se preferir, pode usar uma conta de consulta partilhada, por exemplo `consulta@...`.
5. Torne a sua conta **gerência**. No **SQL Editor**, corra esta instrução, trocando o email pelo seu:
   ```sql
   update public.perfis set papel = 'editor'
   where id = (select id from auth.users where email = 'o.seu@email.pt');
   ```
   Todas as outras contas ficam automaticamente como **consulta**.

## Passo 2 — Ligar a app ao Supabase

1. No Supabase, vá a **Project Settings → API** (ou **Data API**) e copie:
   - o **Project URL** (ex.: `https://abcdefgh.supabase.co`);
   - a chave **anon public**.
2. Abra `config.js` num editor de texto e substitua os dois valores.

> A chave **anon** pode ficar visível no site. Quem protege os dados são as regras do passo 1: sem conta não se vê nada, e só a gerência altera.
> **Nunca** use a chave `service_role` neste ficheiro.

## Passo 3 — GitHub

1. Crie um repositório **privado**, por exemplo `mapa-horarios`.
2. Carregue todos os ficheiros desta pasta (Add file → Upload files). O `config.js` já tem de estar preenchido.

## Passo 4 — Netlify

1. **Add new site → Import an existing project → GitHub** e escolha o repositório.
2. Deixe o **Build command** vazio. Em **Publish directory**, escreva `.` (um ponto).
3. Clique em **Deploy**. Pode mudar o nome em **Site configuration → Change site name** (ex.: `horarios-cb.netlify.app`).
4. Volte ao Supabase, a **Authentication → URL Configuration**:
   - Em **Site URL**, coloque o endereço do Netlify.
   - Adicione o mesmo endereço em **Redirect URLs**.
   - Isto é necessário para o "Esqueci-me da palavra-passe" funcionar.

## Passo 5 — Passar os seus horários para a versão online

1. Na **versão local** (o ficheiro que já usa), vá a **Ferramentas → Cópias de segurança → Descarregar cópia (.json)**.
2. Abra o site do Netlify e entre com a conta de gerência.
3. Aparece um aviso a dizer que a base de dados está vazia. Clique em **Importar cópia** e escolha o ficheiro `.json`.
   - Também pode clicar em **Começar com os dados de base**, que são os horários base de 2027.

A partir daqui, use **sempre a versão online**. A versão local continua a funcionar, mas não sincroniza com a online.

## Telemóvel dos colaboradores

Abra o endereço no telemóvel e entre com a conta. Depois:

- **iPhone (Safari):** Partilhar → Adicionar ao ecrã principal.
- **Android (Chrome):** menu ⋮ → Adicionar ao ecrã principal.

Fica com o ícone da Carlos Baltazar como se fosse uma app.

## Atualizar a app no futuro

Substitua o `index.html` no GitHub pela versão nova. O Netlify publica sozinho em 1 a 2 minutos. Os dados ficam no Supabase e não se perdem.

## Gestão do dia a dia

| Quero… | Onde |
|---|---|
| Dar acesso a alguém | Supabase → Authentication → Users → Add user |
| Tirar o acesso | Supabase → Authentication → Users → apagar o utilizador |
| Dar permissão de alterar | SQL: `update public.perfis set papel='editor' where id=(select id from auth.users where email='...');` |
| Voltar a só consulta | o mesmo, com `papel='leitor'` |
| Recuperar uma versão antiga | Na app: Ferramentas → Cópias de segurança → Restaurar |
| Ver quem alterou o quê | Na app: Ferramentas → Histórico de alterações |

## Notas

- **Duas pessoas a editar ao mesmo tempo:** se duas pessoas da gerência alterarem quase em simultâneo, a segunda recebe um aviso e a app carrega a versão mais recente. Assim nada é apagado sem querer, mas a segunda pessoa tem de repetir a última alteração.
- **Plano gratuito:** chega para este uso (poucas pessoas e poucos dados).
  - O Supabase pausa projetos gratuitos sem utilização durante 7 dias. Basta alguém abrir a app uma vez por semana.
  - Se for pausado, reativa-se no painel do Supabase sem perder dados.

Autor e desenvolvimento: Andreia Catalão · Versão 05112026
