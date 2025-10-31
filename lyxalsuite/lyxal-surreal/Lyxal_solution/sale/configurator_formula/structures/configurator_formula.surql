-- ============================================================================
-- TABLE : configurator_formula - Formule de configurateur
-- ============================================================================

DEFINE TABLE configurator_formula SCHEMAFULL;
    COMMENT "Formule de configurateur";

DEFINE FIELD name ON configurator_formula TYPE string;
DEFINE FIELD code ON configurator_formula TYPE string;
DEFINE FIELD formula ON configurator_formula TYPE string;
DEFINE FIELD description ON configurator_formula TYPE string;
DEFINE FIELD active ON configurator_formula TYPE bool DEFAULT true;
DEFINE FIELD created_on ON configurator_formula TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON configurator_formula TYPE datetime DEFAULT time::now();