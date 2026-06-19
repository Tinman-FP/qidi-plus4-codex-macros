# Release Scope

Included:

- Tested adaptive `PRINT_START_PRODUCTION` macro.
- Qidi Box humidity auto helper macro.
- Pre-adaptive production-start baseline.
- Install, validation, attribution, and safety docs.
- Release checker.

Excluded:

- Full printer backups.
- `printer.cfg`.
- `gcode_macro.cfg`.
- KAMP source files.
- Beacon source files.
- `saved_variables.cfg`.
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
- Keeping baselines small makes review possible.
