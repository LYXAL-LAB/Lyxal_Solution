"""Rejoue la suite de tests SurrealQL de `lyxal_core` contre un serveur SurrealDB jetable.

1. Démarre `surreal start memory` sur un port libre, avec des identifiants générés.
2. Importe toutes les fonctions de `crates/lyxal_core/functions/*/functions/` et vérifie
   qu'elles sont toutes définies.
3. Vérifie que chaque fonction a son fichier de tests `<nom>.test.surql`, et inversement.
4. Exécute chaque fichier de tests, obligatoirement au format « assertions » (la ligne
   `-- lyxal-test: assertions` figure dans ses 30 premières lignes) :

    -- lyxal-test: assertions

    -- test: adresse valide
    RETURN fn::validation_email("contact@example.com", 254).valid == true;

    -- test: argument invalide
    -- attendu-erreur: CORE_INVALID_ARGUMENT
    RETURN fn::validation_email("x", -1);

  Chaque bloc `-- test:` contient exactement une instruction, exécutée seule. Elle doit renvoyer
  `true`, ou lever exactement l'erreur annoncée par `-- attendu-erreur:`. Tout autre résultat
  fait échouer le script.
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


def thrown_code(message: str) -> str:
    """Code d'un `THROW "<CODE>"` tel que le serveur le renvoie (`An error occurred: <CODE>`)."""
    return re.sub(r"^An error occurred:\s*", "", message.strip()).strip("'\" ")


def strip_comments(text: str) -> str:
    return "\n".join(line for line in text.splitlines() if not line.strip().startswith("--")).strip()


START_ATTEMPTS = 3
START_TIMEOUT = 30
PROBE_TIMEOUT = 5


def free_port() -> int:
    """Port local libre à cet instant (relâché aussitôt : il peut être repris)."""
    with socket.socket() as sock:
        sock.bind(("127.0.0.1", 0))
        return sock.getsockname()[1]


class SurrealServer:
    """Serveur SurrealDB en mémoire, démarré pour la durée d'un bloc `with`."""

    def __init__(self) -> None:
        self.user, self.password = "core_ci", secrets.token_urlsafe(24)
        self.port = free_port()
        self.auth = base64.b64encode(f"{self.user}:{self.password}".encode()).decode()
        self.process = None

    def __enter__(self) -> "SurrealServer":
        # Le port libre est choisi puis relâché avant que le serveur ne le prenne : s'il est
        # pris entre-temps, le serveur s'arrête aussitôt. On recommence alors sur un autre port.
        failures = []
        for _attempt in range(START_ATTEMPTS):
            # Sortie d'erreur du serveur gardée dans un fichier temporaire (jamais un tube, qui
            # bloquerait le serveur une fois plein) et affichée si le démarrage échoue
            log = tempfile.TemporaryFile()
            self.process = subprocess.Popen(
                [SURREAL, "start", "--log", "error", "--user", self.user, "--pass", self.password,
                 "--bind", f"127.0.0.1:{self.port}", "memory"],
                stdout=subprocess.DEVNULL, stderr=log,
            )
            deadline = time.monotonic() + START_TIMEOUT
            while time.monotonic() < deadline and self.process.poll() is None:
                # Délai sur la sonde : un port pris par un programme qui ne répond pas la bloquerait
                try:
                    ready = subprocess.run(
                        [SURREAL, "is-ready", "--endpoint", self.endpoint],
                        capture_output=True, timeout=PROBE_TIMEOUT,
                    ).returncode == 0
                except subprocess.TimeoutExpired:
                    ready = False
                if ready:
                    return self
                time.sleep(0.2)
            exited = self.process.poll()
            if exited is None:
                self.process.terminate()
            self.process.wait(timeout=10)
            log.seek(0)
            stderr = log.read()
            log.close()
            failures.append(
                f"port {self.port} : "
                + (f"arrêté avec le code {exited}" if exited is not None else f"pas prêt en {START_TIMEOUT} s")
                + f" ; sortie d'erreur : {stderr.decode(errors='replace').strip()[-2000:] or '(vide)'}"
            )
            self.process = None
            if exited is None:
                # Serveur lancé mais jamais prêt : un autre port n'y changerait rien
                break
            self.port = free_port()
        raise RuntimeError("Le serveur SurrealDB n'a pas démarré.\n" + "\n".join(failures))

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

    passed: int = 0
    failures: list[str] = field(default_factory=list)


def run_assertions(server: SurrealServer, text: str) -> FileReport:
    report = FileReport()
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


def run_file(server: SurrealServer, path: Path) -> FileReport:
    text = path.read_text()
    head = "\n".join(text.splitlines()[:30])
    if not FORMAT_MARKER.search(head):
        return FileReport(failures=["ligne `-- lyxal-test: assertions` absente des 30 premières lignes"])
    return run_assertions(server, text)


def main() -> int:
    function_files = sorted(f for d in DOMAINS for f in (CORE / d / "functions").glob("*.surql"))
    test_files = sorted(f for d in DOMAINS for f in (CORE / d / "tests").glob("*.surql"))
    failures = []
    for domain in DOMAINS:
        functions = {f.stem for f in (CORE / domain / "functions").glob("*.surql")}
        tests = {f.name for f in (CORE / domain / "tests").glob("*.surql")}
        for name in sorted(functions - {t.removesuffix(".test.surql") for t in tests}):
            failures.append((Path("crates/lyxal_core/functions") / domain / "functions" / f"{name}.surql", "fonction sans fichier de tests"))
        for name in sorted(t for t in tests if not t.endswith(".test.surql") or t.removesuffix(".test.surql") not in functions):
            failures.append((Path("crates/lyxal_core/functions") / domain / "tests" / name, "fichier de tests sans fonction correspondante"))

    with SurrealServer() as server:
        defined = server.load_functions(function_files)
        print(f"Fonctions : {defined} définies / {len(function_files)} fichiers.")
        if defined != len(function_files):
            print("Toutes les fonctions de lyxal_core ne sont pas définies.", file=sys.stderr)
            return 1

        assertions_passed = 0
        for path in test_files:
            report = run_file(server, path)
            assertions_passed += report.passed
            failures += [(path.relative_to(ROOT), message) for message in report.failures]

    print(f"Tests : {len(test_files)} fichiers, {assertions_passed} assertions vérifiées.")
    print(f"Échecs : {len(failures)}.")
    for relative, message in failures:
        print(f"::error file={relative}::{message}")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
