# Attribution

This repository was prepared so the Qidi Plus 4 macro work can be public,
useful, and properly credited.

## Project Credits

| Contributor | Credit |
| --- | --- |
| William Tinney / Tinman-FP | Project owner, printer operator, requirements, live-machine testing, repeated print validation, and release approval. |
| OpenAI Codex | Assisted with implementation, safety checks, source organization, documentation, validation scripts, and GitHub publishing workflow. |

## Upstream And Reference Sources

| Source | URL | How it was used |
| --- | --- | --- |
| QIDI Plus4 official repository | <https://github.com/QIDITECH/QIDI_PLUS4> | Vendor firmware/config reference and standard Qidi macro behavior comparison. |
| QIDI Klipper fork | <https://github.com/QIDITECH/klipper> | Vendor-modified Klipper lineage for Qidi machines. |
| Klipper | <https://github.com/Klipper3d/klipper> | Firmware and macro language foundation. |
| Klipper documentation | <https://www.klipper3d.org/> | Macro, bed mesh, heater, restart, and configuration behavior reference. |
| Moonraker | <https://github.com/Arksine/moonraker> | API/control plane used for safe status checks, config upload/download, and restart verification. |
| KAMP | <https://github.com/kyleisah/Klipper-Adaptive-Meshing-Purging> | Adaptive mesh/purge concept and the `PROFILE=kamp` mesh workflow assumed by the production macro. |
| Beacon | <https://github.com/beacon3d/beacon_klipper> | Probe ecosystem context for Beacon-style mesh behavior on the tested machine. |
| BIGTREETECH EBB | <https://github.com/bigtreetech/EBB> | EBB42 Gen2 pinout, sample configuration, and toolboard wiring reference for the Max EZ conversion. |
| BIGTREETECH Nebula | <https://github.com/bigtreetech/Nebula> | Nebula extruder connector labels, RGB/button/filament behavior, rotation distance, and optional Klipper control template reference. |
| BIGTREETECH MMS | <https://github.com/bigtreetech/BIGTREETECH_MMS> | ViViD/Buffer install and configuration reference for the Max EZ staging package. |
| BIGTREETECH ViViD wiki | <https://global.bttwiki.com/BIGTREETECH_ViViD.html> | ViViD hardware and ecosystem reference. |
| Happy Hare | <https://github.com/moggieuk/Happy-Hare> | Alternative Python 3 Klipper MMU framework considered for later migration. |
| `gcode_shell_command.py` by Eric Callahan | <https://github.com/Arksine/moonraker> | GPLv3 shell-command Klipper extra used by the staged PLR macros. |

## Local Provenance

The adaptive heat-soak release was derived from William Tinney's live Qidi Plus
4 production macro after these prior fixes were already working:

- Chamber circulation fan starts before bed/nozzle/chamber heat-up.
- Startup `G28` and `Z_TILT_ADJUST` run before mesh work.
- The post-wipe crash-causing motion path was removed.
- The chamber heater cap had already been moved to 60 percent.

The public macro was applied only after Moonraker reported:

- `print_stats=standby`
- `virtual_sdcard.is_active=False`
- `webhooks.state=ready`

The live macro was backed up on the printer before replacement.

## What Is Not Included

This public release intentionally excludes:

- SSH credentials.
- Private LAN addresses.
- Full live printer backups.
- `saved_variables.cfg`.
- Real MCU serial IDs.
- Moonraker secrets or access tokens.
- Raw logs.
- G-code test output.
- Raw chat transcripts.
- Other printers' configuration files.
