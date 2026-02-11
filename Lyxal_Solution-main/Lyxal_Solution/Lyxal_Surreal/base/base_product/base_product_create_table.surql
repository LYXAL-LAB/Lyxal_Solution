-- =============================================================================
-- MODULE BASE SOUS MODULE PRODUCT
-- TABLE: base_product (Product)
-- Produits avec toutes leurs propriétés étendues
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_product SCHEMAFULL
COMMENT 'Produits avec toutes leurs propriétés étendues'
PERMISSIONS fullName;

-- Identification de base
DEFINE FIELD name ON base_product TYPE string;
DEFINE FIELD code ON base_product TYPE string;
DEFINE FIELD serialNumber ON base_product TYPE option<string>;
DEFINE FIELD description ON base_product TYPE option<string>;
DEFINE FIELD internalDescription ON base_product TYPE option<string>;

-- Media
DEFINE FIELD picture ON base_product TYPE option<record<base_meta_file>>;

-- Catégorisation
DEFINE FIELD productCategory ON base_product TYPE option<record<base_product_category>>;
DEFINE FIELD productFamily ON base_product TYPE option<record<base_product_family>>;
DEFINE FIELD unit ON base_product TYPE option<record<base_unit>>;

-- Type et configuration
DEFINE FIELD productTypeSelect ON base_product TYPE option<string>; -- service, storable
DEFINE FIELD procurementMethodSelect ON base_product TYPE option<string>; -- buy, produce, buyAndProduce
DEFINE FIELD saleSupplySelect ON base_product TYPE option<int>; -- 1=FROM_STOCK, 2=PURCHASE, 3=PRODUCE, 4=FROM_STOCK_AND_PRODUCE
DEFINE FIELD productSubTypeSelect ON base_product TYPE option<int>; -- 1=FINISHED, 2=SEMI_FINISHED, 3=COMPONENT
DEFINE FIELD inventoryTypeSelect ON base_product TYPE option<int>;

-- Statut
DEFINE FIELD isPrototype ON base_product TYPE bool DEFAULT false;
DEFINE FIELD isUnrenewed ON base_product TYPE bool DEFAULT false;
DEFINE FIELD sellable ON base_product TYPE bool DEFAULT true;
DEFINE FIELD purchasable ON base_product TYPE bool DEFAULT true;
DEFINE FIELD inAti ON base_product TYPE bool DEFAULT false;
DEFINE FIELD expense ON base_product TYPE bool DEFAULT false;

-- Prix de vente
DEFINE FIELD salePrice ON base_product TYPE option<decimal>;
DEFINE FIELD saleCurrency ON base_product TYPE option<record<base_currency>>;
DEFINE FIELD autoUpdateSalePrice ON base_product TYPE bool DEFAULT false;

-- Prix d'achat et coût
DEFINE FIELD purchasePrice ON base_product TYPE option<decimal>;
DEFINE FIELD lastPurchaseDate ON base_product TYPE option<datetime>;
DEFINE FIELD lastPurchasePrice ON base_product TYPE option<decimal>;
DEFINE FIELD purchaseCurrency ON base_product TYPE option<record<base_currency>>;
DEFINE FIELD costPrice ON base_product TYPE option<decimal>;
DEFINE FIELD costTypeSelect ON base_product TYPE int DEFAULT 1; -- 1=STANDARD, 2=LAST_PURCHASE, 3=AVERAGE, 4=LAST_PRODUCTION

-- Coefficients
DEFINE FIELD managPriceCoef ON base_product TYPE option<decimal>;
DEFINE FIELD shippingCoef ON base_product TYPE option<decimal>;
DEFINE FIELD defShipCoefByPartner ON base_product TYPE bool DEFAULT false;

-- Listes de prix
DEFINE FIELD priceListLineList ON base_product TYPE array<record<base_price_list_line>>;

-- Dates de vie
DEFINE FIELD startDate ON base_product TYPE option<datetime>;
DEFINE FIELD endDate ON base_product TYPE option<datetime>;

-- Variants
DEFINE FIELD productVariantConfig ON base_product TYPE option<record<base_product_variant_config>>;
DEFINE FIELD productVariant ON base_product TYPE option<record<base_product_variant>>;
DEFINE FIELD parentProduct ON base_product TYPE option<record<base_product>>;
DEFINE FIELD isModel ON base_product TYPE bool DEFAULT false;
DEFINE FIELD manageVariantPrice ON base_product TYPE bool DEFAULT false;

-- Fournisseur
DEFINE FIELD defaultSupplierPartner ON base_product TYPE option<record<base_partner>>;
DEFINE FIELD supplierDeliveryTime ON base_product TYPE option<int>;

-- Comptabilité
DEFINE FIELD accountManagementList ON base_product TYPE array<record<account_management>>;
DEFINE FIELD versionSelect ON base_product TYPE option<int>;

-- Code-barres
DEFINE FIELD barCode ON base_product TYPE option<record<base_meta_file>>;
DEFINE FIELD barcodeTypeConfig ON base_product TYPE option<record<base_barcode_type_config>>;
DEFINE FIELD alternativeBarcodeList ON base_product TYPE array<record<base_alternative_barcode>>;

-- Nom complet
DEFINE FIELD fullName ON base_product TYPE string;

-- Dimensions et poids
DEFINE FIELD massUnit ON base_product TYPE option<record<base_unit>>;
DEFINE FIELD grossMass ON base_product TYPE option<decimal>;
DEFINE FIELD netMass ON base_product TYPE option<decimal>;
DEFINE FIELD lengthUnit ON base_product TYPE option<record<unit>>;
DEFINE FIELD length ON base_product TYPE decimal DEFAULT 0;
DEFINE FIELD width ON base_product TYPE decimal DEFAULT 0;
DEFINE FIELD height ON base_product TYPE decimal DEFAULT 0;
DEFINE FIELD diameter ON base_product TYPE option<decimal>;
DEFINE FIELD articleVolume ON base_product TYPE option<decimal>;

-- Production
DEFINE FIELD economicManufOrderQty ON base_product TYPE option<decimal>;

-- Frais de port
DEFINE FIELD isShippingCostsProduct ON base_product TYPE bool DEFAULT false;

-- Quantités multiples
DEFINE FIELD saleProductMultipleQtyList ON base_product TYPE array<record<base_product_multiple_qty>>;
DEFINE FIELD allowToForceSaleQty ON base_product TYPE bool DEFAULT false;
DEFINE FIELD purchaseProductMultipleQtyList ON base_product TYPE array<record<base_product_multiple_qty>>;
DEFINE FIELD allowToForcePurchaseQty ON base_product TYPE bool DEFAULT false;

-- Noms commerciaux
DEFINE FIELD tradingNameSellerSet ON base_product TYPE array<record<base_trading_name>>;
DEFINE FIELD tradingNameBuyerSet ON base_product TYPE array<record<base_trading_name>>;

-- Entreprises
DEFINE FIELD productCompanyList ON base_product TYPE array<record<base_product_company>>;

-- Attributs JSON
DEFINE FIELD productAttrs ON base_product TYPE option<object>;

-- Discriminant
DEFINE FIELD dtype ON base_product TYPE option<string>;

-- Index
DEFINE INDEX idx_base_product_code ON base_product FIELDS code UNIQUE;
DEFINE INDEX idx_base_product_serial ON base_product FIELDS serialNumber UNIQUE;
DEFINE INDEX idx_base_product_name ON base_product FIELDS name;
DEFINE INDEX idx_base_product_category ON base_product FIELDS productCategory;
DEFINE INDEX idx_base_product_family ON base_product FIELDS productFamily;
DEFINE INDEX idx_base_product_sellable ON base_product FIELDS sellable;
DEFINE INDEX idx_base_product_purchasable ON base_product FIELDS purchasable;