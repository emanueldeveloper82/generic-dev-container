#!/usr/bin/env bash
# =============================================================================
# Executado automaticamente após criar o Dev Container (postCreateCommand).
# Edite a seção "Pré-requisitos do seu projeto" para instalar dependências
# do módulo em que você está trabalhando.
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

log() { echo "[post-create] $*"; }

log "Iniciando setup em: $ROOT"

# --- Ferramentas globais do ambiente (pre-commit, hooks Git) ---
install_pre_commit() {
  if ! command -v pre-commit >/dev/null 2>&1; then
    log "Instalando pre-commit..."
    python3 -m pip install --user --upgrade pip
    python3 -m pip install --user pre-commit
    export PATH="${HOME}/.local/bin:${PATH}"
  fi

  if [[ -f "${ROOT}/.pre-commit-config.yaml" ]]; then
    log "Registrando hooks do pre-commit..."
    pre-commit install --install-hooks
    pre-commit install --hook-type commit-msg 2>/dev/null || true
  else
    log "Aviso: .pre-commit-config.yaml não encontrado; hooks não instalados."
  fi
}

# --- Pré-requisitos do seu projeto (edite conforme o módulo) ---
setup_project_prerequisites() {
  log "Pré-requisitos do projeto (personalize esta função)..."

  # Node.js
  # if [[ -f package.json ]]; then
  #   log "npm ci"
  #   npm ci
  # fi

  # Python
  # if [[ -f requirements.txt ]]; then
  #   log "pip install -r requirements.txt"
  #   python3 -m pip install -r requirements.txt
  # fi
  # if [[ -f pyproject.toml ]]; then
  #   log "pip install -e ."
  #   python3 -m pip install -e ".[dev]"
  # fi

  # Go
  # if [[ -f go.mod ]]; then
  #   log "go mod download"
  #   go mod download
  # fi

  # Java (Maven)
  # if [[ -f pom.xml ]]; then
  #   log "mvn dependency:go-offline"
  #   mvn -q dependency:go-offline
  # fi

  # Java (Gradle)
  # if [[ -f gradlew ]]; then
  #   log "./gradlew dependencies"
  #   chmod +x gradlew
  #   ./gradlew dependencies --no-daemon
  # fi

  : # placeholder — remova quando adicionar comandos reais
}

# --- Git: acesso ao servidor (SSH/HTTPS) — ajuste se necessário ---
setup_git() {
  log "Configurando Git..."

  git config --global --add safe.directory "$ROOT" 2>/dev/null || true

  # Credenciais HTTPS (descomente e preencha, ou use gh auth / credential manager)
  # git config --global user.name "Seu Nome"
  # git config --global user.email "seu@email.com"
  # git config --global credential.helper store

  # SSH: monte ~/.ssh do host ou use ForwardAgent (devcontainer.json)
  # if [[ -d "${HOME}/.ssh" ]]; then
  #   chmod 700 "${HOME}/.ssh"
  #   chmod 600 "${HOME}/.ssh/id_*" 2>/dev/null || true
  # fi
}

# --- Validação das runtimes instaladas pelas Features ---
print_runtimes() {
  log "Runtimes disponíveis:"
  command -v node >/dev/null && echo "  Node:   $(node -v)"
  command -v python3 >/dev/null && echo "  Python: $(python3 --version)"
  command -v go >/dev/null && echo "  Go:     $(go version)"
  command -v java >/dev/null && echo "  Java:   $(java -version 2>&1 | head -1)"
  command -v mvn >/dev/null && echo "  Maven:  $(mvn -version 2>&1 | head -1)"
  command -v pre-commit >/dev/null && echo "  pre-commit: $(pre-commit --version)"
}

main() {
  setup_git
  install_pre_commit
  setup_project_prerequisites
  print_runtimes
  log "Concluído com sucesso."
}

main "$@"
