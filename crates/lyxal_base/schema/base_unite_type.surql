-- ============================================================================
-- TABLE  : base_unite_type
-- MODULE : lyxal_base
-- RÔLE   : Types et catégories d'unités de mesure
-- ============================================================================

DEFINE TABLE OVERWRITE base_unite_type
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS NONE
    COMMENT "Types et catégories d'unités de mesure";

-- ----------------------------------------------------------------------------
-- Code
-- Exemple : LONGUEUR, SURFACE, VOLUME, MASSE, DUREE, QUANTITE
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE code
    ON TABLE base_unite_type
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT
        string::len($value) >= 1
        AND string::len($value) <= 32
        AND string::is_alphanum($value)
    COMMENT "Code technique unique du type d'unité";

-- ----------------------------------------------------------------------------
-- Libelle
-- Exemple : Longueur, Surface, Volume, Masse
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE libelle
    ON TABLE base_unite_type
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT
        string::len($value) >= 1
        AND string::len($value) <= 128
    COMMENT "Libellé du type d'unité";

-- ----------------------------------------------------------------------------
-- Statut d'activation
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE enabled
    ON TABLE base_unite_type
    TYPE bool
    DEFAULT true
    COMMENT "Indique si le type d'unité est actif";

-- ----------------------------------------------------------------------------
-- Appartenance au socle système
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE is_system
    ON TABLE base_unite_type
    TYPE bool
    DEFAULT false
    READONLY
    COMMENT "Indique si le type d'unité fait partie du socle système immuable";

-- ----------------------------------------------------------------------------
-- Horodatages
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE created_at
    ON TABLE base_unite_type
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création immuable";

DEFINE FIELD OVERWRITE updated_at
    ON TABLE base_unite_type
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de dernière modification";

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX OVERWRITE idx_base_unite_type_code
    ON TABLE base_unite_type
    FIELDS code
    UNIQUE;

DEFINE INDEX OVERWRITE idx_base_unite_type_enabled
    ON TABLE base_unite_type
    FIELDS enabled;

DEFINE INDEX OVERWRITE idx_base_unite_type_is_system
    ON TABLE base_unite_type
    FIELDS is_system;
