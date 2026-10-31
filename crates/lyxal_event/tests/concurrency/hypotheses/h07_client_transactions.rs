//! Expérimentation et investigation approfondie de l'hypothèse H-07 (Transactions interactives)
//!
//! Objectif selon mandat CTO :
//! Étape 1 : Vérification de faisabilité de `BEGIN TRANSACTION` / `COMMIT TRANSACTION`
//!           sur plusieurs requêtes client distinctes (appels SDK multiples),
//!           à la fois sur moteur embarqué (`mem://`) et sur transport distant (`ws://`).
//! Étape 2 : Si faisable, expérimentation contrôlée de concurrence (100 répétitions).

use surrealdb::engine::any::Any;
use surrealdb::Surreal;
use serde::Deserialize;
use std::path::Path;
use crate::concurrency::harness::process_supervisor::ProcessSupervisor;

#[derive(Debug)]
pub struct FeasibilityResult {
    pub mem_single_call_txn: bool,
    pub mem_multi_query_txn: bool,
    pub ws_single_call_txn: Option<bool>,
    pub ws_multi_query_txn: Option<bool>,
    pub observation: String,
}

/// Étape 1 : Vérifie si une transaction peut être maintenue sur plusieurs requêtes client distinctes
pub async fn verify_h07_feasibility(db: &Surreal<Any>) -> Result<FeasibilityResult, surrealdb::Error> {
    println!("\n=== [H-07 ÉTAPE 1] VÉRIFICATION DE FAISABILITÉ DES TRANSACTIONS MULTI-REQUÊTES ===");

    // -------------------------------------------------------------
    // PARTIE 1 : Test sur Moteur Embarqué (mem://)
    // -------------------------------------------------------------
    println!("\n--- [PARTIE 1] Tests sur moteur embarqué (mem://) ---");

    // Test A : Bloc transactionnel dans un SEUL appel query("BEGIN ... CANCEL")
    println!("  -> Test A : Bloc BEGIN / CANCEL au sein d'un appel query unique...");
    let single_call_res = db
        .query("BEGIN TRANSACTION; CREATE h07_single_call:test CONTENT { val: 1 }; CANCEL TRANSACTION;")
        .await;

    let mut check_a = db.query("SELECT * FROM h07_single_call:test;").await?;
    #[derive(Deserialize)]
    struct Dummy {}
    let items_a: Vec<Dummy> = check_a.take(0).unwrap_or_default();
    let mem_single_call_supported = single_call_res.is_ok() && items_a.is_empty();
    println!("     Test A (appel unique) : Rollback effectif = {}", mem_single_call_supported);

    // Test B : Transaction interactive sur PLUSIEURS appels query distincts
    println!("  -> Test B : Transaction interactive sur appels SDK distincts...");
    let _ = db.query("BEGIN TRANSACTION;").await;
    let _ = db.query("CREATE h07_multi_query:test CONTENT { val: 2 };").await;
    let _ = db.query("CANCEL TRANSACTION;").await;

    let mut check_b = db.query("SELECT * FROM h07_multi_query:test;").await?;
    let items_b: Vec<Dummy> = check_b.take(0).unwrap_or_default();
    let mem_multi_query_supported = items_b.is_empty();
    println!("     Test B (appels multiples distincts) : Ligne persistée malgré CANCEL = {}", !mem_multi_query_supported);

    // -------------------------------------------------------------
    // PARTIE 2 : Test sur Transport WebSocket Distant (surreal.exe 3.2.0)
    // -------------------------------------------------------------
    println!("\n--- [PARTIE 2] Tests sur serveur WebSocket officiel (surreal.exe 3.2.0) ---");
    let surreal_bin = "C:\\Users\\HP\\Desktop\\Lyxal_OS\\surreal.exe";
    let (ws_single, ws_multi) = if Path::new(surreal_bin).exists() {
        let ws_port = 8001;
        let ws_endpoint = format!("ws://127.0.0.1:{}", ws_port);
        let supervisor = ProcessSupervisor::new(ws_endpoint.clone());

        // Démarrage du serveur isolé sur port 8001
        match std::process::Command::new(surreal_bin)
            .args([
                "start",
                "--bind",
                &format!("127.0.0.1:{}", ws_port),
                "--user",
                "root",
                "--pass",
                "root",
                "memory",
            ])
            .spawn()
        {
            Ok(mut child) => {
                println!("  -> Serveur SurrealDB 3.2.0 démarré sur port {} (PID : {})...", ws_port, child.id());
                tokio::time::sleep(std::time::Duration::from_millis(800)).await;

                let ws_test_res = async {
                    let ws_client = supervisor.connect_client("test_h07_ns", "test_h07_db").await?;

                    // Test WS Single-Call
                    println!("  -> Test WS A : Bloc BEGIN / CANCEL en appel unique...");
                    let ws_s_res = ws_client
                        .query("BEGIN TRANSACTION; CREATE h07_ws_single:test CONTENT { val: 1 }; CANCEL TRANSACTION;")
                        .await;
                    let mut ws_chk_a = ws_client.query("SELECT * FROM h07_ws_single:test;").await?;
                    let ws_items_a: Vec<Dummy> = ws_chk_a.take(0).unwrap_or_default();
                    let ws_s_ok = ws_s_res.is_ok() && ws_items_a.is_empty();
                    println!("     Test WS A : Rollback effectif = {}", ws_s_ok);

                    // Test WS Multi-Call
                    println!("  -> Test WS B : Transaction interactive sur appels WebSocket distincts...");
                    let _ = ws_client.query("BEGIN TRANSACTION;").await;
                    let _ = ws_client.query("CREATE h07_ws_multi:test CONTENT { val: 2 };").await;
                    let _ = ws_client.query("CANCEL TRANSACTION;").await;

                    let mut ws_chk_b = ws_client.query("SELECT * FROM h07_ws_multi:test;").await?;
                    let ws_items_b: Vec<Dummy> = ws_chk_b.take(0).unwrap_or_default();
                    let ws_m_ok = ws_items_b.is_empty();
                    println!("     Test WS B : Ligne persistée malgré CANCEL = {}", !ws_m_ok);

                    Ok::<(bool, bool), surrealdb::Error>((ws_s_ok, ws_m_ok))
                }.await;

                // Arrêt du serveur
                let _ = child.kill();

                match ws_test_res {
                    Ok((s, m)) => (Some(s), Some(m)),
                    Err(e) => {
                        println!("  [NOTE WS] Échec de connexion/requête WS : {}", e);
                        (None, None)
                    }
                }
            }
            Err(e) => {
                println!("  [NOTE WS] Impossible de lancer surreal.exe : {}", e);
                (None, None)
            }
        }
    } else {
        println!("  [NOTE WS] Binaire surreal.exe introuvable pour test distant.");
        (None, None)
    };

    let observation = format!(
        "Moteur mem:// [SingleCall: {}, MultiCall: {}] | WebSocket ws:// [SingleCall: {:?}, MultiCall: {:?}]",
        mem_single_call_supported, mem_multi_query_supported, ws_single, ws_multi
    );

    println!("\n  [BILAN OBSERVÉ] {}", observation);
    if !mem_multi_query_supported && ws_multi != Some(true) {
        println!("  [CONCLUSION ÉTAPE 1] Les transactions interactives multi-requêtes (Option C client-side) ne sont PAS prises en charge par SurrealDB 3.2.0 et le SDK Rust 2.6.5.");
        println!("  -> RÈGLE D'ARRÊT MANDAT CTO ACTIVÉE : Arrêt sans inventer de contournement.");
    }

    Ok(FeasibilityResult {
        mem_single_call_txn: mem_single_call_supported,
        mem_multi_query_txn: mem_multi_query_supported,
        ws_single_call_txn: ws_single,
        ws_multi_query_txn: ws_multi,
        observation,
    })
}

/// Étape 2 : Expérimentation contrôlée de concurrence si faisable
pub async fn run_h07_controlled_experiment(
    _db: &Surreal<Any>,
    _repetitions: usize,
) -> Result<bool, surrealdb::Error> {
    // Conditionné à l'étape 1
    Ok(false)
}
