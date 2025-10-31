-- ======================================================================
-- TABLE : PROJECT_CHECK_LIST_ITEM
-- ======================================================================
DEFINE TABLE project_check_list_item SCHEMAFULL
    COMMENT "Élément de check-list de projet";

-- Champs principaux
DEFINE FIELD id ON project_check_list_item TYPE record<project_check_list_item>;
DEFINE FIELD created_on ON project_check_list_item TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON project_check_list_item TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project_check_list_item TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD name ON project_check_list_item TYPE string;
DEFINE FIELD sequence ON project_check_list_item TYPE int DEFAULT 0;

-- État
DEFINE FIELD is_completed ON project_check_list_item TYPE bool DEFAULT false;

-- Relations
DEFINE FIELD project_task_id ON project_check_list_item TYPE option<record<project_task>>;
DEFINE FIELD template_id ON project_check_list_item TYPE option<record<project_check_list_template>>;

-- Index
DEFINE INDEX idx_project_check_list_item_task ON project_check_list_item COLUMNS project_task_id;
DEFINE INDEX idx_project_check_list_item_template ON project_check_list_item COLUMNS template_id;