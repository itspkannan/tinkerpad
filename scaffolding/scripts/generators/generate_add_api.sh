#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$1
PROJECT_NAME=$2

OUTPUT="scripts/add_api.sh"
PARTS_DIR="$SCRIPT_DIR/generator/part/api"

echo '#!/usr/bin/env bash' > "$OUTPUT"
echo 'set -euo pipefail' >> "$OUTPUT"

# Append all parts
cat "$PARTS_DIR/module.sh.part" >> "$OUTPUT"
cat "$PARTS_DIR/readme.sh.part" >> "$OUTPUT"
cat "$PARTS_DIR/makefile.sh.part" >> "$OUTPUT"
cat "$PARTS_DIR/tox.sh.part" >> "$OUTPUT"

# Add conditional generation of main.py based on framework
cat >> "$OUTPUT" <<'EOF'

if [[ "$TYPE" == "api" ]]; then
  FRAMEWORK="${FRAMEWORK:-sanic}"
  if [[ "$FRAMEWORK" == "sanic" ]]; then
EOF
cat "$PARTS_DIR/sanic.sh.part" >> "$OUTPUT"
cat >> "$OUTPUT" <<'EOF'
  elif [[ "$FRAMEWORK" == "fastapi" ]]; then
EOF
cat "$PARTS_DIR/fastapi.sh.part" >> "$OUTPUT"
cat >> "$OUTPUT" <<'EOF'
  fi
fi

echo "✅ Api '$NAME' created at $SRC_DIR"
EOF

chmod +x "$OUTPUT"
echo "✅ Script generated: $OUTPUT"
