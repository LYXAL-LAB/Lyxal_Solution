-- =============================================================================
-- MODULE BASE SOUS MODULE PRODUCT
-- TABLE: base_product_category (ProductCategory)
-- Catégories de produits
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_product_category SCHEMAFULL
COMMENT 'Catégories de produits'
PERMISSIONS FULL;

DEFINE FIELD name ON base_product_category TYPE string;
DEFINE FIELD parentCategory ON base_product_category TYPE option<record<base_product_category>>;
DEFINE FIELD fullName ON base_product_category TYPE string;
DEFINE FIELD sequence ON base_product_category TYPE option<record<base_sequence>>;
DEFINE FIELD maxDiscount ON base_product_category TYPE option<decimal>; -- 0-100%
DEFINE FIELD growthCoef ON base_product_category TYPE decimal DEFAULT 1;

-- Index
DEFINE INDEX idx_base_product_category_name ON base_product_category FIELDS name;
DEFINE INDEX idx_base_product_category_parent ON base_product_category FIELDS parentCategory;