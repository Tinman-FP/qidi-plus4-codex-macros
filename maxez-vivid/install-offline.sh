#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  install-offline.sh --host <pi-hostname-or-address> [--user pi] [--restart]

Copies the Max EZ ViViD staging package to a Klipper Pi. The target printer
must be idle if Moonraker is reachable. Klipper is not restarted unless
--restart is supplied.
USAGE
}

host=""
remote_user="pi"
restart=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)
      host="${2:-}"
      shift 2
      ;;
    --user)
      remote_user="${2:-}"
      shift 2
      ;;
    --restart)
      restart=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$host" ]]; then
  usage >&2
  exit 2
fi

package_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
remote="${remote_user}@${host}"
config_dir="/home/pi/printer_data/config"
plr_dir="/home/pi/scripts/plr"
extras_dir="/home/pi/klipper/klippy/extras"
backup_dir="${config_dir}/backups/maxez-vivid-$(date +%Y%m%d-%H%M%S)"
moonraker_url="http://${host}:7125/printer/objects/query?print_stats&virtual_sdcard&webhooks"

status_json="$(curl -fsS --connect-timeout 3 --max-time 5 "$moonraker_url" 2>/dev/null || true)"
if [[ -n "$status_json" ]]; then
  if printf '%s' "$status_json" | grep -Eq '"state"[[:space:]]*:[[:space:]]*"(printing|paused)"'; then
    echo "Refusing to install while print_stats is printing or paused." >&2
    exit 1
  fi
  if printf '%s' "$status_json" | grep -Eq '"is_active"[[:space:]]*:[[:space:]]*true'; then
    echo "Refusing to install while virtual_sdcard is active." >&2
    exit 1
  fi
else
  echo "Moonraker status was not reachable; continuing with SSH copy only."
fi

ssh "$remote" "set -e
mkdir -p '$backup_dir' '$config_dir' '$plr_dir' '$extras_dir'
for file in printer.cfg maxez_mainsail_core.cfg maxez_qidi_macros.cfg qidi_print_start_production.cfg plr.cfg saved_variables.cfg saved_variables.seed.cfg; do
  if [ -e '$config_dir/'\"\$file\" ]; then
    cp -a '$config_dir/'\"\$file\" '$backup_dir/'\"\$file\"
  fi
done
if [ -e '$extras_dir/gcode_shell_command.py' ]; then
  cp -a '$extras_dir/gcode_shell_command.py' '$backup_dir/gcode_shell_command.py'
fi"

scp "$package_dir/printer.cfg" "$remote:$config_dir/printer.cfg"
scp "$package_dir"/config/*.cfg "$remote:$config_dir/"
scp "$package_dir"/scripts/plr/* "$remote:$plr_dir/"
scp "$package_dir/extras/gcode_shell_command.py" "$remote:$extras_dir/gcode_shell_command.py"

ssh "$remote" "set -e
chmod +x '$plr_dir/plr.sh' '$plr_dir/update_gcode_lines.sh'
if [ ! -e '$config_dir/saved_variables.cfg' ]; then
  cp '$config_dir/saved_variables.seed.cfg' '$config_dir/saved_variables.cfg'
fi"

echo "Installed Max EZ ViViD staged config files."
echo "Backups, when present, were written to: $backup_dir"
echo "Before restart, fill in serial IDs in $config_dir/printer.cfg and the BTT MMS config."

if [[ "$restart" -eq 1 ]]; then
  ssh "$remote" "curl -fsS -X POST http://127.0.0.1:7125/printer/restart >/dev/null"
  echo "Requested Klipper restart through Moonraker."
fi
