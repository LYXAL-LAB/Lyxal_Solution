-- Export de budget global
DEFINE TABLE global_budget_export SCHEMAFULL;
DEFINE FIELD name ON global_budget_export TYPE string;
DEFINE FIELD global_budget ON global_budget_export TYPE record<global_budget>;
DEFINE FIELD company ON global_budget_export TYPE record<company>;
DEFINE FIELD export_type_select ON global_budget_export TYPE int;
DEFINE FIELD period_type_select ON global_budget_export TYPE int;
DEFINE FIELD from_date ON global_budget_export TYPE date;
DEFINE FIELD to_date ON global_budget_export TYPE date;
DEFINE FIELD include_expected ON global_budget_export TYPE bool DEFAULT true;
DEFINE FIELD include_committed ON global_budget_export TYPE bool DEFAULT true;
DEFINE FIELD include_reserved ON global_budget_export TYPE bool DEFAULT true;
DEFINE FIELD include_realized ON global_budget_export TYPE bool DEFAULT true;
DEFINE FIELD include_available ON global_budget_export TYPE bool DEFAULT true;
DEFINE FIELD group_by_budget_level ON global_budget_export TYPE bool DEFAULT false;
DEFINE FIELD group_by_period ON global_budget_export TYPE bool DEFAULT false;
DEFINE FIELD export_format_select ON global_budget_export TYPE int DEFAULT 1;
DEFINE FIELD file_path ON global_budget_export TYPE string;
DEFINE FIELD export_date ON global_budget_export TYPE datetime;
DEFINE FIELD exported_by ON global_budget_export TYPE record<user>;
DEFINE FIELD description ON global_budget_export TYPE string;
DEFINE FIELD created_at ON global_budget_export TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON global_budget_export TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON global_budget_export TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_global_budget_export_global_budget ON global_budget_export FIELDS global_budget;
DEFINE INDEX idx_global_budget_export_company ON global_budget_export FIELDS company;
DEFINE INDEX idx_global_budget_export_type ON global_budget_export FIELDS export_type_select;
DEFINE INDEX idx_global_budget_export_date ON global_budget_export FIELDS export_date;