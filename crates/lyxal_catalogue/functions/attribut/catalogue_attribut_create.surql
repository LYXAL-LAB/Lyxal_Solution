-- ============================================================================
-- FONCTION : fn::catalogue_attribut_create
-- MODULE   : lyxal_catalogue
-- RÔLE     : Définition d'une caractéristique typée au dictionnaire
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_attribut_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            code: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
            libelle: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 255 } }], required: true },
            type_donnee: { pipeline: [{ rule: "enum", options: { allowed: ["STRING", "NUMBER", "BOOLEAN", "DATE", "COLOR"], case_sensitive: true } }], required: true },
            unite: { pipeline: [{ rule: "record", options: { expected_table: "base_unite" } }] },
            is_variant_driver: { pipeline: [{ rule: "boolean" }], default: false },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("CATALOGUE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, {
        fields: {
            code: { pipeline: [{ rule: "uppercase" }] }
        },
        unknown_keys: "keep"
    }, 40);
    LET $code = $p.code;
    LET $libelle = $p.libelle;
    LET $type_donnee = $p.type_donnee;
    LET $unite_id = $p.unite;
    LET $is_variant_driver = $p.is_variant_driver;
    LET $language = $p.language;

    -- Contrôle d'unicité du code
    LET $existing = (SELECT id FROM catalogue_attribut WHERE code = $code);
    IF array::len($existing) > 0 {
        RETURN fn::error_result("CATALOGUE_ATTRIBUT_ALREADY_EXISTS", $language, { code: $code });
    };

    -- Contrôle d'unité si spécifiée
    IF $unite_id != NONE {
        -- Unité existante et utilisable (unité et type actifs), selon lyxal_base
        IF !(fn::base_unite_get({ id: <string> $unite_id }).data.usable ?? false) {
            RETURN fn::error_result("CATALOGUE_ATTRIBUT_UNITE_INVALID", $language, { unite: <string> $unite_id });
        };
    };

    LET $created = (CREATE catalogue_attribut CONTENT {
        code: $code,
        libelle: $libelle,
        type_donnee: $type_donnee,
        unite: $unite_id,
        is_variant_driver: $is_variant_driver,
        enabled: true,
        is_system: false,
        created_at: time::now(),
        updated_at: time::now()
    });
    IF array::len($created) == 0 {
        RETURN fn::error_result("CATALOGUE_WRITE_FORBIDDEN", $language, { table: "catalogue_attribut" });
    };

    RETURN fn::result_ok($created[0]);
} COMMENT "Crée une caractéristique typée dans le dictionnaire des attributs";
