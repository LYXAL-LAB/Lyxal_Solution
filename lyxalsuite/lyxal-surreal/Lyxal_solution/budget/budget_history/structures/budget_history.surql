-- Historique des modifications de budget
DEFINE TABLE budget_history SCHEMAFULL;
DEFINE FIELD budget ON budget_history TYPE record<budget>;
DEFINE FIELD global_budget ON budget_history TYPE record<global_budget>;
DEFINE FIELD budget_level ON budget_history TYPE record<budget_level>;
DEFINE FIELD operation_type_select ON budget_history TYPE int;
DEFINE FIELD old_amount ON budget_history TYPE decimal;
DEFINE FIELD new_amount ON budget_history TYPE decimal;
DEFINE FIELD amount_difference ON budget_history TYPE decimal;
DEFINE FIELD operation_date ON budget_history TYPE datetime DEFAULT time::now();
DEFINE FIELD user ON budget_history TYPE record<user>;
DEFINE FIELD period ON budget_history TYPE record<period>;
DEFINE FIELD description ON budget_history TYPE string;
DEFINE FIELD reason ON budget_history TYPE string;
DEFINE FIELD source_object_id ON budget_history TYPE string;
DEFINE FIELD source_object_type ON budget_history TYPE string;
DEFINE FIELD created_at ON budget_history TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON budget_history TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON budget_history TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_budget_history_budget ON budget_history FIELDS budget;
DEFINE INDEX idx_budget_history_global_budget ON budget_history FIELDS global_budget;
DEFINE INDEX idx_budget_history_level ON budget_history FIELDS budget_level;
DEFINE INDEX idx_budget_history_operation_type ON budget_history FIELDS operation_type_select;
DEFINE INDEX idx_budget_history_date ON budget_history FIELDS operation_date;
DEFINE INDEX idx_budget_history_user ON budget_history FIELDS user; 