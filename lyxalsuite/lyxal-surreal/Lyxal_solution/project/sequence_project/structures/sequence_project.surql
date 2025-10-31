-- ======================================================================
-- TABLE : SEQUENCE_PROJECT
-- ======================================================================
DEFINE TABLE sequence_project SCHEMAFULL
    COMMENT "Séquence pour projets";

-- Champs principaux

DEFINE FIELD created_on ON sequence_project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON sequence_project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON sequence_project TYPE int DEFAULT 0;

-- Identification

DEFINE FIELD name ON sequence_project TYPE string;
DEFINE FIELD prefix ON sequence_project TYPE string;
DEFINE FIELD suffix ON sequence_project TYPE string;

-- Configuration

DEFINE FIELD padding ON sequence_project TYPE int DEFAULT 5;
DEFINE FIELD next_num ON sequence_project TYPE int DEFAULT 1;
DEFINE FIELD increment ON sequence_project TYPE int DEFAULT 1;

-- Relations

DEFINE FIELD company_id ON sequence_project TYPE option<record<company>>;

-- Index

DEFINE INDEX idx_sequence_project_name ON sequence_project COLUMNS name;
DEFINE INDEX idx_sequence_project_company ON sequence_project COLUMNS company_id;
