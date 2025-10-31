#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
IMPORT SIRENE → SurrealDB (Version robuste Yaniss)

✔ Nettoyage et filtrage des données
✔ Conservation des SIREN avec zéros initiaux
✔ Enregistrement des lignes brutes fautives dans erreurs_import.log
✔ Checkpoint pour reprise automatique
"""

import json
import re
from pathlib import Path
from datetime import datetime, timezone
from surrealdb import Surreal

# ============================================================
# CONFIG
# ============================================================

SIRENE_FILE = Path(r"C:\Users\Admin\Desktop\Lyxal_Solution\Lyxal_Solution\dataset\StockUniteLegale_utf8.jsonl")
SURREALDB_URL = "wss://lyxal-06bsd9k399ou7e5fa4tblm6b3g.aws-euw1.surreal.cloud/rpc"
SURREALDB_NAMESPACE = "Lyxal_Solution"
SURREALDB_DATABASE = "Labs"
SURREALDB_USER = "admin"
SURREALDB_PASSWORD = "admin"

TABLE_NAME = "business_company"
BATCH_SIZE = 50
CHECKPOINT_EVERY = 10_000
CHECKPOINT_FILE = Path("import_checkpoint.json")
ERROR_LOG_FILE = Path("erreurs_import.log")
TOTAL_ESTIMATED = 28_760_238
RESET_CHECKPOINT = False

# ============================================================
# CHECKPOINTS
# ============================================================

def load_checkpoint():
    if CHECKPOINT_FILE.exists():
        with open(CHECKPOINT_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    return {"last_processed": 0, "total_imported": 0, "errors": 0}

def save_checkpoint(cp):
    with open(CHECKPOINT_FILE, "w", encoding="utf-8") as f:
        json.dump(cp, f, indent=2)

# ============================================================
# LOG ERREURS
# ============================================================

def log_error_line(line_number: int, raw_line: str):
    """Enregistre la ligne brute du fichier source en cas d'erreur"""
    with open(ERROR_LOG_FILE, "a", encoding="utf-8") as errfile:
        errfile.write(f"{line_number}: {raw_line.strip()}\n")

# ============================================================
# UTILS
# ============================================================

def safe_id(val):
    if val is None:
        return None
    s = str(val).strip().lower()
    return re.sub(r"[^a-z0-9_]+", "_", s)

def to_surreal_date(value):
    if not value:
        return None
    val = value.strip()
    if val in ("0000-00-00", "9999-12-31"):
        return None
    try:
        dt = datetime.strptime(val, "%Y-%m-%d").replace(tzinfo=timezone.utc)
        return f"d'{dt.isoformat().replace('+00:00','Z')}'"
    except Exception:
        return None

def remove_none(d):
    if isinstance(d, dict):
        new = {k: remove_none(v) for k, v in d.items() if v is not None}
        return new if new else {}
    elif isinstance(d, list):
        return [remove_none(v) for v in d if v is not None]
    return d

def inject_recordids_and_dates(payload: str, refs: list[str]) -> str:
    for ref in refs:
        if ref:
            payload = payload.replace(f"\"{ref}\"", ref)
    payload = re.sub(r'"d\'(.*?)\'"', r"d'\1'", payload)
    return payload

# ============================================================
# CONVERSION SIRENE → OBJET COMPANY
# ============================================================

def convert_sirene_to_company(data: dict) -> dict:
    siren = str(data.get("siren", "")).zfill(9)
    nic = str(data.get("nicSiegeUniteLegale", "")).zfill(5) if data.get("nicSiegeUniteLegale") else None
    siret = f"{siren}{nic}" if siren and nic else None

    activity_code = safe_id(data.get("activitePrincipaleUniteLegale"))
    nomenclature = safe_id(data.get("nomenclatureActivitePrincipaleUniteLegale"))
    legal_form = safe_id(data.get("categorieJuridiqueUniteLegale"))
    admin_status = safe_id(data.get("etatAdministratifUniteLegale"))
    category = safe_id(data.get("categorieEntreprise"))
    workforce_range = safe_id(data.get("trancheEffectifsUniteLegale"))

    return {
        "identifiers": {
            "siren": siren,
            "nic_siege": nic,
            "siret_siege": siret,
        },
        "names": {
            "official": data.get("denominationUniteLegale"),
            "usual_1": data.get("denominationUsuelle1UniteLegale"),
            "usual_2": data.get("denominationUsuelle2UniteLegale"),
            "usual_3": data.get("denominationUsuelle3UniteLegale"),
            "sigle": data.get("sigleUniteLegale"),
        },
        "activity": {
            "code": f"business_activity_code:{nomenclature}_{activity_code}" if activity_code and nomenclature else None,
            "nomenclature": f"business_nomenclature_type:{nomenclature}" if nomenclature else None,
        },
        "legal": {
            "form": f"business_legal_form:cj_{legal_form}" if legal_form else None,
            "administrative_status": f"business_administrative_status:status_{admin_status}" if admin_status else None,
            "creation_date": to_surreal_date(data.get("dateCreationUniteLegale")) or None,
        },
        "classification": {
            "category": f"business_company_category:cat_{category}" if category else None,
            "category_year": data.get("anneeCategorieEntreprise"),
        },
        "workforce": {
            "range": f"business_workforce_range:wr_{workforce_range}" if workforce_range else None,
            "year": data.get("anneeEffectifsUniteLegale"),
        },
        "diffusion": {
            "status": data.get("statutDiffusionUniteLegale", "O"),
            "is_purged": bool(data.get("unitePurgeeUniteLegale")) if data.get("unitePurgeeUniteLegale") is not None else False,
        },
        "metadata": {
            "period_start_date": to_surreal_date(data.get("dateDebut")),
            "import_date": f"d'{datetime.now(timezone.utc).isoformat().replace('+00:00','Z')}'",
        },
    }

# ============================================================
# IMPORT PRINCIPAL
# ============================================================

def import_companies():
    checkpoint = load_checkpoint()
    if RESET_CHECKPOINT:
        checkpoint = {"last_processed": 0, "total_imported": 0, "errors": 0}
        save_checkpoint(checkpoint)
        print("♻️ Checkpoint réinitialisé — reprise à 0")

    start_line = checkpoint["last_processed"]
    total_imported = checkpoint["total_imported"]
    total_errors = checkpoint["errors"]

    db = Surreal(SURREALDB_URL)
    db.signin({"username": SURREALDB_USER, "password": SURREALDB_PASSWORD})
    db.use(SURREALDB_NAMESPACE, SURREALDB_DATABASE)
    print("✅ Connexion SurrealDB OK")

    print("🧪 Test d’écriture…")
    test_res = db.query('CREATE import_probe CONTENT { ok: true, at: time::now() };')
    print("   ↳ Réponse:", test_res)

    start_time = datetime.now()
    process_file(db, start_line, total_imported, total_errors, start_time)

# ============================================================
# TRAITEMENT DU FICHIER SIRENE
# ============================================================

def process_file(db: Surreal, start_line: int, total_imported: int, total_errors: int, start_time: datetime):
    current_line = 0
    batch_sql = []

    with open(SIRENE_FILE, "r", encoding="utf-8") as f:
        for raw in f:
            current_line += 1
            if current_line <= start_line:
                continue

            try:
                data = json.loads(raw)
                company = convert_sirene_to_company(data)
                if not company or not company["identifiers"].get("siren"):
                    total_errors += 1
                    log_error_line(current_line, raw)
                    continue

                company = remove_none(company)
                siren = company["identifiers"]["siren"]
                payload = json.dumps(company, ensure_ascii=False)

                refs = [
                    company.get("activity", {}).get("code"),
                    company.get("activity", {}).get("nomenclature"),
                    company.get("legal", {}).get("form"),
                    company.get("legal", {}).get("administrative_status"),
                    company.get("classification", {}).get("category"),
                    company.get("workforce", {}).get("range"),
                ]
                payload = inject_recordids_and_dates(payload, refs)

                if not payload.endswith("}"):
                    print(f"🚨 Payload mal formé à la ligne {current_line} — ligne originale conservée")
                    log_error_line(current_line, raw)
                    total_errors += 1
                    continue

                batch_sql.append(f"CREATE {TABLE_NAME}:s{siren} CONTENT {payload};")

                if len(batch_sql) >= BATCH_SIZE:
                    try:
                        db.query("\n".join(batch_sql))
                        total_imported += len(batch_sql)
                    except Exception as e:
                        print(f"\n❌ Erreur SurrealDB (batch fin ligne {current_line:,}): {e}")
                        print("🔎 Décomposition du batch pour identifier les fautes...")
                        for sql in batch_sql:
                            try:
                                db.query(sql)
                                total_imported += 1
                            except Exception as e_single:
                                total_errors += 1
                                print(f"⚠️ Erreur SurrealDB à la ligne {current_line}: {e_single}")
                                print(f"🧾 Ligne originale:")
                                log_error_line(current_line, raw)
                        save_checkpoint({
                            "last_processed": current_line,
                            "total_imported": total_imported,
                            "errors": total_errors,
                            "timestamp": datetime.now().isoformat(),
                        })
                    finally:
                        batch_sql.clear()

                if current_line % 1000 == 0:
                    elapsed = (datetime.now() - start_time).total_seconds()
                    rate = (current_line - start_line) / elapsed if elapsed > 0 else 0.0
                    eta_h = ((TOTAL_ESTIMATED - current_line) / rate / 3600) if rate > 0 else 0.0
                    print(f"📊 {current_line:>10,} | ✅ {total_imported:>10,} | ❌ {total_errors:>8} | ⚡ {rate:>6.0f}/s | ⏳ {eta_h:>5.1f}h")

                if current_line % CHECKPOINT_EVERY == 0:
                    save_checkpoint({
                        "last_processed": current_line,
                        "total_imported": total_imported,
                        "errors": total_errors,
                        "timestamp": datetime.now().isoformat(),
                    })
                    print(f"💾 Checkpoint @ {current_line:,}")

            except Exception as e:
                total_errors += 1
                print(f"⚠️ Erreur conversion @ ligne {current_line:,}: {e}")
                log_error_line(current_line, raw)

    if batch_sql:
        try:
            db.query("\n".join(batch_sql))
            total_imported += len(batch_sql)
        except Exception as e:
            print(f"❌ Erreur dernier batch: {e}")
            for sql in batch_sql:
                try:
                    db.query(sql)
                    total_imported += 1
                except Exception as e_single:
                    total_errors += 1
                    print(f"⚠️ Erreur SurrealDB à la fin: {e_single}")
                    log_error_line(current_line, raw)

    save_checkpoint({
        "last_processed": current_line,
        "total_imported": total_imported,
        "errors": total_errors,
        "timestamp": datetime.now().isoformat(),
    })

    elapsed = (datetime.now() - start_time).total_seconds()
    print("\n" + "=" * 100)
    print(f"✅ FIN IMPORT")
    print(f"📊 Lignes lues        : {current_line:,}")
    print(f"✅ Enregistrements OK : {total_imported:,}")
    print(f"❌ Erreurs            : {total_errors:,}")
    print(f"⏱️  Temps total        : {elapsed/3600:.2f} h")
    print("=" * 100)

# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":
    import_companies()
