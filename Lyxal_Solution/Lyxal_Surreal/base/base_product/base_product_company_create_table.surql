-- =============================================================================
-- MODULE BASE SOUS MODULE PRODUCT
-- TABLE: base_product_company (ProductCompany)
-- Configuration de produit par entreprise
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_product_company TYPE NORMAL SCHEMAFULL
COMMENT 'Configuration de produit par entreprise'
PERMISSIONS FULL;

DEFINE FIELD product ON base_product_company TYPE record<base_product>;
DEFINE FIELD company ON base_product_company TYPE record<base_company>;

-- Données spécifiques à l'entreprise
DEFINE FIELD salePrice ON base_product_company TYPE option<decimal>;
DEFINE FIELD costPrice ON base_product_company TYPE option<decimal>;

-- Index
DEFINE INDEX idx_base_product_company_unique ON base_product_company FIELDS product, company UNIQUE;