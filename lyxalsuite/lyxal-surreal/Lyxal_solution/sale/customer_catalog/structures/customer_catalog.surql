-- ================================================
-- TABLE : customer_catalog - Catalogue client
-- ================================================

DEFINE TABLE customer_catalog SCHEMAFULL;
    COMMENT "Catalogue client";

DEFINE FIELD product ON customer_catalog TYPE record<product>;
DEFINE FIELD customer_partner ON customer_catalog TYPE record<partner>;
DEFINE FIELD product_customer_name ON customer_catalog TYPE string;
DEFINE FIELD product_customer_code ON customer_catalog TYPE string;
DEFINE FIELD created_on ON customer_catalog TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON customer_catalog TYPE datetime DEFAULT time::now();