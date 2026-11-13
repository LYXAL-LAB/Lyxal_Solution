-- ============================================================================
-- FONCTIONS : réglages
-- MODULE    : lyxal_secrets
-- ============================================================================

-- ----------------------------------------------------------------------------
-- fn::secrets_settings_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_settings_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::secrets_can({ action: "list", tenant: $p.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    RETURN fn::result_ok({
        own: (SELECT * FROM ONLY secrets_settings WHERE scope_key = $scope LIMIT 1),
        effective: fn::secrets_settings_effective({ tenant: $p.tenant })
    });
} COMMENT "Réglages d'une portée ({ tenant }) : { own, effective } (organisation, sinon installation, sinon valeurs par défaut). Droit : liste";

-- ----------------------------------------------------------------------------
-- fn::secrets_settings_set
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_settings_set($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            max_versions: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 100 } }] },
            deleted_retention_days: { pipeline: [{ rule: "integer", options: { min_value: 7, max_value: 90 } }] },
            purge_protection: { pipeline: [{ rule: "boolean" }] },
            max_value_bytes: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1048576 } }] },
            default_visibility: { pipeline: [{ rule: "enum", options: { allowed: ["restricted", "revealable"], case_sensitive: true } }] },
            expiry_warning_days: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 365 } }] },
            clear: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "each", options: { pipeline: [{ rule: "enum", options: { allowed: ["max_versions", "deleted_retention_days", "max_value_bytes", "default_visibility", "expiry_warning_days"], case_sensitive: true } }] } }], default: [] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::secrets_can({ action: "settings", tenant: $p.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    LET $existing = (SELECT id, purge_protection FROM ONLY secrets_settings WHERE scope_key = $scope LIMIT 1);
    IF $existing.purge_protection = true AND $p.purge_protection = false {
        RETURN fn::error_result("SECRETS_PURGE_PROTECTED", $p.language, { reason: "irreversible" });
    };
    LET $fields = ["max_versions", "deleted_retention_days", "purge_protection", "max_value_bytes", "default_visibility", "expiry_warning_days"];
    -- Champ fourni : remplacé ; champ dans clear : effacé ; sinon conservé
    LET $changes = object::from_entries(array::filter(
        array::map($fields, |$f| [$f, IF $f IN $p.clear { NONE } ELSE { $p[$f] }]),
        |$e| $e[1] IS NOT NONE OR $e[0] IN $p.clear
    ));
    LET $saved = IF $existing IS NONE {
        (CREATE ONLY type::record("secrets_settings", $scope) CONTENT object::extend($changes, { tenant: $p.tenant }))
    } ELSE {
        (UPDATE ONLY $existing.id MERGE $changes)
    };
    IF $saved == NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_settings" }); };
    RETURN fn::result_ok($saved);
} COMMENT "Enregistre les réglages d'une portée ({ tenant, max_versions, deleted_retention_days, purge_protection, max_value_bytes, default_visibility, expiry_warning_days, clear }) : un champ fourni est remplacé, un champ nommé dans clear est effacé, les autres sont conservés. La protection contre la purge ne se retire pas (SECRETS_PURGE_PROTECTED). Droit : réglages";
