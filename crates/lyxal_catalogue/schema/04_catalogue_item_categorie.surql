-- ============================================================================
-- TABLE  : catalogue_item_categorie
-- MODULE : lyxal_catalogue
-- RÔLE   : Affectation des éléments du catalogue aux catégories
-- ============================================================================

DEFINE TABLE OVERWRITE catalogue_item_categorie
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE (
            ($token != NONE AND $token.aud = "lyxal-catalogue" AND (
                ($token.role = "catalogue_sync_agent" AND item.is_custom = false)
                OR ($token.role = "tenant_user" AND (item.is_custom = false OR (item.is_custom = true AND item.tenant_id != NONE AND $token.tenant_id != NONE AND item.tenant_id = $token.tenant_id)))
            ))
            OR ($token == NONE AND $auth != NONE AND (
                ($auth.role = "catalogue_sync_agent" AND item.is_custom = false)
                OR ($auth.role = "tenant_user" AND (item.is_custom = false OR (item.is_custom = true AND item.tenant_id != NONE AND $auth.tenant_id != NONE AND item.tenant_id = $auth.tenant_id)))
            ))
        )
        FOR create, update, delete WHERE (
            ($token != NONE AND $token.aud = "lyxal-catalogue" AND (
                ($token.role = "catalogue_sync_agent" AND "catalogue:sync:write" IN $token.scope AND item.is_custom = false)
                OR ($token.role = "tenant_user" AND item.is_custom = true AND item.tenant_id != NONE AND $token.tenant_id != NONE AND item.tenant_id = $token.tenant_id)
            ))
            OR ($token == NONE AND $auth != NONE AND (
                ($auth.role = "catalogue_sync_agent" AND "catalogue:sync:write" IN $auth.permissions AND item.is_custom = false)
                OR ($auth.role = "tenant_user" AND item.is_custom = true AND item.tenant_id != NONE AND $auth.tenant_id != NONE AND item.tenant_id = $auth.tenant_id)
            ))
        )
    COMMENT "Affectations des éléments aux catégories";

DEFINE FIELD OVERWRITE item ON TABLE catalogue_item_categorie
    TYPE record<catalogue_item>
    REFERENCE
    COMMENT "Élément du catalogue";

DEFINE FIELD OVERWRITE categorie ON TABLE catalogue_item_categorie
    TYPE record<catalogue_categorie>
    REFERENCE
    COMMENT "Catégorie assignée";

DEFINE FIELD OVERWRITE is_primary ON TABLE catalogue_item_categorie
    TYPE bool
    DEFAULT false
    COMMENT "Indique si c'est la catégorie principale de navigation";

DEFINE FIELD OVERWRITE created_at ON TABLE catalogue_item_categorie
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date d'affectation";

DEFINE INDEX OVERWRITE idx_item_cat_unique ON TABLE catalogue_item_categorie FIELDS item, categorie UNIQUE;
DEFINE INDEX OVERWRITE idx_item_cat_lookup ON TABLE catalogue_item_categorie FIELDS categorie, item;
