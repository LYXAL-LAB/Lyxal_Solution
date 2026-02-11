-- ======================================================================
-- TABLE : PROJECT_STATUS
-- ======================================================================
DEFINE TABLE project_status SCHEMAFULL
    COMMENT "Statut de projet";

-- Champs principaux
DEFINE FIELD id ON project_status TYPE record<project_status>;
DEFINE FIELD created_on ON project_status TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON project_status TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project_status TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD name ON project_status TYPE string;
DEFINE FIELD sequence ON project_status TYPE int DEFAULT 0;

-- Configuration statut
DEFINE FIELD is_completed_status ON project_status TYPE bool DEFAULT false;

-- Index
DEFINE INDEX idx_project_status_name ON project_status COLUMNS name UNIQUE;
DEFINE INDEX idx_project_status_sequence ON project_status COLUMNS sequence;