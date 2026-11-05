-- ============================================================================
-- FONCTION : fn::catalogue_item_list
-- MODULE   : lyxal_catalogue
-- RÔLE     : Liste paginée et filtrable des éléments du catalogue
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_item_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            type: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_type" } }] },
            categorie: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_categorie" } }] },
            enabled: { pipeline: [{ rule: "boolean" }] },
            search: { pipeline: [{ rule: "optional_string", options: { max_length: 255 } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 200 } }], default: 50 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 1000000 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("CATALOGUE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, {
        fields: {
            search: { pipeline: [{ rule: "lowercase" }] }
        },
        unknown_keys: "keep"
    }, 40);
    LET $type = $p.type;
    LET $categorie = $p.categorie;
    LET $enabled = $p.enabled;
    LET $search = $p.search;
    LET $limit = $p.limit;
    LET $start = $p.start;
    LET $language = $p.language;

    -- Si filtrage par catégorie demandé, on sélectionne via catalogue_item_categorie
    LET $category_item_ids = IF $categorie != NONE {
        (SELECT VALUE item FROM catalogue_item_categorie WHERE categorie = $categorie)
    } ELSE {
        NONE
    };

    LET $records = (SELECT * FROM catalogue_item WHERE
        ($type == NONE OR type = $type) AND
        ($enabled == NONE OR enabled = $enabled) AND
        ($category_item_ids == NONE OR id IN $category_item_ids) AND
        ($search == NONE OR string::lowercase(code) CONTAINS $search OR string::lowercase(libelle) CONTAINS $search)
        ORDER BY libelle ASC LIMIT $limit START $start
    );

    RETURN fn::result_ok($records);
} COMMENT "Liste paginée des éléments du catalogue avec multi-filtres (type, catégorie, statut, recherche)";
