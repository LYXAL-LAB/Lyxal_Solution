-- Catalogue
DEFINE TABLE IF NOT EXISTS base_catalog TYPE NORMAL SCHEMAFULL
COMMENT 'Catalogue de produits'
PERMISSIONS FULL;

DEFINE FIELD name ON base_catalog TYPE string;
DEFINE FIELD code ON base_catalog TYPE string;
DEFINE FIELD catalog_type ON base_catalog TYPE record<base_catalog_type>;
DEFINE FIELD description ON base_catalog TYPE string;
DEFINE FIELD is_active ON base_catalog TYPE bool DEFAULT true;
DEFINE FIELD start_date ON base_catalog TYPE datetime;
DEFINE FIELD end_date ON base_catalog TYPE datetime;
DEFINE FIELD currency ON base_catalog TYPE record<base_currency>;
DEFINE FIELD company ON base_catalog TYPE record<base_company>;
DEFINE FIELD pdf_file ON base_catalog TYPE record<base_meta_file>;
DEFINE FIELD image ON base_catalog TYPE record<base_meta_file>;
DEFINE FIELD partner_set ON base_catalog TYPE array<record<base_partner>>;
DEFINE FIELD product_set ON base_catalog TYPE array<record<base_product>>;
DEFINE FIELD is_public ON base_catalog TYPE bool DEFAULT false;
DEFINE FIELD sequence ON base_catalog TYPE int DEFAULT 0;
DEFINE FIELD created_at ON base_catalog TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_catalog TYPE datetime DEFAULT time::now();

-- Index d'optimisation

DEFINE INDEX idx_base_catalog_code ON base_catalog FIELDS code;
DEFINE INDEX idx_base_catalog_type ON base_catalog FIELDS catalog_type;
DEFINE INDEX idx_base_catalog_active ON base_catalog FIELDS is_active;
DEFINE INDEX idx_base_catalog_date_range ON base_catalog FIELDS start_date, end_date;