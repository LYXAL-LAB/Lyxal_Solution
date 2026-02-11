-- =============================================================================
-- MODULE : BASE SOUS MODULE : PRINTING_TEMPLATES
-- TABLE: base_printing_settings (PrintingSettings)
-- Paramètres d'impression
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_printing_settings TYPE NORMAL SCHEMAFULL
COMMENT 'Paramètres d\'impression'
PERMISSIONS FULL;

DEFINE FIELD name ON base_printing_settings TYPE string;
DEFINE FIELD logoPositionSelect ON base_printing_settings TYPE option<int>;
DEFINE FIELD headerHeight ON base_printing_settings TYPE option<int>;
DEFINE FIELD footerHeight ON base_printing_settings TYPE option<int>;

-- Index
DEFINE INDEX idx_base_printing_settings_name ON base_printing_settings FIELDS name;
