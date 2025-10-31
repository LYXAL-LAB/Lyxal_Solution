-- =============================================================================
-- MODULE BASE SOUS MODULE PRINTING_TEMPLATES
-- TABLE: base_print (Print)
-- Impressions
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_print TYPE NORMAL SCHEMAFULL
COMMENT 'Impressions'
PERMISSIONS FULL;

DEFINE FIELD name ON base_print TYPE string;
DEFINE FIELD printTemplate ON base_print TYPE record<base_print_template>;
DEFINE FIELD printDate ON base_print TYPE option<datetime>;
DEFINE FIELD printLineList ON base_print TYPE array<record<base_print_line>>;

-- Index
DEFINE INDEX idx_base_print_template ON base_print FIELDS printTemplate;
DEFINE INDEX idx_base_print_date ON base_print FIELDS printDate;
