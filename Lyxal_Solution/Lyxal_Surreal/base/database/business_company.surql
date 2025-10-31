-- =====================================================================================
-- TABLE: business_company
-- Description: Entreprises françaises (Unités légales SIRENE)
-- Module: Business
-- Source: INSEE - Stock des unités légales
-- =====================================================================================

DEFINE TABLE IF NOT EXISTS business_company SCHEMAFULL
    COMMENT 'Entreprises françaises (unités légales du répertoire SIRENE)';

-- =====================================================================================
-- IDENTIFIANTS
-- =====================================================================================

DEFINE FIELD IF NOT EXISTS identifiers ON TABLE business_company TYPE object
    COMMENT 'Identifiants officiels de l\'entreprise';

DEFINE FIELD IF NOT EXISTS identifiers.siren ON TABLE business_company
    TYPE string
    ASSERT $value = /^[0-9]{9}$/
    COMMENT 'Numéro SIREN (9 chiffres) - Identifiant unique';

DEFINE FIELD IF NOT EXISTS identifiers.nic_siege ON TABLE business_company
    TYPE string
    ASSERT $value = /^[0-9]{5}$/
    COMMENT 'NIC du siège social (5 chiffres)';

DEFINE FIELD IF NOT EXISTS identifiers.siret_siege ON TABLE business_company
    TYPE string
    COMMENT 'SIRET du siège (SIREN + NIC) - calculé';

DEFINE FIELD IF NOT EXISTS identifiers.association_id ON TABLE business_company
    TYPE option<string>
    COMMENT 'Identifiant RNA pour les associations (ex: W751234567)';

-- =====================================================================================
-- INFORMATIONS LÉGALES
-- =====================================================================================

DEFINE FIELD IF NOT EXISTS legal ON TABLE business_company TYPE object
    COMMENT 'Informations juridiques et administratives';

DEFINE FIELD IF NOT EXISTS legal.form ON TABLE business_company
    TYPE option<record<business_legal_form>>
    COMMENT 'Forme juridique (niveau III uniquement)';

DEFINE FIELD IF NOT EXISTS legal.creation_date ON TABLE business_company
    TYPE option<datetime>
    COMMENT 'Date de création de l\'unité légale';

DEFINE FIELD IF NOT EXISTS legal.administrative_status ON TABLE business_company
    TYPE option<record<business_administrative_status>>
    COMMENT 'État administratif (Active/Cessée)';

DEFINE FIELD IF NOT EXISTS legal.is_employer ON TABLE business_company
    TYPE option<bool>
    COMMENT 'Caractère employeur (O/N)';

DEFINE FIELD IF NOT EXISTS legal.is_social_economy ON TABLE business_company
    TYPE option<bool>
    COMMENT 'Appartenance à l\'Économie Sociale et Solidaire (ESS)';

DEFINE FIELD IF NOT EXISTS legal.is_mission_company ON TABLE business_company
    TYPE option<bool>
    COMMENT 'Société à mission (O/N)';

-- =====================================================================================
-- ACTIVITÉ ÉCONOMIQUE
-- =====================================================================================

DEFINE FIELD IF NOT EXISTS activity ON TABLE business_company TYPE object
    COMMENT 'Activité économique principale';

DEFINE FIELD IF NOT EXISTS activity.code ON TABLE business_company
    TYPE option<record<business_activity_code>>
    COMMENT 'Code d\'activité principale (APE/NAF)';

DEFINE FIELD IF NOT EXISTS activity.nomenclature ON TABLE business_company
    TYPE option<record<business_nomenclature_type>>
    COMMENT 'Type de nomenclature utilisée (NAFRev2, NAFRev1, etc.)';

-- =====================================================================================
-- EFFECTIFS
-- =====================================================================================

DEFINE FIELD IF NOT EXISTS workforce ON TABLE business_company TYPE object
    COMMENT 'Effectifs salariés';

DEFINE FIELD IF NOT EXISTS workforce.range ON TABLE business_company
    TYPE option<record<business_workforce_range>>
    COMMENT 'Tranche d\'effectifs (TEFET)';

DEFINE FIELD IF NOT EXISTS workforce.year ON TABLE business_company
    TYPE option<int>
    COMMENT 'Année de référence des effectifs';

-- =====================================================================================
-- CATÉGORISATION
-- =====================================================================================

DEFINE FIELD IF NOT EXISTS classification ON TABLE business_company TYPE object
    COMMENT 'Catégorisation de l\'entreprise';

DEFINE FIELD IF NOT EXISTS classification.category ON TABLE business_company
    TYPE option<record<business_company_category>>
    COMMENT 'Catégorie d\'entreprise (MIC, PME, ETI, GE)';

DEFINE FIELD IF NOT EXISTS classification.category_year ON TABLE business_company
    TYPE option<int>
    COMMENT 'Année de référence de la catégorie';

-- =====================================================================================
-- DÉNOMINATION (Personnes morales)
-- =====================================================================================

DEFINE FIELD IF NOT EXISTS names ON TABLE business_company TYPE object
    COMMENT 'Dénominations de l\'entreprise (personnes morales)';

DEFINE FIELD IF NOT EXISTS names.official ON TABLE business_company
    TYPE option<string>
    COMMENT 'Dénomination officielle';

DEFINE FIELD IF NOT EXISTS names.usual_1 ON TABLE business_company
    TYPE option<string>
    COMMENT 'Dénomination usuelle 1 (enseigne principale)';

DEFINE FIELD IF NOT EXISTS names.usual_2 ON TABLE business_company
    TYPE option<string>
    COMMENT 'Dénomination usuelle 2 (enseigne secondaire)';

DEFINE FIELD IF NOT EXISTS names.usual_3 ON TABLE business_company
    TYPE option<string>
    COMMENT 'Dénomination usuelle 3 (enseigne secondaire)';

DEFINE FIELD IF NOT EXISTS names.sigle ON TABLE business_company
    TYPE option<string>
    COMMENT 'Sigle de l\'entreprise (acronyme)';

-- =====================================================================================
-- PERSONNE (Entrepreneurs individuels uniquement)
-- =====================================================================================

DEFINE FIELD IF NOT EXISTS individual ON TABLE business_company TYPE option<object>
    COMMENT 'Informations sur l\'entrepreneur individuel (null pour personnes morales)';

DEFINE FIELD IF NOT EXISTS individual.gender ON TABLE business_company
    TYPE option<record<business_gender>>
    COMMENT 'Genre de l\'entrepreneur (M/F/ND)';

DEFINE FIELD IF NOT EXISTS individual.last_name ON TABLE business_company
    TYPE option<string>
    COMMENT 'Nom de famille';

DEFINE FIELD IF NOT EXISTS individual.last_name_usage ON TABLE business_company
    TYPE option<string>
    COMMENT 'Nom d\'usage (nom marital)';

DEFINE FIELD IF NOT EXISTS individual.first_name_1 ON TABLE business_company
    TYPE option<string>
    COMMENT 'Prénom 1';

DEFINE FIELD IF NOT EXISTS individual.first_name_2 ON TABLE business_company
    TYPE option<string>
    COMMENT 'Prénom 2';

DEFINE FIELD IF NOT EXISTS individual.first_name_3 ON TABLE business_company
    TYPE option<string>
    COMMENT 'Prénom 3';

DEFINE FIELD IF NOT EXISTS individual.first_name_4 ON TABLE business_company
    TYPE option<string>
    COMMENT 'Prénom 4';

DEFINE FIELD IF NOT EXISTS individual.usual_first_name ON TABLE business_company
    TYPE option<string>
    COMMENT 'Prénom usuel';

DEFINE FIELD IF NOT EXISTS individual.pseudonym ON TABLE business_company
    TYPE option<string>
    COMMENT 'Pseudonyme (nom de scène, nom d\'artiste)';

-- =====================================================================================
-- DIFFUSION
-- =====================================================================================

DEFINE FIELD IF NOT EXISTS diffusion ON TABLE business_company TYPE object
    COMMENT 'Paramètres de diffusion publique';

DEFINE FIELD IF NOT EXISTS diffusion.status ON TABLE business_company
    TYPE string
    DEFAULT 'O'
    COMMENT 'Statut de diffusion (O=Oui, P=Partielle)';

DEFINE FIELD IF NOT EXISTS diffusion.is_purged ON TABLE business_company
    TYPE bool
    DEFAULT false
    COMMENT 'Unité purgée (données supprimées)';

-- =====================================================================================
-- MÉTADONNÉES
-- =====================================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE business_company TYPE object
    COMMENT 'Métadonnées de gestion';

DEFINE FIELD IF NOT EXISTS metadata.period_start_date ON TABLE business_company
    TYPE option<datetime>
    COMMENT 'Date de début de la période (historisation)';

DEFINE FIELD IF NOT EXISTS metadata.last_update ON TABLE business_company
    TYPE option<datetime>
    COMMENT 'Date du dernier traitement INSEE';

DEFINE FIELD IF NOT EXISTS metadata.period_count ON TABLE business_company
    TYPE int
    DEFAULT 1
    COMMENT 'Nombre de périodes historiques';

DEFINE FIELD IF NOT EXISTS metadata.import_date ON TABLE business_company
    TYPE datetime
    DEFAULT time::now()
    COMMENT 'Date d\'import dans SurrealDB';

-- =====================================================================================
-- INDEX
-- =====================================================================================

DEFINE INDEX IF NOT EXISTS siren_idx ON TABLE business_company
    COLUMNS identifiers.siren UNIQUE
    COMMENT 'Index unique sur le SIREN';

DEFINE INDEX IF NOT EXISTS siret_siege_idx ON TABLE business_company
    COLUMNS identifiers.siret_siege
    COMMENT 'Index sur le SIRET du siège';

DEFINE INDEX IF NOT EXISTS legal_form_idx ON TABLE business_company
    COLUMNS legal.form
    COMMENT 'Index sur la forme juridique';

DEFINE INDEX IF NOT EXISTS activity_code_idx ON TABLE business_company
    COLUMNS activity.code
    COMMENT 'Index sur le code d\'activité';

DEFINE INDEX IF NOT EXISTS admin_status_idx ON TABLE business_company
    COLUMNS legal.administrative_status
    COMMENT 'Index sur le statut administratif (pour filtrer actives/cessées)';

DEFINE INDEX IF NOT EXISTS category_idx ON TABLE business_company
    COLUMNS classification.category
    COMMENT 'Index sur la catégorie d\'entreprise';

-- =====================================================================================
-- PERMISSIONS (à adapter selon vos besoins)
-- =====================================================================================

-- DEFINE ACCESS POLICY read_all ON TABLE business_company
--     FOR select WHERE true;

-- DEFINE ACCESS POLICY read_active_only ON TABLE business_company
--     FOR select WHERE legal.administrative_status = business_administrative_status:status_a;

