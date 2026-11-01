use lyxal_error::{
    ErrorDefinitionCreateParams, ErrorLogParams, ErrorMappingCreateParams, LyxalCallError,
    LyxalError, LyxalResult,
};
use serde_json::json;
use surrealdb_types::{SurrealValue, Value};

/// Convertit un JSON en valeur SurrealDB, `null` devenant `NONE`.
///
/// `fn::result_ok` et `fn::error_result` renvoient `NONE` (et non `NULL`) pour un champ absent :
/// c'est ce que reçoit réellement le SDK.
fn to_surreal(raw: serde_json::Value) -> Value {
    match raw {
        serde_json::Value::Null => Value::None,
        serde_json::Value::Object(map) => {
            let mut obj = surrealdb_types::Object::new();
            for (k, v) in map {
                obj.insert(k, to_surreal(v));
            }
            Value::Object(obj)
        }
        other => other.into_value(),
    }
}

/// Simule la lecture d'un `LyxalResult<T>` renvoyé par SurrealDB.
fn from_db<T: SurrealValue>(raw: serde_json::Value) -> LyxalResult<T> {
    LyxalResult::<T>::from_value(to_surreal(raw)).expect("LyxalResult conforme")
}

#[test]
fn test_lyxal_result_success_with_data() {
    let raw = json!({
        "ok": true,
        "data": { "id": "error_definition:test", "code": "TEST_CODE" },
        "error": null
    });

    let res: LyxalResult<serde_json::Value> = from_db(raw);
    assert!(res.ok);
    assert!(res.error.is_none());

    let data = res.into_result("test_op").unwrap();
    assert_eq!(data["code"], "TEST_CODE");
}

#[test]
fn test_lyxal_result_success_void_unit() {
    let raw = json!({
        "ok": true,
        "data": null,
        "error": null
    });

    let res: LyxalResult<()> = from_db(raw);
    assert!(res.ok);
    assert!(res.into_result("test_void").is_ok());
}

#[test]
fn test_lyxal_result_success_optional_type() {
    let raw = json!({
        "ok": true,
        "data": null,
        "error": null
    });

    let res: LyxalResult<Option<String>> = from_db(raw);
    assert!(res.ok);
    let opt = res.into_result("test_opt").unwrap();
    assert_eq!(opt, None);
}

#[test]
fn test_lyxal_result_business_error_propagation() {
    let raw = json!({
        "ok": false,
        "data": null,
        "error": {
            "code": "ERROR_DEFINITION_NOT_FOUND",
            "message": "Error definition not found",
            "label": "Définition introuvable",
            "description": "Explication détaillée",
            "resolution": "Créer la définition",
            "category": "not_found",
            "severity": "error",
            "http_status": 404,
            "retryable": false,
            "documentation": {},
            "metadata": {},
            "details": { "code": "UNKNOWN" }
        }
    });

    let res: LyxalResult<String> = from_db(raw);
    assert!(!res.ok);
    assert!(res.data.is_none());

    let err = res.into_result("test_lookup").unwrap_err();
    match &err {
        LyxalCallError::Business(be) => {
            assert_eq!(be.code, "ERROR_DEFINITION_NOT_FOUND");
            assert_eq!(be.http_status, Some(404));
            assert_eq!(be.details["code"], "UNKNOWN");
        }
        _ => panic!("Expected LyxalCallError::Business, got {:?}", err),
    }

    assert!(err.is_business_code("ERROR_DEFINITION_NOT_FOUND"));
    assert!(!err.is_business_code("OTHER_CODE"));
}

#[test]
fn test_lyxal_result_rejects_inconsistent_ok_true_with_none_data() {
    let res: LyxalResult<String> = LyxalResult {
        ok: true,
        data: None,
        error: None,
    };

    let err = res.into_result("test_func").unwrap_err();
    assert!(matches!(
        err,
        LyxalCallError::InvalidContract {
            function: "test_func"
        }
    ));
}

#[test]
fn test_lyxal_result_rejects_inconsistent_ok_false_with_some_data() {
    let err_def = LyxalError {
        code: "TEST_ERR".into(),
        message: "msg".into(),
        label: "label".into(),
        description: None,
        resolution: None,
        category: "business".into(),
        severity: "error".into(),
        http_status: Some(400),
        retryable: false,
        documentation: json!({}),
        metadata: json!({}),
        details: json!({}),
    };

    let res: LyxalResult<String> = LyxalResult {
        ok: false,
        data: Some("data".into()),
        error: Some(err_def),
    };

    let err = res.into_result("test_func").unwrap_err();
    assert!(matches!(
        err,
        LyxalCallError::InvalidContract {
            function: "test_func"
        }
    ));
}

#[test]
fn test_lyxal_result_rejects_inconsistent_ok_true_with_some_error() {
    let err_def = LyxalError {
        code: "TEST_ERR".into(),
        message: "msg".into(),
        label: "label".into(),
        description: None,
        resolution: None,
        category: "business".into(),
        severity: "error".into(),
        http_status: Some(400),
        retryable: false,
        documentation: json!({}),
        metadata: json!({}),
        details: json!({}),
    };

    let res: LyxalResult<String> = LyxalResult {
        ok: true,
        data: Some("data".into()),
        error: Some(err_def),
    };

    let err = res.into_result("test_func").unwrap_err();
    assert!(matches!(
        err,
        LyxalCallError::InvalidContract {
            function: "test_func"
        }
    ));
}

#[test]
fn test_lyxal_result_rejects_inconsistent_ok_false_with_none_error() {
    let res: LyxalResult<String> = LyxalResult {
        ok: false,
        data: None,
        error: None,
    };

    let err = res.into_result("test_func").unwrap_err();
    assert!(matches!(
        err,
        LyxalCallError::InvalidContract {
            function: "test_func"
        }
    ));
}

#[test]
fn test_lyxal_call_error_helpers() {
    let call_err = LyxalCallError::business_code("CUSTOM_AUTH_FAILED", json!({ "user": "alice" }));
    assert!(call_err.is_business_code("CUSTOM_AUTH_FAILED"));
    assert!(!call_err.is_business_code("OTHER"));

    let disp = format!("{}", call_err);
    assert!(disp.contains("CUSTOM_AUTH_FAILED"));
}

#[test]
fn test_types_surreal_value_roundtrip() {
    let create_params = ErrorDefinitionCreateParams {
        code: "ERR_TEST_ROUNDTRIP".into(),
        message: "Message test".into(),
        category: Some("validation".into()),
        severity: Some("error".into()),
        http_status: Some(400),
        retryable: Some(false),
        ..Default::default()
    };

    let val = create_params.into_value();
    let obj = match &val {
        Value::Object(obj) => obj,
        other => panic!("objet attendu, obtenu {other:?}"),
    };
    assert_eq!(
        obj.get("code"),
        Some(&Value::String("ERR_TEST_ROUNDTRIP".into()))
    );
    // Un champ optionnel absent est transmis comme NONE (lu par `$params.x ?? défaut` en SurrealQL).
    assert!(matches!(obj.get("translations"), None | Some(Value::None)));
    let json = val.into_json_value();
    assert_eq!(json["http_status"], 400);

    let mapping_params = ErrorMappingCreateParams {
        provider: "stripe".into(),
        match_type: "exact".into(),
        target_code: "PAYMENT_FAILED".into(),
        service: Some("charges".into()),
        external_code: Some("card_declined".into()),
        http_status: Some(402),
        external_http_status: Some(402),
        description: Some("Carte refusée".into()),
        retryable_override: Some(false),
        ..Default::default()
    };

    let val_mapping = mapping_params.into_value().into_json_value();
    assert_eq!(val_mapping["provider"], "stripe");
    assert_eq!(val_mapping["match_type"], "exact");
    assert_eq!(val_mapping["service"], "charges");
    assert_eq!(val_mapping["external_http_status"], 402);
    assert_eq!(val_mapping["description"], "Carte refusée");
    assert_eq!(val_mapping["retryable_override"], false);

    let log_params = ErrorLogParams {
        code: "ERROR_OCCURRED".into(),
        source_module: Some("lyxal_booking".into()),
        technical_message: Some("Database timeout".into()),
        ..Default::default()
    };

    let val_log = log_params.into_value().into_json_value();
    assert_eq!(val_log["code"], "ERROR_OCCURRED");
    assert_eq!(val_log["source_module"], "lyxal_booking");
}
