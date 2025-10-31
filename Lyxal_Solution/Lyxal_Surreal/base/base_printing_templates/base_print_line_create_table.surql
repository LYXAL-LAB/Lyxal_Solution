-- =============================================================================
-- MODULE BASE SOUS MODULE PRINTING_TEMPLATES
-- TABLE: print_line (PrintLine)
-- Lignes d'impression
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_print_line TYPE NORMAL SCHEMAFULL
COMMENT 'Lignes d\'impression';

DEFINE FIELD print ON base_print_line TYPE record<print>;
DEFINE FIELD title ON base_print_line TYPE string;
DEFINE FIELD content ON base_print_line TYPE string;
DEFINE FIELD sequence ON base_print_line TYPE option<int>;

-- Index
DEFINE INDEX idx_base_print_line_print ON base_print_line FIELDS print;
