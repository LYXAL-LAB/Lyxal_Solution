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

#[cfg(feature = "axum")]
#[test]
fn test_axum_http_status_mapping() {
    use axum::http::StatusCode;
    use axum::response::IntoResponse;

    // 1. UnsupportedEndpoint -> 400
    let err = LyxalSurrealError::UnsupportedEndpoint {
        endpoint: "http://bad.endpoint".into(),
    };
    assert_eq!(err.into_response().status(), StatusCode::BAD_REQUEST);

    // 2. MissingCredentials -> 401
    let err = LyxalSurrealError::MissingCredentials {
        endpoint: "ws://remote.endpoint".into(),
    };
    assert_eq!(err.into_response().status(), StatusCode::UNAUTHORIZED);

    // 3. InvalidFunctionName -> 400
    let err = LyxalSurrealError::InvalidFunctionName { function: "bad;" };
    assert_eq!(err.into_response().status(), StatusCode::BAD_REQUEST);
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
