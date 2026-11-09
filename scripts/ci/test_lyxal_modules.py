"""Rejoue les tests SurrealQL des modules Lyxal contre un serveur SurrealDB jetable.

Un module est testé s'il a un `manifest.toml` et des fichiers `tests/*.test.surql`
(`lyxal_core` a son propre banc : `test_lyxal_core.py`).

Pour chaque fichier de tests :

1. une base neuve est créée ; le module et ses dépendances y sont installés depuis leurs
   manifestes (phases `schemas`, `functions`, `error_definitions`, `events`, `seeds`,
   `migrations`, dans l'ordre déclaré), comme le fait `lyxal_runtime` ;
2. un accès `lyxal_test` (`TYPE RECORD WITH JWT`, HS512, clé aléatoire) y est défini, pour
   exécuter des blocs sous l'identité d'un utilisateur ;
3. les blocs `-- test:` sont exécutés dans l'ordre, chacun dans sa propre requête : les
   enregistrements créés par un bloc restent visibles des blocs suivants.

Format (en plus du format « assertions » de `test_lyxal_core.py`) :

    -- lyxal-test: assertions
    -- identité alpha: { "id": "auth_session:alpha", "pv": 1, "permissions": ["catalogue.item.read", "catalogue.item.manage"] }

    -- test: Alpha crée son article privé
    -- en tant que: alpha
    RETURN fn::catalogue_item_create({ ... }).ok;

* `-- identité <nom>: <objet JSON>` (avant le premier test) déclare les claims d'un jeton ;
  le script ajoute `ns`, `db`, `ac`, `iat`, `nbf`, `exp` et `jti`, et signe le jeton.
* `-- en tant que: <nom>` exécute le bloc sous cette identité (sinon : session root).
* `-- préparation: <nom>` ouvre un bloc qui doit seulement réussir (sa valeur est ignorée) :
  données de départ, ou table de test lisible par tous pour passer un identifiant d'une
  identité à une autre.
* `-- attendu-erreur: <CODE>` attend une erreur dont le code est `<CODE>` : `THROW "<CODE>"`
  ou `THROW "<CODE>: message"`, y compris levé par un `DEFINE EVENT`.

Chaque fonction publique du module (`fn::<préfixe>_*` définie dans `functions/`) doit être
appelée par au moins un test.
"""

import base64
import hashlib
import hmac
import json
import re
import secrets
import subprocess
import sys
import tempfile
import time
import tomllib
import urllib.error
import urllib.request
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.dont_write_bytecode = True
import test_lyxal_core as core  # noqa: E402

ROOT = core.ROOT
CRATES = ROOT / "crates"
PHASES = ("schemas", "functions", "error_definitions", "events", "seeds", "migrations")
NS = "lyxal_modules_ci"
ACCESS = "lyxal_test"

SETUP_MARKER = re.compile(r"^--\s*préparation\s*:\s*(.*)$")
IDENTITY_MARKER = re.compile(r"^--\s*identité\s+([a-z0-9_]+)\s*:\s*(\{.*\})\s*$")
AS_MARKER = re.compile(r"^--\s*en tant que\s*:\s*([a-z0-9_]+)\s*$")
FUNCTION_DEF = re.compile(r"DEFINE\s+FUNCTION\s+OVERWRITE\s+fn::([a-z0-9_]+)\s*\(", re.I)
THROWN = re.compile(r"An error occurred:\s*'?\"?([A-Z][A-Z0-9_]*)")


def manifest(module: str) -> dict:
    return tomllib.loads((CRATES / module / "manifest.toml").read_text())


def install_order(module: str) -> list[str]:
    """Le module et ses dépendances, dépendances d'abord (ordre topologique)."""
    order: list[str] = []

    def visit(name: str, path: tuple[str, ...]) -> None:
        if name in path:
            raise RuntimeError(f"Dépendance circulaire : {' -> '.join(path + (name,))}")
        if name in order:
            return
        for dependency in manifest(name).get("dependencies", []):
            visit(dependency["id"], path + (name,))
        order.append(name)

    visit(module, ())
    return order


def resources(module: str) -> list[Path]:
    declared = manifest(module).get("resources", {})
    return [CRATES / module / file for phase in PHASES for file in declared.get(phase, [])]


def thrown_code(message: str) -> str:
    match = THROWN.search(message)
    return match.group(1) if match else core.thrown_code(message)


def b64(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()


class ModuleDatabase:
    """Base neuve d'un serveur jetable, où un module et ses dépendances sont installés."""

    def __init__(self, server: core.SurrealServer, module: str, name: str) -> None:
        self.server, self.module, self.db = server, module, name
        self.key = secrets.token_hex(32)

    def install(self) -> None:
        with tempfile.NamedTemporaryFile("w", suffix=".surql", delete=False) as bundle:
            bundle.write("OPTION IMPORT;\n")
            for name in install_order(self.module):
                for file in resources(name):
                    bundle.write(file.read_text() + "\n")
            bundle.write(f'DEFINE ACCESS {ACCESS} ON DATABASE TYPE RECORD WITH JWT ALGORITHM HS512 KEY "{self.key}";\n')
        try:
            imported = subprocess.run(
                [core.SURREAL, "import", "--endpoint", self.server.endpoint, "--user", self.server.user,
                 "--pass", self.server.password, "--ns", NS, "--db", self.db, bundle.name],
                capture_output=True, text=True,
            )
        finally:
            Path(bundle.name).unlink()
        if imported.returncode != 0:
            raise RuntimeError(f"Installation de {self.module} en échec :\n{imported.stderr[-2000:]}")

    def token(self, claims: dict) -> str:
        now = int(time.time())
        payload = {"ns": NS, "db": self.db, "ac": ACCESS, "iat": now, "nbf": now, "exp": now + 900,
                   "jti": secrets.token_hex(8)} | claims
        signing_input = f"{b64(json.dumps({'alg': 'HS512', 'typ': 'JWT'}).encode())}.{b64(json.dumps(payload).encode())}"
        signature = hmac.new(self.key.encode(), signing_input.encode(), hashlib.sha512).digest()
        return f"{signing_input}.{b64(signature)}"

    def sql(self, body: str, token: str | None = None) -> list:
        authorization = f"Bearer {token}" if token else f"Basic {self.server.auth}"
        request = urllib.request.Request(
            f"{self.server.endpoint}/sql", data=body.encode(),
            headers={"Accept": "application/json", "Authorization": authorization,
                     "surreal-ns": NS, "surreal-db": self.db},
        )
        with urllib.request.urlopen(request, timeout=120) as response:
            return json.load(response)


def parse(text: str) -> tuple[dict, list[dict], list[str]]:
    identities, blocks, problems, current = {}, [], [], None
    for line in text.splitlines():
        stripped = line.strip()
        test, setup = core.TEST_MARKER.match(stripped), SETUP_MARKER.match(stripped)
        identity = IDENTITY_MARKER.match(stripped)
        if test or setup:
            name = (test or setup).group(1).strip() or "(sans nom)"
            current = {"name": name, "lines": [], "as": None, "error": None, "setup": bool(setup)}
            blocks.append(current)
        elif identity and current is None:
            try:
                identities[identity.group(1)] = json.loads(identity.group(2))
            except json.JSONDecodeError as error:
                problems.append(f"identité « {identity.group(1)} » : JSON invalide ({error})")
        elif current is None:
            if stripped and not stripped.startswith("--"):
                problems.append("instruction placée avant le premier bloc `-- test:`")
        else:
            as_marker, error_marker = AS_MARKER.match(stripped), core.ERROR_MARKER.match(stripped)
            if as_marker:
                current["as"] = as_marker.group(1)
            elif error_marker:
                current["error"] = error_marker.group(1)
            else:
                current["lines"].append(line)
    if not any(not block["setup"] for block in blocks):
        problems.append("aucun bloc `-- test:`")
    return identities, blocks, problems


def run_file(server: core.SurrealServer, module: str, path: Path, index: int) -> tuple[int, list[str], str]:
    text = path.read_text()
    if not core.FORMAT_MARKER.search("\n".join(text.splitlines()[:30])):
        return 0, ["ligne `-- lyxal-test: assertions` absente des 30 premières lignes"], text
    identities, blocks, failures = parse(text)
    database = ModuleDatabase(server, module, f"t{index}")
    database.install()
    tokens = {name: database.token(claims) for name, claims in identities.items()}
    passed = 0
    for block in blocks:
        label = f"« {block['name']} »"
        if block["as"] and block["as"] not in tokens:
            failures.append(f"{label} : identité « {block['as']} » non déclarée")
            continue
        try:
            results = database.sql("\n".join(block["lines"]), tokens.get(block["as"]))
        except urllib.error.HTTPError as error:
            failures.append(f"{label} : requête refusée : {error.read().decode()[:300]}")
            continue
        if len(results) != 1:
            failures.append(f"{label} : un bloc doit contenir exactement une instruction ({len(results)} trouvées)")
            continue
        status, value = results[0]["status"], results[0]["result"]
        if block["error"]:
            if status == "OK":
                failures.append(f"{label} : aurait dû lever {block['error']}, a renvoyé {json.dumps(value, ensure_ascii=False)[:200]}")
            elif thrown_code(str(value)) != block["error"]:
                failures.append(f"{label} : aurait dû lever {block['error']}, a levé {str(value)[:300]}")
            else:
                passed += 1
        elif status != "OK":
            failures.append(f"{label} : erreur inattendue : {str(value)[:300]}")
        elif block["setup"]:
            continue
        elif value is True:
            passed += 1
        else:
            failures.append(f"{label} : doit renvoyer true, a renvoyé {json.dumps(value, ensure_ascii=False)[:300]}")
    return passed, failures, text


def public_functions(module: str) -> set[str]:
    prefix = module.removeprefix("lyxal_") + "_"
    names = set()
    for file in (CRATES / module / "functions").rglob("*.surql"):
        names |= {name for name in FUNCTION_DEF.findall(file.read_text()) if name.startswith(prefix)}
    return names


def main() -> int:
    modules = sorted(d.name for d in CRATES.iterdir()
                     if d.name != "lyxal_core" and (d / "manifest.toml").exists() and list((d / "tests").glob("*.test.surql")))
    failures, passed, files = [], 0, 0
    with core.SurrealServer() as server:
        for module in modules:
            called = ""
            for path in sorted((CRATES / module / "tests").glob("*.test.surql")):
                files += 1
                try:
                    ok, problems, text = run_file(server, module, path, files)
                except RuntimeError as error:
                    ok, problems, text = 0, [str(error)], ""
                passed += ok
                called += text
                failures += [(path.relative_to(ROOT), problem) for problem in problems]
            for name in sorted(public_functions(module)):
                if not re.search(rf"fn::{name}\s*\(", called):
                    failures.append((Path("crates") / module / "functions", f"fn::{name} n'est appelée par aucun test"))
    print(f"Modules : {', '.join(modules) or 'aucun'}.")
    print(f"Tests : {files} fichiers, {passed} assertions vérifiées.")
    print(f"Échecs : {len(failures)}.")
    for relative, message in failures:
        print(f"::error file={relative}::{message}")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
