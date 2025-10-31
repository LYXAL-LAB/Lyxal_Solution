-- Lignes de scénario de budget
DEFINE TABLE budget_scenario_line SCHEMAFULL;
DEFINE FIELD budget_scenario ON budget_scenario_line TYPE record<budget_scenario>;
DEFINE FIELD budget_level ON budget_scenario_line TYPE record<budget_level>;
DEFINE FIELD period ON budget_scenario_line TYPE record<period>;
DEFINE FIELD amount ON budget_scenario_line TYPE decimal;
DEFINE FIELD variation_type_select ON budget_scenario_line TYPE int;
DEFINE FIELD variation_percentage ON budget_scenario_line TYPE decimal;
DEFINE FIELD variation_amount ON budget_scenario_line TYPE decimal;
DEFINE FIELD formula ON budget_scenario_line TYPE string;
DEFINE FIELD computed_amount ON budget_scenario_line TYPE decimal;
DEFINE FIELD is_computed ON budget_scenario_line TYPE bool DEFAULT false;
DEFINE FIELD description ON budget_scenario_line TYPE string;
DEFINE FIELD sequence ON budget_scenario_line TYPE int;
DEFINE FIELD created_at ON budget_scenario_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON budget_scenario_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON budget_scenario_line TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_budget_scenario_line_scenario ON budget_scenario_line FIELDS budget_scenario;
DEFINE INDEX idx_budget_scenario_line_level ON budget_scenario_line FIELDS budget_level;
DEFINE INDEX idx_budget_scenario_line_period ON budget_scenario_line FIELDS period;
DEFINE INDEX idx_budget_scenario_line_sequence ON budget_scenario_line FIELDS sequence;