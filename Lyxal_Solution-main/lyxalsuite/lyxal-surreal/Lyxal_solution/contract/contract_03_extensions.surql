-- CONTRACT MODULE 3 : EXTENSIONS D'ENTITÉS EXISTANTES
-- Extensions : Invoice, InvoiceLine, SaleOrder, PurchaseOrder, App, Batch, File, etc.

-- Extension Invoice
DEFINE TABLE invoice_contract SCHEMAFULL;
DEFINE FIELD invoice ON invoice_contract TYPE record<invoice>;
DEFINE FIELD contract_set ON invoice_contract TYPE array<record<contract>>;
DEFINE FIELD is_contract_invoice ON invoice_contract TYPE bool DEFAULT false;
DEFINE FIELD operation_sub_type_contract_invoice ON invoice_contract TYPE int DEFAULT 4;
DEFINE FIELD created_at ON invoice_contract TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON invoice_contract TYPE int DEFAULT 0;

-- Extension InvoiceLine
DEFINE TABLE invoice_line_contract SCHEMAFULL;
DEFINE FIELD invoice_line ON invoice_line_contract TYPE record<invoice_line>;
DEFINE FIELD contract_line ON invoice_line_contract TYPE record<contract_line>;
DEFINE FIELD created_at ON invoice_line_contract TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON invoice_line_contract TYPE int DEFAULT 0;

-- Extension SaleOrder
DEFINE TABLE sale_order_contract SCHEMAFULL;
DEFINE FIELD sale_order ON sale_order_contract TYPE record<sale_order>;
DEFINE FIELD contract ON sale_order_contract TYPE record<contract>;
DEFINE FIELD created_at ON sale_order_contract TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON sale_order_contract TYPE int DEFAULT 0;

-- Extension PurchaseOrder
DEFINE TABLE purchase_order_contract SCHEMAFULL;
DEFINE FIELD purchase_order ON purchase_order_contract TYPE record<purchase_order>;
DEFINE FIELD contract ON purchase_order_contract TYPE record<contract>;
DEFINE FIELD created_at ON purchase_order_contract TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON purchase_order_contract TYPE int DEFAULT 0;

-- Extension App
DEFINE TABLE app_contract_extension SCHEMAFULL;
DEFINE FIELD app ON app_contract_extension TYPE record<app>;
DEFINE FIELD app_contract ON app_contract_extension TYPE record<app_contract>;
DEFINE FIELD created_at ON app_contract_extension TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_contract_extension TYPE int DEFAULT 0;

-- Extension Batch
DEFINE TABLE batch_contract SCHEMAFULL;
DEFINE FIELD batch ON batch_contract TYPE record<batch>;
DEFINE FIELD contract_batch ON batch_contract TYPE record<contract_batch>;
DEFINE FIELD created_at ON batch_contract TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON batch_contract TYPE int DEFAULT 0;

-- Extension File
DEFINE TABLE file_contract SCHEMAFULL;
DEFINE FIELD file ON file_contract TYPE record<file>;
DEFINE FIELD contract_version ON file_contract TYPE record<contract_version>;
DEFINE FIELD created_at ON file_contract TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON file_contract TYPE int DEFAULT 0;

-- Extension Pricing
DEFINE TABLE pricing_contract SCHEMAFULL;
DEFINE FIELD pricing ON pricing_contract TYPE record<pricing>;
DEFINE FIELD pricing_type_select_contract_yeb_yer ON pricing_contract TYPE string DEFAULT "YEB/YER";
DEFINE FIELD created_at ON pricing_contract TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON pricing_contract TYPE int DEFAULT 0;

-- Extension AnalyticMoveLine
DEFINE TABLE analytic_move_line_contract SCHEMAFULL;
DEFINE FIELD analytic_move_line ON analytic_move_line_contract TYPE record<analytic_move_line>;
DEFINE FIELD contract_line ON analytic_move_line_contract TYPE record<contract_line>;
DEFINE FIELD created_at ON analytic_move_line_contract TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON analytic_move_line_contract TYPE int DEFAULT 0;

-- Extension AccountManagement
DEFINE TABLE account_management_contract SCHEMAFULL;
DEFINE FIELD account_management ON account_management_contract TYPE record<account_management>;
DEFINE FIELD contract_related_account ON account_management_contract TYPE record<account>;
DEFINE FIELD created_at ON account_management_contract TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON account_management_contract TYPE int DEFAULT 0;

-- Extension AccountConfig
DEFINE TABLE account_config_contract SCHEMAFULL;
DEFINE FIELD account_config ON account_config_contract TYPE record<account_config>;
DEFINE FIELD contract_account_config ON account_config_contract TYPE record<account>;
DEFINE FIELD created_at ON account_config_contract TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON account_config_contract TYPE int DEFAULT 0; 