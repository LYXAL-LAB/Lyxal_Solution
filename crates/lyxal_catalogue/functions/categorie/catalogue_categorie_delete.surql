-- ============================================================================
-- FONCTION : fn::catalogue_categorie_delete
-- MODULE   : lyxal_catalogue
-- RÔLE     : Suppression sécurisée d'une catégorie
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_categorie_delete($params: object) {
    LET $cat_id = <record<catalogue_categorie>> $params.id;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    LET $cat = (SELECT * FROM ONLY $cat_id);
    IF $cat == NONE {
        RETURN fn::error_result("CATALOGUE_CATEGORIE_NOT_FOUND", $language, { id: <string> $cat_id });
    };

    IF $cat.is_system == true {
        RETURN fn::error_result("CATALOGUE_CATEGORIE_SYSTEM_IMMUTABLE", $language, { id: <string> $cat_id });
    };

    -- Contrôle d'absence de sous-catégories
    LET $children_count = (SELECT count() FROM catalogue_categorie WHERE parent = $cat_id)[0].count;
    IF $children_count > 0 {
        RETURN fn::error_result("CATALOGUE_CATEGORIE_HAS_CHILDREN", $language, { children_count: $children_count });
    };

    -- Contrôle d'absence d'items rattachés
    LET $items_count = (SELECT count() FROM catalogue_item_categorie WHERE categorie = $cat_id)[0].count;
    IF $items_count > 0 {
        RETURN fn::error_result("CATALOGUE_CATEGORIE_IN_USE", $language, { items_count: $items_count });
    };

    DELETE ONLY $cat_id;

    RETURN fn::result_ok({ id: <string> $cat_id, deleted: true });
} COMMENT "Supprime une catégorie si elle ne possède ni sous-catégories ni articles liés";
