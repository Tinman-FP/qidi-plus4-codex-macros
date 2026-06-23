#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="${PLR_SCRIPT_DIR:-/home/pi/scripts/plr}"
CONFIG_FILE="${PLR_CONFIG_FILE:-/home/pi/printer_data/config/saved_variables.cfg}"
GCODE_ROOT="${PLR_GCODE_ROOT:-/home/pi/printer_data/gcodes}"
RECORD_FILE="${PLR_RECORD_FILE:-$SCRIPT_DIR/plr_record}"

read_var() {
  local name="$1"
  awk -F ' = ' -v key="$name" '$1 == key {print $2}' "$CONFIG_FILE" | tail -n 1 | sed "s/^'//; s/'$//"
}

write_var() {
  local name="$1"
  local value="$2"
  local tmp="${CONFIG_FILE}.$$.tmp"

  if grep -q "^${name} = " "$CONFIG_FILE"; then
    sed "s|^${name} = .*|${name} = ${value}|" "$CONFIG_FILE" > "$tmp"
    mv "$tmp" "$CONFIG_FILE"
  else
    printf '%s = %s\n' "$name" "$value" >> "$CONFIG_FILE"
  fi
}

resolve_gcode_path() {
  local saved_path="$1"
  local last_file="$2"
  local candidate

  if [[ -n "$saved_path" && "$saved_path" = /* && -f "$saved_path" ]]; then
    printf '%s\n' "$saved_path"
    return 0
  fi

  if [[ -n "$saved_path" ]]; then
    candidate="$GCODE_ROOT/${saved_path#/}"
    if [[ -f "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  fi

  if [[ -n "$last_file" ]]; then
    candidate="$GCODE_ROOT/.cache/$last_file"
    if [[ -f "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
    candidate="$GCODE_ROOT/$last_file"
    if [[ -f "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  fi

  return 1
}

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: saved variables file not found: $CONFIG_FILE" >&2
  exit 1
fi

number="0"
if [[ -r "$RECORD_FILE" ]]; then
  number="$(tr -cd '0-9' < "$RECORD_FILE")"
fi
number="${number:-0}"

if ! [[ "$number" =~ ^[0-9]+$ ]]; then
  number="0"
fi

saved_position="$(read_var plr_file_position)"
saved_path="$(read_var filepath)"
if [[ -z "$saved_path" ]]; then
  saved_path="$(read_var file_path)"
fi
last_file="$(read_var last_file)"

if [[ "$number" -le 0 && "$saved_position" =~ ^[0-9]+$ && "$saved_position" -gt 0 ]]; then
  if gcode_path="$(resolve_gcode_path "$saved_path" "$last_file")"; then
    number="$(head -c "$saved_position" "$gcode_path" | wc -l | tr -d ' ')"
    number="${number:-0}"
  fi
fi

write_var gcode_lines "$number"
echo "gcode_lines = $number"
