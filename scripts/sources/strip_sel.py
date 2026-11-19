#!/usr/bin/env python3
"""Tri du code propriétaire de Stalwart (décisions F5 et C3 du programme courrier).

Stalwart est publié sous double licence « AGPL-3.0-only OR LicenseRef-SEL ». Une partie de
son code n'existe que sous la licence Entreprise (`LicenseRef-SEL`, propriétaire) : elle ne
doit jamais servir de source à Lyxal OS. Ce script la retire d'une copie de travail clonée par
`scripts/sources/fetch_sources.sh`, écrit un rapport par crate, puis vérifie le résultat.

Marqueurs traités (relevés dans le dépôt de Stalwart au commit figé, et dans son propre
script `resources/scripts/ossify.py`, lu mais jamais exécuté) :

1. Fichier entièrement propriétaire : une ligne de commentaire qui ne porte que
   `SPDX-License-Identifier: LicenseRef-SEL`, placée hors de tout extrait (en pratique dans
   l'en-tête du fichier). Le fichier est supprimé.
2. Extrait propriétaire dans un fichier à double licence : bloc ouvert par une ligne
   contenant `SPDX-SnippetBegin`, fermé par une ligne contenant `SPDX-SnippetEnd`, et qui
   contient une ligne `SPDX-License-Identifier: LicenseRef-SEL`. Les lignes du bloc sont
   retirées, ligne d'ouverture et ligne de fermeture comprises (une fermeture écrite
   `} // SPDX-SnippetEnd` emporte donc son accolade, comme dans le script de l'éditeur).
   Un extrait sous une autre licence est gardé tel quel.
3. Un extrait propriétaire jamais fermé est retiré jusqu'à la fin du fichier et signalé
   comme anomalie (code de sortie 1).

L'en-tête `SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-SEL` (double licence) n'est
pas un marqueur propriétaire : le fichier est gardé et son en-tête n'est pas modifié.

Écarts voulus avec `ossify.py` : tous les fichiers texte sont examinés (pas seulement `.rs`) ;
la règle 1 ne se limite pas au premier commentaire du fichier ; la racine d'un crate
entièrement propriétaire (`src/lib.rs`) est supprimée au lieu d'être vidée (la copie de
travail n'est jamais compilée) ; un extrait non fermé est une anomalie. L'option
`--compare-ossify` applique en plus les règles de `ossify.py`, réécrites ici, et affiche
toute différence de résultat.

Vérification finale (toujours faite, ou seule avec `--check`) : aucune ligne
`SPDX-License-Identifier: LicenseRef-SEL` ni aucun extrait propriétaire ne doit rester. Les
autres mentions de `LicenseRef-SEL` ne sont admises que sous deux formes, comptées dans le
rapport : l'expression de double licence `AGPL-3.0-only OR LicenseRef-SEL`, et les fichiers
de `ALLOWED_MENTION_FILES` (texte de la licence, notice du README, script de l'éditeur).
Toute autre mention fait échouer le script.

Usage :
    python3 -I scripts/sources/strip_sel.py <copie de travail> [--report rapport.md]
            [--json rapport.json] [--dry-run] [--check] [--compare-ossify]

Le script ne lit que des fichiers et n'exécute rien de la copie de travail.
"""

import argparse
import json
import os
import re
import sys

SEL = "LicenseRef-SEL"
DUAL_EXPRESSION = "AGPL-3.0-only OR LicenseRef-SEL"

# Ligne de commentaire qui ne porte que l'identifiant propriétaire (préfixes de commentaire
# usuels : //, /*, *, #, --, ;, <!--).
SEL_ONLY_LINE = re.compile(
    r"^\s*(?://+|/\*+|\*+|#+|--+|;+|<!--)?\s*SPDX-License-Identifier:\s*LicenseRef-SEL\s*(?:\*/|-->)?\s*$"
)
SNIPPET_BEGIN = "SPDX-SnippetBegin"
SNIPPET_END = "SPDX-SnippetEnd"

# Fichiers de Stalwart où une mention de la licence Entreprise est admise après le tri.
ALLOWED_MENTION_FILES = {
    "LICENSES/LicenseRef-SEL.txt": "texte de la licence Entreprise",
    "README.md": "notice de licence du projet",
    "resources/scripts/ossify.py": "script de tri de l'éditeur, qui cite le marqueur",
}

SKIPPED_DIRS = {".git"}
OUTSIDE_CRATES = "(hors crates)"


def iter_files(root):
    """Chemins relatifs (séparateur « / ») de tous les fichiers, hors dossiers ignorés."""
    for current, dirs, files in os.walk(root):
        dirs[:] = sorted(d for d in dirs if d not in SKIPPED_DIRS)
        for name in sorted(files):
            path = os.path.join(current, name)
            if os.path.islink(path):
                continue
            yield os.path.relpath(path, root).replace(os.sep, "/")


def read_text(path):
    """Contenu d'un fichier texte UTF-8, ou None pour un fichier binaire."""
    with open(path, "rb") as handle:
        raw = handle.read()
    try:
        return raw.decode("utf-8"), raw
    except UnicodeDecodeError:
        return None, raw


def crate_of(relative_path):
    parts = relative_path.split("/")
    if len(parts) >= 3 and parts[0] == "crates":
        return parts[1]
    return OUTSIDE_CRATES


def analyse(text):
    """Applique les règles à un contenu.

    Retourne (fichier_propriétaire, nouveau_contenu, extraits_retirés, lignes_retirées,
    extrait_non_fermé).
    """
    lines = text.split("\n")
    kept = []
    snippets = 0
    removed_lines = 0
    unterminated = False
    whole_file = False
    index = 0
    while index < len(lines):
        line = lines[index]
        if SNIPPET_BEGIN in line:
            end = index
            closed = False
            while end < len(lines):
                if SNIPPET_END in lines[end]:
                    closed = True
                    break
                end += 1
            block = lines[index : end + 1] if closed else lines[index:]
            if any(SEL_ONLY_LINE.match(item) for item in block):
                snippets += 1
                removed_lines += len(block)
                if not closed:
                    unterminated = True
                index += len(block)
                continue
            # Extrait sous une autre licence : gardé en entier.
            kept.extend(block)
            index += len(block)
            continue
        if SEL_ONLY_LINE.match(line):
            whole_file = True
        kept.append(line)
        index += 1
    return whole_file, "\n".join(kept), snippets, removed_lines, unterminated


def ossify_rules(relative_path, text):
    """Résultat des règles de `ossify.py` (réécrites) : ("file" | "snippets" | "none", nombre)."""
    if not relative_path.endswith(".rs"):
        return "none", 0
    lines = text.strip().split("\n")
    first_comment = []
    if lines and lines[0].strip().startswith("/*"):
        for line in lines:
            first_comment.append(line)
            if "*/" in line:
                break
    elif lines and lines[0].strip().startswith("//"):
        for line in lines:
            stripped = line.strip()
            if stripped.startswith("//") or stripped == "":
                first_comment.append(line)
            else:
                break
    if "SPDX-License-Identifier: LicenseRef-SEL" in "\n".join(first_comment):
        return "file", 0
    lines = text.split("\n")
    count = 0
    index = 0
    while index < len(lines):
        if "// SPDX-SnippetBegin" in lines[index]:
            end = index
            block = []
            while end < len(lines):
                block.append(lines[end])
                if "// SPDX-SnippetEnd" in lines[end]:
                    break
                end += 1
            if "SPDX-License-Identifier: LicenseRef-SEL" in "\n".join(block):
                count += 1
                index = end + 1
                continue
        index += 1
    return ("snippets", count) if count else ("none", 0)


def strip_tree(root, dry_run=False, compare_ossify=False):
    """Trie la copie de travail. Retourne le rapport (dictionnaire)."""
    crates = {}
    deleted_files = []
    snippet_files = []
    anomalies = []
    differences = []

    def crate_entry(name):
        return crates.setdefault(
            name,
            {
                "files_before": 0,
                "files_deleted": 0,
                "lines_deleted_files": 0,
                "files_with_snippets": 0,
                "snippets_removed": 0,
                "lines_removed_snippets": 0,
            },
        )

    for relative in list(iter_files(root)):
        path = os.path.join(root, relative)
        entry = crate_entry(crate_of(relative))
        entry["files_before"] += 1
        text, _raw = read_text(path)
        if text is None or (SEL not in text and SNIPPET_BEGIN not in text):
            continue
        whole_file, new_text, snippets, removed_lines, unterminated = analyse(text)
        if compare_ossify:
            reference = ossify_rules(relative, text)
            ours = ("file", 0) if whole_file else (("snippets", snippets) if snippets else ("none", 0))
            if reference != ours:
                differences.append({"file": relative, "strip_sel": list(ours), "ossify": list(reference)})
        if whole_file:
            entry["files_deleted"] += 1
            entry["lines_deleted_files"] += text.count("\n")
            deleted_files.append(relative)
            if not dry_run:
                os.remove(path)
            continue
        if snippets:
            entry["files_with_snippets"] += 1
            entry["snippets_removed"] += snippets
            entry["lines_removed_snippets"] += removed_lines
            snippet_files.append({"file": relative, "snippets": snippets, "lines": removed_lines})
            if unterminated:
                anomalies.append(f"{relative} : extrait propriétaire non fermé, retiré jusqu'à la fin du fichier")
            if not dry_run:
                with open(path, "w", encoding="utf-8", newline="") as handle:
                    handle.write(new_text)

    return {
        "root": os.path.abspath(root),
        "dry_run": dry_run,
        "crates": {name: crates[name] for name in sorted(crates)},
        "deleted_files": deleted_files,
        "snippet_files": snippet_files,
        "anomalies": anomalies,
        "ossify_differences": differences if compare_ossify else None,
    }


def check_tree(root):
    """Vérifie qu'aucune partie propriétaire ne reste. Retourne le résultat (dictionnaire)."""
    violations = []
    dual_mentions = 0
    dual_files = 0
    listed = {}
    for relative in iter_files(root):
        text, raw = read_text(os.path.join(root, relative))
        if text is None:
            if SEL.encode() in raw:
                violations.append(f"{relative} : fichier binaire contenant {SEL}")
            continue
        if SEL not in text:
            continue
        whole_file, _new, snippets, _lines, _unterminated = analyse(text)
        if whole_file:
            violations.append(f"{relative} : fichier sous {SEL} seule")
        if snippets:
            violations.append(f"{relative} : {snippets} extrait(s) sous {SEL}")
        file_dual = 0
        for number, line in enumerate(text.split("\n"), 1):
            if SEL not in line or SEL_ONLY_LINE.match(line):
                continue
            if relative in ALLOWED_MENTION_FILES:
                listed[relative] = listed.get(relative, 0) + 1
            elif line.replace(DUAL_EXPRESSION, "").find(SEL) == -1:
                file_dual += 1
            else:
                violations.append(f"{relative}:{number} : mention de {SEL} hors des formes admises")
        if file_dual:
            dual_mentions += file_dual
            dual_files += 1
    return {
        "violations": violations,
        "dual_licence_mentions": dual_mentions,
        "dual_licence_files": dual_files,
        "listed_files": {name: {"mentions": listed[name], "reason": ALLOWED_MENTION_FILES[name]} for name in sorted(listed)},
    }


def render_markdown(report, check):
    """Rapport lisible : tableau par crate, fichiers supprimés, vérification."""
    out = []
    totals = {key: 0 for key in ("files_before", "files_deleted", "files_with_snippets", "snippets_removed", "lines_removed_snippets", "lines_deleted_files")}
    out.append("| Crate | Fichiers avant | Fichiers supprimés | Lignes des fichiers supprimés | Fichiers avec extraits | Extraits retirés | Lignes d'extraits retirées |")
    out.append("| :--- | -: | -: | -: | -: | -: | -: |")
    for name, entry in report["crates"].items():
        for key in totals:
            totals[key] += entry[key]
        if not (entry["files_deleted"] or entry["snippets_removed"]):
            continue
        out.append(
            f"| `{name}` | {entry['files_before']} | {entry['files_deleted']} | {entry['lines_deleted_files']} "
            f"| {entry['files_with_snippets']} | {entry['snippets_removed']} | {entry['lines_removed_snippets']} |"
        )
    out.append(
        f"| **Total (tous les crates)** | {totals['files_before']} | {totals['files_deleted']} | {totals['lines_deleted_files']} "
        f"| {totals['files_with_snippets']} | {totals['snippets_removed']} | {totals['lines_removed_snippets']} |"
    )
    out.append("")
    untouched = [name for name, entry in report["crates"].items() if not (entry["files_deleted"] or entry["snippets_removed"])]
    out.append("Crates sans aucune partie propriétaire : " + (", ".join(f"`{name}`" for name in untouched) or "aucun") + ".")
    out.append("")
    out.append("Fichiers supprimés :")
    out.append("")
    for name in report["deleted_files"]:
        out.append(f"* `{name}`")
    if not report["deleted_files"]:
        out.append("* aucun")
    out.append("")
    if report["anomalies"]:
        out.append("Anomalies :")
        out.append("")
        out.extend(f"* {item}" for item in report["anomalies"])
        out.append("")
    if report["ossify_differences"] is not None:
        if report["ossify_differences"]:
            out.append("Différences avec les règles de `ossify.py` :")
            out.append("")
            for item in report["ossify_differences"]:
                out.append(f"* `{item['file']}` : strip_sel {item['strip_sel']}, ossify {item['ossify']}")
        else:
            out.append("Règles de `ossify.py` (réécrites) : même résultat, fichier par fichier.")
        out.append("")
    out.append(
        f"Vérification : {len(check['violations'])} partie(s) propriétaire(s) restante(s) ; "
        f"{check['dual_licence_mentions']} mention(s) de double licence dans {check['dual_licence_files']} fichier(s) ; "
        "fichiers listés : "
        + (", ".join(f"`{name}` ({value['mentions']}, {value['reason']})" for name, value in check["listed_files"].items()) or "aucun")
        + "."
    )
    for item in check["violations"]:
        out.append(f"* RESTE : {item}")
    return "\n".join(out) + "\n"


def main(argv=None):
    parser = argparse.ArgumentParser(description="Retire le code sous LicenseRef-SEL d'une copie de travail de Stalwart.")
    parser.add_argument("directory", help="copie de travail (ex. .sources/stalwart)")
    parser.add_argument("--report", help="fichier Markdown du rapport")
    parser.add_argument("--json", dest="json_path", help="fichier JSON du rapport")
    parser.add_argument("--dry-run", action="store_true", help="ne modifie rien ; la vérification porte alors sur la copie non triée")
    parser.add_argument("--check", action="store_true", help="vérification seule")
    parser.add_argument("--compare-ossify", action="store_true", help="compare avec les règles de ossify.py")
    args = parser.parse_args(argv)

    if not os.path.isdir(args.directory):
        print(f"dossier introuvable : {args.directory}", file=sys.stderr)
        return 2

    if args.check:
        report = {"root": os.path.abspath(args.directory), "dry_run": True, "crates": {}, "deleted_files": [], "snippet_files": [], "anomalies": [], "ossify_differences": None}
    else:
        report = strip_tree(args.directory, dry_run=args.dry_run, compare_ossify=args.compare_ossify)
    check = check_tree(args.directory)
    markdown = render_markdown(report, check)

    if args.report:
        with open(args.report, "w", encoding="utf-8") as handle:
            handle.write(markdown)
    if args.json_path:
        with open(args.json_path, "w", encoding="utf-8") as handle:
            json.dump({"strip": report, "check": check}, handle, ensure_ascii=False, indent=2)
            handle.write("\n")
    print(markdown, end="")

    failed = bool(report["anomalies"]) or (bool(check["violations"]) and not args.dry_run)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
