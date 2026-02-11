-- =============================================================================
-- TABLE: fiscal_position (FiscalPosition)
-- Positions fiscales
-- =============================================================================
DEFINE TABLE fiscal_position SCHEMAFULL;

DEFINE FIELD name ON fiscal_position TYPE string;
DEFINE FIELD code ON fiscal_position TYPE option<string>;

-- Index
DEFINE INDEX idx_fiscal_position_name ON fiscal_position COLUMNS name;
DEFINE INDEX idx_fiscal_position_code ON fiscal_position COLUMNS code;