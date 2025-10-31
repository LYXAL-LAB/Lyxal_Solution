-- ================================================
-- TABLE : cart_line - Ligne de panier de vente
-- ================================================

DEFINE TABLE cart_line SCHEMAFULL;
    COMMENT "Ligne de panier de vente";
    
DEFINE FIELD cart ON cart_line TYPE record<cart>;
DEFINE FIELD product ON cart_line TYPE record<product>;
DEFINE FIELD product_name ON cart_line TYPE string;
DEFINE FIELD quantity ON cart_line TYPE float DEFAULT 1;
DEFINE FIELD unit ON cart_line TYPE record<unit>;
DEFINE FIELD price ON cart_line TYPE float;
DEFINE FIELD description ON cart_line TYPE string;
DEFINE FIELD created_on ON cart_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON cart_line TYPE datetime DEFAULT time::now();