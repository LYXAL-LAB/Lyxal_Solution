-- =============================================================================
-- TABLE: registration_number_template (RegistrationNumberTemplate)
-- Modèles de numéros d'enregistrement par pays
-- =============================================================================
DEFINE TABLE base_registration_number_template SCHEMAFULL;

DEFINE FIELD name ON base_registration_number_template TYPE string;
DEFINE FIELD pattern ON base_registration_number_template TYPE option<string>;
DEFINE FIELD isUsedForSiren ON base_registration_number_template TYPE bool DEFAULT false;
DEFINE FIELD isUsedForTax ON base_registration_number_template TYPE bool DEFAULT false;

-- Index
DEFINE INDEX idx_base_registration_template_name ON base_registration_number_template COLUMNS name;