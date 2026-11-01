"""Auto-test de scripts/ci/test_lyxal_core.py : le banc doit accepter les bons tests et rejeter les mauvais.

Charge les fonctions jouets de `scripts/ci/fixtures/lyxal_core_tests/functions.surql`, puis vérifie que :
- `pass.test.surql` passe entièrement ;
- chaque fichier `fail_*.test.surql` produit exactement un échec, du motif attendu.
"""

import importlib.util
import sys
from pathlib import Path

sys.dont_write_bytecode = True  # pas de __pycache__ dans le dépôt

HERE = Path(__file__).resolve().parent
FIXTURES = HERE / "fixtures" / "lyxal_core_tests"

spec = importlib.util.spec_from_file_location("test_lyxal_core", HERE / "test_lyxal_core.py")
bench = importlib.util.module_from_spec(spec)
spec.loader.exec_module(bench)

# Fichier d'échec -> fragment attendu dans le message d'échec.
EXPECTED_FAILURES = {
    "fail_false.test.surql": "renvoie false",
    "fail_not_bool.test.surql": "doit renvoyer true",
    "fail_missing_error.test.surql": "aurait dû lever CORE_INVALID_ARGUMENT, a renvoyé",
    "fail_wrong_error.test.surql": "aurait dû lever CORE_UNSUPPORTED_OPTION, a levé",
    "fail_unexpected_error.test.surql": "erreur inattendue",
    "fail_two_statements.test.surql": "exactement une instruction",
    "fail_statement_before_block.test.surql": "avant le premier bloc",
    "fail_no_block.test.surql": "aucun bloc",
}


def main() -> int:
    problems = []
    with bench.SurrealServer() as server:
        if server.load_functions([FIXTURES / "functions.surql"]) != 2:
            print("Les fonctions jouets ne sont pas toutes définies.", file=sys.stderr)
            return 1

        report = bench.run_file(server, FIXTURES / "pass.test.surql")
        if not report.assertions or report.failures or report.passed != 4:
            problems.append(f"pass.test.surql : attendu 4 assertions réussies, obtenu {report.passed} "
                            f"réussies et {report.failures}")

        fail_files = sorted(p.name for p in FIXTURES.glob("fail_*.test.surql"))
        if fail_files != sorted(EXPECTED_FAILURES):
            problems.append(f"fixtures d'échec inattendues : {fail_files}")
        for name, fragment in EXPECTED_FAILURES.items():
            report = bench.run_file(server, FIXTURES / name)
            if len(report.failures) != 1 or fragment not in report.failures[0]:
                problems.append(f"{name} : attendu un échec contenant « {fragment} », obtenu {report.failures}")

    for problem in problems:
        print(f"::error::{problem}")
    print(f"Auto-test du banc lyxal_core : {1 + len(EXPECTED_FAILURES)} cas, {len(problems)} problème(s).")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
