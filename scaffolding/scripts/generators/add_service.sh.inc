#!/usr/bin/env bash
monorepo.poetry_package.add.service() {
  cat > "scripts/add_service.sh" <<'EOS'
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT=$(cd "$SCRIPT_DIR/.." && pwd)

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--name) NAME="$2"; shift 2 ;;
    *) echo "❌ Unknown flag: $1"; exit 1 ;;
  esac
done

: "${NAME:?Missing -n <module-name>}"
MOD_NAME=$(echo "$NAME" | tr '-' '_')
BASE_DIR="$PROJECT/service"
SRC_DIR="$BASE_DIR/$MOD_NAME"

mkdir -p "$BASE_DIR"
cd "$BASE_DIR"

# Create a new Poetry package
poetry new "$MOD_NAME"
cd "$MOD_NAME"

# Use in-project virtualenv and install dev dependencies
poetry config virtualenvs.in-project true
poetry add --group dev pytest mypy ruff tox

# Create Makefile
cat > Makefile <<MAKE
test:
	poetry run pytest

lint:
	poetry run ruff $MOD_NAME

type-check:
	poetry run mypy $MOD_NAME

format:
	poetry run ruff format $MOD_NAME

tox:
	poetry run tox

.PHONY: test lint type-check format tox
MAKE

# Create tox.ini
cat > tox.ini <<TOX
[tox]
envlist = py39

[testenv]
deps =
    pytest
    ruff
    mypy
commands =
    pytest
    ruff $MOD_NAME
    mypy $MOD_NAME
TOX

# Create README
cat > "$BASE_DIR/README.md" <<README
# Domain Module: ${MOD_NAME}

This is a service module and can be deployed 

## 📦 Development Setup

\`\`\`bash
cd service/${NAME}
poetry install
make test
make lint
make type-check
make format
make tox
\`\`\`
README

echo "✅ Domain module '${NAME}' created at $SRC_DIR"
EOS

  chmod +x "scripts/add_service.sh"

}
