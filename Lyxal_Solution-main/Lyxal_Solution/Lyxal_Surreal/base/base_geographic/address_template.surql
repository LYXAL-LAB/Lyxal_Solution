-- =============================================================================
-- TABLE: address_template (AddressTemplate)
-- Modèles d'adresse par pays
-- =============================================================================
DEFINE TABLE base_address_template SCHEMAFULL;

DEFINE FIELD name ON base_address_template TYPE string;
DEFINE FIELD addressL2 ON base_address_template TYPE option<string>;
DEFINE FIELD addressL3 ON base_address_template TYPE option<string>;
DEFINE FIELD addressL4 ON base_address_template TYPE option<string>;
DEFINE FIELD addressL5 ON base_address_template TYPE option<string>;
DEFINE FIELD addressL6 ON base_address_template TYPE option<string>;
DEFINE FIELD isUsed ON base_address_template TYPE bool DEFAULT false;

-- Index
DEFINE INDEX idx_base_address_template_name ON base_address_template COLUMNS name;
