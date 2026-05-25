# Spec-Driven Development (SDD) com Spec Kit

Guia para instalar e usar o **[Spec Kit](https://github.com/github/spec-kit)** (GitHub) neste Dev Container. O CLI se chama **`specify`** (pacote `specify-cli`).

> **Atenção:** instale **somente** a partir do repositório GitHub. Pacotes homônimos no PyPI **não** são oficiais.

## O que é

O Spec Kit organiza o desenvolvimento em fases com comandos no **Cursor**:

| Fase | Comando no Cursor | Objetivo |
|------|-------------------|----------|
| Constituição | `/speckit.constitution` | Princípios do projeto |
| Especificação | `/speckit.specify` | O **quê** e **por quê** (sem stack) |
| Esclarecimento | `/speckit.clarify` | (Opcional) tirar dúvidas |
| Plano | `/speckit.plan` | Stack e arquitetura |
| Tarefas | `/speckit.tasks` | Lista acionável |
| Análise | `/speckit.analyze` | (Opcional) consistência entre artefatos |
| Implementação | `/speckit.implement` | Código guiado pelo plano |

Após o `specify init`, o projeto ganha pastas como `.specify/` e `.cursor/skills/` **no repositório da aplicação**, não na raiz deste template de ambiente.

## Pré-requisitos

| Item | Neste container |
|------|-----------------|
| Python 3.11+ | **3.12** (feature do devcontainer) |
| Git | Já instalado |
| **[uv](https://docs.astral.sh/uv/)** | Instalar no passo 2 abaixo |
| Cursor | Integração `cursor-agent` |
| Node.js | Só se **sua** app precisar — o Spec Kit não exige |

Última release estável de referência: **[v0.8.13](https://github.com/github/spec-kit/releases)** (confira Releases antes de fixar a tag).

## Passo a passo

### 1. Abrir o Dev Container

1. Abra este repositório no Cursor.
2. `F1` → **Dev Containers: Reopen in Container**.
3. Confirme no terminal integrado:

```bash
whoami    # vscode
pwd       # /workspaces
python3 --version
git --version
```

Os comandos seguintes rodam **dentro do container**, não no PowerShell do Windows.

### 2. Instalar o `uv`

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source "$HOME/.local/bin/env" 2>/dev/null || export PATH="$HOME/.local/bin:$PATH"
uv --version
```

### 3. Instalar o CLI `specify`

**Instalação persistente (recomendada):**

```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@v0.8.13
export PATH="$HOME/.local/bin:$PATH"
specify version
specify integration list
```

**Teste rápido sem instalar globalmente:**

```bash
uvx --from git+https://github.com/github/spec-kit.git@v0.8.13 specify version
```

**Alternativa com pipx:**

```bash
pipx install "git+https://github.com/github/spec-kit.git@v0.8.13"
specify version
```

### 4. Escolher onde inicializar o SDD

Use a pasta [`projetos/`](../projetos/) para cada aplicação com seu próprio `.git`:

```bash
cd /workspaces/projetos
git clone https://github.com/sua-org/seu-projeto.git
cd seu-projeto
```

Inicialize o Spec Kit **na pasta do app**, não em `/workspaces` (raiz do template de ambiente).

### 5. Inicializar com integração Cursor

```bash
cd /workspaces/projetos/seu-projeto

specify init . \
  --integration cursor-agent \
  --script sh \
  --ignore-agent-tools
```

| Flag | Motivo |
|------|--------|
| `cursor-agent` | Comandos `/speckit.*` no Cursor |
| `--script sh` | Scripts bash no Linux do container |
| `--ignore-agent-tools` | Não exige Cursor CLI no container |

**Outras variantes:**

```bash
# Novo projeto vazio
specify init meu-novo-app --integration cursor-agent --script sh

# Diretório atual
specify init --here --integration cursor-agent --script sh

# Pasta já com arquivos (pode sobrescrever artefatos gerenciados)
specify init . --force --integration cursor-agent --script sh
```

### 6. Verificar no Cursor

1. Abra o projeto em `projetos/seu-projeto` no chat do **Agent**.
2. Digite `/speckit` e confira se os comandos aparecem.
3. No terminal do container:

```bash
ls -la .specify .cursor/skills
```

### 7. Primeiro fluxo SDD (exemplo)

No chat do Cursor, na pasta do app, execute os comandos **na ordem abaixo**. À direita de cada linha: o que a fase faz; no prompt, use o texto de exemplo (ou adapte).

```text
/speckit.constitution Foco em qualidade de código, testes, UX consistente e performance.
  → Constituição — princípios e padrões do projeto (qualidade, testes, UX, performance).

/speckit.specify Construir um CRUD de tarefas com filtros por status e data de vencimento.
  → Especificação — o quê e o por quê, sem escolher stack.

/speckit.plan API em FastAPI, Postgres no serviço db do compose, testes com pytest.
  → Plano — stack, arquitetura e como a app usa a infra do compose.

/speckit.tasks
  → Tarefas — quebra o plano em itens acionáveis (checklist de implementação).

/speckit.analyze
  → Análise — revisa consistência entre constituição, spec, plano e tarefas; corrija divergências antes de codar.
  ⚠ Execute esta fase **antes** de `/speckit.implement`. Implementar com artefatos inconsistentes costuma gerar retrabalho.

/speckit.implement
  → Implementação — gera/ajusta o código seguindo o plano e as tarefas validadas na análise.
```

### 8. Onde rodar cada coisa

| Ação | Onde |
|------|------|
| `specify init`, upgrades | Terminal **no container** |
| `/speckit.*` | **Cursor Agent** |
| `npm`, `pip`, build da app | Terminal **no container**, na pasta do app |
| Postgres, Redis, RabbitMQ | Hosts `db`, `redis`, `rabbitmq` **dentro** do compose |

No `/speckit.plan` você pode referenciar a infra deste template (Postgres em `db:5432`, Redis, RabbitMQ, WireMock, Redpanda). Variáveis e portas: [`.env`](../.env) na raiz.

- **Dentro do container:** hosts `db`, `redis`, `rabbitmq`, etc.
- **No Windows (ferramentas locais):** `localhost` + portas publicadas (ex.: Postgres em `5433` — ver `POSTGRES_PUBLISHED_PORT`).

## Comandos úteis depois do setup

```bash
specify integration switch cursor-agent --script sh
specify integration upgrade cursor-agent
uv tool upgrade specify-cli
```

## Automatizar no próximo rebuild (opcional)

O `scripts/post-create.sh` ainda **não** instala o Spec Kit por padrão. Para automatizar, adicione uma função `install_spec_kit` e chame-a no `main`:

```bash
install_spec_kit() {
  if ! command -v uv >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="${HOME}/.local/bin:${PATH}"
  fi
  if ! command -v specify >/dev/null 2>&1; then
    uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@v0.8.13
    export PATH="${HOME}/.local/bin:${PATH}"
  fi
  command -v specify >/dev/null && echo "  Specify: $(specify version)"
}
```

Depois: **Dev Containers: Rebuild Container**.

## O que evitar

1. **Não** instalar `specify-cli` do PyPI.org (não é oficial).
2. **Não** rodar `specify init` na raiz `/workspaces` se o SDD é só para um app — use `projetos/<app>`.
3. **Não** commitar o [`.env`](../.env) com segredos.
4. Documentação do produto em [`docs/`](../docs/) é separada de `.specify/` do app — o SDD vive no **repositório da aplicação**.

## Relação com outras pastas

| Pasta | Uso |
|-------|-----|
| [`sdd/`](.) | Este guia (SDD / Spec Kit no ambiente) |
| [`projetos/`](../projetos/) | Código das aplicações (`git clone`) |
| [`docs/`](../docs/) | Documentação do produto (ADRs, arquitetura, etc.) |
| Raiz `/workspaces` | Template do Dev Container |

## Links oficiais

- Repositório: https://github.com/github/spec-kit
- Instalação: https://github.github.io/spec-kit/installation.html
- Quick Start: https://github.github.io/spec-kit/quickstart.html
- Integrações (Cursor): https://github.github.io/spec-kit/reference/integrations.html
- Guia SDD: https://github.com/github/spec-kit/blob/main/spec-driven.md
- Instalar uv: https://github.github.io/spec-kit/install/uv.html

## Resumo

**Reopen in Container** → instale `uv` + `specify` → `cd /workspaces/projetos/<seu-app>` → `specify init . --integration cursor-agent --script sh --ignore-agent-tools` → use `/speckit.*` no Cursor.
