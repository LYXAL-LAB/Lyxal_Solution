-- =============================================================================
-- TABLE: site (Site)
-- Sites et établissements
---- A FAIRE - A IMPLEMENTER
-- VERIFIER LA TABLE QU'ELLE EST BIEN COHERENTE ET MANQUE RIEN SELON MODELE AXELOR
-- VERIFIER LES INDEXS
-- CREER LA FONCTION DE CREATION DE LA TABLE
-- CREER LES SEEDS TAGS SITE_ACTIVE, SITE_INACTIVE, SITE_INTERNAL, SITE_EXTERNAL
-- INTEGRER DANS LE DEPLOY DU SOUS MODULE
-- =============================================================================

DEFINE TABLE IF NOT EXISTS base_site TYPE NORMAL SCHEMAFULL
    COMMENT "Site de projet"
    PERMISSIONS FULL;

-- Champs principaux
DEFINE FIELD created_on ON base_site TYPE datetime DEFAULT time::now()
COMMENT 'Date de création du site';
DEFINE FIELD updated_on ON base_site TYPE datetime DEFAULT time::now()
COMMENT 'Date de mise à jour du site';

-- Identification
DEFINE FIELD name ON base_site TYPE string
COMMENT 'Nom du site';
DEFINE FIELD fullName ON base_site TYPE string
COMMENT 'Nom complet du site';

-- Relations
DEFINE FIELD partner ON base_site TYPE option<record<base_partner>>
COMMENT 'Partenaire du site';
DEFINE FIELD address ON base_site TYPE option<record<base_address>>
COMMENT 'Adresse du site';
DEFINE FIELD company ON base_site TYPE record<base_company>
COMMENT 'Entreprise du site';
DEFINE FIELD tradingName ON base_site TYPE option<record<base_trading_name>>
COMMENT 'Nom commercial du site';
DEFINE FIELD tags ON base_site TYPE array<record<system_tag>> DEFAULT []
COMMENT 'Tags (ex: site_active, site_inactive, site_internal, site_external)';

-- Index
DEFINE INDEX idx_site_name ON base_site FIELDS name;
DEFINE INDEX idx_site_company ON base_site FIELDS company_id;
DEFINE INDEX idx_site_type ON base_site FIELDS typeSelect;