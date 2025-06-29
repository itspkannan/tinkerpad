#!/bin/bash

if [[ -n "$BASH_VERSION" ]]; then
  set -euo pipefail
fi

########################################
# Helper: Initialize base files
########################################
init_project_files() {
  echo "📁 Creating base files..."
  echo -e "__pycache__/\n.venv/\n.env\n*.pyc\n.coverage\n.poetry/\nbuild/\ndist/" > .gitignore

  cat <<EOF > .editorconfig
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

########################################
# Helper: VSCode config
########################################
init_vscode_config() {
  mkdir -p .vscode
  cat <<EOF > .vscode/settings.json
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

########################################
# Helper: Root Makefile
########################################
init_makefile_root() {
  cat <<'EOF' > Makefile
.DEFAULT_GOAL := help

help:  ## Show available commands
	@echo "\n🛠️  Project Makefile Commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## ' Makefile | awk 'BEGIN {FS=":.*?## "}; {printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2}'
	@echo ""
EOF
}

########################################
# Helper: Add services support
########################################
init_services_support() {
  mkdir -p proto services domains

  cat <<'EOF' > add.service.sh
#!/usr/bin/env bash
SERVICE_NAME="$1"
if [ -z "$SERVICE_NAME" ]; then
  echo "Usage: ./add.service.sh <service_name>"
  exit 1
fi

read -p "What kind of service is '$SERVICE_NAME'? [grpc/http/cli]: " TYPE
cd "$(dirname "$0")" || exit 1

DOMAIN_NAME="$(echo "$SERVICE_NAME" | tr '-' '_')"
mkdir -p domains/$DOMAIN_NAME/$DOMAIN_NAME
echo "# Business logic for $DOMAIN_NAME" > domains/$DOMAIN_NAME/$DOMAIN_NAME/__init__.py

cd domains/$DOMAIN_NAME
poetry init --name "$DOMAIN_NAME" --no-interaction
poetry config virtualenvs.in-project true
poetry add --group dev ruff mypy pytest
cd - > /dev/null || exit 1

if [ "$TYPE" = "grpc" ]; then
  mkdir -p proto
  touch proto/$SERVICE_NAME.proto
  mkdir -p services/app-$SERVICE_NAME-grpc
  cd services/app-$SERVICE_NAME-grpc || exit 1

  poetry init --name "app_$SERVICE_NAME" --no-interaction
  poetry config virtualenvs.in-project true
  poetry add --path ../../domains/$DOMAIN_NAME
  poetry add grpcio grpcio-tools

  mkdir -p app
  echo "from $DOMAIN_NAME import *\n\nprint(\"Starting gRPC service: $SERVICE_NAME\")" > app/main.py

  mkdir -p scripts
  cat <<EOGEN > scripts/gen_grpc.sh
#!/usr/bin/env bash
python -m grpc_tools.protoc -I ../../proto --python_out=app --grpc_python_out=app ../../proto/$SERVICE_NAME.proto
EOGEN
  chmod +x scripts/gen_grpc.sh

  cd - > /dev/null || exit 1
fi
EOF

  chmod +x add.service.sh
}

########################################
# Helper: Add commons folder and Makefile
########################################
init_commons_support() {
  mkdir -p commons

  cat <<'EOF' > commons/Makefile
.DEFAULT_GOAL := help

COMMON_MODULES := $(shell find . -mindepth 2 -maxdepth 2 -name pyproject.toml -exec dirname {} \;)

help:  ## Show available commands
	@echo "\nCommon Module Commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## ' Makefile | awk 'BEGIN {FS=":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

build-all:  ## Install all common modules with poetry
	@for mod in $(COMMON_MODULES); do \
	  echo "📦 Installing in $$mod..."; \
	  (cd $$mod && poetry install --no-root); \
	done
	@echo "✅ All common modules installed."

test-all:  ## Run pytest in all common modules
	@for mod in $(COMMON_MODULES); do \
	  echo "🧪 Running tests in $$mod..."; \
	  (cd $$mod && poetry run pytest); \
	done

lint-all:  ## Run ruff in all common modules
	@for mod in $(COMMON_MODULES); do \
	  echo "🔍 Linting $$mod..."; \
	  (cd $$mod && poetry run ruff .); \
	done

format-all:  ## Auto-format all common modules
	@for mod in $(COMMON_MODULES); do \
	  echo "✨ Formatting $$mod..."; \
	  (cd $$mod && poetry run ruff . --fix); \
	done
EOF
}

########################################
# Main Monorepo Creator
########################################
create_monorepo() {
  local PROJECT_NAME="$1"
  local TYPE="$2"

  echo "🚀 Creating monorepo '$PROJECT_NAME' of type '$TYPE'..."
  mkdir -p "$PROJECT_NAME"
  cd "$PROJECT_NAME" || exit 1

  init_project_files
  init_vscode_config
  init_makefile_root

  [[ "$TYPE" == "services" || "$TYPE" == "all" ]] && init_services_support
  [[ "$TYPE" == "common" || "$TYPE" == "all" ]] && init_commons_support

  echo "✅ Monorepo '$PROJECT_NAME' setup complete."
  [[ "$TYPE" == "services" || "$TYPE" == "all" ]] && echo "👉 Use ./add.service.sh to scaffold services."
}



add_common_module() {
  local REPO_PATH="."
  local MODULE_NAME=""
  local DESCRIPTION=""
  local PY_VERSION="^3.9"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p|--path)
        REPO_PATH="$2"
        shift 2
        ;;
      -n|--name)
        MODULE_NAME="$2"
        shift 2
        ;;
      -d|--description)
        DESCRIPTION="$2"
        shift 2
        ;;
      -v|--python)
        PY_VERSION="$2"
        shift 2
        ;;
      -h|--help)
        echo "Usage: add_common_module -n <name> [-p <repo_path>] [-d <description>] [-v <python_version>]"
        return 0
        ;;
      *)
        echo "❌ Unknown option: $1"
        return 1
        ;;
    esac
  done

  if [[ -z "$MODULE_NAME" ]]; then
    echo "❌ Missing required -n <module-name>"
    return 1
  fi

  local PACKAGE_NAME
  PACKAGE_NAME=$(echo "$MODULE_NAME" | tr '-' '_')
  local COMMONS_DIR="$REPO_PATH/commons"
  local TARGET_DIR="$COMMONS_DIR/$MODULE_NAME"

  if [[ ! -d "$REPO_PATH" ]]; then
    echo "❌ Repo path '$REPO_PATH' does not exist"
    return 1
  fi

  if [[ -d "$TARGET_DIR" ]]; then
    echo "❌ Module already exists: $TARGET_DIR"
    return 1
  fi

  mkdir -p "$TARGET_DIR/$PACKAGE_NAME"

  echo "\"\"\"${DESCRIPTION:-Common utilities} (package: $PACKAGE_NAME)\"\"\"" > "$TARGET_DIR/$PACKAGE_NAME/__init__.py"

  cat > "$TARGET_DIR/pyproject.toml" <<EOF
[tool.poetry]
name = "$PACKAGE_NAME"
version = "0.1.0"
description = "${DESCRIPTION}"
authors = ["you@example.com"]
packages = [{include = "$PACKAGE_NAME"}]

[tool.poetry.dependencies]
python = "$PY_VERSION"

[tool.poetry.group.dev.dependencies]
ruff = "*"
mypy = "*"
pytest = "*"
EOF

  (
    cd "$TARGET_DIR" || return 1
    poetry config virtualenvs.in-project true --local
    poetry install --no-root
  )

  # Create commons Makefile if it doesn’t exist
  local MAKEFILE_PATH="$COMMONS_DIR/Makefile"
  if [[ ! -f "$MAKEFILE_PATH" ]]; then
    echo "🧩 Creating commons Makefile at $MAKEFILE_PATH..."
    cat <<'EOF' > "$MAKEFILE_PATH"
.DEFAULT_GOAL := help

COMMON_MODULES := $(shell find . -mindepth 2 -maxdepth 2 -name pyproject.toml -exec dirname {} \;)

help:  ## Show available commands
	@echo "\nCommon Module Commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS=":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

build-all:  ## Install all common modules with poetry
	@for mod in $(COMMON_MODULES); do \
	  echo "📦 Installing in $$mod..."; \
	  (cd $$mod && poetry install --no-root); \
	done
	@echo "✅ All common modules installed."

test-all:  ## Run pytest in all common modules
	@for mod in $(COMMON_MODULES); do \
	  echo "🧪 Running tests in $$mod..."; \
	  (cd $$mod && poetry run pytest); \
	done

lint-all:  ## Run ruff in all common modules
	@for mod in $(COMMON_MODULES); do \
	  echo "🔍 Linting $$mod..."; \
	  (cd $$mod && poetry run ruff .); \
	done

format-all:  ## Auto-format all common modules
	@for mod in $(COMMON_MODULES); do \
	  echo "✨ Formatting $$mod..."; \
	  (cd $$mod && poetry run ruff . --fix); \
	done
EOF
  fi

  echo "✅ Common module '$MODULE_NAME' created at '$TARGET_DIR'"
}
