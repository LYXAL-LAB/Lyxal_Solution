-- Extensions de ligne de facture pour budget
DEFINE TABLE invoice_line_budget SCHEMAFULL;
DEFINE FIELD invoice ON invoice_line_budget TYPE record<invoice_budget>;
DEFINE FIELD product ON invoice_line_budget TYPE record<product>;
DEFINE FIELD product_name ON invoice_line_budget TYPE string;
DEFINE FIELD description ON invoice_line_budget TYPE string;
DEFINE FIELD qty ON invoice_line_budget TYPE decimal;
DEFINE FIELD price ON invoice_line_budget TYPE decimal;
DEFINE FIELD amount_total_tax_included ON invoice_line_budget TYPE decimal;
DEFINE FIELD amount_total_tax_excluded ON invoice_line_budget TYPE decimal;
DEFINE FIELD unit ON invoice_line_budget TYPE record<unit>;
DEFINE FIELD tax_line ON invoice_line_budget TYPE record<tax_line>;
DEFINE FIELD account ON invoice_line_budget TYPE record<account>;
DEFINE FIELD analytic_move_line_list ON invoice_line_budget TYPE array<record<analytic_move_line>>;
DEFINE FIELD budget_distribution_list ON invoice_line_budget TYPE array<record<budget_distribution>>;
DEFINE FIELD budget_distribution_sum_amount ON invoice_line_budget TYPE decimal;
DEFINE FIELD budget_remaining_amount_to_allocate ON invoice_line_budget TYPE decimal;
DEFINE FIELD budget_exceeded_amount ON invoice_line_budget TYPE decimal;
DEFINE FIELD is_budget_exceeded ON invoice_line_budget TYPE bool DEFAULT false;
DEFINE FIELD sequence ON invoice_line_budget TYPE int;
DEFINE FIELD created_at ON invoice_line_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON invoice_line_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON invoice_line_budget TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_invoice_line_budget_invoice ON invoice_line_budget FIELDS invoice;
DEFINE INDEX idx_invoice_line_budget_product ON invoice_line_budget FIELDS product;
DEFINE INDEX idx_invoice_line_budget_exceeded ON invoice_line_budget FIELDS is_budget_exceeded;
