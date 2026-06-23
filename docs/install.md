# Install Guide

This guide assumes you already have a Qidi Plus 4 running Klipper/Moonraker and
a production start macro file named `qidi_print_start_production.cfg`.

## Safety Gate

Install only when the printer is idle:

- `print_stats.state` is not `printing` or `paused`.
- `virtual_sdcard.is_active` is false.
- `webhooks.state` is `ready`.

Do not restart Klipper while a print is active.

## Dependencies

The adaptive production macro expects your printer config to provide:

- `AUTOTUNE_SHAPERS`
- `TOOL_CHANGE_END`
- `DISABLE_ALL_SENSOR`
- `CLEAR_PAUSE`
- `set_zoffset`
- `M141`
- `M191`
- `G28`
- `Z_TILT_ADJUST`
- `BED_MESH_CALIBRATE PROFILE=kamp`
- `SAVE_VARIABLE`
- `CLEAR_NOZZLE`
- `CLEAR_NOZZLE_PLR`
- `BOX_PRINT_START`
- `EXTRUSION_AND_FLUSH`
- `ENABLE_ALL_SENSOR`
- `save_last_file`

If any of these are missing, adapt the macro before installing.

## Recommended Install Flow

1. Download your live `qidi_print_start_production.cfg`.
2. Save a local copy and a printer-side backup.
3. Compare your live file to
   `reference/baseline/qidi_print_start_production.before_adaptive_heat_soak.cfg`.
4. If your live file has drifted, stop and merge manually.
5. Upload `macros/qidi_print_start_production.cfg` as
   `qidi_print_start_production.cfg`.
6. Restart Klipper only while idle.
7. Verify the loaded config:
   - `variable_use_adaptive_heat_soak=1`
   - `variable_heat_soak_mesh_threshold=0.015`
   - `QIDI_ADAPTIVE_HEAT_SOAK_MESH` is present
   - `G29` is not present in `PRINT_START_PRODUCTION`
8. Run a controlled print with supervision.

## PLR Macro

`macros/plr.cfg` replaces the stock Qidi `plr.cfg` macro layer. Install it only
when idle, and keep a printer-side backup of the previous `plr.cfg`.

This macro expects:

- `/home/mks/scripts/plr/plr.sh`
- `/home/mks/scripts/plr/update_gcode_lines.sh`
- `gcode_shell_command`
- `SAVE_VARIABLE`
- `virtual_sdcard`
- `bed_mesh`
- `set_zoffset`

Do not install it if another included file already defines
`[gcode_macro SET_PRINT_STATS_INFO]`; merge the `_QIDI_PLR_CAPTURE_STATE` call
into the existing wrapper instead.

## Parameters

The macro defaults are:

| Variable | Default |
| --- | --- |
| `variable_use_adaptive_heat_soak` | `1` |
| `variable_heat_soak_mesh_threshold` | `0.015` |
| `variable_heat_soak_mesh_interval_seconds` | `60` |
| `variable_heat_soak_mesh_settle_seconds` | `60` |
| `variable_heat_soak_mesh_max_iterations` | `8` |

You can override relevant behavior from slicer start G-code with parameters
such as `HEAT_SOAK_THRESHOLD`, `HEAT_SOAK_INTERVAL`, `HEAT_SOAK_SETTLE`, and
`HEAT_SOAK_MESH`.

## Humidity Helper

`macros/qidi_box_humidity_auto.cfg` is separate from the production start macro.
Install it only if your Qidi Box exposes:

- `aht20_f heater_box1`
- `heater_generic heater_box1`
- `SAVE_VARIABLE`
- `UPDATE_DELAYED_GCODE`

Useful commands:

- `BOX_HUMIDITY_AUTO_STATUS`
- `BOX_HUMIDITY_AUTO_ENABLE TEMP=40 HIGH=19 LOW=14 POLL=30`
- `BOX_HUMIDITY_AUTO_DISABLE`

## Max EZ ViViD Package

The `maxez-vivid/` package is for the separate Qidi Plus 4 Max EZ conversion
with Nebula, EBB42 Gen 2, Mosquito, Beacon, PLR, and BTT ViViD staging.

Use it only after filling in the target machine's serial IDs:

- Main Max EZ MCU in `maxez-vivid/printer.cfg`.
- EBB42 Gen 2 MCU in `maxez-vivid/printer.cfg`.
- Beacon probe in `maxez-vivid/printer.cfg`.
- ViViD and Buffer MCUs in BTT's `bigtreetech-mms/mms/mms.cfg`.

When the Pi is reachable, run:

```bash
./maxez-vivid/install-offline.sh --host <pi-hostname-or-address>
```

The installer checks Moonraker when available and refuses to copy files if a
print is active. It copies staged files and leaves Klipper restart explicit
unless `--restart` is supplied.

In the Max EZ package, slicer calls to `PRINT_START` are routed into
`PRINT_START_PRODUCTION`, so existing start G-code can pick up the adaptive
heat-soak path without changing slicer profiles.

Install BTT MMS separately on the Pi from BTT's official repository, then copy
confirmed values from
`maxez-vivid/vivid/maxez-vivid-overrides.template.cfg` into the BTT MMS files.
Do not include that template directly.
