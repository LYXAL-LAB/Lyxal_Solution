-- ============================================================================
-- FONCTION : fn::base_unite_type_update
-- MODULE   : lyxal_base
-- RÔLE     : Mise à jour du libellé ou de l'activation d'un type d'unité
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::base_unite_type_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "base_unite_type" } }], required: true },
            libelle: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }] },
            enabled: { pipeline: [{ rule: "boolean" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("BASE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $language = $p.language;
    IF $p.libelle == NONE AND $p.enabled == NONE {
        RETURN fn::error_result("BASE_NO_UPDATABLE_FIELDS_PROVIDED", $language, { allowed_fields: ["libelle", "enabled"] });
    };

    LET $existing = (SELECT * FROM ONLY $p.id);
    IF $existing == NONE {
        RETURN fn::error_result("BASE_UNITE_TYPE_NOT_FOUND", $language, { id: <string> $p.id });
    };

    LET $updated = (UPDATE ONLY $p.id MERGE {
        enabled: $p.enabled ?? $existing.enabled
    });
    IF $updated == NONE {
        RETURN fn::error_result("BASE_WRITE_FORBIDDEN", $language, { table: "base_unite_type" });
    };
    -- Libellé : texte source de la clé lyxal_i18n ; son échec rétablit l'enregistrement
    IF $p.libelle != NONE {
        LET $failure = fn::base_libelle_update("unite_type", $existing.code, $p.libelle);
        IF $failure IS NOT NONE {
            UPDATE $p.id MERGE { enabled: $existing.enabled };
            RETURN fn::error_result("BASE_LIBELLE_WRITE_FAILED", $language, { cause: $failure });
        };
    };
    LET $labelled = fn::base_libelle_attach([$updated], "unite_type", $language);
    IF $labelled.error IS NOT NONE {
        RETURN fn::error_result("BASE_LIBELLE_READ_FAILED", $language, { cause: $labelled.error });
    };
    RETURN fn::result_ok($labelled.records[0]);
} COMMENT "Met à jour le libellé ou l'activation d'un type d'unité ; la désactivation ne modifie pas les unités rattachées";
