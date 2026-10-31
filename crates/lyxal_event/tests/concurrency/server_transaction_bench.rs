//! Banc d'investigation transactionnelle serveur pour lyxal_event Lot 2
//!
//! Étape 1 : Diagnostic WebSocket (incompatibilité subprotocol documentée)
//! Étape 2 : Test transactionnel isolé en appel query unique (`BEGIN TRANSACTION ... COMMIT TRANSACTION`)
//!           avec distinction résultat UPDATE vs résultat COMMIT (100 répétitions).
//! Étape 3 : Vérification empirique des fonctions SurrealQL `fn::` (atomicité vs autocommit).

use surrealdb::engine::any::Any;
use surrealdb::Surreal;
use serde::Deserialize;

#[derive(Debug, Clone)]
pub enum Step2WorkerResult {
    /// Succès complet : UPDATE a retourné la ligne ET COMMIT a été validé sans erreur
    ConfirmedClaim { id: String, nonce: String },
    /// UPDATE a trouvé 0 ligne (la ligne a déjà été verrouillée/mise à jour par le concurrent)
    EmptyUpdate,
    /// Conflit MVCC / Transactionnel au niveau du COMMIT (rollback automatique)
    CommitConflict(String),
    /// Autre erreur
    ExecutionError(String),
}

/// Prépare une livraison de test propre
async fn setup_single_pending_delivery(db: &Surreal<Any>, test_name: &str) -> Result<String, surrealdb::Error> {
    db.query("DEFINE FIELD OVERWRITE claim_nonce ON TABLE event_delivery TYPE option<string>;").await?;

    let init_parents = format!(
        "LET $sub = (CREATE event_subscription CONTENT {{
            name: 'sub_{test_name}',
            target_module: 'test_module',
            event_pattern: 'test.*',
            handler_name: 'test_handler',
            max_attempts: 5
        }});
        LET $outbox = (CREATE event_outbox CONTENT {{
            event_id: rand::uuid::v7(),
            event_type: 'test.evt',
            producer: 'test_producer',
            correlation_id: rand::uuid::v7(),
            payload: {{}},
            context: {{ instance_id: 'inst_{test_name}', namespace: 'test', database: 'test' }}
        }});
        CREATE event_delivery CONTENT {{
            target_module: 'test_module',
            status: 'pending',
            attempts: 0,
            max_attempts: 5,
            next_retry_at: time::now(),
            outbox_event: $outbox[0].id,
            subscription: $sub[0].id,
            context: {{ instance_id: 'inst_{test_name}', namespace: 'test', database: 'test' }}
        }} RETURN id;"
    );

    let mut setup_res = db.query(init_parents).await?;
    #[derive(Deserialize)]
    struct IdRow { id: surrealdb::sql::Thing }
    let rows: Vec<IdRow> = setup_res.take(2)?;
    let target_id = rows.first().unwrap().id.to_string();
    Ok(target_id)
}

/// Exécute une tentative d'acquisition transactionnelle en un seul appel `db.query()`
async fn execute_server_transaction_claim(
    db: &Surreal<Any>,
    target_id: &str,
    worker_id: &str,
) -> Step2WorkerResult {
    // Requête unique englobant la transaction complète :
    // BEGIN TRANSACTION -> UPDATE conditionnel avec sous-sélection -> COMMIT TRANSACTION
    let script = format!(
        "BEGIN TRANSACTION; \
         UPDATE (SELECT VALUE id FROM {target_id} WHERE status = 'pending' LIMIT 1) \
             SET status = 'processing', \
                 lease_owner = '{worker_id}', \
                 claim_nonce = <string> rand::uuid::v7(), \
                 locked_until = time::now() + 10s \
             WHERE status = 'pending' \
             RETURN AFTER; \
         COMMIT TRANSACTION;"
    );

    let query_res = db.query(&script).await;

    match query_res {
        Ok(mut resp) => {
            let statement_res: Result<surrealdb::Value, surrealdb::Error> = resp.take(0);
            match statement_res {
                Ok(val) => {
                    let s = val.to_string();
                    // L'UPDATE retourne `Array(Array([Object(...)]))` s'il a modifié la ligne
                    // ou `Array(Array([]))` s'il a modifié 0 ligne.
                    if s.contains("event_delivery") && s.contains("processing") {
                        let id = target_id.to_string();
                        // Recherche du nonce dans la représentation
                        let nonce = if let Some(idx) = s.find("01a1") {
                            s[idx..idx+36.min(s.len()-idx)].to_string()
                        } else {
                            "detected".to_string()
                        };
                        Step2WorkerResult::ConfirmedClaim { id, nonce }
                    } else {
                        Step2WorkerResult::EmptyUpdate
                    }
                }
                Err(e) => {
                    let err_msg = e.to_string();
                    if err_msg.to_lowercase().contains("conflict")
                        || err_msg.to_lowercase().contains("transaction")
                        || err_msg.to_lowercase().contains("retry")
                    {
                        Step2WorkerResult::CommitConflict(err_msg)
                    } else {
                        Step2WorkerResult::ExecutionError(err_msg)
                    }
                }
            }
        }
        Err(e) => {
            let err_msg = e.to_string();
            if err_msg.to_lowercase().contains("conflict")
                || err_msg.to_lowercase().contains("transaction")
                || err_msg.to_lowercase().contains("retry")
            {
                Step2WorkerResult::CommitConflict(err_msg)
            } else {
                Step2WorkerResult::ExecutionError(err_msg)
            }
        }
    }
}

/// Étape 2 : Exécution de l'investigation transactionnelle (100 itérations concurrentes)
pub async fn run_step2_server_transactions(
    db: &Surreal<Any>,
    iterations: usize,
) -> Result<(usize, usize, usize, usize), surrealdb::Error> {
    println!("\n=== [ÉTAPE 2] TEST TRANSACTIONNEL SERVEUR UNIQUE ({} RÉPÉTITIONS) ===", iterations);

    let mut single_winner_count = 0;
    let mut double_winner_count = 0;
    let mut zero_winner_count = 0;
    let mut total_mvcc_conflicts = 0;

    for i in 1..=iterations {
        let target_id = setup_single_pending_delivery(db, &format!("s2_{i}")).await?;

        let db1 = db.clone();
        let db2 = db.clone();
        let tid1 = target_id.clone();
        let tid2 = target_id.clone();

        // Lancement concurrent strict de deux workers
        let (res1, res2) = tokio::join!(
            execute_server_transaction_claim(&db1, &tid1, "worker_tx1"),
            execute_server_transaction_claim(&db2, &tid2, "worker_tx2"),
        );

        let mut confirmed_claims = 0;
        let mut conflicts = 0;

        match res1 {
            Step2WorkerResult::ConfirmedClaim { .. } => confirmed_claims += 1,
            Step2WorkerResult::CommitConflict(_) => conflicts += 1,
            _ => {}
        }

        match res2 {
            Step2WorkerResult::ConfirmedClaim { .. } => confirmed_claims += 1,
            Step2WorkerResult::CommitConflict(_) => conflicts += 1,
            _ => {}
        }

        total_mvcc_conflicts += conflicts;

        // Contrôle de l'état final persistant en base
        #[derive(Deserialize, Debug)]
        #[allow(dead_code)]
        struct AuditRow {
            status: String,
            lease_owner: Option<String>,
            claim_nonce: Option<String>,
        }
        let mut audit_res = db.query(format!("SELECT status, lease_owner, claim_nonce FROM {target_id};")).await?;
        let final_rows: Vec<AuditRow> = audit_res.take(0).unwrap_or_default();
        let final_row = final_rows.first();
        let final_status = final_row.map(|r| r.status.as_str()).unwrap_or("unknown");

        if confirmed_claims == 1 && final_status == "processing" {
            single_winner_count += 1;
        } else if confirmed_claims > 1 {
            double_winner_count += 1;
            eprintln!("  [ALERTE CRITIQUE SUR ITÉRATION {}] Double confirmation de commit observée !", i);
            eprintln!("     Worker 1: {:?}", res1);
            eprintln!("     Worker 2: {:?}", res2);
            eprintln!("     État final en base : {:?}", final_row);
            // STOP IMMÉDIAT EN CAS DE DOUBLE ACQUISITION
            return Ok((single_winner_count, double_winner_count, zero_winner_count, total_mvcc_conflicts));
        } else {
            zero_winner_count += 1;
        }

        if i % 25 == 0 || i == iterations {
            println!("  -> Progrès : {}/{} essais complétés (Exclusivité confirmée: {}, Conflits MVCC: {})",
                i, iterations, single_winner_count, total_mvcc_conflicts
            );
        }
    }

    println!("\n=== [BILAN ÉTAPE 2] ===");
    println!("  Total essais : {}", iterations);
    println!("  Acquisitions uniques confirmées (PASS) : {}", single_winner_count);
    println!("  Doubles acquisitions (FAIL) : {}", double_winner_count);
    println!("  Zéro acquisition (avortées/conflit mutuel) : {}", zero_winner_count);
    println!("  Total rejets de commit MVCC : {}", total_mvcc_conflicts);

    Ok((single_winner_count, double_winner_count, zero_winner_count, total_mvcc_conflicts))
}

/// Étape 3 : Examen empirique des fonctions SurrealQL `fn::`
pub async fn run_step3_function_transactional_probe(
    db: &Surreal<Any>,
) -> Result<(usize, usize), surrealdb::Error> {
    println!("\n=== [ÉTAPE 3] VÉRIFICATION DES PROPRIÉTÉS TRANSACTIONNELLES D'UNE FONCTION FN:: ===");

    // Test 3.1 : Définition d'une fonction encapsulant l'UPDATE conditionnel
    println!("  -> Test 3.1 : Enregistrement de fn::test_claim_func...");
    let def_fn = "
        DEFINE FUNCTION OVERWRITE fn::test_claim_func($del_id: string, $worker: string) {
            LET $rec = type::thing('event_delivery', $del_id);
            LET $res = (UPDATE (SELECT VALUE id FROM $rec WHERE status = 'pending' LIMIT 1)
                SET status = 'processing',
                    lease_owner = $worker,
                    claim_nonce = <string> rand::uuid::v7(),
                    locked_until = time::now() + 10s
                WHERE status = 'pending'
                RETURN AFTER);
            RETURN $res;
        };
    ";
    db.query(def_fn).await?;

    // Test de concurrence sur fn::test_claim_func (20 répétitions)
    let mut fn_single_winner = 0;
    let mut fn_double_winner = 0;

    for i in 1..=20 {
        let target_id = setup_single_pending_delivery(db, &format!("fn_{i}")).await?;
        let clean_id = target_id.trim_start_matches("event_delivery:").to_string();

        let q1 = format!("fn::test_claim_func('{clean_id}', 'w1');");
        let q2 = format!("fn::test_claim_func('{clean_id}', 'w2');");

        let (res1, res2) = tokio::join!(
            db.query(&q1),
            db.query(&q2),
        );

        let mut claims = 0;
        let check_fn_res = |res: Result<surrealdb::Response, surrealdb::Error>| -> bool {
            if let Ok(mut r) = res {
                if let Ok(val) = r.take::<surrealdb::Value>(0) {
                    let s = val.to_string();
                    return s.contains("event_delivery") && s.contains("processing");
                }
            }
            false
        };

        if check_fn_res(res1) { claims += 1; }
        if check_fn_res(res2) { claims += 1; }

        if claims == 1 {
            fn_single_winner += 1;
        } else if claims > 1 {
            fn_double_winner += 1;
        }
    }

    println!("  -> Résultats sur 20 courses fn:: directes :");
    println!("     Acquisitions exclusives : {} / 20", fn_single_winner);
    println!("     Doubles acquisitions : {} / 20", fn_double_winner);

    // Test 3.2 : Est-ce qu'une fonction peut contenir explicitement BEGIN / COMMIT ?
    println!("\n  -> Test 3.2 : Test de syntaxe BEGIN / COMMIT à l'intérieur d'une fonction fn::...");
    let def_fn_txn = "
        DEFINE FUNCTION OVERWRITE fn::test_fn_with_txn() {
            BEGIN TRANSACTION;
            CREATE h07_fn_test CONTENT { a: 1 };
            COMMIT TRANSACTION;
            RETURN true;
        };
    ";
    let txn_fn_res = db.query(def_fn_txn).await;
    match txn_fn_res {
        Ok(r) => {
            match r.check() {
                Ok(_) => println!("     Syntaxe BEGIN TRANSACTION acceptée dans le corps de fn::"),
                Err(e) => println!("     Syntaxe BEGIN TRANSACTION rejetée dans le corps de fn:: : {}", e),
            }
        }
        Err(e) => println!("     Erreur enregistrement fonction avec transaction : {}", e),
    }

    Ok((fn_single_winner, fn_double_winner))
}
