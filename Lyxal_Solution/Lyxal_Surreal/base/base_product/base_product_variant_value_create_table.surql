-- =============================================================================
-- MODULE BASE SOUS MODULE PRODUCT
-- TABLE: base_product_variant_value (ProductVariantValue)
-- Valeurs des variantes de produits
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_product_variant_value TYPE NORMAL SCHEMAFULL
COMMENT 'Valeurs des variantes de produits';

DEFINE FIELD name ON base_product_variant_value TYPE string;
DEFINE FIELD productVariantAttr ON base_product_variant_value TYPE record<base_product_variant_attr>;
DEFINE FIELD applicationDate ON base_product_variant_value TYPE option<datetime>;

-- Index

DEFINE INDEX idx_base_product_variant_value_attr ON base_product_variant_value FIELDS productVariantAttr;