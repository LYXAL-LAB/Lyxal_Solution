-- ============================================================================
-- FONCTION : fn::catalogue_item_get
-- MODULE   : lyxal_catalogue
-- RÔLE     : Récupération d'un élément avec projection enrichie
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_item_get($params: object) {
    LET $id_param = $params.id;
    LET $code_param = $params.code;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    LET $item = IF $id_param != NONE {
        SELECT * FROM ONLY <record<catalogue_item>> $id_param
    } ELSE IF $code_param != NONE {
        (SELECT * FROM catalogue_item WHERE code = string::uppercase(string::trim($code_param)))[0]
    } ELSE {
        NONE
    };

    IF $item == NONE {
        RETURN fn::error_result("CATALOGUE_ITEM_NOT_FOUND", $language, { id: $id_param, code: $code_param });
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
