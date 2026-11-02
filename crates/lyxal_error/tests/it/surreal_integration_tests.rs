//! Tests d'intégration contre un serveur SurrealDB 3.3.4 réel.
//!
//! Chaque test démarre un serveur `surreal` en mémoire, installe `lyxal_core` puis
//! `lyxal_error` depuis leurs manifestes, et appelle les fonctions publiques avec les
//! types Rust du crate (`*Params` en entrée, types de résultat en sortie) : le contrat
//! DTO ↔ SurrealQL est ainsi vérifié de bout en bout, `RecordId` et `Datetime` compris.

use lyxal_error::*;
use std::path::PathBuf;
use std::process::{Child, Command, Stdio};
use std::time::Duration;
use surrealdb::engine::any::{connect, Any};
use surrealdb::opt::auth::Root;
use surrealdb::Surreal;
use surrealdb_types::{Datetime, RecordId, SurrealValue};

/// Binaire `surreal` utilisé par les tests : `LYXAL_SURREAL_BIN`, à défaut `surreal` dans le `PATH`.
fn surreal_bin() -> String {
    std::env::var("LYXAL_SURREAL_BIN").unwrap_or_else(|_| "surreal".to_owned())
}

/// Serveur SurrealDB en mémoire, arrêté à la fin du test.
struct SurrealServer {
    child: Child,
}

impl Drop for SurrealServer {
    fn drop(&mut self) {
        let _ = self.child.kill();
        let _ = self.child.wait();
    }
}

fn free_port() -> u16 {
    std::net::TcpListener::bind("127.0.0.1:0")
        .and_then(|listener| listener.local_addr())
        .map(|addr| addr.port())
        .expect("port libre")
}

/// Exécute un script SurrealQL et échoue si une instruction est en erreur.
async fn run_script(db: &Surreal<Any>, label: &str, surql: &str) {
    db.query(surql)
        .await
        .unwrap_or_else(|e| panic!("{label} : {e}"))
        .check()
        .unwrap_or_else(|e| panic!("{label} : {e}"));
}

/// Installe les ressources de plusieurs manifestes, phase par phase : tous les schémas, puis
/// toutes les fonctions, puis toutes les définitions d'erreurs. Les définitions de
/// `lyxal_core` s'écrivent dans la table `error_definition` de `lyxal_error`.
async fn install_manifests(db: &Surreal<Any>, module_dirs: &[PathBuf]) {
    let manifests: Vec<(PathBuf, toml::Value)> = module_dirs
        .iter()
        .map(|dir| {
            let content = std::fs::read_to_string(dir.join("manifest.toml")).expect("manifest");
            (
                dir.clone(),
                toml::from_str(&content).expect("manifest TOML"),
            )
        })
        .collect();
    for key in ["schemas", "functions", "error_definitions"] {
        for (dir, manifest) in &manifests {
            let Some(files) = manifest
                .get("resources")
                .and_then(|r| r.get(key))
                .and_then(|v| v.as_array())
            else {
                continue;
            };
            let script: String = files
                .iter()
                .map(|f| {
                    let path = dir.join(f.as_str().expect("chemin"));
                    std::fs::read_to_string(&path)
                        .unwrap_or_else(|e| panic!("{} : {e}", path.display()))
                })
                .collect::<Vec<_>>()
                .join("\n");
            run_script(db, &format!("{} [{key}]", dir.display()), &script).await;
        }
    }
}

/// `lyxal_core` puis `lyxal_error`.
fn modules() -> Vec<PathBuf> {
    vec![crate_dir().join("../lyxal_core"), crate_dir()]
}

fn crate_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
}

/// Démarre un serveur, s'y connecte en `ws://` (authentification Root) et installe
/// `lyxal_core` puis `lyxal_error`.
async fn setup_db() -> (SurrealServer, Surreal<Any>) {
    let port = free_port();
    let child = Command::new(surreal_bin())
        .args([
            "start",
            "--bind",
            &format!("127.0.0.1:{port}"),
            "--user",
            "root",
            "--pass",
            "root",
            "memory",
        ])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .spawn()
        .expect("Impossible de lancer `surreal` (définir LYXAL_SURREAL_BIN ou l'ajouter au PATH)");
    let server = SurrealServer { child };

    let endpoint = format!("ws://127.0.0.1:{port}");
    let started = std::time::Instant::now();
    let db = loop {
        match connect(&endpoint).await {
            Ok(db) => break db,
            Err(e) if started.elapsed() > Duration::from_secs(30) => {
                panic!("SurrealDB injoignable sur {endpoint} : {e}")
            }
            Err(_) => tokio::time::sleep(Duration::from_millis(100)).await,
        }
    };
    db.signin(Root {
        username: "root".into(),
        password: "root".into(),
    })
    .await
    .expect("signin Root");
    db.use_ns("lyxal_test")
        .use_db("test_error")
        .await
        .expect("ns/db");

    install_manifests(&db, &modules()).await;
    (server, db)
}

/// Appelle `fn::<name>($params)` et renvoie le contrat `{ ok, data, error }` converti.
async fn call<T: SurrealValue, P: SurrealValue + 'static>(
    db: &Surreal<Any>,
    name: &'static str,
    params: P,
) -> Result<T, LyxalCallError> {
    let mut response = db
        .query(format!("RETURN fn::{name}($params);"))
        .bind(("params", params))
        .await
        .unwrap_or_else(|e| panic!("{name} : {e}"));
    let result: Option<LyxalResult<T>> =
        response.take(0).unwrap_or_else(|e| panic!("{name} : {e}"));
    result
        .expect("contrat { ok, data, error } attendu")
        .into_result(name)
}

/// Exécute une requête SurrealQL et renvoie le contrat converti (entrées hors DTO).
async fn call_raw<T: SurrealValue>(db: &Surreal<Any>, surql: &str) -> Result<T, LyxalCallError> {
    let mut response = db.query(surql).await.expect("requête");
    let result: Option<LyxalResult<T>> = response.take(0).expect("lecture du contrat");
    result
        .expect("contrat { ok, data, error } attendu")
        .into_result("raw")
}

/// Code et détails d'une erreur métier.
fn business(err: LyxalCallError) -> LyxalError {
    match err {
        LyxalCallError::Business(e) => e,
        other => panic!("erreur métier attendue, obtenu {other:?}"),
    }
}

async fn count_where(db: &Surreal<Any>, table: &str, condition: &str) -> i64 {
    let mut response = db
        .query(format!(
            "RETURN count(SELECT * FROM {table} WHERE {condition});"
        ))
        .await
        .expect("count");
    response.take::<Option<i64>>(0).expect("count").unwrap_or(0)
}

async fn count(db: &Surreal<Any>, table: &str) -> i64 {
    let mut response = db
        .query(format!("RETURN count(SELECT * FROM {table});"))
        .await
        .expect("count");
    response.take::<Option<i64>>(0).expect("count").unwrap_or(0)
}

#[tokio::test]
async fn test_surreal_bootstrap_idempotence() {
    let (_server, db) = setup_db().await;

    // 8 définitions de lyxal_error + 3 définitions CORE_* de lyxal_core
    assert_eq!(count(&db, "error_definition").await, 11);
    assert_eq!(
        count_where(&db, "error_definition", "module = 'core'").await,
        3
    );
    assert_eq!(count(&db, "error_external_mapping").await, 0);

    // Le rejeu des définitions ne crée ni doublon ni erreur
    install_manifests(&db, &modules()).await;
    assert_eq!(count(&db, "error_definition").await, 11);
}

#[tokio::test]
async fn test_surreal_result_ok_and_error_result() {
    let (_server, db) = setup_db().await;

    let ok: String = call_raw(&db, "RETURN fn::result_ok('payload');")
        .await
        .unwrap();
    assert_eq!(ok, "payload");

    let err = business(
        call_raw::<serde_json::Value>(
            &db,
            "RETURN fn::error_result('ERROR_INVALID_INPUT', 'fr', { fields: { code: ['required'] } });",
        )
        .await
        .unwrap_err(),
    );
    assert_eq!(err.code, "ERROR_INVALID_INPUT");
    assert_eq!(err.http_status, Some(400));
    assert_eq!(err.category, "validation");
    assert!(err.details["fields"]["code"].is_array());

    // Code inconnu : erreur interne générique, code d'origine conservé
    let unknown = business(
        call_raw::<serde_json::Value>(
            &db,
            "RETURN fn::error_result('UNKNOWN_CODE_12345', 'fr', {});",
        )
        .await
        .unwrap_err(),
    );
    assert_eq!(unknown.code, "UNKNOWN_CODE_12345");
    assert_eq!(unknown.http_status, Some(500));
    assert_eq!(unknown.category, "internal");
}

#[tokio::test]
async fn test_surreal_error_definition_lifecycle() {
    let (_server, db) = setup_db().await;

    // Création
    let created: ErrorDefinition = call(
        &db,
        "error_definition_create",
        ErrorDefinitionCreateParams {
            code: "TEST_CUSTOM_ERR".into(),
            module: "test".into(),
            message: "A custom test error occurred".into(),
            category: Some("business".into()),
            severity: Some("warning".into()),
            http_status: Some(422),
            retryable: Some(true),
            log_occurrence: Some(false),
            translations: Some(serde_json::json!({
                "fr": { "label": "Erreur de test" },
                "en": { "label": "Test error" }
            })),
            metadata: Some(serde_json::json!({ "tag": "it" })),
            ..Default::default()
        },
    )
    .await
    .unwrap();
    assert_eq!(
        created.id,
        RecordId::new("error_definition", "TEST_CUSTOM_ERR")
    );
    assert_eq!(created.module, "test");
    assert_eq!(created.http_status, Some(422));
    assert!(created.retryable);
    assert!(!created.log_occurrence);
    assert_eq!(created.metadata["tag"], "it");
    assert_eq!(created.documentation, serde_json::json!({}));

    // Doublon
    let dup = business(
        call::<ErrorDefinition, _>(
            &db,
            "error_definition_create",
            ErrorDefinitionCreateParams {
                code: "TEST_CUSTOM_ERR".into(),
                module: "test".into(),
                message: "Doublon".into(),
                ..Default::default()
            },
        )
        .await
        .unwrap_err(),
    );
    assert_eq!(dup.code, "ERROR_DEFINITION_ALREADY_EXISTS");

    // Préfixe du code différent du module
    let prefix = business(
        call::<ErrorDefinition, _>(
            &db,
            "error_definition_create",
            ErrorDefinitionCreateParams {
                code: "OTHER_ERR".into(),
                module: "test".into(),
                message: "Mauvais préfixe".into(),
                ..Default::default()
            },
        )
        .await
        .unwrap_err(),
    );
    assert_eq!(prefix.code, "ERROR_DEFINITION_CODE_PREFIX_MISMATCH");

    // Entrée invalide : rapport par champ de lyxal_core
    let invalid = business(
        call::<ErrorDefinition, _>(
            &db,
            "error_definition_create",
            ErrorDefinitionCreateParams {
                code: "bad code".into(),
                module: "test".into(),
                message: "m".into(),
                category: Some("inconnue".into()),
                ..Default::default()
            },
        )
        .await
        .unwrap_err(),
    );
    assert_eq!(invalid.code, "ERROR_INVALID_INPUT");
    assert!(invalid.details["fields"].get("code").is_some());
    assert!(invalid.details["fields"].get("category").is_some());

    // Champ inconnu (ancien alias) refusé
    let alias = business(
        call_raw::<serde_json::Value>(
            &db,
            "RETURN fn::error_definition_get({ code_or_id: 'TEST_CUSTOM_ERR' });",
        )
        .await
        .unwrap_err(),
    );
    assert_eq!(alias.code, "ERROR_INVALID_INPUT");

    // Lecture
    let got: ErrorDefinition = call(
        &db,
        "error_definition_get",
        ErrorDefinitionGetParams {
            code: "TEST_CUSTOM_ERR".into(),
            language: None,
        },
    )
    .await
    .unwrap();
    assert_eq!(got.code, "TEST_CUSTOM_ERR");

    let missing = business(
        call::<ErrorDefinition, _>(
            &db,
            "error_definition_get",
            ErrorDefinitionGetParams {
                code: "TEST_INEXISTENT".into(),
                language: Some("en".into()),
            },
        )
        .await
        .unwrap_err(),
    );
    assert_eq!(missing.code, "ERROR_DEFINITION_NOT_FOUND");

    // Mise à jour partielle : les champs non fournis sont conservés
    let updated: ErrorDefinition = call(
        &db,
        "error_definition_update",
        ErrorDefinitionUpdateParams {
            code: "TEST_CUSTOM_ERR".into(),
            severity: Some("error".into()),
            http_status: Some(400),
            retryable: Some(false),
            ..Default::default()
        },
    )
    .await
    .unwrap();
    assert_eq!(updated.severity, "error");
    assert_eq!(updated.http_status, Some(400));
    assert!(!updated.retryable);
    assert_eq!(updated.message, "A custom test error occurred");
    assert_eq!(updated.metadata["tag"], "it");

    // Liste filtrée
    let listed: Vec<ErrorDefinition> = call(
        &db,
        "error_definition_list",
        ErrorDefinitionListParams {
            module: Some("test".into()),
            ..Default::default()
        },
    )
    .await
    .unwrap();
    assert_eq!(listed.len(), 1);
    assert_eq!(listed[0].code, "TEST_CUSTOM_ERR");

    let paged: Vec<ErrorDefinition> = call(
        &db,
        "error_definition_list",
        ErrorDefinitionListParams {
            limit: Some(2),
            start: Some(1),
            ..Default::default()
        },
    )
    .await
    .unwrap();
    assert_eq!(paged.len(), 2);

    // Désactivation logique
    let disabled: DisableResult = call(
        &db,
        "error_definition_disable",
        ErrorDefinitionDisableParams {
            code: "TEST_CUSTOM_ERR".into(),
            language: None,
        },
    )
    .await
    .unwrap();
    assert!(disabled.disabled);
    assert_eq!(disabled.id, created.id);

    let active: Vec<ErrorDefinition> = call(
        &db,
        "error_definition_list",
        ErrorDefinitionListParams {
            module: Some("test".into()),
            ..Default::default()
        },
    )
    .await
    .unwrap();
    assert!(active.is_empty());

    let all: Vec<ErrorDefinition> = call(
        &db,
        "error_definition_list",
        ErrorDefinitionListParams {
            module: Some("test".into()),
            enabled_only: Some(false),
            ..Default::default()
        },
    )
    .await
    .unwrap();
    assert_eq!(all.len(), 1);
    assert!(!all[0].enabled);
}

#[tokio::test]
async fn test_surreal_error_mapping_and_external_resolution() {
    let (_server, db) = setup_db().await;

    // Création
    let mapping: ErrorMapping = call(
        &db,
        "error_mapping_create",
        ErrorMappingCreateParams {
            provider: "stripe".into(),
            external_code: "card_".into(),
            definition_code: "ERROR_INVALID_INPUT".into(),
            service: Some("checkout".into()),
            matcher: Some("prefix".into()),
            priority: Some(10),
            description: Some("Paiement refusé".into()),
            ..Default::default()
        },
    )
    .await
    .unwrap();
    assert_eq!(mapping.matcher, "prefix");
    assert_eq!(
        mapping.definition,
        RecordId::new("error_definition", "ERROR_INVALID_INPUT")
    );
    assert_eq!(mapping.priority, 10);

    // Doublon, définition inconnue, matcher `regex` supprimé
    let dup = business(
        call::<ErrorMapping, _>(
            &db,
            "error_mapping_create",
            ErrorMappingCreateParams {
                provider: "stripe".into(),
                external_code: "card_".into(),
                definition_code: "ERROR_INVALID_INPUT".into(),
                service: Some("checkout".into()),
                matcher: Some("prefix".into()),
                ..Default::default()
            },
        )
        .await
        .unwrap_err(),
    );
    assert_eq!(dup.code, "ERROR_MAPPING_ALREADY_EXISTS");

    let unknown_def = business(
        call::<ErrorMapping, _>(
            &db,
            "error_mapping_create",
            ErrorMappingCreateParams {
                provider: "stripe".into(),
                external_code: "x".into(),
                definition_code: "TEST_INEXISTENT".into(),
                ..Default::default()
            },
        )
        .await
        .unwrap_err(),
    );
    assert_eq!(unknown_def.code, "ERROR_DEFINITION_NOT_FOUND");

    let regex = business(
        call::<ErrorMapping, _>(
            &db,
            "error_mapping_create",
            ErrorMappingCreateParams {
                provider: "stripe".into(),
                external_code: "^card".into(),
                definition_code: "ERROR_INVALID_INPUT".into(),
                matcher: Some("regex".into()),
                ..Default::default()
            },
        )
        .await
        .unwrap_err(),
    );
    assert_eq!(regex.code, "ERROR_INVALID_INPUT");

    // Résolution d'une erreur externe
    let matched: Option<ErrorExternalMatch> = call(
        &db,
        "error_map_external",
        ErrorMapExternalParams {
            provider: "stripe".into(),
            external_code: "card_declined".into(),
            service: Some("checkout".into()),
            ..Default::default()
        },
    )
    .await
    .unwrap();
    let matched = matched.expect("correspondance attendue");
    assert_eq!(matched.mapping, mapping.id);
    assert_eq!(matched.definition_code, "ERROR_INVALID_INPUT");

    let none: Option<ErrorExternalMatch> = call(
        &db,
        "error_map_external",
        ErrorMapExternalParams {
            provider: "stripe".into(),
            external_code: "insufficient_funds".into(),
            ..Default::default()
        },
    )
    .await
    .unwrap();
    assert!(none.is_none());

    // Lecture, identifiant d'une autre table, identifiant inconnu
    let got: ErrorMapping = call(
        &db,
        "error_mapping_get",
        ErrorMappingGetParams {
            mapping_id: mapping.id.clone(),
            language: None,
        },
    )
    .await
    .unwrap();
    assert_eq!(got.provider, "stripe");

    let wrong_table = business(
        call::<ErrorMapping, _>(
            &db,
            "error_mapping_get",
            ErrorMappingGetParams {
                mapping_id: RecordId::new("error_definition", "ERROR_INVALID_INPUT"),
                language: None,
            },
        )
        .await
        .unwrap_err(),
    );
    assert_eq!(wrong_table.code, "ERROR_INVALID_INPUT");

    let not_found = business(
        call::<ErrorMapping, _>(
            &db,
            "error_mapping_get",
            ErrorMappingGetParams {
                mapping_id: RecordId::new("error_external_mapping", "inexistant"),
                language: None,
            },
        )
        .await
        .unwrap_err(),
    );
    assert_eq!(not_found.code, "ERROR_MAPPING_NOT_FOUND");

    // Mise à jour partielle
    let updated: ErrorMapping = call(
        &db,
        "error_mapping_update",
        ErrorMappingUpdateParams {
            mapping_id: mapping.id.clone(),
            service: None,
            matcher: None,
            definition_code: Some("ERROR_MAPPING_NOT_FOUND".into()),
            priority: Some(5),
            external_http_status: Some(402),
            description: None,
            retryable_override: Some(false),
            enabled: None,
            metadata: None,
            language: None,
        },
    )
    .await
    .unwrap();
    assert_eq!(updated.priority, 5);
    assert_eq!(
        updated.definition,
        RecordId::new("error_definition", "ERROR_MAPPING_NOT_FOUND")
    );
    assert_eq!(updated.external_http_status, Some(402));
    assert_eq!(updated.retryable_override, Some(false));
    assert_eq!(updated.description.as_deref(), Some("Paiement refusé"));

    // Liste et désactivation
    let listed: Vec<ErrorMapping> = call(
        &db,
        "error_mapping_list",
        ErrorMappingListParams {
            provider: Some("stripe".into()),
            ..Default::default()
        },
    )
    .await
    .unwrap();
    assert_eq!(listed.len(), 1);

    let disabled: DisableResult = call(
        &db,
        "error_mapping_disable",
        ErrorMappingDisableParams {
            mapping_id: mapping.id.clone(),
            language: None,
        },
    )
    .await
    .unwrap();
    assert!(disabled.disabled);
    assert_eq!(disabled.id, mapping.id);

    let after: Option<ErrorExternalMatch> = call(
        &db,
        "error_map_external",
        ErrorMapExternalParams {
            provider: "stripe".into(),
            external_code: "card_declined".into(),
            ..Default::default()
        },
    )
    .await
    .unwrap();
    assert!(after.is_none(), "une correspondance désactivée est ignorée");
}

#[tokio::test]
async fn test_surreal_error_occurrence_logging_and_purging() {
    let (_server, db) = setup_db().await;

    // Journalisation avec une source typée
    let source = RecordId::new("booking", "b1");
    let logged: Option<ErrorOccurrence> = call(
        &db,
        "error_log",
        ErrorLogParams {
            code: "ERROR_INVALID_INPUT".into(),
            source_module: "test_integration".into(),
            operation: Some("user_signup".into()),
            source: Some(source.clone()),
            technical_message: Some("email manquant".into()),
            environment: Some("test".into()),
            ..Default::default()
        },
    )
    .await
    .unwrap();
    let occurrence = logged.expect("occurrence journalisée");
    assert_eq!(occurrence.code, "ERROR_INVALID_INPUT");
    assert_eq!(occurrence.source, Some(source));
    assert_eq!(
        occurrence.definition,
        Some(RecordId::new("error_definition", "ERROR_INVALID_INPUT"))
    );
    assert_eq!(occurrence.environment, "test");

    // Lecture et identifiant inconnu
    let got: ErrorOccurrence = call(
        &db,
        "error_occurrence_get",
        ErrorOccurrenceGetParams {
            occurrence_id: occurrence.id.clone(),
            language: None,
        },
    )
    .await
    .unwrap();
    assert_eq!(got.operation.as_deref(), Some("user_signup"));

    let not_found = business(
        call::<ErrorOccurrence, _>(
            &db,
            "error_occurrence_get",
            ErrorOccurrenceGetParams {
                occurrence_id: RecordId::new("error_occurrence", "inexistant"),
                language: None,
            },
        )
        .await
        .unwrap_err(),
    );
    assert_eq!(not_found.code, "ERROR_OCCURRENCE_NOT_FOUND");

    // Liste
    let listed: Vec<ErrorOccurrence> = call(
        &db,
        "error_occurrence_list",
        ErrorOccurrenceListParams {
            source_module: Some("test_integration".into()),
            ..Default::default()
        },
    )
    .await
    .unwrap();
    assert_eq!(listed.len(), 1);

    // Une date sous forme de chaîne est refusée
    let string_date = business(
        call_raw::<PurgeResult>(
            &db,
            "RETURN fn::error_occurrence_purge_before({ before_date: '2099-01-01T00:00:00Z' });",
        )
        .await
        .unwrap_err(),
    );
    assert_eq!(string_date.code, "ERROR_INVALID_INPUT");

    // Purge
    let before: Datetime = "2099-01-01T00:00:00Z".parse().expect("date");
    let purged: PurgeResult = call(
        &db,
        "error_occurrence_purge_before",
        ErrorOccurrencePurgeParams {
            before_date: before,
            language: None,
        },
    )
    .await
    .unwrap();
    assert_eq!(purged.count, 1);
    assert_eq!(purged.before, before);
    assert_eq!(count(&db, "error_occurrence").await, 0);
}
