-- Configuration de modèle de compte
DEFINE TABLE account_model SCHEMAFULL;
DEFINE FIELD name ON account_model TYPE string;
DEFINE FIELD code ON account_model TYPE string;
DEFINE FIELD account ON account_model TYPE record<account>;
DEFINE FIELD account_type ON account_model TYPE record<account_type>;
DEFINE FIELD is_debit ON account_model TYPE bool DEFAULT true;
DEFINE FIELD budget_structure ON account_model TYPE record<budget_structure>;
DEFINE FIELD sequence ON account_model TYPE int;
DEFINE FIELD description ON account_model TYPE string;
DEFINE FIELD created_at ON account_model TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON account_model TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON account_model TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_account_model_account ON account_model FIELDS account;
DEFINE INDEX idx_account_model_structure ON account_model FIELDS budget_structure;
DEFINE INDEX idx_account_model_code ON account_model FIELDS code;