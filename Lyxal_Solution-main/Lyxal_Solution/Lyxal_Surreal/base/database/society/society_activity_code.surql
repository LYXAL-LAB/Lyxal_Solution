-- =====================================================================================
-- TABLE: society_activity_code
-- Description: Codes d'activités économiques (tous les niveaux, toutes les nomenclatures)
-- Module: Base
-- Recherche full-text sur les libellés via les relations i18n_key->i18n_translation
-- 
-- Fonctions à implémenter : get record, get list
-- 
-- Table en record : society_activity_nomenclature_type, society_activity_hierrachical_level, 
-- society_activity_code, i18n_key, country
-- =====================================================================================

DEFINE TABLE IF NOT EXISTS society_activity_code SCHEMAFULL
    COMMENT 'Codes d\'activités économique (NAF, NAP, etc.)'
    PERMISSIONS FOR SELECT FULL;

-- =====================================================================================
-- CHAMPS
-- =====================================================================================

DEFINE FIELD IF NOT EXISTS code ON TABLE society_activity_code
    TYPE string
    COMMENT 'Code d\'activité (ex: 01.11Z, 70.2C, SECTION A)';

DEFINE FIELD IF NOT EXISTS nomenclature_type ON TABLE society_activity_code
    TYPE record<society_activity_nomenclature_type>
    COMMENT 'Type de nomenclature (référence vers society_activity_nomenclature_type)';

DEFINE FIELD IF NOT EXISTS hierarchical_level ON TABLE society_activity_code
    TYPE record<society_activity_hierarchical_level>
    COMMENT 'Niveau hiérarchique (référence vers society_activity_hierarchical_level)';

DEFINE FIELD IF NOT EXISTS parent_code ON TABLE society_activity_code
    TYPE option<record<society_activity_code>>
    COMMENT 'Code parent dans la hiérarchie (null pour les sections)';

DEFINE FIELD IF NOT EXISTS libelle_long_i18n_key ON TABLE society_activity_code
    TYPE record<i18n_key>
    COMMENT 'Clé i18n pour le libellé complet';

DEFINE FIELD IF NOT EXISTS libelle_moyen_i18n_key ON TABLE society_activity_code
    TYPE option<record<i18n_key>>
    COMMENT 'Clé i18n pour le libellé moyen (65 caractères)';

DEFINE FIELD IF NOT EXISTS libelle_court_i18n_key ON TABLE society_activity_code
    TYPE option<record<i18n_key>>
    COMMENT 'Clé i18n pour le libellé court (40 caractères)';

DEFINE FIELD IF NOT EXISTS pays_reference ON TABLE society_activity_code
    TYPE option<record<country>>
    COMMENT 'pays rattaché au code'

-- =====================================================================================
-- INDEX
-- =====================================================================================

DEFINE INDEX IF NOT EXISTS code_nomenclature_idx ON TABLE society_activity_code 
    FIELDS code, nomenclature_type,pays_reference UNIQUE
    COMMENT 'Index unique sur code + nomenclature + pays_reference
    (un même code peut exister dans plusieurs nomenclatures)';

DEFINE INDEX IF NOT EXISTS nomenclature_idx ON TABLE society_activity_code 
    FIELDS nomenclature_type
    COMMENT 'Index sur le type de nomenclature';

DEFINE INDEX IF NOT EXISTS level_idx ON TABLE society_activity_code 
    FIELDS hierarchical_level
    COMMENT 'Index sur le niveau hiérarchique';

DEFINE INDEX IF NOT EXISTS parent_idx ON TABLE society_activity_code 
    FIELDS parent_code
    COMMENT 'Index sur le code parent (pour navigation hiérarchique)';

-- Note: Recherche full-text sur les libellés via les relations i18n_key->i18n_translation