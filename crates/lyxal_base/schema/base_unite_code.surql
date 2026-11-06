-- ============================================================================
-- TABLE  : base_unite_code
-- MODULE : lyxal_base
-- RÔLE   : Codes d'échange normalisés des unités de mesure
-- ============================================================================

DEFINE TABLE OVERWRITE base_unite_code
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete NONE
    COMMENT "Codes d'échange normalisés des unités (UN/ECE Rec. 20 et Rec. 21), identifiant base_unite_code:[<NORME>, <CODE>]";

-- ----------------------------------------------------------------------------
-- Norme
-- UNECE_REC20 : unités de mesure ; UNECE_REC21 : types d'emballage
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE norme
    ON TABLE base_unite_code
    TYPE string
    ASSERT $value IN ["UNECE_REC20", "UNECE_REC21"]
    COMMENT "Norme du code d'échange";

-- ----------------------------------------------------------------------------
-- Code
-- Exemple : MTK, KGM, C62, H87, RO
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE code
    ON TABLE base_unite_code
    TYPE string
    ASSERT
        string::len($value) >= 1
        AND string::len($value) <= 16
        AND string::is_alphanum($value)
        AND $value == string::uppercase($value)
    COMMENT "Code dans la norme (alphanumérique, majuscules)";

-- ----------------------------------------------------------------------------
-- Unité désignée
-- ----------------------------------------------------------------------------

DEFINE FIELD OVERWRITE unite
    ON TABLE base_unite_code
    TYPE record<base_unite>
    REFERENCE ON DELETE REJECT
    COMMENT "Unité du référentiel désignée par le code";

DEFINE FIELD OVERWRITE created_at
    ON TABLE base_unite_code
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création immuable";

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX OVERWRITE idx_base_unite_code_norme_code
    ON TABLE base_unite_code
    FIELDS norme, code
    UNIQUE;

DEFINE INDEX OVERWRITE idx_base_unite_code_code
    ON TABLE base_unite_code
    FIELDS code;

DEFINE INDEX OVERWRITE idx_base_unite_code_unite
    ON TABLE base_unite_code
    FIELDS unite;
