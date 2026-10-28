use lyxal_error::LyxalResult;
use serde::Deserialize;
use std::path::PathBuf;
use surrealdb::engine::local::Mem;
use surrealdb::Surreal;

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct DefinitionData {
    code: String,
    #[serde(default)]
    category: Option<String>,
    #[serde(default)]
    severity: Option<String>,
    #[serde(default)]
    http_status: Option<u16>,
    #[serde(default)]
    enabled: Option<bool>,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct DisableResult {
    disabled: bool,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct MappingData {
    provider: String,
    #[serde(default)]
    external_code: Option<String>,
    #[serde(default)]
    enabled: Option<bool>,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct OccurrenceData {
    code: String,
    source_module: String,
    #[serde(default)]
    operation: Option<String>,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct PurgeData {
    purged: bool,
    count: usize,
}

async fn setup_db() -> Surreal<surrealdb::engine::local::Db> {
    let db = Surreal::new::<Mem>(())
        .await
        .expect("Failed to initialize SurrealDB Mem engine");
    db.use_ns("lyxal_test")
        .use_db("test_error")
        .await
        .expect("Failed to select namespace/db");

    let manifest_path = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("manifest.toml");
    let content = std::fs::read_to_string(&manifest_path).expect("Read manifest.toml");
    let parsed: toml::Value = toml::from_str(&content).expect("Parse manifest.toml");
    let resources = parsed.get("resources").and_then(|v| v.as_table()).unwrap();

    let execute_resources = async |db: &Surreal<surrealdb::engine::local::Db>, key: &str| {
        let list = resources.get(key).and_then(|v| v.as_array()).unwrap();
        for item in list {
            let rel_path = item.as_str().unwrap();
            let full_path = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join(rel_path);
            let surql = std::fs::read_to_string(&full_path)
                .unwrap_or_else(|_| panic!("Failed to read {}", full_path.display()));

            let mut res = db
                .query(&surql)
                .await
                .unwrap_or_else(|e| panic!("Failed to execute {}: {:?}", rel_path, e));
            let errors = res.take_errors();
            if !errors.is_empty() {
                panic!("SurrealDB error in {}: {:?}", rel_path, errors);
            }
        }
    };

    execute_resources(&db, "schemas").await;
    execute_resources(&db, "migrations").await;
    execute_resources(&db, "functions").await;
    execute_resources(&db, "error_definitions").await;
    execute_resources(&db, "seeds").await;

    db
}

async fn query_lyxal_result<T: serde::de::DeserializeOwned>(
    db: &Surreal<surrealdb::engine::local::Db>,
    query: &str,
) -> LyxalResult<T> {
    let mut resp = db
        .query(query)
        .await
        .unwrap_or_else(|e| panic!("Query failed: {}\nError: {:?}", query, e));
    let raw: Option<LyxalResult<T>> = resp
        .take(0)
        .unwrap_or_else(|e| panic!("Take failed: {}\nError: {:?}", query, e));
    raw.unwrap_or_else(|| panic!("Empty response for query: {}", query))
}

#[tokio::test]
async fn test_surreal_bootstrap_and_migration_idempotence() {
    let db = setup_db().await;

    // Verify error definitions table has the canon codes
    let mut resp = db
        .query("SELECT VALUE code FROM error_definition WHERE code IN ['ERROR_PARAM_REQUIRED', 'ERROR_DEFINITION_NOT_FOUND']")
        .await
        .unwrap();
    let defs: Vec<String> = resp.take(0).unwrap();
    assert_eq!(defs.len(), 2, "Expected canonical error definitions");

    // Reapply migration
    let migration_path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("migrations/0001_initial_schema.surql");
    let migration_surql = std::fs::read_to_string(migration_path).unwrap();
    let mut mig_res = db.query(&migration_surql).await.unwrap();
    assert!(
        mig_res.take_errors().is_empty(),
        "Reapplying migration must succeed idempotently"
    );

    // Verify migration record exists in schema_migration
    let mut check_resp = db
        .query("SELECT VALUE status FROM schema_migration WHERE name = '0001_initial_schema'")
        .await
        .unwrap();
    let records: Vec<String> = check_resp.take(0).unwrap();
    assert_eq!(records.len(), 1);
    assert_eq!(records[0], "APPLIED");
}

#[tokio::test]
async fn test_surreal_primitives_result_ok_and_error_result() {
    let db = setup_db().await;

    // Test fn::result_ok
    let res: LyxalResult<String> = query_lyxal_result(&db, "RETURN fn::result_ok('success_payload');").await;
    assert!(res.ok);
    assert_eq!(res.into_result("test").unwrap(), "success_payload");

    // Test fn::error_result with known code and French translation
    let err_res: LyxalResult<serde_json::Value> = query_lyxal_result(
        &db,
        "RETURN fn::error_result('ERROR_PARAM_REQUIRED', 'fr', { field: 'username' });",
    )
    .await;
    assert!(!err_res.ok);
    let err = err_res.into_result("test").unwrap_err();
    match &err {
        lyxal_error::LyxalCallError::Business(be) => {
            assert_eq!(be.code, "ERROR_PARAM_REQUIRED");
            assert_eq!(be.http_status, Some(400));
            assert_eq!(be.category, "validation");
            assert_eq!(be.details["field"], "username");
            assert!(be.label.contains("obligatoire") || be.message.contains("obligatoire"));
        }
        _ => panic!("Expected Business error, got {:?}", err),
    }

    // Test fn::error_result with unknown code -> resolves with unknown code details
    let fallback_res: LyxalResult<serde_json::Value> = query_lyxal_result(
        &db,
        "RETURN fn::error_result('UNKNOWN_CODE_12345', 'fr', { context: 'test' });",
    )
    .await;
    assert!(!fallback_res.ok);
    let fallback_err = fallback_res.into_result("test").unwrap_err();
    match &fallback_err {
        lyxal_error::LyxalCallError::Business(be) => {
            assert_eq!(be.code, "UNKNOWN_CODE_12345");
            assert_eq!(be.http_status, Some(500));
            assert_eq!(be.category, "internal");
            assert!(be.label.contains("inconnue"));
        }
        _ => panic!("Expected Business fallback error, got {:?}", fallback_err),
    }
}

#[tokio::test]
async fn test_surreal_error_definition_lifecycle() {
    let db = setup_db().await;

    // 1. Creation with object params
    let create_res: LyxalResult<DefinitionData> = query_lyxal_result(
        &db,
        r#"
            RETURN fn::error_definition_create({
                code: "TEST_CUSTOM_ERR",
                module: "test",
                message: "A custom test error occurred",
                category: "business",
                severity: "warning",
                http_status: 422,
                retryable: false,
                translations: {
                    fr: { label: "Erreur personnalisée de test" },
                    en: { label: "Custom test error" }
                }
            });
        "#,
    )
    .await;
    assert!(create_res.ok);
    let created = create_res.into_result("create").unwrap();
    assert_eq!(created.code, "TEST_CUSTOM_ERR");

    // 2. Duplicate creation rejects
    let dup_res: LyxalResult<DefinitionData> = query_lyxal_result(
        &db,
        r#"
            RETURN fn::error_definition_create({
                code: "TEST_CUSTOM_ERR",
                module: "test",
                message: "Duplicate"
            });
        "#,
    )
    .await;
    assert!(!dup_res.ok);
    let dup_err = dup_res.into_result("create").unwrap_err();
    assert!(dup_err.is_business_code("ERROR_DEFINITION_ALREADY_EXISTS"));

    // 3. Get with string code
    let get_res: LyxalResult<DefinitionData> =
        query_lyxal_result(&db, "RETURN fn::error_definition_get('TEST_CUSTOM_ERR');").await;
    assert!(get_res.ok);
    assert_eq!(get_res.into_result("get").unwrap().code, "TEST_CUSTOM_ERR");

    // 4. Update
    let upd_res: LyxalResult<DefinitionData> = query_lyxal_result(
        &db,
        r#"
            RETURN fn::error_definition_update({
                code: "TEST_CUSTOM_ERR",
                severity: "error",
                http_status: 400
            });
        "#,
    )
    .await;
    assert!(upd_res.ok);
    let updated = upd_res.into_result("update").unwrap();
    assert_eq!(updated.severity.as_deref(), Some("error"));
    assert_eq!(updated.http_status, Some(400));

    // 5. List definitions before disable (must contain TEST_CUSTOM_ERR)
    let list_res: LyxalResult<Vec<DefinitionData>> = query_lyxal_result(
        &db,
        "RETURN fn::error_definition_list({ category: 'business' });",
    )
    .await;
    assert!(list_res.ok);
    let items = list_res.into_result("list").unwrap();
    assert!(items.iter().any(|i| i.code == "TEST_CUSTOM_ERR"));

    // 6. Disable definition
    let dis_res: LyxalResult<DisableResult> =
        query_lyxal_result(&db, "RETURN fn::error_definition_disable('TEST_CUSTOM_ERR');").await;
    assert!(dis_res.ok);
    assert!(dis_res.into_result("disable").unwrap().disabled);

    // 7. List definitions after disable (must be excluded from default enabled_only list)
    let list_after: LyxalResult<Vec<DefinitionData>> = query_lyxal_result(
        &db,
        "RETURN fn::error_definition_list({ category: 'business' });",
    )
    .await;
    assert!(list_after.ok);
    let items_after = list_after.into_result("list_after").unwrap();
    assert!(!items_after.iter().any(|i| i.code == "TEST_CUSTOM_ERR"));
}

#[tokio::test]
async fn test_surreal_error_mapping_and_resolution() {
    let db = setup_db().await;

    // 1. Create mapping
    let map_res: LyxalResult<MappingData> = query_lyxal_result(
        &db,
        r#"
            RETURN fn::error_mapping_create({
                provider: "stripe",
                external_code: "card_declined",
                matcher: "exact",
                definition_id: "error_definition:ERROR_PARAM_REQUIRED",
                priority: 10
            });
        "#,
    )
    .await;
    assert!(map_res.ok);
    let created = map_res.into_result("create_mapping").unwrap();
    assert_eq!(created.provider, "stripe");

    println!("Created mapping: {:?}", created);


    // 2. Resolve external mapping (exact match)
    let match_res: LyxalResult<Option<serde_json::Value>> = query_lyxal_result(
        &db,
        r#"
            RETURN fn::error_map_external({
                provider: "stripe",
                external_code: "card_declined"
            });
        "#,
    )
    .await;
    println!("match_res: {:?}", match_res);
    assert!(match_res.ok);
    let matched_opt = match_res.into_result("map_ext").unwrap();
    assert!(matched_opt.is_some());
    let matched = matched_opt.unwrap();
    assert_eq!(matched["provider"], "stripe");
    assert_eq!(matched["external_code"], "card_declined");

    // 3. Resolve unknown external code returns None without error
    let unknown_res: LyxalResult<Option<serde_json::Value>> = query_lyxal_result(
        &db,
        r#"
            RETURN fn::error_map_external({
                provider: "stripe",
                external_code: "unknown_weird_error_491823"
            });
        "#,
    )
    .await;
    assert!(unknown_res.ok);
    assert!(unknown_res.into_result("map_ext").unwrap().is_none());

    // 4. Missing required param provider returns ERROR_PARAM_REQUIRED
    let missing_res: LyxalResult<Option<serde_json::Value>> = query_lyxal_result(
        &db,
        r#"
            RETURN fn::error_map_external({
                external_code: "card_declined"
            });
        "#,
    )
    .await;
    assert!(!missing_res.ok);
    let missing_err = missing_res.into_result("map_ext").unwrap_err();
    assert!(missing_err.is_business_code("ERROR_PARAM_REQUIRED"));

    // 5. Disable mapping
    let dis_res: LyxalResult<DisableResult> = query_lyxal_result(
        &db,
        "RETURN fn::error_mapping_disable({ id: (SELECT VALUE id FROM error_external_mapping WHERE provider = 'stripe' LIMIT 1)[0] });",
    )
    .await;
    assert!(dis_res.ok);
    assert!(dis_res.into_result("disable_mapping").unwrap().disabled);
}

#[tokio::test]
async fn test_surreal_error_occurrence_logging_and_purging() {
    let db = setup_db().await;

    // 1. Log error occurrence via fn::error_log
    let log_res: LyxalResult<OccurrenceData> = query_lyxal_result(
        &db,
        r#"
            RETURN fn::error_log({
                code: "ERROR_PARAM_REQUIRED",
                source_module: "test_integration",
                operation: "user_signup",
                technical_message: "Validation field email missing",
                environment: "test"
            });
        "#,
    )
    .await;
    assert!(log_res.ok);
    let occ = log_res.into_result("log").unwrap();
    assert_eq!(occ.code, "ERROR_PARAM_REQUIRED");
    assert_eq!(occ.source_module, "test_integration");

    // 2. Retrieve occurrence by ID
    let get_res: LyxalResult<OccurrenceData> = query_lyxal_result(
        &db,
        "RETURN fn::error_occurrence_get({ id: (SELECT VALUE id FROM error_occurrence WHERE source_module = 'test_integration' LIMIT 1)[0] });",
    )
    .await;
    assert!(get_res.ok);
    assert_eq!(
        get_res.into_result("get_occ").unwrap().operation.as_deref(),
        Some("user_signup")
    );

    // 3. List occurrences
    let list_res: LyxalResult<Vec<OccurrenceData>> = query_lyxal_result(
        &db,
        "RETURN fn::error_occurrence_list({ source_module: 'test_integration' });",
    )
    .await;
    assert!(list_res.ok);
    let items = list_res.into_result("list_occ").unwrap();
    assert!(!items.is_empty());

    // 4. Purge occurrences before future date
    let purge_res: LyxalResult<PurgeData> = query_lyxal_result(
        &db,
        "RETURN fn::error_occurrence_purge_before({ before: '2099-01-01T00:00:00Z' });",
    )
    .await;
    assert!(purge_res.ok);
    let purge_data = purge_res.into_result("purge").unwrap();
    assert!(purge_data.purged);
    assert!(purge_data.count >= 1);
}
