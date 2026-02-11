-- Extensions de ligne d'écriture pour budget
DEFINE TABLE move_line_budget SCHEMAFULL;
DEFINE FIELD move ON move_line_budget TYPE record<move_budget>;
DEFINE FIELD account ON move_line_budget TYPE record<account>;
DEFINE FIELD partner ON move_line_budget TYPE record<partner>;
DEFINE FIELD debit ON move_line_budget TYPE decimal;
DEFINE FIELD credit ON move_line_budget TYPE decimal;
DEFINE FIELD amount_currency ON move_line_budget TYPE decimal;
DEFINE FIELD currency_rate ON move_line_budget TYPE decimal;
DEFINE FIELD currency ON move_line_budget TYPE record<currency>;
DEFINE FIELD date ON move_line_budget TYPE date;
DEFINE FIELD due_date ON move_line_budget TYPE date;
DEFINE FIELD description ON move_line_budget TYPE string;
DEFINE FIELD origin ON move_line_budget TYPE string;
DEFINE FIELD analytic_move_line_list ON move_line_budget TYPE array<record<analytic_move_line>>;
DEFINE FIELD budget_distribution_list ON move_line_budget TYPE array<record<budget_distribution>>;
DEFINE FIELD budget_distribution_sum_amount ON move_line_budget TYPE decimal;
DEFINE FIELD budget_remaining_amount_to_allocate ON move_line_budget TYPE decimal;
DEFINE FIELD budget_exceeded_amount ON move_line_budget TYPE decimal;
DEFINE FIELD is_budget_exceeded ON move_line_budget TYPE bool DEFAULT false;
DEFINE FIELD budget_key ON move_line_budget TYPE string;
DEFINE FIELD created_at ON move_line_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON move_line_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON move_line_budget TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_move_line_budget_move ON move_line_budget FIELDS move;
DEFINE INDEX idx_move_line_budget_account ON move_line_budget FIELDS account;
DEFINE INDEX idx_move_line_budget_partner ON move_line_budget FIELDS partner;
DEFINE INDEX idx_move_line_budget_date ON move_line_budget FIELDS date;
DEFINE INDEX idx_move_line_budget_exceeded ON move_line_budget FIELDS is_budget_exceeded;
DEFINE INDEX idx_move_line_budget_key ON move_line_budget FIELDS budget_key;