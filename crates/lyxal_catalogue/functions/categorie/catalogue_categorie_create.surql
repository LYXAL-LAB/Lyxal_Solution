-- ============================================================================
-- FONCTION : fn::catalogue_categorie_create
-- MODULE   : lyxal_catalogue
-- RÔLE     : Création d'une catégorie dans la taxonomie arborescente
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_categorie_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            code: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
            libelle: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 255 } }], required: true },
            parent: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_categorie" } }] },
            ordre: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 1000000 } }], default: 0 },
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
    LET $parent_id = $p.parent;
    LET $ordre = $p.ordre;
    LET $language = $p.language;

    -- Contrôle d'unicité du code
    LET $existing = (SELECT id FROM catalogue_categorie WHERE code = $code);
    IF array::len($existing) > 0 {
        RETURN fn::error_result("CATALOGUE_CATEGORIE_ALREADY_EXISTS", $language, { code: $code });
    };

    -- Contrôle du parent si spécifié
    IF $parent_id != NONE {
        LET $parent_rec = (SELECT * FROM ONLY $parent_id);
        IF $parent_rec == NONE {
            RETURN fn::error_result("CATALOGUE_CATEGORIE_NOT_FOUND", $language, { parent_id: <string> $parent_id });
        };
    };

    LET $created = (CREATE catalogue_categorie CONTENT {
        code: $code,
        libelle: $libelle,
        parent: $parent_id,
        ordre: $ordre,
        enabled: true,
        is_system: false,
        created_at: time::now(),
        updated_at: time::now()
    });

    RETURN fn::result_ok($created[0]);
} COMMENT "Crée une nouvelle catégorie arborescente";
