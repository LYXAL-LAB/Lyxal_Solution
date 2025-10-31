-- ============================================================================
-- TABLE : configurator - Configurateur
-- ============================================================================

DEFINE TABLE configurator SCHEMAFULL;
    COMMENT "Configurateur";

DEFINE FIELD configurator_creator ON configurator TYPE record<configurator_creator>;
DEFINE FIELD configurator_creator_name ON configurator TYPE string;
DEFINE FIELD attributes ON configurator TYPE string;
DEFINE FIELD indicators ON configurator TYPE string;
DEFINE FIELD product ON configurator TYPE record<product>;
DEFINE FIELD configurator_version ON configurator TYPE int;
DEFINE FIELD created_on ON configurator TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON configurator TYPE datetime DEFAULT time::now();