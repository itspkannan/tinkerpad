#!/usr/bin/env bash

monorepo.poetry_package.bootstrap() {
  local PROJECT_NAME=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p|--project) PROJECT_NAME="$2"; shift 2 ;;
      *) echo "❌ Unknown argument: $1"; return 1 ;;
    esac
  done

  if [[ -z "$PROJECT_NAME" ]]; then
    echo "❌ Missing project name. Usage: create_monorepo -p <name>"
    return 1
  fi

  monorepo.setup.folder_structure "$PROJECT_NAME"
  monorepo.setup.base_files
  monorepo.setup.create_generators $SCRIPT_DIR
  echo "✅ Monorepo '$PROJECT_NAME' bootstrapped."
}

monorepo.setup.create_generators() {
  local SCRIPT_DIR="$1"
  monorepo.poetry_package.add.common
  monorepo.poetry_package.add.domain
  monorepo.poetry_package.add.service

}
