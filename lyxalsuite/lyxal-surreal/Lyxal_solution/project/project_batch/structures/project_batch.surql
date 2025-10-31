-- ======================================================================
-- TABLE : PROJECT_BATCH
-- ======================================================================
DEFINE TABLE project_batch SCHEMAFULL
    COMMENT "Traitement par lot des projets";

-- Champs principaux
DEFINE FIELD id ON project_batch TYPE record<project_batch>;
DEFINE FIELD created_on ON project_batch TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON project_batch TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project_batch TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD name ON project_batch TYPE string;
DEFINE FIELD description ON project_batch TYPE string;

-- Configuration
DEFINE FIELD batch_type_select ON project_batch TYPE string;
DEFINE FIELD status_select ON project_batch TYPE int DEFAULT 0;

-- Relations
DEFINE FIELD company_id ON project_batch TYPE option<record<company>>;
DEFINE FIELD project_id ON project_batch TYPE option<record<project>>;

-- Paramètres d'exécution
DEFINE FIELD scheduled_date ON batch_project TYPE datetime;
DEFINE FIELD execution_date ON batch_project TYPE datetime;
DEFINE FIELD completion_date ON batch_project TYPE datetime;

-- Résultats
DEFINE FIELD comments ON project_batch TYPE string;
DEFINE FIELD anomaly_number ON project_batch TYPE int DEFAULT 0;
DEFINE FIELD total_record ON batch_project TYPE int DEFAULT 0;
DEFINE FIELD success_record ON batch_project TYPE int DEFAULT 0;
DEFINE FIELD error_record ON batch_project TYPE int DEFAULT 0;

-- Index

DEFINE INDEX idx_project_batch_name ON project_batch COLUMNS name;
DEFINE INDEX idx_project_batch_company ON project_batch COLUMNS company_id;
DEFINE INDEX idx_project_batch_project ON project_batch COLUMNS project_id;
DEFINE INDEX idx_project_batch_status ON project_batch COLUMNS status_select;
DEFINE INDEX idx_project_batch_type ON project_batch COLUMNS batch_type_select;