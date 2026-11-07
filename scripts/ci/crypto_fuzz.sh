#!/usr/bin/env bash
# Campagne de fuzzing de lyxal_crypto (4 cibles, LeakSanitizer actif) : outillage épinglé,
# installé s'il manque. Usage : scripts/ci/crypto_fuzz.sh [secondes par cible, défaut 60]
set -euo pipefail

# Outillage épinglé (mêmes versions en local et en CI).
NIGHTLY="nightly-2026-10-20"
CARGO_FUZZ_VERSION="0.13.2"
SECONDS_PER_TARGET="${1:-60}"

cd "$(dirname "$0")/../.."

rustup toolchain list | grep -q "^${NIGHTLY}" || rustup toolchain install "${NIGHTLY}" --profile minimal
if [ "$(cargo fuzz --version 2>/dev/null || true)" != "cargo-fuzz ${CARGO_FUZZ_VERSION}" ]; then
    cargo install cargo-fuzz --version "${CARGO_FUZZ_VERSION}" --locked --force
fi

# Une session continue par cible ; tout échec, y compris du sanitizer, fait échouer le script.
python3 -I crates/lyxal_crypto/tools/run_fuzz.py \
    --seconds "${SECONDS_PER_TARGET}" --segments 1 --toolchain "${NIGHTLY}"
