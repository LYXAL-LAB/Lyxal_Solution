-- ============================================================================
-- TABLE : configurator_so_line_formula - Formule de configurateur pour ligne 
-- de commande de vente
-- ============================================================================

DEFINE TABLE configurator_so_line_formula SCHEMAFULL;
    COMMENT "Formule de configurateur pour ligne de commande de vente";

DEFINE FIELD configurator_creator ON configurator_so_line_formula TYPE record<configurator_creator>;
DEFINE FIELD formula ON configurator_so_line_formula TYPE string;
DEFINE FIELD meta_field ON configurator_so_line_formula TYPE string;
DEFINE FIELD active ON configurator_so_line_formula TYPE bool DEFAULT true;
DEFINE FIELD created_on ON configurator_so_line_formula TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON configurator_so_line_formula TYPE datetime DEFAULT time::now();