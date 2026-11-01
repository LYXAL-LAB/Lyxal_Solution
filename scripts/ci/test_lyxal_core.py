"""Rejoue la suite de tests SurrealQL de `lyxal_core` contre un serveur SurrealDB jetable.

1. Démarre `surreal start memory` sur un port libre, avec des identifiants générés.
2. Importe toutes les fonctions de `crates/lyxal_core/functions/*/functions/` et vérifie
   qu'elles sont toutes définies.
3. Exécute chaque fichier de tests et classe chaque instruction :
   - `OK` : retour nominal ;
   - `THROW` : erreur métier attendue (`THROW "<CODE>"`) ;
   - `JSON` : rejet attendu de `encoding::json::decode()` (fichiers de tests `json*`) ;
   - inattendue : toute autre erreur. Le script échoue s'il en existe une.
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
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CORE = ROOT / "crates" / "lyxal_core" / "functions"
DOMAINS = {"validations": "tests", "security": "tests", "sanitize": "tests", "utils": "tests"}
SURREAL = os.environ.get("LYXAL_SURREAL_BIN", "surreal")
NS, DB = "lyxal_core_ci", "lyxal_core_ci"
THROW_CODE = re.compile(r"^(An error occurred: )?'?[A-Z][A-Z0-9_]{3,}'?$")


def free_port() -> int:
    with socket.socket() as sock:
        sock.bind(("127.0.0.1", 0))
        return sock.getsockname()[1]


def sql(port: int, auth: str, body: str) -> list:
    request = urllib.request.Request(
        f"http://127.0.0.1:{port}/sql",
        data=body.encode(),
        headers={
            "Accept": "application/json",
            "Authorization": f"Basic {auth}",
            "surreal-ns": NS,
            "surreal-db": DB,
        },
    )
    with urllib.request.urlopen(request, timeout=120) as response:
        return json.load(response)


def main() -> int:
    function_files = sorted(f for d in DOMAINS for f in (CORE / d / "functions").glob("*.surql"))
    test_files = sorted(f for d, t in DOMAINS.items() for f in (CORE / d / t).glob("*.surql"))

    user, password, port = "core_ci", secrets.token_urlsafe(24), free_port()
    auth = base64.b64encode(f"{user}:{password}".encode()).decode()
    server = subprocess.Popen(
        [SURREAL, "start", "--log", "error", "--user", user, "--pass", password,
         "--bind", f"127.0.0.1:{port}", "memory"],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    try:
        for _ in range(100):
            ready = subprocess.run([SURREAL, "is-ready", "--endpoint", f"http://127.0.0.1:{port}"],
                                   capture_output=True)
            if ready.returncode == 0:
                break
            time.sleep(0.2)
        else:
            print("Le serveur SurrealDB n'a pas démarré.", file=sys.stderr)
            return 1

        with tempfile.NamedTemporaryFile("w", suffix=".surql", delete=False) as bundle:
            bundle.write("OPTION IMPORT;\n")
            for file in function_files:
                bundle.write(file.read_text() + "\n")
        try:
            imported = subprocess.run(
                [SURREAL, "import", "--endpoint", f"http://127.0.0.1:{port}", "--user", user,
                 "--pass", password, "--ns", NS, "--db", DB, bundle.name],
                capture_output=True, text=True,
            )
        finally:
            os.unlink(bundle.name)
        if imported.returncode != 0:
            print(f"Import des fonctions en échec :\n{imported.stderr[-2000:]}", file=sys.stderr)
            return 1

        info = sql(port, auth, "INFO FOR DB;")[0]["result"]
        defined = len(info.get("functions", {}))
        print(f"Fonctions : {defined} définies / {len(function_files)} fichiers.")
        if defined != len(function_files):
            print("Toutes les fonctions de lyxal_core ne sont pas définies.", file=sys.stderr)
            return 1

        counts, unexpected = Counter(), []
        for file in test_files:
            relative = file.relative_to(ROOT)
            try:
                results = sql(port, auth, file.read_text())
            except urllib.error.HTTPError as error:
                unexpected.append((relative, "-", error.read().decode()[:300]))
                continue
            for index, result in enumerate(results):
                if result["status"] == "OK":
                    counts["OK"] += 1
                    continue
                message = str(result["result"]).strip()
                if THROW_CODE.match(message):
                    counts["THROW"] += 1
                elif file.name.startswith("json") and "encoding::json::decode" in message:
                    counts["JSON"] += 1
                else:
                    unexpected.append((relative, index, message[:300]))

        total = sum(counts.values()) + len(unexpected)
        print(f"Tests : {len(test_files)} fichiers, {total} instructions — {counts['OK']} OK, "
              f"{counts['THROW']} THROW métier, {counts['JSON']} rejets JSON, "
              f"{len(unexpected)} erreur(s) inattendue(s).")
        for relative, index, message in unexpected:
            print(f"::error file={relative}::instruction {index} : {message}")
        return 1 if unexpected else 0
    finally:
        server.terminate()
        server.wait(timeout=10)


if __name__ == "__main__":
    sys.exit(main())
