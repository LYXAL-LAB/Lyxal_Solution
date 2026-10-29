-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_definition_update                                            │
-- │  Mise à jour des métadonnées d'une définition d'erreur canonique        │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::error_definition_update(
    $params: object
) {
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };
    LET $code_or_id = $params.code_or_id ?? $params.id ?? $params.code;

    IF $code_or_id == NONE OR string::len(string::trim($code_or_id)) == 0 {
        RETURN fn::error_result("ERROR_PARAM_REQUIRED", $language, { field: "code_or_id" });
    };

    LET $val = string::trim($code_or_id);
    LET $clean_code = string::uppercase($val);
    LET $existing = SELECT * FROM error_definition 
                     WHERE id = $val 
                        OR id = type::record("error_definition", $clean_code) 
                        OR code = $clean_code 
                     LIMIT 1;

    IF array::len($existing) == 0 {
        RETURN fn::error_result("ERROR_DEFINITION_NOT_FOUND", $language, { code_or_id: $val });
    };

    LET $cur = $existing[0];
    LET $clean_msg = IF $params.message != NONE AND string::len(string::trim($params.message)) > 0 { string::trim($params.message) } ELSE { $cur.message };
    LET $cat = IF $params.category != NONE { string::lowercase(string::trim($params.category)) } ELSE { $cur.category };
    LET $sev = IF $params.severity != NONE { string::lowercase(string::trim($params.severity)) } ELSE { $cur.severity };
    LET $status = IF $params.http_status != NONE { $params.http_status } ELSE { $cur.http_status };
    LET $trans = IF $params.translations != NONE { $params.translations } ELSE { $cur.translations };
    LET $ret = IF $params.retryable != NONE { $params.retryable } ELSE { $cur.retryable };
    LET $log_occ = IF $params.log_occurrence != NONE { $params.log_occurrence } ELSE { $cur.log_occurrence };
    LET $doc = IF $params.documentation != NONE { $params.documentation } ELSE { $cur.documentation };
    LET $meta = IF $params.metadata != NONE { $params.metadata } ELSE { $cur.metadata };
    LET $enab = IF $params.active != NONE { $params.active } ELSE IF $params.enabled != NONE { $params.enabled } ELSE { $cur.enabled };

    UPDATE $cur.id MERGE {
        message: $clean_msg,
        category: $cat,
        severity: $sev,
        http_status: $status,
        translations: $trans,
        retryable: $ret,
        log_occurrence: $log_occ,
        documentation: $doc,
        metadata: $meta,
        enabled: $enab,
        updated_at: time::now()
    };

    LET $updated = SELECT * FROM $cur.id;
    RETURN fn::result_ok($updated[0]);
} COMMENT "Met à jour le message, la catégorie, la sévérité ou les traductions d'une erreur";
