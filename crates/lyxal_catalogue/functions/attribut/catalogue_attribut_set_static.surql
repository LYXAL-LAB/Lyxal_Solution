-- ============================================================================
-- FONCTION : fn::catalogue_attribut_set_static
-- MODULE   : lyxal_catalogue
-- RÔLE     : Affectation d'un attribut statique à un item parent
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_attribut_set_static($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            item_id: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_item" } }], required: true },
            attribut_id: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_attribut" } }], required: true },
            valeur_id: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_attribut_valeur" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("CATALOGUE_INVALID_PARAMETERS", $params.language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $item_id = $p.item_id;
    LET $attribut_id = $p.attribut_id;
    LET $valeur_id = $p.valeur_id;
    LET $language = $p.language;

    LET $item = (SELECT * FROM ONLY $item_id);
    IF $item == NONE {
        RETURN fn::error_result("CATALOGUE_ITEM_NOT_FOUND", $language, { id: <string> $item_id });
    };

    LET $attr = (SELECT * FROM ONLY $attribut_id);
    IF $attr == NONE {
        RETURN fn::error_result("CATALOGUE_ATTRIBUT_NOT_FOUND", $language, { id: <string> $attribut_id });
    };

    LET $val = (SELECT * FROM ONLY $valeur_id);
    IF $val == NONE {
        RETURN fn::error_result("CATALOGUE_ATTRIBUT_VALEUR_NOT_FOUND", $language, { id: <string> $valeur_id });
    };

    IF $val.attribut != $attribut_id {
        RETURN fn::error_result("CATALOGUE_ATTRIBUT_VALEUR_INVALID", $language, { attribut: <string> $attribut_id, valeur: <string> $valeur_id });
    };

    -- Remplacement de l'éventuelle valeur existante
    DELETE catalogue_variante_attribut WHERE item = $item_id AND variante IS NONE AND attribut = $attribut_id;

    LET $created = (CREATE catalogue_variante_attribut CONTENT {
        item: $item_id,
        variante: NONE,
        attribut: $attribut_id,
        attribut_valeur: $valeur_id
    });

    RETURN fn::result_ok($created[0]);
} COMMENT "Affecte un attribut commun/statique à un item parent";
