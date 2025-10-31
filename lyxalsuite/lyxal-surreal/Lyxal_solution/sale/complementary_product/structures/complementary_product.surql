-- ========================================================
-- TABLE : complementary_product - Produits complémentaires
-- ========================================================

DEFINE TABLE complementary_product SCHEMAFULL;
    COMMENT "Produits complémentaires"; 
    
DEFINE FIELD name ON complementary_product TYPE string;
DEFINE FIELD code ON complementary_product TYPE string;
DEFINE FIELD product ON complementary_product TYPE record<product>;
DEFINE FIELD complementary_product_list ON complementary_product TYPE string;
DEFINE FIELD active ON complementary_product TYPE bool DEFAULT true;
DEFINE FIELD company ON complementary_product TYPE record<company>;
DEFINE FIELD created_on ON complementary_product TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON complementary_product TYPE datetime DEFAULT time::now();