use lyxal_error::{
    ErrorDefinitionCreateParams, ErrorLogParams, ErrorMappingCreateParams, LyxalCallError,
    LyxalError, LyxalResult,
};
use serde_json::json;

#[test]
fn test_lyxal_result_success_with_data() {
    let raw = json!({
        "ok": true,
        "data": { "id": "error_definition:test", "code": "TEST_CODE" },
        "error": null
    });

    let res: LyxalResult<serde_json::Value> = serde_json::from_value(raw).unwrap();
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

    let res: LyxalResult<()> = serde_json::from_value(raw).unwrap();
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

    let res: LyxalResult<Option<String>> = serde_json::from_value(raw).unwrap();
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

    let res: LyxalResult<String> = serde_json::from_value(raw).unwrap();
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
fn test_types_serialization_roundtrip() {
    let create_params = ErrorDefinitionCreateParams {
        code: "ERR_TEST_ROUNDTRIP".into(),
        message: "Message test".into(),
        category: Some("validation".into()),
        severity: Some("error".into()),
        http_status: Some(400),
        retryable: Some(false),
        ..Default::default()
    };

    let val = serde_json::to_value(&create_params).unwrap();
    assert_eq!(val["code"], "ERR_TEST_ROUNDTRIP");
    assert_eq!(val["http_status"], 400);
    assert!(val.get("translations").is_none()); // skip_serializing_if

    let mapping_params = ErrorMappingCreateParams {
        provider: "stripe".into(),
        match_type: "exact".into(),
        target_code: "PAYMENT_FAILED".into(),
        external_code: Some("card_declined".into()),
        http_status: Some(402),
        ..Default::default()
    };

    let val_mapping = serde_json::to_value(&mapping_params).unwrap();
    assert_eq!(val_mapping["provider"], "stripe");
    assert_eq!(val_mapping["match_type"], "exact");

    let log_params = ErrorLogParams {
        code: "ERROR_OCCURRED".into(),
        source_module: Some("lyxal_booking".into()),
        technical_message: Some("Database timeout".into()),
        ..Default::default()
    };

    let val_log = serde_json::to_value(&log_params).unwrap();
    assert_eq!(val_log["code"], "ERROR_OCCURRED");
    assert_eq!(val_log["source_module"], "lyxal_booking");
}
