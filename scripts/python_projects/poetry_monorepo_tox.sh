#!/bin/sh


monorepo.poetry_package.setup.folder_structure() {
  local PROJECT_NAME="$1"
  echo "📁 Creating project at: $PROJECT_NAME"
  mkdir -p "$PROJECT_NAME"
  cd "$PROJECT_NAME"
  mkdir -p commons services domains proto
}

monorepo.poetry_package.setup.base_files() {
  cat > .gitignore <<EOF
__pycache__/
.venv/
.env
*.pyc
.coverage
.poetry/
build/
dist/
EOF

  cat > .editorconfig <<EOF
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
indent_style = space
indent_size = 4
trim_trailing_whitespace = true
EOF
}


monorepo.poetry_package.setup.vscode_config() {
  mkdir -p .vscode
  cat > .vscode/settings.json <<EOF
{
  "python.defaultInterpreterPath": ".venv/bin/python",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  },
  "ruff.organizeImports": true,
  "ruff.enable": true
}
EOF
}

cat > Makefile <<'EOF'
.DEFAULT_GOAL := help

help:  ## Show available commands
	@echo "\n🛠️  Project Makefile Commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## ' Makefile | awk 'BEGIN {FS=":.*?## "}; {printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2}'
	@echo ""

lint:  ## Run ruff in all modules
	@find commons domains services -name pyproject.toml -exec dirname {} \; | while read mod; do \
		echo "🔍 Linting $$mod..."; \
		(cd $$mod && poetry run ruff .); \
	done

type-check:  ## Run mypy in all modules
	@find commons domains services -name pyproject.toml -exec dirname {} \; | while read mod; do \
		echo "📐 Type-checking $$mod..."; \
		(cd $$mod && poetry run mypy .); \
	done

test:  ## Run tests in all modules
	@find commons domains services -name pyproject.toml -exec dirname {} \; | while read mod; do \
		echo "🧪 Testing $$mod..."; \
		(cd $$mod && poetry run pytest); \
	done

tox:  ## Run tox in all modules using embedded config
	@find commons domains services -name tox.ini -exec dirname {} \; | while read mod; do \
		echo "🐍 Running tox in $$mod..."; \
		(cd $$mod && poetry run tox || echo "⚠️ Tox failed in $$mod"); \
	done
EOF

monorepo.poetry_package.setup.makefile() {
  cat > Makefile <<'EOF'
.DEFAULT_GOAL := help

help:  ## Show available commands
	@echo "\n🛠️  Project Makefile Commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## ' Makefile | awk 'BEGIN {FS=":.*?## "}; {printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2}'
	@echo ""

lint:  ## Run ruff in all modules
	@find commons domains services -name pyproject.toml -exec dirname {} \; | while read mod; do \
	  echo "🔍 Linting $$mod..."; \
	  (cd $$mod && poetry run ruff .); \
	done

type-check:  ## Run mypy in all modules
	@find commons domains services -name pyproject.toml -exec dirname {} \; | while read mod; do \
	  echo "📐 Type-checking $$mod..."; \
	  (cd $$mod && poetry run mypy .); \
	done

test:  ## Run tests in all modules
	@find commons domains services -name pyproject.toml -exec dirname {} \; | while read mod; do \
	  echo "🧪 Testing $$mod..."; \
	  (cd $$mod && poetry run pytest); \
	done

tox:  ## Run tox if present
	@if [ -f tox.ini ]; then tox; else echo "tox.ini not found"; fi
EOF
}


monorepo.poetry_package.setup.helper_scripts() {
  local project="$1"

  cat > "$project/scripts/add_common.sh" <<'EOS'
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
BASE_DIR="$PROJECT/commons/$NAME"
SRC_DIR="$BASE_DIR/$MOD_NAME"
mkdir -p "$SRC_DIR"

cd "$BASE_DIR"
poetry new "$MOD_NAME" --src
cd "$MOD_NAME"
poetry config virtualenvs.in-project true
poetry add --group dev pytest mypy ruff tox

echo '# Common: ${NAME}

This module was created using the monorepo helper.

## Development

```bash
poetry install
make test
make lint
make type-check
make format
make tox
```' > "$BASE_DIR/README.md"
echo '.DEFAULT_GOAL := help

help:  ## Show available commands
	@echo "\n📦 Module Commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS=":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

install:  ## Install dependencies
	poetry install --no-root

test:  ## Run tests
	poetry run pytest

lint:  ## Run ruff
	poetry run ruff .

type-check:  ## Run mypy
	poetry run mypy .

format:  ## Auto-format code
	poetry run ruff . --fix

tox:  ## Run tox
	tox' > "$BASE_DIR/Makefile"
echo '[tox]
envlist = py39

[testenv]
deps =
    pytest
    mypy
    ruff
commands =
    pytest
    mypy ${MOD_NAME}
    ruff ${MOD_NAME}' > "$BASE_DIR/tox.ini"





echo "✅ Common '$NAME' created at $SRC_DIR"
EOS
  chmod +x "$project/scripts/add_common.sh"

  cat > "$project/scripts/add_domain.sh" <<'EOS'
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
BASE_DIR="$PROJECT/domains/$NAME"
SRC_DIR="$BASE_DIR/$MOD_NAME"
mkdir -p "$SRC_DIR"

cd "$BASE_DIR"
poetry new "$MOD_NAME" --src
cd "$MOD_NAME"
poetry config virtualenvs.in-project true
poetry add --group dev pytest mypy ruff tox

echo '# Domain: ${NAME}

This module was created using the monorepo helper.

## Development

```bash
poetry install
make test
make lint
make type-check
make format
make tox
```' > "$BASE_DIR/README.md"
echo '.DEFAULT_GOAL := help

help:  ## Show available commands
	@echo "\n📦 Module Commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS=":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

install:  ## Install dependencies
	poetry install --no-root

test:  ## Run tests
	poetry run pytest

lint:  ## Run ruff
	poetry run ruff .

type-check:  ## Run mypy
	poetry run mypy .

format:  ## Auto-format code
	poetry run ruff . --fix

tox:  ## Run tox
	tox' > "$BASE_DIR/Makefile"
echo '[tox]
envlist = py39

[testenv]
deps =
    pytest
    mypy
    ruff
commands =
    pytest
    mypy ${MOD_NAME}
    ruff ${MOD_NAME}' > "$BASE_DIR/tox.ini"





echo "✅ Domain '$NAME' created at $SRC_DIR"
EOS
  chmod +x "$project/scripts/add_domain.sh"

  cat > "$project/scripts/add_service.sh" <<'EOS'
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
BASE_DIR="$PROJECT/services/$NAME"
SRC_DIR="$BASE_DIR/$MOD_NAME"
mkdir -p "$SRC_DIR"

cd "$BASE_DIR"
poetry new "$MOD_NAME" --src
cd "$MOD_NAME"
poetry config virtualenvs.in-project true
poetry add --group dev pytest mypy ruff tox

echo '# Service: ${NAME}

This module was created using the monorepo helper.

## Development

```bash
poetry install
make test
make lint
make type-check
make format
make tox
```' > "$BASE_DIR/README.md"
echo '.DEFAULT_GOAL := help

help:  ## Show available commands
	@echo "\n📦 Module Commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS=":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

install:  ## Install dependencies
	poetry install --no-root

test:  ## Run tests
	poetry run pytest

lint:  ## Run ruff
	poetry run ruff .

type-check:  ## Run mypy
	poetry run mypy .

format:  ## Auto-format code
	poetry run ruff . --fix

tox:  ## Run tox
	tox' > "$BASE_DIR/Makefile"
echo '[tox]
envlist = py39

[testenv]
deps =
    pytest
    mypy
    ruff
commands =
    pytest
    mypy ${MOD_NAME}
    ruff ${MOD_NAME}' > "$BASE_DIR/tox.ini"

echo 'FROM python:3.9-slim

WORKDIR /app
COPY . .

RUN pip install poetry && poetry install

CMD ["poetry", "run", "python", "app/main.py"]' > "$BASE_DIR/Dockerfile"



echo "✅ Service '$NAME' created at $SRC_DIR"
EOS
  chmod +x "$project/scripts/add_service.sh"

  cat > "$project/scripts/add_api.sh" <<'EOS'
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT=$(cd "$SCRIPT_DIR/.." && pwd)

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--name) NAME="$2"; shift 2 ;;
    -f|--framework) FRAMEWORK="$2"; shift 2 ;;  # API only
    *) echo "❌ Unknown flag: $1"; exit 1 ;;
  esac
done

: "${NAME:?Missing -n <module-name>}"
MOD_NAME=$(echo "$NAME" | tr '-' '_')
BASE_DIR="$PROJECT/services/$NAME"
SRC_DIR="$BASE_DIR/$MOD_NAME"
mkdir -p "$SRC_DIR"

cd "$BASE_DIR"
poetry new "$MOD_NAME" --src
cd "$MOD_NAME"
poetry config virtualenvs.in-project true
poetry add --group dev pytest mypy ruff tox

echo '# Api: ${NAME}

This module was created using the monorepo helper.

## Development

```bash
poetry install
make test
make lint
make type-check
make format
make tox
```' > "$BASE_DIR/README.md"
echo '.DEFAULT_GOAL := help

help:  ## Show available commands
	@echo "\n📦 Module Commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS=":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

install:  ## Install dependencies
	poetry install --no-root

test:  ## Run tests
	poetry run pytest

lint:  ## Run ruff
	poetry run ruff .

type-check:  ## Run mypy
	poetry run mypy .

format:  ## Auto-format code
	poetry run ruff . --fix

tox:  ## Run tox
	tox' > "$BASE_DIR/Makefile"
echo '[tox]
envlist = py39

[testenv]
deps =
    pytest
    mypy
    ruff
commands =
    pytest
    mypy ${MOD_NAME}
    ruff ${MOD_NAME}' > "$BASE_DIR/tox.ini"

echo 'FROM python:3.9-slim

WORKDIR /app
COPY . .

RUN pip install poetry && poetry install

CMD ["poetry", "run", "python", "app/main.py"]' > "$BASE_DIR/Dockerfile"


if [[ "$TYPE" == "api" ]]; then
  FRAMEWORK="${FRAMEWORK:-sanic}"
  poetry add ${FRAMEWORK}
  if [[ "$FRAMEWORK" == "sanic" ]]; then
cat > "$SRC_DIR/main.py" <<EOF
from sanic import Sanic
from sanic.response import json

app = Sanic("App_$MOD_NAME")

@app.get("/")
async def hello(request):
    return json({"message": "Hello from $MOD_NAME using Sanic"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
EOF
  elif [[ "$FRAMEWORK" == "fastapi" ]]; then
    poetry add fastapi uvicorn
cat > "$SRC_DIR/main.py" <<EOF
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def hello():
    return {"message": "Hello from $MOD_NAME using FastAPI"}
EOF
  fi
fi

echo "✅ Api '$NAME' created at $SRC_DIR"
EOS
  chmod +x "$project/scripts/add_api.sh"

}


monorepo.poetry_package.bootstrap() {
  local PROJECT_NAME=""

  # parse args
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p|--project)
        PROJECT_NAME="$2"
        shift 2
        ;;
      *)
        echo "❌ Unknown argument: $1"
        return 1
        ;;
    esac
  done

  if [[ -z "$PROJECT_NAME" ]]; then
    echo "❌ Missing project name. Usage: monorepo.poetry_package.bootstrap -p <name>"
    return 1
  fi

  monorepo.poetry_package.setup.folder_structure "$PROJECT_NAME"
  monorepo.poetry_package.setup.base_files
  monorepo.poetry_package.setup.vscode_config
  monorepo.poetry_package.setup.makefile
  monorepo.poetry_package.setup.helper_scripts

  echo "✅ Monorepo '$PROJECT_NAME' bootstrapped."
  echo "👉 Use add_common_module.sh / add.service.sh to scaffold modules"
}
