-- ============================================================================
-- FONCTION : fn::base_unite_type_update
-- MODULE   : lyxal_base
-- RÔLE     : Mise à jour du libellé, de l'activation ou de l'unité de base d'un type d'unité
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::base_unite_type_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "base_unite_type" } }], required: true },
            libelle: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }] },
            enabled: { pipeline: [{ rule: "boolean" }] },
            base_unit: { pipeline: [{ rule: "record", options: { expected_table: "base_unite" } }] },
            clear_base_unit: { pipeline: [{ rule: "boolean" }], default: false },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("BASE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $language = $p.language;
    IF $p.libelle == NONE AND $p.enabled == NONE AND $p.base_unit == NONE AND !$p.clear_base_unit {
        RETURN fn::error_result("BASE_NO_UPDATABLE_FIELDS_PROVIDED", $language, { allowed_fields: ["libelle", "enabled", "base_unit", "clear_base_unit"] });
    };
    -- Une unité de base ne peut pas être à la fois désignée et retirée
    IF $p.base_unit != NONE AND $p.clear_base_unit {
        RETURN fn::error_result("BASE_INVALID_PARAMETERS", $language, { fields: { clear_base_unit: ["CORE_VALIDATION_COMBINATION"] } });
    };

    LET $existing = (SELECT * FROM ONLY $p.id);
    IF $existing == NONE {
        RETURN fn::error_result("BASE_UNITE_TYPE_NOT_FOUND", $language, { id: <string> $p.id });
    };

    -- Unité de base : une unité de ce type, de facteur 1
    IF $p.base_unit != NONE {
        LET $unit = (SELECT type, factor FROM ONLY $p.base_unit);
        LET $reason = IF $unit == NONE { "not_found" }
            ELSE IF $unit.type != $p.id { "other_type" }
            ELSE IF $unit.factor != 1dec { "factor_not_one" };
        IF $reason != NONE {
            RETURN fn::error_result("BASE_UNITE_BASE_INVALID", $language, { unit: <string> $p.base_unit, type: <string> $p.id, reason: $reason });
        };
    };
    LET $base_unit = IF $p.clear_base_unit { NONE } ELSE { $p.base_unit ?? $existing.base_unit };

    LET $updated = (UPDATE ONLY $p.id MERGE {
        enabled: $p.enabled ?? $existing.enabled,
        base_unit: $base_unit
    });
    IF $updated == NONE {
        RETURN fn::error_result("BASE_WRITE_FORBIDDEN", $language, { table: "base_unite_type" });
    };
    -- Libellé : texte source de la clé lyxal_i18n ; son échec rétablit l'enregistrement
    IF $p.libelle != NONE {
        LET $failure = fn::base_libelle_update("unite_type", $existing.code, $p.libelle);
        IF $failure IS NOT NONE {
            UPDATE $p.id MERGE { enabled: $existing.enabled, base_unit: $existing.base_unit };
            RETURN fn::error_result("BASE_LIBELLE_WRITE_FAILED", $language, { cause: $failure });
        };
    };
    LET $labelled = fn::base_libelle_attach([$updated], "unite_type", $language);
    IF $labelled.error IS NOT NONE {
        RETURN fn::error_result("BASE_LIBELLE_READ_FAILED", $language, { cause: $labelled.error });
    };
    RETURN fn::result_ok($labelled.records[0]);
} COMMENT "Met à jour le libellé, l'activation ou l'unité de base d'un type d'unité (base_unit : unité de ce type, de facteur 1, sinon BASE_UNITE_BASE_INVALID ; clear_base_unit pour la retirer : les unités du type ne sont plus convertibles) ; la désactivation ne modifie pas les unités rattachées";
