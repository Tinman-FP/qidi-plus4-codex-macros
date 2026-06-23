#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="${PLR_BASE_DIR:-/home/pi/printer_data}"
GCODE_ROOT="${PLR_GCODE_ROOT:-$BASE_DIR/gcodes}"
CONFIG_FILE="${PLR_CONFIG_FILE:-$BASE_DIR/config/saved_variables.cfg}"
SD_PATH="${PLR_SD_PATH:-$GCODE_ROOT/.plr}"

Z_HEIGHT="${1:-}"
LAST_FILE="${2:-}"
EXTRUDER_TEMP="${3:-}"
BED_TEMP="${4:-}"
CHAMBER_TEMP="${5:-}"
FILE_PATH="${6:-}"
FILE_POSITION="${7:-}"
GCODE_LINES="${8:-}"

read_var() {
  local name="$1"
  awk -F ' = ' -v key="$name" '$1 == key {print $2}' "$CONFIG_FILE" | tail -n 1 | sed "s/^'//; s/'$//"
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

require_number() {
  local name="$1"
  local value="$2"
  if ! [[ "$value" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    echo "Error: $name is missing or not numeric: $value" >&2
    exit 1
  fi
}

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: saved variables file not found: $CONFIG_FILE" >&2
  exit 1
fi

Z_HEIGHT="${Z_HEIGHT:-$(read_var power_resume_z)}"
LAST_FILE="${LAST_FILE:-$(read_var last_file)}"
EXTRUDER_TEMP="${EXTRUDER_TEMP:-$(read_var print_temp)}"
BED_TEMP="${BED_TEMP:-$(read_var bed_temp)}"
CHAMBER_TEMP="${CHAMBER_TEMP:-$(read_var hot_temp)}"
FILE_PATH="${FILE_PATH:-$(read_var filepath)}"
if [[ -z "$FILE_PATH" ]]; then
  FILE_PATH="$(read_var file_path)"
fi
FILE_POSITION="${FILE_POSITION:-$(read_var plr_file_position)}"
GCODE_LINES="${GCODE_LINES:-$(read_var gcode_lines)}"

require_number "Z_HEIGHT" "$Z_HEIGHT"
require_number "EXTRUDER_TEMP" "$EXTRUDER_TEMP"
require_number "BED_TEMP" "$BED_TEMP"
require_number "CHAMBER_TEMP" "${CHAMBER_TEMP:-0}"

FILE_POSITION="${FILE_POSITION:-0}"
GCODE_LINES="${GCODE_LINES:-0}"
if ! [[ "$FILE_POSITION" =~ ^[0-9]+$ ]]; then
  FILE_POSITION="0"
fi
if ! [[ "$GCODE_LINES" =~ ^[0-9]+$ ]]; then
  GCODE_LINES="0"
fi

if [[ -z "$LAST_FILE" || "$LAST_FILE" == "default" || -z "$FILE_PATH" || "$FILE_PATH" == "default" ]]; then
  echo "Error: saved file path/name is incomplete" >&2
  exit 1
fi

if ! GCODE_PATH="$(resolve_gcode_path "$FILE_PATH" "$LAST_FILE")"; then
  echo "Error: could not find saved G-code path: $FILE_PATH / $LAST_FILE" >&2
  exit 1
fi

if [[ "$GCODE_LINES" -le 0 && "$FILE_POSITION" -gt 0 ]]; then
  GCODE_LINES="$(head -c "$FILE_POSITION" "$GCODE_PATH" | wc -l | tr -d ' ')"
  GCODE_LINES="${GCODE_LINES:-0}"
fi

if [[ "$GCODE_LINES" -le 1 ]]; then
  echo "Error: gcode_lines is too small for PLR: $GCODE_LINES" >&2
  exit 1
fi

mkdir -p "$SD_PATH"
rm -f "$SD_PATH/plr.gcode"

tmp_file="$(mktemp /tmp/maxez-plr.XXXXXX)"
trap 'rm -f "$tmp_file" "$tmp_file.head"' EXIT
cp "$GCODE_PATH" "$tmp_file"

num_lines=$((GCODE_LINES - 1))
head -n "$num_lines" "$tmp_file" > "$tmp_file.head"

z_from_file="$(sed -n '/;Z:/s/.*;Z:\([0-9.]*\).*/\1/p; /; Z_HEIGHT: /s/.*; Z_HEIGHT: \([0-9.]*\).*/\1/p' "$tmp_file.head" | tail -n 1)"
if [[ -n "$z_from_file" && "$Z_HEIGHT" == "0" ]]; then
  Z_HEIGHT="$z_from_file"
fi

require_number "Z_HEIGHT" "$Z_HEIGHT"

if grep -q "thumbnail" "$tmp_file"; then
  {
    printf ';start copy\n'
    sed -n '1,/thumbnail end/p' "$tmp_file"
    printf ';\n\n'
  } >> "$SD_PATH/plr.gcode"
fi

{
  printf '; Max EZ generated power-loss recovery file\n'
  printf '; Source: %s\n' "$FILE_PATH"
  printf '; Resume line: %s\n' "$GCODE_LINES"
  printf '; Resume byte position: %s\n' "$FILE_POSITION"
  printf 'SET_KINEMATIC_POSITION Z=%s\n' "$Z_HEIGHT"
  printf 'M109 S%s\n' "$EXTRUDER_TEMP"
  printf 'M140 S%s\n' "$BED_TEMP"
  printf 'M104 S%s\n' "$EXTRUDER_TEMP"
  printf 'G91\n'
  printf 'G1 Z5\n'
  printf 'G90\n'
  printf 'G28 X Y\n'
  printf 'CLEAR_NOZZLE_PLR HOTEND=%s\n' "$EXTRUDER_TEMP"
  printf 'M190 S%s\n' "$BED_TEMP"
  if [[ "${CHAMBER_TEMP:-0}" != "0" && "${CHAMBER_TEMP:-0}" != "0.0" ]]; then
    printf 'M191 S%s\n' "$CHAMBER_TEMP"
  fi
  awk -v n="$num_lines" 'NR <= n && /M106/ {print}' "$tmp_file"
  printf 'G90\n'
  printf 'G1 Z%s\n' "$Z_HEIGHT"
  awk -v n="$num_lines" 'NR <= n && /(M83|M82)/ {line=$0} END {if (line != "") print line}' "$tmp_file"
  printf 'ENABLE_ALL_SENSOR\n'
  printf 'G1 F6000\n'
  sed '1,'"$num_lines"'d' "$tmp_file"
} >> "$SD_PATH/plr.gcode"

echo "Generated $SD_PATH/plr.gcode from $GCODE_PATH at line $GCODE_LINES"
