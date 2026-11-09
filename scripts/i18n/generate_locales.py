#!/usr/bin/env python3
"""Génère le référentiel des langues de lyxal_i18n depuis Unicode CLDR.

Lit les paquets officiels `cldr-json` (cldr-core, cldr-localenames-full, cldr-misc-full) à la
version CLDR_VERSION, téléchargés depuis le registre npm, et écrit
`crates/lyxal_i18n/seeds/i18n_locale.surql` (versionné). À relancer seulement à une montée de
version de CLDR ; le CI rejoue le seed sans rien régénérer.

Usage :
    python3 scripts/i18n/generate_locales.py [--cldr-dir DOSSIER]

Sans `--cldr-dir`, les trois paquets sont téléchargés (`npm pack`) dans un dossier temporaire.
Données CLDR : licence Unicode-3.0.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
import tarfile
import tempfile
from pathlib import Path

CLDR_VERSION = "49.0.0"
PACKAGES = ("cldr-core", "cldr-localenames-full", "cldr-misc-full")
ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "crates" / "lyxal_i18n" / "seeds" / "i18n_locale.surql"
ACTIVE = {"fr", "en"}
PLURAL_ORDER = ("zero", "one", "two", "few", "many", "other")
# Forme acceptée par la règle `locale` de lyxal_core : langue[-Script][-RÉGION]
TAG = re.compile(r"^[a-z]{2,3}(-[A-Z][a-z]{3})?(-([A-Z]{2}|[0-9]{3}))?$")
SCRIPT = re.compile(r"^[A-Z][a-z]{3}$")


def fetch(target: Path) -> Path:
    """Télécharge et décompresse les paquets cldr-json dans `target`."""
    for package in PACKAGES:
        directory = target / package
        directory.mkdir(parents=True, exist_ok=True)
        name = subprocess.run(
            ["npm", "pack", f"{package}@{CLDR_VERSION}", "--silent"],
            cwd=directory, check=True, capture_output=True, text=True,
        ).stdout.strip().splitlines()[-1]
        with tarfile.open(directory / name) as archive:
            archive.extractall(directory, filter="data")
    return target


def load(path: Path) -> dict:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


class Cldr:
    """Accès aux données CLDR nécessaires au référentiel."""

    def __init__(self, base: Path) -> None:
        core = base / "cldr-core" / "package"
        self.names = base / "cldr-localenames-full" / "package" / "main"
        self.misc = base / "cldr-misc-full" / "package" / "main"
        version = load(core / "package.json")["version"]
        if version != CLDR_VERSION:
            sys.exit(f"cldr-core {version} trouvé, {CLDR_VERSION} attendu")
        supplemental = core / "supplemental"
        # Langues publiées et langues « par défaut » (fr-FR, en-US, zh-Hant-TW : contenu identique
        # à leur parent, absentes de availableLocales)
        self.available = sorted(set(load(core / "availableLocales.json")["availableLocales"]["full"])
                                | set(load(core / "defaultContent.json")["defaultContent"]))
        self.parents = load(supplemental / "parentLocales.json")["supplemental"]["parentLocales"]["parentLocale"]
        self.likely = load(supplemental / "likelySubtags.json")["supplemental"]["likelySubtags"]
        self.cardinal = load(supplemental / "plurals.json")["supplemental"]["plurals-type-cardinal"]
        self.ordinal = load(supplemental / "ordinals.json")["supplemental"]["plurals-type-ordinal"]
        self._display: dict[str, dict] = {}

    def parent(self, tag: str) -> str | None:
        """Langue parente selon CLDR : parent explicite, sinon troncature ; None à la racine."""
        explicit = self.parents.get(tag)
        if explicit is not None:
            return None if explicit in ("root", "und") else explicit
        parts = tag.split("-")
        if len(parts) == 1:
            return None
        # Règle nonlikelyScript : langue-Script dont le script n'est pas le script probable
        if len(parts) == 2 and SCRIPT.match(parts[1]):
            likely = self.likely.get(parts[0], "").split("-")
            if len(likely) < 2 or likely[1] != parts[1]:
                return None
        return "-".join(parts[:-1])

    def chain(self, tag: str) -> list[str]:
        """Chaîne de repli, sans l'étiquette elle-même."""
        chain: list[str] = []
        current = self.parent(tag)
        while current is not None:
            chain.append(current)
            current = self.parent(current)
        return chain

    def lookup(self, tag: str, table: dict) -> dict | None:
        """Valeur de `table` pour l'étiquette, sa chaîne de repli puis sa langue."""
        for candidate in [tag, *self.chain(tag), tag.split("-")[0]]:
            if candidate in table:
                return table[candidate]
        return None

    def display(self, locale: str) -> dict | None:
        """Noms d'affichage (langues, scripts, régions, motif) dans la langue `locale`."""
        if locale not in self._display:
            data = None
            for candidate in [locale, *self.chain(locale)]:
                folder = self.names / candidate
                if folder.is_dir():
                    def part(file: str, key: str) -> dict:
                        path = folder / file
                        if not path.is_file():
                            return {}
                        return load(path)["main"][candidate]["localeDisplayNames"].get(key, {})

                    data = {
                        "languages": part("languages.json", "languages"),
                        "scripts": part("scripts.json", "scripts"),
                        "territories": part("territories.json", "territories"),
                        "pattern": part("localeDisplayNames.json", "localeDisplayPattern")
                        or {"localePattern": "{0} ({1})", "localeSeparator": "{0}, {1}"},
                    }
                    break
            self._display[locale] = data
        return self._display[locale]

    def name(self, tag: str, locale: str) -> str | None:
        """Nom de `tag` dans la langue `locale` : nom composé de CLDR, sinon langue (détails)."""
        names = self.display(locale)
        if names is None:
            return None
        if tag in names["languages"]:
            return names["languages"][tag]
        parts = tag.split("-")
        language = names["languages"].get(parts[0])
        if language is None:
            return None
        details = []
        for part in parts[1:]:
            table = names["scripts"] if SCRIPT.match(part) else names["territories"]
            details.append(table.get(part, part))
        if not details:
            return language
        separator = names["pattern"]["localeSeparator"]
        joined = details[0]
        for detail in details[1:]:
            joined = separator.replace("{0}", joined).replace("{1}", detail)
        return names["pattern"]["localePattern"].replace("{0}", language).replace("{1}", joined)

    def direction(self, tag: str) -> str:
        for candidate in [tag, *self.chain(tag), tag.split("-")[0]]:
            path = self.misc / candidate / "layout.json"
            if path.is_file():
                order = load(path)["main"][candidate]["layout"]["orientation"]["characterOrder"]
                return "rtl" if order == "right-to-left" else "ltr"
        return "ltr"

    def plurals(self, tag: str, table: dict) -> list[str]:
        rules = self.lookup(tag, table) or {}
        present = {key.removeprefix("pluralRule-count-") for key in rules}
        return [category for category in PLURAL_ORDER if category in present] or ["other"]


def surql_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def record(cldr: Cldr, tag: str) -> str:
    parts = tag.split("-")
    script = next((p for p in parts[1:] if SCRIPT.match(p)), None)
    region = next((p for p in parts[1:] if not SCRIPT.match(p)), None)
    name_en = cldr.name(tag, "en") or tag
    name_native = cldr.name(tag, tag) or name_en
    fields = {
        "tag": surql_string(tag),
        "language": surql_string(parts[0]),
        "script": surql_string(script) if script else "NONE",
        "region": surql_string(region) if region else "NONE",
        "name_en": surql_string(name_en),
        "name_native": surql_string(name_native),
        "direction": surql_string(cldr.direction(tag)),
        "plural_cardinal": json.dumps(cldr.plurals(tag, cldr.cardinal)),
        "plural_ordinal": json.dumps(cldr.plurals(tag, cldr.ordinal)),
        "fallback": json.dumps(cldr.chain(tag), ensure_ascii=False),
        "active": "true" if tag in ACTIVE else "false",
        "cldr_version": surql_string(CLDR_VERSION.split(".")[0]),
    }
    content = ", ".join(f"{key}: {value}" for key, value in fields.items())
    return (
        f"IF !record::exists(i18n_locale:⟨{tag}⟩) THEN (\n"
        f"    CREATE i18n_locale:⟨{tag}⟩ CONTENT {{ {content} }}\n"
        ") END;\n"
    )


def generate(base: Path) -> tuple[int, list[str]]:
    cldr = Cldr(base)
    tags = sorted(t for t in cldr.available if t not in ("root", "und") and TAG.match(t))
    skipped = sorted(t for t in cldr.available if t not in ("root", "und") and not TAG.match(t))
    # Toute langue de repli doit figurer dans le référentiel
    known = set(tags)
    for tag in tags:
        missing = [parent for parent in cldr.chain(tag) if parent not in known]
        if missing:
            sys.exit(f"{tag} : langue de repli absente du référentiel ({', '.join(missing)})")
    header = (
        "-- ============================================================================\n"
        "-- SEEDS : référentiel des langues (Unicode CLDR " + CLDR_VERSION + ", licence Unicode-3.0)\n"
        "-- MODULE : lyxal_i18n\n"
        "-- ============================================================================\n"
        "-- Fichier généré par scripts/i18n/generate_locales.py : ne pas modifier à la main.\n"
        "-- Rejouable et non destructif : une langue existante n'est pas modifiée (son état actif\n"
        "-- est conservé). Langues actives à la création : fr, en.\n\n"
    )
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(header + "".join(record(cldr, tag) for tag in tags), encoding="utf-8")
    return len(tags), skipped


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--cldr-dir", type=Path, help="dossier contenant les paquets cldr-json décompressés")
    args = parser.parse_args()
    if args.cldr_dir:
        count, skipped = generate(args.cldr_dir)
    else:
        with tempfile.TemporaryDirectory() as directory:
            count, skipped = generate(fetch(Path(directory)))
    print(f"{OUTPUT.relative_to(ROOT)} : {count} langues (CLDR {CLDR_VERSION})")
    if skipped:
        print(f"Écartées (variantes non prises en charge) : {', '.join(skipped)}")


if __name__ == "__main__":
    main()
