-- ============================================================================
-- TABLE  : base_unite
-- MODULE : lyxal_base
-- RÔLE   : Référentiel universel des unités de mesure
-- ============================================================================

DEFINE TABLE OVERWRITE base_unite
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS NONE
    COMMENT "Référentiel universel des unités de mesure";

-- ----------------------------------------------------------------------------
-- Code
-- Exemple : M, CM, M2, M3, ML, KG, H, U, ENS, FORFAIT
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE code
    ON TABLE base_unite
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT
        string::len($value) >= 1
        AND string::len($value) <= 32
        AND string::is_alphanum($value)
    COMMENT "Code technique unique de l'unité";

-- ----------------------------------------------------------------------------
-- Libelle
-- Exemple : Mètre, Centimètre, Mètre carré, Kilogramme
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE libelle
    ON TABLE base_unite
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT
        string::len($value) >= 1
        AND string::len($value) <= 128
    COMMENT "Libellé de l'unité";

-- ----------------------------------------------------------------------------
-- Abreviation
-- Exemple : m, cm, m², m³, ml, kg, h
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE abreviation
    ON TABLE base_unite
    TYPE string
    VALUE string::trim($value)
    ASSERT
        string::len($value) >= 1
        AND string::len($value) <= 10
    COMMENT "Abréviation de l'unité";

-- ----------------------------------------------------------------------------
-- Type d'unite
-- Référence : base_unite_type
-- Exemple : base_unite_type:LONGUEUR, base_unite_type:SURFACE
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE type
    ON TABLE base_unite
    TYPE record<base_unite_type>
    REFERENCE
    COMMENT "Référence vers le type d'unité";

-- ----------------------------------------------------------------------------
-- Statut d'activation
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE enabled
    ON TABLE base_unite
    TYPE bool
    DEFAULT true
    COMMENT "Indique si l'unité est active pour les nouveaux documents";

-- ----------------------------------------------------------------------------
-- Appartenance au socle système
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE is_system
    ON TABLE base_unite
    TYPE bool
    DEFAULT false
    READONLY
    COMMENT "Indique si l'unité fait partie du socle système immuable";

-- ----------------------------------------------------------------------------
-- Horodatages
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE created_at
    ON TABLE base_unite
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création immuable";

DEFINE FIELD OVERWRITE updated_at
    ON TABLE base_unite
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de dernière modification";

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX OVERWRITE idx_base_unite_code
    ON TABLE base_unite
    FIELDS code
    UNIQUE;

DEFINE INDEX OVERWRITE idx_base_unite_type
    ON TABLE base_unite
    FIELDS type;

DEFINE INDEX OVERWRITE idx_base_unite_enabled
    ON TABLE base_unite
    FIELDS enabled;

DEFINE INDEX OVERWRITE idx_base_unite_is_system
    ON TABLE base_unite
    FIELDS is_system;
