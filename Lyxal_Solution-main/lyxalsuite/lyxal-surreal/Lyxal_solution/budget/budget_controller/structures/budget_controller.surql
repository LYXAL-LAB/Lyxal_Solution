-- Contrôleur de budget
DEFINE TABLE budget_controller SCHEMAFULL;
DEFINE FIELD name ON budget_controller TYPE string;
DEFINE FIELD code ON budget_controller TYPE string;
DEFINE FIELD user ON budget_controller TYPE record<user>;
DEFINE FIELD company ON budget_controller TYPE record<company>;
DEFINE FIELD budget_set ON budget_controller TYPE array<record<budget>>;
DEFINE FIELD global_budget_set ON budget_controller TYPE array<record<global_budget>>;
DEFINE FIELD budget_level_set ON budget_controller TYPE array<record<budget_level>>;
DEFINE FIELD company_department_set ON budget_controller TYPE array<record<company_department>>;
DEFINE FIELD is_active ON budget_controller TYPE bool DEFAULT true;
DEFINE FIELD can_view_budget ON budget_controller TYPE bool DEFAULT true;
DEFINE FIELD can_edit_budget ON budget_controller TYPE bool DEFAULT false;
DEFINE FIELD can_validate_budget ON budget_controller TYPE bool DEFAULT false;
DEFINE FIELD can_control_commitment ON budget_controller TYPE bool DEFAULT false;
DEFINE FIELD description ON budget_controller TYPE string;
DEFINE FIELD created_at ON budget_controller TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON budget_controller TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON budget_controller TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_budget_controller_user ON budget_controller FIELDS user;
DEFINE INDEX idx_budget_controller_company ON budget_controller FIELDS company;
DEFINE INDEX idx_budget_controller_active ON budget_controller FIELDS is_active;