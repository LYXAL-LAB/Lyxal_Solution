-- ============================================================================
-- FONCTION : fn::base_unite_type_delete
-- MODULE   : lyxal_base
-- RÔLE     : Suppression d'un type d'unité ni système ni utilisé
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::base_unite_type_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "base_unite_type" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("BASE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $language = $p.language;

    LET $existing = (SELECT id, code, is_system FROM ONLY $p.id);
    IF $existing == NONE {
        RETURN fn::error_result("BASE_UNITE_TYPE_NOT_FOUND", $language, { id: <string> $p.id });
    };
    IF $existing.is_system {
        RETURN fn::error_result("BASE_UNITE_TYPE_IS_SYSTEM", $language, { id: <string> $p.id });
    };
    -- Références entrantes de toute table (champs déclarés REFERENCE), sans connaître les consommateurs
    LET $references = array::len((SELECT VALUE <~? FROM ONLY $p.id) ?? []);
    IF $references > 0 {
        RETURN fn::error_result("BASE_UNITE_TYPE_IN_USE", $language, { id: <string> $p.id, references: $references });
    };

    LET $deleted = (DELETE ONLY $p.id RETURN BEFORE);
    IF $deleted == NONE {
        RETURN fn::error_result("BASE_WRITE_FORBIDDEN", $language, { table: "base_unite_type" });
    };
    -- Clé du libellé et ses traductions ; un échec annule la suppression (même transaction)
    LET $failure = fn::base_libelle_delete("unite_type", $existing.code);
    IF $failure IS NOT NONE AND $failure != "I18N_KEY_NOT_FOUND" { THROW "BASE_LIBELLE_WRITE_FAILED"; };
    RETURN fn::result_ok({ id: <string> $p.id, deleted: true });
} COMMENT "Supprime un type d'unité qui n'est ni système ni référencé (unités ou autres modules) ; sinon, le désactiver";
