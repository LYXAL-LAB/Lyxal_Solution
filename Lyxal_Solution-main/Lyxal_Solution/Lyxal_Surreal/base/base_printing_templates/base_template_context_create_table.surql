-- =============================================================================
-- MODULE BASE SOUS MODULE PRINTING_TEMPLATES
-- TABLE: base_template_context (TemplateContext)
-- Contextes de templates
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_template_context TYPE NORMAL SCHEMAFULL
COMMENT 'Contextes de templates'
PERMISSIONS FULL;

DEFINE FIELD name ON base_template_context TYPE string;
DEFINE FIELD template ON base_template_context TYPE record<base_template_print>;

-- Index
DEFINE INDEX idx_base_template_context_template ON base_template_context FIELDS template;