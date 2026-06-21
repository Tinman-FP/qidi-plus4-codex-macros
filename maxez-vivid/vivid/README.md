# ViViD Bring-Up Notes

This folder stages the BTT ViViD path for the Max EZ build. It is intentionally
not an active include in `printer.cfg` yet because the ViViD and Buffer serial
IDs, entry sensor wiring, cutter path, bowden length, and purge/brush positions
must be confirmed on the actual machine.

Recommended first bring-up path:

1. Install the Max EZ package and confirm the base Klipper config parses.
2. Install BTT MMS on the Pi from the official `BIGTREETECH_MMS` repository.
3. Configure the BTT-provided `bigtreetech-mms/mms/mms.cfg` serial IDs.
4. Copy only the confirmed values from `maxez-vivid-overrides.template.cfg`.
5. Restart Klipper with hardware attached and validate one module at a time.

Do not install BTT MMS and Happy Hare as active MMU controllers at the same
time. The BTT MMS stack is the conservative first bring-up choice because it
ships with BTT's ViViD-specific config and installer. Happy Hare remains the
stronger universal MMU abstraction if we decide to migrate after basic ViViD
motion, sensors, and drying are proven.
