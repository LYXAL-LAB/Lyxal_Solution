-- ======================================================================
-- TABLE : PROJECT_TASK
-- ======================================================================
DEFINE TABLE project_task SCHEMAFULL
    COMMENT "Tâche de projet - élément de travail";

-- Champs principaux
DEFINE FIELD id ON project_task TYPE record<project_task>;
DEFINE FIELD created_on ON project_task TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON project_task TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project_task TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD name ON project_task TYPE string;
DEFINE FIELD full_name ON project_task TYPE string;
DEFINE FIELD task_id ON project_task TYPE string;
DEFINE FIELD description ON project_task TYPE string;

-- Relations principales
DEFINE FIELD project_id ON project_task TYPE option<record<project>>;
DEFINE FIELD parent_task_id ON project_task TYPE option<record<project_task>>;
DEFINE FIELD assigned_to_id ON project_task TYPE option<record<user>>;
DEFINE FIELD status_id ON project_task TYPE option<record<task_status>>;
DEFINE FIELD priority_id ON project_task TYPE option<record<project_priority>>;
DEFINE FIELD project_task_category_id ON project_task TYPE option<record<project_task_category>>;

-- Dates et planification
DEFINE FIELD task_date ON project_task TYPE datetime;
DEFINE FIELD task_deadline ON project_task TYPE datetime;
DEFINE FIELD task_duration ON project_task TYPE decimal;
DEFINE FIELD budgeted_time ON project_task TYPE decimal;
DEFINE FIELD time_spent ON project_task TYPE decimal;
DEFINE FIELD progress ON project_task TYPE decimal DEFAULT 0;

-- Hiérarchie
DEFINE FIELD sequence ON project_task TYPE int DEFAULT 0;
DEFINE FIELD task_end_date ON project_task TYPE datetime;

-- Type de tâche
DEFINE FIELD type_select ON project_task TYPE string DEFAULT "task";

-- Informations métier
DEFINE FIELD invoicing_type ON project_task TYPE int DEFAULT 0;
DEFINE FIELD unit_price ON project_task TYPE decimal;
DEFINE FIELD currency_id ON project_task TYPE option<record<currency>>;

-- Configuration
DEFINE FIELD is_unique_task_for_multiple_quantity ON project_task TYPE bool DEFAULT true;
DEFINE FIELD qty ON project_task TYPE decimal DEFAULT 1;

-- Produit associé
DEFINE FIELD product_id ON project_task TYPE option<record<product>>;

-- Relations hiérarchiques
DEFINE FIELD project_task_list ON project_task TYPE array<record<project_task>>;
DEFINE FIELD finish_to_start_task_set ON project_task TYPE array<record<project_task>>;
DEFINE FIELD start_to_start_task_set ON project_task TYPE array<record<project_task>>;
DEFINE FIELD finish_to_finish_task_set ON project_task TYPE array<record<project_task>>;
DEFINE FIELD start_to_finish_task_set ON project_task TYPE array<record<project_task>>;

-- Liens entre tâches
DEFINE FIELD project_task_link_list ON project_task TYPE array<record<project_task_link>>;

-- Check-lists
DEFINE FIELD project_check_list_item_list ON project_task TYPE array<record<project_check_list_item>>;

-- Index
DEFINE INDEX idx_project_task_project ON project_task COLUMNS project_id;
DEFINE INDEX idx_project_task_assigned_to ON project_task COLUMNS assigned_to_id;
DEFINE INDEX idx_project_task_status ON project_task COLUMNS status_id;
DEFINE INDEX idx_project_task_priority ON project_task COLUMNS priority_id;
DEFINE INDEX idx_project_task_parent ON project_task COLUMNS parent_task_id;
DEFINE INDEX idx_project_task_dates ON project_task COLUMNS task_date, task_deadline;