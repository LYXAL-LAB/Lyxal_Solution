-- ============================================================================
-- TABLE : configurator_creator - Créateur de configurateur
-- ============================================================================

DEFINE TABLE configurator_creator SCHEMAFULL;
    COMMENT "Créateur de configurateur";

DEFINE FIELD name ON configurator_creator TYPE string;
DEFINE FIELD code ON configurator_creator TYPE string;
DEFINE FIELD description ON configurator_creator TYPE string;
DEFINE FIELD product ON configurator_creator TYPE record<product>;
DEFINE FIELD is_active ON configurator_creator TYPE bool DEFAULT true;
DEFINE FIELD use_condition ON configurator_creator TYPE string;
DEFINE FIELD script ON configurator_creator TYPE string;
DEFINE FIELD created_on ON configurator_creator TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON configurator_creator TYPE datetime DEFAULT time::now();