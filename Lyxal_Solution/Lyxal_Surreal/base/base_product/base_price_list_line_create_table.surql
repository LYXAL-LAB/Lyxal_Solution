-- =============================================================================
-- MODULE BASE SOUS MODULE PRODUCT
-- TABLE: base_price_list_line (PriceListLine)
-- Lignes de liste de prix
-- =============================================================================
DEFINE TABLE IF NOT EXIST base_price_list_line TYPE NORMAL SCHEMAFULL
COMMENT 'Lignes de liste de prix'
PERMISSIONS FULL;

DEFINE FIELD priceList ON base_price_list_line TYPE record<base_price_list>;
DEFINE FIELD product ON base_price_list_line TYPE option<record<base_product>>;
DEFINE FIELD productCategory ON base_price_list_line TYPE option<record<base_product_category>>;

-- Type d'action
DEFINE FIELD typeSelect ON base_price_list_line TYPE option<int>; -- 1=DISCOUNT, 2=INCREASE, 3=REPLACE
DEFINE FIELD anomalySelect ON base_price_list_line TYPE option<int>; -- 1=UNAVAILABLE_FOR_SALE, 2=NOT_RENEWED, 3=UNAVAILABLE_FOR_PURCHASE

-- Montant
DEFINE FIELD amountTypeSelect ON base_price_list_line TYPE option<int>; -- 0=NONE, 1=PERCENT, 2=FIXED
DEFINE FIELD amount ON base_price_list_line TYPE option<decimal>;

-- Quantité minimum
DEFINE FIELD minQty ON base_price_list_line TYPE option<decimal>;

-- Index
DEFINE INDEX idx_base_price_list_line_list ON base_price_list_line FIELDS priceList;
DEFINE INDEX idx_base_price_list_line_product ON base_price_list_line FIELDS product;
DEFINE INDEX idx_base_price_list_line_category ON base_price_list_line FIELDS productCategory;
DEFINE INDEX idx_base_price_list_line_product_list ON base_price_list_line FIELDS priceList, product UNIQUE;