-- ============================================================================
-- FONCTION : fn::base_unite_delete
-- MODULE   : lyxal_base
-- RÔLE     : Suppression d'une unité ni système ni référencée
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

    LET $existing = (SELECT id, code, is_system FROM ONLY $p.id);
    IF $existing == NONE {
        RETURN fn::error_result("BASE_UNITE_NOT_FOUND", $language, { id: <string> $p.id });
    };
    IF $existing.is_system {
        RETURN fn::error_result("BASE_UNITE_IS_SYSTEM", $language, { id: <string> $p.id });
    };
    -- Références entrantes de toute table (champs déclarés REFERENCE), sans connaître les
    -- consommateurs ; les codes d'échange de l'unité lui appartiennent et sont supprimés avec elle
    LET $references = array::len(((SELECT VALUE <~? FROM ONLY $p.id) ?? []).filter(|$r| record::tb($r) != "base_unite_code"));
    IF $references > 0 {
        RETURN fn::error_result("BASE_UNITE_IN_USE", $language, { id: <string> $p.id, references: $references });
    };

    DELETE base_unite_code WHERE unite = $p.id;
    LET $deleted = (DELETE ONLY $p.id RETURN BEFORE);
    IF $deleted == NONE {
        RETURN fn::error_result("BASE_WRITE_FORBIDDEN", $language, { table: "base_unite" });
    };
    -- Clé du libellé et ses traductions ; un échec annule la suppression (même transaction)
    LET $failure = fn::base_libelle_delete("unite", $existing.code);
    IF $failure IS NOT NONE AND $failure != "I18N_KEY_NOT_FOUND" { THROW "BASE_LIBELLE_WRITE_FAILED"; };
    RETURN fn::result_ok({ id: <string> $p.id, deleted: true });
} COMMENT "Supprime une unité qui n'est ni système ni référencée par une autre table ; sinon, la désactiver";
