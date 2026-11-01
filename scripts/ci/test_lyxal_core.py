"""Rejoue la suite de tests SurrealQL de `lyxal_core` contre un serveur SurrealDB jetable.

1. Démarre `surreal start memory` sur un port libre, avec des identifiants générés.
2. Importe toutes les fonctions de `crates/lyxal_core/functions/*/functions/` et vérifie
   qu'elles sont toutes définies.
3. Exécute chaque fichier de tests selon son format.

Format « assertions » (fichier dont les premières lignes contiennent `-- lyxal-test: assertions`) :

    -- lyxal-test: assertions

    -- test: adresse valide
    RETURN fn::validation_email("contact@example.com", 254).valid == true;

    -- test: argument invalide
    -- attendu-erreur: CORE_INVALID_ARGUMENT
    RETURN fn::validation_email("x", -1);

  Chaque bloc `-- test:` contient exactement une instruction, exécutée seule. Elle doit renvoyer
  `true`, ou lever exactement l'erreur annoncée par `-- attendu-erreur:`. Tout autre résultat
  fait échouer le script.

Ancien format (fichiers pas encore migrés) : chaque instruction est classée `OK`, `THROW` métier
(`THROW "<CODE>"`) ou rejet JSON attendu (fichiers `json*`) ; toute autre erreur fait échouer
le script. Ce mode ne vérifie pas les valeurs renvoyées et disparaît à la fin de la reprise
(`crates/lyxal_core/implementation_plan.md`).
"""

import base64
import json
import os
import re
import secrets
import socket
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request
from collections import Counter
from dataclasses import dataclass, field
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CORE = ROOT / "crates" / "lyxal_core" / "functions"
DOMAINS = ("validations", "security", "sanitize", "utils")
SURREAL = os.environ.get("LYXAL_SURREAL_BIN", "surreal")
NS, DB = "lyxal_core_ci", "lyxal_core_ci"

FORMAT_MARKER = re.compile(r"^--\s*lyxal-test:\s*assertions\s*$", re.M)
TEST_MARKER = re.compile(r"^--\s*test:\s*(.*)$")
ERROR_MARKER = re.compile(r"^--\s*attendu-erreur:\s*([A-Z][A-Z0-9_]*)\s*$")
LEGACY_THROW = re.compile(r"^(An error occurred: )?'?[A-Z][A-Z0-9_]{3,}'?$")


def thrown_code(message: str) -> str:
    """Code d'un `THROW "<CODE>"` tel que le serveur le renvoie (`An error occurred: <CODE>`)."""
    return re.sub(r"^An error occurred:\s*", "", message.strip()).strip("'\" ")


def strip_comments(text: str) -> str:
    return "\n".join(line for line in text.splitlines() if not line.strip().startswith("--")).strip()


class SurrealServer:
    """Serveur SurrealDB en mémoire, démarré pour la durée d'un bloc `with`."""

    def __init__(self) -> None:
        self.user, self.password = "core_ci", secrets.token_urlsafe(24)
        with socket.socket() as sock:
            sock.bind(("127.0.0.1", 0))
            self.port = sock.getsockname()[1]
        self.auth = base64.b64encode(f"{self.user}:{self.password}".encode()).decode()
        self.process = None

    def __enter__(self) -> "SurrealServer":
        self.process = subprocess.Popen(
            [SURREAL, "start", "--log", "error", "--user", self.user, "--pass", self.password,
             "--bind", f"127.0.0.1:{self.port}", "memory"],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
        for _ in range(100):
            ready = subprocess.run([SURREAL, "is-ready", "--endpoint", self.endpoint], capture_output=True)
            if ready.returncode == 0:
                return self
            time.sleep(0.2)
        self.__exit__()
        raise RuntimeError("Le serveur SurrealDB n'a pas démarré.")

    def __exit__(self, *_exc) -> None:
        if self.process:
            self.process.terminate()
            self.process.wait(timeout=10)

    @property
    def endpoint(self) -> str:
        return f"http://127.0.0.1:{self.port}"

    def sql(self, body: str) -> list:
        request = urllib.request.Request(
            f"{self.endpoint}/sql",
            data=body.encode(),
            headers={"Accept": "application/json", "Authorization": f"Basic {self.auth}",
                     "surreal-ns": NS, "surreal-db": DB},
        )
        with urllib.request.urlopen(request, timeout=120) as response:
            return json.load(response)

    def load_functions(self, files: list[Path]) -> int:
        """Importe les fichiers de fonctions et renvoie le nombre de fonctions définies."""
        with tempfile.NamedTemporaryFile("w", suffix=".surql", delete=False) as bundle:
            bundle.write("OPTION IMPORT;\n")
            for file in files:
                bundle.write(file.read_text() + "\n")
        try:
            imported = subprocess.run(
                [SURREAL, "import", "--endpoint", self.endpoint, "--user", self.user,
                 "--pass", self.password, "--ns", NS, "--db", DB, bundle.name],
                capture_output=True, text=True,
            )
        finally:
            os.unlink(bundle.name)
        if imported.returncode != 0:
            raise RuntimeError(f"Import des fonctions en échec :\n{imported.stderr[-2000:]}")
        return len(self.sql("INFO FOR DB;")[0]["result"].get("functions", {}))


@dataclass
class FileReport:
    """Résultat d'un fichier de tests."""

    assertions: bool
    passed: int = 0
    counts: Counter = field(default_factory=Counter)
    failures: list[str] = field(default_factory=list)


def run_assertions(server: SurrealServer, text: str) -> FileReport:
    report = FileReport(assertions=True)
    preamble, blocks, current = [], [], None
    for line in text.splitlines():
        marker = TEST_MARKER.match(line.strip())
        if marker:
            current = {"name": marker.group(1).strip() or "(sans nom)", "lines": []}
            blocks.append(current)
        elif current is None:
            preamble.append(line)
        else:
            current["lines"].append(line)

    if strip_comments("\n".join(line for line in preamble if not FORMAT_MARKER.match(line))):
        report.failures.append("instruction placée avant le premier bloc `-- test:`")
    if not blocks:
        report.failures.append("aucun bloc `-- test:` dans un fichier au format assertions")

    for block in blocks:
        expected_error = next((m.group(1) for m in (ERROR_MARKER.match(l.strip()) for l in block["lines"]) if m), None)
        body = "\n".join(block["lines"])
        try:
            results = server.sql(body)
        except urllib.error.HTTPError as error:
            report.failures.append(f"« {block['name']} » : requête refusée : {error.read().decode()[:300]}")
            continue
        if len(results) != 1:
            report.failures.append(f"« {block['name']} » : un bloc doit contenir exactement une instruction ({len(results)} trouvées)")
            continue
        status, value = results[0]["status"], results[0]["result"]
        if expected_error:
            if status == "OK":
                report.failures.append(f"« {block['name']} » : aurait dû lever {expected_error}, a renvoyé {json.dumps(value, ensure_ascii=False)[:200]}")
            elif thrown_code(str(value)) != expected_error:
                report.failures.append(f"« {block['name']} » : aurait dû lever {expected_error}, a levé {str(value)[:200]}")
            else:
                report.passed += 1
        elif status != "OK":
            report.failures.append(f"« {block['name']} » : erreur inattendue : {str(value)[:200]}")
        elif value is True:
            report.passed += 1
        elif value is False:
            report.failures.append(f"« {block['name']} » : l'assertion renvoie false")
        else:
            report.failures.append(f"« {block['name']} » : doit renvoyer true, a renvoyé {json.dumps(value, ensure_ascii=False)[:200]}")
    return report


def run_legacy(server: SurrealServer, text: str, file_name: str) -> FileReport:
    report = FileReport(assertions=False)
    try:
        results = server.sql(text)
    except urllib.error.HTTPError as error:
        report.failures.append(f"requête refusée : {error.read().decode()[:300]}")
        return report
    for index, result in enumerate(results):
        if result["status"] == "OK":
            report.counts["OK"] += 1
            continue
        message = str(result["result"]).strip()
        if LEGACY_THROW.match(message):
            report.counts["THROW"] += 1
        elif file_name.startswith("json") and "encoding::json::decode" in message:
            report.counts["JSON"] += 1
        else:
            report.failures.append(f"instruction {index} : {message[:300]}")
    return report


def run_file(server: SurrealServer, path: Path) -> FileReport:
    text = path.read_text()
    head = "\n".join(text.splitlines()[:30])
    if FORMAT_MARKER.search(head):
        return run_assertions(server, text)
    return run_legacy(server, text, path.name)


def main() -> int:
    function_files = sorted(f for d in DOMAINS for f in (CORE / d / "functions").glob("*.surql"))
    test_files = sorted(f for d in DOMAINS for f in (CORE / d / "tests").glob("*.surql"))

    with SurrealServer() as server:
        defined = server.load_functions(function_files)
        print(f"Fonctions : {defined} définies / {len(function_files)} fichiers.")
        if defined != len(function_files):
            print("Toutes les fonctions de lyxal_core ne sont pas définies.", file=sys.stderr)
            return 1

        assertion_files = legacy_files = assertions_passed = 0
        legacy_counts, failures = Counter(), []
        for path in test_files:
            report = run_file(server, path)
            if report.assertions:
                assertion_files += 1
                assertions_passed += report.passed
            else:
                legacy_files += 1
                legacy_counts += report.counts
            failures += [(path.relative_to(ROOT), message) for message in report.failures]

    print(f"Format assertions : {assertion_files} fichiers, {assertions_passed} assertions vérifiées.")
    print(f"Ancien format (non vérifié en valeur) : {legacy_files} fichiers — {legacy_counts['OK']} OK, "
          f"{legacy_counts['THROW']} THROW métier, {legacy_counts['JSON']} rejets JSON.")
    print(f"Échecs : {len(failures)}.")
    for relative, message in failures:
        print(f"::error file={relative}::{message}")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
