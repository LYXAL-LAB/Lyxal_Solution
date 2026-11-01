#!/usr/bin/env bash
# Installe le binaire `surreal` à la version de référence du workspace (SurrealDB 3.3.4).
# Sans effet si la bonne version est déjà présente dans le PATH.
set -euo pipefail

VERSION="${SURREAL_VERSION:-3.3.4}"

if command -v surreal >/dev/null 2>&1 && surreal version | grep -q "^${VERSION} "; then
    echo "surreal ${VERSION} déjà installé : $(command -v surreal)"
    exit 0
fi

curl -sSf https://install.surrealdb.com | sh -s -- --version "v${VERSION}"

# L'installateur place le binaire dans /usr/local/bin s'il est accessible en écriture, sinon dans ~/.surrealdb.
if [ -x "${HOME}/.surrealdb/surreal" ]; then
    export PATH="${HOME}/.surrealdb:${PATH}"
    if [ -n "${GITHUB_PATH:-}" ]; then
        echo "${HOME}/.surrealdb" >> "${GITHUB_PATH}"
    fi
fi

surreal version | grep -q "^${VERSION} " || {
    echo "Version de surreal inattendue : $(surreal version)" >&2
    exit 1
}
echo "surreal ${VERSION} installé : $(command -v surreal)"
