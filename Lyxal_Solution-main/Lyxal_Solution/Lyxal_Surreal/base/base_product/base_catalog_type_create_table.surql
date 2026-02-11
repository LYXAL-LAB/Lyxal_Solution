-- Type de Catalogue
DEFINE TABLE IF NOT EXISTS base_catalog_type TYPE NORMAL SCHEMAFULL
COMMENT 'Type de catalogue produit'
PERMISSIONS FULL;

DEFINE FIELD name ON catalog_type TYPE string ASSERT $value != NONE;
DEFINE FIELD code ON catalog_type TYPE string UNIQUE;
DEFINE FIELD sequence ON catalog_type TYPE int DEFAULT 0;
DEFINE FIELD is_active ON catalog_type TYPE bool DEFAULT true;
DEFINE FIELD description ON catalog_type TYPE string;
DEFINE FIELD created_at ON catalog_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON catalog_type TYPE datetime DEFAULT time::now();

-- Index d'optimisation

DEFINE INDEX idx_catalog_type_code ON catalog_type FIELDS code;
DEFINE INDEX idx_catalog_type_active ON catalog_type FIELDS is_active;
