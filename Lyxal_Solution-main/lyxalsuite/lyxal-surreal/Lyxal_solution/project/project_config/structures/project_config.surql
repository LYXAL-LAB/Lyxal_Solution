-- ======================================================================
-- TABLE : PROJECT_CONFIG
-- ======================================================================
DEFINE TABLE project_config SCHEMAFULL
    COMMENT "Configuration de projet";

-- Champs principaux
DEFINE FIELD id ON project_config TYPE record<project_config>;
DEFINE FIELD created_on ON project_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON project_config TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project_config TYPE int DEFAULT 0;

-- Configuration
DEFINE FIELD config_type_select ON project_config TYPE string;
DEFINE FIELD related_model ON project_config TYPE string;
DEFINE FIELD company_id ON project_config TYPE option<record<company>>;

-- Index
DEFINE INDEX idx_project_config_company ON project_config COLUMNS company_id;