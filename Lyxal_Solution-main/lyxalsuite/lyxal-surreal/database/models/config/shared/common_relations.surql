-- ================================================================================================
-- 🔗 CONFIGURATION SYSTÈME - RELATIONS IA-NATIVE
-- ================================================================================================
-- Module : lyxal-config
-- Description : Relations de configuration migrées depuis lyxal-base
-- Version : 1.0.0
-- Architecture : Relations intelligentes pour configuration système
-- ================================================================================================

-- ================================================================================================
-- 🌐 RELATIONS CONFIGURATION LOCALE IA-ENHANCED
-- ================================================================================================

-- Relation: company → locale_configuration (IA-Native)
DEFINE TABLE company_locale SCHEMAFULL TYPE RELATION
    COMMENT "Configuration locale entreprise avec IA d'adaptation culturelle"
    PERMISSIONS 
        FOR SELECT WHERE true
        FOR CREATE, UPDATE WHERE ($auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'localization_manager')
        FOR DELETE WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD in ON company_locale TYPE record<company> ASSERT $value != NULL;
DEFINE FIELD out ON company_locale TYPE record<locale_configuration> ASSERT $value != NULL;

-- Configuration locale
DEFINE FIELD isDefault ON company_locale TYPE bool DEFAULT false;
DEFINE FIELD usageContext ON company_locale TYPE string 
    ASSERT $value INSIDE ['UI', 'DOCUMENTS', 'COMMUNICATION', 'REPORTING', 'ALL']
    DEFAULT 'ALL';

-- Intelligence culturelle IA
DEFINE FIELD culturalAI ON company_locale TYPE object VALUE {
    culturalAdaptation: 0.0,
    businessPracticesAlignment: 0.0,
    communicationEffectiveness: 0.0,
    localizationQuality: 0.0
};

-- Métadonnées
DEFINE FIELD configuredAt ON company_locale TYPE datetime DEFAULT time::now();
DEFINE FIELD configuredBy ON company_locale TYPE record<user>;
DEFINE FIELD isActive ON company_locale TYPE bool DEFAULT true;

-- ================================================================================================
-- 🎯 CONCLUSION - RELATIONS CONFIGURATION SYSTÈME
-- ================================================================================================

-- Total : 1 relation de configuration système
-- Architecture : Relations IA-native pour configuration adaptative
-- Capacités : Intelligence culturelle et adaptation automatique
-- Performance : Optimisations pour configuration multi-locale
-- Innovation : IA d'adaptation culturelle intégrée 