#!/usr/bin/env python3
"""Banc SurrealQL de la remise d'un message reçu (plan de performance, sous-lot 0).

Démarre un serveur `surreal` jetable en mémoire, y installe `lyxal_mail` et ses dépendances comme
le fait `scripts/ci/test_lyxal_modules.py`, puis mesure **dans le serveur** (`time::now()` avant
et après chaque appel) les fonctions publiques qu'une remise appelle. Chaque instruction d'une
requête HTTP `/sql` est sa propre transaction, comme un appel de `call_fn`. Quatre mesures :

  * `remise`  : une remise, poste par poste (`fn::mail_delivery_begin`,
    `fn::storage_object_begin`, `fn::secrets_tenant_key_ring`, `fn::storage_object_commit`,
    `fn::mail_delivery_commit`), chaque appel dans sa transaction ; moyenne et médiane ;
  * `appels`  : premier et deuxième appel d'une même expression dans une transaction (le
    premier paie le chargement des définitions de fonctions, le deuxième non) ; médianes ;
  * `lots`    : `fn::mail_delivery_commit` seule, par message, selon la taille du lot (8, 16 et
    32 messages) et celle de l'enveloppe (3 ou 150 destinataires) ; médianes ;
  * `clients` : débit avec 1 à 16 clients, une connexion HTTP chacun, chacun dans son
    organisation (`organisations`) puis tous dans la même (`organisation`).

En fin de mesure `clients`, la cohérence est contrôlée : compteurs des comptes égaux aux messages,
UID uniques par dossier. Le banc n'écrit aucun fichier et ne chiffre rien : il mesure le temps de
calcul de la base (le banc Rust `crates/lyxal_mail/tests/it/measures.rs` mesure la remise
entière). `--ref` mesure les modules d'une autre révision Git (mesure « avant »). Hors CI. Usage :

    python3 -I scripts/bench/delivery/bench_delivery.py --out apres.json
    python3 -I scripts/bench/delivery/bench_delivery.py --ref <révision> --out avant.json
    python3 -I scripts/bench/delivery/bench_delivery.py --only remise,appels --deliveries 300
    python3 -I scripts/bench/delivery/bench_delivery.py --only lots --lots 8x3,32x3,8x150

Binaire : `${LYXAL_SURREAL_BIN:-surreal}` (3.3.4).
"""

import argparse
import collections
import http.client
import json
import platform
import secrets
import statistics
import subprocess
import sys
import tempfile
import threading
import time
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "scripts" / "ci"))
sys.dont_write_bytecode = True
import test_lyxal_core as core  # noqa: E402
import test_lyxal_modules as mods  # noqa: E402

MODULE = "lyxal_mail"
STEPS = ["fn::mail_delivery_begin", "fn::storage_object_begin", "fn::secrets_tenant_key_ring",
         "fn::storage_object_commit", "fn::mail_delivery_commit"]
# Clé scellée d'essai : seule sa forme est contrôlée (le banc ne chiffre rien)
CONTENT_KEY = "enc:v2:k1:" + "A" * 86
CHALLENGE_HASH = "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262"

# Paramètres d'une ouverture de remise, contrôlés par les trois formes comparées dans `appels`
OPENING = "{ account: 'mail_account:abc', size: 10240, delivery_key: string::repeat('a', 64) }"
ENGINE_ONE = """fn::validation_object_execute({ a: 'mail_content:c' }, { fields: {
    a: { pipeline: [{ rule: "record", options: { expected_table: "mail_content" } }], required: true } }, unknown_keys: "reject" }, 20)"""
ENGINE_OPENING = f"""fn::validation_object_execute({OPENING}, {{ fields: {{
    account: {{ pipeline: [{{ rule: "record", options: {{ expected_table: "mail_account" }} }}], required: true }},
    size: {{ pipeline: [{{ rule: "integer", options: {{ min_value: 1, max_value: 5368709120 }} }}], required: true }},
    delivery_key: {{ pipeline: [{{ rule: "hexadecimal", options: {{ min_length: 64, max_length: 64, allow_prefix: false }} }}], required: true }},
    language: {{ pipeline: [{{ rule: "language_code", options: {{ allow_alpha3: false }} }}], default: "fr" }} }}, unknown_keys: "reject" }}, 20)"""
FIELDS_ONE = """fn::validation_fields_execute({ a: 'mail_content:c' }, {
    a: { checks: [|$v: any| fn::validation_record($v, "mail_content")], required: true } }, "reject")"""
FIELDS_OPENING = f"""fn::validation_fields_execute({OPENING}, {{
    account: {{ checks: [|$v: any| fn::validation_record($v, "mail_account")], required: true }},
    size: {{ checks: [|$v: any| fn::validation_integer($v, 1, 5368709120)], required: true }},
    delivery_key: {{ checks: [|$v: any| fn::validation_hexadecimal($v, 64, 64, false)], required: true }},
    language: {{ checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }} }}, "reject")"""
PRIMITIVES_OPENING = """{ account: fn::validation_record('mail_account:abc', "mail_account"), size: fn::validation_integer(10240, 1, 5368709120),
    delivery_key: fn::validation_hexadecimal(string::repeat('a', 64), 64, 64, false), language: fn::validation_language_code('fr', false, NONE) }"""
STEP_APPLY = """fn::validation_step_apply(fn::utils_engine_state('mail_content:c', 'a', NONE), { rule: 'record', value: NONE, options: { expected_table: 'mail_content' } })"""


class Bench:
    """Base du serveur jetable où `lyxal_mail` est installé, jointe sous la session système."""

    def __init__(self, server: core.SurrealServer, name: str, timeout: float) -> None:
        self.server, self.timeout = server, timeout
        self.database = mods.ModuleDatabase(server, MODULE, name)
        self.database.install()

    def sql(self, body: str) -> list:
        """Exécute une requête ; lève si une instruction échoue."""
        request = urllib.request.Request(
            f"{self.server.endpoint}/sql", data=body.encode(),
            headers={"Accept": "application/json", "Authorization": f"Basic {self.server.auth}",
                     "surreal-ns": mods.NS, "surreal-db": self.database.db},
        )
        with urllib.request.urlopen(request, timeout=self.timeout) as response:
            results = json.load(response)
        failed = [r for r in results if r["status"] != "OK"]
        if failed:
            raise RuntimeError(f"Requête en échec : {json.dumps(failed[0], ensure_ascii=False)[-2000:]}")
        return results

    def root_token(self) -> str:
        """Jeton de la session système : une requête sous jeton ne paie pas l'authentification Basic."""
        request = urllib.request.Request(
            f"{self.server.endpoint}/signin",
            data=json.dumps({"user": self.server.user, "pass": self.server.password}).encode(),
            headers={"Accept": "application/json", "Content-Type": "application/json"},
        )
        with urllib.request.urlopen(request, timeout=self.timeout) as response:
            return json.load(response)["token"]

    def organisation(self, slug: str, accounts: int, quota: int | None = None) -> dict:
        """Crée une organisation, son domaine de courrier, son bucket chiffré et ses comptes ;
        `quota` : quota de volume de l'organisation, en octets (aucun par défaut)."""
        body = f"""
CREATE auth_organization:{slug} CONTENT {{ slug: '{slug}', name: 'Organisation {slug}' }};
CREATE auth_organization_domain:{slug} CONTENT {{ organization: auth_organization:{slug}, domain: '{slug}.test', state: 'verified', challenge_hash: '{CHALLENGE_HASH}' }};
LET $domain = fn::mail_domain_create({{ auth_domain: 'auth_organization_domain:{slug}' }});
LET $bucket = fn::storage_bucket_create({{ tenant: 'auth_organization:{slug}', name: 'lyxal-mail', encrypted: true, emit_events: false, backend: 'default', description: 'banc' }});
"""
        for index in range(accounts):
            body += f"""
CREATE auth_identity:{slug}u{index} CONTENT {{ schema: auth_identity_schema:default_v1, traits: {{ email: '{slug}u{index}@lyxal.test' }} }};
RELATE auth_identity:{slug}u{index}->auth_member_of->auth_organization:{slug};
LET $account{index} = fn::mail_account_create({{ identity: 'auth_identity:{slug}u{index}', domain: <string> $domain.data.id, local_part: 'u{index}' }});
"""
        made = ", ".join(f"$account{index}" for index in range(accounts))
        settings = "{ ok: true }" if quota is None else f"fn::storage_settings_set({{ tenant: 'auth_organization:{slug}', quota_bytes: {quota} }})"
        body += f"""
LET $settings = {settings};
RETURN {{ errors: [$domain, $bucket, $settings, {made}].map(|$made| $made.error)[WHERE $this IS NOT NONE],
    bucket: <string> $bucket.data.id, accounts: [{made}].map(|$made| <string> $made.data.account.id) }};
"""
        layout = self.sql(body)[-1]["result"]
        if layout["errors"]:
            raise RuntimeError(f"Préparation de l'organisation {slug} en échec : {json.dumps(layout['errors'], ensure_ascii=False)[:2000]}")
        return {"slug": slug, "bucket": layout["bucket"], "accounts": layout["accounts"]}


def item(begin: str, opened: str, key: str, tag: str, to: list[tuple[str, str]], cc: list[tuple[str, str]]) -> str:
    """Élément de `fn::mail_delivery_commit` : contenu réservé (`begin`) et fichier écrit (`opened`), variables de la requête."""
    def people(rows: list[tuple[str, str]]) -> str:
        return "[" + ", ".join(f"{{ name: '{name}', address: '{address}' }}" for name, address in rows) + "]"
    return f"""{{
    content: <string> {begin}.data.content, object: <string> {opened}.data.id, role: 'inbox', received_at: time::now(), delivery_key: '{key}',
    message_id: 'm{tag}@ailleurs.test', in_reply_to: [], references: [], base_subject: 'compte rendu de chantier', is_report: false,
    envelope: {{ date: time::now(), subject: 'Compte rendu de chantier {tag}', message_id: 'm{tag}@ailleurs.test',
        from: [{{ name: 'Paul', address: 'paul@ailleurs.test' }}],
        to: {people(to)},
        cc: {people(cc)} }},
    structure: {{ }}, has_attachment: false,
    reception: {{ spf: 'pass', dkim: 'pass', dmarc: 'pass', iprev: 'pass', antivirus: 'not_scanned', spam: 'none', tls: true }} }}"""


def delivery(organisation: dict, account: str, tag: str) -> str:
    """Requête d'une remise : cinq appels publics, chacun dans sa transaction, et leurs durées."""
    key, checksum = secrets.token_hex(32), secrets.token_hex(32)
    one = item("$begin", "$opened", key, tag, [("Jean", "jean@alpha.test"), ("Marie", "marie@alpha.test")], [("Chantier", "chantier@alpha.test")])
    return f"""
LET $t0 = time::now();
LET $begin = fn::mail_delivery_begin({{ account: '{account}', size: 10240, delivery_key: '{key}' }});
LET $t1 = time::now();
LET $opened = fn::storage_object_begin({{ bucket: '{organisation["bucket"]}', key: $begin.data.storage_key, filename: 'message.eml', declared_type: 'message/rfc822', declared_size: 10240, resumable: false }});
LET $t2 = time::now();
LET $ring = fn::secrets_tenant_key_ring({{ tenant: 'auth_organization:{organisation["slug"]}', purpose: 'files' }});
LET $t3 = time::now();
LET $written = fn::storage_object_commit({{ object: <string> $opened.data.id, size: 10240, content_type: 'message/rfc822', blake3: '{checksum}', content_key: '{CONTENT_KEY}' }});
LET $t4 = time::now();
LET $commit = fn::mail_delivery_commit({{ account: '{account}', items: [{one}] }});
LET $t5 = time::now();
RETURN {{
    errors: [$begin.error, $opened.error, $ring.error, $written.error, $commit.error, $commit.data.items[0].error][WHERE $this IS NOT NONE],
    micros: [duration::micros($t1 - $t0), duration::micros($t2 - $t1), duration::micros($t3 - $t2), duration::micros($t4 - $t3), duration::micros($t5 - $t4)]
}};
"""


def batch(organisation: dict, account: str, tag: str, size: int, recipients: int) -> str:
    """Requête d'un lot : `size` contenus réservés et fichiers écrits (hors mesure), puis une seule
    `fn::mail_delivery_commit` mesurée ; enveloppe de `recipients` destinataires par message."""
    to = [(f"Destinataire {index}", f"destinataire{index}@alpha.test") for index in range(recipients)]
    body, items = "", []
    for index in range(size):
        key, checksum = secrets.token_hex(32), secrets.token_hex(32)
        body += f"""
LET $begin{index} = fn::mail_delivery_begin({{ account: '{account}', size: 10240, delivery_key: '{key}' }});
LET $opened{index} = fn::storage_object_begin({{ bucket: '{organisation["bucket"]}', key: $begin{index}.data.storage_key, filename: 'message.eml', declared_type: 'message/rfc822', declared_size: 10240, resumable: false }});
LET $written{index} = fn::storage_object_commit({{ object: <string> $opened{index}.data.id, size: 10240, content_type: 'message/rfc822', blake3: '{checksum}', content_key: '{CONTENT_KEY}' }});
"""
        items.append(item(f"$begin{index}", f"$opened{index}", key, f"{tag}x{index}", to, []))
    prepared = ", ".join(f"$begin{index}.error, $opened{index}.error, $written{index}.error" for index in range(size))
    return body + f"""
LET $t0 = time::now();
LET $commit = fn::mail_delivery_commit({{ account: '{account}', items: [{", ".join(items)}] }});
LET $t1 = time::now();
RETURN {{
    errors: array::concat([{prepared}, $commit.error], $commit.data.items.error ?? [])[WHERE $this IS NOT NONE],
    inscribed: count($commit.data.items[WHERE duplicate == false]),
    micros: duration::micros($t1 - $t0)
}};
"""


def measure_batches(bench: Bench, shapes: list[tuple[int, int]], repeat: int, warmup: int) -> dict:
    """`fn::mail_delivery_commit` par message selon la taille du lot et de l'enveloppe : médianes en millisecondes."""
    organisation = bench.organisation("gamma", len(shapes))
    report = {}
    print(f"\nfn::mail_delivery_commit par message, selon le lot (médianes de {repeat} lots, ms)")
    print(f"{'':<34} {'par message':>12} {'lot entier':>12}")
    for account, (size, recipients) in zip(organisation["accounts"], shapes):
        samples = []
        for index in range(warmup + repeat):
            outcome = bench.sql(batch(organisation, account, f"l{size}r{recipients}n{index}", size, recipients))[-1]["result"]
            if outcome["errors"] or outcome["inscribed"] != size:
                raise RuntimeError(f"Lot refusé ({outcome['inscribed']} inscrits sur {size}) : {json.dumps(outcome['errors'], ensure_ascii=False)[:2000]}")
            if index >= warmup:
                samples.append(outcome["micros"] / 1000)
        label = f"lot de {size}, {recipients} destinataires"
        report[label] = {"per_message_ms": round(statistics.median(samples) / size, 2), "batch_ms": round(statistics.median(samples), 2)}
        print(f"{label:<34} {report[label]['per_message_ms']:>12.2f} {report[label]['batch_ms']:>12.2f}", flush=True)
    return report


def measure_delivery(bench: Bench, deliveries: int, warmup: int) -> dict:
    """Une remise, poste par poste : moyenne et médiane en millisecondes de chaque appel."""
    organisation = bench.organisation("alpha", 1)
    rows = []
    for index in range(warmup + deliveries):
        outcome = bench.sql(delivery(organisation, organisation["accounts"][0], str(index)))[-1]["result"]
        if outcome["errors"]:
            raise RuntimeError(f"Remise refusée : {json.dumps(outcome['errors'], ensure_ascii=False)[:2000]}")
        if index >= warmup:
            rows.append(outcome["micros"])
    report = {}
    print(f"\nUne remise, chaque appel dans sa transaction ({deliveries} remises, ms)")
    print(f"{'':<34} {'moyenne':>9} {'médiane':>9}")
    for position, step in enumerate(STEPS):
        samples = [row[position] / 1000 for row in rows]
        report[step] = {"mean_ms": round(statistics.mean(samples), 2), "p50_ms": round(statistics.median(samples), 2)}
        print(f"{step:<34} {report[step]['mean_ms']:>9.2f} {report[step]['p50_ms']:>9.2f}", flush=True)
    report["total"] = {"mean_ms": round(sum(report[step]["mean_ms"] for step in STEPS), 2)}
    print(f"{'Total base':<34} {report['total']['mean_ms']:>9.2f}", flush=True)
    return report


def call_cases(bench: Bench, with_fields: bool) -> list[tuple[str, str]]:
    """Expressions mesurées par `appels` ; celles de l'exécuteur à fermetures si la révision l'a."""
    organisation = bench.organisation("beta", 1)
    account = organisation["accounts"][0]
    # Un fichier écrit et son message inscrit, pour les lectures et l'événement
    bench.sql(delivery(organisation, account, "appels"))
    stored = bench.sql("RETURN <string> (SELECT VALUE id FROM ONLY storage_object LIMIT 1);")[-1]["result"]
    event = f"""fn::event_publish({{ event_id: rand::uuid::v7(), event_type: "mail.message.received", producer: "lyxal_mail", source: {account},
    payload: {{ account: '{account}', size: 10240, has_attachment: false }}, metadata: {{}} }})"""
    cases = [
        ("fn::validation_record (primitive)", "fn::validation_record('mail_content:c', 'mail_content')"),
        ("fn::validation_step_apply, règle record", STEP_APPLY),
        ("fn::validation_object_execute, un champ", ENGINE_ONE),
        ("fn::validation_object_execute, 4 champs de l'ouverture", ENGINE_OPENING),
    ]
    if with_fields:
        cases += [
            ("fn::validation_fields_execute, un champ", FIELDS_ONE),
            ("fn::validation_fields_execute, 4 champs de l'ouverture", FIELDS_OPENING),
        ]
    return cases + [
        ("4 primitives de l'ouverture, appelées directement", PRIMITIVES_OPENING),
        ("fn::secrets_tenant_key_ring", f"fn::secrets_tenant_key_ring({{ tenant: 'auth_organization:{organisation['slug']}', purpose: 'files' }})"),
        ("fn::storage_object_get", f"fn::storage_object_get({{ object: '{stored}' }})"),
        ("fn::storage_bucket_get", f"fn::storage_bucket_get({{ bucket: '{organisation['bucket']}' }})"),
        ("fn::mail_recipient_resolve", f"fn::mail_recipient_resolve({{ address: 'u0@{organisation['slug']}.test' }})"),
        ("fn::event_publish", event),
        ("fn::event_publish, sans ventilation", event.replace("metadata: {} })", "metadata: {}, auto_fanout: false })")),
    ]


def measure_calls(bench: Bench, with_fields: bool, repeat: int, warmup: int) -> dict:
    """Premier et deuxième appel d'une expression dans une transaction : médianes en millisecondes."""
    report = {}
    print(f"\nPremier et deuxième appel dans une transaction (médianes de {repeat}, ms)")
    print(f"{'':<58} {'premier':>9} {'deuxième':>9}")
    for label, call in call_cases(bench, with_fields):
        # Un résultat { ok: false } ou { valid: false } fausserait la mesure : contrôlé d'abord
        checked = bench.sql(f"RETURN {call};")[-1]["result"]
        if isinstance(checked, dict) and (checked.get("ok") is False or checked.get("valid") is False):
            raise RuntimeError(f"« {label} » refusé : {json.dumps(checked, ensure_ascii=False)[:1500]}")
        statement = f"""RETURN {{
    LET $t0 = time::now(); LET $first = {call};
    LET $t1 = time::now(); LET $second = {call};
    LET $t2 = time::now();
    RETURN [duration::micros($t1 - $t0), duration::micros($t2 - $t1)];
}};
"""
        samples = [r["result"] for r in bench.sql(statement * (warmup + repeat))[warmup:]]
        report[label] = {"first_ms": round(statistics.median(s[0] for s in samples) / 1000, 2),
                         "second_ms": round(statistics.median(s[1] for s in samples) / 1000, 2)}
        print(f"{label:<58} {report[label]['first_ms']:>9.2f} {report[label]['second_ms']:>9.2f}", flush=True)
    return report


def client(bench: Bench, token: str, organisation: dict, account: str, name: str, stop_at: float, stats: dict) -> None:
    """Un client ; sa panne (délai, connexion coupée, réponse illisible) est gardée dans `stats["failure"]`."""
    try:
        deliver_until(bench, token, organisation, account, name, stop_at, stats)
    except Exception as failure:  # relevée par measure_clients, qui arrête le banc
        stats["failure"] = failure


def deliver_until(bench: Bench, token: str, organisation: dict, account: str, name: str, stop_at: float, stats: dict) -> None:
    """Une connexion HTTP gardée ouverte, des remises l'une après l'autre jusqu'à l'échéance."""
    connection = http.client.HTTPConnection("127.0.0.1", bench.server.port, timeout=bench.timeout)
    headers = {"Accept": "application/json", "Authorization": f"Bearer {token}",
               "surreal-ns": mods.NS, "surreal-db": bench.database.db}
    sent = 0
    while time.monotonic() < stop_at:
        sent += 1
        started = time.monotonic()
        connection.request("POST", "/sql", body=delivery(organisation, account, f"{name}x{sent}").encode(), headers=headers)
        results = json.loads(connection.getresponse().read())
        failed = [r for r in results if r["status"] != "OK"]
        if failed:
            # Transaction en échec (conflit d'écriture, par exemple) : remise comptée refusée
            stats["refused"][str(failed[0]["result"])[:80]] += 1
        elif results[-1]["result"]["errors"]:
            stats["refused"][results[-1]["result"]["errors"][0]["code"]] += 1
        else:
            stats["latencies"].append(time.monotonic() - started)
    connection.close()


def check_consistency(bench: Bench) -> None:
    """Compteurs des comptes égaux aux messages inscrits, UID uniques dans chaque dossier,
    compteurs de volume de chaque organisation égaux aux fiches (`fn::storage_usage_verify`)."""
    gaps = bench.sql("""
RETURN {
    accounts: (SELECT VALUE id FROM mail_account WHERE message_count != count(SELECT VALUE id FROM mail_message WHERE account = $parent.id)),
    mailboxes: (SELECT VALUE id FROM mail_mailbox WHERE total != array::len(array::distinct(SELECT VALUE uid FROM mail_message WHERE mailbox = $parent.id))),
    volumes: (SELECT VALUE id FROM auth_organization).map(|$tenant| fn::storage_usage_verify({ tenant: <string> $tenant }))[WHERE !$this.ok OR !$this.data.valid]
};
""")[-1]["result"]
    if gaps["accounts"] or gaps["mailboxes"] or gaps["volumes"]:
        raise RuntimeError(f"Incohérence en fin de banc : {json.dumps(gaps, ensure_ascii=False)[:1500]}")
    print("Cohérence : compteurs des comptes égaux aux messages, UID uniques par dossier, compteurs de volume égaux aux fiches.", flush=True)


def measure_clients(bench: Bench, counts: list[int], seconds: float, quota: int | None) -> dict:
    """Débit selon le nombre de clients, dans des organisations distinctes puis dans une seule."""
    most = max(counts)
    organisations = [bench.organisation(f"org{index}", most if index == 0 else 1, quota) for index in range(most)]
    token = bench.root_token()
    report = {}
    print(f"\nMontée en clients ({seconds:.0f} s par palier, une connexion HTTP par client)")
    for mode in ("organisations", "organisation"):
        report[mode] = {}
        for count in counts:
            stats = [{"latencies": [], "refused": collections.Counter()} for _ in range(count)]
            stop_at = time.monotonic() + seconds
            threads = []
            for index in range(count):
                organisation = organisations[index] if mode == "organisations" else organisations[0]
                account = organisation["accounts"][0 if mode == "organisations" else index]
                threads.append(threading.Thread(target=client, args=(bench, token, organisation, account, f"{mode[-1]}{count}c{index}", stop_at, stats[index])))
            started = time.monotonic()
            for thread in threads:
                thread.start()
            for thread in threads:
                thread.join()
            failures = [stat["failure"] for stat in stats if "failure" in stat]
            if failures:
                raise RuntimeError(f"{len(failures)} client(s) sur {count} en panne, mesure invalide : {failures[0]!r}")
            elapsed = time.monotonic() - started
            latencies = sorted(latency for stat in stats for latency in stat["latencies"])
            refused = sum((stat["refused"] for stat in stats), collections.Counter())
            report[mode][str(count)] = {
                "per_second": round(len(latencies) / elapsed, 1),
                "p50_ms": round(statistics.median(latencies) * 1000, 1) if latencies else None,
                "refused": sum(refused.values()),
                "refusals": dict(refused.most_common(3)),
            }
            line = report[mode][str(count)]
            where = "une organisation par client" if mode == "organisations" else "une seule organisation"
            print(f"{where:<28} {count:>2} clients : {line['per_second']:>6.1f} remises par seconde, p50 {line['p50_ms'] or 0:>7.1f} ms, "
                  f"{line['refused']} refusées {line['refusals'] or ''}", flush=True)
    check_consistency(bench)
    return report


def use_revision(ref: str, workdir: Path) -> None:
    """Fait installer les modules d'une révision Git (--ref) à la place de ceux de la copie de travail."""
    archive = subprocess.run(["git", "-C", str(ROOT), "archive", ref, "crates"], capture_output=True, check=True).stdout
    subprocess.run(["tar", "-x", "-C", str(workdir)], input=archive, check=True)
    mods.CRATES = workdir / "crates"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--only", default="remise,appels,lots,clients", help="mesures à faire, séparées par des virgules")
    parser.add_argument("--deliveries", type=int, default=100, help="remises de la mesure « remise »")
    parser.add_argument("--repeat", type=int, default=100, help="transactions par cas de la mesure « appels »")
    parser.add_argument("--warmup", type=int, default=10, help="remises ou transactions écartées en tête de mesure")
    parser.add_argument("--lots", default="8x3,16x3,32x3,8x150", help="formes de la mesure « lots » : <messages>x<destinataires de l'enveloppe>")
    parser.add_argument("--batches", type=int, default=20, help="lots par forme de la mesure « lots » (3 de plus sont écartés en tête)")
    parser.add_argument("--clients", default="1,2,4,8,16", help="paliers de la mesure « clients »")
    parser.add_argument("--seconds", type=float, default=12, help="durée d'un palier de la mesure « clients »")
    parser.add_argument("--quota", type=int, help="quota de volume de chaque organisation de la mesure « clients », en octets (aucun par défaut)")
    parser.add_argument("--timeout", type=float, default=600, help="durée maximale d'une requête du banc, en secondes")
    parser.add_argument("--ref", help="révision Git dont les modules sont mesurés (mesure « avant »)")
    parser.add_argument("--out", type=Path)
    args = parser.parse_args()
    wanted = set(args.only.split(","))
    unknown = wanted - {"remise", "appels", "lots", "clients"}
    if unknown:
        parser.error(f"mesure inconnue : {', '.join(sorted(unknown))}")

    report = {"surreal": core.SURREAL, "machine": platform.platform(), "ref": args.ref or "copie de travail"}
    with tempfile.TemporaryDirectory() as workdir, core.SurrealServer() as server:
        if args.ref:
            use_revision(args.ref, Path(workdir))
        with_fields = (mods.CRATES / "lyxal_core/functions/validations/functions/fields_execute.surql").exists()
        # Une base neuve par mesure : aucune ne lit les données d'une autre
        if "remise" in wanted:
            report["remise"] = measure_delivery(Bench(server, "remise", args.timeout), args.deliveries, args.warmup)
        if "appels" in wanted:
            report["appels"] = measure_calls(Bench(server, "appels", args.timeout), with_fields, args.repeat, args.warmup)
        if "lots" in wanted:
            shapes = [tuple(int(part) for part in shape.split("x")) for shape in args.lots.split(",")]
            report["lots"] = measure_batches(Bench(server, "lots", args.timeout), shapes, args.batches, 3)
        if "clients" in wanted:
            report["clients"] = measure_clients(Bench(server, "clients", args.timeout), [int(c) for c in args.clients.split(",")], args.seconds, args.quota)
    if args.out:
        args.out.write_text(json.dumps(report, indent=2, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
