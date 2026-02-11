-- ======================================================================
-- TABLE : RESOURCE_TYPE
-- ======================================================================
DEFINE TABLE resource_type SCHEMAFULL
    COMMENT "Type de ressource";

-- Champs principaux
DEFINE FIELD id ON resource_type TYPE record<resource_type>;
DEFINE FIELD created_on ON resource_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON resource_type TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON resource_type TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD name ON resource_type TYPE string;

-- Index
DEFINE INDEX idx_resource_type_name ON resource_type COLUMNS name UNIQUE;