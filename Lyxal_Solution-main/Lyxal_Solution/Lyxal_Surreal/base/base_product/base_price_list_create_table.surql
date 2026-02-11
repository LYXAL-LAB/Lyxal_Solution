-- =============================================================================
-- MODULE BASE SOUS MODULE PRODUCT
-- TABLE: base_price_list (PriceList)
-- Listes de prix
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_price_list TYPE NORMAL SCHEMAFULL
COMMENT 'Listes de prix'
PERMISSIONS FULL;

-- Identification
DEFINE FIELD title ON base_price_list TYPE string;
DEFINE FIELD isActive ON base_price_list TYPE bool DEFAULT false;
DEFINE FIELD comments ON base_price_list TYPE option<string>;

-- Configuration
DEFINE FIELD nonNegotiable ON base_price_list TYPE bool DEFAULT false;
DEFINE FIELD hideDiscount ON base_price_list TYPE bool DEFAULT false;
DEFINE FIELD generalDiscount ON base_price_list TYPE option<decimal>; -- 0-100%

-- Type
DEFINE FIELD typeSelect ON base_price_list TYPE int; -- 1=SALE, 2=PURCHASE, 3=CUSTOMER_CONTRACT, 4=SUPPLIER_CONTRACT
DEFINE FIELD basedOnSelect ON base_price_list TYPE option<int>; -- 1=COST_PRICE, 2=SALE_PRICE

-- Historisation
DEFINE FIELD historizedPriceList ON base_price_list TYPE array<record<base_price_list>>;
DEFINE FIELD parentPriceList ON base_price_list TYPE option<record<base_price_list>>;

-- Dates d'application
DEFINE FIELD applicationBeginDate ON base_price_list TYPE option<datetime>;
DEFINE FIELD applicationEndDate ON base_price_list TYPE option<datetime>;

-- Devise
DEFINE FIELD currency ON base_price_list TYPE record<base_currency>;

-- Lignes
DEFINE FIELD priceListLineList ON base_price_list TYPE array<record<base_price_list_line>>;

-- Index
DEFINE INDEX idx_base_price_list_title ON base_price_list FIELDS title;
DEFINE INDEX idx_base_price_list_type ON base_price_list FIELDS typeSelect;
DEFINE INDEX idx_base_price_list_active ON base_price_list FIELDS isActive;
DEFINE INDEX idx_base_price_list_currency ON base_price_list FIELDS currency;