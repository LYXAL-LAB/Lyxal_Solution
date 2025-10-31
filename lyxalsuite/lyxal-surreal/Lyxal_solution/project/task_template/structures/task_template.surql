-- ======================================================================
-- TABLE : TASK_TEMPLATE
-- ======================================================================
DEFINE TABLE task_template SCHEMAFULL
    COMMENT "Modèle de tâche pour la création rapide";

-- Champs principaux
DEFINE FIELD id ON task_template TYPE record<task_template>;
DEFINE FIELD created_on ON task_template TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON task_template TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON task_template TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD name ON task_template TYPE string;
DEFINE FIELD description ON task_template TYPE string;

-- Planification
DEFINE FIELD delay_to_start ON task_template TYPE decimal DEFAULT 0;
DEFINE FIELD duration ON task_template TYPE decimal;
DEFINE FIELD total_planned_hrs ON task_template TYPE decimal;

-- Relations
DEFINE FIELD parent_task_template_id ON task_template TYPE option<record<task_template>>;
DEFINE FIELD assigned_to_id ON task_template TYPE option<record<user>>;
DEFINE FIELD team_id ON task_template TYPE option<record<team>>;
DEFINE FIELD project_task_category_id ON task_template TYPE option<record<project_task_category>>;
DEFINE FIELD product_id ON task_template TYPE option<record<product>>;

-- Configuration
DEFINE FIELD is_unique_task_for_multiple_quantity ON task_template TYPE bool DEFAULT true;
DEFINE FIELD qty ON task_template TYPE decimal DEFAULT 1;

-- Relations hiérarchiques
DEFINE FIELD task_template_list ON task_template TYPE array<record<task_template>>;

-- Index
DEFINE INDEX idx_task_template_name ON task_template COLUMNS name;
DEFINE INDEX idx_task_template_parent ON task_template COLUMNS parent_task_template_id;
DEFINE INDEX idx_task_template_category ON task_template COLUMNS project_task_category_id;