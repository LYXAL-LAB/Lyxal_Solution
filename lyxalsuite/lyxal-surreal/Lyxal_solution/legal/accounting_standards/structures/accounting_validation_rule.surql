-- ==============================================================================
-- TABLE : RÈGLES DE VALIDATION COMPTABLE
-- ==============================================================================

DEFINE TABLE accounting_validation_rule SCHEMAFULL;
DEFINE FIELD rule_name ON accounting_validation_rule TYPE string 
    ASSERT string::len($value) > 0;
DEFINE FIELD rule_type ON accounting_validation_rule TYPE string 
    ASSERT $value IN ['balance', 'debit_credit', 'mandatory_field', 'format', 'range', 'custom'];
DEFINE FIELD accounting_standard ON accounting_validation_rule TYPE record<accounting_standard>;
DEFINE FIELD applicable_accounts ON accounting_validation_rule TYPE array<record<account_chart>>;
DEFINE FIELD rule_condition ON accounting_validation_rule TYPE string;
DEFINE FIELD error_message ON accounting_validation_rule TYPE string;
DEFINE FIELD severity ON accounting_validation_rule TYPE string 
    ASSERT $value IN ['error', 'warning', 'info'];
DEFINE FIELD is_blocking ON accounting_validation_rule TYPE bool DEFAULT false;
DEFINE FIELD is_active ON accounting_validation_rule TYPE bool DEFAULT true;
DEFINE FIELD created_on ON accounting_validation_rule TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON accounting_validation_rule TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON accounting_validation_rule TYPE option<record<user>>;
DEFINE FIELD updated_by ON accounting_validation_rule TYPE option<record<user>>;

-- Index optimisés
DEFINE INDEX idx_accounting_validation_rule_standard ON accounting_validation_rule COLUMNS accounting_standard;
DEFINE INDEX idx_accounting_validation_rule_type ON accounting_validation_rule COLUMNS rule_type;
DEFINE INDEX idx_accounting_validation_rule_active ON accounting_validation_rule COLUMNS is_active;
