-- =============================================================================
-- TABLE: base_agency (Agence)
-- Agences
---- A FAIRE - A IMPLEMENTER
-- VERIFIER LA TABLE QU'ELLE EST BIEN COHERENTE ET MANQUE RIEN SELON MODELE AXELOR
-- VERIFIER LES INDEXS
-- CREER LA FONCTION DE CREATION DE LA TABLE
-- CREER LES SEEDS TAGS AGENCY_ACTIVE, AGENCY_INACTIVE
-- INTEGRER DANS LE DEPLOY DU SOUS MODULE
-- =============================================================================

-- Agence 
DEFINE TABLE IF NOT EXISTS base_agency TYPE NORMAL SCHEMAFULL
COMMENT 'Agence'
PERMISSIONS FULL;

-- FIELDS
DEFINE FIELD name ON base_agency TYPE string
COMMENT 'Nom de l\'agence';
DEFINE FIELD code ON base_agency TYPE string
COMMENT 'Code de l\'agence';
DEFINE FIELD address ON base_agency TYPE record<base_address>
COMMENT 'Adresse de l\'agence';
DEFINE FIELD phone ON base_agency TYPE string
COMMENT 'Téléphone de l\'agence';
DEFINE FIELD email ON base_agency TYPE string
COMMENT 'Email de l\'agence';
DEFINE FIELD manager ON base_agency TYPE record<base_user>
COMMENT 'Responsable de l\'agence';
DEFINE FIELD company ON base_agency TYPE record<base_company>
COMMENT 'Entreprise de l\'agence';
DEFINE FIELD description ON base_agency TYPE string
COMMENT 'Description de l\'agence';
DEFINE FIELD territory ON base_agency TYPE record<base_territory>
COMMENT 'Territoire de l\'agence';
DEFINE FIELD tags ON base_agency TYPE array<record<system_tag>> DEFAULT []
COMMENT 'Tags (ex: agency_active, agency_inactive)';
DEFINE FIELD created_at ON base_agency TYPE datetime DEFAULT time::now()
COMMENT 'Date de création de l\'agence';
DEFINE FIELD updated_at ON base_agency TYPE datetime DEFAULT time::now()
COMMENT 'Date de mise à jour de l\'agence';

-- Index d'optimisation

DEFINE INDEX idx_agency_code ON base_agency FIELDS code;
DEFINE INDEX idx_agency_manager ON base_agency FIELDS manager;