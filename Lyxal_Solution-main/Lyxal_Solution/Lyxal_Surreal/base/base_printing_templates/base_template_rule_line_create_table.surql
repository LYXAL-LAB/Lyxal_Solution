-- =============================================================================
-- MODULE : BASE SOUS MODULE : PRINTING_TEMPLATES
-- TABLE: base_template_rule_line (TemplateRuleLine)
-- Lignes de règles de templates
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_template_rule_line TYPE NORMAL SCHEMAFULL
COMMENT 'Lignes de règles de templates'
PERMISSIONS FULL;

DEFINE FIELD templateRule ON base_template_rule_line TYPE record<base_template_rule>;
DEFINE FIELD metaField ON base_template_rule_line TYPE record<base_meta_field>;
DEFINE FIELD value ON base_template_rule_line TYPE string;

-- Index
DEFINE INDEX idx_base_template_rule_line_rule ON base_template_rule_line FIELDS templateRule; 