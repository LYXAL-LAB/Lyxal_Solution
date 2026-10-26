-- ============================================================================
-- FONCTION : fn::catalogue_item_list
-- MODULE   : lyxal_catalogue
-- RÔLE     : Liste paginée et filtrable des éléments du catalogue
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_item_list($params: object) {
    LET $type = IF $params.type != NONE { <record<catalogue_type>> $params.type } ELSE { NONE };
    LET $categorie = IF $params.categorie != NONE { <record<catalogue_categorie>> $params.categorie } ELSE { NONE };
    LET $enabled = $params.enabled;
    LET $search = IF $params.search != NONE AND string::len(string::trim($params.search)) > 0 {
        string::lowercase(string::trim($params.search))
    } ELSE {
        NONE
    };
    LET $raw_limit = IF $params.limit != NONE { $params.limit } ELSE { 50 };
    LET $raw_start = IF $params.start != NONE { $params.start } ELSE { 0 };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $raw_limit < 1 OR $raw_limit > 200 OR $raw_start < 0 {
        RETURN fn::error_result("CATALOGUE_PAGINATION_INVALID", $language, { limit: $raw_limit, start: $raw_start });
    };

    LET $limit = <int> $raw_limit;
    LET $start = <int> $raw_start;

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
