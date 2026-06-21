# Release Scope

Included:

- Tested adaptive `PRINT_START_PRODUCTION` macro.
- Qidi Box humidity auto helper macro.
- Pre-adaptive production-start baseline.
- Staged Max EZ `printer.cfg` package for Nebula, EBB42 Gen 2, Mosquito,
  Beacon, PLR, and ViViD bring-up.
- Install, validation, attribution, and safety docs.
- Release checker.

Excluded:

- Full printer backups.
- Live-machine `printer.cfg` files with real serial IDs.
- `gcode_macro.cfg`.
- KAMP source files.
- Beacon source files.
- Live `saved_variables.cfg`.
- Moonraker config.
- Private LAN addresses.
- SSH credentials.
- Logs.
- G-code output.
- Scratch experiments and aborted variants.

Why this scope:

- The public repo should expose the reusable Qidi work without leaking machine
  secrets or unrelated printer history.
- The adaptive macro depends on existing Qidi/Klipper/KAMP/Beacon-style
  behavior, but it does not need to vendor those upstream projects.
- The Max EZ package is staged with placeholders so the software work can be
  reviewed and uploaded later without publishing machine identifiers.
- Keeping baselines small makes review possible.
