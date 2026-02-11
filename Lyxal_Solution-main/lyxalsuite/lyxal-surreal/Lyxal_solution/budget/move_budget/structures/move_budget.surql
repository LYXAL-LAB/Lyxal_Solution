-- Extensions d'écriture pour budget
DEFINE TABLE move_budget SCHEMAFULL;
DEFINE FIELD reference ON move_budget TYPE string;
DEFINE FIELD journal ON move_budget TYPE record<journal>;
DEFINE FIELD period ON move_budget TYPE record<period>;
DEFINE FIELD date ON move_budget TYPE date;
DEFINE FIELD partner ON move_budget TYPE record<partner>;
DEFINE FIELD company ON move_budget TYPE record<company>;
DEFINE FIELD currency ON move_budget TYPE record<currency>;
DEFINE FIELD status_select ON move_budget TYPE int;
DEFINE FIELD move_line_list ON move_budget TYPE array<record<move_line_budget>>;
DEFINE FIELD budget_distribution_generated ON move_budget TYPE bool DEFAULT false;
DEFINE FIELD budget_distribution_sum_amount ON move_budget TYPE decimal;
DEFINE FIELD budget_remaining_amount_to_allocate ON move_budget TYPE decimal;
DEFINE FIELD budget_exceeded_amount ON move_budget TYPE decimal;
DEFINE FIELD is_budget_exceeded ON move_budget TYPE bool DEFAULT false;
DEFINE FIELD budget_control_level_select ON move_budget TYPE int;
DEFINE FIELD created_at ON move_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON move_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON move_budget TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_move_budget_company ON move_budget FIELDS company;
DEFINE INDEX idx_move_budget_journal ON move_budget FIELDS journal;
DEFINE INDEX idx_move_budget_period ON move_budget FIELDS period;
DEFINE INDEX idx_move_budget_date ON move_budget FIELDS date;
DEFINE INDEX idx_move_budget_exceeded ON move_budget FIELDS is_budget_exceeded;