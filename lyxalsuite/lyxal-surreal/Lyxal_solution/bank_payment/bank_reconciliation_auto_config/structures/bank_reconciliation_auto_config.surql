-- Automatisation de réconciliation
DEFINE TABLE bank_reconciliation_auto_config SCHEMAFULL;
DEFINE FIELD name ON bank_reconciliation_auto_config TYPE string;
DEFINE FIELD company ON bank_reconciliation_auto_config TYPE record<company>;
DEFINE FIELD cash_account ON bank_reconciliation_auto_config TYPE record<account>;
DEFINE FIELD is_active ON bank_reconciliation_auto_config TYPE bool DEFAULT true;
DEFINE FIELD reconcile_threshold ON bank_reconciliation_auto_config TYPE decimal DEFAULT 0.0;
DEFINE FIELD auto_reconcile_on_import ON bank_reconciliation_auto_config TYPE bool DEFAULT false;
DEFINE FIELD match_description ON bank_reconciliation_auto_config TYPE bool DEFAULT true;
DEFINE FIELD match_reference ON bank_reconciliation_auto_config TYPE bool DEFAULT true;
DEFINE FIELD match_partner ON bank_reconciliation_auto_config TYPE bool DEFAULT true;
DEFINE FIELD match_amount ON bank_reconciliation_auto_config TYPE bool DEFAULT true;
DEFINE FIELD match_date ON bank_reconciliation_auto_config TYPE bool DEFAULT false;
DEFINE FIELD date_tolerance_days ON bank_reconciliation_auto_config TYPE int DEFAULT 0;
DEFINE FIELD amount_tolerance_percentage ON bank_reconciliation_auto_config TYPE decimal DEFAULT 0.0;
DEFINE FIELD created_at ON bank_reconciliation_auto_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON bank_reconciliation_auto_config TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON bank_reconciliation_auto_config TYPE int DEFAULT 0;

-- Index

DEFINE INDEX idx_bank_reconciliation_auto_config_company ON bank_reconciliation_auto_config FIELDS company;
DEFINE INDEX idx_bank_reconciliation_auto_config_account ON bank_reconciliation_auto_config FIELDS cash_account;
DEFINE INDEX idx_bank_reconciliation_auto_config_active ON bank_reconciliation_auto_config FIELDS is_active; 