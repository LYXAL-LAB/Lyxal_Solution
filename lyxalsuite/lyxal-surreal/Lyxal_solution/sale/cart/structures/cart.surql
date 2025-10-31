-- ================================================
-- TABLE : cart - Panier de vente
-- ================================================

DEFINE TABLE cart SCHEMAFULL;
    COMMENT "Panier de vente";

DEFINE FIELD user_id ON cart TYPE record<user>;
DEFINE FIELD company ON cart TYPE record<company>;
DEFINE FIELD partner ON cart TYPE record<partner>;
DEFINE FIELD created_on ON cart TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON cart TYPE datetime DEFAULT time::now();