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

    -- Locataire de la session : sa personnalisation et sa disponibilité accompagnent chaque article maître
    LET $tenant = fn::catalogue_caller({}).tenant;
    LET $personnalisation = IF $item.is_custom == false AND $tenant != NONE {
        (SELECT libelle_personnalise, code_interne_client, enabled FROM ONLY catalogue_item_personnalisation WHERE item = $item.id AND tenant = $tenant LIMIT 1)
    } ELSE { NONE };

    -- Projection enrichie
    LET $categories = (SELECT categorie, is_primary FROM catalogue_item_categorie WHERE item = $item.id);
    LET $variantes = (SELECT * FROM catalogue_variante WHERE item = $item.id);
    LET $attributs_statiques = (SELECT attribut, attribut_valeur FROM catalogue_variante_attribut WHERE item = $item.id AND variante IS NONE);
    LET $active_composition = (SELECT * FROM catalogue_composition WHERE parent_item = $item.id AND statut = "PUBLISHED")[0];

    RETURN fn::result_ok({
        item: $item,
        personnalisation: $personnalisation,
        disponible: $item.enabled AND ($personnalisation.enabled ?? true),
        categories: $categories,
        variantes: $variantes,
        attributs_statiques: $attributs_statiques,
        composition_active: $active_composition
    });
} COMMENT "Retourne un élément de catalogue avec ses déclinaisons et métadonnées associées ; pour un article maître, la personnalisation du locataire de la session (ou NONE) et sa disponibilité pour lui (disponible : article actif et non désactivé par ce locataire)";
