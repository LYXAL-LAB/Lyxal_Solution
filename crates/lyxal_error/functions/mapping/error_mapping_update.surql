-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_mapping_update                                               │
-- │  Mise à jour d'une règle de correspondance d'erreur externe             │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::error_mapping_update(
    $params: object
) {
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };
    LET $raw_id = $params.mapping_id ?? $params.id;
    LET $mapping_id = IF type::is_record($raw_id) {
        $raw_id
    } ELSE IF type::is_string($raw_id) {
        IF string::starts_with($raw_id, "error_external_mapping:") {
            type::record("error_external_mapping", string::slice($raw_id, 23))
        } ELSE {
            type::record("error_external_mapping", $raw_id)
        }
    } ELSE {
        NONE
    };

    IF $mapping_id == NONE {
        RETURN fn::error_result("ERROR_PARAM_REQUIRED", $language, { field: "mapping_id" });
    };

    LET $existing = SELECT * FROM $mapping_id;
    IF array::len($existing) == 0 {
        RETURN fn::error_result("ERROR_MAPPING_NOT_FOUND", $language, { mapping_id: $mapping_id });
    };

    LET $cur = $existing[0];
    LET $raw_matcher = $params.matcher ?? $params.match_type;
    LET $m = IF $raw_matcher != NONE AND string::len(string::trim($raw_matcher)) > 0 { string::lowercase(string::trim($raw_matcher)) } ELSE { $cur.matcher };
    LET $raw_def = $params.definition_id ?? $params.target_code ?? $params.definition;
    LET $def = IF $raw_def != NONE {
        IF type::is_record($raw_def) {
            $raw_def
        } ELSE {
            LET $id_str = string::replace(<string>$raw_def, "error_definition:", "");
            type::record("error_definition", $id_str)
        }
    } ELSE {
        $cur.definition
    };
    LET $p = IF $params.priority != NONE { $params.priority } ELSE { $cur.priority };
    LET $r_override = IF $params.retryable_override != NONE { $params.retryable_override } ELSE { $cur.retryable_override };
    LET $svc = IF $params.service != NONE { $params.service } ELSE { $cur.service };
    LET $ext_status = IF $params.external_http_status != NONE { $params.external_http_status } ELSE IF $params.http_status != NONE { $params.http_status } ELSE { $cur.external_http_status };
    LET $desc = IF $params.description != NONE { $params.description } ELSE { $cur.description };
    LET $enab = IF $params.enabled != NONE { $params.enabled } ELSE IF $params.active != NONE { $params.active } ELSE { $cur.enabled };

    UPDATE $mapping_id MERGE {
        matcher: $m,
        definition: $def,
        priority: $p,
        service: $svc,
        external_http_status: $ext_status,
        description: $desc,
        retryable_override: $r_override,
        enabled: $enab,
        updated_at: time::now()
    };

    LET $updated = SELECT * FROM $mapping_id;
    RETURN fn::result_ok($updated[0]);
} COMMENT "Met à jour la méthode de correspondance, la priorité ou le code d'erreur cible";
