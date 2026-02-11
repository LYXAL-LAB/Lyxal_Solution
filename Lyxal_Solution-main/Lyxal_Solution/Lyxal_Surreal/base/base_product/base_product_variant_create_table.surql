-- =============================================================================
-- MODULE BASE SOUS MODULE PRODUCT
-- TABLE: base_product_variant (ProductVariant)
-- Variantes de produits
-- =============================================================================
DEFINE TABLE IF NOT EXISTS  base_product_variant TYPE NORMAL SCHEMAFULL
COMMENT 'Variantes de produits'
PERMISSIONS FULL;

DEFINE FIELD name ON base_product_variant TYPE string;
DEFINE FIELD parentProduct ON base_product_variant TYPE record<base_product>;
DEFINE FIELD productVariantConfig ON base_product_variant TYPE record<base_product_variant_config>;
DEFINE FIELD productVariantValueList ON base_product_variant TYPE array<record<base_product_variant_value>>;
DEFINE FIELD price ON base_product_variant TYPE option<decimal>;
DEFINE FIELD applicationDate ON base_product_variant TYPE option<datetime>;

-- Index

DEFINE INDEX idx_base_product_variant_parent ON base_product_variant FIELDS parentProduct;
DEFINE INDEX idx_base_product_variant_config ON base_product_variant FIELDS productVariantConfig;