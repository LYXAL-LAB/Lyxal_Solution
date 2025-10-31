-- ======================================================================
-- 18. TABLE : PROJECT_VERSION
-- ======================================================================
DEFINE TABLE project_version SCHEMAFULL
    COMMENT "Version/Roadmap de projet";

-- Champs principaux
DEFINE FIELD id ON project_version TYPE record<project_version>;
DEFINE FIELD created_on ON project_version TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON project_version TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project_version TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD name ON project_version TYPE string;
DEFINE FIELD full_name ON project_version TYPE string;
DEFINE FIELD description ON project_version TYPE string;

-- Relations
DEFINE FIELD project_id ON project_version TYPE option<record<project>>;

-- Dates
DEFINE FIELD from_date ON project_version TYPE datetime;
DEFINE FIELD to_date ON project_version TYPE datetime;

-- Configuration
DEFINE FIELD sequence ON project_version TYPE int DEFAULT 0;

-- Index
DEFINE INDEX idx_project_version_name ON project_version COLUMNS name;
DEFINE INDEX idx_project_version_project ON project_version COLUMNS project_id;
DEFINE INDEX idx_project_version_sequence ON project_version COLUMNS sequence;
DEFINE INDEX idx_project_version_dates ON project_version COLUMNS from_date, to_date;