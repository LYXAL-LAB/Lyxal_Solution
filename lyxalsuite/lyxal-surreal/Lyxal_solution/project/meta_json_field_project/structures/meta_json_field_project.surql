-- ======================================================================
-- TABLE : META_JSON_FIELD_PROJECT
-- ======================================================================
DEFINE TABLE meta_json_field_project SCHEMAFULL
    COMMENT "Champ JSON métadonnées pour projets";

-- Champs principaux

DEFINE FIELD created_on ON meta_json_field_project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON meta_json_field_project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON meta_json_field_project TYPE int DEFAULT 0;

-- Identification

DEFINE FIELD name ON meta_json_field_project TYPE string;
DEFINE FIELD title ON meta_json_field_project TYPE string;
DEFINE FIELD type ON meta_json_field_project TYPE string;

-- Configuration

DEFINE FIELD model ON meta_json_field_project TYPE string;
DEFINE FIELD model_field ON meta_json_field_project TYPE string;
DEFINE FIELD sequence ON meta_json_field_project TYPE int DEFAULT 0;

-- Paramètres

DEFINE FIELD required ON meta_json_field_project TYPE bool DEFAULT false;
DEFINE FIELD readonly ON meta_json_field_project TYPE bool DEFAULT false;
DEFINE FIELD hidden ON meta_json_field_project TYPE bool DEFAULT false;

-- Valeur par défaut

DEFINE FIELD default_value ON meta_json_field_project TYPE string;

-- Index

DEFINE INDEX idx_meta_json_field_project_name ON meta_json_field_project COLUMNS name;
DEFINE INDEX idx_meta_json_field_project_model ON meta_json_field_project COLUMNS model;
DEFINE INDEX idx_meta_json_field_project_sequence ON meta_json_field_project COLUMNS sequence;
