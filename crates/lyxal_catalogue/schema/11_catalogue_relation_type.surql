-- ============================================================================
-- TABLE  : catalogue_relation_type
-- MODULE : lyxal_catalogue
-- RÔLE   : Typologie des relations entre éléments
-- ============================================================================

DEFINE TABLE OVERWRITE catalogue_relation_type
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete NONE
    COMMENT "Types de relations entre éléments (ACCESSOIRE, SUBSTITUT, SIMILAIRE, COMPATIBLE, OBLIGATOIRE)";


DEFINE FIELD OVERWRITE code ON TABLE catalogue_relation_type
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT string::len($value) >= 1 AND string::len($value) <= 32
    COMMENT "Code normalisé du type de relation";

DEFINE FIELD OVERWRITE libelle ON TABLE catalogue_relation_type
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) >= 1 AND string::len($value) <= 128
    COMMENT "Libellé usuel";

DEFINE FIELD OVERWRITE is_bidirectionnelle ON TABLE catalogue_relation_type
    TYPE bool
    DEFAULT false
    COMMENT "Indique si la relation est réciproque automatiquement";

DEFINE FIELD OVERWRITE enabled ON TABLE catalogue_relation_type
    TYPE bool
    DEFAULT true
    COMMENT "Statut d'activation";

DEFINE FIELD OVERWRITE is_system ON TABLE catalogue_relation_type
    TYPE bool
    DEFAULT false
    READONLY
    COMMENT "Indique si le type appartient au socle immuable";

DEFINE FIELD OVERWRITE created_at ON TABLE catalogue_relation_type
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE catalogue_relation_type
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de mise à jour";

DEFINE INDEX OVERWRITE idx_catalogue_relation_type_code ON TABLE catalogue_relation_type FIELDS code UNIQUE;
