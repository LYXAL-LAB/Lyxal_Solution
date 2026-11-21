#!/usr/bin/env python3
"""Banc de mesure du moteur `fn::utils_engine_*` de `lyxal_core` (décision P2, lot 4e-1).

Démarre un serveur `surreal` jetable en mémoire (comme `scripts/ci/test_lyxal_core.py`), charge
les fonctions de `lyxal_core`, puis mesure **dans le serveur** (`time::now()` autour de chaque
appel, sans authentification ni transport HTTP) la durée d'un appel :

  * `fn::validation_object_execute` sur un objet de 3 champs ;
  * `fn::validation_object_execute` sur les paramètres de `fn::mail_message_create` (schéma
    recopié de `crates/lyxal_mail/functions/mail_message.surql`, enveloppe typée comprise) ;
  * `fn::validation_pipeline_execute`, `fn::sanitize_object_execute`,
    `fn::security_object_execute` sur un petit objet ;
  * `fn::utils_collection_sort_by` sur 1 000 et 10 000 objets (clés aléatoires, doublons et
    clés absentes compris).

Chaque cas est contrôlé (un rapport de validation doit être valide), exécuté `--warmup` fois puis
`--repeat` fois ; le banc affiche la médiane, le 95e centile et le minimum en millisecondes. Une
requête qui dépasse `--timeout` secondes est notée comme telle. `--ref` mesure les fonctions d'une
autre révision Git (mesure « avant »). Hors CI. Usage :

    python3 -I scripts/bench/core/bench_core_engine.py --repeat 50 --out apres.json
    python3 -I scripts/bench/core/bench_core_engine.py --ref <révision> --timeout 120 --out avant.json

Binaire : `${LYXAL_SURREAL_BIN:-surreal}` (3.3.4).
"""

import argparse
import json
import platform
import statistics
import subprocess
import sys
import tempfile
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "scripts" / "ci"))
sys.dont_write_bytecode = True
import test_lyxal_core as core  # noqa: E402

THREE_FIELDS = """
fn::validation_object_execute({ email: "  contact@example.com ", name: "Jean Dupont", age: 42 }, {
    fields: {
        email: { pipeline: [{ rule: "email", options: { max_length: 254 } }], required: true },
        name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 100 } }], required: true },
        age: { pipeline: [{ rule: "integer" }, { rule: "percentage", options: { min_value: 0, max_value: 150 } }] }
    },
    unknown_keys: "strip"
}, 20)
"""

# Schéma de fn::mail_message_create (crates/lyxal_mail/functions/mail_message.surql), règles
# internes fn::mail_keywords_rule développée sur place.
MAIL_SPEC = """
LET $text = |$max| { pipeline: [{ rule: "optional_string", options: { max_length: $max } }] };
LET $ids = |$max| { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true, max_length: 2048 } }, { rule: "array_length", options: { max_length: $max } }] };
LET $list = { pipeline: [{ rule: "array_length", options: { max_length: 1000 } }, { rule: "each", options: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: {
    fields: { name: $text(2048), address: $text(2048), group: $text(2048) }, unknown_keys: "reject"
} } }] } }] };
LET $keywords = { pipeline: [
    { rule: "array_length", options: { max_length: 1000 } },
    { rule: "each", options: { pipeline: [
        { rule: "required_string", options: { min_length: 1, max_length: 128 } },
        { rule: "regex", options: { pattern: "^[\\\\x21\\\\x23\\\\x24\\\\x26\\\\x27\\\\x2B-\\\\x5B\\\\x5E-\\\\x7A\\\\x7C-\\\\x7E]+$" } }
    ] } }
] };
LET $mail_schema = {
    fields: {
        content: { pipeline: [{ rule: "record", options: { expected_table: "mail_content" } }], required: true },
        mailbox: { pipeline: [{ rule: "record", options: { expected_table: "mail_mailbox" } }], required: true },
        received_at: { pipeline: [{ rule: "datetime" }], required: true },
        sent_at: { pipeline: [{ rule: "datetime" }] },
        seen: { pipeline: [{ rule: "boolean" }], default: false },
        answered: { pipeline: [{ rule: "boolean" }], default: false },
        flagged: { pipeline: [{ rule: "boolean" }], default: false },
        deleted: { pipeline: [{ rule: "boolean" }], default: false },
        draft: { pipeline: [{ rule: "boolean" }], default: false },
        keywords: $keywords,
        message_id: $text(2048),
        in_reply_to: $ids(100),
        references: $ids(1000),
        base_subject: $text(16384),
        is_report: { pipeline: [{ rule: "boolean" }], default: false },
        envelope: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: {
            fields: {
                date: { pipeline: [{ rule: "datetime" }] }, subject: $text(16384), message_id: $text(2048),
                in_reply_to: $ids(100), references: $ids(1000),
                from: $list, sender: $list, reply_to: $list, to: $list, cc: $list, bcc: $list
            },
            unknown_keys: "reject"
        } } }] },
        structure: { pipeline: [{ rule: "is_object" }, { rule: "max_serialized_length", options: { max_length: 1048576 } }] },
        has_attachment: { pipeline: [{ rule: "boolean" }], default: false },
        language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
    },
    unknown_keys: "reject"
};
LET $mail_params = {
    content: "mail_content:c1",
    mailbox: "mail_mailbox:inbox",
    received_at: d"2026-11-21T10:00:00Z",
    sent_at: d"2026-11-21T09:59:00Z",
    seen: false,
    flagged: true,
    keywords: ["$seen", "projet", "urgent"],
    message_id: "<m1@example.com>",
    in_reply_to: ["<m0@example.com>"],
    references: ["<r1@example.com>", "<r2@example.com>", "<m0@example.com>"],
    base_subject: "Réunion de chantier",
    envelope: {
        date: d"2026-11-21T09:59:00Z",
        subject: "Re: Réunion de chantier",
        message_id: "<m1@example.com>",
        in_reply_to: ["<m0@example.com>"],
        references: ["<r1@example.com>", "<r2@example.com>", "<m0@example.com>"],
        from: [{ name: "Jean Dupont", address: "jean@example.com" }],
        to: [{ name: "Marie", address: "marie@example.com" }, { address: "paul@example.com" }],
        cc: [{ name: "Équipe", group: "equipe" }]
    },
    structure: { type: "multipart/mixed", parts: [{ type: "text/plain", size: 1200 }, { type: "application/pdf", size: 40960, name: "plan.pdf" }] },
    has_attachment: true
};
"""

MAIL = "fn::validation_object_execute($mail_params, $mail_schema, 40)"

PIPELINE = """
fn::validation_pipeline_execute(["a", "b", "c"], [{ rule: "array_length", options: { max_length: 10 } },
    { rule: "each", options: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 10 } }] } }], 10)
"""

SANITIZE = """
fn::sanitize_object_execute({ email: "  Contact@Example.COM ", name: "  Jean   Dupont " }, {
    fields: {
        email: { pipeline: [{ rule: "trim" }, { rule: "lowercase" }] },
        name: { pipeline: [{ rule: "collapse_whitespace" }] }
    },
    unknown_keys: "keep"
}, 20)
"""

SECURITY = """
fn::security_object_execute({ comment: "<script>alert(1)</script>", token: "secret-123" }, {
    fields: {
        comment: { pipeline: [{ rule: "detect_xss" }] },
        token: { pipeline: [{ rule: "secret_mask" }] }
    },
    unknown_keys: "keep"
}, 20)
"""

SORT_DATA = """
LET $items_{n} = (<array> (0..{n})).map(|$i| IF $i % 97 = 0 {{ {{ id: $i }} }} ELSE {{ {{ id: $i, k: rand::int(0, {n} / 4) }} }});
"""

CASES = [
    ("validation_object_execute, 3 champs", "", THREE_FIELDS),
    ("validation_object_execute, paramètres de fn::mail_message_create", MAIL_SPEC, MAIL),
    ("validation_pipeline_execute, tableau de 3 chaînes", "", PIPELINE),
    ("sanitize_object_execute, 2 champs", "", SANITIZE),
    ("security_object_execute, 2 champs", "", SECURITY),
    ("utils_collection_sort_by, 1 000 objets", SORT_DATA.format(n=1000), 'fn::utils_collection_sort_by($items_1000, "k", "asc")'),
    ("utils_collection_sort_by, 10 000 objets", SORT_DATA.format(n=10000), 'fn::utils_collection_sort_by($items_10000, "k", "desc")'),
]


def sql(server: core.SurrealServer, body: str, timeout: float) -> list:
    request = urllib.request.Request(
        f"{server.endpoint}/sql",
        data=body.encode(),
        headers={"Accept": "application/json", "Authorization": f"Basic {server.auth}",
                 "surreal-ns": core.NS, "surreal-db": core.DB},
    )
    with urllib.request.urlopen(request, timeout=timeout) as response:
        return json.load(response)


def measure(server: core.SurrealServer, setup: str, call: str, warmup: int, repeat: int, timeout: float) -> list[float]:
    """Durées d'un appel en millisecondes, mesurées dans le serveur ; le premier appel est contrôlé."""
    checked = sql(server, setup + f"RETURN {call};", timeout)
    failed = [r for r in checked if r["status"] != "OK"]
    if failed:
        raise RuntimeError(f"Requête en échec : {failed[0]['result']}")
    result = checked[-1]["result"]
    if isinstance(result, dict) and result.get("valid") is False:
        raise RuntimeError(f"Données du banc refusées : {json.dumps(result.get('by_field'), ensure_ascii=False)}")
    body = setup + f"""
LET $warm = (<array> (0..{warmup})).map(|$i| {call});
RETURN (<array> (0..{repeat})).map(|$i| {{
    LET $started = time::now();
    LET $result = {call};
    RETURN duration::micros(time::now() - $started);
}});
"""
    return [micros / 1000.0 for micros in sql(server, body, timeout)[-1]["result"]]


def summary(samples: list[float]) -> dict:
    ordered = sorted(samples)
    return {
        "p50_ms": round(statistics.median(ordered), 2),
        "p95_ms": round(ordered[min(len(ordered) - 1, int(len(ordered) * 0.95))], 2),
        "min_ms": round(ordered[0], 2),
        "samples": len(ordered),
    }


def function_files(ref: str | None, workdir: Path) -> list[Path]:
    """Fichiers de fonctions de lyxal_core : ceux de la copie de travail, ou ceux d'une révision (--ref)."""
    root = core.CORE
    if ref:
        archive = subprocess.run(["git", "-C", str(ROOT), "archive", ref, "crates/lyxal_core/functions"],
                                 capture_output=True, check=True).stdout
        subprocess.run(["tar", "-x", "-C", str(workdir)], input=archive, check=True)
        root = workdir / "crates" / "lyxal_core" / "functions"
    return sorted(f for d in core.DOMAINS for f in (root / d / "functions").glob("*.surql"))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--repeat", type=int, default=30)
    parser.add_argument("--warmup", type=int, default=3)
    parser.add_argument("--sort-repeat", type=int, default=5, help="répétitions des tris (plus longs)")
    parser.add_argument("--timeout", type=float, default=300, help="durée maximale d'une requête du banc, en secondes")
    parser.add_argument("--ref", help="révision Git dont les fonctions sont mesurées (mesure « avant »)")
    parser.add_argument("--only", help="ne mesure que les cas dont le libellé contient ce texte")
    parser.add_argument("--out", type=Path)
    args = parser.parse_args()

    report = {"surreal": core.SURREAL, "machine": platform.platform(), "ref": args.ref or "copie de travail", "cases": {}}
    with tempfile.TemporaryDirectory() as workdir:
        files = function_files(args.ref, Path(workdir))
        server = None
        try:
            for label, setup, call in CASES:
                if args.only and args.only not in label:
                    continue
                if server is None:
                    # Serveur neuf au départ, et après un dépassement de délai (requête encore en cours)
                    server = core.SurrealServer().__enter__()
                    server.load_functions(files)
                is_sort = "sort_by" in label
                repeat = args.sort_repeat if is_sort else args.repeat
                warmup = 1 if is_sort else args.warmup
                try:
                    stats = summary(measure(server, setup, call, warmup, repeat, args.timeout))
                except TimeoutError:
                    report["cases"][label] = {"timeout_s": args.timeout}
                    print(f"{label:<70} plus de {args.timeout:.0f} s", flush=True)
                    server.__exit__(None, None, None)
                    server = None
                    continue
                report["cases"][label] = stats
                print(f"{label:<70} p50 {stats['p50_ms']:>9.2f} ms   p95 {stats['p95_ms']:>9.2f} ms   min {stats['min_ms']:>9.2f} ms", flush=True)
        finally:
            if server is not None:
                server.__exit__(None, None, None)
    if args.out:
        args.out.write_text(json.dumps(report, indent=2, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
