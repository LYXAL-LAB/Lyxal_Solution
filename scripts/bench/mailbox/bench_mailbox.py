#!/usr/bin/env python3
"""Banc de mesure « boîte aux lettres » sur SurrealDB (lot 0 du programme courrier, décision C5).

Répond à une question : SurrealDB 3.3.4 tient-il les accès d'un magasin de courrier modélisé
en tables (voie B de la décision P4) à l'échelle d'une grosse boîte ?

Le script démarre un serveur `surreal` jetable (port libre, identifiants générés, même
approche que `scripts/ci/test_lyxal_core.py`), installe `schema.surql`, charge une boîte de N
messages répartis sur 20 dossiers, puis mesure avec répétitions (médiane et 95e centile) :

  * une page de 50 messages d'un dossier triée par date décroissante (première page, page
    profonde par décalage `START`, page profonde par curseur de date) ;
  * les changements depuis un numéro de modification (synchronisation) ;
  * le changement d'un drapeau, avec avancée du numéro de modification et du compteur ;
  * le compte des non-lus (un dossier, tous les dossiers, compteur tenu à l'écriture) ;
  * la recherche sur l'expéditeur et le sujet (sans index plein texte, puis avec) ;
  * le débit d'insertion (chargement par lots, puis remise message par message).

Chaque requête de lecture est aussi lancée avec `EXPLAIN` : le plan est gardé dans le résultat.

Hors CI, hors workspace. Usage :

    python3 -I scripts/bench/mailbox/bench_mailbox.py --messages 100000 --engine memory \\
        --out resultats.json
    python3 -I scripts/bench/mailbox/bench_mailbox.py --messages 1000000 --engine rocksdb \\
        --data-dir /chemin/vide --out resultats.json

Moteurs : `memory`, `rocksdb`, `surrealkv` (ceux du binaire 3.3.4). Le dossier de données
(`--data-dir`) est créé puis supprimé par le script, sauf avec `--keep`.
Binaire : `${LYXAL_SURREAL_BIN:-surreal}`.
"""

import argparse
import base64
import bisect
import datetime
import http.client
import json
import math
import os
import platform
import random
import secrets
import shutil
import socket
import statistics
import subprocess
import sys
import tempfile
import threading
import time
import urllib.error
import urllib.request
from pathlib import Path

HERE = Path(__file__).resolve().parent
SURREAL = os.environ.get("LYXAL_SURREAL_BIN", "surreal")
NS, DB = "bench_mailbox", "bench_mailbox"
QUERY_TIMEOUT = 300
BATCH = 1000

# Seuils de la décision C5 (en millisecondes, ou en messages par seconde).
THRESHOLD_PAGE_MS = 100.0
THRESHOLD_SYNC_MS = 100.0
THRESHOLD_FLAG_MS = 20.0
THRESHOLD_INSERT_PER_S = 300.0

# Dossiers : nom et part des messages.
FOLDERS = [
    ("INBOX", 0.38), ("Archive", 0.24), ("Sent", 0.10), ("Clients", 0.06), ("Chantiers", 0.05),
    ("Factures", 0.04), ("Fournisseurs", 0.03), ("Newsletters", 0.03), ("Notifications", 0.02),
    ("Trash", 0.015), ("Junk", 0.01), ("Drafts", 0.002), ("RH", 0.005), ("Juridique", 0.004),
    ("Projets/2024", 0.004), ("Projets/2025", 0.004), ("Projets/2026", 0.003), ("Voyages", 0.001),
    ("Personnel", 0.001), ("Divers", 0.001),
]

BASE_WORDS = (
    "facture devis commande livraison chantier réunion planning rappel relance contrat avenant "
    "paiement virement échéance retard urgent important confirmation rendez-vous visite compte "
    "rendu rapport projet dossier document pièce jointe signature validation demande réponse "
    "question information proposition offre tarif remise client fournisseur équipe direction "
    "mise jour version finale brouillon note frais congés absence formation invitation "
    "inscription newsletter notification alerte sécurité mot passe connexion support ticket "
    "incident maintenance travaux matériaux béton acier bois peinture électricité plomberie "
    "toiture façade isolation permis déclaration assurance sinistre expertise réception réserve "
    "garantie situation décompte métré plan étude calcul budget prévision trimestre bilan "
    "audit contrôle qualité conformité norme procédure consigne livrable jalon recette "
    "déploiement serveur sauvegarde restauration base données migration"
).split()
SYLLABLES = ["ba", "co", "du", "fa", "gi", "lo", "mé", "na", "pi", "ra", "so", "tu", "vé", "xa", "zi", "chan", "tro", "bli", "gra", "pon"]
FIRST_NAMES = ["Jean", "Anne", "Paul", "Marie", "Luc", "Sophie", "Marc", "Julie", "Hugo", "Emma", "Louis", "Chloé", "Nina", "Omar", "Léa", "Yann"]
LAST_NAMES = ["Dupont", "Martin", "Bernard", "Petit", "Robert", "Richard", "Durand", "Moreau", "Simon", "Laurent", "Lefebvre", "Michel", "Garcia", "David", "Roux", "Fournier"]
DOMAINS = ["exemple.fr", "client-a.example", "fournisseur-b.example", "batiment.example", "cabinet.example", "mairie.example", "banque.example", "lettre.example"]

RARE_WORD = "zyxquartz"      # présent dans très peu de sujets (1 sur 20 000 environ)
ABSENT_WORD = "introuvablexyz"  # présent dans aucun sujet


def free_port():
    with socket.socket() as sock:
        sock.bind(("127.0.0.1", 0))
        return sock.getsockname()[1]


class Server:
    """Serveur SurrealDB jetable. `path` : `memory`, `rocksdb://...` ou `surrealkv://...`."""

    def __init__(self, path):
        self.path = path
        self.user, self.password = "bench", "bench" + secrets.token_urlsafe(24)
        self.auth = base64.b64encode(f"{self.user}:{self.password}".encode()).decode()
        self.port = None
        self.process = None
        self.log = None
        self.token = None
        self.local = threading.local()

    def start(self):
        for _attempt in range(3):
            self.port = free_port()
            self.log = tempfile.TemporaryFile()
            self.process = subprocess.Popen(
                [SURREAL, "start", "--log", "error", "--user", self.user, "--pass", self.password,
                 "--bind", f"127.0.0.1:{self.port}", self.path],
                stdout=subprocess.DEVNULL, stderr=self.log,
            )
            deadline = time.monotonic() + 120
            while time.monotonic() < deadline and self.process.poll() is None:
                try:
                    ready = subprocess.run(
                        [SURREAL, "is-ready", "--endpoint", f"http://127.0.0.1:{self.port}"],
                        capture_output=True, timeout=5,
                    ).returncode == 0
                except subprocess.TimeoutExpired:
                    ready = False
                if ready:
                    self.signin()
                    return
                time.sleep(0.2)
            self.stop()
        raise RuntimeError("Le serveur SurrealDB n'a pas démarré.")

    def stop(self):
        if self.process and self.process.poll() is None:
            self.process.terminate()
            try:
                self.process.wait(timeout=120)
            except subprocess.TimeoutExpired:
                self.process.kill()
                self.process.wait()
        self.process = None

    def signin(self):
        """Ouvre une session : le jeton évite de revérifier le mot de passe à chaque requête
        (vérification volontairement lente, environ 20 ms, qui fausserait toutes les mesures)."""
        request = urllib.request.Request(
            f"http://127.0.0.1:{self.port}/signin",
            data=json.dumps({"user": self.user, "pass": self.password}).encode(),
            headers={"Accept": "application/json", "Content-Type": "application/json"},
        )
        with urllib.request.urlopen(request, timeout=30) as response:
            self.token = json.load(response)["token"]
        if isinstance(self.token, dict):
            self.token = self.token.get("access") or self.token.get("token")

    def _connection(self, timeout):
        """Connexion HTTP gardée ouverte, une par fil d'exécution."""
        connection = getattr(self.local, "connection", None)
        if connection is None or getattr(self.local, "port", None) != self.port:
            connection = http.client.HTTPConnection("127.0.0.1", self.port, timeout=timeout)
            self.local.connection, self.local.port = connection, self.port
        connection.timeout = timeout
        if connection.sock is not None:
            connection.sock.settimeout(timeout)
        return connection

    def sql(self, body, timeout=QUERY_TIMEOUT):
        """Exécute un texte SurrealQL. Retourne (résultats, durée côté client en ms).

        La durée couvre l'envoi, l'exécution et la lecture de la réponse sur une connexion déjà
        ouverte et une session déjà authentifiée, comme le fait un client applicatif."""
        headers = {"Accept": "application/json", "Authorization": f"Bearer {self.token}",
                   "surreal-ns": NS, "surreal-db": DB}
        data = body.encode()
        started = time.perf_counter()
        for attempt in (1, 2):
            connection = self._connection(timeout)
            try:
                connection.request("POST", "/sql", body=data, headers=headers)
                response = connection.getresponse()
                raw = response.read()
                break
            except (http.client.HTTPException, ConnectionError, BrokenPipeError):
                connection.close()
                self.local.connection = None
                if attempt == 2:
                    raise
                started = time.perf_counter()
        elapsed = (time.perf_counter() - started) * 1000.0
        if response.status != 200:
            raise RuntimeError(f"HTTP {response.status} : {raw.decode(errors='replace')[:500]}")
        payload = json.loads(raw)
        for item in payload:
            if item.get("status") != "OK":
                raise RuntimeError(f"requête en échec : {str(item.get('result'))[:500]}\n{body[:300]}")
        return payload, elapsed


def server_ms(text):
    """Durée annoncée par le serveur (« 1.2ms », « 350µs », « 2s »…) en millisecondes."""
    for suffix, factor in (("ns", 1e-6), ("µs", 1e-3), ("ms", 1.0), ("s", 1000.0)):
        if text.endswith(suffix):
            try:
                return float(text[: -len(suffix)]) * factor
            except ValueError:
                return float("nan")
    return float("nan")


# --------------------------------------------------------------------------------------
# Données
# --------------------------------------------------------------------------------------

class Generator:
    """Boîte synthétique reproductible (graine fixe)."""

    def __init__(self, total, seed=20261118):
        self.total = total
        self.rng = random.Random(seed)
        words = list(BASE_WORDS)
        while len(words) < 3000:
            words.append("".join(self.rng.choice(SYLLABLES) for _ in range(self.rng.randint(2, 4))))
        self.words = words
        self.word_weights = self._zipf(len(words), 1.05)
        self.senders = [
            (f"{self.rng.choice(FIRST_NAMES)} {self.rng.choice(LAST_NAMES)}", f"contact{index}@{self.rng.choice(DOMAINS)}")
            for index in range(4000)
        ]
        self.sender_weights = self._zipf(len(self.senders), 1.1)
        self.folder_cum = []
        acc = 0.0
        for _name, share in FOLDERS:
            acc += share
            self.folder_cum.append(acc)
        self.uid_next = [1] * len(FOLDERS)
        self.unseen = [0] * len(FOLDERS)
        self.thread_pool = []
        self.start = datetime.datetime(2020, 1, 1, tzinfo=datetime.timezone.utc)
        self.span = 6 * 365 * 86400

    @staticmethod
    def _zipf(count, exponent):
        cum, acc = [], 0.0
        for rank in range(1, count + 1):
            acc += 1.0 / rank ** exponent
            cum.append(acc)
        return cum

    def _pick(self, cum):
        return bisect.bisect_left(cum, self.rng.random() * cum[-1])

    def subject(self, index):
        words = [self.words[self._pick(self.word_weights)] for _ in range(self.rng.randint(3, 9))]
        if index % 20000 == 7:
            words.insert(self.rng.randint(0, len(words)), RARE_WORD)
        prefix = self.rng.random()
        text = " ".join(words).capitalize()
        return ("Re: " if prefix < 0.25 else "TR: " if prefix < 0.30 else "") + text

    def rows(self):
        """Produit les messages dans l'ordre d'arrivée (dates croissantes)."""
        for index in range(self.total):
            folder = min(bisect.bisect_left(self.folder_cum, self.rng.random() * self.folder_cum[-1]), len(FOLDERS) - 1)
            uid = self.uid_next[folder]
            self.uid_next[folder] += 1
            received = self.start + datetime.timedelta(seconds=int(self.span * (index + self.rng.random()) / self.total))
            name = FOLDERS[folder][0]
            seen_rate = {"INBOX": 0.80, "Newsletters": 0.30, "Notifications": 0.40, "Junk": 0.05}.get(name, 0.97)
            seen = self.rng.random() < seen_rate
            if not seen:
                self.unseen[folder] += 1
            if self.thread_pool and self.rng.random() < 0.4:
                thread = self.rng.choice(self.thread_pool)
            else:
                thread = f"t{index}"
                if len(self.thread_pool) < 5000:
                    self.thread_pool.append(thread)
                else:
                    self.thread_pool[self.rng.randrange(5000)] = thread
            sender_name, sender_addr = self.senders[self._pick(self.sender_weights)]
            keywords = []
            if self.rng.random() < 0.05:
                keywords.append(self.rng.choice(["$forwarded", "$label1", "$label2", "important", "a-traiter"]))
            yield {
                "folder": folder, "uid": uid, "received": received.strftime("%Y-%m-%dT%H:%M:%SZ"),
                "size": int(min(25_000_000, math.exp(self.rng.gauss(9.6, 1.4)))), "seen": seen,
                "flagged": self.rng.random() < 0.03, "answered": self.rng.random() < 0.15,
                "draft": name == "Drafts", "deleted": False, "keywords": keywords, "thread": thread,
                "message_id": f"<{index}.{self.rng.getrandbits(48):x}@{sender_addr.split('@')[1]}>",
                "from_addr": sender_addr, "from_name": sender_name, "subject": self.subject(index),
                "blob_ref": f"{self.rng.getrandbits(128):032x}",
            }


def bool_sql(value):
    return "true" if value else "false"


def row_sql(row, modseq):
    return (
        "{account:bench_account:1,mailbox:bench_mailbox:%d,uid:%d,modseq:%d,received_at:d'%s',size:%d,"
        "seen:%s,flagged:%s,answered:%s,draft:%s,deleted:%s,keywords:%s,thread:%s,message_id:%s,"
        "from_addr:%s,from_name:%s,subject:%s,blob_ref:%s}"
        % (
            row["folder"], row["uid"], modseq, row["received"], row["size"], bool_sql(row["seen"]),
            bool_sql(row["flagged"]), bool_sql(row["answered"]), bool_sql(row["draft"]), bool_sql(row["deleted"]),
            json.dumps(row["keywords"]), json.dumps(row["thread"]), json.dumps(row["message_id"]),
            json.dumps(row["from_addr"]), json.dumps(row["from_name"], ensure_ascii=False),
            json.dumps(row["subject"], ensure_ascii=False), json.dumps(row["blob_ref"]),
        )
    )


def load(server, total, progress):
    """Charge la boîte par lots. Retourne les statistiques de chargement et l'état des dossiers."""
    generator = Generator(total)
    server.sql("CREATE bench_account:1 SET email = 'boite@exemple.fr' RETURN NONE;")
    folders = ";".join(
        f"CREATE bench_mailbox:{index} SET account = bench_account:1, name = {json.dumps(name)}, "
        f"uid_validity = 1, uid_next = 1, highest_modseq = 0, total = 0, unseen = 0 RETURN NONE"
        for index, (name, _share) in enumerate(FOLDERS)
    )
    server.sql(folders + ";")
    # Numéros de modification : chaque message reçoit le sien à l'arrivée ; 15 % des messages
    # sont ensuite « modifiés » (drapeau changé) et prennent un numéro plus récent, comme dans
    # une vraie boîte où l'ordre des modifications n'est pas l'ordre des UID.
    modseq = [0] * len(FOLDERS)
    batch, batch_times, inserted = [], [], 0
    started = time.perf_counter()
    for row in generator.rows():
        modseq[row["folder"]] += 1
        batch.append(row_sql(row, modseq[row["folder"]]))
        if len(batch) == BATCH:
            _result, elapsed = server.sql("INSERT INTO bench_message [" + ",".join(batch) + "] RETURN NONE;")
            batch_times.append(elapsed)
            inserted += len(batch)
            batch = []
            if progress and inserted % 50000 == 0:
                rate = inserted / (time.perf_counter() - started)
                print(f"  chargé {inserted}/{total} ({rate:.0f} messages/s)", file=sys.stderr, flush=True)
    if batch:
        _result, elapsed = server.sql("INSERT INTO bench_message [" + ",".join(batch) + "] RETURN NONE;")
        batch_times.append(elapsed)
        inserted += len(batch)
    load_seconds = time.perf_counter() - started

    # Modifications après coup : 15 % des messages de chaque dossier, par tranches.
    rng = random.Random(7)
    touched = 0
    touch_started = time.perf_counter()
    for folder in range(len(FOLDERS)):
        count = generator.uid_next[folder] - 1
        picks = rng.sample(range(1, count + 1), int(count * 0.15)) if count else []
        for offset in range(0, len(picks), 500):
            statements = []
            for uid in picks[offset : offset + 500]:
                modseq[folder] += 1
                statements.append(
                    f"UPDATE bench_message SET flagged = !flagged, modseq = {modseq[folder]} "
                    f"WHERE mailbox = bench_mailbox:{folder} AND uid = {uid} RETURN NONE"
                )
            server.sql("BEGIN;" + ";".join(statements) + ";COMMIT;")
            touched += len(statements)
    touch_seconds = time.perf_counter() - touch_started
    counters = ";".join(
        f"UPDATE bench_mailbox:{folder} SET uid_next = {generator.uid_next[folder]}, highest_modseq = {modseq[folder]}, "
        f"total = {generator.uid_next[folder] - 1}, unseen = {generator.unseen[folder]} RETURN NONE"
        for folder in range(len(FOLDERS))
    )
    server.sql(counters + ";")
    state = {
        "counts": [generator.uid_next[folder] - 1 for folder in range(len(FOLDERS))],
        "modseq": modseq, "unseen": generator.unseen, "senders": generator.senders,
        "common_word": BASE_WORDS[0], "medium_word": generator.words[400],
    }
    stats = {
        "messages": inserted, "load_seconds": round(load_seconds, 1),
        "batch_insert_per_s": round(inserted / load_seconds, 1),
        "batch_ms_median": round(statistics.median(batch_times), 1),
        "batch_ms_p95": round(percentile(batch_times, 95), 1),
        "flag_updates_after_load": touched,
        "flag_updates_per_s_in_batches_of_500": round(touched / touch_seconds, 1) if touch_seconds else None,
    }
    return stats, state


# --------------------------------------------------------------------------------------
# Mesures
# --------------------------------------------------------------------------------------

def percentile(values, percent):
    ordered = sorted(values)
    if not ordered:
        return float("nan")
    rank = (len(ordered) - 1) * percent / 100.0
    low, high = int(math.floor(rank)), int(math.ceil(rank))
    return ordered[low] + (ordered[high] - ordered[low]) * (rank - low)


def summarise(client_times, server_times, rows):
    return {
        "repetitions": len(client_times),
        "client_ms_median": round(statistics.median(client_times), 2),
        "client_ms_p95": round(percentile(client_times, 95), 2),
        "client_ms_max": round(max(client_times), 2),
        "server_ms_median": round(statistics.median(server_times), 2),
        "server_ms_p95": round(percentile(server_times, 95), 2),
        "rows_median": statistics.median(rows) if rows else None,
    }


def measure_read(server, name, build, repetitions, results, threshold=None, warmup=2):
    """Mesure une requête de lecture. `build(i)` rend le texte SurrealQL de la répétition i."""
    try:
        for index in range(warmup):
            server.sql(build(-1 - index))
        client_times, server_times, rows = [], [], []
        for index in range(repetitions):
            payload, elapsed = server.sql(build(index))
            client_times.append(elapsed)
            server_times.append(server_ms(payload[-1]["time"]))
            result = payload[-1]["result"]
            rows.append(len(result) if isinstance(result, list) else 1)
            if elapsed > 20000 and index >= 2:
                break  # requête très lente : trois passages suffisent
        entry = summarise(client_times, server_times, rows)
        try:
            plan, _elapsed = server.sql("EXPLAIN " + build(0))
            entry["explain"] = plan[-1]["result"]
        except RuntimeError as error:
            entry["explain"] = f"EXPLAIN impossible : {error}"
    except Exception as error:  # noqa: BLE001 — le banc note l'échec et continue
        entry = {"error": str(error)[:600]}
    entry["query"] = build(0)
    if threshold is not None:
        entry["threshold_ms"] = threshold
        entry["within_threshold"] = (
            "error" not in entry and entry["client_ms_p95"] < threshold
        )
    results[name] = entry
    shown = entry.get("client_ms_median", "échec")
    print(f"  {name}: médiane {shown} ms, p95 {entry.get('client_ms_p95', '-')} ms", file=sys.stderr, flush=True)


def flag_update_sql(folder, uid):
    """Changement du drapeau « lu » : avance le numéro de modification du dossier, tient le
    compteur de non-lus, puis écrit le message — le tout dans une transaction."""
    return (
        "BEGIN;"
        f"LET $msg = (SELECT id, seen FROM ONLY bench_message WHERE mailbox = bench_mailbox:{folder} AND uid = {uid} LIMIT 1);"
        f"LET $box = (UPDATE ONLY bench_mailbox:{folder} SET highest_modseq += 1, unseen += (IF $msg.seen THEN 1 ELSE -1 END) RETURN AFTER);"
        "UPDATE $msg.id SET seen = !seen, modseq = $box.highest_modseq RETURN NONE;"
        "COMMIT;"
    )


def measure_flag_update(server, state, repetitions, results, name="flag_update"):
    rng = random.Random(11)
    try:
        client_times, server_times = [], []
        for index in range(repetitions + 3):
            folder = 0 if index % 2 == 0 else rng.choice([1, 2, 3, 4])
            uid = rng.randint(1, state["counts"][folder])
            payload, elapsed = server.sql(flag_update_sql(folder, uid))
            if index >= 3:
                client_times.append(elapsed)
                server_times.append(sum(server_ms(item["time"]) for item in payload))
        entry = summarise(client_times, server_times, [])
    except Exception as error:  # noqa: BLE001
        entry = {"error": str(error)[:600]}
    entry["query"] = flag_update_sql(0, 12345)
    entry["threshold_ms"] = THRESHOLD_FLAG_MS
    entry["within_threshold"] = "error" not in entry and entry["client_ms_p95"] < THRESHOLD_FLAG_MS
    results[name] = entry
    print(f"  {name}: médiane {entry.get('client_ms_median', 'échec')} ms, p95 {entry.get('client_ms_p95', '-')} ms", file=sys.stderr, flush=True)


def delivery_sql(folder, sequence, generator_row):
    """Remise d'un message : réserve l'UID et le numéro de modification dans le dossier, puis
    crée le message, dans une transaction."""
    row = dict(generator_row)
    fields = row_sql({**row, "folder": folder, "uid": 0}, 0)
    fields = fields.replace("uid:0,modseq:0,", "uid:$box.uid_next - 1,modseq:$box.highest_modseq,", 1)
    return (
        "BEGIN;"
        f"LET $box = (UPDATE ONLY bench_mailbox:{folder} SET uid_next += 1, highest_modseq += 1, total += 1, unseen += 1 RETURN AFTER);"
        f"CREATE bench_message CONTENT {fields} RETURN NONE;"
        "COMMIT;"
    )


def measure_delivery(server, total, count, results, name, writers=1):
    """Débit de remise message par message : `writers` clients, chacun sur son dossier."""
    generator = Generator(count * writers, seed=99 + writers)
    rows = list(generator.rows())
    errors, times = [], []
    lock = threading.Lock()

    def work(writer):
        local = []
        try:
            for index in range(count):
                row = rows[writer * count + index]
                row["seen"] = False
                _payload, elapsed = server.sql(delivery_sql(writer, index, row))
                local.append(elapsed)
        except Exception as error:  # noqa: BLE001
            with lock:
                errors.append(str(error)[:400])
        with lock:
            times.extend(local)

    started = time.perf_counter()
    threads = [threading.Thread(target=work, args=(writer,)) for writer in range(writers)]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()
    seconds = time.perf_counter() - started
    entry = {
        "writers": writers, "messages": len(times), "seconds": round(seconds, 2),
        "messages_per_s": round(len(times) / seconds, 1) if seconds else None,
        "client_ms_median": round(statistics.median(times), 2) if times else None,
        "client_ms_p95": round(percentile(times, 95), 2) if times else None,
        "errors": errors[:3], "threshold_per_s": THRESHOLD_INSERT_PER_S,
        "query": delivery_sql(0, 0, rows[0]),
    }
    entry["within_threshold"] = not errors and bool(times) and entry["messages_per_s"] >= THRESHOLD_INSERT_PER_S
    results[name] = entry
    print(f"  {name}: {entry['messages_per_s']} messages/s ({writers} client(s))", file=sys.stderr, flush=True)


def run_measures(server, state, repetitions, results, fulltext):
    rng = random.Random(3)
    inbox, inbox_count = 0, state["counts"][0]
    fields = "id, uid, received_at, size, seen, flagged, answered, thread, from_addr, from_name, subject"

    if not fulltext:
        measure_read(server, "page_first", lambda i: (
            f"SELECT {fields} FROM bench_message WHERE mailbox = bench_mailbox:{inbox if i % 2 == 0 else 1} "
            "ORDER BY received_at DESC LIMIT 50;"), repetitions, results, THRESHOLD_PAGE_MS)
        deep = min(10000, max(0, inbox_count - 100))
        measure_read(server, "page_deep_offset", lambda i: (
            f"SELECT {fields} FROM bench_message WHERE mailbox = bench_mailbox:{inbox} "
            f"ORDER BY received_at DESC LIMIT 50 START {deep};"), repetitions, results, THRESHOLD_PAGE_MS)
        very_deep = max(0, inbox_count // 2)
        measure_read(server, "page_very_deep_offset", lambda i: (
            f"SELECT {fields} FROM bench_message WHERE mailbox = bench_mailbox:{inbox} "
            f"ORDER BY received_at DESC LIMIT 50 START {very_deep};"), min(repetitions, 10), results, THRESHOLD_PAGE_MS)
        cursors = [
            (datetime.datetime(2020, 1, 1) + datetime.timedelta(days=rng.randint(200, 2000))).strftime("%Y-%m-%dT%H:%M:%SZ")
            for _ in range(repetitions + 5)
        ]
        measure_read(server, "page_deep_cursor", lambda i: (
            f"SELECT {fields} FROM bench_message WHERE mailbox = bench_mailbox:{inbox} AND received_at < d'{cursors[i]}' "
            "ORDER BY received_at DESC LIMIT 50;"), repetitions, results, THRESHOLD_PAGE_MS)

        top = state["modseq"][inbox]
        measure_read(server, "sync_changes_100", lambda i: (
            f"SELECT id, uid, modseq, seen, flagged, answered, deleted, keywords FROM bench_message "
            f"WHERE mailbox = bench_mailbox:{inbox} AND modseq > {top - 100} ORDER BY modseq LIMIT 1000;"),
            repetitions, results, THRESHOLD_SYNC_MS)
        measure_read(server, "sync_changes_5000", lambda i: (
            f"SELECT id, uid, modseq, seen, flagged, answered, deleted, keywords FROM bench_message "
            f"WHERE mailbox = bench_mailbox:{inbox} AND modseq > {max(0, top - 5000)} ORDER BY modseq LIMIT 5000;"),
            min(repetitions, 15), results, THRESHOLD_SYNC_MS)
        measure_read(server, "sync_nothing_new", lambda i: (
            f"SELECT id, uid, modseq FROM bench_message WHERE mailbox = bench_mailbox:{inbox} AND modseq > {top + 1000000} "
            "ORDER BY modseq LIMIT 1000;"), repetitions, results, THRESHOLD_SYNC_MS)

        measure_flag_update(server, state, max(repetitions, 50), results)

        measure_read(server, "unread_count_one_folder", lambda i: (
            f"SELECT count() AS unseen FROM bench_message WHERE mailbox = bench_mailbox:{inbox} AND seen = false GROUP ALL;"),
            repetitions, results)
        measure_read(server, "unread_count_all_folders_group_by", lambda i: (
            "SELECT mailbox, count() AS unseen FROM bench_message WHERE account = bench_account:1 AND seen = false GROUP BY mailbox;"),
            min(repetitions, 5), results)
        measure_read(server, "unread_count_all_folders_one_query_per_folder", lambda i: "".join(
            f"SELECT count() AS unseen FROM bench_message WHERE mailbox = bench_mailbox:{folder} AND seen = false GROUP ALL;"
            for folder in range(len(FOLDERS))), min(repetitions, 10), results)
        measure_read(server, "unread_count_kept_counter", lambda i: (
            "SELECT id, name, total, unseen, uid_next, highest_modseq FROM bench_mailbox WHERE account = bench_account:1;"),
            repetitions, results)
        measure_read(server, "total_count_one_folder", lambda i: (
            f"SELECT count() AS total FROM bench_message WHERE mailbox = bench_mailbox:{inbox} GROUP ALL;"),
            min(repetitions, 10), results)

        measure_read(server, "search_from_exact", lambda i: (
            f"SELECT {fields} FROM bench_message WHERE account = bench_account:1 AND from_addr = "
            f"{json.dumps(state['senders'][(i * 37) % 2000][1])} ORDER BY received_at DESC LIMIT 50;"), repetitions, results)
        for label, word in (("common", state["common_word"]), ("rare", RARE_WORD), ("absent", ABSENT_WORD)):
            measure_read(server, f"search_subject_scan_folder_{label}", lambda i, word=word: (
                f"SELECT {fields} FROM bench_message WHERE mailbox = bench_mailbox:{inbox} AND "
                f"string::contains(string::lowercase(subject), {json.dumps(word)}) ORDER BY received_at DESC LIMIT 50;"),
                min(repetitions, 5), results)
        measure_read(server, "search_from_name_scan_account", lambda i: (
            f"SELECT {fields} FROM bench_message WHERE account = bench_account:1 AND "
            "string::contains(string::lowercase(from_name), 'dupont') ORDER BY received_at DESC LIMIT 50;"),
            min(repetitions, 5), results)
    else:
        for label, word in (("common", state["common_word"]), ("medium", state["medium_word"]), ("rare", RARE_WORD), ("absent", ABSENT_WORD)):
            measure_read(server, f"search_subject_fulltext_{label}", lambda i, word=word: (
                f"SELECT {fields} FROM bench_message WHERE subject @@ {json.dumps(word)} LIMIT 50;"),
                min(repetitions, 15), results)
            measure_read(server, f"search_subject_fulltext_folder_sorted_{label}", lambda i, word=word: (
                f"SELECT {fields} FROM bench_message WHERE mailbox = bench_mailbox:{inbox} AND subject @@ {json.dumps(word)} "
                "ORDER BY received_at DESC LIMIT 50;"), min(repetitions, 10), results)
        measure_read(server, "search_subject_fulltext_two_words", lambda i: (
            f"SELECT {fields} FROM bench_message WHERE subject @@ {json.dumps(state['common_word'] + ' ' + state['medium_word'])} LIMIT 50;"),
            min(repetitions, 15), results)
        measure_read(server, "search_from_name_fulltext", lambda i: (
            f"SELECT {fields} FROM bench_message WHERE from_name @@ 'dupont' LIMIT 50;"), min(repetitions, 15), results)
        # Avec l'index plein texte en place : coût d'écriture et lecture de contrôle.
        measure_read(server, "page_first_with_fulltext", lambda i: (
            f"SELECT {fields} FROM bench_message WHERE mailbox = bench_mailbox:{inbox} ORDER BY received_at DESC LIMIT 50;"),
            repetitions, results, THRESHOLD_PAGE_MS)
        measure_flag_update(server, state, max(repetitions, 50), results, name="flag_update_with_fulltext")


def consistency(server):
    """Contrôle de fin : les compteurs tenus par les écritures du banc (changements de drapeau,
    remises) doivent égaler ce que la table des messages contient réellement."""
    try:
        payload, _elapsed = server.sql(
            "SELECT VALUE n FROM (SELECT count() AS n FROM bench_message WHERE mailbox = bench_mailbox:0 GROUP ALL);"
            "SELECT VALUE n FROM (SELECT count() AS n FROM bench_message WHERE mailbox = bench_mailbox:0 AND seen = false GROUP ALL);"
            "SELECT VALUE m FROM (SELECT math::max(modseq) AS m FROM bench_message WHERE mailbox = bench_mailbox:0 GROUP ALL);"
            "SELECT total, unseen, highest_modseq, uid_next FROM ONLY bench_mailbox:0;"
        )
        total, unseen, modseq, box = (payload[index]["result"] for index in range(4))
        actual = {"total": total[0] if total else 0, "unseen": unseen[0] if unseen else 0, "highest_modseq": modseq[0] if modseq else 0}
        kept = {key: box[key] for key in ("total", "unseen", "highest_modseq")}
        return {"inbox_actual": actual, "inbox_kept_counters": kept, "consistent": actual == kept}
    except Exception as error:  # noqa: BLE001
        return {"error": str(error)[:400]}


def run_variants(server, state, repetitions, results):
    """Variantes essayées quand une mesure de base dépasse un seuil ou coûte cher."""
    inbox, inbox_count = 0, state["counts"][0]
    fields = "id, uid, received_at, size, seen, flagged, answered, thread, from_addr, from_name, subject"
    deep = min(10000, max(0, inbox_count - 100))

    # Page profonde : par plage d'UID (index unique dossier + UID), comme le fait IMAP.
    measure_read(server, "variant_page_deep_uid_range", lambda i: (
        f"SELECT {fields} FROM bench_message WHERE mailbox = bench_mailbox:{inbox} AND uid <= {max(51, inbox_count - deep - i)} "
        "ORDER BY uid DESC LIMIT 50;"), repetitions, results, THRESHOLD_PAGE_MS)
    # Page profonde par décalage, identifiants seuls : sépare le coût du saut du coût de lecture.
    measure_read(server, "variant_page_deep_offset_ids_only", lambda i: (
        f"SELECT VALUE id FROM bench_message WHERE mailbox = bench_mailbox:{inbox} "
        f"ORDER BY received_at DESC LIMIT 50 START {deep};"), repetitions, results, THRESHOLD_PAGE_MS)
    # Numéro de séquence IMAP → UID : compter les messages d'UID inférieur.
    measure_read(server, "variant_count_uid_below", lambda i: (
        f"SELECT count() AS seq FROM bench_message WHERE mailbox = bench_mailbox:{inbox} AND uid <= {inbox_count // 2} GROUP ALL;"),
        min(repetitions, 10), results)

    # Compteurs tenus par la base : vue agrégée (table calculée), mise à jour à chaque écriture.
    try:
        started = time.perf_counter()
        server.sql(
            "DEFINE TABLE OVERWRITE bench_unseen_by_mailbox AS "
            "SELECT count() AS unseen, mailbox FROM bench_message WHERE seen = false GROUP BY mailbox;",
            timeout=3600,
        )
        results["variant_view_build_seconds"] = {"seconds": round(time.perf_counter() - started, 1)}
        measure_read(server, "variant_unread_count_view", lambda i: "SELECT mailbox, unseen FROM bench_unseen_by_mailbox;", repetitions, results)
        measure_flag_update(server, state, max(repetitions, 50), results, name="variant_flag_update_with_view")
        measure_delivery(server, 0, 200, results, "variant_delivery_one_by_one_with_view", writers=1)
        payload, _elapsed = server.sql(
            "SELECT VALUE unseen FROM bench_unseen_by_mailbox WHERE mailbox = bench_mailbox:0;"
            "SELECT VALUE n FROM (SELECT count() AS n FROM bench_message WHERE mailbox = bench_mailbox:0 AND seen = false GROUP ALL);"
        )
        results["variant_view_consistency"] = {"view": payload[0]["result"], "actual": payload[1]["result"], "consistent": payload[0]["result"] == payload[1]["result"]}
        server.sql("REMOVE TABLE bench_unseen_by_mailbox;", timeout=3600)
    except Exception as error:  # noqa: BLE001
        results["variant_view_error"] = {"error": str(error)[:600]}

    # Index de compte de la table entière.
    try:
        started = time.perf_counter()
        server.sql("DEFINE INDEX OVERWRITE bench_message_count ON TABLE bench_message COUNT;", timeout=3600)
        results["variant_count_index_build_seconds"] = {"seconds": round(time.perf_counter() - started, 1)}
        measure_read(server, "variant_count_whole_table_with_count_index", lambda i: "SELECT count() AS total FROM bench_message GROUP ALL;", min(repetitions, 10), results)
        measure_read(server, "variant_count_one_folder_with_count_index", lambda i: (
            f"SELECT count() AS total FROM bench_message WHERE mailbox = bench_mailbox:{inbox} GROUP ALL;"), min(repetitions, 10), results)
        server.sql("REMOVE INDEX bench_message_count ON TABLE bench_message;", timeout=3600)
    except Exception as error:  # noqa: BLE001
        results["variant_count_index_error"] = {"error": str(error)[:600]}


def wait_for_indexes(server, names, timeout):
    """Attend la fin de la construction en tâche de fond des index nommés."""
    deadline = time.monotonic() + timeout
    while True:
        states = []
        for name in names:
            payload, _elapsed = server.sql(f"INFO FOR INDEX {name} ON TABLE bench_message;")
            building = (payload[-1]["result"] or {}).get("building") or {}
            states.append(building.get("status", "ready"))
        if all(state == "ready" for state in states):
            return
        if any(state in ("error", "aborted") for state in states):
            raise RuntimeError(f"construction d'index en échec : {payload[-1]['result']}")
        if time.monotonic() > deadline:
            raise RuntimeError(f"construction d'index non terminée en {timeout} s : {states}")
        time.sleep(2)


def machine():
    cpu = ""
    try:
        for line in Path("/proc/cpuinfo").read_text().splitlines():
            if line.startswith("model name"):
                cpu = line.split(":", 1)[1].strip()
                break
        memory_kb = int(next(line for line in Path("/proc/meminfo").read_text().splitlines() if line.startswith("MemTotal")).split()[1])
    except (OSError, StopIteration, ValueError):
        memory_kb = 0
    return {
        "cpu": cpu, "cores": os.cpu_count(), "memory_gib": round(memory_kb / 1048576, 1),
        "system": f"{platform.system()} {platform.release()}", "python": platform.python_version(),
        "surreal": subprocess.run([SURREAL, "version"], capture_output=True, text=True).stdout.strip(),
    }


def directory_size(path):
    total = 0
    for current, _dirs, files in os.walk(path):
        for name in files:
            try:
                total += os.path.getsize(os.path.join(current, name))
            except OSError:
                pass
    return total


def main():
    parser = argparse.ArgumentParser(description="Banc « boîte aux lettres » sur SurrealDB.")
    parser.add_argument("--messages", type=int, default=100000)
    parser.add_argument("--engine", choices=("memory", "rocksdb", "surrealkv"), default="memory")
    parser.add_argument("--data-dir", help="dossier de données (moteurs sur disque) ; créé puis supprimé")
    parser.add_argument("--repeat", type=int, default=30)
    parser.add_argument("--out", help="fichier JSON des résultats")
    parser.add_argument("--keep", action="store_true", help="garde le dossier de données")
    parser.add_argument("--no-fulltext", action="store_true", help="ne mesure pas l'index plein texte")
    parser.add_argument("--delivery", type=int, default=600, help="messages de l'essai de remise un par un")
    parser.add_argument("--fulltext-concurrently", action="store_true", help="construit les index plein texte avec CONCURRENTLY")
    parser.add_argument("--variants", action="store_true", help="mesure aussi les variantes (plage d'UID, vue agrégée, index de compte)")
    args = parser.parse_args()

    data_dir = None
    if args.engine == "memory":
        path = "memory"
    else:
        if not args.data_dir:
            parser.error("--data-dir est requis pour un moteur sur disque")
        data_dir = Path(args.data_dir).resolve()
        if data_dir.exists() and any(data_dir.iterdir()):
            parser.error(f"{data_dir} n'est pas vide")
        data_dir.mkdir(parents=True, exist_ok=True)
        path = f"{args.engine}://{data_dir}/db"

    output = {
        "date": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "machine": machine(), "engine": args.engine, "messages": args.messages, "repeat": args.repeat,
        "measures": {},
    }
    server = Server(path)
    try:
        server.start()
        server.sql(f"DEFINE NAMESPACE IF NOT EXISTS {NS}; USE NS {NS}; DEFINE DATABASE IF NOT EXISTS {DB};")
        server.sql((HERE / "schema.surql").read_text(encoding="utf-8"))
        print(f"Chargement de {args.messages} messages ({args.engine})…", file=sys.stderr, flush=True)
        output["load"], state = load(server, args.messages, progress=True)
        if data_dir:
            # Moteur sur disque : redémarrage avant les mesures, pour lire depuis les fichiers
            # du moteur et non depuis ses tampons d'écriture (le cache du système reste chaud).
            server.stop()
            output["data_dir_bytes_after_load"] = directory_size(data_dir)
            server.start()
        print("Mesures de base…", file=sys.stderr, flush=True)
        run_measures(server, state, args.repeat, output["measures"], fulltext=False)
        measure_delivery(server, args.messages, args.delivery, output["measures"], "delivery_one_by_one", writers=1)
        measure_delivery(server, args.messages, max(100, args.delivery // 4), output["measures"], "delivery_four_clients_four_folders", writers=4)
        if args.variants:
            print("Variantes…", file=sys.stderr, flush=True)
            run_variants(server, state, args.repeat, output["measures"])

        if not args.no_fulltext:
            print("Construction des index plein texte…", file=sys.stderr, flush=True)
            started = time.perf_counter()
            try:
                fulltext_schema = (HERE / "schema_fulltext.surql").read_text(encoding="utf-8")
                if args.fulltext_concurrently:
                    # Construction en tâche de fond, par tranches, puis attente de la fin.
                    fulltext_schema = fulltext_schema.replace(" BM25;", " BM25 CONCURRENTLY;")
                    output["fulltext_build_mode"] = "CONCURRENTLY"
                server.sql(fulltext_schema, timeout=7200)
                if args.fulltext_concurrently:
                    wait_for_indexes(server, ("bench_message_subject_ft", "bench_message_from_name_ft"), 5400)
                output["fulltext_index_build_seconds"] = round(time.perf_counter() - started, 1)
                run_measures(server, state, args.repeat, output["measures"], fulltext=True)
                measure_delivery(server, args.messages, max(100, args.delivery // 2), output["measures"], "delivery_one_by_one_with_fulltext", writers=1)
            except Exception as error:  # noqa: BLE001
                output["fulltext_error"] = str(error)[:600]
                print(f"  plein texte : échec ({output['fulltext_error'][:200]})", file=sys.stderr, flush=True)
        output["consistency"] = consistency(server)
        if data_dir:
            output["data_dir_bytes_at_end"] = directory_size(data_dir)
    finally:
        server.stop()
        if data_dir and not args.keep:
            shutil.rmtree(data_dir, ignore_errors=True)
        if args.out:
            Path(args.out).write_text(json.dumps(output, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"load": output.get("load"), "measures": {
        name: {key: value for key, value in entry.items() if key not in ("explain", "query")}
        for name, entry in output["measures"].items()}}, ensure_ascii=False, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main())
