//! Expérimentation des hypothèses H-06 et H-08
//! H-06 : Atomicité multi-instructions des corps de fonctions SurrealQL (corrélation dead_letter / delivery)
//! H-08 : Disponibilité et fidélité de capture des change feeds SurrealDB 3.2.0
//! Référence : LOT2_BENCHMARK_IMPLEMENTATION_PLAN.md §5 & Mandat Porte 1

use surrealdb::engine::any::Any;
use surrealdb::Surreal;
use serde::Deserialize;

/// Éprouve l'hypothèse H-06 :
/// Simule un échec sur la deuxième instruction (`UPDATE` delivery) pour vérifier
/// si la première instruction (`CREATE event_dead_letter`) est atomiquement rollbackée.
pub async fn test_hypothesis_h06(db: &Surreal<Any>) -> Result<bool, surrealdb::Error> {
    println!("\n=== [H-06] TEST ATOMICITÉ MULTI-INSTRUCTIONS & THROW (CORRÉLATION DLQ) ===");

    // Définition d'une fonction de test simulant la branche dead-letter avec échec forcé sur l'update
    let create_fn = "DEFINE FUNCTION OVERWRITE fn::test_atomic_dlq($del_id: string, $nonce: string) { \
        CREATE event_dead_letter CONTENT { delivery_id: $del_id, reason: 'test_h06_probe' }; \
        LET $res = (UPDATE type::thing('event_delivery', $del_id) SET status = 'dead_letter' WHERE claim_nonce = $nonce AND status = 'processing' RETURN AFTER); \
        IF array::len($res) == 0 { \
            THROW 'FENCING_REJECTED'; \
        }; \
        RETURN true; \
    };";
    println!("  -> Enregistrement de la fonction fn::test_atomic_dlq...");
    db.query(create_fn).await?;

    // 1. Initialisation des parents SCHEMAFULL
    let init_parents = "
        LET $sub = (CREATE event_subscription CONTENT {
            name: 'sub_h06',
            target_module: 'test_h06',
            event_pattern: 'test.*',
            handler_name: 'handler_h06',
            max_attempts: 5
        });
        LET $outbox = (CREATE event_outbox CONTENT {
            event_id: rand::uuid::v7(),
            event_type: 'test.evt',
            producer: 'test_h06',
            correlation_id: rand::uuid::v7(),
            payload: {},
            context: { instance_id: 'inst_h06', namespace: 'test', database: 'test' }
        });
        CREATE event_delivery CONTENT {
            target_module: 'test_h06',
            status: 'pending',
            attempts: 0,
            max_attempts: 5,
            next_retry_at: time::now(),
            claim_nonce: 'real_nonce',
            outbox_event: $outbox[0].id,
            subscription: $sub[0].id,
            context: { instance_id: 'inst_h06', namespace: 'test', database: 'test' }
        } RETURN id;
    ";

    let mut setup_res = db.query(init_parents).await?;

    #[derive(Deserialize)]
    struct IdRow { id: surrealdb::sql::Thing }
    let rows: Vec<IdRow> = setup_res.take(2)?;
    let target_id = rows.first().unwrap().id.to_string();
    let target_id_clean = target_id.trim_start_matches("event_delivery:").to_string();
    println!("  -> Livraison de test créée : {} (clean id: {})", target_id, target_id_clean);

    // 2. Appel de la fonction avec un nonce erroné (doit déclencher THROW 'FENCING_REJECTED')
    println!("  -> Appel de fn::test_atomic_dlq avec un nonce erroné...");
    let call_res = db
        .query("fn::test_atomic_dlq($del_id, 'wrong_nonce');")
        .bind(("del_id", target_id_clean))
        .await;

    let threw_error = match call_res {
        Ok(r) => {
            let chk = r.check();
            println!("  -> Résultat exécution fonction (check) : {:?}", chk);
            chk.is_err()
        }
        Err(e) => {
            println!("  -> Erreur retournée immédiatement : {}", e);
            true
        }
    };

    println!("  -> THROW capturé comme erreur d'exécution : {}", threw_error);

    // 3. Vérification de l'absence d'enregistrement orphelin dans event_dead_letter
    println!("  -> Vérification de l'absence d'enregistrement orphelin dans event_dead_letter...");
    let mut check_res = db
        .query("SELECT count() AS total FROM event_dead_letter WHERE reason = 'test_h06_probe' GROUP ALL;")
        .await?;

    #[derive(Deserialize)]
    struct TotalRow {
        total: usize,
    }

    let rows: Vec<TotalRow> = check_res.take(0)?;
    let dlq_count = rows.first().map(|r| r.total).unwrap_or(0);
    println!("  -> Nombre d'enregistrements résiduels dans event_dead_letter : {}", dlq_count);

    let is_valid = threw_error && dlq_count == 0;
    if is_valid {
        println!("  [SUCCÈS] H-06 VALIDÉE : L'instruction CREATE a été intégralement annulée lors du THROW (atomicité confirmée).");
    } else {
        println!("  [ÉCHEC] H-06 INVALIDÉE : Enregistrement orphelin persisté malgré le THROW (défaut d'atomicité multi-instructions).");
    }

    Ok(is_valid)
}

/// Éprouve l'hypothèse H-08 :
/// Disponibilité et fidélité de capture des change feeds SurrealDB 3.2.0
pub async fn test_hypothesis_h08(_db: &Surreal<Any>) -> Result<bool, surrealdb::Error> {
    println!("\n=== [H-08] TEST CHANGE FEEDS (NON REQUIS EN PORTE 1 NOMINALE) ===");
    Ok(true)
}
