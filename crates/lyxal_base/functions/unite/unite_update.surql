-- ============================================================================
-- FONCTION : fn::base_unite_update
-- MODULE   : lyxal_base
-- RÔLE     : Mise à jour d'une unité, cohérente avec son type
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::base_unite_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "base_unite" } }], required: true },
            libelle: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }] },
            abreviation: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 10 } }] },
            type: { pipeline: [{ rule: "record", options: { expected_table: "base_unite_type" } }] },
            factor: { pipeline: [{ rule: "number", options: { min_value: 0.000001, max_value: 1000000 } }] },
            clear_factor: { pipeline: [{ rule: "boolean" }], default: false },
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
    IF $p.libelle == NONE AND $p.abreviation == NONE AND $p.type == NONE AND $p.factor == NONE AND !$p.clear_factor AND $p.enabled == NONE {
        RETURN fn::error_result("BASE_NO_UPDATABLE_FIELDS_PROVIDED", $language, { allowed_fields: ["libelle", "abreviation", "type", "factor", "clear_factor", "enabled"] });
    };
    -- Un facteur ne peut pas être à la fois fourni et retiré
    IF $p.factor != NONE AND $p.clear_factor {
        RETURN fn::error_result("BASE_INVALID_PARAMETERS", $language, { fields: { clear_factor: ["CORE_VALIDATION_COMBINATION"] } });
    };

    LET $existing = (SELECT * FROM ONLY $p.id);
    IF $existing == NONE {
        RETURN fn::error_result("BASE_UNITE_NOT_FOUND", $language, { id: <string> $p.id });
    };

    -- Nouveau type : il doit exister et être actif
    IF $p.type != NONE {
        LET $new_parent = (SELECT enabled FROM ONLY $p.type);
        IF $new_parent == NONE {
            RETURN fn::error_result("BASE_UNITE_TYPE_INVALID", $language, { type: <string> $p.type });
        };
        IF !$new_parent.enabled {
            RETURN fn::error_result("BASE_UNITE_TYPE_DISABLED", $language, { type: <string> $p.type });
        };
    };
    LET $type = $p.type ?? $existing.type;
    LET $enabled = $p.enabled ?? $existing.enabled;

    -- Une unité ne devient pas active sur un type inactif
    IF $p.enabled == true AND (SELECT VALUE enabled FROM ONLY $type) != true {
        RETURN fn::error_result("BASE_UNITE_TYPE_DISABLED", $language, { type: <string> $type });
    };

    -- Facteur : un facteur se rapporte à l'unité de base du type ; changer de type le retire,
    -- sauf s'il est fourni dans le même appel
    LET $factor = IF $p.clear_factor { NONE }
        ELSE IF $p.factor != NONE { <decimal> $p.factor }
        ELSE IF $type != $existing.type { NONE }
        ELSE { $existing.factor };
    -- L'unité de base d'un type garde ce type et le facteur 1
    IF (SELECT VALUE base_unit FROM ONLY $existing.type) == $existing.id {
        IF $type != $existing.type {
            RETURN fn::error_result("BASE_UNITE_BASE_INVALID", $language, { unit: <string> $p.id, type: <string> $existing.type, reason: "base_unit_type" });
        };
        IF $factor != 1dec {
            RETURN fn::error_result("BASE_UNITE_BASE_INVALID", $language, { unit: <string> $p.id, type: <string> $existing.type, reason: "base_unit_factor" });
        };
    };

    LET $updated = (UPDATE ONLY $p.id MERGE {
        abreviation: $p.abreviation ?? $existing.abreviation,
        type: $type,
        factor: $factor,
        enabled: $enabled
    });
    IF $updated == NONE {
        RETURN fn::error_result("BASE_WRITE_FORBIDDEN", $language, { table: "base_unite" });
    };
    -- Libellé : texte source de la clé lyxal_i18n ; son échec rétablit l'enregistrement
    IF $p.libelle != NONE {
        LET $failure = fn::base_libelle_update("unite", $existing.code, $p.libelle);
        IF $failure IS NOT NONE {
            UPDATE $p.id MERGE { abreviation: $existing.abreviation, type: $existing.type, factor: $existing.factor, enabled: $existing.enabled };
            RETURN fn::error_result("BASE_LIBELLE_WRITE_FAILED", $language, { cause: $failure });
        };
    };
    LET $labelled = fn::base_libelle_attach([$updated], "unite", $language);
    IF $labelled.error IS NOT NONE {
        RETURN fn::error_result("BASE_LIBELLE_READ_FAILED", $language, { cause: $labelled.error });
    };
    RETURN fn::result_ok($labelled.records[0]);
} COMMENT "Met à jour le libellé, l'abréviation, le type, le facteur de conversion (factor, ou clear_factor pour le retirer) ou l'activation d'une unité ; une unité n'est jamais rattachée à un type inactif ni réactivée sur un type inactif ; changer de type retire le facteur s'il n'est pas fourni ; l'unité de base d'un type garde ce type et le facteur 1 (BASE_UNITE_BASE_INVALID)";
