-- Budget principal
DEFINE TABLE budget SCHEMAFULL;
DEFINE FIELD name ON budget TYPE string;
DEFINE FIELD code ON budget TYPE string;
DEFINE FIELD company ON budget TYPE record<company>;
DEFINE FIELD from_date ON budget TYPE date;
DEFINE FIELD to_date ON budget TYPE date;
DEFINE FIELD status_select ON budget TYPE int DEFAULT 1;
DEFINE FIELD budget_type_select ON budget TYPE int;
DEFINE FIELD source_budget ON budget TYPE record<budget>;
DEFINE FIELD available_amount ON budget TYPE decimal;
DEFINE FIELD total_amount_expected ON budget TYPE decimal;
DEFINE FIELD total_amount_committed ON budget TYPE decimal;
DEFINE FIELD total_amount_reserved ON budget TYPE decimal;
DEFINE FIELD total_amount_realized ON budget TYPE decimal;
DEFINE FIELD available_amount_with_simulation ON budget TYPE decimal;
DEFINE FIELD simulate_expected ON budget TYPE bool DEFAULT false;
DEFINE FIELD simulate_committed ON budget TYPE bool DEFAULT false;
DEFINE FIELD simulate_reserved ON budget TYPE bool DEFAULT false;
DEFINE FIELD simulate_realized ON budget TYPE bool DEFAULT false;
DEFINE FIELD budget_line_list ON budget TYPE array<record<budget_line>>;
DEFINE FIELD budget_level_list ON budget TYPE array<record<budget_level>>;
DEFINE FIELD company_department ON budget TYPE record<company_department>;
DEFINE FIELD comment ON budget TYPE string;
DEFINE FIELD is_copy_from_previous_year ON budget TYPE bool DEFAULT false;
DEFINE FIELD source_budget_year ON budget TYPE record<year>;
DEFINE FIELD created_at ON budget TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON budget TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON budget TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_budget_company ON budget FIELDS company;
DEFINE INDEX idx_budget_status ON budget FIELDS status_select;
DEFINE INDEX idx_budget_type ON budget FIELDS budget_type_select;
DEFINE INDEX idx_budget_date ON budget FIELDS from_date, to_date;
DEFINE INDEX idx_budget_code ON budget FIELDS code;