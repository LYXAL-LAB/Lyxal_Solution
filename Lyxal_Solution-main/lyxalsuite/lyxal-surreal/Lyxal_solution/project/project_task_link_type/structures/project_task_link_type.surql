-- ======================================================================
-- TABLE : PROJECT_TASK_LINK_TYPE
-- ======================================================================
DEFINE TABLE project_task_link_type SCHEMAFULL
    COMMENT "Type de lien entre tâches";

-- Champs principaux
DEFINE FIELD id ON project_task_link_type TYPE record<project_task_link_type>;
DEFINE FIELD created_on ON project_task_link_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON project_task_link_type TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project_task_link_type TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD name ON project_task_link_type TYPE string;

-- Relation opposée
DEFINE FIELD opposite_link_type_id ON project_task_link_type TYPE option<record<project_task_link_type>>;

-- Index
DEFINE INDEX idx_project_task_link_type_name ON project_task_link_type COLUMNS name UNIQUE;