-- =============================================================================
-- MODULE BASE SOUS MODULE PRINTING_TEMPLATES
-- TABLE: base_template_rule (TemplateRule)
-- Règles de templates
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_template_rule TYPE NORMAL SCHEMAFULL
COMMENT 'Règles de templates'
PERMISSIONS FULL;

DEFINE FIELD name ON base_template_rule TYPE string;
DEFINE FIELD templateRuleLineList ON base_template_rule TYPE array<record<base_template_rule_line>>;

-- Index
DEFINE INDEX idx_base_template_rule_name ON base_template_rule FIELDS name;