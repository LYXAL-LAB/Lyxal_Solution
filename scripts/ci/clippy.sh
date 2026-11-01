#!/usr/bin/env bash
# Lance clippy (-D warnings) sur chaque crate du workspace, sans analyser ses dépendances internes.
set -euo pipefail

cd "$(dirname "$0")/../.."

# Crates exclus temporairement, avec la raison. Retirer une ligne dès que le crate est repris.
EXCLUDED=(
    "lyxal_pipeline_ingestion" # 13 remarques préexistantes, traitées à la reprise du module (cf. son README)
)

mapfile -t crates < <(cargo metadata --no-deps --format-version 1 \
    | python3 -I -c 'import json, sys; print("\n".join(p["name"] for p in json.load(sys.stdin)["packages"]))')

status=0
for crate in "${crates[@]}"; do
    if printf '%s\n' "${EXCLUDED[@]}" | grep -qx "${crate}"; then
        echo "== ${crate} : exclu"
        continue
    fi
    echo "== ${crate}"
    cargo clippy -p "${crate}" --no-deps --all-targets --all-features -- -D warnings || status=1
done
exit "${status}"
