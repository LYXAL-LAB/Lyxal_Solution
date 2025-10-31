-- =============================================================================
-- MODULE BASE SOUS MODULE PRODUCT
-- TABLE: base_product_multiple_qty (ProductMultipleQty)
-- Quantités multiples pour vente/achat
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_product_multiple_qty TYPE NORMAL SCHEMAFULL
COMMENT 'Quantités multiples pour vente/achat'
PERMISSIONS FULL;

DEFINE FIELD saleProduct ON base_product_multiple_qty TYPE option<record<base_product>>;
DEFINE FIELD purchaseProduct ON base_product_multiple_qty TYPE option<record<base_product>>;
DEFINE FIELD multipleQty ON base_product_multiple_qty TYPE decimal;

-- Index
DEFINE INDEX idx_base_product_multiple_qty_sale ON base_product_multiple_qty FIELDS saleProduct;
DEFINE INDEX idx_base_product_multiple_qty_purchase ON base_product_multiple_qty FIELDS purchaseProduct;