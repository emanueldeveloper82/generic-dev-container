#!/usr/bin/env bash
# Remove containers/volumes do Dev Container deste projeto (útil após mudar senha do Postgres ou portas).
set -euo pipefail

PROJECT_NAME="${1:-generic-dev-container_devcontainer}"
COMPOSE_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.devcontainer" && pwd)/docker-compose.yml"
ENV_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.env"

echo "Parando projeto Docker: ${PROJECT_NAME}"
docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" -p "${PROJECT_NAME}" down -v --remove-orphans

echo "Concluído. No Cursor: Dev Containers → Rebuild and Reopen in Container"
