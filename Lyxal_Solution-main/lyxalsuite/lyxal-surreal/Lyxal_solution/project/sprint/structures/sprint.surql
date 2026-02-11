-- ======================================================================
-- TABLE : SPRINT
-- ======================================================================
DEFINE TABLE sprint SCHEMAFULL
    COMMENT "Sprint pour gestion agile";

-- Champs principaux
DEFINE FIELD id ON sprint TYPE record<sprint>;
DEFINE FIELD created_on ON sprint TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON sprint TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON sprint TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD name ON sprint TYPE string;
DEFINE FIELD description ON sprint TYPE string;

-- Relations
DEFINE FIELD project_id ON sprint TYPE option<record<project>>;

-- Dates
DEFINE FIELD from_date ON sprint TYPE datetime;
DEFINE FIELD to_date ON sprint TYPE datetime;

-- Configuration
DEFINE FIELD sequence ON sprint TYPE int DEFAULT 0;

-- Relations avec tâches
DEFINE FIELD task_list ON sprint TYPE array<record<project_task>>;

-- Index
DEFINE INDEX idx_sprint_name ON sprint COLUMNS name;
DEFINE INDEX idx_sprint_project ON sprint COLUMNS project_id;
DEFINE INDEX idx_sprint_sequence ON sprint COLUMNS sequence;
DEFINE INDEX idx_sprint_dates ON sprint COLUMNS from_date, to_date;