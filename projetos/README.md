# Projetos de aplicação

Esta pasta (`projetos/`) é onde você **desenvolve suas aplicações**: cada repositório clonado vira um subdiretório aqui, dentro do mesmo Dev Container.

## Fluxo de trabalho

1. Abra o Dev Container (Cursor → **Reopen in Container**).
2. Entre na pasta `projetos/`:

   ```bash
   cd /workspaces/projetos
   ```

3. Clone o repositório do projeto em que vai trabalhar:

   ```bash
   git clone https://github.com/sua-org/seu-projeto.git
   cd seu-projeto
   ```

4. Instale dependências e rode a aplicação conforme o README **do projeto clonado**.
5. Opcional: configure o `scripts/post-create.sh` na raiz do template para automatizar setup ao recriar o container.

## Exemplo de estrutura

```
projetos/
├── README.md              ← este arquivo
├── api-usuarios/          ← git clone do serviço A
├── api-pedidos/           ← git clone do serviço B
└── frontend-web/          ← git clone do frontend
```

## Serviços de infraestrutura

Bancos, filas e mocks (Postgres, Redis, RabbitMQ, WireMock, Redpanda) sobem pelo **docker-compose** do Dev Container. Use as variáveis do [`.env`](../.env) na raiz do template:

- **Dentro do container:** hosts `db`, `redis`, `rabbitmq`, etc.
- **No Windows (ferramentas locais):** `localhost` + portas publicadas (ex.: Postgres Docker em `5433` — ver `POSTGRES_PUBLISHED_PORT`).

## Git

- O repositório **generic-dev-container** versiona apenas o **ambiente** (Dev Container, scripts, docs do template).
- Os repositórios clonados em `projetos/` têm seu **próprio** `.git` — faça `commit` / `push` **dentro de cada pasta de projeto**, não na raiz do template (salvo mudanças no próprio ambiente).

## Documentação do produto

Especificações, ADRs e diagramas do que você está construindo ficam em [`docs/`](../docs/), não misturadas com o código clonado aqui (a menos que o time do projeto prefira docs dentro do próprio repositório clonado).
