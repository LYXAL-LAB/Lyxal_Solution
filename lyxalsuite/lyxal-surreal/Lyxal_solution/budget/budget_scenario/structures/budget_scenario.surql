-- Scénarios de budget
DEFINE TABLE budget_scenario SCHEMAFULL;
DEFINE FIELD name ON budget_scenario TYPE string;
DEFINE FIELD code ON budget_scenario TYPE string;
DEFINE FIELD company ON budget_scenario TYPE record<company>;
DEFINE FIELD budget ON budget_scenario TYPE record<budget>;
DEFINE FIELD from_date ON budget_scenario TYPE date;
DEFINE FIELD to_date ON budget_scenario TYPE date;
DEFINE FIELD status_select ON budget_scenario TYPE int DEFAULT 1;
DEFINE FIELD is_template ON budget_scenario TYPE bool DEFAULT false;
DEFINE FIELD description ON budget_scenario TYPE string;
DEFINE FIELD budget_scenario_line_list ON budget_scenario TYPE array<record<budget_scenario_line>>;
DEFINE FIELD budget_scenario_variable_list ON budget_scenario TYPE array<record<budget_scenario_variable>>;
DEFINE FIELD year ON budget_scenario TYPE record<year>;
DEFINE FIELD period_duration_select ON budget_scenario TYPE int;
DEFINE FIELD created_at ON budget_scenario TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON budget_scenario TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON budget_scenario TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_budget_scenario_company ON budget_scenario FIELDS company;
DEFINE INDEX idx_budget_scenario_budget ON budget_scenario FIELDS budget;
DEFINE INDEX idx_budget_scenario_status ON budget_scenario FIELDS status_select;
DEFINE INDEX idx_budget_scenario_template ON budget_scenario FIELDS is_template;
DEFINE INDEX idx_budget_scenario_date ON budget_scenario FIELDS from_date, to_date;