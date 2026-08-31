-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_mapping_update                                               │
-- │  Mise à jour d'une règle de correspondance d'erreur externe             │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::error_mapping_update(
    $mapping_id: option<record<error_external_mapping>>,
    $matcher: option<string>,
    $definition_id: option<record<error_definition>>,
    $priority: option<int>,
    $retryable_override: option<bool>
) {
    IF $mapping_id == NONE {
        RETURN fn::result_error("CORE_ERROR_DEFINITION_NOT_FOUND", "fr", { field: "mapping_id" });
    };

    LET $existing = SELECT * FROM $mapping_id;
    IF array::len($existing) == 0 {
        RETURN fn::result_error("CORE_ERROR_DEFINITION_NOT_FOUND", "fr", { id: $mapping_id });
    };

    LET $cur = $existing[0];
    LET $m = IF $matcher != NONE { string::lowercase(string::trim($matcher)) } ELSE { $cur.matcher };
    LET $def = IF $definition_id != NONE { $definition_id } ELSE { $cur.definition };
    LET $p = IF $priority != NONE { $priority } ELSE { $cur.priority };
    LET $r_override = IF $retryable_override != NONE { $retryable_override } ELSE { $cur.retryable_override };

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
