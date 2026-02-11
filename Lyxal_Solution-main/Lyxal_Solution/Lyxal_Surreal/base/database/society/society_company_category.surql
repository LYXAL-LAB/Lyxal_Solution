-- =====================================================================================
-- TABLE: society_company_category
-- Description: Catégories d'entreprises selon la loi de modernisation de l'économie
-- Module: Base
-- =====================================================================================

DEFINE TABLE IF NOT EXISTS society_company_category TYPE NORMAL SCHEMAFULL
    COMMENT 'Catégories d\'entreprises (article 51 de la loi de modernisation de l\'économie)'
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete NONE;

-- =====================================================================================
-- CHAMPS
-- =====================================================================================

DEFINE FIELD IF NOT EXISTS code ON TABLE society_company_category
    TYPE string
    COMMENT 'Code de la catégorie (MIC, PME, ETI, GE)';

DEFINE FIELD IF NOT EXISTS name_i18n_key ON TABLE society_company_category
    TYPE record<i18n_key>
    COMMENT 'Clé i18n pour le nom de la catégorie';

DEFINE FIELD IF NOT EXISTS description_i18n_key ON TABLE society_company_category
    TYPE record<i18n_key>
    COMMENT 'Clé i18n pour la description détaillée';

DEFINE FIELD IF NOT EXISTS min_employees ON TABLE society_company_category
    TYPE option<int>
    COMMENT 'Nombre minimum de salariés';

DEFINE FIELD IF NOT EXISTS max_employees ON TABLE society_company_category
    TYPE option<int>
    COMMENT 'Nombre maximum de salariés (null pour illimité)';

DEFINE FIELD IF NOT EXISTS max_revenue_millions ON TABLE society_company_category
    TYPE option<int>
    COMMENT 'Chiffre d\'affaires maximum en millions d\'euros';

DEFINE FIELD IF NOT EXISTS max_balance_millions ON TABLE society_company_category
    TYPE option<int>
    COMMENT 'Total bilan maximum en millions d\'euros';

DEFINE FIELD IF NOT EXISTS sort_order ON TABLE society_company_category
    TYPE int
    DEFAULT 0
    COMMENT 'Ordre de tri (par taille croissante)';

DEFINE FIELD IF NOT EXISTS pays_reference ON TABLE society_company_category
    TYPE record<country>
    COMMENT 'Code du pays';

-- =====================================================================================
-- INDEX
-- =====================================================================================

DEFINE INDEX IF NOT EXISTS code_idx ON TABLE society_company_category FIELDS code UNIQUE
    COMMENT 'Index unique sur le code de catégorie';