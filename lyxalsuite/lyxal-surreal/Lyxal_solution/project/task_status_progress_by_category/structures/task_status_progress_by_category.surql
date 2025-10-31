-- ======================================================================
-- TABLE : TASK_STATUS_PROGRESS_BY_CATEGORY
-- ======================================================================
DEFINE TABLE task_status_progress_by_category SCHEMAFULL
    COMMENT "Progression des statuts de tâches par catégorie";

-- Champs principaux
DEFINE FIELD id ON task_status_progress_by_category TYPE record<task_status_progress_by_category>;
DEFINE FIELD created_on ON task_status_progress_by_category TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON task_status_progress_by_category TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON task_status_progress_by_category TYPE int DEFAULT 0;

-- Relations
DEFINE FIELD task_status_id ON task_status_progress_by_category TYPE option<record<task_status>>;
DEFINE FIELD project_task_category_id ON task_status_progress_by_category TYPE option<record<project_task_category>>;

-- Progression
DEFINE FIELD progress ON task_status_progress_by_category TYPE decimal DEFAULT 0;

-- Index
DEFINE INDEX idx_task_status_progress_status ON task_status_progress_by_category COLUMNS task_status_id;
DEFINE INDEX idx_task_status_progress_category ON task_status_progress_by_category COLUMNS project_task_category_id;