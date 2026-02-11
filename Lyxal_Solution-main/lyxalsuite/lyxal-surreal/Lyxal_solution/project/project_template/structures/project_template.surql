-- ======================================================================
-- 13. TABLE : PROJECT_TEMPLATE
-- ======================================================================
DEFINE TABLE project_template SCHEMAFULL
    COMMENT "Modèle de projet pour la création rapide";

-- Champs principaux
DEFINE FIELD id ON project_template TYPE record<project_template>;
DEFINE FIELD created_on ON project_template TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON project_template TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project_template TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD name ON project_template TYPE string;
DEFINE FIELD full_name ON project_template TYPE string;
DEFINE FIELD code ON project_template TYPE string;
DEFINE FIELD description ON project_template TYPE string;

-- Relations de base
DEFINE FIELD team_id ON project_template TYPE option<record<team>>;
DEFINE FIELD assigned_to_id ON project_template TYPE option<record<user>>;
DEFINE FIELD company_id ON project_template TYPE option<record<company>>;

-- Configuration
DEFINE FIELD synchronize ON project_template TYPE bool DEFAULT false;
DEFINE FIELD task_status_management_select ON project_template TYPE int DEFAULT 2;

-- Relations
DEFINE FIELD project_task_category_set ON project_template TYPE array<record<project_task_category>>;
DEFINE FIELD members_user_set ON project_template TYPE array<record<user>>;
DEFINE FIELD product_set ON project_template TYPE array<record<product>>;
DEFINE FIELD project_task_status_set ON project_template TYPE array<record<task_status>>;
DEFINE FIELD task_template_set ON project_template TYPE array<record<task_template>>;

-- Relations One-to-Many
DEFINE FIELD wiki_list ON project_template TYPE array<record<wiki>>;

-- Index
DEFINE INDEX idx_project_template_name ON project_template COLUMNS name;
DEFINE INDEX idx_project_template_code ON project_template COLUMNS code UNIQUE;
DEFINE INDEX idx_project_template_company ON project_template COLUMNS company_id;