#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
fi

SCRIPT_SOURCE="${BASH_SOURCE[0]:-${(%):-%x}}"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"

source "$SCRIPT_DIR/mono_repo_helper.sh.inc"
source "$SCRIPT_DIR/mono_bootstrap_python.sh.inc"

source "$SCRIPT_DIR/generators/add_common.sh.inc"
source "$SCRIPT_DIR/generators/add_domain.sh.inc"
source "$SCRIPT_DIR/generators/add_service.sh.inc"

sh $SCRIPT_DIR/generators/generate_add_api.sh $SCRIPT_DIR
