-- =============================================================================
-- TABLE: legal_category (Catégories de formes juridiques)
-- Classification hiérarchique et dynamique des formes juridiques
-- =============================================================================
DEFINE TABLE legal_category SCHEMAFULL;

-- Identification
DEFINE FIELD name ON legal_category TYPE string ASSERT $value != NONE
    COMMENT "Nom de la catégorie (ex: Société, Entreprise individuelle)";

DEFINE FIELD code ON legal_category TYPE string ASSERT $value != NONE
    COMMENT "Code unique (ex: SOCIETE, ENTREPRISE_INDIVIDUELLE)";

DEFINE FIELD description ON legal_category TYPE option<string>
    COMMENT "Description détaillée de la catégorie";

-- Hiérarchie
DEFINE FIELD parent_category ON legal_category TYPE option<record<legal_category>>
    COMMENT "Catégorie parente pour créer une hiérarchie";

DEFINE FIELD level ON legal_category TYPE int DEFAULT 1
    COMMENT "Niveau dans la hiérarchie (1=racine, 2=sous-catégorie, etc.)";

-- Statut et système
DEFINE FIELD active ON legal_category TYPE bool DEFAULT true
    COMMENT "Catégorie active";

DEFINE FIELD created_on ON legal_category TYPE datetime DEFAULT time::now()
    COMMENT "Date de création";

DEFINE FIELD updated_on ON legal_category TYPE datetime DEFAULT time::now()
    COMMENT "Date de mise à jour";

DEFINE FIELD created_by ON legal_category TYPE option<string>
    COMMENT "Créé par";

DEFINE FIELD updated_by ON legal_category TYPE option<string>
    COMMENT "Mis à jour par";

-- Index optimisés
DEFINE INDEX idx_legal_category_code ON legal_category COLUMNS code UNIQUE;
DEFINE INDEX idx_legal_category_name_parent ON legal_category COLUMNS name, parent_category UNIQUE;
DEFINE INDEX idx_legal_category_parent ON legal_category COLUMNS parent_category;
DEFINE INDEX idx_legal_category_level ON legal_category COLUMNS level;
DEFINE INDEX idx_legal_category_active ON legal_category COLUMNS active;
