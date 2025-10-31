-- =====================================================================================
-- TABLE: society_size_code
-- Description: Tranches d'effectifs salariés des entreprises (nomenclature)
-- Module: Base
-- =====================================================================================

DEFINE TABLE IF NOT EXISTS society_size_code TYPE NORMAL SCHEMAFULL
    COMMENT 'Tranches d\'effectifs salariés des entreprises'
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete NONE;

-- =====================================================================================
-- CHAMPS
-- =====================================================================================

DEFINE FIELD IF NOT EXISTS code ON TABLE society_size_code
    TYPE string
    COMMENT 'Code officiel INSEE de la tranche (ex: 01, 02, 11, 21, NN)';

DEFINE FIELD IF NOT EXISTS size_nomenclature_code ON TABLE society_size_code
    TYPE record<society_size_nomenclature>
    COMMENT 'Nomenclature de la taille';

DEFINE FIELD IF NOT EXISTS name_i18n_key ON TABLE society_size_code
    TYPE record<i18n_key>
    COMMENT 'Clé i18n pour le libellé de la tranche';

DEFINE FIELD IF NOT EXISTS min_employees ON TABLE society_size_code
    TYPE option<int>
    COMMENT 'Nombre minimum de salariés (null pour NN)';

DEFINE FIELD IF NOT EXISTS max_employees ON TABLE society_size_code
    TYPE option<int>
    COMMENT 'Nombre maximum de salariés (null pour illimité ou NN)';

DEFINE FIELD IF NOT EXISTS sort_order ON TABLE society_size_code
    TYPE int
    DEFAULT 0
    COMMENT 'Ordre de tri (pour affichage)';

-- =====================================================================================
-- INDEX
-- =====================================================================================

DEFINE INDEX IF NOT EXISTS code_nomenclature_idx ON TABLE society_size_code 
    FIELDS code, size_nomenclature_code UNIQUE
    COMMENT 'Index unique sur le code + nomenclature de la taille';

DEFINE INDEX IF NOT EXISTS employees_idx ON TABLE society_size_code 
    FIELDS min_employees, max_employees
    COMMENT 'Index sur les nombres de salariés';

DEFINE INDEX IF NOT EXISTS sort_idx ON TABLE society_size_code 
    FIELDS sort_order
    COMMENT 'Index sur l''ordre de tri';