-- =============================================================================
-- MODULE BASE SOUS MODULE PRODUCT
-- TABLE: base_alternative_barcode (AlternativeBarcode)
-- Codes-barres alternatifs
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_alternative_barcode TYPE NORMAL SCHEMAFULL
COMMENT 'Codes-barres alternatifs'
PERMISSIONS FULL;

DEFINE FIELD product ON base_alternative_barcode TYPE record<base_product>;
DEFINE FIELD barcode ON base_alternative_barcode TYPE string;
DEFINE FIELD barcodeTypeConfig ON base_alternative_barcode TYPE option<record<base_barcode_type_config>>;

-- Index
DEFINE INDEX idx_base_alternative_barcode_product ON base_alternative_barcode FIELDS product;
DEFINE INDEX idx_base_alternative_barcode_code ON base_alternative_barcode FIELDS barcode;