# Happy Hare Option

Happy Hare supports many Klipper MMU systems, including VVD/ViViD-style
hardware. It is a good migration candidate if we want a broader MMU framework
after the ViViD hardware is electrically proven.

For this machine, keep Happy Hare inactive during first ViViD bring-up:

- BTT MMS is purpose-built around BTT's ViViD and Buffer config files.
- The Max EZ printer config is already being changed for a new MCU, EBB42 Gen
  2, Nebula extruder, Beacon workflow, Mosquito hotend, and PLR macros.
- Running one MMU control stack at a time keeps failure diagnosis cleaner.

If we migrate later, the Happy Hare work should be a separate branch with its
own generated MMU config, tool map, parking/cut/purge validation, and slicer
tool-change review.
