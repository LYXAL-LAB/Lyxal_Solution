-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_mapping_get                                                  │
-- │  Lecture d'une règle de correspondance d'erreur externe par son ID      │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::error_mapping_get(
    $mapping_id: option<record<error_external_mapping>>
) {
    IF $mapping_id == NONE {
        RETURN fn::result_error("CORE_ERROR_DEFINITION_NOT_FOUND", "fr", { field: "mapping_id" });
    };

    LET $res = SELECT * FROM $mapping_id;
    IF array::len($res) == 0 {
        RETURN fn::result_error("CORE_ERROR_DEFINITION_NOT_FOUND", "fr", { id: $mapping_id });
    };

    RETURN fn::result_ok($res[0]);
} COMMENT "Récupère les détails d'un mapping d'erreur externe au format universel";
