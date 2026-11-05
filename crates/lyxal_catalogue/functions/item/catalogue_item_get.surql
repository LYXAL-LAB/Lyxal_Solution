-- ============================================================================
-- FONCTION : fn::catalogue_item_get
-- MODULE   : lyxal_catalogue
-- RÔLE     : Récupération d'un élément avec projection enrichie
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_item_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_item" } }] },
            code: { pipeline: [{ rule: "optional_string", options: { max_length: 64 } }] },
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
    LET $id_param = $p.id;
    LET $code_param = $p.code;
    LET $language = $p.language;

    IF $id_param == NONE AND $code_param == NONE {
        RETURN fn::error_result("CATALOGUE_INVALID_PARAMETERS", $language, { fields: { id: ["CORE_VALIDATION_REQUIRED"], code: ["CORE_VALIDATION_REQUIRED"] } });
    };

    LET $item = IF $id_param != NONE {
        SELECT * FROM ONLY $id_param
    } ELSE {
        (SELECT * FROM catalogue_item WHERE code = $code_param)[0]
    };

    IF $item == NONE {
        RETURN fn::error_result("CATALOGUE_ITEM_NOT_FOUND", $language, { id: <string> $id_param, code: $code_param });
    };

    -- Projection enrichie
    LET $categories = (SELECT categorie, is_primary FROM catalogue_item_categorie WHERE item = $item.id);
    LET $variantes = (SELECT * FROM catalogue_variante WHERE item = $item.id);
    LET $attributs_statiques = (SELECT attribut, attribut_valeur FROM catalogue_variante_attribut WHERE item = $item.id AND variante IS NONE);
    LET $active_composition = (SELECT * FROM catalogue_composition WHERE parent_item = $item.id AND statut = "PUBLISHED")[0];

    RETURN fn::result_ok({
        item: $item,
        categories: $categories,
        variantes: $variantes,
        attributs_statiques: $attributs_statiques,
        composition_active: $active_composition
    });
} COMMENT "Retourne un élément de catalogue avec ses déclinaisons et métadonnées associées";
