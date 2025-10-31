-- =============================================================================
-- MODULE BASE SOUS MODULE PRINTING_TEMPLATES
-- TABLE: base_print_template_line (PrintTemplateLine)
-- Lignes de templates de rapport
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_print_template_line TYPE NORMAL SCHEMAFULL
COMMENT 'Lignes de templates de rapport'
PERMISSIONS FULL;

DEFINE FIELD printTemplate ON base_print_template_line TYPE record<base_print_template>;
DEFINE FIELD title ON base_print_template_line TYPE string;
DEFINE FIELD content ON base_print_template_line TYPE string;
DEFINE FIELD sequence ON base_print_template_line TYPE option<int>;

-- Index
DEFINE INDEX idx_base_print_template_line_template ON base_print_template_line FIELDS printTemplate;
