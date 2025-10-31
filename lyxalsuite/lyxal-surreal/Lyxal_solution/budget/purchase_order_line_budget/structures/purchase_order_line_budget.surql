-- Extensions de ligne de commande d'achat pour budget
DEFINE TABLE purchase_order_line_budget SCHEMAFULL;
DEFINE FIELD purchase_order ON purchase_order_line_budget TYPE record<purchase_order_budget>;
DEFINE FIELD product ON purchase_order_line_budget TYPE record<product>;
DEFINE FIELD product_name ON purchase_order_line_budget TYPE string;
DEFINE FIELD description ON purchase_order_line_budget TYPE string;
DEFINE FIELD qty ON purchase_order_line_budget TYPE decimal;
DEFINE FIELD price ON purchase_order_line_budget TYPE decimal;
DEFINE FIELD amount_total_tax_included ON purchase_order_line_budget TYPE decimal;
DEFINE FIELD amount_total_tax_excluded ON purchase_order_line_budget TYPE decimal;
DEFINE FIELD unit ON purchase_order_line_budget TYPE record<unit>;
DEFINE FIELD estimated_receipt_date ON purchase_order_line_budget TYPE date;
DEFINE FIELD tax_line ON purchase_order_line_budget TYPE record<tax_line>;
DEFINE FIELD analytic_move_line_list ON purchase_order_line_budget TYPE array<record<analytic_move_line>>;
DEFINE FIELD budget_distribution_list ON purchase_order_line_budget TYPE array<record<budget_distribution>>;
DEFINE FIELD budget_distribution_sum_amount ON purchase_order_line_budget TYPE decimal;
DEFINE FIELD budget_remaining_amount_to_allocate ON purchase_order_line_budget TYPE decimal;
DEFINE FIELD budget_exceeded_amount ON purchase_order_line_budget TYPE decimal;
DEFINE FIELD is_budget_exceeded ON purchase_order_line_budget TYPE bool DEFAULT false;
DEFINE FIELD sequence ON purchase_order_line_budget TYPE int;
DEFINE FIELD created_at ON purchase_order_line_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON purchase_order_line_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON purchase_order_line_budget TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_purchase_order_line_budget_order ON purchase_order_line_budget FIELDS purchase_order;
DEFINE INDEX idx_purchase_order_line_budget_product ON purchase_order_line_budget FIELDS product;
DEFINE INDEX idx_purchase_order_line_budget_exceeded ON purchase_order_line_budget FIELDS is_budget_exceeded;