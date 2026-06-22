#!/usr/bin/env python3
"""Basic public-release checks for the Qidi Plus 4 macro package."""

from __future__ import annotations

import hashlib
import pathlib
import re
import sys


ROOT = pathlib.Path(__file__).resolve().parents[1]
EXPECTED_SHA256 = {
    "macros/qidi_print_start_production.cfg": "f3336628843f9e50bf5c3ab3f7af61e7b8106b3e5ef6428e667dbcf8402eccda",
    "reference/baseline/qidi_print_start_production.before_adaptive_heat_soak.cfg": "085c8350ff1e4da14e7a29e822e9034fcfde5ffffea4c8b30a36ca756e545934",
    "macros/qidi_box_humidity_auto.cfg": "c937137b2e85da1d88b11a23caa4b94173819e7a7f42290d87f55629feba6feb",
}

REQUIRED_FILES = [
    "README.md",
    "docs/install.md",
    "docs/release-scope.md",
    "docs/validation.md",
    "macros/qidi_print_start_production.cfg",
    "macros/qidi_box_humidity_auto.cfg",
    "reference/baseline/qidi_print_start_production.before_adaptive_heat_soak.cfg",
    "maxez-vivid/README.md",
    "maxez-vivid/install-offline.sh",
    "maxez-vivid/printer.cfg",
    "maxez-vivid/config/maxez_mainsail_core.cfg",
    "maxez-vivid/config/maxez_qidi_macros.cfg",
    "maxez-vivid/config/plr.cfg",
    "maxez-vivid/config/qidi_print_start_production.cfg",
    "maxez-vivid/config/saved_variables.seed.cfg",
    "maxez-vivid/extras/gcode_shell_command.py",
    "maxez-vivid/scripts/plr/plr.sh",
    "maxez-vivid/scripts/plr/update_gcode_lines.sh",
    "maxez-vivid/scripts/plr/plr_record",
    "maxez-vivid/vivid/README.md",
    "maxez-vivid/vivid/mms-install-notes.md",
    "maxez-vivid/vivid/happy-hare-notes.md",
    "maxez-vivid/vivid/maxez-vivid-overrides.template.cfg",
]

SECRET_PATTERNS = [
    re.compile(r"192\\.168\\.\\d+\\.\\d+"),
    re.compile(r"100\\.105\\.\\d+\\.\\d+"),
    re.compile(r"/Users/"),
    re.compile(r"BEGIN [A-Z ]*PRIVATE KEY"),
    re.compile(r"sshpass", re.IGNORECASE),
    re.compile(r"password\\s*[:=]", re.IGNORECASE),
    re.compile(r"access_code", re.IGNORECASE),
    re.compile(r"api[_-]?key", re.IGNORECASE),
    re.compile(r"[0-9a-f]{2}(:[0-9a-f]{2}){5}", re.IGNORECASE),
]


def sha256(path: pathlib.Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def assert_sha_manifest() -> None:
    for rel, expected in EXPECTED_SHA256.items():
        actual = sha256(ROOT / rel)
        if actual != expected:
            raise AssertionError(f"{rel} sha256 {actual} != {expected}")


def assert_required_files() -> None:
    for rel in REQUIRED_FILES:
        path = ROOT / rel
        if not path.is_file():
            raise AssertionError(f"missing required file: {rel}")


def assert_no_private_artifacts() -> None:
    skipped = {".git"}
    for path in ROOT.rglob("*"):
        if any(part in skipped for part in path.parts):
            continue
        if not path.is_file():
            continue
        if path.name == "LICENSE":
            continue
        if path == pathlib.Path(__file__).resolve():
            continue
        text = path.read_text(errors="ignore")
        for pattern in SECRET_PATTERNS:
            match = pattern.search(text)
            if match:
                raise AssertionError(f"{path.relative_to(ROOT)} matched private pattern {pattern.pattern!r}")


def assert_adaptive_macro_shape() -> None:
    macro = (ROOT / "macros/qidi_print_start_production.cfg").read_text()
    required = [
        "variable_use_adaptive_heat_soak: 1",
        "variable_heat_soak_mesh_threshold: 0.015",
        "[gcode_macro QIDI_ADAPTIVE_HEAT_SOAK_MESH]",
        "BED_MESH_CALIBRATE PROFILE=kamp",
        "CLEAR_NOZZLE_PLR HOTEND={hotendtemp}",
    ]
    for token in required:
        if token not in macro:
            raise AssertionError(f"missing required token: {token}")
    if re.search(r"(?im)^\\s*G29\\b", macro):
        raise AssertionError("PRINT_START_PRODUCTION package must not contain a G29 command")

    def first(token: str, start: int = 0) -> int:
        idx = macro.find(token, start)
        if idx < 0:
            raise AssertionError(f"missing sequence token: {token}")
        return idx

    initial_g28 = first("G28")
    initial_z_tilt = first("Z_TILT_ADJUST", initial_g28)
    loop = first("QIDI_ADAPTIVE_HEAT_SOAK_MESH", initial_z_tilt)
    final_g28 = first("G28", loop)
    final_z_tilt = first("Z_TILT_ADJUST", final_g28)
    final_mesh = first("BED_MESH_CALIBRATE PROFILE=kamp", final_z_tilt)
    nozzle_clear = first("CLEAR_NOZZLE", final_mesh)

    if not (initial_g28 < initial_z_tilt < loop < final_g28 < final_z_tilt < final_mesh < nozzle_clear):
        raise AssertionError("adaptive production-start sequence order is wrong")


def assert_maxez_vivid_package() -> None:
    printer_cfg = (ROOT / "maxez-vivid/printer.cfg").read_text()
    required_printer_tokens = [
        "[include maxez_mainsail_core.cfg]",
        "[include maxez_qidi_macros.cfg]",
        "[include qidi_print_start_production.cfg]",
        "[include plr.cfg]",
        "serial: /dev/serial/by-id/<max-ez-main-mcu>",
        "serial: /dev/serial/by-id/<beacon-probe>",
        "EBB42 Gen2/toolhead temporarily disabled",
        "#[mcu EBB]",
        "#serial: /dev/serial/by-id/<ebb42-gen2-mcu>",
        "#[extruder]",
        "#heater_pin: EBB:PB0",
        "#sensor_pin: EBB:PA1",
        "#sensor_type: PT1000",
        "pin: PC2 #Fan 6",
        "[fan_generic auxiliary_cooling_fan]",
        "pin: PA4",
        "[fan_generic chamber_circulation_fan]",
        "pin: PA3",
    ]
    for token in required_printer_tokens:
        if token not in printer_cfg:
            raise AssertionError(f"maxez-vivid/printer.cfg missing {token!r}")

    forbidden_active_includes = [
        "box.cfg",
        "codex_qidi_box_live_candidate.cfg",
        "qidi_box_humidity_auto.cfg",
        "SO3.cfg",
        "Macros.cfg",
    ]
    for include in forbidden_active_includes:
        if re.search(rf"(?m)^\\s*\\[include\\s+{re.escape(include)}\\]", printer_cfg):
            raise AssertionError(f"legacy include is active in maxez printer.cfg: {include}")

    install_script = (ROOT / "maxez-vivid/install-offline.sh").read_text()
    required_script_tokens = [
        "print_stats",
        "virtual_sdcard",
        "Refusing to install",
        "scp",
        "gcode_shell_command.py",
    ]
    for token in required_script_tokens:
        if token not in install_script:
            raise AssertionError(f"install script missing {token!r}")

    plr_cfg = (ROOT / "maxez-vivid/config/plr.cfg").read_text()
    for token in ["[gcode_shell_command POWER_LOSS_RESUME]", "RESUME_INTERRUPTED", "profile_name"]:
        if token not in plr_cfg:
            raise AssertionError(f"PLR config missing {token!r}")

    template = (ROOT / "maxez-vivid/vivid/maxez-vivid-overrides.template.cfg").read_text()
    required_template_tokens = [
        "[mcu buffer]",
        "[mcu vivid]",
        "[mms cut]",
        "enable: 0",
        "tray_point: (95.0, 324.0)",
        "wipe_points: (58.0, 324.0), (78.0, 324.0)",
    ]
    for token in required_template_tokens:
        if token not in template:
            raise AssertionError(f"ViViD template missing {token!r}")


def main() -> int:
    assert_required_files()
    assert_sha_manifest()
    assert_no_private_artifacts()
    assert_adaptive_macro_shape()
    assert_maxez_vivid_package()
    print("release checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
