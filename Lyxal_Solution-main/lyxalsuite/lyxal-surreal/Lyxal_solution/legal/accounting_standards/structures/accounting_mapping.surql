-- ==============================================================================
-- TABLE : MAPPING ENTRE NORMES
-- ==============================================================================

DEFINE TABLE accounting_mapping SCHEMAFULL;
DEFINE FIELD source_standard ON accounting_mapping TYPE record<accounting_standard>;
DEFINE FIELD target_standard ON accounting_mapping TYPE record<accounting_standard>;
DEFINE FIELD source_account ON accounting_mapping TYPE record<account_chart>;
DEFINE FIELD target_account ON accounting_mapping TYPE record<account_chart>;
DEFINE FIELD mapping_type ON accounting_mapping TYPE string 
    ASSERT $value IN ['direct', 'split', 'consolidate', 'conditional'];
DEFINE FIELD mapping_ratio ON accounting_mapping TYPE float DEFAULT 1.0;
DEFINE FIELD conditions ON accounting_mapping TYPE object;
DEFINE FIELD notes ON accounting_mapping TYPE string;
DEFINE FIELD is_active ON accounting_mapping TYPE bool DEFAULT true;
DEFINE FIELD created_on ON accounting_mapping TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON accounting_mapping TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON accounting_mapping TYPE option<string>;
DEFINE FIELD updated_by ON accounting_mapping TYPE option<string>;

-- Index optimisés
DEFINE INDEX idx_accounting_mapping_source ON accounting_mapping COLUMNS source_standard, source_account;
DEFINE INDEX idx_accounting_mapping_target ON accounting_mapping COLUMNS target_standard, target_account;
DEFINE INDEX idx_accounting_mapping_active ON accounting_mapping COLUMNS is_active;
