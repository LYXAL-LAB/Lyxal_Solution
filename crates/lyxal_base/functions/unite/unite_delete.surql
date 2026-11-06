-- ============================================================================
-- FONCTION : fn::base_unite_delete
-- MODULE   : lyxal_base
-- RÔLE     : Suppression d'une unité non système
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::base_unite_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "base_unite" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("BASE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $language = $p.language;

    LET $existing = (SELECT id, is_system FROM ONLY $p.id);
    IF $existing == NONE {
        RETURN fn::error_result("BASE_UNITE_NOT_FOUND", $language, { id: <string> $p.id });
    };
    IF $existing.is_system {
        RETURN fn::error_result("BASE_UNITE_IS_SYSTEM", $language, { id: <string> $p.id });
    };

    LET $deleted = (DELETE ONLY $p.id RETURN BEFORE);
    IF $deleted == NONE {
        RETURN fn::error_result("BASE_WRITE_FORBIDDEN", $language, { table: "base_unite" });
    };
    RETURN fn::result_ok({ id: <string> $p.id, deleted: true });
} COMMENT "Supprime une unité qui n'est pas système ; une unité système se désactive";
