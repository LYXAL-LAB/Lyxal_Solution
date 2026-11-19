#!/usr/bin/env bash
# Installe `cargo-deny` à la version épinglée du workspace (contrôle des licences, deny.toml).
# Sans effet si la bonne version est déjà présente.
set -euo pipefail

VERSION="${CARGO_DENY_VERSION:-0.21.0}"

if cargo deny --version 2>/dev/null | grep -q "^cargo-deny ${VERSION}$"; then
    echo "cargo-deny ${VERSION} déjà installé : $(command -v cargo-deny)"
    exit 0
fi

cargo install cargo-deny --version "${VERSION}" --locked

cargo deny --version | grep -q "^cargo-deny ${VERSION}$" || {
    echo "Version de cargo-deny inattendue : $(cargo deny --version)" >&2
    exit 1
}
echo "cargo-deny ${VERSION} installé : $(command -v cargo-deny)"
