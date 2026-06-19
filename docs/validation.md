# Validation

## Live Deployment

The adaptive production macro was installed on William Tinney's Qidi Plus 4
after Moonraker reported the printer idle:

- `print_stats=standby`
- `virtual_sdcard.is_active=False`
- `webhooks.state=ready`

Before upload, the live macro matched the expected baseline:

```text
085c8350ff1e4da14e7a29e822e9034fcfde5ffffea4c8b30a36ca756e545934  qidi_print_start_production.before_adaptive_heat_soak.cfg
```

The candidate uploaded as the active production macro:

```text
f3336628843f9e50bf5c3ab3f7af61e7b8106b3e5ef6428e667dbcf8402eccda  qidi_print_start_production.cfg
```

The printer-side backup was:

```text
qidi_print_start_production.cfg.bak_adaptive_heat_soak_before_20260619_000212
```

`configfile.save_config_pending=True` was preserved locally before restart; the
printer was not changed with `SAVE_CONFIG`.

## Post-Restart Checks

After Klipper restart:

- `webhooks.state=ready`
- `print_stats=standby`
- `virtual_sdcard.is_active=False`
- active macro SHA matched the candidate
- `variable_use_adaptive_heat_soak=1`
- `variable_heat_soak_mesh_threshold=0.015`
- `QIDI_ADAPTIVE_HEAT_SOAK_MESH` loaded
- no `G29` remained in `PRINT_START_PRODUCTION`

Verified production order:

1. initial `G28`
2. initial `Z_TILT_ADJUST`
3. adaptive heat-soak mesh loop
4. final `G28`
5. final `Z_TILT_ADJUST`
6. final `BED_MESH_CALIBRATE PROFILE=kamp`
7. nozzle clear

## Print Testing

William Tinney reported that the Qidi worked great after multiple prints using
the new code. This public release was prepared after that real-world validation.
