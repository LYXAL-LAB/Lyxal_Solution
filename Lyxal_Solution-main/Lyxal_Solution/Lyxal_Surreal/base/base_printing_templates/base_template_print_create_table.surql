-- =============================================================================
-- MODULE BASE SOUS MODULE PRINTING_TEMPLATES
-- TABLE: base_template_print (Template)
-- Templates génériques
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_template_print TYPE NORMAL SCHEMAFULL
COMMENT 'Templates génériques'
PERMISSIONS FULL;

DEFINE FIELD name ON base_template_print TYPE string;
DEFINE FIELD printTemplateSet ON base_template_print TYPE array<record<base_printing_template>>;
DEFINE FIELD localizationSet ON base_template_print TYPE array<record<base_localization>>;

-- Index
DEFINE INDEX idx_base_template_name ON tbase_template_printemplate FIELDS name;