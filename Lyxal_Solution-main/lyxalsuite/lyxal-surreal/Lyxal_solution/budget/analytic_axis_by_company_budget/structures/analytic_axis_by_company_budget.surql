-- Configuration analytique par entreprise pour budget
DEFINE TABLE analytic_axis_by_company_budget SCHEMAFULL;
DEFINE FIELD analytic_axis ON analytic_axis_by_company_budget TYPE record<analytic_axis>;
DEFINE FIELD company ON analytic_axis_by_company_budget TYPE record<company>;
DEFINE FIELD sequence ON analytic_axis_by_company_budget TYPE int;
DEFINE FIELD is_budget_key ON analytic_axis_by_company_budget TYPE bool DEFAULT false;
DEFINE FIELD budget_key_sequence ON analytic_axis_by_company_budget TYPE int;
DEFINE FIELD created_at ON analytic_axis_by_company_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON analytic_axis_by_company_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON analytic_axis_by_company_budget TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_analytic_axis_by_company_budget_company ON analytic_axis_by_company_budget FIELDS company;
DEFINE INDEX idx_analytic_axis_by_company_budget_axis ON analytic_axis_by_company_budget FIELDS analytic_axis;
DEFINE INDEX idx_analytic_axis_by_company_budget_key ON analytic_axis_by_company_budget FIELDS is_budget_key;