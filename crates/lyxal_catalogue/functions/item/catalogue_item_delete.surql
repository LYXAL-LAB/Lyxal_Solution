-- ============================================================================
-- FONCTION : fn::catalogue_item_delete
-- MODULE   : lyxal_catalogue
-- RÔLE     : Suppression sécurisée d'un élément du catalogue
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_item_delete($params: object) {
    LET $id = <record<catalogue_item>> $params.id;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

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
        LET $is_sync_auth = (
            ($token != NONE 
            AND $token.role = "catalogue_sync_agent" 
            AND $token.iss = "lyxal-os"
            AND $token.aud = "lyxal-catalogue"
            AND "catalogue:sync:write" IN $token.scope)
            OR
            ($auth != NONE 
            AND $auth.role = "catalogue_sync_agent" 
            AND "catalogue:sync:write" IN $auth.permissions)
        );
        IF $is_sync_auth {
            RETURN fn::error_result("CATALOGUE_ITEM_SYNC_CANNOT_ACCESS_CUSTOM", $language, {
                id: <string> $id,
                notice: "Le service catalogue_sync_agent ne doit pas modifier ou supprimer les articles privés des clients."
            });
        };
        LET $caller_role = IF $token != NONE AND $token.role != NONE { 
            string::trim($token.role) 
        } ELSE IF $auth != NONE AND $auth.role != NONE { 
            string::trim($auth.role) 
        } ELSE { 
            NONE 
        };
        IF $caller_role != "tenant_user" {
            RETURN fn::error_result("CATALOGUE_ITEM_TENANT_REQUIRED", $language, {
                id: <string> $id,
                notice: "La suppression d'un article privé exige une identité cliente avec le rôle tenant_user."
            });
        };
        IF $item.tenant_id == NONE OR string::len(string::trim($item.tenant_id)) == 0 {
            RETURN fn::error_result("CATALOGUE_ITEM_TENANT_ORPHAN", $language, {
                id: <string> $id,
                notice: "Article privé orphelin sans propriétaire vérifiable : suppression interdite."
            });
        };
        LET $caller_tenant = IF $token != NONE AND $token.tenant_id != NONE { 
            string::trim($token.tenant_id) 
        } ELSE IF $auth != NONE AND $auth.tenant_id != NONE { 
            string::trim($auth.tenant_id) 
        } ELSE { 
            NONE 
        };
        IF $caller_tenant == NONE OR string::len($caller_tenant) == 0 {
            RETURN fn::error_result("CATALOGUE_ITEM_TENANT_REQUIRED", $language, {
                id: <string> $id,
                notice: "Une identité sans tenant_id valide ne peut pas supprimer un article privé."
            });
        };
        IF $caller_tenant != $item.tenant_id {
            RETURN fn::error_result("CATALOGUE_ITEM_TENANT_FORBIDDEN", $language, {
                id: <string> $id,
                notice: "Suppression interdite : cet article privé appartient à une autre organisation."
            });
        };
    };

    -- Contrôle d'absence de compositions utilisant cet élément en composant
    LET $usage_count = (SELECT count() FROM catalogue_composition_ligne WHERE composant_item = $id)[0].count;
    IF $usage_count > 0 {
        RETURN fn::error_result("CATALOGUE_ITEM_IN_USE", $language, { usage_in_compositions: $usage_count });
    };

    -- Suppression en cascade des associations annexes
    DELETE catalogue_item_categorie WHERE item = $id;
    DELETE catalogue_variante_attribut WHERE item = $id;
    DELETE catalogue_variante WHERE item = $id;
    DELETE catalogue_relation WHERE source = $id OR cible = $id;
    DELETE ONLY $id;

    RETURN fn::result_ok({ id: <string> $id, deleted: true });
} COMMENT "Supprime un élément s'il n'est pas consommé dans des nomenclatures";
