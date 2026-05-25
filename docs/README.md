# Documentação do projeto

Esta pasta (`docs/`) é o **local oficial da documentação** do projeto que você está desenvolvendo dentro deste Dev Container.

## O que colocar aqui

- Requisitos funcionais e não funcionais
- Diagramas de arquitetura e fluxos
- Decisões técnicas (ADRs)
- Guias de setup, deploy e operação
- Contratos de API (OpenAPI, exemplos de payload)
- Runbooks e troubleshooting específicos do produto

## Organização sugerida

```
docs/
├── README.md           ← este arquivo
├── arquitetura/
├── api/
├── adr/                ← Architecture Decision Records
└── guias/
```

## Convenções

- Prefira **Markdown** (`.md`) para facilitar revisão no Git.
- Mantenha nomes de arquivos em **kebab-case** (ex.: `fluxo-autenticacao.md`).
- Documentação de infraestrutura compartilhada (Dev Container, Docker Compose) permanece no [README da raiz](../README.md) e em `.devcontainer/`.

## Relação com outras pastas

| Pasta | Uso |
|-------|-----|
| [`docs/`](../docs/) | Documentação do **produto** / módulo em desenvolvimento |
| [`projetos/`](../projetos/) | Código-fonte clonado (`git clone`) das aplicações |
| Raiz do repositório | Template do ambiente de desenvolvimento genérico |
