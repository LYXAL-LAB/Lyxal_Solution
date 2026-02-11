-- ======================================================================
-- TABLE : PROJECT_PRIORITY
-- ======================================================================
DEFINE TABLE project_priority SCHEMAFULL
    COMMENT "Priorité de projet et tâche";

-- Champs principaux
DEFINE FIELD id ON project_priority TYPE record<project_priority>;
DEFINE FIELD created_on ON project_priority TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON project_priority TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project_priority TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD name ON project_priority TYPE string;
DEFINE FIELD technical_type_select ON project_priority TYPE string;
DEFINE FIELD sequence ON project_priority TYPE int DEFAULT 0;

-- Configuration
DEFINE FIELD is_default ON project_priority TYPE bool DEFAULT false;

-- Couleur
DEFINE FIELD color ON project_priority TYPE string;

-- Index
DEFINE INDEX idx_project_priority_name ON project_priority COLUMNS name UNIQUE;
DEFINE INDEX idx_project_priority_sequence ON project_priority COLUMNS sequence;