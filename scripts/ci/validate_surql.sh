#!/usr/bin/env bash
# Valide la syntaxe de tous les fichiers SurrealQL du workspace (crates/ et apps/) avec `surreal validate`,
# puis refuse toute déclaration `LET` d'un nom de variable réservé par SurrealDB 4.0.
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

# Noms réservés : SurrealDB 4.0 refuse une fonction ou un bloc qui déclare `LET $event`, `$before`,
# `$after`, `$value`, `$input`, `$parent`, `$self` ou `$this` (la 3.3.4 l'accepte encore). Lire ces
# variables là où la base les fournit reste permis. Les commentaires et les chaînes sont ignorés.
printf '%s\0' "${files[@]}" | python3 -I -c '
import re, sys

RESERVED = re.compile(r"\bLET\s+\$(event|before|after|value|input|parent|self|this)\b", re.IGNORECASE)
# Une chaîne (guillemets doubles ou simples, échappements compris) ou un commentaire de fin de ligne.
NOISE = re.compile(r"\"(?:\\.|[^\"\\])*\"|\x27(?:\\.|[^\x27\\])*\x27|--.*|//.*")

found = 0
for path in filter(None, sys.stdin.read().split("\0")):
    with open(path, encoding="utf-8") as handle:
        for number, line in enumerate(handle, 1):
            match = RESERVED.search(NOISE.sub(lambda m: "" if m.group(0)[0] in "-/" else "\"\"", line))
            if match:
                found += 1
                name = match.group(1).lower()
                print(f"::error file={path},line={number}::{path}:{number} : LET ${name} est interdit "
                      f"(nom réservé, refusé par SurrealDB 4.0) ; renommer la variable locale.")
print(f"Noms réservés : {found} déclaration(s) LET interdite(s).")
sys.exit(1 if found else 0)
'
