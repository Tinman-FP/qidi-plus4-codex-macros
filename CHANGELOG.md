# Changelog

## 2026-06-22

- Enabled the Max EZ `hall_filament_width_sensor` on the BTT Octopus Max EZ
  `FWS` header (`PC0`/`PF10`) with flow compensation disabled for bring-up.
- Documented the Max EZ FWS connector pinout for the Qidi Hall filament width
  sensor.
- Backed off Max EZ X/Y sensorless homing one SGT increment to reduce early
  triggers.
- Increased Max EZ X/Y TMC2130 hold current to 0.70A for stronger axis hold
  during sensorless homing tests.
- Matched the Max EZ Z driver hold current to the working Qidi `.145`
  behavior and corrected Z-tilt probe points for the active Beacon offset.
- Matched the Max EZ Beacon X/Y homing order to the working Qidi `.145`
  Beacon configuration.
- Set Max EZ X/Y sensorless homing current and hold current to 0.75A during
  live CoreXY bring-up.
- Reduced Max EZ Z/Z1 hold current to 0.75A after TMC overtemp shutdown while
  leaving Z run current at 1.07A.
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
