-- =============================================================================
-- MODULE BASE SOUS MODULE PRODUCT
-- TABLE: base_product_family (ProductFamily)
-- Familles de produits (comptables)
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_product_family TYPE NORMAL SCHEMAFULL
COMMENT 'Familles de produits';

DEFINE FIELD name ON base_product_family TYPE string;

-- Configuration comptable
DEFINE FIELD accountManagementList ON base_product_family TYPE array<record<base_account_management>>;

-- Index
DEFINE INDEX idx_base_product_family_name ON base_product_family FIELDS name;