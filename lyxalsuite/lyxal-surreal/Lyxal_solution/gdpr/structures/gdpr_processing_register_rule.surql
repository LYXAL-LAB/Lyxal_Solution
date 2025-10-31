-- Règle de registre de traitement GDPR
DEFINE TABLE gdpr_processing_register_rule SCHEMAFULL;
DEFINE FIELD gdpr_processing_register ON gdpr_processing_register_rule TYPE record<gdpr_processing_register> ASSERT $value != NONE;
DEFINE FIELD name ON gdpr_processing_register_rule TYPE string ASSERT $value != NONE;
DEFINE FIELD rule_type_select ON gdpr_processing_register_rule TYPE int DEFAULT 1; -- 1:Data Collection, 2:Data Processing, 3:Data Storage, 4:Data Sharing, 5:Data Deletion
DEFINE FIELD condition ON gdpr_processing_register_rule TYPE string;
DEFINE FIELD action ON gdpr_processing_register_rule TYPE string ASSERT $value != NONE;
DEFINE FIELD frequency_select ON gdpr_processing_register_rule TYPE int DEFAULT 1; -- 1:Manual, 2:Daily, 3:Weekly, 4:Monthly, 5:Yearly
DEFINE FIELD is_automated ON gdpr_processing_register_rule TYPE bool DEFAULT false;
DEFINE FIELD automation_script ON gdpr_processing_register_rule TYPE string;
DEFINE FIELD notification_required ON gdpr_processing_register_rule TYPE bool DEFAULT false;
DEFINE FIELD notification_recipients ON gdpr_processing_register_rule TYPE array<string>;
DEFINE FIELD compliance_check ON gdpr_processing_register_rule TYPE string;
DEFINE FIELD risk_level ON gdpr_processing_register_rule TYPE int DEFAULT 2; -- 1:Low, 2:Medium, 3:High, 4:Critical
DEFINE FIELD mitigation_measures ON gdpr_processing_register_rule TYPE string;
DEFINE FIELD is_active ON gdpr_processing_register_rule TYPE bool DEFAULT true;
DEFINE FIELD last_execution_date ON gdpr_processing_register_rule TYPE datetime;
DEFINE FIELD next_execution_date ON gdpr_processing_register_rule TYPE datetime;
DEFINE FIELD execution_count ON gdpr_processing_register_rule TYPE int DEFAULT 0;
DEFINE FIELD created_at ON gdpr_processing_register_rule TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON gdpr_processing_register_rule TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON gdpr_processing_register_rule TYPE int DEFAULT 0;

-- Index d'optimisation

DEFINE INDEX idx_gdpr_register_rule_register ON gdpr_processing_register_rule FIELDS gdpr_processing_register;
DEFINE INDEX idx_gdpr_register_rule_type ON gdpr_processing_register_rule FIELDS rule_type_select;
DEFINE INDEX idx_gdpr_register_rule_automated ON gdpr_processing_register_rule FIELDS is_automated;
DEFINE INDEX idx_gdpr_register_rule_active ON gdpr_processing_register_rule FIELDS is_active;
DEFINE INDEX idx_gdpr_register_rule_next_exec ON gdpr_processing_register_rule FIELDS next_execution_date;
DEFINE INDEX idx_gdpr_register_rule_risk ON gdpr_processing_register_rule FIELDS risk_level;