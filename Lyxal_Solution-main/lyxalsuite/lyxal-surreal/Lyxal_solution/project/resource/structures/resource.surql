-- ======================================================================
-- TABLE : RESOURCE
-- ======================================================================
DEFINE TABLE resource SCHEMAFULL
    COMMENT "Ressource de projet";

-- Champs principaux
DEFINE FIELD id ON resource TYPE record<resource>;
DEFINE FIELD created_on ON resource TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON resource TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON resource TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD name ON resource TYPE string;
DEFINE FIELD batch_no ON resource TYPE string;

-- Relations
DEFINE FIELD resource_type_id ON resource TYPE option<record<resource_type>>;
DEFINE FIELD resource_image_id ON resource TYPE option<record<meta_file>>;

-- Index
DEFINE INDEX idx_resource_name ON resource COLUMNS name;
DEFINE INDEX idx_resource_type ON resource COLUMNS resource_type_id;
DEFINE INDEX idx_resource_batch ON resource COLUMNS batch_no;