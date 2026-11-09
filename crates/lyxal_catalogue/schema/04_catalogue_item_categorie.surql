-- ============================================================================
-- TABLE  : catalogue_item_categorie
-- MODULE : lyxal_catalogue
-- RÔLE   : Affectation des éléments du catalogue aux catégories
-- ============================================================================

DEFINE TABLE OVERWRITE catalogue_item_categorie
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::catalogue_access({ is_custom: item.is_custom, tenant: item.tenant, action: "read" })
        FOR create, update, delete WHERE fn::catalogue_access({ is_custom: item.is_custom, tenant: item.tenant, action: "write" })
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
