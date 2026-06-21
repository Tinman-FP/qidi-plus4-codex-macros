# Qidi Plus 4 Codex Macros

Public release of tested Qidi Plus 4 Klipper/Moonraker macros from William
Tinney's printer operations work.

The first release contains:

- `macros/qidi_print_start_production.cfg` - tested adaptive heat-soak
  production start macro.
- `macros/qidi_box_humidity_auto.cfg` - Qidi Box humidity maintenance helper.
- `reference/baseline/qidi_print_start_production.before_adaptive_heat_soak.cfg`
  - pre-adaptive baseline used for the verified upgrade.
- `maxez-vivid/` - offline staging package for the Qidi Plus 4 Max EZ build
  with Nebula, EBB42 Gen 2, Mosquito, Beacon, PLR, and BTT ViViD notes.

This repository is intentionally small. It does not publish raw printer
backups, private IP addresses, SSH credentials, saved variables, G-code output,
customer files, logs, or unrelated printer work.

## What The Adaptive Start Does

`PRINT_START_PRODUCTION` keeps the successful Qidi startup fixes and adds an
adaptive heat-soak mesh loop:

1. Starts the chamber circulation fan at 100 percent before heat-up.
2. Heats bed, nozzle, and chamber together.
3. Waits for chamber stabilization.
4. Runs initial `G28` and `Z_TILT_ADJUST`.
5. Runs adaptive `BED_MESH_CALIBRATE PROFILE=kamp` passes every 60 seconds
   until consecutive meshes differ by no more than `0.015 mm`, or until the
   max iteration count is reached.
6. Runs final post-soak `G28`, `Z_TILT_ADJUST`, and
   `BED_MESH_CALIBRATE PROFILE=kamp`.
7. Wipes/clears the nozzle after the final mesh so the print uses the final
   post-soak geometry.

The tested production macro removes the previous hidden `G29` path from the
production start sequence.

## Compatibility

Tested on William Tinney's Qidi Plus 4 running Klipper/Moonraker with:

- Qidi-style `M141` / `M191` chamber control.
- `Z_TILT_ADJUST`.
- Adaptive/KAMP-style `BED_MESH_CALIBRATE PROFILE=kamp`.
- Existing Qidi nozzle clear macros: `CLEAR_NOZZLE` and `CLEAR_NOZZLE_PLR`.
- Existing Qidi sensor/tool-change macros used by the stock production start.

These files are not drop-in universal Klipper configs. Read
[docs/install.md](docs/install.md) before installing.

## Max EZ ViViD Staging

The `maxez-vivid/` package is a separate, offline-ready build path for a Qidi
Plus 4 Max EZ moving from the legacy Qidi Box path to BTT ViViD. It keeps the
Max EZ baseline MCU pins and applies only the requested toolhead changes:

- Nebula extruder on EBB42 Gen 2.
- Mosquito heater on `EBB:PB0`.
- Mosquito thermistor on `EBB:PA1`.
- No active fans assigned to the EBB42 Gen 2.
- Qidi Box includes disabled because the legacy binary extras are not suitable
  for the fresh Python 3 Klipper build.

The ViViD files are staged as bring-up notes and templates until the physical
serial IDs, sensor pins, cutter path, and purge/brush coordinates are validated.

## Credits

Project owner and printer validation:

- William Tinney / Tinman-FP

Implementation and documentation assistance:

- OpenAI Codex

Upstream and source lineage credited in detail:

- [ATTRIBUTION.md](ATTRIBUTION.md)
- [NOTICE.md](NOTICE.md)

This project is not affiliated with QIDI, Klipper, Moonraker, KAMP, or Beacon.

## License

GPL-3.0-or-later. See [LICENSE](LICENSE).

The GPL posture is intentional because this work lives in the Klipper/Qidi
macro ecosystem and should remain source-available.
