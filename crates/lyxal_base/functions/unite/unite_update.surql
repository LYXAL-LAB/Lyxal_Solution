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
    IF $p.libelle == NONE AND $p.abreviation == NONE AND $p.type == NONE AND $p.enabled == NONE {
        RETURN fn::error_result("BASE_NO_UPDATABLE_FIELDS_PROVIDED", $language, { allowed_fields: ["libelle", "abreviation", "type", "enabled"] });
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

    LET $updated = (UPDATE ONLY $p.id MERGE {
        libelle: $p.libelle ?? $existing.libelle,
        abreviation: $p.abreviation ?? $existing.abreviation,
        type: $type,
        enabled: $enabled
    });
    IF $updated == NONE {
        RETURN fn::error_result("BASE_WRITE_FORBIDDEN", $language, { table: "base_unite" });
    };
    RETURN fn::result_ok($updated);
} COMMENT "Met à jour le libellé, l'abréviation, le type ou l'activation d'une unité ; une unité n'est jamais rattachée à un type inactif ni réactivée sur un type inactif";
