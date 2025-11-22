#!/usr/bin/env bash
set -e

CONFIG_FILE="$HOME/.displayplacer-presets"

# Find displayplacer binary
DISPLAYPLACER_BIN="$(command -v displayplacer || true)"

if [ -z "$DISPLAYPLACER_BIN" ]; then
  echo "Error: displayplacer not found in PATH." >&2
  exit 1
fi

# Get current layout command from displayplacer list output
get_current_layout_cmd() {
  "$DISPLAYPLACER_BIN" list | grep '^displayplacer ' | head -n 1
}

# Build a "signature" for the currently connected monitors (just the IDs, sorted)
get_current_signature() {
  local layout_cmd="$1"
  echo "$layout_cmd" |
    grep -o 'id:[^ ]*' |
    sed 's/id://g' |
    sort |
    tr '\n' '-' |
    sed 's/-$//'
}

cmd="$1"

if [ -z "$cmd" ]; then
  echo "Usage: $0 save|apply"
  exit 1
fi

layout_cmd="$(get_current_layout_cmd)"

if [ -z "$layout_cmd" ]; then
  echo "Error: Could not read current layout from displayplacer." >&2
  exit 1
fi

signature="$(get_current_signature "$layout_cmd")"

case "$cmd" in
save)
  # Remove existing preset for this signature
  if [ -f "$CONFIG_FILE" ]; then
    grep -v "^$signature|||" "$CONFIG_FILE" >"$CONFIG_FILE.tmp" || true
    mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
  fi

  # Save new preset
  echo "$signature|||$layout_cmd" >>"$CONFIG_FILE"
  echo "Saved layout preset for monitors: $signature"
  ;;

apply)
  if [ ! -f "$CONFIG_FILE" ]; then
    # No presets yet, nothing to do
    exit 0
  fi

  # Try to find matching signature
  line="$(grep "^$signature|||" "$CONFIG_FILE" || true)"

  if [ -z "$line" ]; then
    # No preset for this combination -> do nothing silently
    exit 0
  fi

  preset_cmd="${line#*|||}"
  eval "$preset_cmd"
  ;;

*)
  echo "Usage: $0 save|apply"
  exit 1
  ;;
esac
