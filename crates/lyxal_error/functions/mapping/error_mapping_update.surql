-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_mapping_update                                               │
-- │  Mise à jour d'une règle de correspondance d'erreur externe             │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::error_mapping_update(
    $params: object
) {
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };
    LET $raw_id = $params.mapping_id ?? $params.id;
    LET $mapping_id = IF type::is::record($raw_id) {
        $raw_id
    } ELSE IF type::is::string($raw_id) {
        IF string::starts_with($raw_id, "error_external_mapping:") {
            type::thing("error_external_mapping", string::slice($raw_id, 23))
        } ELSE {
            type::thing("error_external_mapping", $raw_id)
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
    LET $m = IF $params.matcher != NONE AND string::len(string::trim($params.matcher)) > 0 { string::lowercase(string::trim($params.matcher)) } ELSE { $cur.matcher };
    LET $def = IF $params.definition_id != NONE { $params.definition_id } ELSE IF $params.definition != NONE { $params.definition } ELSE { $cur.definition };
    LET $p = IF $params.priority != NONE { $params.priority } ELSE { $cur.priority };
    LET $r_override = IF $params.retryable_override != NONE { $params.retryable_override } ELSE { $cur.retryable_override };

    UPDATE $mapping_id MERGE {
        matcher: $m,
        definition: $def,
        priority: $p,
        retryable_override: $r_override,
        updated_at: time::now()
    };

    LET $updated = SELECT * FROM $mapping_id;
    RETURN fn::result_ok($updated[0]);
} COMMENT "Met à jour la méthode de correspondance, la priorité ou le code d'erreur cible";
