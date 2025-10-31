-- Extensions de commande d'achat pour budget
DEFINE TABLE purchase_order_budget SCHEMAFULL;
DEFINE FIELD purchase_order_seq ON purchase_order_budget TYPE string;
DEFINE FIELD supplier_partner ON purchase_order_budget TYPE record<partner>;
DEFINE FIELD company ON purchase_order_budget TYPE record<company>;
DEFINE FIELD order_date ON purchase_order_budget TYPE date;
DEFINE FIELD estimated_receipt_date ON purchase_order_budget TYPE date;
DEFINE FIELD amount_total_tax_included ON purchase_order_budget TYPE decimal;
DEFINE FIELD amount_total_tax_excluded ON purchase_order_budget TYPE decimal;
DEFINE FIELD currency ON purchase_order_budget TYPE record<currency>;
DEFINE FIELD status_select ON purchase_order_budget TYPE int;
DEFINE FIELD purchase_order_line_list ON purchase_order_budget TYPE array<record<purchase_order_line_budget>>;
DEFINE FIELD budget_distribution_sum_amount ON purchase_order_budget TYPE decimal;
DEFINE FIELD budget_remaining_amount_to_allocate ON purchase_order_budget TYPE decimal;
DEFINE FIELD budget_distribution_generated ON purchase_order_budget TYPE bool DEFAULT false;
DEFINE FIELD budget_exceeded_amount ON purchase_order_budget TYPE decimal;
DEFINE FIELD is_budget_exceeded ON purchase_order_budget TYPE bool DEFAULT false;
DEFINE FIELD budget_control_level_select ON purchase_order_budget TYPE int;
DEFINE FIELD created_at ON purchase_order_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON purchase_order_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON purchase_order_budget TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_purchase_order_budget_company ON purchase_order_budget FIELDS company;
DEFINE INDEX idx_purchase_order_budget_supplier ON purchase_order_budget FIELDS supplier_partner;
DEFINE INDEX idx_purchase_order_budget_status ON purchase_order_budget FIELDS status_select;
DEFINE INDEX idx_purchase_order_budget_date ON purchase_order_budget FIELDS order_date;
DEFINE INDEX idx_purchase_order_budget_exceeded ON purchase_order_budget FIELDS is_budget_exceeded;