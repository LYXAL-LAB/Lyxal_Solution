#!/usr/bin/env python3
"""Banc de mesure du modèle `lyxal_mail` (lot 4c du programme courrier, plan §16 et §19).

Complète le banc du lot 0 (`bench_mailbox.py`, tables d'essai sans permission) : il installe le
vrai module `lyxal_mail` et ses dépendances dans un serveur `surreal` jetable (comme
`scripts/ci/test_lyxal_modules.py`), crée une organisation, un membre et son compte, charge une
boîte de N messages par `fn::mail_message_create`, puis mesure (médiane et 95e centile du temps
vu par le client, connexion gardée ouverte) :

  * la remise par `fn::mail_message_create` sous une session de membre (permissions des tables
    évaluées sur chaque fiche lue ou écrite), sous le compte de service et sous la session système ;
  * la contention du compteur de modifications du compte (décision M6) : quatre clients qui
    remettent dans le même compte, dans un même dossier puis dans quatre dossiers ; conflits de
    transaction comptés, rejoués trois fois au plus comme le fera le service Rust ;
  * le changement d'un drapeau (`fn::mail_message_flags_set`) ;
  * une page de 50 messages (par date et par UID), une plage de 1 000 UID, et les changements depuis un numéro de
    modification avec pierres tombales (`fn::mail_message_changes`), sous une session de membre
    et sous la session système : l'écart est le coût des permissions des tables, évaluées sur
    les seules fiches lues (plages d'identifiants bornées, décision P1).

Seuils de la décision C5 (lot 0) : page et synchronisation en moins de 100 ms, changement de
drapeau en moins de 20 ms, remise d'au moins 300 messages par seconde. Hors CI. Usage :

    python3 -I scripts/bench/mailbox/bench_mail_module.py --messages 20000 --out resultats.json

Binaire : `${LYXAL_SURREAL_BIN:-surreal}` (3.3.4). Moteur en mémoire.
"""

import argparse
import http.client
import json
import platform
import statistics
import sys
import threading
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "scripts" / "ci"))
sys.dont_write_bytecode = True
import test_lyxal_modules as modules  # noqa: E402

THRESHOLDS = {"page": 100.0, "sync": 100.0, "flag": 20.0}
SETUP = """
CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha" };
CREATE auth_identity:jean CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "jean@bench.test" } };
RELATE auth_identity:jean->auth_member_of->auth_organization:alpha;
CREATE auth_session:jean CONTENT { identity: auth_identity:jean, organization: auth_organization:alpha, idle_expires_at: time::now() + 1d, expires_at: time::now() + 1d };
CREATE auth_identity:worker CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "worker@bench.test" } };
CREATE auth_session:worker CONTENT { identity: auth_identity:worker, idle_expires_at: time::now() + 1d, expires_at: time::now() + 1d };
CREATE auth_organization_domain:alpha CONTENT { organization: auth_organization:alpha, domain: "bench.test", state: "verified", challenge_hash: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" };
LET $domain = fn::mail_domain_create({ auth_domain: "auth_organization_domain:alpha" }).data.id;
LET $account = fn::mail_account_create({ identity: "auth_identity:jean", domain: <string> $domain, local_part: "jean" }).data.account.id;
FOR $n IN [1, 2, 3, 4] { fn::mail_mailbox_create({ account: <string> $account, name: string::concat("B", <string> $n) }); };
-- Contenus stockés du banc : fiche lyxal_storage simulée (aucun octet n'est écrit au lot 4c)
DEFINE FUNCTION OVERWRITE fn::banc_contenus($account: record<mail_account>, $count: int) -> array {
    RETURN (<array> (0..$count)).map(|$i| {
        LET $content = (CREATE ONLY mail_content CONTENT { tenant: auth_organization:alpha, account: $account,
            key: string::concat(<string> record::id($account), "/", <string> rand::uuid::v7(), ".eml"), size: 4096, expires_at: time::now() + 1d });
        UPDATE $content.id SET state = "stored", object = storage_object:banc;
        RETURN <string> $content.id;
    });
};
RETURN { account: <string> $account, boxes: (SELECT VALUE [path, <string> id] FROM mail_mailbox WHERE account = $account) };
"""


def message_sql(content, mailbox, index):
    return (f'fn::mail_message_create({{ content: "{content}", mailbox: "{mailbox}", received_at: time::now(), '
            f'message_id: "m{index}@banc.test", base_subject: "Sujet {index % 97}", '
            f'envelope: {{ subject: "Sujet {index % 97}", from: [{{ name: "Expéditeur", address: "exp{index % 13}@ailleurs.test" }}], '
            f'to: [{{ address: "jean@bench.test" }}] }}, structure: {{ type: "text/plain", size: 4096, lines: 80 }} }})')


class Client:
    """Connexion HTTP gardée ouverte vers /sql, sous une session (jeton) ou la session système."""

    def __init__(self, server, database, token=None):
        self.connection = http.client.HTTPConnection("127.0.0.1", server.port, timeout=600)
        self.headers = {"Accept": "application/json", "surreal-ns": modules.NS, "surreal-db": database.db,
                        "Authorization": f"Bearer {token}" if token else f"Basic {server.auth}"}

    def sql(self, body):
        self.connection.request("POST", "/sql", body=body.encode(), headers=self.headers)
        response = self.connection.getresponse()
        return json.loads(response.read())

    def one(self, body):
        start = time.perf_counter()
        result = self.sql(body)[-1]
        elapsed = (time.perf_counter() - start) * 1000
        if result["status"] != "OK":
            raise RuntimeError(str(result["result"])[:300])
        return result["result"], elapsed


def stats(times):
    ordered = sorted(times)
    return {"count": len(ordered), "p50_ms": round(statistics.median(ordered), 2),
            "p95_ms": round(ordered[min(len(ordered) - 1, int(0.95 * len(ordered)))], 2)}


def contents(client, account, count):
    return client.one(f'RETURN fn::banc_contenus({account}, {count});')[0]


FAST_LOAD = """FOR $c IN {ids} {{
    LET $box = (SELECT uid_next FROM ONLY {inbox});
    LET $m = (SELECT VALUE modseq FROM ONLY {account}) + 1;
    CREATE fn::mail_message_key({inbox}, $box.uid_next) CONTENT {{ tenant: auth_organization:alpha, account: {account}, owner: auth_identity:jean, mailbox: {inbox},
        content: type::record($c), origin: "import", uid: $box.uid_next, modseq: $m, create_modseq: $m, thread: <string> rand::uuid::v7(),
        received_at: time::now(), size: 4096, keywords: [], message_id: string::concat($c, "@banc.test"), base_subject: "Sujet",
        envelope: {{ subject: "Sujet", from: [{{ name: "Expéditeur", address: "exp@ailleurs.test" }}], to: [{{ address: "jean@bench.test" }}] }},
        structure: {{ type: "text/plain", size: 4096, lines: 80 }} }};
}};"""


def load(client, account, inbox, total, fast=False):
    """Boîte de `total` messages ; `fast` : écriture directe sous la session système (gardes et
    compteurs exécutés, sans la validation des paramètres), pour les grandes boîtes."""
    done, start = 0, time.perf_counter()
    while done < total:
        batch = min(500 if fast else 200, total - done)
        ids = contents(client, account, batch)
        if fast:
            result = client.sql(FAST_LOAD.format(ids=json.dumps(ids), inbox=inbox, account=account))[-1]
            if result["status"] != "OK":
                raise RuntimeError(str(result["result"])[:300])
        else:
            body = "\n".join(f"{message_sql(c, inbox, done + i)};" for i, c in enumerate(ids))
            for result in client.sql(body):
                if result["status"] != "OK" or not result["result"]["ok"]:
                    raise RuntimeError(str(result["result"])[:300])
        done += batch
        print(f"  chargement : {done}/{total}", file=sys.stderr)
    return round(total / (time.perf_counter() - start), 1)


def delivery(client, root, account, mailbox, count, start_index):
    ids = contents(root, account, count)
    times = []
    for i, content in enumerate(ids):
        result, elapsed = client.one(f"RETURN {message_sql(content, mailbox, start_index + i)};")
        if not result["ok"]:
            raise RuntimeError(result["error"]["code"])
        times.append(elapsed)
    measured = stats(times)
    measured["per_second"] = round(1000 * count / sum(times), 1)
    return measured


def contention(server, database, token, root, account, mailboxes, per_client):
    """Quatre clients remettent en même temps dans le même compte ; conflit → rejeu (3 au plus)."""
    prepared = [contents(root, account, per_client) for _ in mailboxes]
    report = {"conflicts": 0, "failed": 0, "times": []}
    lock = threading.Lock()

    def run(slot):
        client = Client(server, database, token)
        for i, content in enumerate(prepared[slot]):
            for attempt in range(4):
                start = time.perf_counter()
                result = client.sql(f"RETURN {message_sql(content, mailboxes[slot], 1_000_000 + slot * per_client + i)};")[-1]
                elapsed = (time.perf_counter() - start) * 1000
                ok = result["status"] == "OK" and result["result"]["ok"]
                with lock:
                    if ok:
                        report["times"].append(elapsed)
                    elif attempt < 3:
                        report["conflicts"] += 1
                    else:
                        report["failed"] += 1
                if ok:
                    break

    start = time.perf_counter()
    threads = [threading.Thread(target=run, args=(slot,)) for slot in range(len(mailboxes))]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()
    wall = time.perf_counter() - start
    measured = stats(report["times"]) if report["times"] else {}
    measured.update(conflicts=report["conflicts"], failed=report["failed"],
                    per_second=round(len(report["times"]) / wall, 1))
    return measured


def repeat(client, body, repetitions):
    times = []
    for _ in range(repetitions):
        result, elapsed = client.one(body)
        if isinstance(result, dict) and result.get("ok") is False:
            raise RuntimeError(result["error"]["code"])
        times.append(elapsed)
    return stats(times)


def repeat_error(client, body, code, repetitions):
    times = []
    for _ in range(repetitions):
        result, elapsed = client.one(body)
        if result.get("ok") is not False or result["error"]["code"] != code:
            raise RuntimeError(str(result)[:300])
        times.append(elapsed)
    return stats(times)


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--messages", type=int, default=20000)
    parser.add_argument("--delivery", type=int, default=300)
    parser.add_argument("--repeat", type=int, default=30)
    parser.add_argument("--fast-load", action="store_true", help="charger la boîte par écriture directe (session système)")
    parser.add_argument("--out", type=Path)
    args = parser.parse_args()
    results = {"machine": {"platform": platform.platform(), "python": platform.python_version()},
               "messages": args.messages, "measures": {}}
    measures = results["measures"]
    with modules.core.SurrealServer() as server:
        database = modules.ModuleDatabase(server, "lyxal_mail", "banc")
        database.install()
        member = database.token({"id": "auth_session:jean", "pv": 1, "permissions": ["mail.mailbox.access"]})
        worker = database.token({"id": "auth_session:worker", "pv": 1, "permissions": ["mail.worker"]})
        root, jean, service = Client(server, database), Client(server, database, member), Client(server, database, worker)
        setup = root.sql(SETUP)[-1]["result"]
        account, boxes = setup["account"], dict(setup["boxes"])
        inbox = boxes["INBOX"]
        print("Chargement de la boîte…", file=sys.stderr)
        measures["load_per_second_root"] = load(root, account, inbox, args.messages, args.fast_load)
        print("Remise…", file=sys.stderr)
        measures["delivery_member"] = delivery(jean, root, account, inbox, args.delivery, 2_000_000)
        measures["delivery_worker"] = delivery(service, root, account, inbox, args.delivery, 3_000_000)
        measures["delivery_root"] = delivery(root, root, account, inbox, args.delivery, 4_000_000)
        # Part de la validation des paramètres (lyxal_core) : même appel, refusé juste après elle
        # (dossier absent), sous la session système
        refused = message_sql("mail_content:absent", "mail_mailbox:absent", 0)
        measures["delivery_validation_only_root"] = repeat_error(root, f"RETURN {refused};", "MAIL_MAILBOX_NOT_FOUND", args.repeat)
        print("Contention…", file=sys.stderr)
        per_client = max(25, args.delivery // 4)
        measures["contention_same_mailbox"] = contention(server, database, member, root, account, [inbox] * 4, per_client)
        measures["contention_four_mailboxes"] = contention(server, database, member, root, account,
                                                           [boxes[f"B{n}"] for n in range(1, 5)], per_client)
        print("Lectures…", file=sys.stderr)
        last = root.one(f'RETURN (SELECT VALUE id FROM ONLY mail_message WHERE mailbox = {inbox} ORDER BY uid DESC LIMIT 1);')[0]
        measures["flag_member"] = repeat(jean, f'RETURN fn::mail_message_flags_set({{ messages: ["{last}"], replace: [IF rand::bool() {{ "$seen" }} ELSE {{ "$flagged" }}] }});', args.repeat)
        for who, client in (("member", jean), ("root", root)):
            measures[f"page_first_{who}"] = repeat(client, f'RETURN fn::mail_message_list({{ mailbox: "{inbox}", limit: 50 }});', args.repeat)
            measures[f"page_uid_{who}"] = repeat(client, f'RETURN fn::mail_message_list({{ mailbox: "{inbox}", uid_min: 1, limit: 50 }});', args.repeat)
            measures[f"uid_range_1000_{who}"] = repeat(client, f'RETURN fn::mail_message_list({{ mailbox: "{inbox}", uid_min: 1, limit: 1000 }});', args.repeat)
        # Changements : 1 000 drapeaux (deux lots de 500) et 200 effacements depuis un point de synchronisation
        since = root.one(f"RETURN (SELECT VALUE modseq FROM ONLY {account});")[0]
        ids = root.one(f'RETURN (SELECT VALUE <string> id FROM mail_message WHERE mailbox = {inbox} ORDER BY uid LIMIT 1200);')[0]
        for chunk in (ids[:500], ids[500:1000]):
            root.one(f"RETURN fn::mail_message_flags_set({{ messages: {json.dumps(chunk)}, add: [\"banc\"] }});")
        root.one(f'RETURN fn::mail_message_expunge({{ mailbox: "{inbox}", messages: {json.dumps(ids[1000:1200])} }});')
        for who, client in (("member", jean), ("root", root)):
            measures[f"changes_1200_{who}"] = repeat(client, f'RETURN fn::mail_message_changes({{ account: "{account}", since: {since}, limit: 5000 }});', max(5, args.repeat // 3))
            measures[f"changes_mailbox_{who}"] = repeat(client, f'RETURN fn::mail_message_changes({{ mailbox: "{inbox}", since: {since}, limit: 1000 }});', max(5, args.repeat // 3))
        consistent = root.one(f"""RETURN {{
            account: (SELECT VALUE message_count FROM ONLY {account}) == array::len(SELECT VALUE id FROM mail_message WHERE account = {account}),
            uids: array::len(SELECT VALUE id FROM mail_message WHERE mailbox = {inbox}) == array::len(array::distinct(SELECT VALUE uid FROM mail_message WHERE mailbox = {inbox})),
            dates: count(SELECT id FROM mail_message_date) == count(SELECT id FROM mail_message)
        }};""")[0]
        results["consistent"] = consistent
    for name, threshold in (("flag_member", THRESHOLDS["flag"]), ("page_first_member", THRESHOLDS["page"]),
                            ("changes_1200_member", THRESHOLDS["sync"])):
        measures[name]["threshold_ms"] = threshold
        measures[name]["holds"] = measures[name]["p95_ms"] < threshold
    measures["delivery_member"]["holds_300_per_second"] = measures["delivery_member"]["per_second"] >= 300
    text = json.dumps(results, indent=2, ensure_ascii=False)
    if args.out:
        args.out.write_text(text + "\n")
    print(text)


if __name__ == "__main__":
    main()
