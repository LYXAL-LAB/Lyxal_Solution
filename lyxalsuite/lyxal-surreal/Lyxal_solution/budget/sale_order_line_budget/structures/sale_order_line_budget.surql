- Extensions de ligne de commande de vente pour budget
DEFINE TABLE sale_order_line_budget SCHEMAFULL;
DEFINE FIELD sale_order ON sale_order_line_budget TYPE record<sale_order_budget>;
DEFINE FIELD product ON sale_order_line_budget TYPE record<product>;
DEFINE FIELD product_name ON sale_order_line_budget TYPE string;
DEFINE FIELD description ON sale_order_line_budget TYPE string;
DEFINE FIELD qty ON sale_order_line_budget TYPE decimal;
DEFINE FIELD price ON sale_order_line_budget TYPE decimal;
DEFINE FIELD amount_total_tax_included ON sale_order_line_budget TYPE decimal;
DEFINE FIELD amount_total_tax_excluded ON sale_order_line_budget TYPE decimal;
DEFINE FIELD unit ON sale_order_line_budget TYPE record<unit>;
DEFINE FIELD estimated_delivery_date ON sale_order_line_budget TYPE date;
DEFINE FIELD tax_line ON sale_order_line_budget TYPE record<tax_line>;
DEFINE FIELD analytic_move_line_list ON sale_order_line_budget TYPE array<record<analytic_move_line>>;
DEFINE FIELD budget_distribution_list ON sale_order_line_budget TYPE array<record<budget_distribution>>;
DEFINE FIELD budget_distribution_sum_amount ON sale_order_line_budget TYPE decimal;
DEFINE FIELD budget_remaining_amount_to_allocate ON sale_order_line_budget TYPE decimal;
DEFINE FIELD budget_exceeded_amount ON sale_order_line_budget TYPE decimal;
DEFINE FIELD is_budget_exceeded ON sale_order_line_budget TYPE bool DEFAULT false;
DEFINE FIELD sequence ON sale_order_line_budget TYPE int;
DEFINE FIELD created_at ON sale_order_line_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON sale_order_line_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON sale_order_line_budget TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_sale_order_line_budget_order ON sale_order_line_budget FIELDS sale_order;
DEFINE INDEX idx_sale_order_line_budget_product ON sale_order_line_budget FIELDS product;
DEFINE INDEX idx_sale_order_line_budget_exceeded ON sale_order_line_budget FIELDS is_budget_exceeded;