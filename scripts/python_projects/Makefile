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
