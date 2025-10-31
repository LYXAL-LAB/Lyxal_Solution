-- Application budget
DEFINE TABLE app_budget SCHEMAFULL;
DEFINE FIELD name ON app_budget TYPE string DEFAULT "Budget";
DEFINE FIELD code ON app_budget TYPE string DEFAULT "budget";
DEFINE FIELD is_active ON app_budget TYPE bool DEFAULT true;
DEFINE FIELD sequence ON app_budget TYPE int DEFAULT 30;
DEFINE FIELD depends_on_set ON app_budget TYPE array<string>;
DEFINE FIELD manage_multi_budget ON app_budget TYPE bool DEFAULT false;
DEFINE FIELD manage_budget_key ON app_budget TYPE bool DEFAULT false;
DEFINE FIELD manage_budget_key_global_budget ON app_budget TYPE bool DEFAULT false;
DEFINE FIELD manage_commitment_reservation ON app_budget TYPE bool DEFAULT false;
DEFINE FIELD is_manage_committed_amount_by_budget_line ON app_budget TYPE bool DEFAULT false;
DEFINE FIELD check_available_budget ON app_budget TYPE bool DEFAULT false;
DEFINE FIELD check_available_budget_by_move_line ON app_budget TYPE bool DEFAULT false;
DEFINE FIELD budget_distribution_sum_amount_equal_budget_line_amount ON app_budget TYPE bool DEFAULT false;
DEFINE FIELD created_at ON app_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON app_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_budget TYPE int DEFAULT 0;