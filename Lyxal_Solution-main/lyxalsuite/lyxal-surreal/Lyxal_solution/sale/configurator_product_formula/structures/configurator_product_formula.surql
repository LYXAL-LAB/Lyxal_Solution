-- ============================================================================
-- TABLE : configurator_product_formula - Formule de configurateur pour produit
-- ============================================================================

DEFINE TABLE configurator_product_formula SCHEMAFULL;
    COMMENT "Formule de configurateur pour produit";

DEFINE FIELD configurator_creator ON configurator_product_formula TYPE record<configurator_creator>;
DEFINE FIELD formula ON configurator_product_formula TYPE string;
DEFINE FIELD meta_field ON configurator_product_formula TYPE string;
DEFINE FIELD active ON configurator_product_formula TYPE bool DEFAULT true;
DEFINE FIELD created_on ON configurator_product_formula TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON configurator_product_formula TYPE datetime DEFAULT time::now();