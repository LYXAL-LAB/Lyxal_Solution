#!/usr/bin/env bash
# Contrôles de lyxal_crypto hors tests Rust :
# - contrat d'API (types sensibles : traits exigés présents, traits interdits absents) ;
# - vecteurs du format d'enveloppe enc:v2, recalculés par OpenSSL (bibliothèque Python
#   `cryptography`), indépendamment du crate.
set -euo pipefail

cd "$(dirname "$0")/../../crates/lyxal_crypto"

# check_contracts.py compile hors ligne avec le verrou de tools/contracts : dépendances d'abord.
cargo fetch --locked --manifest-path tools/contracts/Cargo.toml
python3 -I tools/check_contracts.py
python3 -I tools/check_fixtures.py
