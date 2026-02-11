-- Variables de scénario de budget
DEFINE TABLE budget_scenario_variable SCHEMAFULL;
DEFINE FIELD budget_scenario ON budget_scenario_variable TYPE record<budget_scenario>;
DEFINE FIELD name ON budget_scenario_variable TYPE string;
DEFINE FIELD code ON budget_scenario_variable TYPE string;
DEFINE FIELD variable_type_select ON budget_scenario_variable TYPE int;
DEFINE FIELD value_string ON budget_scenario_variable TYPE string;
DEFINE FIELD value_decimal ON budget_scenario_variable TYPE decimal;
DEFINE FIELD value_integer ON budget_scenario_variable TYPE int;
DEFINE FIELD value_boolean ON budget_scenario_variable TYPE bool;
DEFINE FIELD value_date ON budget_scenario_variable TYPE date;
DEFINE FIELD description ON budget_scenario_variable TYPE string;
DEFINE FIELD formula ON budget_scenario_variable TYPE string;
DEFINE FIELD is_computed ON budget_scenario_variable TYPE bool DEFAULT false;
DEFINE FIELD sequence ON budget_scenario_variable TYPE int;
DEFINE FIELD created_at ON budget_scenario_variable TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON budget_scenario_variable TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON budget_scenario_variable TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_budget_scenario_variable_scenario ON budget_scenario_variable FIELDS budget_scenario;
DEFINE INDEX idx_budget_scenario_variable_code ON budget_scenario_variable FIELDS code;
DEFINE INDEX idx_budget_scenario_variable_type ON budget_scenario_variable FIELDS variable_type_select;