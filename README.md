# Generic Dev Container

Ambiente de desenvolvimento **isolado**, **reproduzível** e **genérico** para suas aplicações, usando [Dev Containers](https://containers.dev/) no Cursor ou VS Code.

---

## O que é um Dev Container?

```
┌─────────────────────────────────────────────────────────────┐
│  Seu Windows                                                │
│  ┌──────────────┐     ┌──────────────────────────────────┐  │
│  │ Cursor /     │────▶│ Docker Desktop                   │  │
│  │ VS Code      │     │  ┌────────────────────────────┐  │  │
│  └──────────────┘     │  │ Container "devcontainer"   │  │  │
│                       │  │  • Python 3.12, Node 20    │  │  │
│                       │  │  • Seu código (montado)    │  │  │
│                       │  └────────────────────────────┘  │  │
│                       │  ┌─────────┐ ┌─────────┐ ...     │  │
│                       │  │Postgres │ │ WireMock│         │  │
│                       │  └─────────┘ └─────────┘         │  │
│                       └──────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

| Conceito | Explicação |
|----------|------------|
| **Docker** | Empacota um sistema Linux com ferramentas fixas (Node, Python, Git, etc.). |
| **Dev Container** | O editor abre *dentro* desse Linux; seu código no Windows continua na pasta do projeto, montada no container. |
| **Por que usar?** | Mesma versão de runtime para todo o time; sem “funciona na minha máquina”; setup em um clique. |

---
**Vantagens:**

- Não precisa instalar Python, Node, Postgres, Kafka etc. no Windows.
- Todo o time usa as **mesmas versões** de ferramentas.
- O projeto sobe com um comando: **Reopen in Container**.
---

## Pré-requisitos

1. **Docker Desktop** (Windows/macOS) ou Docker Engine + Compose (Linux) — [Instalar Docker](https://docs.docker.com/get-docker/).
2. **Cursor** ou **VS Code** com a extensão **Dev Containers** (`ms-vscode-remote.remote-containers`).
3. Este repositório clonado localmente.

> **Windows:** para melhor desempenho, clone o projeto dentro do filesystem do **WSL2** (ex.: `\\wsl$\Ubuntu\home\...`), não em `C:\` com disco lento ou permissões estranhas.

---

## Guia passo a passo

### Passo 1 — Entender a estrutura

Tudo que define o ambiente fica em `.devcontainer/`:

```
generic-dev-container/
├── .devcontainer/
│   ├── devcontainer.json
│   ├── Dockerfile
│   ├── docker-compose.yml   ← app + Postgres, Redis, RabbitMQ, WireMock, Redpanda
│   └── wiremock/mappings/   ← stubs HTTP (opcional)
├── docs/                    ← documentação do produto em desenvolvimento
├── projetos/                ← git clone das aplicações em que você trabalha
├── .env                     ← suas credenciais locais (não commitar)
├── .env.example             ← template versionado
├── .pre-commit-config.yaml  ← hooks de validação antes do commit
├── scripts/
│   └── post-create.sh       ← pré-requisitos do projeto (roda ao criar o container)
├── .cursor/agents/
│   └── dev-container-guide.md
└── README.md
```

| Pasta | Descrição |
|-------|-----------|
| [`docs/`](docs/README.md) | Documentação do projeto a ser desenvolvido |
| [`projetos/`](projetos/README.md) | Repositórios clonados (`git clone`) para codificar |

### Passo 2 — Revisar o `devcontainer.json`

Abra [`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json). Os pontos principais:

- **`dockerComposeFile`** — sobe o container `app` e os serviços de infraestrutura.
- **`dockerComposeEnvFile`** — usa o `.env` da raiz para substituir variáveis no Compose.
- **`features`** — Node (LTS), Python 3.12, **Go** (`latest` estável), **Java 21**, Git e GitHub CLI.
- **`forwardPorts`** — app + Postgres, Redis, RabbitMQ, WireMock, Redpanda.
- **`postCreateCommand`** — valida runtimes após o primeiro build.

Lista de features: [devcontainers/features](https://github.com/devcontainers/features).

#### Go (“LTS”)

Go **não tem releases LTS** como Node ou Java. A equipe do Go publica versões estáveis frequentes; em geral usa-se a **última estável** (`"version": "latest"`) ou uma versão fixa (ex.: `"1.23"`). No template, `latest` é instalado via feature oficial.

#### Java 21 e múltiplas versões

**Sim, é possível ter várias versões de Java no mesmo dev container**, mas com nuances:

| Abordagem | Como funciona |
|-----------|----------------|
| **Feature `java` + `additionalVersions`** | Uma única feature instala o JDK padrão (`version`) e versões extras separadas por vírgula. O `version` principal vira o **default** no `PATH` e no SDKMAN!. |
| **Trocar versão no terminal** | Com SDKMAN!: `sdk use java 17.0.9-ms` ou `sdk default java 21.0.5-ms`. |
| **VS Code / extensão Java** | Configure `java.configuration.runtimes` com um item por versão instalada. |

Exemplo para Java 21 (padrão) **e** Java 17 (legado):

```json
"ghcr.io/devcontainers/features/java:1": {
  "version": "21",
  "additionalVersions": "17",
  "jdkDistro": "ms",
  "installMaven": true,
  "installGradle": true
}
```

**Limitações:** cada JDK aumenta tempo de build e tamanho da imagem. Para projetos que exigem só Java 21, mantenha apenas `"version": "21"` (como no template atual). Não é recomendado declarar a feature `java` duas vezes no JSON — use `additionalVersions`.

### Passo 3 — Ajustar o Dockerfile (opcional)

O arquivo [`.devcontainer/Dockerfile`](.devcontainer/Dockerfile) parte da imagem oficial `mcr.microsoft.com/devcontainers/base:ubuntu` e instala utilitários (`curl`, `jq`). Adicione aqui apenas o que **não** existir como Feature — por exemplo, um cliente de banco específico.

### Passo 4 — Abrir no container

1. Abra esta pasta no **Cursor**.
2. `F1` (ou `Ctrl+Shift+P`) → **Dev Containers: Reopen in Container** (*Reabrir no Container*).
3. Na **primeira vez**, o Docker fará o build (pode levar alguns minutos).
4. Quando terminar, o terminal integrado estará **dentro** do Linux do container.

### Passo 5 — Validar o ambiente

No terminal do Cursor (já dentro do container):

```bash
whoami
node -v
python3 --version
go version
java -version
mvn -version
git --version
gh --version
pre-commit --version
pre-commit run --all-files   # opcional: testar hooks
```

Se os comandos responderem com versões, o ambiente está pronto para desenvolver.

### Passo 5b — Scripts pós-criação e pre-commit

| Arquivo | Função |
|---------|--------|
| [`scripts/post-create.sh`](scripts/post-create.sh) | Roda no **primeiro build** e em **Rebuild Container**; instala `pre-commit`, registra hooks Git e é o lugar para `npm ci`, `pip install`, `go mod download`, etc. |
| [`.pre-commit-config.yaml`](.pre-commit-config.yaml) | Valida YAML/JSON, detecta chaves privadas, roda ShellCheck nos `.sh` e Hadolint no Dockerfile. |

**Personalizar o módulo em que você trabalha:** edite a função `setup_project_prerequisites()` em `scripts/post-create.sh` (exemplos comentados para Node, Python, Go, Maven e Gradle).

**Commits e acesso ao Git:**

1. Configure identidade (se ainda não tiver): `git config --global user.name` e `user.email` (ou descomente o bloco em `setup_git()` no script).
2. **HTTPS:** `gh auth login` ou credential helper.
3. **SSH:** monte `~/.ssh` do host no container (Settings → devcontainer `mounts`) ou use chaves dentro do container.
4. Cada `git commit` dispara o **pre-commit** automaticamente; para pular em emergência: `git commit --no-verify` (evite no dia a dia).

Rodar hooks manualmente:

```bash
pre-commit run --all-files
pre-commit autoupdate   # atualizar versões dos hooks
```

### Passo 6 — Desenvolver sua aplicação

Você pode:

- **Clonar** seus projetos dentro de `/workspaces/...` (pasta montada = sua pasta no Windows/WSL), ou
- **Usar este repo como template**: copie a pasta `.devcontainer/` para outro repositório.

Fluxo típico em um app Node:

```bash
npm init -y
npm install express
# editar código, rodar npm run dev — porta 3000 já está em forwardPorts
```

Fluxo típico em Python:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install fastapi uvicorn
# uvicorn main:app --reload --port 8000
```

### Passo 7 — Configurar `.env`

1. Copie o template: `cp .env.example .env` (ou edite o `.env` já criado).
2. Ajuste usuários, senhas, hosts e portas.

#### Postgres local no Windows + Postgres no Docker

| Variável | Significado |
|----------|-------------|
| `POSTGRES_PORT` | **Sempre `5432`** — porta na rede Docker (app → `db:5432`) |
| `POSTGRES_PUBLISHED_PORT` | Porta no **Windows** (ex.: `5433` se o 5432 já for do Postgres instalado localmente) |
| `POSTGRES_HOST` | Use `db` para apps **dentro** do Dev Container |
| `DATABASE_URL` | Conexão interna: `...@db:5432/...` |
| `DATABASE_URL_HOST` | Conexão do Windows (DBeaver): `...@localhost:5433/...` |

**Não** altere `POSTGRES_PORT` para `5433` — isso quebra a URL dentro do container. Só mude `POSTGRES_PUBLISHED_PORT`.

| Serviço | Host (dentro do container) | Porta interna | Porta no Windows (padrão) |
|---------|---------------------------|---------------|---------------------------|
| PostgreSQL | `db` | 5432 | `POSTGRES_PUBLISHED_PORT` (5433) |
| Redis | `redis` | 6379 | `REDIS_PUBLISHED_PORT` |
| RabbitMQ | `rabbitmq` | 5672 / 15672 | igual |
| WireMock | `wiremock` | 8080 | `WIREMOCK_PORT` |
| Redpanda | `redpanda` | 9092 | `REDPANDA_KAFKA_PORT` |

### Passo 8 — Personalizar para cada projeto

| Necessidade | Onde configurar |
|-------------|-----------------|
| Versão do Node/Python | `features` no `devcontainer.json` |
| `npm install` automático | `scripts/post-create.sh` → `setup_project_prerequisites()` |
| Qualidade no commit | `.pre-commit-config.yaml` |
| Variáveis de ambiente | `.env` + `dockerComposeEnvFile` (não commitar `.env`) |
| Mais extensões | `customizations.vscode.extensions` |
| Usuário root (evitar se possível) | `remoteUser` |

---

## Usar o subagente no Cursor

Foi criado o subagente **`dev-container-guide`** em [`.cursor/agents/dev-container-guide.md`](.cursor/agents/dev-container-guide.md).

Para testar, no chat do Cursor:

```text
Use o subagente dev-container-guide para adicionar Go 1.22 e explicar cada alteração.
```

O roteador do Cursor usa a `description` do frontmatter para saber quando delegar tarefas de Dev Container.

---

## Solução de problemas

| Problema | O que fazer |
|----------|-------------|
| “Docker não está rodando” | Abra o Docker Desktop e aguarde ficar “Running”. |
| Build da imagem falha | Veja o painel de saída do Dev Containers; teste: `docker build -f .devcontainer/Dockerfile .` na raiz do repo. |
| `Failed to install Cursor server` / Compose up falhou | Veja logs: `docker logs generic-dev-container_devcontainer-db-1`. Rode `bash scripts/reset-devcontainer.sh` e **Rebuild Container**. |
| `chdir to cwd "/workspaces/..." failed: no such file or directory` | O volume estava em `/workspaces` mas o `workspaceFolder` apontava para um subdiretório inexistente. Template usa ambos em `/workspaces` — faça **Rebuild Container**. |
| `POSTGRES_PASSWORD is not specified` | Corrigido: o compose não sobrescreve mais o `.env` com variáveis vazias. Confirme `POSTGRES_PASSWORD` no `.env` e resete volumes. |
| Postgres local na 5432 | Defina `POSTGRES_PUBLISHED_PORT=5433` (ou outra porta livre). Mantenha `POSTGRES_PORT=5432` e `POSTGRES_HOST=db`. |
| `Bind for 0.0.0.0:5433 failed: port is already allocated` | Outro container usa a porta: `docker ps` e pare o conflito, ou mude `POSTGRES_PUBLISHED_PORT` para 5434. |
| Terminal lento no Windows | Mova o projeto para WSL2. |
| Porta já em uso (outros serviços) | Altere a porta publicada no `.env` (Redis, WireMock, etc.) e reabra o container. |
| Serviço não sobe | `docker compose -f .devcontainer/docker-compose.yml --env-file .env ps` na raiz do repo. |
| Git pede “dubious ownership” | O `postStartCommand` já adiciona `safe.directory`; se persistir, rode o comando manualmente no container. |

---

## Próximos passos sugeridos

1. Copiar `.devcontainer/` para um repositório de app real.
2. Ajustar `postCreateCommand` para o gerenciador de pacotes do projeto.
3. Versionar o template e compartilhar com o time via Git.
4. (Avançado) Publicar uma imagem pré-buildada no registry da equipe para builds mais rápidos.

---

## Licença

MIT — veja [LICENSE](LICENSE).
