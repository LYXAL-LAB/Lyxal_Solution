-- Extensions de commande de vente pour budget
DEFINE TABLE sale_order_budget SCHEMAFULL;
DEFINE FIELD sale_order_seq ON sale_order_budget TYPE string;
DEFINE FIELD client_partner ON sale_order_budget TYPE record<partner>;
DEFINE FIELD company ON sale_order_budget TYPE record<company>;
DEFINE FIELD order_date ON sale_order_budget TYPE date;
DEFINE FIELD confirmed_date ON sale_order_budget TYPE date;
DEFINE FIELD amount_total_tax_included ON sale_order_budget TYPE decimal;
DEFINE FIELD amount_total_tax_excluded ON sale_order_budget TYPE decimal;
DEFINE FIELD currency ON sale_order_budget TYPE record<currency>;
DEFINE FIELD status_select ON sale_order_budget TYPE int;
DEFINE FIELD sale_order_line_list ON sale_order_budget TYPE array<record<sale_order_line_budget>>;
DEFINE FIELD budget_distribution_sum_amount ON sale_order_budget TYPE decimal;
DEFINE FIELD budget_remaining_amount_to_allocate ON sale_order_budget TYPE decimal;
DEFINE FIELD budget_distribution_generated ON sale_order_budget TYPE bool DEFAULT false;
DEFINE FIELD budget_exceeded_amount ON sale_order_budget TYPE decimal;
DEFINE FIELD is_budget_exceeded ON sale_order_budget TYPE bool DEFAULT false;
DEFINE FIELD budget_control_level_select ON sale_order_budget TYPE int;
DEFINE FIELD created_at ON sale_order_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON sale_order_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON sale_order_budget TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_sale_order_budget_company ON sale_order_budget FIELDS company;
DEFINE INDEX idx_sale_order_budget_client ON sale_order_budget FIELDS client_partner;
DEFINE INDEX idx_sale_order_budget_status ON sale_order_budget FIELDS status_select;
DEFINE INDEX idx_sale_order_budget_date ON sale_order_budget FIELDS order_date;
DEFINE INDEX idx_sale_order_budget_exceeded ON sale_order_budget FIELDS is_budget_exceeded;