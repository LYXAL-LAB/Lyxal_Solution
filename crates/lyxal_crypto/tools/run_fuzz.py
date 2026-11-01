#!/usr/bin/env python3
"""Build and run four bounded coverage-guided campaigns, keeping actual exit status.

Requires cargo-fuzz, nightly and an execution context allowing LeakSanitizer to finish.
Never suppresses sanitizer checks or treats an environment failure as a successful run.
"""
import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import time

CRATE = Path(__file__).resolve().parents[1]
FUZZ = CRATE / "fuzz"
TARGETS = ("envelope", "context", "phc", "rotation")
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--seconds", type=int, default=1800)
parser.add_argument("--segments", type=int, default=3,
                    help="checkpoint the total duration into this many independently completed runs")
args = parser.parse_args()
if args.segments < 1 or args.seconds < args.segments:
    parser.error("--seconds must be >= --segments >= 1")
subprocess.run(["cargo", "+nightly", "fuzz", "build"], cwd=CRATE, check=True)
output = FUZZ / "target" / "campaigns" / str(time.time_ns())
output.mkdir(parents=True)


def campaign(name):
    corpus = FUZZ / "corpus" / name
    artifacts = FUZZ / "artifacts" / name
    corpus.mkdir(parents=True, exist_ok=True)
    artifacts.mkdir(parents=True, exist_ok=True)
    for seed in (FUZZ / "seeds").glob(name + "*"):
        shutil.copyfile(seed, corpus / seed.name)
    binary = FUZZ / "target/x86_64-unknown-linux-gnu/release" / name
    base_command = [str(binary), str(corpus),
               "-timeout=10", "-rss_limit_mb=2048", "-print_final_stats=1",
               "-max_len=" + ("1500000" if name in ("envelope", "context") else "8192"),
               "-artifact_prefix=" + str(artifacts) + "/"]
    fingerprint = hashlib.sha256(binary.read_bytes()).hexdigest()
    for segment in range(args.segments):
        seconds = args.seconds // args.segments + (segment < args.seconds % args.segments)
        command = base_command + [f"-max_total_time={seconds}"]
        started = time.time()
        stem = f"{name}-{segment + 1}"
        with (output / (stem + ".log")).open("w") as log:
            result = subprocess.run(command, cwd=CRATE, stdout=log, stderr=subprocess.STDOUT)
        record = {"target": name, "segment": segment + 1, "requested_seconds": seconds,
                  "command": command, "start_unix": started,
                  "end_unix": time.time(), "exit_code": result.returncode,
                  "binary_sha256": fingerprint}
        (output / (stem + ".json")).write_text(json.dumps(record, indent=2))
        print(f"{stem}: exit {result.returncode}; evidence {output}", flush=True)
        if result.returncode:
            return result.returncode
    return 0


with ThreadPoolExecutor(max_workers=4) as pool:
    outcomes = list(pool.map(campaign, TARGETS))
raise SystemExit(0 if all(code == 0 for code in outcomes) else 1)
