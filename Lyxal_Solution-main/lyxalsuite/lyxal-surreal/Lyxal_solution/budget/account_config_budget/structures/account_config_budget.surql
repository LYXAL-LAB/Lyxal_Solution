-- Configuration de compte pour budget
DEFINE TABLE account_config_budget SCHEMAFULL;
DEFINE FIELD name ON account_config_budget TYPE string;
DEFINE FIELD company ON account_config_budget TYPE record<company>;
DEFINE FIELD budget_account_set ON account_config_budget TYPE array<record<account>>;
DEFINE FIELD expense_account_set ON account_config_budget TYPE array<record<account>>;
DEFINE FIELD revenue_account_set ON account_config_budget TYPE array<record<account>>;
DEFINE FIELD is_auto_compute_budget_key ON account_config_budget TYPE bool DEFAULT false;
DEFINE FIELD budget_key_template ON account_config_budget TYPE string;
DEFINE FIELD created_at ON account_config_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON account_config_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON account_config_budget TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_account_config_budget_company ON account_config_budget FIELDS company;