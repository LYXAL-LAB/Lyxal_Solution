-- Niveaux de budget
DEFINE TABLE budget_level SCHEMAFULL;
DEFINE FIELD name ON budget_level TYPE string;
DEFINE FIELD code ON budget_level TYPE string;
DEFINE FIELD budget ON budget_level TYPE record<budget>;
DEFINE FIELD parent_budget_level ON budget_level TYPE record<budget_level>;
DEFINE FIELD available_amount ON budget_level TYPE decimal;
DEFINE FIELD total_amount_expected ON budget_level TYPE decimal;
DEFINE FIELD total_amount_committed ON budget_level TYPE decimal;
DEFINE FIELD total_amount_reserved ON budget_level TYPE decimal;
DEFINE FIELD total_amount_realized ON budget_level TYPE decimal;
DEFINE FIELD available_amount_with_simulation ON budget_level TYPE decimal;
DEFINE FIELD simulate_expected ON budget_level TYPE bool DEFAULT false;
DEFINE FIELD simulate_committed ON budget_level TYPE bool DEFAULT false;
DEFINE FIELD simulate_reserved ON budget_level TYPE bool DEFAULT false;
DEFINE FIELD simulate_realized ON budget_level TYPE bool DEFAULT false;
DEFINE FIELD budget_line_list ON budget_level TYPE array<record<budget_line>>;
DEFINE FIELD child_budget_level_list ON budget_level TYPE array<record<budget_level>>;
DEFINE FIELD section1_value ON budget_level TYPE string;
DEFINE FIELD section2_value ON budget_level TYPE string;
DEFINE FIELD section3_value ON budget_level TYPE string;
DEFINE FIELD section4_value ON budget_level TYPE string;
DEFINE FIELD section5_value ON budget_level TYPE string;
DEFINE FIELD description ON budget_level TYPE string;
DEFINE FIELD budget_structure ON budget_level TYPE record<budget_structure>;
DEFINE FIELD created_at ON budget_level TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON budget_level TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON budget_level TYPE int DEFAULT 0;

-- Index

DEFINE INDEX idx_budget_level_budget ON budget_level FIELDS budget;
DEFINE INDEX idx_budget_level_parent ON budget_level FIELDS parent_budget_level;
DEFINE INDEX idx_budget_level_code ON budget_level FIELDS code;
DEFINE INDEX idx_budget_level_structure ON budget_level FIELDS budget_structure;