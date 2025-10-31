-- Lignes de budget
DEFINE TABLE budget_line SCHEMAFULL;
DEFINE FIELD budget ON budget_line TYPE record<budget>;
DEFINE FIELD budget_level ON budget_line TYPE record<budget_level>;
DEFINE FIELD period ON budget_line TYPE record<period>;
DEFINE FIELD amount_expected ON budget_line TYPE decimal;
DEFINE FIELD amount_committed ON budget_line TYPE decimal;
DEFINE FIELD amount_reserved ON budget_line TYPE decimal;
DEFINE FIELD amount_realized ON budget_line TYPE decimal;
DEFINE FIELD available_amount ON budget_line TYPE decimal;
DEFINE FIELD available_amount_with_simulation ON budget_line TYPE decimal;
DEFINE FIELD simulate_expected ON budget_line TYPE bool DEFAULT false;
DEFINE FIELD simulate_committed ON budget_line TYPE bool DEFAULT false;
DEFINE FIELD simulate_reserved ON budget_line TYPE bool DEFAULT false;
DEFINE FIELD simulate_realized ON budget_line TYPE bool DEFAULT false;
DEFINE FIELD amount_expected_previous_period ON budget_line TYPE decimal;
DEFINE FIELD amount_committed_previous_period ON budget_line TYPE decimal;
DEFINE FIELD amount_reserved_previous_period ON budget_line TYPE decimal;
DEFINE FIELD amount_realized_previous_period ON budget_line TYPE decimal;
DEFINE FIELD percentage_committed ON budget_line TYPE decimal;
DEFINE FIELD percentage_reserved ON budget_line TYPE decimal;
DEFINE FIELD percentage_realized ON budget_line TYPE decimal;
DEFINE FIELD description ON budget_line TYPE string;
DEFINE FIELD created_at ON budget_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON budget_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON budget_line TYPE int DEFAULT 0;

--Index

DEFINE INDEX idx_budget_line_budget ON budget_line FIELDS budget;
DEFINE INDEX idx_budget_line_budget_level ON budget_line FIELDS budget_level;
DEFINE INDEX idx_budget_line_period ON budget_line FIELDS period;