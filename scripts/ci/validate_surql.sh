#!/usr/bin/env bash
# Valide la syntaxe de tous les fichiers SurrealQL du workspace (crates/ et apps/) avec `surreal validate`.
set -euo pipefail

cd "$(dirname "$0")/../.."
SURREAL="${LYXAL_SURREAL_BIN:-surreal}"

mapfile -d '' files < <(find crates apps -name '*.surql' -not -path '*/target/*' -print0 | sort -z)
failed=()
for file in "${files[@]}"; do
    if ! "${SURREAL}" validate "${file}" >/dev/null 2>&1; then
        failed+=("${file}")
    fi
done

echo "SurrealQL : ${#files[@]} fichiers, ${#failed[@]} en échec ($("${SURREAL}" version))."
if [ "${#failed[@]}" -gt 0 ]; then
    for file in "${failed[@]}"; do
        echo "::error file=${file}::surreal validate a échoué"
        "${SURREAL}" validate "${file}" 2>&1 | grep -v -E '^\s+[0-9]+:|^\s+at ' | head -8 || true
    done
    exit 1
fi
