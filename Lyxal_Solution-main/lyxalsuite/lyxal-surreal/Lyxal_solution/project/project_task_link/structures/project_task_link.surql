-- ======================================================================
-- TABLE : PROJECT_TASK_LINK
-- ======================================================================
DEFINE TABLE project_task_link SCHEMAFULL
    COMMENT "Lien entre tâches de projet";

-- Champs principaux
DEFINE FIELD id ON project_task_link TYPE record<project_task_link>;
DEFINE FIELD created_on ON project_task_link TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON project_task_link TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project_task_link TYPE int DEFAULT 0;

-- Relations
DEFINE FIELD project_task_id ON project_task_link TYPE option<record<project_task>>;
DEFINE FIELD related_task_id ON project_task_link TYPE option<record<project_task>>;
DEFINE FIELD link_type_id ON project_task_link TYPE option<record<project_task_link_type>>;

-- Index
DEFINE INDEX idx_project_task_link_task ON project_task_link COLUMNS project_task_id;
DEFINE INDEX idx_project_task_link_related ON project_task_link COLUMNS related_task_id;
DEFINE INDEX idx_project_task_link_type ON project_task_link COLUMNS link_type_id;