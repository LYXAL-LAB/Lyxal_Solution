-- ============================================================================
-- TABLE  : catalogue_categorie
-- MODULE : lyxal_catalogue
-- RÔLE   : Catégories arborescentes du catalogue
-- ============================================================================

DEFINE TABLE OVERWRITE catalogue_categorie
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete NONE
    COMMENT "Catégories arborescentes du catalogue";

DEFINE FIELD OVERWRITE code ON TABLE catalogue_categorie
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT string::len($value) >= 1 AND string::len($value) <= 64
    COMMENT "Code unique de la catégorie";

DEFINE FIELD OVERWRITE libelle ON TABLE catalogue_categorie
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) >= 1 AND string::len($value) <= 128
    COMMENT "Désignation de la catégorie";

DEFINE FIELD OVERWRITE parent ON TABLE catalogue_categorie
    TYPE option<record<catalogue_categorie>>
    REFERENCE
    COMMENT "Catégorie parente hiérarchique";

DEFINE FIELD OVERWRITE ordre ON TABLE catalogue_categorie
    TYPE int
    DEFAULT 0
    COMMENT "Ordre d'affichage";

DEFINE FIELD OVERWRITE enabled ON TABLE catalogue_categorie
    TYPE bool
    DEFAULT true
    COMMENT "Statut d'activation";

DEFINE FIELD OVERWRITE is_system ON TABLE catalogue_categorie
    TYPE bool
    DEFAULT false
    READONLY
    COMMENT "Indique si la catégorie appartient au socle système";

DEFINE FIELD OVERWRITE created_at ON TABLE catalogue_categorie
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE catalogue_categorie
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de mise à jour";

DEFINE INDEX OVERWRITE idx_catalogue_categorie_code ON TABLE catalogue_categorie FIELDS code UNIQUE;
DEFINE INDEX OVERWRITE idx_catalogue_categorie_parent ON TABLE catalogue_categorie FIELDS parent;
