-- =====================================================================================
-- TABLE: society_activity_nomenclature_type
-- Description: Types de nomenclatures d'activités (NAFRev2, NAFRev1, NAF1993, NAP...)
-- Module: Base
-- =====================================================================================

DEFINE TABLE IF NOT EXISTS society_activity_nomenclature_type SCHEMAFULL
    COMMENT 'Types de nomenclatures d\'activités économiques '
    PERMISSIONS FOR SELECT FULL
    FOR CREATE, UPDATE, DELETE NONE;

-- =====================================================================================
-- CHAMPS
-- =====================================================================================

DEFINE FIELD IF NOT EXISTS code ON TABLE society_activity_nomenclature_type
    TYPE string
    COMMENT 'Code unique du type de nomenclature (ex: NAFRev2, NAP)';

DEFINE FIELD IF NOT EXISTS name_i18n_key ON TABLE society_activity_nomenclature_type
    TYPE record<i18n_key>
    COMMENT 'Clé i18n pour le nom de la nomenclature';

DEFINE FIELD IF NOT EXISTS description_i18n_key ON TABLE society_activity_nomenclature_type
    TYPE record<i18n_key>
    COMMENT 'Clé i18n pour la description de la nomenclature';

DEFINE FIELD IF NOT EXISTS period_start ON TABLE society_activity_nomenclature_type
    TYPE option<int>
    COMMENT 'Année de début d\'utilisation';

DEFINE FIELD IF NOT EXISTS period_end ON TABLE society_activity_nomenclature_type
    TYPE option<int>
    COMMENT 'Année de fin d\'utilisation (null si toujours en vigueur)';

DEFINE FIELD IF NOT EXISTS is_active ON TABLE society_activity_nomenclature_type
    TYPE bool
    DEFAULT true
    COMMENT 'Indique si la nomenclature est toujours en vigueur';

DEFINE FIELD IF NOT EXISTS sort_order ON TABLE society_activity_nomenclature_type
    TYPE int
    DEFAULT 0
    COMMENT 'Ordre de tri (pour affichage)';

DEFINE FIELD IF NOT EXISTS pays_reference ON TABLE society_activity_nomenclature_type
    TYPE option<record<country>>
    COMMENT 'pays de reference du type de nomenclature'

-- =====================================================================================
-- INDEX
-- =====================================================================================

DEFINE INDEX IF NOT EXISTS code_idx ON TABLE society_activity_nomenclature_type FIELDS code UNIQUE
    COMMENT 'Index unique sur le code de nomenclature';