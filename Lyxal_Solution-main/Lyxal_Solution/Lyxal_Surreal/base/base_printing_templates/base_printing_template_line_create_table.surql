-- =============================================================================
-- MODULE : BASE SOUS MODULE : PRINTING_TEMPLATES
-- TABLE: base_printing_template_line (PrintingTemplateLine)
-- Lignes de templates d'impression
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_printing_template_line TYPE NORMAL SCHEMAFULL
COMMENT 'Lignes de templates d\'impression'
PERMISSIONS FULL;

DEFINE FIELD printingTemplate ON base_printing_template_line TYPE record<base_printing_template>;
DEFINE FIELD title ON base_printing_template_line TYPE string;
DEFINE FIELD content ON base_printing_template_line TYPE string;
DEFINE FIELD sequence ON base_printing_template_line TYPE option<int>;

-- Index
DEFINE INDEX idx_base_printing_template_line_template ON base_printing_template_line FIELDS printingTemplate;
