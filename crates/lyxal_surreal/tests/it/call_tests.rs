use async_trait::async_trait;
use lyxal_surreal::{
    create_surreal_client, LyxalCallError, LyxalSurrealCall, LyxalSurrealError, RootCredentials,
    SecretString, SurrealConnectOptions,
};
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::types::SurrealValue;
use surrealdb::Surreal;

/// Store de test implémentant le trait officiel `LyxalSurrealCall`
struct TestStore {
    db: Surreal<Any>,
}

#[async_trait]
impl LyxalSurrealCall for TestStore {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.db
    }
}

/// Options de connexion de test (namespace `lyxal_test`).
fn opts(
    endpoint: &str,
    credentials: Option<RootCredentials>,
    database: &str,
) -> SurrealConnectOptions {
    SurrealConnectOptions {
        endpoint: endpoint.to_owned(),
        credentials,
        namespace: "lyxal_test".to_owned(),
        database: database.to_owned(),
        connect_timeout: Duration::from_secs(10),
    }
}

fn secret(text: &str) -> SecretString {
    SecretString::new(text.to_owned()).expect("secret")
}

#[derive(SurrealValue)]
struct AddParams {
    a: i64,
    b: i64,
}

#[derive(SurrealValue)]
struct EmptyParams {}

#[tokio::test]
async fn test_create_surreal_client_mem_lifecycle() {
    let client = create_surreal_client(opts("mem://", None, "test_db"))
        .await
        .expect("Connection to mem:// without Root credentials must succeed");

    let mut res = client
        .query("RETURN 42;")
        .await
        .expect("Execute basic query");
    let val: Option<i64> = res.take(0).expect("Take result");
    assert_eq!(val, Some(42));
}

#[tokio::test]
async fn test_create_surreal_client_rejects_unsupported_protocol() {
    let res = create_surreal_client(opts("http://127.0.0.1:8000", None, "test_db")).await;
    match res {
        Err(LyxalSurrealError::UnsupportedEndpoint { endpoint }) => {
            assert_eq!(endpoint, "http://127.0.0.1:8000");
        }
        _ => panic!("Expected UnsupportedEndpoint error, got {:?}", res),
    }
}

#[tokio::test]
async fn test_create_surreal_client_rejects_missing_credentials_on_remote() {
    let res = create_surreal_client(opts("ws://127.0.0.1:8000", None, "test_db")).await;
    match res {
        Err(LyxalSurrealError::MissingCredentials { endpoint }) => {
            assert_eq!(endpoint, "ws://127.0.0.1:8000");
        }
        _ => panic!("Expected MissingCredentials error, got {:?}", res),
    }

    let empty_creds = Some(RootCredentials::new("", secret("")));
    let res_empty =
        create_surreal_client(opts("ws://127.0.0.1:8000", empty_creds, "test_db")).await;
    assert!(matches!(
        res_empty,
        Err(LyxalSurrealError::MissingCredentials { .. })
    ));
}

#[tokio::test]
async fn test_call_fn_nominal_success() {
    let client = create_surreal_client(opts("mem://", None, "test_db"))
        .await
        .expect("Connect mem://");

    // Déclaration d'une fonction respectant le contrat universel { ok: true, data: ..., error: NONE }
    client
        .query(
            r#"
            DEFINE FUNCTION OVERWRITE fn::test_add($params: object) {
                RETURN {
                    ok: true,
                    data: $params.a + $params.b,
                    error: NONE
                };
            };
            "#,
        )
        .await
        .expect("Define test_add function");

    let store = TestStore { db: client };
    let sum: i64 = store
        .call_fn("test_add", AddParams { a: 15, b: 27 })
        .await
        .expect("call_fn should succeed and return sum");

    assert_eq!(sum, 42);
}

#[tokio::test]
async fn test_call_fn_business_error_propagation() {
    let client = create_surreal_client(opts("mem://", None, "test_db"))
        .await
        .expect("Connect mem://");

    // Déclaration d'une fonction simulant une erreur métier canonique
    client
        .query(
            r#"
            DEFINE FUNCTION OVERWRITE fn::test_business_error($params: object) {
                RETURN {
                    ok: false,
                    data: NONE,
                    error: {
                        code: "BOOKING_SLOT_UNAVAILABLE",
                        message: "The requested slot is already booked",
                        label: "Créneau non disponible",
                        description: "Le créneau demandé a déjà été réservé.",
                        resolution: "Veuillez sélectionner un autre créneau.",
                        category: "business",
                        severity: "warning",
                        http_status: 409,
                        retryable: false,
                        documentation: {},
                        metadata: {},
                        details: { slot_id: "slot_123" }
                    }
                };
            };
            "#,
        )
        .await
        .expect("Define test_business_error function");

    let store = TestStore { db: client };
    let res: Result<String, LyxalSurrealError> =
        store.call_fn("test_business_error", EmptyParams {}).await;

    assert!(res.is_err(), "Expected error from call_fn");
    let err = res.unwrap_err();

    // Vérification de la propagation typée et du helper is_business_code
    assert!(err.is_business_code("BOOKING_SLOT_UNAVAILABLE"));
    assert!(!err.is_business_code("OTHER_CODE"));

    match &err {
        LyxalSurrealError::Call(LyxalCallError::Business(be)) => {
            assert_eq!(be.code, "BOOKING_SLOT_UNAVAILABLE");
            assert_eq!(be.http_status, Some(409));
            assert_eq!(be.category, "business");
            assert_eq!(be.details["slot_id"], "slot_123");
        }
        _ => panic!("Expected Call(Business) variant, got {:?}", err),
    }
}

#[tokio::test]
async fn test_call_fn_invalid_contract_rejection() {
    let client = create_surreal_client(opts("mem://", None, "test_db"))
        .await
        .expect("Connect mem://");

    // Fonction retournant une violation du contrat tripartite Lyxal (ok=true ET error présent)
    client
        .query(
            r#"
            DEFINE FUNCTION OVERWRITE fn::test_bad_contract($params: object) {
                RETURN {
                    ok: true,
                    data: "incoherent",
                    error: {
                        code: "TEST_INCOHERENT",
                        message: "Invalid state",
                        label: "État contractuel incohérent",
                        category: "internal",
                        severity: "error",
                        retryable: false
                    }
                };
            };

            DEFINE FUNCTION OVERWRITE fn::test_none_contract($params: object) {
                RETURN NONE;
            };
            "#,
        )
        .await
        .expect("Define invalid contract functions");

    let store = TestStore { db: client };

    // Cas 1 : ok=true avec error présent -> InvalidContract
    let res: Result<String, LyxalSurrealError> =
        store.call_fn("test_bad_contract", EmptyParams {}).await;
    assert!(res.is_err());
    match res.unwrap_err() {
        LyxalSurrealError::Call(LyxalCallError::InvalidContract { function }) => {
            assert_eq!(function, "test_bad_contract");
        }
        err => panic!("Expected InvalidContract error, got {:?}", err),
    }

    // Cas 2 : retour NONE -> InvalidContract
    let res_none: Result<String, LyxalSurrealError> =
        store.call_fn("test_none_contract", EmptyParams {}).await;
    assert!(res_none.is_err());
    match res_none.unwrap_err() {
        LyxalSurrealError::Call(LyxalCallError::InvalidContract { function }) => {
            assert_eq!(function, "test_none_contract");
        }
        err => panic!(
            "Expected InvalidContract error for NONE return, got {:?}",
            err
        ),
    }
}

#[tokio::test]
async fn test_call_fn_sql_injection_rejection() {
    let client = create_surreal_client(opts("mem://", None, "test_db"))
        .await
        .expect("Connect mem://");
    let store = TestStore { db: client };

    // Tentatives d'injection SQL ou de nom de fonction illégal
    let injections = [
        "booking;DROP TABLE account;",
        "booking--comment",
        "fn::nested::call",
        "UPPERCASE_NOT_ALLOWED",
        "with spaces",
        "",
    ];

    for bad_name in injections {
        let res: Result<String, LyxalSurrealError> = store.call_fn(bad_name, EmptyParams {}).await;
        match res {
            Err(LyxalSurrealError::InvalidFunctionName { function }) => {
                assert_eq!(function, bad_name);
            }
            _ => panic!(
                "Expected InvalidFunctionName for '{}', got {:?}",
                bad_name, res
            ),
        }
    }
}

#[derive(SurrealValue)]
struct ThrowParams {
    message: String,
}

/// Un code de module levé par `THROW` (seul ou suivi d'un texte) devient l'erreur métier
/// résolue par `fn::error_result` ; un texte libre levé reste une erreur de base.
#[tokio::test]
async fn test_call_fn_resolves_thrown_module_codes() {
    let db = create_surreal_client(opts("mem://", None, "test_thrown"))
        .await
        .expect("Connect mem://");
    let crate_dir = std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let error_dir = crate_dir.join("../lyxal_error");
    install_resource(&db, &error_dir, "schemas").await;
    install_resource(&db, &error_dir, "functions").await;
    install_resource(&db, &crate_dir, "error_definitions").await;
    db.query(
        r#"DEFINE FUNCTION OVERWRITE fn::test_throw($params: object) {
            THROW $params.message;
        };"#,
    )
    .await
    .and_then(|r| r.check())
    .expect("Define test_throw function");
    let store = TestStore { db };

    for message in ["SURREAL_CONNECT_TIMEOUT", "SURREAL_CONNECT_TIMEOUT: annulé"] {
        let err = store
            .call_fn::<i64, _>(
                "test_throw",
                ThrowParams {
                    message: message.into(),
                },
            )
            .await
            .expect_err("erreur levée");
        match &err {
            LyxalSurrealError::Call(LyxalCallError::Business(be)) => {
                assert_eq!(be.code, "SURREAL_CONNECT_TIMEOUT", "{message}");
                assert_eq!(be.http_status, Some(503));
                assert_eq!(be.label, "Délai de connexion à la base de données dépassé");
            }
            other => panic!("{message} : erreur métier attendue, obtenu {other:?}"),
        }
    }

    // Code de module sans définition : erreur métier interne portant le code
    let unknown = store
        .call_fn::<i64, _>(
            "test_throw",
            ThrowParams {
                message: "TEST_UNDEFINED_CODE".into(),
            },
        )
        .await
        .expect_err("erreur levée");
    assert!(
        unknown.is_business_code("TEST_UNDEFINED_CODE"),
        "{unknown:?}"
    );

    // Texte libre : erreur de base inchangée
    let free = store
        .call_fn::<i64, _>(
            "test_throw",
            ThrowParams {
                message: "quelque chose a échoué".into(),
            },
        )
        .await
        .expect_err("erreur levée");
    assert!(matches!(free, LyxalSurrealError::Database(_)), "{free:?}");
}

/// Exécute les fichiers d'une ressource d'un manifeste.
async fn install_resource(db: &Surreal<Any>, module_dir: &std::path::Path, key: &str) {
    let manifest: toml::Value = toml::from_str(
        &std::fs::read_to_string(module_dir.join("manifest.toml")).expect("manifest"),
    )
    .expect("manifest TOML");
    let files = manifest["resources"]
        .get(key)
        .and_then(|v| v.as_array())
        .cloned()
        .unwrap_or_default();
    for file in files {
        let path = module_dir.join(file.as_str().expect("chemin"));
        let surql = std::fs::read_to_string(&path).expect("fichier");
        db.query(surql)
            .await
            .and_then(|r| r.check())
            .unwrap_or_else(|e| panic!("{} : {e}", path.display()));
    }
}

/// Les définitions `SURREAL_*` s'installent dans la table `error_definition` de `lyxal_error`,
/// sans doublon au rejeu, et se résolvent par `fn::error_resolve`.
#[tokio::test]
async fn test_surreal_error_definitions_install_and_resolve() {
    let db = create_surreal_client(opts("mem://", None, "test_definitions"))
        .await
        .expect("Connect mem://");
    let crate_dir = std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let error_dir = crate_dir.join("../lyxal_error");
    install_resource(&db, &error_dir, "schemas").await;
    install_resource(&db, &error_dir, "functions").await;
    install_resource(&db, &crate_dir, "error_definitions").await;
    install_resource(&db, &crate_dir, "error_definitions").await;

    let mut res = db
        .query("RETURN (SELECT VALUE code FROM error_definition WHERE module = 'surreal' ORDER BY code);")
        .await
        .expect("requête");
    let codes: Vec<String> = res.take(0).expect("codes");
    assert_eq!(
        codes,
        [
            "SURREAL_CONNECT_TIMEOUT",
            "SURREAL_DATABASE_ERROR",
            "SURREAL_INVALID_FUNCTION_NAME",
            "SURREAL_MISSING_CREDENTIALS",
            "SURREAL_UNSUPPORTED_ENDPOINT",
        ]
    );

    let mut res = db
        .query("RETURN fn::error_resolve('SURREAL_CONNECT_TIMEOUT', 'fr', {});")
        .await
        .expect("résolution");
    let resolved: Option<serde_json::Value> = res
        .take::<Option<surrealdb::types::Value>>(0)
        .expect("lecture")
        .map(|v| v.into_json_value());
    let resolved = resolved.expect("erreur résolue");
    assert_eq!(resolved["code"], "SURREAL_CONNECT_TIMEOUT");
    assert_eq!(resolved["http_status"], 503);
    assert_eq!(resolved["retryable"], true);
    assert_eq!(
        resolved["label"],
        "Délai de connexion à la base de données dépassé"
    );
}

/// Connexion distante réelle (`ws://` + authentification Root) et appel `call_fn` de bout en bout.
///
/// Lancer un serveur, par exemple `surreal start --user root --pass root memory`, puis :
/// `LYXAL_SURREAL_WS_URL=ws://127.0.0.1:8000 cargo test -p lyxal_surreal -- --ignored`.
/// Identifiants : `LYXAL_SURREAL_USER` / `LYXAL_SURREAL_PASS` (défaut `root` / `root`).
#[tokio::test]
#[ignore = "nécessite un serveur SurrealDB distant (LYXAL_SURREAL_WS_URL)"]
async fn test_remote_ws_root_signin_and_call_fn() {
    let url = std::env::var("LYXAL_SURREAL_WS_URL").expect("LYXAL_SURREAL_WS_URL doit être défini");
    let user = std::env::var("LYXAL_SURREAL_USER").unwrap_or_else(|_| "root".to_owned());
    let pass = std::env::var("LYXAL_SURREAL_PASS").unwrap_or_else(|_| "root".to_owned());

    let creds = RootCredentials::new(user, secret(&pass));
    let db = create_surreal_client(opts(&url, Some(creds), "test_remote"))
        .await
        .expect("Connexion ws:// avec authentification Root");

    db.query(
        "DEFINE FUNCTION OVERWRITE fn::test_remote_add($params: object) {
            RETURN { ok: true, data: $params.a + $params.b, error: NONE };
        };",
    )
    .await
    .expect("Définition de la fonction de test");

    let store = TestStore { db };
    let sum: i64 = store
        .call_fn("test_remote_add", AddParams { a: 20, b: 22 })
        .await
        .expect("call_fn distant");
    assert_eq!(sum, 42);
}
