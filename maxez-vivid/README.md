# Max EZ ViViD Integration Package

Offline staging package for a Qidi Plus 4 Max EZ running a fresh Klipper/Python
3 build with:

- Qidi Plus 4 Max EZ baseline motion, heater, fan, Beacon, and macro layout.
- Nebula extruder on a BTT EBB42 Gen 2 toolhead board.
- Slice Engineering Mosquito hotend.
- BTT ViViD staged as the replacement path for the legacy Qidi Box.

The machine config keeps the Max EZ MCU pins from the Max EZ baseline and only
changes the toolhead path requested for this build:

- Extruder heater: `EBB:PB0`.
- Hotend thermistor: `EBB:PA1`.
- EBB42 Gen 2 fans: unused.
- Hotend cooling fan remains on the Max EZ harness at `PC2`.
- Auxiliary and chamber fans remain on the Max EZ MCU as `PA4` and `PA3`.

## Files

| Path | Purpose |
| --- | --- |
| `printer.cfg` | Main staged printer config with placeholder serial IDs. |
| `config/` | Max EZ macro, Mainsail, PLR, and production-start includes. |
| `scripts/plr/` | Power-loss recovery helper scripts used by `plr.cfg`. |
| `extras/gcode_shell_command.py` | Klipper extra required by the PLR shell commands. |
| `vivid/` | ViViD bring-up notes and staged override template. |
| `install-offline.sh` | Copies this package to a Pi once it is reachable. |

## Current Status

This package is ready for software-side upload, but it is not a final hardware
bring-up profile. Before restarting Klipper with hardware attached, fill in the
actual serial IDs for the main MCU, EBB42 Gen 2, Beacon, ViViD, and Buffer.

The legacy Qidi Box includes remain disabled. The older Qidi Box Klipper extras
were binary modules built for an older Python runtime, while the BTT ViViD/MMS
path is Python 3-native.

## Install Preview

When the Pi is back online:

```bash
./maxez-vivid/install-offline.sh --host <pi-hostname-or-address>
```

The script backs up existing target files, copies the staged config, installs
the PLR helper scripts, and leaves Klipper restart as an explicit choice.
