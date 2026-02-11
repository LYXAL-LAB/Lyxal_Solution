-- =============================================================================
-- MODULE BASE SOUS MODULE PRODUCT
-- TABLE: base_barcode_type_config (BarcodeTypeConfig)
-- Configuration des types de codes-barres
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_barcode_type_config TYPE NORMAL SCHEMAFULL
COMMENT 'Configuration des types de codes-barres'
PERMISSIONS FULL;

DEFINE FIELD name ON base_barcode_type_config TYPE string;
DEFINE FIELD code ON base_barcode_type_config TYPE string;
DEFINE FIELD serialization ON base_barcode_type_config TYPE option<string>;

-- Index
DEFINE INDEX idx_base_barcode_type_name ON base_barcode_type_config FIELDS name;
DEFINE INDEX idx_base_barcode_type_code ON base_barcode_type_config FIELDS code UNIQUE; 