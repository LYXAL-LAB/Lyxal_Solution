-- =============================================================================
-- MODULE BASE SOUS MODULE PRODUCT
-- TABLE: base_product_variant_config (ProductVariantConfig)
-- Configuration des variantes de produits
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_product_variant_config SCHEMAFULL
COMMENT 'Configuration des variantes de produits'
PERMISSIONS FULL;

DEFINE FIELD name ON base_product_variant_config TYPE string;
DEFINE FIELD productVariantValue1 ON base_product_variant_config TYPE option<record<base_product_variant_value>>;
DEFINE FIELD productVariantValue2 ON base_product_variant_config TYPE option<record<base_product_variant_value>>;
DEFINE FIELD productVariantValue3 ON base_product_variant_config TYPE option<record<base_product_variant_value>>;
DEFINE FIELD productVariantValue4 ON base_product_variant_config TYPE option<record<base_product_variant_value>>;
DEFINE FIELD productVariantValue5 ON base_product_variant_config TYPE option<record<base_product_variant_value>>;

-- Index

DEFINE INDEX idx_base_product_variant_config_name ON base_product_variant_config FIELDS name;