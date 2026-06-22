# Changelog

## 2026-06-22

- Updated the Max EZ Mosquito hotend template to use the live-verified
  Slice RTD Pt1000 on the EBB42 Gen 2 thermistor input.
- Published the `maxez-vivid/printer.cfg` template by adding a scoped
  `.gitignore` exception for that public placeholder config.

## 2026-06-21

- Added `maxez-vivid/` offline staging package for the Qidi Plus 4 Max EZ
  conversion to Nebula, EBB42 Gen 2, Mosquito, Beacon, PLR, and BTT ViViD.
- Added Pi copy script with Moonraker active-print guard.
- Added ViViD/BTT MMS bring-up notes and staged override template.
- Expanded validation and release-scope checks for the new Max EZ package.

## 2026-06-19

- Public initial release.
- Added tested `qidi_print_start_production.cfg` adaptive heat-soak macro.
- Added `qidi_box_humidity_auto.cfg` helper macro.
- Added pre-adaptive `PRINT_START_PRODUCTION` baseline for review.
- Added professional README, install guide, validation notes, attribution,
  notice, security policy, and release checker.
