-- ============================================================================
-- FONCTIONS : réglages
-- MODULE    : lyxal_storage
-- ============================================================================

-- ----------------------------------------------------------------------------
-- fn::storage_settings_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_settings_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("STORAGE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::storage_can({ action: "read", tenant: $p.tenant }) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    RETURN fn::result_ok({
        own: (SELECT * FROM ONLY storage_settings WHERE scope_key = $scope LIMIT 1),
        effective: fn::storage_settings_effective({ tenant: $p.tenant })
    });
} COMMENT "Réglages d'une portée ({ tenant }) : { own, effective } (organisation, sinon installation, sinon valeurs par défaut). Droit : lecture";

-- ----------------------------------------------------------------------------
-- fn::storage_settings_set
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_settings_set($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            max_object_size: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 5368709120 } }] },
            quota_bytes: { pipeline: [{ rule: "integer", options: { min_value: 0 } }] },
            pending_ttl_seconds: { pipeline: [{ rule: "integer", options: { min_value: 60, max_value: 604800 } }] },
            upload_ttl_seconds: { pipeline: [{ rule: "integer", options: { min_value: 60, max_value: 604800 } }] },
            deleted_retention_days: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 3650 } }] },
            blocked_types: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "array_length", options: { max_length: 100 } }, { rule: "each", options: { pipeline: [{ rule: "mime_type" }] } }] },
            clear: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "each", options: { pipeline: [{ rule: "enum", options: { allowed: ["max_object_size", "quota_bytes", "pending_ttl_seconds", "upload_ttl_seconds", "deleted_retention_days", "blocked_types"], case_sensitive: true } }] } }], default: [] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("STORAGE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::storage_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    LET $fields = ["max_object_size", "quota_bytes", "pending_ttl_seconds", "upload_ttl_seconds", "deleted_retention_days", "blocked_types"];
    -- Champ fourni : remplacé ; champ dans clear : effacé ; sinon conservé
    LET $changes = object::from_entries(array::filter(
        array::map($fields, |$f| [$f, IF $f IN $p.clear { NONE } ELSE { $p[$f] }]),
        |$e| $e[1] IS NOT NONE OR $e[0] IN $p.clear
    ));
    LET $existing = (SELECT VALUE id FROM ONLY storage_settings WHERE scope_key = $scope LIMIT 1);
    LET $saved = IF $existing IS NONE {
        (CREATE ONLY type::record("storage_settings", $scope) CONTENT object::extend($changes, { tenant: $p.tenant }))
    } ELSE {
        (UPDATE ONLY $existing MERGE $changes)
    };
    IF $saved == NONE { RETURN fn::error_result("STORAGE_WRITE_FORBIDDEN", $p.language, { table: "storage_settings" }); };
    RETURN fn::result_ok($saved);
} COMMENT "Enregistre les réglages d'une portée ({ tenant, max_object_size, quota_bytes, pending_ttl_seconds, upload_ttl_seconds, deleted_retention_days, blocked_types, clear }) : un champ fourni est remplacé, un champ nommé dans clear est effacé, les autres sont conservés. Droit : gestion";
