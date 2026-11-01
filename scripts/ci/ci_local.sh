#!/usr/bin/env bash
# Rejoue en local toutes les vérifications de la CI, dans le même ordre.
set -euo pipefail

cd "$(dirname "$0")/../.."
step() { printf '\n========== %s ==========\n' "$1"; }

step "Formatage";            cargo fmt --all -- --check
step "Clippy";               scripts/ci/clippy.sh
step "SurrealQL";            scripts/ci/validate_surql.sh
step "Auto-test du banc lyxal_core"; python3 -I scripts/ci/test_lyxal_core_selftest.py
step "Bibliothèque lyxal_core"; python3 -I scripts/ci/test_lyxal_core.py
step "Tests";                scripts/ci/test_all.sh

printf '\nToutes les vérifications sont passées.\n'
