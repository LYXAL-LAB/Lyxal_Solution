-- Budget global
DEFINE TABLE global_budget SCHEMAFULL;
DEFINE FIELD name ON global_budget TYPE string;
DEFINE FIELD code ON global_budget TYPE string;
DEFINE FIELD company ON global_budget TYPE record<company>;
DEFINE FIELD from_date ON global_budget TYPE date;
DEFINE FIELD to_date ON global_budget TYPE date;
DEFINE FIELD status_select ON global_budget TYPE int DEFAULT 1;
DEFINE FIELD budget_type_select ON global_budget TYPE int;
DEFINE FIELD available_amount ON global_budget TYPE decimal;
DEFINE FIELD total_amount_expected ON global_budget TYPE decimal;
DEFINE FIELD total_amount_committed ON global_budget TYPE decimal;
DEFINE FIELD total_amount_reserved ON global_budget TYPE decimal;
DEFINE FIELD total_amount_realized ON global_budget TYPE decimal;
DEFINE FIELD available_amount_with_simulation ON global_budget TYPE decimal;
DEFINE FIELD simulate_expected ON global_budget TYPE bool DEFAULT false;
DEFINE FIELD simulate_committed ON global_budget TYPE bool DEFAULT false;
DEFINE FIELD simulate_reserved ON global_budget TYPE bool DEFAULT false;
DEFINE FIELD simulate_realized ON global_budget TYPE bool DEFAULT false;
DEFINE FIELD budget_list ON global_budget TYPE array<record<budget>>;
DEFINE FIELD budget_level_list ON global_budget TYPE array<record<budget_level>>;
DEFINE FIELD global_budget_line_list ON global_budget TYPE array<record<global_budget_line>>;
DEFINE FIELD company_department ON global_budget TYPE record<company_department>;
DEFINE FIELD comment ON global_budget TYPE string;
DEFINE FIELD is_copy_from_previous_year ON global_budget TYPE bool DEFAULT false;
DEFINE FIELD source_global_budget_year ON global_budget TYPE record<year>;
DEFINE FIELD budget_manager_set ON global_budget TYPE array<record<user>>;
DEFINE FIELD budget_key ON global_budget TYPE string;
DEFINE FIELD created_at ON global_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON global_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON global_budget TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_global_budget_company ON global_budget FIELDS company;
DEFINE INDEX idx_global_budget_status ON global_budget FIELDS status_select;
DEFINE INDEX idx_global_budget_type ON global_budget FIELDS budget_type_select;
DEFINE INDEX idx_global_budget_date ON global_budget FIELDS from_date, to_date;
DEFINE INDEX idx_global_budget_key ON global_budget FIELDS budget_key;