-- ============================================================================
-- FONCTION : fn::catalogue_categorie_delete
-- MODULE   : lyxal_catalogue
-- RÔLE     : Suppression sécurisée d'une catégorie
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_categorie_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_categorie" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("CATALOGUE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $cat_id = $p.id;
    LET $language = $p.language;

    LET $cat = (SELECT * FROM ONLY $cat_id);
    IF $cat == NONE {
        RETURN fn::error_result("CATALOGUE_CATEGORIE_NOT_FOUND", $language, { id: <string> $cat_id });
    };

    IF $cat.is_system == true {
        RETURN fn::error_result("CATALOGUE_CATEGORIE_SYSTEM_IMMUTABLE", $language, { id: <string> $cat_id });
    };

    -- Contrôle d'absence de sous-catégories
    LET $children_count = count(SELECT id FROM catalogue_categorie WHERE parent = $cat_id);
    IF $children_count > 0 {
        RETURN fn::error_result("CATALOGUE_CATEGORIE_HAS_CHILDREN", $language, { children_count: $children_count });
    };

    -- Contrôle d'absence d'items rattachés
    LET $items_count = count(SELECT id FROM catalogue_item_categorie WHERE categorie = $cat_id);
    IF $items_count > 0 {
        RETURN fn::error_result("CATALOGUE_CATEGORIE_IN_USE", $language, { items_count: $items_count });
    };

    LET $deleted = (DELETE ONLY $cat_id RETURN BEFORE);
    IF $deleted == NONE {
        RETURN fn::error_result("CATALOGUE_WRITE_FORBIDDEN", $language, { table: "catalogue_categorie" });
    };

    RETURN fn::result_ok({ id: <string> $cat_id, deleted: true });
} COMMENT "Supprime une catégorie si elle ne possède ni sous-catégories ni articles liés";
