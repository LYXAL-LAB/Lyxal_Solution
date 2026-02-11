-- Distribution de budget
DEFINE TABLE budget_distribution SCHEMAFULL;
DEFINE FIELD budget_line ON budget_distribution TYPE record<budget_line>;
DEFINE FIELD budget_level ON budget_distribution TYPE record<budget_level>;
DEFINE FIELD invoice_line ON budget_distribution TYPE record<invoice_line>;
DEFINE FIELD move_line ON budget_distribution TYPE record<move_line>;
DEFINE FIELD purchase_order_line ON budget_distribution TYPE record<purchase_order_line>;
DEFINE FIELD sale_order_line ON budget_distribution TYPE record<sale_order_line>;
DEFINE FIELD amount ON budget_distribution TYPE decimal;
DEFINE FIELD percentage ON budget_distribution TYPE decimal;
DEFINE FIELD distribution_type_select ON budget_distribution TYPE int;
DEFINE FIELD budget_key ON budget_distribution TYPE string;
DEFINE FIELD is_checked ON budget_distribution TYPE bool DEFAULT false;
DEFINE FIELD sequence ON budget_distribution TYPE int;
DEFINE FIELD description ON budget_distribution TYPE string;
DEFINE FIELD created_at ON budget_distribution TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON budget_distribution TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON budget_distribution TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_budget_distribution_budget_line ON budget_distribution FIELDS budget_line;
DEFINE INDEX idx_budget_distribution_budget_level ON budget_distribution FIELDS budget_level;
DEFINE INDEX idx_budget_distribution_type ON budget_distribution FIELDS distribution_type_select;
DEFINE INDEX idx_budget_distribution_checked ON budget_distribution FIELDS is_checked;