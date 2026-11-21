#!/usr/bin/env python3
"""Isolement des paquets AGPL (décisions P3 et G16 du programme courrier).

Règle : seuls les paquets du courrier, des agendas et des contacts (`lyxal_mail`,
`lyxal_mail_proto`, `lyxal-groupware`, plus tard `lyxal_dav`, `lyxal_calendar`,
`lyxal_contacts`) sont sous AGPL. Aucun paquet du workspace sous licence permissive
(`MIT OR Apache-2.0`) ne doit dépendre, même pour ses tests ou sa compilation, d'un paquet sous
licence GPL ou AGPL : `lyxal-server` et les crates du Noyau ne lient aucun code AGPL. Le sens
inverse est permis (les essais de `lyxal-groupware` lancent `lyxal-server`).

Le contrôle lit `cargo metadata` (graphe résolu) : pour chaque membre permissif, toutes ses
dépendances directes (normales, de test, de compilation), puis leurs dépendances normales et de
compilation, de proche en proche. Échoue (code 1) en nommant le chemin fautif.
Lancé par la CI (job « Licences et sources ») et par scripts/ci/ci_local.sh.
"""
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
# AGPL ou GPL dans une expression SPDX (la LGPL n'est pas visée).
COPYLEFT = re.compile(r"(^|[^L])A?GPL-")


def is_copyleft(package):
    return bool(COPYLEFT.search(package.get("license") or ""))


def main():
    metadata = json.loads(subprocess.run(
        ["cargo", "metadata", "--format-version", "1", "--locked"],
        cwd=ROOT, capture_output=True, text=True, check=True).stdout)
    packages = {package["id"]: package for package in metadata["packages"]}
    nodes = {node["id"]: node for node in metadata["resolve"]["nodes"]}
    members = metadata["workspace_members"]

    def dependencies(package_id, all_kinds):
        for dep in nodes[package_id]["deps"]:
            kinds = {kind["kind"] for kind in dep["dep_kinds"]}
            if all_kinds or kinds & {None, "build"}:
                yield dep["pkg"]

    failures = []
    copyleft_members = []
    for member in members:
        package = packages[member]
        if is_copyleft(package):
            copyleft_members.append(package["name"])
            continue
        # Parcours en largeur, avec le chemin pour le message
        seen = {member}
        queue = [(dep, [package["name"]]) for dep in dependencies(member, True)]
        while queue:
            current, path = queue.pop(0)
            if current in seen:
                continue
            seen.add(current)
            name = packages[current]["name"]
            if is_copyleft(packages[current]):
                failures.append(
                    f"{package['name']} ({package.get('license')}) dépend de {name} "
                    f"({packages[current].get('license')}) : {' -> '.join(path + [name])}")
                continue
            queue.extend((dep, path + [name]) for dep in dependencies(current, False))

    if failures:
        print("Isolement AGPL rompu (décision P3) :", file=sys.stderr)
        for failure in failures:
            print(f"  - {failure}", file=sys.stderr)
        return 1
    print(f"Isolement AGPL : aucun paquet permissif ne dépend des paquets copyleft "
          f"({', '.join(sorted(copyleft_members)) or 'aucun'}).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
