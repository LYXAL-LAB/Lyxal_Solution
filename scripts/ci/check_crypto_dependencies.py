#!/usr/bin/env python3
"""Garde-fou des dépendances cryptographiques (décision C12 du lot 2 du programme courrier).

Règle (.agents/rules/lyxal_standards_and_checklist.md §11.3) : toute cryptographie passe par
lyxal_crypto. Ce contrôle échoue si :

1. un paquet du workspace autre que lyxal_crypto déclare une dépendance directe (normale, de
   test ou de compilation) vers une crate cryptographique de la liste FORBIDDEN ; seule
   exception : tokio-rustls, permis aux hôtes (apps/*) pour le transport TLS (TlsAcceptor,
   STARTTLS), la configuration restant construite par lyxal_crypto (décision C7) ;
2. un fichier .rs hors de crates/lyxal_crypto appelle directement ring, aws-lc-rs, ou construit
   une configuration rustls (ServerConfig / ClientConfig::builder*) ;
3. l'arbre normal de lyxal_crypto contient la crate rsa (faille « Marvin », décision C2) ou
   ed25519-dalek (décision C1 : aws-lc-rs seul moteur asymétrique) ;
4. lyxal_crypto lui-même déclare une dépendance directe (de tout type) vers ring (décision C1 :
   un seul moteur asymétrique, aws-lc-rs ; ring reste amené indirectement par rustls), rsa,
   ed25519-dalek, mail-auth (canonicalisation DKIM portée, décision C4) ou openssl.

Les crates de protocole qui amènent leur propre TLS (lettre, reqwest dans lyxal_notification)
restent permises : ce sont des dépendances indirectes, validées en K10 / N4.
Lancé par scripts/ci/crypto_checks.sh (job « Cryptographie » de la CI et scripts/ci/ci_local.sh).
"""
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
OWNER = "lyxal_crypto"
FORBIDDEN = {
    "aes-gcm", "aes", "argon2", "aws-lc-rs", "aws-lc-sys", "blake3", "chacha20poly1305", "ece",
    "ed25519-dalek", "hkdf", "hmac", "jsonwebtoken", "mail-auth", "openssl", "p256", "ring",
    "rsa", "rustls", "sha1", "sha2", "totp-rs", "tokio-rustls",
}
# Permis aux hôtes seulement (apps/*), pour le transport.
HOST_ONLY = {"tokio-rustls"}
FORBIDDEN_IN_TREE = {"rsa", "ed25519-dalek"}
# Interdites même à lyxal_crypto, comme dépendances directes (normales, de test, de compilation).
FORBIDDEN_IN_OWNER = {"ring", "rsa", "ed25519-dalek", "mail-auth", "openssl"}
SOURCE_PATTERNS = [
    re.compile(r"\bring::"),
    re.compile(r"\baws_lc_rs::"),
    re.compile(r"\b(ServerConfig|ClientConfig)::builder"),
]
# Dossiers de sources Rust du workspace (les autres dossiers du dépôt ne sont pas compilés).
SKIPPED_PARTS = {"target", ".git", "node_modules"}

failures = []
metadata = json.loads(subprocess.run(
    ["cargo", "metadata", "--no-deps", "--format-version", "1", "--locked"],
    cwd=ROOT, capture_output=True, text=True, check=True).stdout)
members = set(metadata["workspace_members"])
source_roots = []
for package in metadata["packages"]:
    if package["id"] not in members:
        continue
    manifest = Path(package["manifest_path"])
    source_roots.append(manifest.parent)
    if package["name"] == OWNER:
        for dependency in package["dependencies"]:
            if dependency["name"] in FORBIDDEN_IN_OWNER:
                kind = dependency["kind"] or "normal"
                failures.append(f"{OWNER} : dépendance {kind} directe interdite vers "
                                f"« {dependency['name']} » (décisions C1, C2, C4)")
        continue
    is_host = manifest.parent.parent == ROOT / "apps"
    for dependency in package["dependencies"]:
        name = dependency["name"]
        if name not in FORBIDDEN or (name in HOST_ONLY and is_host):
            continue
        kind = dependency["kind"] or "normal"
        failures.append(f"{package['name']} : dépendance {kind} directe interdite vers « {name} »"
                        " (passer par lyxal_crypto)")

for directory in source_roots:
    if directory.name == OWNER:
        continue
    for path in sorted(directory.rglob("*.rs")):
        if SKIPPED_PARTS.intersection(path.relative_to(directory).parts):
            continue
        for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if line.lstrip().startswith("//"):
                continue
            for pattern in SOURCE_PATTERNS:
                if pattern.search(line):
                    failures.append(f"{path.relative_to(ROOT)}:{number} : appel cryptographique ou "
                                    f"configuration TLS hors de lyxal_crypto ({pattern.pattern})")

tree = subprocess.run(
    ["cargo", "tree", "-p", OWNER, "-e", "normal", "--prefix", "none", "--format", "{p}",
     "--locked"],
    cwd=ROOT, capture_output=True, text=True, check=True).stdout
in_tree = {line.split()[0] for line in tree.splitlines() if line.strip()}
for name in sorted(FORBIDDEN_IN_TREE & in_tree):
    failures.append(f"lyxal_crypto : la crate « {name} » est dans l'arbre normal (décisions C1, C2)")

if failures:
    print("ÉCHEC : dépendances cryptographiques hors de lyxal_crypto", file=sys.stderr)
    for failure in failures:
        print(f"  - {failure}", file=sys.stderr)
    sys.exit(1)
print(f"PASS : {len(source_roots)} paquets du workspace, aucune crate cryptographique directe hors "
      f"de {OWNER} ({len(FORBIDDEN)} crates contrôlées) ; arbre de {OWNER} sans "
      f"{', '.join(sorted(FORBIDDEN_IN_TREE))} ; {OWNER} sans dépendance directe vers "
      f"{', '.join(sorted(FORBIDDEN_IN_OWNER))}")
