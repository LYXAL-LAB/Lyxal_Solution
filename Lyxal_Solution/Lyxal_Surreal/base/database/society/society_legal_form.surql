-- =====================================================================================
-- TABLE: society_legal_form
-- Description: Formes juridiques des entreprises (hiérarchie complète à 3 niveaux)
-- Module: Base
-- =====================================================================================

DEFINE TABLE IF NOT EXISTS society_legal_form TYPE NORMAL SCHEMAFULL
    COMMENT 'Formes juridiques des entreprises (SARL, SAS, EI, etc.)'
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete NONE;

-- =====================================================================================
-- CHAMPS
-- =====================================================================================

DEFINE FIELD IF NOT EXISTS code ON TABLE society_legal_form
    TYPE string
    COMMENT 'Code officiel de la forme juridique (1, 2 ou 4 chiffres selon le niveau)';

DEFINE FIELD IF NOT EXISTS level ON TABLE society_legal_form
    TYPE record<society_legal_form_level>
    COMMENT 'Niveau hiérarchique (référence vers society_legal_form_level)';

DEFINE FIELD IF NOT EXISTS parent_code ON TABLE society_legal_form
    TYPE option<record<society_legal_form>>
    COMMENT 'Code parent dans la hiérarchie (null pour niveau I)';

DEFINE FIELD IF NOT EXISTS name_i18n_key ON TABLE society_legal_form
    TYPE record<i18n_key>
    COMMENT 'Clé i18n pour le libellé de la forme juridique';

DEFINE FIELD IF NOT EXISTS pays_reference ON TABLE society_legal_form
    TYPE record<country>
    COMMENT 'Code du pays';

-- =====================================================================================
-- INDEX
-- =====================================================================================

DEFINE INDEX IF NOT EXISTS code_idx ON TABLE society_legal_form FIELDS code UNIQUE
    COMMENT 'Index unique sur le code de forme juridique';

DEFINE INDEX IF NOT EXISTS level_idx ON TABLE society_legal_form FIELDS level
    COMMENT 'Index sur le niveau hiérarchique';

DEFINE INDEX IF NOT EXISTS parent_idx ON TABLE society_legal_form FIELDS parent_code
    COMMENT 'Index sur le code parent (pour navigation hiérarchique)';