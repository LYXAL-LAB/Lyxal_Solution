-- =============================================================================
-- MODULE BASE SOUS MODULE PRINTING_TEMPLATES
-- TABLE: base_printing_template_wizard (PrintingTemplateWizard)
-- Assistant de templates d'impression
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_printing_template_wizard TYPE NORMAL SCHEMAFULL
COMMENT 'Assistant de templates d\'impression';

DEFINE FIELD name ON base_printing_template_wizard TYPE string;
DEFINE FIELD printingTemplate ON base_printing_template_wizard TYPE record<base_printing_template>;
DEFINE FIELD objectId ON base_printing_template_wizard TYPE option<int>;

-- Index
DEFINE INDEX idx_base_printing_template_wizard_template ON base_printing_template_wizard FIELDS printingTemplate;
