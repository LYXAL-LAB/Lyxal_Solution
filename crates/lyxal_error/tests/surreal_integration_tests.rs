use lyxal_error::LyxalResult;
use serde::Deserialize;
use std::io::Write;
use std::path::PathBuf;
use std::process::{Child, Command, Stdio};
use std::sync::atomic::{AtomicU16, Ordering};
use std::time::Duration;

static NEXT_PORT: AtomicU16 = AtomicU16::new(18400);
static TEST_MUTEX: std::sync::Mutex<()> = std::sync::Mutex::new(());

pub struct Surreal320 {
    child: Child,
    pub port: u16,
    _guard: std::sync::MutexGuard<'static, ()>,
}

impl Surreal320 {
    pub fn start() -> Self {
        let guard = TEST_MUTEX.lock().unwrap_or_else(|e| e.into_inner());
        let port = NEXT_PORT.fetch_add(1, Ordering::SeqCst);
        let surreal_bin = "c:\\Users\\HP\\Desktop\\Lyxal_OS\\surreal.exe";
        let child = Command::new(surreal_bin)
            .args([
                "start",
                "--bind",
                &format!("127.0.0.1:{}", port),
                "--user",
                "root",
                "--pass",
                "root",
                "mem://",
            ])
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .spawn()
            .expect("Failed to spawn surreal.exe 3.2.0");

        let start_time = std::time::Instant::now();
        let mut ready = false;
        while start_time.elapsed() < Duration::from_secs(10) {
            if let Ok(stream) = std::net::TcpStream::connect(("127.0.0.1", port)) {
                drop(stream);
                ready = true;
                break;
            }
            std::thread::sleep(Duration::from_millis(50));
        }
        if !ready {
            panic!("SurrealDB 3.2.0 failed to bind to port {} within 10s", port);
        }
        std::thread::sleep(Duration::from_millis(200));

        Self {
            child,
            port,
            _guard: guard,
        }
    }

    pub fn execute_raw(&self, surql: &str) -> Vec<serde_json::Value> {
        let surreal_bin = "c:\\Users\\HP\\Desktop\\Lyxal_OS\\surreal.exe";
        let endpoint = format!("http://127.0.0.1:{}", self.port);
        let mut cmd = Command::new(surreal_bin)
            .args([
                "sql",
                "--endpoint",
                &endpoint,
                "-u",
                "root",
                "-p",
                "root",
                "--ns",
                "lyxal_test",
                "--db",
                "test_error",
                "--hide-welcome",
                "--json",
            ])
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .spawn()
            .expect("Spawn surreal sql client");

        if let Some(mut stdin) = cmd.stdin.take() {
            stdin.write_all(surql.as_bytes()).expect("Write SQL to stdin");
        }
        let output = cmd.wait_with_output().expect("Execute surreal sql");
        let stdout_str = String::from_utf8_lossy(&output.stdout);

        let mut results = Vec::new();
        for line in stdout_str.lines() {
            let trimmed = line.trim();
            if trimmed.starts_with('[') || trimmed.starts_with('{') {
                if let Ok(parsed) = serde_json::from_str::<serde_json::Value>(trimmed) {
                    results.push(parsed);
                }
            }
        }
        results
    }

    pub fn query_lyxal_result<T: serde::de::DeserializeOwned>(&self, surql: &str) -> LyxalResult<T> {
        let results = self.execute_raw(surql);
        let last_val = results.last().cloned().unwrap_or(serde_json::Value::Null);

        let item = if let Some(arr) = last_val.as_array() {
            if let Some(first) = arr.first() {
                if let Some(inner_arr) = first.as_array() {
                    inner_arr.first().cloned().unwrap_or(serde_json::Value::Null)
                } else {
                    first.clone()
                }
            } else {
                serde_json::Value::Null
            }
        } else {
            last_val
        };

        serde_json::from_value(item.clone()).unwrap_or_else(|e| {
            panic!(
                "Failed to deserialize LyxalResult: {:?}\nExtracted item: {:?}\nRaw results: {:?}",
                e, item, results
            )
        })
    }

    pub fn query_val(&self, surql: &str) -> serde_json::Value {
        let results = self.execute_raw(surql);
        let last_val = results.last().cloned().unwrap_or(serde_json::Value::Null);
        if let Some(arr) = last_val.as_array() {
            if let Some(first) = arr.first() {
                first.clone()
            } else {
                serde_json::Value::Null
            }
        } else {
            last_val
        }
    }
}

impl Drop for Surreal320 {
    fn drop(&mut self) {
        let _ = self.child.kill();
    }
}

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
    #[serde(default)]
    retryable: Option<bool>,
    #[serde(default)]
    log_occurrence: Option<bool>,
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
    service: Option<String>,
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

fn setup_db() -> Surreal320 {
    let db = Surreal320::start();

    let manifest_path = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("manifest.toml");
    let content = std::fs::read_to_string(&manifest_path).expect("Read manifest.toml");
    let parsed: toml::Value = toml::from_str(&content).expect("Parse manifest.toml");
    let resources = parsed.get("resources").and_then(|v| v.as_table()).unwrap();

    let execute_resources = |key: &str| {
        let list = resources.get(key).and_then(|v| v.as_array()).unwrap();
        for item in list {
            let rel_path = item.as_str().unwrap();
            let full_path = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join(rel_path);
            let surql = std::fs::read_to_string(&full_path)
                .unwrap_or_else(|_| panic!("Failed to read {}", full_path.display()));

            db.execute_raw(&surql);
        }
    };

    execute_resources("schemas");
    execute_resources("migrations");
    execute_resources("functions");
    execute_resources("error_definitions");
    execute_resources("seeds");

    db
}

#[test]
fn test_surreal_bootstrap_and_migration_idempotence() {
    let db = setup_db();

    // Verify error definitions table has the canon codes
    let defs_val = db.query_val(
        "SELECT VALUE code FROM error_definition WHERE code IN ['ERROR_PARAM_REQUIRED', 'ERROR_DEFINITION_NOT_FOUND', 'CORE_ERROR_DEFINITION_NOT_FOUND'];"
    );
    let defs: Vec<String> = serde_json::from_value(defs_val).unwrap();
    assert_eq!(defs.len(), 3, "Expected canonical error definitions");

    // Reapply migration multiple times to verify strict idempotence
    let migration_path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("migrations/0001_initial_schema.surql");
    let migration_surql = std::fs::read_to_string(migration_path).unwrap();

    let mig_res1 = db.query_val(&migration_surql);
    assert_eq!(mig_res1["status"], "APPLIED");

    let mig_res2 = db.query_val(&migration_surql);
    assert_eq!(mig_res2["status"], "APPLIED");

    // Verify replaying error_definitions.surql and seeds/error_mappings.surql doesn't fail or duplicate
    let err_defs_path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("error/error_definitions.surql");
    let err_defs_surql = std::fs::read_to_string(err_defs_path).unwrap();
    db.execute_raw(&err_defs_surql);

    let seeds_path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("seeds/error_mappings.surql");
    let seeds_surql = std::fs::read_to_string(seeds_path).unwrap();
    db.execute_raw(&seeds_surql);

    // Verify count of error_definition is exactly 6 (no duplicates!)
    let count_val = db.query_val("SELECT count() FROM error_definition GROUP ALL;");
    assert_eq!(count_val[0]["count"], 6, "Expected exactly 6 definitions without duplicate");

    // Verify count of error_external_mapping is exactly 2 (no duplicates!)
    let map_count_val = db.query_val("SELECT count() FROM error_external_mapping GROUP ALL;");
    assert_eq!(map_count_val[0]["count"], 2, "Expected exactly 2 mappings without duplicate");
}

#[test]
fn test_surreal_primitives_result_ok_and_error_result() {
    let db = setup_db();

    // Test fn::result_ok
    let res: LyxalResult<String> = db.query_lyxal_result("RETURN fn::result_ok('success_payload');");
    assert!(res.ok);
    assert_eq!(res.into_result("test").unwrap(), "success_payload");

    // Test fn::error_result with known code and French translation
    let err_res: LyxalResult<serde_json::Value> = db.query_lyxal_result(
        "RETURN fn::error_result('ERROR_PARAM_REQUIRED', 'fr', { field: 'username' });"
    );
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
    let fallback_res: LyxalResult<serde_json::Value> = db.query_lyxal_result(
        "RETURN fn::error_result('UNKNOWN_CODE_12345', 'fr', { context: 'test' });"
    );
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

#[test]
fn test_surreal_error_definition_lifecycle() {
    let db = setup_db();

    // 1. Creation with object params including retryable, documentation, metadata
    let create_res: LyxalResult<DefinitionData> = db.query_lyxal_result(
        r#"
            RETURN fn::error_definition_create({
                code: "TEST_CUSTOM_ERR",
                module: "test",
                message: "A custom test error occurred",
                category: "business",
                severity: "warning",
                http_status: 422,
                retryable: true,
                log_occurrence: false,
                translations: {
                    fr: { label: "Erreur personnalisée de test" },
                    en: { label: "Custom test error" }
                },
                documentation: { url: "https://docs.lyxal.dev/errors/TEST_CUSTOM_ERR" },
                metadata: { tag: "integration_320" }
            });
        "#
    );
    assert!(create_res.ok);
    let created = create_res.into_result("create").unwrap();
    assert_eq!(created.code, "TEST_CUSTOM_ERR");
    assert_eq!(created.retryable, Some(true));
    assert_eq!(created.log_occurrence, Some(false));

    // Verify persisted record has documentation and metadata
    let verify_rec = db.query_val("SELECT * FROM error_definition WHERE code = 'TEST_CUSTOM_ERR';");
    assert_eq!(verify_rec[0]["documentation"]["url"], "https://docs.lyxal.dev/errors/TEST_CUSTOM_ERR");
    assert_eq!(verify_rec[0]["metadata"]["tag"], "integration_320");

    // 2. Duplicate creation rejects
    let dup_res: LyxalResult<DefinitionData> = db.query_lyxal_result(
        r#"
            RETURN fn::error_definition_create({
                code: "TEST_CUSTOM_ERR",
                module: "test",
                message: "Duplicate"
            });
        "#
    );
    assert!(!dup_res.ok);
    let dup_err = dup_res.into_result("create").unwrap_err();
    assert!(dup_err.is_business_code("ERROR_DEFINITION_ALREADY_EXISTS"));

    // 3. Get with object params (both code and code_or_id)
    let get_res: LyxalResult<DefinitionData> =
        db.query_lyxal_result("RETURN fn::error_definition_get({ code: 'TEST_CUSTOM_ERR' });");
    assert!(get_res.ok);
    assert_eq!(get_res.into_result("get").unwrap().code, "TEST_CUSTOM_ERR");

    let get_res_alt: LyxalResult<DefinitionData> =
        db.query_lyxal_result("RETURN fn::error_definition_get({ code_or_id: 'TEST_CUSTOM_ERR' });");
    assert!(get_res_alt.ok);
    assert_eq!(get_res_alt.into_result("get_alt").unwrap().code, "TEST_CUSTOM_ERR");

    // 4. Missing param in get rejects with ERROR_PARAM_REQUIRED
    let get_missing: LyxalResult<DefinitionData> =
        db.query_lyxal_result("RETURN fn::error_definition_get({});");
    assert!(!get_missing.ok);
    assert!(get_missing.into_result("get_missing").unwrap_err().is_business_code("ERROR_PARAM_REQUIRED"));

    // 5. Inexistent code in get rejects with ERROR_DEFINITION_NOT_FOUND
    let get_inexistent: LyxalResult<DefinitionData> =
        db.query_lyxal_result("RETURN fn::error_definition_get({ code: 'INEXISTENT_ERROR_XYZ' });");
    assert!(!get_inexistent.ok);
    assert!(get_inexistent.into_result("get_inexistent").unwrap_err().is_business_code("ERROR_DEFINITION_NOT_FOUND"));

    // 6. Update with metadata and retryable
    let upd_res: LyxalResult<DefinitionData> = db.query_lyxal_result(
        r#"
            RETURN fn::error_definition_update({
                code: "TEST_CUSTOM_ERR",
                severity: "error",
                http_status: 400,
                retryable: false,
                metadata: { tag: "updated_320" }
            });
        "#
    );
    assert!(upd_res.ok);
    let updated = upd_res.into_result("update").unwrap();
    assert_eq!(updated.severity.as_deref(), Some("error"));
    assert_eq!(updated.http_status, Some(400));
    assert_eq!(updated.retryable, Some(false));

    // 7. List definitions before disable (must contain TEST_CUSTOM_ERR and filter by severity)
    let list_res: LyxalResult<Vec<DefinitionData>> =
        db.query_lyxal_result("RETURN fn::error_definition_list({ category: 'business', severity: 'error' });");
    assert!(list_res.ok);
    let items = list_res.into_result("list").unwrap();
    assert!(items.iter().any(|i| i.code == "TEST_CUSTOM_ERR"));

    // 8. Missing param in disable rejects with ERROR_PARAM_REQUIRED
    let dis_missing: LyxalResult<DisableResult> =
        db.query_lyxal_result("RETURN fn::error_definition_disable({});");
    assert!(!dis_missing.ok);
    assert!(dis_missing.into_result("dis_missing").unwrap_err().is_business_code("ERROR_PARAM_REQUIRED"));

    // 9. Inexistent code in disable rejects with ERROR_DEFINITION_NOT_FOUND
    let dis_inexistent: LyxalResult<DisableResult> =
        db.query_lyxal_result("RETURN fn::error_definition_disable({ code: 'INEXISTENT_CODE_XYZ' });");
    assert!(!dis_inexistent.ok);
    assert!(dis_inexistent.into_result("dis_inexistent").unwrap_err().is_business_code("ERROR_DEFINITION_NOT_FOUND"));

    // 10. Disable definition with valid object
    let dis_res: LyxalResult<DisableResult> =
        db.query_lyxal_result("RETURN fn::error_definition_disable({ code: 'TEST_CUSTOM_ERR' });");
    assert!(dis_res.ok);
    assert!(dis_res.into_result("disable").unwrap().disabled);

    // 11. Physical data preservation verification (record still exists with enabled: false)
    let phys_check = db.query_val("SELECT code, enabled FROM error_definition WHERE code = 'TEST_CUSTOM_ERR';");
    assert_eq!(phys_check[0]["code"], "TEST_CUSTOM_ERR");
    assert_eq!(phys_check[0]["enabled"], false, "Record must be logically disabled");

    // 12. List definitions after disable (must be excluded from default enabled_only list)
    let list_after: LyxalResult<Vec<DefinitionData>> =
        db.query_lyxal_result("RETURN fn::error_definition_list({ category: 'business' });");
    assert!(list_after.ok);
    let items_after = list_after.into_result("list_after").unwrap();
    assert!(!items_after.iter().any(|i| i.code == "TEST_CUSTOM_ERR"));
}

#[test]
fn test_surreal_error_mapping_and_resolution() {
    let db = setup_db();

    // 1. Create mapping using match_type / definition_id / service / description
    let map_res: LyxalResult<MappingData> = db.query_lyxal_result(
        r#"
            RETURN fn::error_mapping_create({
                provider: "stripe",
                service: "checkout",
                external_code: "card_declined",
                match_type: "exact",
                definition_id: "error_definition:ERROR_PARAM_REQUIRED",
                http_status: 402,
                priority: 10,
                description: "Paiement refusé"
            });
        "#
    );
    assert!(map_res.ok);
    let created = map_res.into_result("create_mapping").unwrap();
    assert_eq!(created.provider, "stripe");
    assert_eq!(created.service.as_deref(), Some("checkout"));

    // 2. Resolve external mapping (exact match)
    let match_res: LyxalResult<Option<serde_json::Value>> = db.query_lyxal_result(
        r#"
            RETURN fn::error_map_external({
                provider: "stripe",
                service: "checkout",
                external_code: "card_declined"
            });
        "#
    );
    assert!(match_res.ok);
    let matched_opt = match_res.into_result("map_ext").unwrap();
    assert!(matched_opt.is_some());
    let matched = matched_opt.unwrap();
    assert_eq!(matched["provider"], "stripe");
    assert_eq!(matched["external_code"], "card_declined");

    // 3. Resolve unknown external code returns None without error
    let unknown_res: LyxalResult<Option<serde_json::Value>> = db.query_lyxal_result(
        r#"
            RETURN fn::error_map_external({
                provider: "stripe",
                external_code: "unknown_weird_error_491823"
            });
        "#
    );
    assert!(unknown_res.ok);
    assert!(unknown_res.into_result("map_ext").unwrap().is_none());

    // 4. Missing required param provider returns ERROR_PARAM_REQUIRED
    let missing_res: LyxalResult<Option<serde_json::Value>> = db.query_lyxal_result(
        r#"
            RETURN fn::error_map_external({
                external_code: "card_declined"
            });
        "#
    );
    assert!(!missing_res.ok);
    assert!(missing_res.into_result("map_ext").unwrap_err().is_business_code("ERROR_PARAM_REQUIRED"));

    // 5. Get mapping by object params
    let map_get_res: LyxalResult<MappingData> = db.query_lyxal_result(
        "RETURN fn::error_mapping_get({ id: (SELECT VALUE id FROM error_external_mapping WHERE provider = 'stripe' LIMIT 1)[0] });"
    );
    assert!(map_get_res.ok);
    assert_eq!(map_get_res.into_result("map_get").unwrap().provider, "stripe");

    // 6. Missing param in mapping get rejects
    let map_get_missing: LyxalResult<MappingData> =
        db.query_lyxal_result("RETURN fn::error_mapping_get({});");
    assert!(!map_get_missing.ok);
    assert!(map_get_missing.into_result("map_get_missing").unwrap_err().is_business_code("ERROR_PARAM_REQUIRED"));

    // 7. Inexistent ID in mapping get rejects
    let map_get_inexistent: LyxalResult<MappingData> =
        db.query_lyxal_result("RETURN fn::error_mapping_get({ mapping_id: 'error_external_mapping:nonexistent' });");
    assert!(!map_get_inexistent.ok);
    assert!(map_get_inexistent.into_result("map_get_inexistent").unwrap_err().is_business_code("ERROR_MAPPING_NOT_FOUND"));

    // 8. Missing param in mapping disable rejects
    let map_dis_missing: LyxalResult<DisableResult> =
        db.query_lyxal_result("RETURN fn::error_mapping_disable({});");
    assert!(!map_dis_missing.ok);
    assert!(map_dis_missing.into_result("map_dis_missing").unwrap_err().is_business_code("ERROR_PARAM_REQUIRED"));

    // 9. Inexistent ID in mapping disable rejects
    let map_dis_inexistent: LyxalResult<DisableResult> =
        db.query_lyxal_result("RETURN fn::error_mapping_disable({ id: 'error_external_mapping:nonexistent' });");
    assert!(!map_dis_inexistent.ok);
    assert!(map_dis_inexistent.into_result("map_dis_inexistent").unwrap_err().is_business_code("ERROR_MAPPING_NOT_FOUND"));

    // 10. Disable mapping with valid object
    let dis_res: LyxalResult<DisableResult> = db.query_lyxal_result(
        "RETURN fn::error_mapping_disable({ id: (SELECT VALUE id FROM error_external_mapping WHERE provider = 'stripe' LIMIT 1)[0] });"
    );
    assert!(dis_res.ok);
    assert!(dis_res.into_result("disable_mapping").unwrap().disabled);
}

#[test]
fn test_surreal_error_occurrence_logging_and_purging() {
    let db = setup_db();

    // 1. Log error occurrence via fn::error_log
    let log_res: LyxalResult<OccurrenceData> = db.query_lyxal_result(
        r#"
            RETURN fn::error_log({
                code: "ERROR_PARAM_REQUIRED",
                source_module: "test_integration",
                operation: "user_signup",
                technical_message: "Validation field email missing",
                environment: "test"
            });
        "#
    );
    assert!(log_res.ok);
    let occ = log_res.into_result("log").unwrap();
    assert_eq!(occ.code, "ERROR_PARAM_REQUIRED");
    assert_eq!(occ.source_module, "test_integration");

    // 2. Retrieve occurrence by ID with object params
    let get_res: LyxalResult<OccurrenceData> = db.query_lyxal_result(
        "RETURN fn::error_occurrence_get({ id: (SELECT VALUE id FROM error_occurrence WHERE source_module = 'test_integration' LIMIT 1)[0] });"
    );
    assert!(get_res.ok);
    assert_eq!(
        get_res.into_result("get_occ").unwrap().operation.as_deref(),
        Some("user_signup")
    );

    // 3. Missing param in occurrence get rejects
    let occ_missing: LyxalResult<OccurrenceData> =
        db.query_lyxal_result("RETURN fn::error_occurrence_get({});");
    assert!(!occ_missing.ok);
    assert!(occ_missing.into_result("occ_missing").unwrap_err().is_business_code("ERROR_PARAM_REQUIRED"));

    // 4. Inexistent ID in occurrence get rejects
    let occ_inexistent: LyxalResult<OccurrenceData> =
        db.query_lyxal_result("RETURN fn::error_occurrence_get({ id: 'error_occurrence:nonexistent' });");
    assert!(!occ_inexistent.ok);
    assert!(occ_inexistent.into_result("occ_inexistent").unwrap_err().is_business_code("ERROR_OCCURRENCE_NOT_FOUND"));

    // 5. List occurrences with object params
    let list_res: LyxalResult<Vec<OccurrenceData>> = db.query_lyxal_result(
        "RETURN fn::error_occurrence_list({ source_module: 'test_integration' });"
    );
    assert!(list_res.ok);
    let items = list_res.into_result("list_occ").unwrap();
    assert!(!items.is_empty());

    // 6. Missing param in occurrence purge rejects
    let purge_missing: LyxalResult<PurgeData> =
        db.query_lyxal_result("RETURN fn::error_occurrence_purge_before({});");
    assert!(!purge_missing.ok);
    assert!(purge_missing.into_result("purge_missing").unwrap_err().is_business_code("ERROR_PARAM_REQUIRED"));

    // 7. Purge occurrences before future date with object params
    let purge_res: LyxalResult<PurgeData> = db.query_lyxal_result(
        "RETURN fn::error_occurrence_purge_before({ before: '2099-01-01T00:00:00Z' });"
    );
    assert!(purge_res.ok);
    let purge_data = purge_res.into_result("purge").unwrap();
    assert!(purge_data.purged);
    assert!(purge_data.count >= 1);
}

#[test]
fn test_surreal_edge_cases_and_contract_coherence() {
    let db = setup_db();

    // 1. Calling list functions with empty object {} must succeed
    let def_list: LyxalResult<Vec<DefinitionData>> =
        db.query_lyxal_result("RETURN fn::error_definition_list({});");
    assert!(def_list.ok);
    assert!(def_list.into_result("def_list").unwrap().len() >= 6);

    let map_list: LyxalResult<Vec<MappingData>> =
        db.query_lyxal_result("RETURN fn::error_mapping_list({});");
    assert!(map_list.ok);

    let occ_list: LyxalResult<Vec<OccurrenceData>> =
        db.query_lyxal_result("RETURN fn::error_occurrence_list({});");
    assert!(occ_list.ok);

    // 2. Calling fn::error_get (internal resolution primitive)
    let canon_res: LyxalResult<DefinitionData> = db.query_lyxal_result(
        "RETURN { ok: true, data: fn::error_get('ERROR_PARAM_REQUIRED'), error: NONE };"
    );
    assert!(canon_res.ok);
    assert_eq!(canon_res.into_result("canon").unwrap().code, "ERROR_PARAM_REQUIRED");

    // 3. Calling fn::error_get with inexistent code returns None without error
    let none_res: LyxalResult<Option<DefinitionData>> = db.query_lyxal_result(
        "RETURN { ok: true, data: fn::error_get('INEXISTENT_CODE_XYZ_123'), error: NONE };"
    );
    assert!(none_res.ok);
    assert!(none_res.into_result("none").unwrap().is_none());
}
