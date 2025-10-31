-- ======================================================================
--  TABLE : PROJECT_CHECK_LIST_TEMPLATE
-- ======================================================================
DEFINE TABLE project_check_list_template SCHEMAFULL
    COMMENT "Modèle de check-list de projet";

-- Champs principaux
DEFINE FIELD id ON project_check_list_template TYPE record<project_check_list_template>;
DEFINE FIELD created_on ON project_check_list_template TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON project_check_list_template TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project_check_list_template TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD name ON project_check_list_template TYPE string;
DEFINE FIELD sequence ON project_check_list_template TYPE int DEFAULT 0;

-- Configuration
DEFINE FIELD is_completed ON project_check_list_template TYPE bool DEFAULT false;

-- Index
DEFINE INDEX idx_project_check_list_template_name ON project_check_list_template COLUMNS name;