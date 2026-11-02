#!/usr/bin/env bash
# Lance tous les tests du workspace, y compris ceux qui exigent un vrai serveur SurrealDB 3.3.4.
#
# Démarre deux serveurs en mémoire, avec des identifiants générés pour cette exécution :
#   - serveur de recette sur 127.0.0.1:8001 (tests « serveur réel » de lyxal_pipeline_ingestion) ;
#   - serveur ws:// pour le test de connexion distante de lyxal_surreal.
set -euo pipefail

cd "$(dirname "$0")/../.."
SURREAL="${LYXAL_SURREAL_BIN:-$(command -v surreal)}"
export LYXAL_SURREAL_BIN="${SURREAL}"

random_secret() { python3 -I -c 'import secrets; print(secrets.token_urlsafe(24))'; }

STAGING_PORT=8001
WS_PORT="${LYXAL_TEST_WS_PORT:-8765}"
export LYXAL_STAGING_USER="stg_$(random_secret | tr -dc 'a-z0-9' | head -c 8)"
export LYXAL_STAGING_PASS="$(random_secret)"
export LYXAL_SURREAL_USER="root"
export LYXAL_SURREAL_PASS="$(random_secret)"
export LYXAL_SURREAL_WS_URL="ws://127.0.0.1:${WS_PORT}"

pids=()
cleanup() { for pid in "${pids[@]}"; do kill "${pid}" 2>/dev/null || true; done; }
trap cleanup EXIT

start_server() { # port utilisateur mot_de_passe
    "${SURREAL}" start --log error --user "$2" --pass "$3" --bind "127.0.0.1:$1" memory >/dev/null 2>&1 &
    pids+=("$!")
    # Échéance en secondes, pas en tentatives : chaque appel à `surreal` passe par le lanceur de l'installateur.
    local deadline=$((SECONDS + 30))
    while (( SECONDS < deadline )); do
        if "${SURREAL}" is-ready --endpoint "http://127.0.0.1:$1" >/dev/null 2>&1; then return 0; fi
        sleep 0.2
    done
    echo "Le serveur SurrealDB du port $1 n'a pas démarré en 30 s." >&2
    return 1
}

start_server "${STAGING_PORT}" "${LYXAL_STAGING_USER}" "${LYXAL_STAGING_PASS}"
start_server "${WS_PORT}" "${LYXAL_SURREAL_USER}" "${LYXAL_SURREAL_PASS}"

cargo test --workspace --no-fail-fast

# Tests ignorés par défaut parce qu'ils exigent un serveur ou sont longs, désignés par leur nom exact.
# Une seule commande sur le workspace : pas de recompilation de SurrealDB avec d'autres fonctionnalités.
# (Les tests ignorés de lyxal_crypto sont des sous-processus lancés par d'autres tests : ils ne sont pas visés.)
cargo test --workspace -- --ignored --exact \
    call_tests::test_remote_ws_root_signin_and_call_fn
