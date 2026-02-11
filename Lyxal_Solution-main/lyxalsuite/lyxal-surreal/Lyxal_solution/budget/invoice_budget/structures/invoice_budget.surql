-- Extensions de facture pour budget
DEFINE TABLE invoice_budget SCHEMAFULL;
DEFINE FIELD partner ON invoice_budget TYPE record<partner>;
DEFINE FIELD company ON invoice_budget TYPE record<company>;
DEFINE FIELD invoice_date ON invoice_budget TYPE date;
DEFINE FIELD due_date ON invoice_budget TYPE date;
DEFINE FIELD amount_total_tax_included ON invoice_budget TYPE decimal;
DEFINE FIELD amount_total_tax_excluded ON invoice_budget TYPE decimal;
DEFINE FIELD currency ON invoice_budget TYPE record<currency>;
DEFINE FIELD status_select ON invoice_budget TYPE int;
DEFINE FIELD operation_type_select ON invoice_budget TYPE int;
DEFINE FIELD budget_distribution_sum_amount ON invoice_budget TYPE decimal;
DEFINE FIELD budget_remaining_amount_to_allocate ON invoice_budget TYPE decimal;
DEFINE FIELD budget_distribution_generated ON invoice_budget TYPE bool DEFAULT false;
DEFINE FIELD budget_exceeded_amount ON invoice_budget TYPE decimal;
DEFINE FIELD invoice_line_list ON invoice_budget TYPE array<record<invoice_line_budget>>;
DEFINE FIELD is_budget_exceeded ON invoice_budget TYPE bool DEFAULT false;
DEFINE FIELD budget_control_level_select ON invoice_budget TYPE int;
DEFINE FIELD created_at ON invoice_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON invoice_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON invoice_budget TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_invoice_budget_company ON invoice_budget FIELDS company;
DEFINE INDEX idx_invoice_budget_partner ON invoice_budget FIELDS partner;
DEFINE INDEX idx_invoice_budget_status ON invoice_budget FIELDS status_select;
DEFINE INDEX idx_invoice_budget_date ON invoice_budget FIELDS invoice_date;
DEFINE INDEX idx_invoice_budget_exceeded ON invoice_budget FIELDS is_budget_exceeded;