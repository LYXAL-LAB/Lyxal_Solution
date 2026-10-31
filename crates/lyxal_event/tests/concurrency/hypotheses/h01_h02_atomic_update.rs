//! Expérimentation des hypothèses H-01 et H-02
//! H-01 : Réévaluation atomique de la clause WHERE englobante au moment du verrou d'écriture (latched read)
//! H-02 : Granularité d'évaluation par ligne de `rand::uuid::v7()`
//! Référence : LOT2_BENCHMARK_IMPLEMENTATION_PLAN.md §5 & Mandat Porte 1

use surrealdb::engine::any::Any;
use surrealdb::Surreal;
use std::collections::HashSet;
use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct ClaimResult {
    pub id: surrealdb::sql::Thing,
    pub claim_nonce: Option<serde_json::Value>,
}

#[derive(Debug)]
pub enum QueryOutcome {
    Claimed { id: String, nonce: Option<String> },
    Empty,
    MvccConflict(String),
    OtherError(String),
}

/// Éprouve l'hypothèse H-01 sur SurrealDB 3.2.0 :
/// Deux requêtes atomiques Option B concurrentes ciblant la même ligne unique
pub async fn test_hypothesis_h01(db: &Surreal<Any>) -> Result<bool, surrealdb::Error> {
    println!("\n=== [H-01] TEST ATOMICITÉ & EXCLUSIVITÉ UPDATE CONCURRENT (OPTION B) ===");

    // 0. Déclaration du champ claim_nonce pour conformité SCHEMAFULL
    db.query("DEFINE FIELD OVERWRITE claim_nonce ON TABLE event_delivery TYPE option<string>;").await?;

    // 1. Initialisation des parents SCHEMAFULL (outbox et subscription)
    let init_parents = "
        LET $sub = (CREATE event_subscription CONTENT {
            name: 'sub_h01',
            target_module: 'test_h01',
            event_pattern: 'test.*',
            handler_name: 'handler_h01',
            max_attempts: 5
        });
        LET $outbox = (CREATE event_outbox CONTENT {
            event_id: rand::uuid::v7(),
            event_type: 'test.evt',
            producer: 'test_h01',
            correlation_id: rand::uuid::v7(),
            payload: {},
            context: { instance_id: 'inst_h01', namespace: 'test', database: 'test' }
        });
        CREATE event_delivery CONTENT {
            target_module: 'test_h01',
            status: 'pending',
            attempts: 0,
            max_attempts: 5,
            next_retry_at: time::now(),
            outbox_event: $outbox[0].id,
            subscription: $sub[0].id,
            context: { instance_id: 'inst_h01', namespace: 'test', database: 'test' }
        } RETURN id;
    ";

    let mut setup_res = db.query(init_parents).await?;

    #[derive(Deserialize)]
    struct IdRow { id: surrealdb::sql::Thing }
    let rows: Vec<IdRow> = setup_res.take(2)?;
    let target_id = rows.first().unwrap().id.to_string();
    println!("  -> Ligne cible créée : {}", target_id);

    let query_w1 = format!(
        "UPDATE (SELECT VALUE id FROM {} WHERE status = 'pending' LIMIT 1) \
         SET status = 'processing', lease_owner = 'worker_w1', claim_nonce = <string> rand::uuid::v7(), locked_until = time::now() + 10s \
         WHERE status = 'pending' RETURN AFTER;",
        target_id
    );

    let query_w2 = format!(
        "UPDATE (SELECT VALUE id FROM {} WHERE status = 'pending' LIMIT 1) \
         SET status = 'processing', lease_owner = 'worker_w2', claim_nonce = <string> rand::uuid::v7(), locked_until = time::now() + 10s \
         WHERE status = 'pending' RETURN AFTER;",
        target_id
    );

    println!("  -> Lancement simultané des requêtes concurrentes (w1 vs w2)...");
    let (res1, res2) = tokio::join!(
        db.query(&query_w1),
        db.query(&query_w2)
    );

    let parse_outcome = |res: Result<surrealdb::Response, surrealdb::Error>| -> QueryOutcome {
        match res {
            Ok(mut r) => {
                match r.take::<Vec<ClaimResult>>(0) {
                    Ok(items) => {
                        if let Some(item) = items.into_iter().next() {
                            QueryOutcome::Claimed {
                                id: item.id.to_string(),
                                nonce: item.claim_nonce.map(|v| v.to_string()),
                            }
                        } else {
                            QueryOutcome::Empty
                        }
                    }
                    Err(e) => {
                        let err_msg = e.to_string();
                        if err_msg.to_lowercase().contains("conflict")
                            || err_msg.to_lowercase().contains("transaction")
                            || err_msg.to_lowercase().contains("retry")
                        {
                            QueryOutcome::MvccConflict(err_msg)
                        } else {
                            QueryOutcome::OtherError(err_msg)
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
                    QueryOutcome::MvccConflict(err_msg)
                } else {
                    QueryOutcome::OtherError(err_msg)
                }
            }
        }
    };

    let outcome_w1 = parse_outcome(res1);
    let outcome_w2 = parse_outcome(res2);

    println!("  -> Résultat Worker w1 : {:?}", outcome_w1);
    println!("  -> Résultat Worker w2 : {:?}", outcome_w2);

    let is_claimed_w1 = matches!(outcome_w1, QueryOutcome::Claimed { .. });
    let is_claimed_w2 = matches!(outcome_w2, QueryOutcome::Claimed { .. });

    // Contrôle d'état final de la ligne en base
    #[derive(Deserialize, Debug)]
    struct FinalState {
        _status: String,
        _lease_owner: Option<String>,
        _claim_nonce: Option<serde_json::Value>,
    }

    let mut audit_res = db
        .query(format!("SELECT status AS _status, lease_owner AS _lease_owner, claim_nonce AS _claim_nonce FROM {};", target_id))
        .await?;
    let final_states: Vec<FinalState> = audit_res.take(0)?;
    println!("  -> État final en base : {:?}", final_states.first());

    // Analyse de conformité CTO :
    let mut claims_won = 0;
    if is_claimed_w1 { claims_won += 1; }
    if is_claimed_w2 { claims_won += 1; }

    println!("  -> Total acquisitions confirmées : {}", claims_won);

    if claims_won > 1 {
        eprintln!("  [CRITIQUE] DOUBLE DÉTENTION DÉTECTÉE ! H-01 INVALIDÉE !");
        return Ok(false);
    }

    if claims_won == 1 {
        println!("  [SUCCÈS] Exclusivité parfaite : exactement 1 winner.");
        let loser_clean = match (&outcome_w1, &outcome_w2) {
            (QueryOutcome::Claimed { .. }, QueryOutcome::Empty) => {
                println!("  -> Mécanisme observé : Latched Read natif (clause WHERE réévaluée à vide).");
                true
            }
            (QueryOutcome::Claimed { .. }, QueryOutcome::MvccConflict(msg)) => {
                println!("  -> Mécanisme observé : Conflit MVCC rejeté ({}) compatible avec exclusivité.", msg);
                true
            }
            (QueryOutcome::Empty, QueryOutcome::Claimed { .. }) => {
                println!("  -> Mécanisme observé : Latched Read natif (clause WHERE réévaluée à vide).");
                true
            }
            (QueryOutcome::MvccConflict(msg), QueryOutcome::Claimed { .. }) => {
                println!("  -> Mécanisme observé : Conflit MVCC rejeté ({}) compatible avec exclusivité.", msg);
                true
            }
            _ => false,
        };
        Ok(loser_clean)
    } else {
        println!("  [ALERTE] 0 claim réussi (les deux ont échoué ou conflit mutuel).");
        Ok(false)
    }
}

/// Éprouve l'hypothèse H-02 sur SurrealDB 3.2.0 :
/// Évalue si `rand::uuid::v7()` est évalué à chaque ligne ou une seule fois par instruction
pub async fn test_hypothesis_h02(db: &Surreal<Any>, batch_size: usize) -> Result<bool, surrealdb::Error> {
    println!("\n=== [H-02] TEST ÉVALUATION DE RAND::UUID::V7() PAR LIGNE ===");

    // Déclaration du champ claim_nonce pour conformité SCHEMAFULL
    db.query("DEFINE FIELD OVERWRITE claim_nonce ON TABLE event_delivery TYPE option<string>;").await?;

    println!("  -> Insertion de {} livraisons de test avec parents SCHEMAFULL...", batch_size);

    let setup_parents = "
        LET $sub = (CREATE event_subscription CONTENT {
            name: 'sub_h02',
            target_module: 'test_h02',
            event_pattern: 'test.*',
            handler_name: 'handler_h02',
            max_attempts: 5
        });
        LET $outbox = (CREATE event_outbox CONTENT {
            event_id: rand::uuid::v7(),
            event_type: 'test.evt',
            producer: 'test_h02',
            correlation_id: rand::uuid::v7(),
            payload: {},
            context: { instance_id: 'inst_h02', namespace: 'test', database: 'test' }
        });
        RETURN [$sub[0].id, $outbox[0].id];
    ";
    let mut p_res = db.query(setup_parents).await?;
    let parents: Option<Vec<surrealdb::sql::Thing>> = p_res.take(2)?;
    let (sub_ref, outbox_ref) = match parents {
        Some(p) if p.len() >= 2 => (p[0].to_string(), p[1].to_string()),
        _ => ("event_subscription:sub_h02".to_string(), "event_outbox:outbox_h02".to_string()),
    };

    let mut setup_q = String::from("BEGIN TRANSACTION;\n");
    for i in 0..batch_size {
        setup_q.push_str(&format!(
            "CREATE event_delivery CONTENT {{ \
                target_module: 'test_h02', \
                status: 'pending', \
                attempts: 0, \
                max_attempts: 5, \
                next_retry_at: time::now(), \
                outbox_event: {}, \
                subscription: {}, \
                context: {{ instance_id: 'inst_h02_{}', namespace: 'test', database: 'test' }} \
            }};\n",
            outbox_ref, sub_ref, i
        ));
    }
    setup_q.push_str("COMMIT TRANSACTION;\n");
    db.query(&setup_q).await?;

    println!("  -> Exécution de l'UPDATE vectorisé avec <string> rand::uuid::v7()...");
    let mut res = db
        .query(
            "UPDATE (SELECT VALUE id FROM event_delivery WHERE target_module = 'test_h02' AND status = 'pending') \
             SET status = 'processing', claim_nonce = <string> rand::uuid::v7() \
             WHERE target_module = 'test_h02' AND status = 'pending' RETURN AFTER;"
        )
        .await?;

    let items: Vec<ClaimResult> = res.take(0)?;
    let mut unique_nonces = HashSet::new();

    for item in &items {
        if let Some(ref nonce) = item.claim_nonce {
            unique_nonces.insert(nonce.to_string());
        }
    }

    println!("  -> Nombre de lignes mises à jour : {}", items.len());
    println!("  -> Nombre de nonces uniques générés : {}", unique_nonces.len());

    let is_valid = items.len() == batch_size && unique_nonces.len() == batch_size;
    if is_valid {
        println!("  [SUCCÈS] H-02 VALIDÉE : 100% des nonces sont distincts (évaluation par ligne).");
    } else {
        println!("  [ÉCHEC] H-02 INVALIDÉE : Détection de collisions ou évaluation statique par instruction.");
    }

    Ok(is_valid)
}
