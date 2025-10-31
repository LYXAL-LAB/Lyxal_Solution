-- ==============================================================================
-- TABLE : complementary_product_selected - Produits complémentaires sélectionnés
-- ==============================================================================

DEFINE TABLE complementary_product_selected SCHEMAFULL;
    COMMENT "Produits complémentaires sélectionnés";

DEFINE FIELD sale_order_line ON complementary_product_selected TYPE record<sale_order_line>;
DEFINE FIELD product ON complementary_product_selected TYPE record<product>;
DEFINE FIELD quantity ON complementary_product_selected TYPE float DEFAULT 1;
DEFINE FIELD price ON complementary_product_selected TYPE float;
DEFINE FIELD is_selected ON complementary_product_selected TYPE bool DEFAULT false;
DEFINE FIELD created_on ON complementary_product_selected TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON complementary_product_selected TYPE datetime DEFAULT time::now();