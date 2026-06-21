# BTT MMS Install Notes For Max EZ

The official BTT MMS flow installs the ViViD support files under the Klipper
config tree and then includes:

```ini
[include bigtreetech-mms/mms/mms.cfg]
```

Use BTT's installer on the Pi after network access returns:

```bash
cd ~
git clone https://github.com/bigtreetech/BIGTREETECH_MMS.git
cd ~/BIGTREETECH_MMS
./install.sh
```

After install, set the actual serial IDs in the BTT MMS config:

```ini
[mcu buffer]
serial: /dev/serial/by-id/<vivid-buffer-mcu>

[mcu vivid]
serial: /dev/serial/by-id/<vivid-main-mcu>
```

Max EZ-specific bring-up checkpoints:

- The base printer config already owns the Max EZ fans and maps Qidi-style
  `M106` to `auxiliary_cooling_fan` and `chamber_circulation_fan`.
- The EBB42 Gen 2 has no assigned fans in this build.
- Configure `entry_sensor` only after the real sensor pin is wired and tested.
- Keep `[mms cut] enable: 0` until the real cutter path is mounted and safe.
- The first purge/brush values should be treated as supervised coordinates,
  not unattended production settings.
- The ViViD dryer and Buffer sensors live in the BTT MMS config, not in this
  Max EZ base `printer.cfg`.

BTT's README currently states the MMS stack targets Klipper in the newer
Python 3 environment. That is the key reason this path is preferred over the
legacy Qidi Box binary extras for the fresh Pi.
