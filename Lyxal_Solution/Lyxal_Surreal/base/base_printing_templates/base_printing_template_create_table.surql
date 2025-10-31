-- =============================================================================
-- MODULE BASE SOUS MODULE : PRINTING_TEMPLATES
-- TABLE: printing_template (PrintingTemplate)
-- Templates d'impression
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_printing_template TYPE NORMAL SCHEMAFULL
COMMENT 'Templates d\'impression'
PERMISSIONS FULL;

DEFINE FIELD name ON base_printing_template TYPE string;
DEFINE FIELD metaModel ON base_printing_template TYPE record<base_meta_model>;
DEFINE FIELD printingTemplateLineList ON base_printing_template TYPE array<record<base_printing_template_line>>;
DEFINE FIELD isDefault ON base_printing_template TYPE bool DEFAULT false;

-- Index
DEFINE INDEX idx_base_printing_template_name ON base_printing_template FIELDS name;
DEFINE INDEX idx_base_printing_template_model ON base_printing_template FIELDS metaModel;
