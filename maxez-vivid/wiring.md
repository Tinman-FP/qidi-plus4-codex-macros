# Max EZ Nebula / EBB42 Gen2 Wiring

This file records the wiring target for the Qidi Plus 4 Max EZ conversion using
the BTT Max EZ main board, BTT EBB42 Gen2 toolboard, BIQU Nebula extruder,
Slice Engineering Mosquito hotend, Beacon probe, and Qidi Hall filament width
sensor.

## Source References

- Nebula wiki: <https://global.bttwiki.com/Nebula.html>
- Nebula manual: <https://github.com/bigtreetech/Nebula/blob/master/Manual/Nebula%20User%20Manual20250603.pdf>
- Nebula Klipper example: <https://github.com/bigtreetech/Nebula/blob/master/Firmware/Klipper/nebula.cfg>
- EBB42 Gen2 docs: <https://github.com/bigtreetech/docs/blob/master/docs/EBB42_GEN2.md>
- EBB42 Gen2 sample config: <https://github.com/bigtreetech/EBB/blob/master/EBB_GEN2/EBB42_GEN2/sample-bigtreetech-ebb42-gen2-v1.0.cfg>
- EBB42 Gen2 pinout: <https://github.com/bigtreetech/EBB/blob/master/EBB_GEN2/EBB42_GEN2/Hardware/EBB42_GEN2_pin_en.jpg>
- BTT Octopus Max EZ Klipper config: <https://github.com/Klipper3d/klipper/blob/master/config/generic-bigtreetech-octopus-max-ez.cfg>

## Nebula RGB, Button, And Filament Switch Mapping

The Nebula 5-pin connector is labeled, left to right in the official manual:

| Nebula pin | Nebula function | Wire to EBB42 Gen2 | Klipper pin |
| --- | --- | --- | --- |
| `5V` | 5 V input | RGB header 5 V / VCC | n/a |
| `GND` | Ground | RGB header GND | n/a |
| `FS` | Filament sensor signal | `FIL` header signal | `EBB:PA3` |
| `GB` | G-code button signal | `ENDSTOP` header signal | `EBB:PA2` |
| `RGB` | RGB data input | RGB header data | `EBB:PB14` |

Use a common ground between the RGB, `FIL`, and `ENDSTOP` signals. Do not wire
the Nebula control connector to 24 V.

The optional software template is:

```text
maxez-vivid/config/nebula_controls.template.cfg
```

It follows BTT's Nebula example behavior:

- RGB is configured as `[neopixel nebula_neopixel]`.
- `GB` is configured as `[gcode_button nebula_unload_button]`.
- `FS` is configured as `[gcode_button nebula_filament_sensor]`.
- Filament insertion can call `NEBULA_LOAD_FILAMENT`.
- The button can call `NEBULA_UNLOAD_FILAMENT`.

Enable that template only after the physical Nebula control harness is wired
and the input states are verified.

## EBB42 Gen2 Used Pins

| Function | EBB42 Gen2 header / signal | Klipper pin | Current status |
| --- | --- | --- | --- |
| EBB MCU | USB or CAN via adapter | `[mcu EBB]` | Active placeholder |
| EBB board temp | Driver temp thermistor | `EBB:PA0` | Active |
| Nebula extruder step | Motor driver STEP | `EBB:PD3` | Active |
| Nebula extruder direction | Motor driver DIR | `EBB:PD2` | Active |
| Nebula extruder enable | Motor driver EN | `!EBB:PB6` | Active |
| Nebula extruder UART | TMC2209 UART | `EBB:PB3` | Active |
| Mosquito heater | `HE` output | `EBB:PB0` | Active |
| Mosquito PT1000 | `TH` input | `EBB:PA1` | Active |
| Nebula RGB data | RGB header data | `EBB:PB14` | Optional |
| Nebula RGB power | RGB header 5 V / VCC | n/a | Optional |
| Nebula RGB ground | RGB header GND | n/a | Optional |
| Nebula filament signal | `FIL` header signal | `EBB:PA3` | Optional |
| Nebula button signal | `ENDSTOP` header signal | `EBB:PA2` | Optional |

EBB42 Gen2 pins intentionally left unused in this build:

| Header / function | Pins | Reason |
| --- | --- | --- |
| FAN0 | `EBB:PB8` | No fans on EBB42 per build requirement |
| FAN1 | `EBB:PB15` | No fans on EBB42 per build requirement |
| FAN2 / tach | `EBB:PB4`, `EBB:PB9` | No fans on EBB42 per build requirement |
| Probe servo/sensor | `EBB:PA4`, `EBB:PA5` | Beacon is USB, not wired to EBB probe |
| I2C | `EBB:PA9`, `EBB:PA10` | No EBB I2C accessory assigned |
| LIS2DW accelerometer | `EBB:PB1`, `EBB:PB2`, `EBB:PB10`, `EBB:PB11` | Beacon is the active resonance accelerometer |

## BTT Max EZ Used Pins

| Function | Max EZ signal | Klipper pin |
| --- | --- | --- |
| X step | Motor-1 STEP | `PC13` |
| X direction | Motor-1 DIR | `!PC14` |
| X enable | Motor-1 EN | `!PE6` |
| X sensorless/TMC CS | Motor-1 CS | `PG14` |
| X sensorless/TMC DIAG | Motor-1 DIAG | `^!PF0` |
| Y step | Motor-2 STEP | `PE4` |
| Y direction | Motor-2 DIR | `!PE5` |
| Y enable | Motor-2 EN | `!PE3` |
| Y sensorless/TMC CS | Motor-2 CS | `PG13` |
| Y sensorless/TMC DIAG | Motor-2 DIAG | `^!PF2` |
| Z step | Motor-3 STEP | `PE1` |
| Z direction | Motor-3 DIR | `PE0` |
| Z enable | Motor-3 EN | `!PE2` |
| Z TMC CS | Motor-3 CS | `PG12` |
| Z TMC DIAG | Motor-3 DIAG | `PF4` |
| Z1 step | Motor-4 STEP | `PB8` |
| Z1 direction | Motor-4 DIR | `PB9` |
| Z1 enable | Motor-4 EN | `!PB7` |
| Z1 TMC CS | Motor-4 CS | `PG11` |
| Z1 TMC DIAG | Motor-4 DIAG | `PF3` |
| Bed heater | Bed MOSFET | `PF5` |
| Bed thermistor | `TB` | `PB1` |
| Hotend fan | Fan 6 | `PC2` |
| Auxiliary cooling fan | Fan output | `PA4` |
| Chamber circulation fan | Fan output | `PA3` |
| Chamber heater | Heater output | `PA5` |
| Chamber thermistor | Thermistor input | `PC5` |
| Chamber heater fan | Fan output | `PA6` |
| Hall filament width ADC1 | FWS `P2` pin 2 | `PC0` |
| Hall filament width ADC2 | FWS `P2` pin 1 | `PF10` |

Max EZ pins present in the config but intentionally disabled or unused:

| Function | Pins | Status |
| --- | --- | --- |
| Legacy filament switch 0 | `PF1` | Disabled |
| Legacy filament switch 1 | `PC15` | Disabled |
| Optional chamber light | `PC7` | Disabled |
| Optional auxiliary output | `PF12` | Disabled |
| Optional main-board neopixel 1 | `PE10` | Disabled |
| Optional main-board neopixel 2 | `PE9` | Disabled |

Beacon is connected as a USB device and is not assigned to a BTT Max EZ GPIO
pin in this build.

## Physical Bring-Up Notes

- Verify the Z1 motor circuit before running `Z_TILT_ADJUST`; an open-load
  fault on Motor-4/Z1 will prevent tilt convergence.
- Keep the EBB fan ports unused unless the build requirement changes.
- Check the EBB42 thermistor jumper before using the PT1000.
- Verify Nebula `FS` and `GB` states with `QUERY_BUTTON` or by watching the
  matching `gcode_button` object before relying on auto-load or auto-unload.
