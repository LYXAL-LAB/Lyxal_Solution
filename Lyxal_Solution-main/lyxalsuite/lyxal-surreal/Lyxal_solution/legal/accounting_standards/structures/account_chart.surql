-- ==============================================================================
-- TABLE : COMPTES COMPTABLES
-- ==============================================================================

DEFINE TABLE account_chart SCHEMAFULL;
DEFINE FIELD account_number ON account_chart TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD account_name ON account_chart TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD account_type ON account_chart TYPE string 
    ASSERT $value IN ['asset', 'liability', 'equity', 'revenue', 'expense', 'other'];
DEFINE FIELD account_class ON account_chart TYPE int 
    ASSERT $value >= 1 AND $value <= 8;
DEFINE FIELD level ON account_chart TYPE int 
    ASSERT $value >= 1 AND $value <= 6;
DEFINE FIELD parent_account ON account_chart TYPE option<record<account_chart>>;
DEFINE FIELD accounting_standard ON account_chart TYPE record<accounting_standard>;
DEFINE FIELD description ON account_chart TYPE string;
DEFINE FIELD debit_credit_nature ON account_chart TYPE string 
    ASSERT $value IN ['debit', 'credit', 'both'];
DEFINE FIELD is_analytical ON account_chart TYPE bool DEFAULT false;
DEFINE FIELD is_auxiliary ON account_chart TYPE bool DEFAULT false;
DEFINE FIELD is_reconciliation ON account_chart TYPE bool DEFAULT false;
DEFINE FIELD is_active ON account_chart TYPE bool DEFAULT true;
DEFINE FIELD usage_rules ON account_chart TYPE object;
DEFINE FIELD validation_rules ON account_chart TYPE object;
DEFINE FIELD reporting_category ON account_chart TYPE string;
DEFINE FIELD tax_category ON account_chart TYPE option<string>;
DEFINE FIELD created_on ON account_chart TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON account_chart TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON account_chart TYPE option<string>;
DEFINE FIELD updated_by ON account_chart TYPE option<string>;

-- Index optimisés
DEFINE INDEX idx_account_chart_number ON account_chart COLUMNS account_number, accounting_standard UNIQUE;
DEFINE INDEX idx_account_chart_class ON account_chart COLUMNS account_class;
DEFINE INDEX idx_account_chart_type ON account_chart COLUMNS account_type;
DEFINE INDEX idx_account_chart_standard ON account_chart COLUMNS accounting_standard;
DEFINE INDEX idx_account_chart_active ON account_chart COLUMNS is_active;
