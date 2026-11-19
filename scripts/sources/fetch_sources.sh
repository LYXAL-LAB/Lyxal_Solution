#!/usr/bin/env bash
# Récupère les sources de travail du programme courrier, agendas et contacts, aux commits
# figés par la décision C2 (crates/lyxal_mail/implementation_plan.md), dans `.sources/<nom>/`.
#
# `.sources/` est ignoré par Git : les sources ne sont jamais versées dans le dépôt.
# Le script ne fait que cloner et vérifier : il n'exécute, ne compile et n'installe rien de ce
# qu'il récupère (aucun hook, aucun sous-module, aucun filtre). Après le clone de Stalwart, il
# lance `strip_sel.py`, qui retire le code sous licence Entreprise (décisions F5 et C3) : seule
# cette copie triée sert de source aux lots suivants.
#
# Rejouable : une source déjà présente au bon commit n'est pas reclonée ; une source présente
# à un autre commit arrête le script (la supprimer à la main pour la recloner).
#
# Usage :
#   scripts/sources/fetch_sources.sh [--from <dossier>] [nom ...]
#     --from <dossier>  clone depuis des dépôts locaux `<dossier>/<nom>` (miroir hors ligne)
#                       au lieu de GitHub ; le commit est vérifié de la même façon.
#     nom               limite aux sources citées (stalwart, mox, rustical, sabre_dav).
#
# Changer un commit figé est un changement comme un autre (décision P14) : plan, `SOURCES.md`
# mis à jour, validation du CTO.
set -euo pipefail

cd "$(dirname "$0")/../.."
ROOT="$(pwd)"
DEST="${ROOT}/.sources"

# nom | URL publique | commit figé | licence déclarée par le projet
SOURCES=(
    "stalwart|https://github.com/stalwartlabs/stalwart|3adead91f3c87e7415b58c9ed8e6ec05a5dda521|AGPL-3.0-only OR LicenseRef-SEL"
    "mox|https://github.com/mjl-/mox|b32f0def9763b2644ad7bd1e8b3894786e80858b|MIT"
    "rustical|https://github.com/lennart-k/rustical|0698bb6b89b51207652eb60973a86364c3446ecb|AGPL-3.0-or-later"
    "sabre_dav|https://github.com/sabre-io/dav|be1d58d6bce7ca33313b02909f9088c93c35db02|BSD-3-Clause"
)

FROM=""
WANTED=()
while [ "$#" -gt 0 ]; do
    case "$1" in
        --from)
            [ "$#" -ge 2 ] || { echo "--from demande un dossier" >&2; exit 2; }
            FROM="$(cd "$2" && pwd)"; shift 2 ;;
        -h|--help) sed -n '2,24p' "$0"; exit 0 ;;
        -*) echo "option inconnue : $1" >&2; exit 2 ;;
        *) WANTED+=("$1"); shift ;;
    esac
done

# Git sans configuration de l'utilisateur ni du système, sans hooks, sans invite.
safe_git() {
    GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null GIT_TERMINAL_PROMPT=0 \
        git -c core.hooksPath=/dev/null -c advice.detachedHead=false -c protocol.file.allow=always "$@"
}

wanted() {
    [ "${#WANTED[@]}" -eq 0 ] && return 0
    local item
    for item in "${WANTED[@]}"; do [ "${item}" = "$1" ] && return 0; done
    return 1
}

for item in "${WANTED[@]}"; do
    known=0
    for entry in "${SOURCES[@]}"; do [ "${entry%%|*}" = "${item}" ] && known=1; done
    [ "${known}" = 1 ] || { echo "source inconnue : ${item}" >&2; exit 2; }
done

mkdir -p "${DEST}"
for entry in "${SOURCES[@]}"; do
    IFS='|' read -r name url commit licence <<< "${entry}"
    wanted "${name}" || continue
    dir="${DEST}/${name}"

    if [ -d "${dir}/.git" ]; then
        current="$(safe_git -C "${dir}" rev-parse HEAD)"
        if [ "${current}" != "${commit}" ]; then
            echo "${name} : ${dir} est au commit ${current}, attendu ${commit}. Supprimer ce dossier puis relancer." >&2
            exit 1
        fi
        echo "${name} : déjà présent au commit ${commit}."
    elif [ -e "${dir}" ]; then
        echo "${name} : ${dir} existe mais n'est pas un clone. Supprimer ce dossier puis relancer." >&2
        exit 1
    else
        origin="${url}"
        [ -n "${FROM}" ] && origin="file://${FROM}/${name}"
        echo "${name} : clone de ${origin} au commit ${commit} (${licence})."
        tmp="${dir}.partial"
        rm -rf "${tmp}"
        safe_git init --quiet "${tmp}"
        if [ -n "${FROM}" ]; then
            # Un miroir local superficiel ne sert que son sommet : on le prend, puis on vérifie.
            safe_git -C "${tmp}" fetch --quiet --depth 1 --no-tags --no-recurse-submodules "${origin}" HEAD
        else
            safe_git -C "${tmp}" fetch --quiet --depth 1 --no-tags --no-recurse-submodules "${origin}" "${commit}"
        fi
        fetched="$(safe_git -C "${tmp}" rev-parse FETCH_HEAD)"
        if [ "${fetched}" != "${commit}" ]; then
            rm -rf "${tmp}"
            echo "${name} : commit reçu ${fetched}, attendu ${commit}." >&2
            exit 1
        fi
        safe_git -C "${tmp}" checkout --quiet --detach FETCH_HEAD
        safe_git -C "${tmp}" remote add origin "${url}"
        mv "${tmp}" "${dir}"
        echo "${name} : commit ${commit} vérifié."
    fi

    if [ "${name}" = "stalwart" ]; then
        mkdir -p "${DEST}/reports"
        report="${DEST}/reports/stalwart_sel"
        python3 -I "${ROOT}/scripts/sources/strip_sel.py" "${dir}" --compare-ossify \
            --report "${report}.new.md" --json "${report}.new.json" >/dev/null
        # Le rapport gardé est celui du passage qui a retiré quelque chose (le premier) : un
        # nouveau passage sur une copie déjà triée ne l'écrase pas par un rapport vide.
        if [ ! -f "${report}.json" ] || grep -q '"file":' "${report}.new.json" \
            || ! grep -q '"deleted_files": \[\]' "${report}.new.json"; then
            mv "${report}.new.md" "${report}.md"
            mv "${report}.new.json" "${report}.json"
        else
            rm -f "${report}.new.md" "${report}.new.json"
        fi
        echo "${name} : code sous LicenseRef-SEL retiré et vérifié (rapport : .sources/reports/stalwart_sel.md)."
    fi
done

echo "Sources prêtes dans ${DEST}."
