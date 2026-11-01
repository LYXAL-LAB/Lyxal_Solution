#!/usr/bin/env python3
"""Run the scoped production checks; write actual outcomes, never inferred success.

Run from an execution context permitting local Unix IPC for the socket test.
Requires Rust 1.85.0 plus clippy/rustfmt on the current toolchain.
"""
import json
import os
from pathlib import Path
import subprocess
import time

CRATE = Path(__file__).resolve().parents[1]
WORKSPACE = CRATE.parent.parent
OUTPUT = CRATE / "target" / "validation"
OUTPUT.mkdir(parents=True, exist_ok=True)
records = []
sources = sorted(str(p) for folder in ["src", "tests", "fuzz/fuzz_targets"]
                 for p in (CRATE / folder).rglob("*.rs"))
checks = [
    ("fmt", ["rustfmt", "--edition", "2021", "--check", *sources], {}),
    ("tests", ["cargo", "test", "--offline", "--locked", "-p", "lyxal_crypto", "--all-targets"], {}),
    ("doctests", ["cargo", "test", "--offline", "--locked", "-p", "lyxal_crypto", "--doc"], {}),
    ("clippy", ["cargo", "clippy", "--offline", "--locked", "-p", "lyxal_crypto", "--all-targets", "--", "-D", "warnings"], {}),
    ("docs", ["cargo", "doc", "--offline", "--locked", "-p", "lyxal_crypto", "--no-deps"], {"RUSTDOCFLAGS": "-D warnings"}),
    ("msrv-tests", ["cargo", "+1.85.0", "test", "--offline", "--locked", "-p", "lyxal_crypto", "--all-targets"], {}),
    ("msrv-doctests", ["cargo", "+1.85.0", "test", "--offline", "--locked", "-p", "lyxal_crypto", "--doc"], {}),
    ("contracts", ["python3", str(CRATE / "tools/check_contracts.py")], {}),
    ("msrv-contracts", ["python3", str(CRATE / "tools/check_contracts.py")], {"RUSTUP_TOOLCHAIN": "1.85.0"}),
]
for name, command, extra in checks:
    started = time.time()
    environment = os.environ.copy()
    environment.update(extra)
    with (OUTPUT / (name + ".log")).open("w") as log:
        result = subprocess.run(command, cwd=WORKSPACE, env=environment, stdout=log, stderr=subprocess.STDOUT)
    records.append({"name": name, "command": command, "exit_code": result.returncode,
                    "seconds": round(time.time() - started, 3), "log": name + ".log"})
    (OUTPUT / "checks.json").write_text(json.dumps(records, indent=2))
    print(f"{name}: exit {result.returncode}", flush=True)
    if result.returncode:
        raise SystemExit(result.returncode)
