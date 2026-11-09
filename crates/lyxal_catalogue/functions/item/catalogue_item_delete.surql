-- ============================================================================
-- FONCTION : fn::catalogue_item_delete
-- MODULE   : lyxal_catalogue
-- RÔLE     : Suppression sécurisée d'un élément du catalogue
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_item_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_item" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("CATALOGUE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $id = $p.id;
    LET $language = $p.language;

    LET $item = (SELECT * FROM ONLY $id);
    IF $item == NONE {
        RETURN fn::error_result("CATALOGUE_ITEM_NOT_FOUND", $language, { id: <string> $id });
    };

    IF $item.is_system == true {
        RETURN fn::error_result("CATALOGUE_ITEM_SYSTEM_IMMUTABLE", $language, { id: <string> $id });
    };

    -- Protection des articles maîtres du Master Catalogue
    IF $item.is_custom == false {
        RETURN fn::error_result("CATALOGUE_ITEM_MASTER_CANNOT_BE_DELETED", $language, {
            id: <string> $id,
            notice: "Les articles synchronisés du Master Catalogue ne peuvent pas être supprimés localement."
        });
    };

    -- Contrôle d'autorisation et propriété stricte pour les articles privés
    IF $item.is_custom == true {
        LET $c = fn::catalogue_caller({});
        IF !$c.system {
            IF $c.sync {
                RETURN fn::error_result("CATALOGUE_ITEM_SYNC_CANNOT_ACCESS_CUSTOM", $language, {
                    id: <string> $id,
                    notice: "Le compte de synchronisation ne doit pas modifier ou supprimer les articles privés des clients."
                });
            };
            IF $item.tenant IS NONE {
                RETURN fn::error_result("CATALOGUE_ITEM_TENANT_ORPHAN", $language, {
                    id: <string> $id,
                    notice: "Article privé orphelin sans organisation propriétaire : suppression interdite."
                });
            };
            IF $c.tenant IS NONE {
                RETURN fn::error_result("CATALOGUE_ITEM_TENANT_REQUIRED", $language, {
                    id: <string> $id,
                    notice: "La suppression d'un article privé exige une session rattachée à une organisation."
                });
            };
            IF $c.tenant != $item.tenant {
                RETURN fn::error_result("CATALOGUE_ITEM_TENANT_FORBIDDEN", $language, {
                    id: <string> $id,
                    notice: "Suppression interdite : cet article privé appartient à une autre organisation."
                });
            };
            IF !$c.manage {
                RETURN fn::error_result("CATALOGUE_WRITE_FORBIDDEN", $language, { table: "catalogue_item", permission: "catalogue.item.manage" });
            };
        };
    };

    -- Contrôle d'absence de compositions utilisant cet élément en composant
    LET $usage_count = count(SELECT id FROM catalogue_composition_ligne WHERE composant_item = $id);
    IF $usage_count > 0 {
        RETURN fn::error_result("CATALOGUE_ITEM_IN_USE", $language, { usage_in_compositions: $usage_count });
    };

    -- Suppression en cascade des associations annexes
    DELETE catalogue_item_categorie WHERE item = $id;
    DELETE catalogue_variante_attribut WHERE item = $id;
    DELETE catalogue_variante WHERE item = $id;
    DELETE catalogue_relation WHERE source = $id OR cible = $id;
    LET $deleted = (DELETE ONLY $id RETURN BEFORE);
    IF $deleted == NONE {
        RETURN fn::error_result("CATALOGUE_WRITE_FORBIDDEN", $language, { table: "catalogue_item" });
    };

    RETURN fn::result_ok({ id: <string> $id, deleted: true });
} COMMENT "Supprime un élément s'il n'est pas consommé dans des nomenclatures";
