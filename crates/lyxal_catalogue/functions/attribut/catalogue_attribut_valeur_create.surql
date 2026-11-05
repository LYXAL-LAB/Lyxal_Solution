-- ============================================================================
-- FONCTION : fn::catalogue_attribut_valeur_create
-- MODULE   : lyxal_catalogue
-- RÔLE     : Définition d'une valeur autorisée pour un attribut typé
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_attribut_valeur_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            attribut: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_attribut" } }], required: true },
            code: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
            libelle_affichage: { pipeline: [{ rule: "optional_string", options: { max_length: 255 } }] },
            valeur_texte: { pipeline: [{ rule: "optional_string", options: { max_length: 1000 } }] },
            valeur_nombre: { pipeline: [{ rule: "number" }] },
            valeur_booleen: { pipeline: [{ rule: "boolean" }] },
            valeur_date: { pipeline: [{ rule: "datetime" }] },
            ordre: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 1000000 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("CATALOGUE_INVALID_PARAMETERS", $params.language, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, {
        fields: {
            code: { pipeline: [{ rule: "uppercase" }] }
        },
        unknown_keys: "keep"
    }, 40);
    LET $attribut_id = $p.attribut;
    LET $code = $p.code;
    LET $libelle = $p.libelle_affichage ?? $code;
    LET $valeur_texte = $p.valeur_texte;
    LET $valeur_nombre = IF $p.valeur_nombre != NONE { <decimal> $p.valeur_nombre } ELSE { NONE };
    LET $valeur_booleen = $p.valeur_booleen;
    LET $valeur_date = $p.valeur_date;
    LET $ordre = $p.ordre;
    LET $language = $p.language;

    LET $attr = (SELECT * FROM ONLY $attribut_id);
    IF $attr == NONE {
        RETURN fn::error_result("CATALOGUE_ATTRIBUT_NOT_FOUND", $language, { attribut: <string> $attribut_id });
    };

    -- Contrôle de cohérence avec le type de donnée
    IF $attr.type_donnee == "NUMBER" AND $valeur_nombre == NONE {
        RETURN fn::error_result("CATALOGUE_ATTRIBUT_TYPE_MISMATCH", $language, { expected: "NUMBER" });
    };
    IF $attr.type_donnee == "BOOLEAN" AND $valeur_booleen == NONE {
        RETURN fn::error_result("CATALOGUE_ATTRIBUT_TYPE_MISMATCH", $language, { expected: "BOOLEAN" });
    };
    IF $attr.type_donnee == "DATE" AND $valeur_date == NONE {
        RETURN fn::error_result("CATALOGUE_ATTRIBUT_TYPE_MISMATCH", $language, { expected: "DATE" });
    };

    LET $created = (CREATE catalogue_attribut_valeur CONTENT {
        attribut: $attribut_id,
        code: $code,
        valeur_texte: $valeur_texte,
        valeur_nombre: $valeur_nombre,
        valeur_booleen: $valeur_booleen,
        valeur_date: $valeur_date,
        libelle_affichage: $libelle,
        ordre: $ordre,
        enabled: true,
        created_at: time::now(),
        updated_at: time::now()
    });

    RETURN fn::result_ok($created[0]);
} COMMENT "Ajoute une valeur autorisée typée pour un attribut donné";
