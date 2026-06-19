# Security And Safety

These files can move a real 3D printer. Review before use.

## Before Installing

- Back up the current printer config.
- Confirm the printer is idle.
- Confirm `virtual_sdcard.is_active` is false.
- Do not restart Klipper during an active or paused print.
- Save any pending `SAVE_CONFIG` data locally before restarting if you do not
  intend to run `SAVE_CONFIG`.
- Compare the macro dependencies in your config before replacing anything.

## Do Not Publish

Do not publish or paste:

- SSH passwords.
- Moonraker tokens.
- Private IPs if they matter in your environment.
- `saved_variables.cfg`.
- Full live printer backups.
- Raw logs with serials or paths.

## Reporting Issues

Open a GitHub issue with:

- Printer model and firmware/config baseline.
- Which file you installed.
- Exact macro parameters used.
- Whether KAMP/adaptive mesh, Beacon/probe, `Z_TILT_ADJUST`, and Qidi chamber
  macros exist on your machine.
- The relevant Klipper error text.

Do not include credentials, full logs, or full machine backups in public issues.
