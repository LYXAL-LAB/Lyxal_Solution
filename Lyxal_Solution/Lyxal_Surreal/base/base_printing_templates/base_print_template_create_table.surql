-- =============================================================================
-- MODULE BASE SOUS MODULE PRINTING_TEMPLATES
-- TABLE: base_print_template (PrintTemplate)
-- Templates de rapport
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_print_template TYPE NORMAL SCHEMAFULL
COMMENT 'Templates de rapport'
PERMISSIONS FULL;

DEFINE FIELD name ON base_print_template TYPE string;
DEFINE FIELD metaModel ON base_print_template TYPE record<base_meta_model>;
DEFINE FIELD templateLink ON base_print_template TYPE option<string>;
DEFINE FIELD outputFormat ON base_print_template TYPE option<string>;
DEFINE FIELD printTemplateLineList ON base_print_template TYPE array<record<base_print_template_line>>;

-- Index
DEFINE INDEX idx_base_print_template_name ON base_print_template FIELDS name;
DEFINE INDEX idx_base_print_template_model ON base_print_template FIELDS metaModel;
