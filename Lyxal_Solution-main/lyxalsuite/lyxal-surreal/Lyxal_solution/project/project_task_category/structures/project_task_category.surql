-- ======================================================================
-- TABLE : PROJECT_TASK_CATEGORY
-- ======================================================================
DEFINE TABLE project_task_category SCHEMAFULL
    COMMENT "Catégorie de tâche de projet";

-- Champs principaux
DEFINE FIELD id ON project_task_category TYPE record<project_task_category>;
DEFINE FIELD created_on ON project_task_category TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON project_task_category TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project_task_category TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD name ON project_task_category TYPE string;
DEFINE FIELD description ON project_task_category TYPE string;

-- Configuration
DEFINE FIELD is_default ON project_task_category TYPE bool DEFAULT false;

-- Relations
DEFINE FIELD project_task_status_set ON project_task_category TYPE array<record<task_status>>;

-- Index
DEFINE INDEX idx_project_task_category_name ON project_task_category COLUMNS name UNIQUE;