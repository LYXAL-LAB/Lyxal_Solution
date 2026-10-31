//! Banc d'investigation d'acquisition exclusive par clé déterministe
//! Mandat CTO : lyxal_event Lot 2 - Phase 1 & 2
//!
//! Objectif : Déterminer si un `CREATE` ciblant un identifiant déterministe
//! `event_delivery_lock:<delivery_id>` garantit l'exclusivité d'acquisition (gagnant unique)
//! sur SurrealDB 3.2.0.

use surrealdb::engine::any::Any;
use surrealdb::Surreal;
use serde::Deserialize;

#[derive(Debug, Clone)]
pub enum LockAttemptResult {
    /// Succès : création confirmée
    Acquired {
        lock_id: String,
        lease_owner: String,
        claim_nonce: String,
    },
    /// Rejet attendu : l'enregistrement existe déjà
    AlreadyExists(String),
    /// Conflit transactionnel / MVCC
    Conflict(String),
    /// Autre erreur
    Error(String),
}

#[derive(Debug, Deserialize, Clone)]
pub struct LockAuditRow {
    pub id: surrealdb::sql::Thing,
    pub lease_owner: String,
    pub claim_nonce: String,
    pub locked_at: surrealdb::sql::Datetime,
    pub locked_until: surrealdb::sql::Datetime,
}

/// Initialise la table de verrou déterministe
pub async fn setup_lock_table(db: &Surreal<Any>) -> Result<(), surrealdb::Error> {
    let schema = "
        DEFINE TABLE OVERWRITE event_delivery_lock SCHEMAFULL;
        DEFINE FIELD OVERWRITE lease_owner ON TABLE event_delivery_lock TYPE string;
        DEFINE FIELD OVERWRITE locked_at ON TABLE event_delivery_lock TYPE datetime;
        DEFINE FIELD OVERWRITE locked_until ON TABLE event_delivery_lock TYPE datetime;
        DEFINE FIELD OVERWRITE claim_nonce ON TABLE event_delivery_lock TYPE string;
    ";
    db.query(schema).await?;
    Ok(())
}

/// Tente la création exclusive par clé déterministe
pub async fn attempt_create_deterministic_lock(
    db: &Surreal<Any>,
    lock_key: &str,
    worker_id: &str,
) -> LockAttemptResult {
    let script = format!(
        "CREATE type::thing('event_delivery_lock', '{lock_key}') CONTENT {{ \
            lease_owner: '{worker_id}', \
            locked_at: time::now(), \
            locked_until: time::now() + 10s, \
            claim_nonce: <string> rand::uuid::v7() \
        }};"
    );

    let query_res = db.query(&script).await;

    match query_res {
        Ok(mut resp) => {
            let stmt_res: Result<Vec<LockAuditRow>, surrealdb::Error> = resp.take(0);
            match stmt_res {
                Ok(rows) => {
                    if let Some(row) = rows.first() {
                        LockAttemptResult::Acquired {
                            lock_id: row.id.to_string(),
                            lease_owner: row.lease_owner.clone(),
                            claim_nonce: row.claim_nonce.clone(),
                        }
                    } else {
                        LockAttemptResult::Error("Empty rows returned on CREATE".to_string())
                    }
                }
                Err(e) => {
                    let msg = e.to_string();
                    let lower = msg.to_lowercase();
                    if lower.contains("already exists") || lower.contains("recordexists") {
                        LockAttemptResult::AlreadyExists(msg)
                    } else if lower.contains("conflict") || lower.contains("retry") {
                        LockAttemptResult::Conflict(msg)
                    } else {
                        LockAttemptResult::Error(msg)
                    }
                }
            }
        }
        Err(e) => {
            let msg = e.to_string();
            let lower = msg.to_lowercase();
            if lower.contains("already exists") || lower.contains("recordexists") {
                LockAttemptResult::AlreadyExists(msg)
            } else if lower.contains("conflict") || lower.contains("retry") {
                LockAttemptResult::Conflict(msg)
            } else {
                LockAttemptResult::Error(msg)
            }
        }
    }
}

/// Phase 1.1 : Test de concurrence à 2 workers (100 itérations)
pub async fn run_phase1_two_workers(
    db: &Surreal<Any>,
    iterations: usize,
) -> Result<(usize, usize, usize, usize), surrealdb::Error> {
    println!("\n=== [PHASE 1.1] CONCURRENCE À 2 WORKERS ({} ITÉRATIONS) ===", iterations);
    setup_lock_table(db).await?;

    let mut single_winner_count = 0;
    let mut double_winner_count = 0;
    let mut zero_winner_count = 0;
    let mut total_already_exists = 0;

    for i in 1..=iterations {
        let lock_key = format!("del_{i}_{}", uuid::Uuid::now_v7());

        let db1 = db.clone();
        let db2 = db.clone();
        let key1 = lock_key.clone();
        let key2 = lock_key.clone();

        // Exécution simultanée stricte des deux CREATE
        let (res1, res2) = tokio::join!(
            attempt_create_deterministic_lock(&db1, &key1, "worker_1"),
            attempt_create_deterministic_lock(&db2, &key2, "worker_2"),
        );

        let mut winners = Vec::new();
        let mut rejections = 0;

        match &res1 {
            LockAttemptResult::Acquired { lease_owner, claim_nonce, .. } => {
                winners.push((lease_owner.clone(), claim_nonce.clone()));
            }
            LockAttemptResult::AlreadyExists(_) => rejections += 1,
            _ => {}
        }

        match &res2 {
            LockAttemptResult::Acquired { lease_owner, claim_nonce, .. } => {
                winners.push((lease_owner.clone(), claim_nonce.clone()));
            }
            LockAttemptResult::AlreadyExists(_) => rejections += 1,
            _ => {}
        }

        total_already_exists += rejections;

        // Audit de l'état persistant dans la table de lock
        let mut audit_res = db.query(format!(
            "SELECT * FROM type::thing('event_delivery_lock', '{lock_key}');"
        )).await?;
        let audit_rows: Vec<LockAuditRow> = audit_res.take(0).unwrap_or_default();
        let persisted_lock = audit_rows.first();

        if winners.len() == 1 {
            let (winner_owner, winner_nonce) = &winners[0];
            // Vérifier que la ligne en base correspond exactement au gagnant
            if let Some(actual) = persisted_lock {
                if actual.lease_owner == *winner_owner && actual.claim_nonce == *winner_nonce {
                    single_winner_count += 1;
                } else {
                    eprintln!("  [ALERTE CRITIQUE ITÉRATION {i}] Incohérence entre confirmation et état base !");
                    double_winner_count += 1;
                    return Ok((single_winner_count, double_winner_count, zero_winner_count, total_already_exists));
                }
            } else {
                eprintln!("  [ALERTE CRITIQUE ITÉRATION {i}] Confirmation reçue mais ligne introuvable en base !");
                zero_winner_count += 1;
            }
        } else if winners.len() > 1 {
            double_winner_count += 1;
            eprintln!("  [ALERTE CRITIQUE SUR ITÉRATION {i}] Double acquisition confirmée !");
            eprintln!("     Worker 1: {:?}", res1);
            eprintln!("     Worker 2: {:?}", res2);
            eprintln!("     État en base : {:?}", persisted_lock);
            // STOP IMMÉDIAT
            return Ok((single_winner_count, double_winner_count, zero_winner_count, total_already_exists));
        } else {
            zero_winner_count += 1;
            eprintln!("  [ALERTE ITÉRATION {i}] Zéro gagnant ! res1: {:?}, res2: {:?}", res1, res2);
        }

        if i % 25 == 0 || i == iterations {
            println!("  -> Progrès : {}/{} (Gagnant unique validé: {}, Erreurs 'already exists': {})",
                i, iterations, single_winner_count, total_already_exists
            );
        }
    }

    println!("\n=== [BILAN PHASE 1.1 - 2 WORKERS] ===");
    println!("  Total essais : {}", iterations);
    println!("  Gagnant unique certifié (PASS) : {}", single_winner_count);
    println!("  Doubles acquisitions (FAIL) : {}", double_winner_count);
    println!("  Zéro gagnant : {}", zero_winner_count);
    println!("  Rejets 'Already exists' capturés : {}", total_already_exists);

    Ok((single_winner_count, double_winner_count, zero_winner_count, total_already_exists))
}

/// Phase 1.2 : Test de saturation à 10 workers concurrents (100 itérations)
pub async fn run_phase1_ten_workers(
    db: &Surreal<Any>,
    iterations: usize,
) -> Result<(usize, usize, usize, usize), surrealdb::Error> {
    println!("\n=== [PHASE 1.2] SATURATION À 10 WORKERS CONCURRENTS ({} ITÉRATIONS) ===", iterations);

    let mut single_winner_count = 0;
    let mut double_winner_count = 0;
    let mut zero_winner_count = 0;
    let mut total_already_exists = 0;

    for i in 1..=iterations {
        let lock_key = format!("del_sat_{i}_{}", uuid::Uuid::now_v7());

        let mut handles = Vec::new();
        for w in 1..=10 {
            let db_clone = db.clone();
            let key_clone = lock_key.clone();
            let worker_id = format!("worker_{w}");
            handles.push(tokio::spawn(async move {
                attempt_create_deterministic_lock(&db_clone, &key_clone, &worker_id).await
            }));
        }

        let mut winners = Vec::new();
        let mut rejections = 0;

        for h in handles {
            let res = h.await.unwrap();
            match res {
                LockAttemptResult::Acquired { lease_owner, claim_nonce, .. } => {
                    winners.push((lease_owner, claim_nonce));
                }
                LockAttemptResult::AlreadyExists(_) => {
                    rejections += 1;
                }
                _ => {}
            }
        }

        total_already_exists += rejections;

        // Audit persistant
        let mut audit_res = db.query(format!(
            "SELECT * FROM type::thing('event_delivery_lock', '{lock_key}');"
        )).await?;
        let audit_rows: Vec<LockAuditRow> = audit_res.take(0).unwrap_or_default();
        let persisted_lock = audit_rows.first();

        if winners.len() == 1 {
            let (winner_owner, winner_nonce) = &winners[0];
            if let Some(actual) = persisted_lock {
                if actual.lease_owner == *winner_owner && actual.claim_nonce == *winner_nonce {
                    single_winner_count += 1;
                } else {
                    eprintln!("  [ALERTE CRITIQUE SATURATION {i}] Désynchronisation gagnant / base !");
                    double_winner_count += 1;
                    return Ok((single_winner_count, double_winner_count, zero_winner_count, total_already_exists));
                }
            } else {
                zero_winner_count += 1;
            }
        } else if winners.len() > 1 {
            double_winner_count += 1;
            eprintln!("  [ALERTE CRITIQUE SATURATION {i}] Multiples gagnants détectés : {:?}", winners);
            return Ok((single_winner_count, double_winner_count, zero_winner_count, total_already_exists));
        } else {
            zero_winner_count += 1;
        }

        if i % 25 == 0 || i == iterations {
            println!("  -> Progrès Saturation : {}/{} (Gagnant unique certifié: {}, Rejets: {})",
                i, iterations, single_winner_count, total_already_exists
            );
        }
    }

    println!("\n=== [BILAN PHASE 1.2 - 10 WORKERS] ===");
    println!("  Total essais : {}", iterations);
    println!("  Gagnant unique certifié (PASS) : {}", single_winner_count);
    println!("  Doubles acquisitions (FAIL) : {}", double_winner_count);
    println!("  Zéro gagnant : {}", zero_winner_count);
    println!("  Rejets 'Already exists' capturés (attendu ~9 par essai) : {}", total_already_exists);

    Ok((single_winner_count, double_winner_count, zero_winner_count, total_already_exists))
}

