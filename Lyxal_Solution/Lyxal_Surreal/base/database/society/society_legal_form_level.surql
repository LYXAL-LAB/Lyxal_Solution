-- =====================================================================================
-- TABLE: society_legal_form_level
-- Description: Niveaux hiérarchiques des formes juridiques (I, II, III)
-- Module: Base
-- =====================================================================================

DEFINE TABLE IF NOT EXISTS society_legal_form_level TYPE NORMAL SCHEMAFULL
    COMMENT 'Niveaux hiérarchiques des formes juridiques'
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete NONE;

-- =====================================================================================
-- CHAMPS
-- =====================================================================================

DEFINE FIELD IF NOT EXISTS code ON TABLE society_legal_form_level
    TYPE string
    COMMENT 'Code unique du niveau (ex: level_1, level_2, level_3)';

DEFINE FIELD IF NOT EXISTS name_i18n_key ON TABLE society_legal_form_level
    TYPE record<i18n_key>
    COMMENT 'Clé i18n pour le nom du niveau';

DEFINE FIELD IF NOT EXISTS description_i18n_key ON TABLE society_legal_form_level
    TYPE record<i18n_key>
    COMMENT 'Clé i18n pour la description du niveau';

DEFINE FIELD IF NOT EXISTS level_number ON TABLE society_legal_form_level
    TYPE int
    COMMENT 'Numéro du niveau (1, 2 ou 3)';

DEFINE FIELD IF NOT EXISTS code_length ON TABLE society_legal_form_level
    TYPE int
    COMMENT 'Longueur du code juridique (1, 2 ou 4 chiffres)';

DEFINE FIELD IF NOT EXISTS is_terminal ON TABLE society_legal_form_level
    TYPE bool
    DEFAULT false
    COMMENT 'Indique si c\'est le niveau terminal (utilisé dans SIRENE)';

DEFINE FIELD IF NOT EXISTS sort_order ON TABLE society_legal_form_level
    TYPE int
    DEFAULT 0
    COMMENT 'Ordre de tri (pour affichage)';

DEFINE FIELD IF NOT EXISTS pays_reference ON TABLE society_legal_form_level
    TYPE record<country>
    COMMENT 'Code du pays';

-- =====================================================================================
-- INDEX
-- =====================================================================================

DEFINE INDEX IF NOT EXISTS code_idx ON TABLE society_legal_form_level FIELDS code UNIQUE
    COMMENT 'Index unique sur le code de niveau';

DEFINE INDEX IF NOT EXISTS level_number_idx ON TABLE society_legal_form_level FIELDS level_number
    COMMENT 'Index sur le numéro de niveau';