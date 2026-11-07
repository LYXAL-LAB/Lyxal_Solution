#!/usr/bin/env bash
# Contrôles de lyxal_crypto hors tests Rust :
# - contrat d'API (types sensibles : traits exigés présents, traits interdits absents) ;
# - vecteurs du format d'enveloppe enc:v2, recalculés par OpenSSL (bibliothèque Python
#   `cryptography`, épinglée, dans un environnement virtuel dédié), indépendamment du crate.
set -euo pipefail

CRYPTOGRAPHY_VERSION="50.0.1"

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
VENV="${ROOT}/target/crypto-checks-venv"
cd "${ROOT}/crates/lyxal_crypto"

# check_contracts.py compile hors ligne avec le verrou de tools/contracts : dépendances d'abord.
cargo fetch --locked --manifest-path tools/contracts/Cargo.toml
python3 -I tools/check_contracts.py

# Environnement virtuel : ses paquets restent visibles en mode isolé (-I), contrairement au
# répertoire utilisateur ; la version installée est exactement celle épinglée.
if [ "$("${VENV}/bin/python" -I -c 'import cryptography; print(cryptography.__version__)' 2>/dev/null || true)" != "${CRYPTOGRAPHY_VERSION}" ]; then
    python3 -m venv --clear "${VENV}"
    "${VENV}/bin/python" -I -m pip install --quiet "cryptography==${CRYPTOGRAPHY_VERSION}"
fi
"${VENV}/bin/python" -I tools/check_fixtures.py
