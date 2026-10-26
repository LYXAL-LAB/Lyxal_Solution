-- ============================================================================
-- TABLE  : catalogue_type
-- MODULE : lyxal_catalogue
-- RÔLE   : Types fondamentaux d'éléments du catalogue
-- ============================================================================

DEFINE TABLE OVERWRITE catalogue_type
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete NONE
    COMMENT "Types fondamentaux d'éléments du catalogue (PRODUIT, SERVICE, OUVRAGE, RESSOURCE, ENSEMBLE)";


DEFINE FIELD OVERWRITE code ON TABLE catalogue_type
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT string::len($value) >= 1 AND string::len($value) <= 32
    COMMENT "Code unique normalisé du type";

DEFINE FIELD OVERWRITE libelle ON TABLE catalogue_type
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) >= 1 AND string::len($value) <= 128
    COMMENT "Libellé usuel";

DEFINE FIELD OVERWRITE description ON TABLE catalogue_type
    TYPE option<string>
    COMMENT "Description fonctionnelle";

DEFINE FIELD OVERWRITE enabled ON TABLE catalogue_type
    TYPE bool
    DEFAULT true
    COMMENT "Indique si le type est actif";

DEFINE FIELD OVERWRITE is_system ON TABLE catalogue_type
    TYPE bool
    DEFAULT false
    READONLY
    COMMENT "Indique si le type fait partie du socle immuable";

DEFINE FIELD OVERWRITE created_at ON TABLE catalogue_type
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE catalogue_type
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de dernière modification";

DEFINE INDEX OVERWRITE idx_catalogue_type_code ON TABLE catalogue_type FIELDS code UNIQUE;
