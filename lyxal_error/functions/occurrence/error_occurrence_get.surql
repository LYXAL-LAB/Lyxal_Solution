-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_occurrence_get                                                │
-- │  Lecture d'une occurrence d'erreur technique par son ID                 │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::error_occurrence_get(
    $occurrence_id: option<record<error_occurrence>>
) {
    IF $occurrence_id == NONE {
        RETURN fn::result_error("CORE_ERROR_DEFINITION_NOT_FOUND", "fr", { field: "occurrence_id" });
    };

    LET $res = SELECT * FROM $occurrence_id;
    IF array::len($res) == 0 {
        RETURN fn::result_error("CORE_ERROR_DEFINITION_NOT_FOUND", "fr", { id: $occurrence_id });
    };

    RETURN fn::result_ok($res[0]);
} COMMENT "Récupère les détails d'une occurrence d'erreur au format universel LyxalResult";
