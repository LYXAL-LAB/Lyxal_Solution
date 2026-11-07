#!/usr/bin/env bash
# Rejoue en local toutes les vérifications de la CI, dans le même ordre.
# --fuzz : ajoute la campagne courte de fuzzing de lyxal_crypto (workflow crypto-fuzz.yml),
# qui installe au besoin Rust nightly et cargo-fuzz épinglés.
set -euo pipefail

FUZZ=0
for arg in "$@"; do
    case "${arg}" in
        --fuzz) FUZZ=1 ;;
        *) echo "option inconnue : ${arg}" >&2; exit 2 ;;
    esac
done

cd "$(dirname "$0")/../.."
step() { printf '\n========== %s ==========\n' "$1"; }

step "Formatage";            cargo fmt --all -- --check
step "Clippy";               scripts/ci/clippy.sh
step "SurrealQL";            scripts/ci/validate_surql.sh
step "Auto-test du banc lyxal_core"; python3 -I scripts/ci/test_lyxal_core_selftest.py
step "Bibliothèque lyxal_core"; python3 -I scripts/ci/test_lyxal_core.py
step "Tests SurrealQL des modules"; python3 -I scripts/ci/test_lyxal_modules.py
step "Cryptographie";        scripts/ci/crypto_checks.sh
step "Tests";                scripts/ci/test_all.sh
if [ "${FUZZ}" = 1 ]; then
    step "Fuzzing de lyxal_crypto"; scripts/ci/crypto_fuzz.sh 60
fi

printf '\nToutes les vérifications sont passées.\n'
