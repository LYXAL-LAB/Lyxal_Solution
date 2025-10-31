-- Lignes de budget global
DEFINE TABLE global_budget_line SCHEMAFULL;
DEFINE FIELD global_budget ON global_budget_line TYPE record<global_budget>;
DEFINE FIELD budget ON global_budget_line TYPE record<budget>;
DEFINE FIELD budget_level ON global_budget_line TYPE record<budget_level>;
DEFINE FIELD period ON global_budget_line TYPE record<period>;
DEFINE FIELD amount_expected ON global_budget_line TYPE decimal;
DEFINE FIELD amount_committed ON global_budget_line TYPE decimal;
DEFINE FIELD amount_reserved ON global_budget_line TYPE decimal;
DEFINE FIELD amount_realized ON global_budget_line TYPE decimal;
DEFINE FIELD available_amount ON global_budget_line TYPE decimal;
DEFINE FIELD available_amount_with_simulation ON global_budget_line TYPE decimal;
DEFINE FIELD simulate_expected ON global_budget_line TYPE bool DEFAULT false;
DEFINE FIELD simulate_committed ON global_budget_line TYPE bool DEFAULT false;
DEFINE FIELD simulate_reserved ON global_budget_line TYPE bool DEFAULT false;
DEFINE FIELD simulate_realized ON global_budget_line TYPE bool DEFAULT false;
DEFINE FIELD percentage_committed ON global_budget_line TYPE decimal;
DEFINE FIELD percentage_reserved ON global_budget_line TYPE decimal;
DEFINE FIELD percentage_realized ON global_budget_line TYPE decimal;
DEFINE FIELD description ON global_budget_line TYPE string;
DEFINE FIELD sequence ON global_budget_line TYPE int;
DEFINE FIELD created_at ON global_budget_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON global_budget_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON global_budget_line TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_global_budget_line_global_budget ON global_budget_line FIELDS global_budget;
DEFINE INDEX idx_global_budget_line_budget ON global_budget_line FIELDS budget;
DEFINE INDEX idx_global_budget_line_level ON global_budget_line FIELDS budget_level;
DEFINE INDEX idx_global_budget_line_period ON global_budget_line FIELDS period;
DEFINE INDEX idx_global_budget_line_sequence ON global_budget_line FIELDS sequence;