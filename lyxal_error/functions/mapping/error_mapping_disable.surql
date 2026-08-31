-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_mapping_disable                                              │
-- │  Désactive logiquement une règle de correspondance d'erreur externe     │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::error_mapping_disable(
    $mapping_id: option<record<error_external_mapping>>
) {
    IF $mapping_id == NONE {
        RETURN fn::result_error("CORE_ERROR_DEFINITION_NOT_FOUND", "fr", { field: "mapping_id" });
    };

    LET $existing = SELECT VALUE id FROM $mapping_id;
    IF array::len($existing) == 0 {
        RETURN fn::result_error("CORE_ERROR_DEFINITION_NOT_FOUND", "fr", { id: $mapping_id });
    };

    UPDATE $mapping_id SET enabled = false, updated_at = time::now();
    RETURN fn::result_ok({ disabled: true, id: $mapping_id });
} COMMENT "Désactive logiquement une règle de correspondance d'erreur externe";
