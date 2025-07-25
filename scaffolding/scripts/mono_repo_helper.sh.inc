#!/usr/bin/env bash

monorepo.setup.folder_structure() {
  local NAME="$1"
  echo "📁 Creating project at: $NAME"
  mkdir -p "$NAME"/{proto,commons,domains,services,scripts}
  cd "$NAME"
}

monorepo.setup.base_files() {
  echo "🧪 Creating top-level Makefile and configs"
  cat > Makefile <<EOF
.DEFAULT_GOAL := help

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' \$(MAKEFILE_LIST) | awk 'BEGIN {FS=":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", \$$1, \$$2}'
	@echo ""

all: ## Run all tests for all modules
	@for dir in commons/* domains/* services/*; do \
	  if [ -f \$$dir/Makefile ]; then \
	    echo "🔧 Running make in \$$dir"; \
	    \$(MAKE) -C \$$dir || exit 1; \
	  fi \
	done
EOF
}
