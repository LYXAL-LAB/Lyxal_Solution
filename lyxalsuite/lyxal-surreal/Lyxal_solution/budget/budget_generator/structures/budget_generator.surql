-- Générateur de budget
DEFINE TABLE budget_generator SCHEMAFULL;
DEFINE FIELD name ON budget_generator TYPE string;
DEFINE FIELD code ON budget_generator TYPE string;
DEFINE FIELD company ON budget_generator TYPE record<company>;
DEFINE FIELD budget_structure ON budget_generator TYPE record<budget_structure>;
DEFINE FIELD period_duration_select ON budget_generator TYPE int;
DEFINE FIELD year ON budget_generator TYPE record<year>;
DEFINE FIELD from_date ON budget_generator TYPE date;
DEFINE FIELD to_date ON budget_generator TYPE date;
DEFINE FIELD is_generate_from_previous_budget ON budget_generator TYPE bool DEFAULT false;
DEFINE FIELD source_budget ON budget_generator TYPE record<budget>;
DEFINE FIELD generation_type_select ON budget_generator TYPE int;
DEFINE FIELD description ON budget_generator TYPE string;
DEFINE FIELD created_at ON budget_generator TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON budget_generator TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON budget_generator TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_budget_generator_company ON budget_generator FIELDS company;
DEFINE INDEX idx_budget_generator_structure ON budget_generator FIELDS budget_structure;
DEFINE INDEX idx_budget_generator_year ON budget_generator FIELDS year;