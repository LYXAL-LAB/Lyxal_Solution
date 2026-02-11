-- ================================================================================
-- LYXAL SURREAL - AXELOR BUSINESS PROJECT - MODULE 3 : COMMERCIAL & BATCH
-- ================================================================================
-- Entités : SaleOrder, SaleOrderLine, PurchaseOrder, PurchaseOrderLine, 
--          BusinessProjectBatch, Batch
-- ================================================================================

-- Extensions SaleOrder pour business project (SaleOrder.xml - 506 bytes)
DEFINE TABLE sale_order_business_project SCHEMAFULL;
DEFINE FIELD sale_order ON sale_order_business_project TYPE record<sale_order>;
DEFINE FIELD project ON sale_order_business_project TYPE record<project>;
DEFINE FIELD invoicing_project ON sale_order_business_project TYPE record<invoicing_project>;
DEFINE FIELD is_business_project ON sale_order_business_project TYPE bool DEFAULT false;
DEFINE FIELD project_folder ON sale_order_business_project TYPE record<project_folder>;
DEFINE FIELD project_template ON sale_order_business_project TYPE record<project_template>;
DEFINE FIELD auto_generate_project ON sale_order_business_project TYPE bool DEFAULT false;
DEFINE FIELD project_task_template_set ON sale_order_business_project TYPE array<record<project_task_template>>;
DEFINE FIELD generated_project ON sale_order_business_project TYPE record<project>;
DEFINE FIELD created_at ON sale_order_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON sale_order_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON sale_order_business_project TYPE int DEFAULT 0;

-- Extensions SaleOrderLine pour business project (SaleOrderLine.xml - 1254 bytes)
DEFINE TABLE sale_order_line_business_project SCHEMAFULL;
DEFINE FIELD sale_order_line ON sale_order_line_business_project TYPE record<sale_order_line>;
DEFINE FIELD project ON sale_order_line_business_project TYPE record<project>;
DEFINE FIELD project_task ON sale_order_line_business_project TYPE record<project_task>;
DEFINE FIELD invoicing_project ON sale_order_line_business_project TYPE record<invoicing_project>;
DEFINE FIELD is_project_invoice_line ON sale_order_line_business_project TYPE bool DEFAULT false;
DEFINE FIELD project_task_template ON sale_order_line_business_project TYPE record<project_task_template>;
DEFINE FIELD auto_generate_project_task ON sale_order_line_business_project TYPE bool DEFAULT false;
DEFINE FIELD generated_project_task ON sale_order_line_business_project TYPE record<project_task>;
DEFINE FIELD project_task_category ON sale_order_line_business_project TYPE record<project_task_category>;
DEFINE FIELD is_project_line ON sale_order_line_business_project TYPE bool DEFAULT false;
DEFINE FIELD created_at ON sale_order_line_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON sale_order_line_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON sale_order_line_business_project TYPE int DEFAULT 0;

-- Extensions PurchaseOrder pour business project (PurchaseOrder.xml - 630 bytes)
DEFINE TABLE purchase_order_business_project SCHEMAFULL;
DEFINE FIELD purchase_order ON purchase_order_business_project TYPE record<purchase_order>;
DEFINE FIELD project ON purchase_order_business_project TYPE record<project>;
DEFINE FIELD invoicing_project ON purchase_order_business_project TYPE record<invoicing_project>;
DEFINE FIELD is_business_project ON purchase_order_business_project TYPE bool DEFAULT false;
DEFINE FIELD project_folder ON purchase_order_business_project TYPE record<project_folder>;
DEFINE FIELD auto_generate_project ON purchase_order_business_project TYPE bool DEFAULT false;
DEFINE FIELD generated_project ON purchase_order_business_project TYPE record<project>;
DEFINE FIELD created_at ON purchase_order_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON purchase_order_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON purchase_order_business_project TYPE int DEFAULT 0;

-- Extensions PurchaseOrderLine pour business project (PurchaseOrderLine.xml - 699 bytes)
DEFINE TABLE purchase_order_line_business_project SCHEMAFULL;
DEFINE FIELD purchase_order_line ON purchase_order_line_business_project TYPE record<purchase_order_line>;
DEFINE FIELD project ON purchase_order_line_business_project TYPE record<project>;
DEFINE FIELD project_task ON purchase_order_line_business_project TYPE record<project_task>;
DEFINE FIELD invoicing_project ON purchase_order_line_business_project TYPE record<invoicing_project>;
DEFINE FIELD is_project_invoice_line ON purchase_order_line_business_project TYPE bool DEFAULT false;
DEFINE FIELD auto_generate_project_task ON purchase_order_line_business_project TYPE bool DEFAULT false;
DEFINE FIELD generated_project_task ON purchase_order_line_business_project TYPE record<project_task>;
DEFINE FIELD project_task_category ON purchase_order_line_business_project TYPE record<project_task_category>;
DEFINE FIELD is_project_line ON purchase_order_line_business_project TYPE bool DEFAULT false;
DEFINE FIELD created_at ON purchase_order_line_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON purchase_order_line_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON purchase_order_line_business_project TYPE int DEFAULT 0;

-- Batch Business Project (BusinessProjectBatch.xml - 1898 bytes)
DEFINE TABLE business_project_batch SCHEMAFULL;
DEFINE FIELD code ON business_project_batch TYPE string;
DEFINE FIELD description ON business_project_batch TYPE string;
DEFINE FIELD company ON business_project_batch TYPE record<company>;
DEFINE FIELD action_select ON business_project_batch TYPE int;
DEFINE FIELD project_list ON business_project_batch TYPE array<record<project>>;
DEFINE FIELD invoicing_project_list ON business_project_batch TYPE array<record<invoicing_project>>;
DEFINE FIELD project_task_list ON business_project_batch TYPE array<record<project_task>>;
DEFINE FIELD timesheet_line_list ON business_project_batch TYPE array<record<timesheet_line>>;
DEFINE FIELD expense_line_list ON business_project_batch TYPE array<record<expense_line>>;
DEFINE FIELD sale_order_line_list ON business_project_batch TYPE array<record<sale_order_line>>;
DEFINE FIELD purchase_order_line_list ON business_project_batch TYPE array<record<purchase_order_line>>;
DEFINE FIELD status_select ON business_project_batch TYPE int DEFAULT 1;
DEFINE FIELD batch_date ON business_project_batch TYPE date;
DEFINE FIELD start_date ON business_project_batch TYPE date;
DEFINE FIELD end_date ON business_project_batch TYPE date;
DEFINE FIELD partner ON business_project_batch TYPE record<partner>;
DEFINE FIELD invoice_template ON business_project_batch TYPE record<invoice_template>;
DEFINE FIELD created_at ON business_project_batch TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON business_project_batch TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON business_project_batch TYPE int DEFAULT 0;

-- Extensions Batch pour business project (Batch.xml - 571 bytes)
DEFINE TABLE batch_business_project SCHEMAFULL;
DEFINE FIELD batch ON batch_business_project TYPE record<batch>;
DEFINE FIELD project_list ON batch_business_project TYPE array<record<project>>;
DEFINE FIELD invoicing_project_list ON batch_business_project TYPE array<record<invoicing_project>>;
DEFINE FIELD project_task_list ON batch_business_project TYPE array<record<project_task>>;
DEFINE FIELD timesheet_line_list ON batch_business_project TYPE array<record<timesheet_line>>;
DEFINE FIELD is_business_project_batch ON batch_business_project TYPE bool DEFAULT false;
DEFINE FIELD invoice_template ON batch_business_project TYPE record<invoice_template>;
DEFINE FIELD partner_filter ON batch_business_project TYPE record<partner>;
DEFINE FIELD project_filter ON batch_business_project TYPE record<project>;
DEFINE FIELD created_at ON batch_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON batch_business_project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON batch_business_project TYPE int DEFAULT 0;

-- Index pour optimisation
DEFINE INDEX idx_sale_order_business_project_sale_order ON sale_order_business_project FIELDS sale_order;
DEFINE INDEX idx_sale_order_business_project_project ON sale_order_business_project FIELDS project;
DEFINE INDEX idx_sale_order_business_project_invoicing_project ON sale_order_business_project FIELDS invoicing_project;
DEFINE INDEX idx_sale_order_business_project_is_business ON sale_order_business_project FIELDS is_business_project;

DEFINE INDEX idx_sale_order_line_business_project_sale_order_line ON sale_order_line_business_project FIELDS sale_order_line;
DEFINE INDEX idx_sale_order_line_business_project_project ON sale_order_line_business_project FIELDS project;
DEFINE INDEX idx_sale_order_line_business_project_project_task ON sale_order_line_business_project FIELDS project_task;

DEFINE INDEX idx_purchase_order_business_project_purchase_order ON purchase_order_business_project FIELDS purchase_order;
DEFINE INDEX idx_purchase_order_business_project_project ON purchase_order_business_project FIELDS project;

DEFINE INDEX idx_purchase_order_line_business_project_purchase_order_line ON purchase_order_line_business_project FIELDS purchase_order_line;
DEFINE INDEX idx_purchase_order_line_business_project_project ON purchase_order_line_business_project FIELDS project;

DEFINE INDEX idx_business_project_batch_company ON business_project_batch FIELDS company;
DEFINE INDEX idx_business_project_batch_status ON business_project_batch FIELDS status_select;
DEFINE INDEX idx_business_project_batch_action ON business_project_batch FIELDS action_select;
DEFINE INDEX idx_business_project_batch_date ON business_project_batch FIELDS batch_date;

DEFINE INDEX idx_batch_business_project_batch ON batch_business_project FIELDS batch;
DEFINE INDEX idx_batch_business_project_is_business ON batch_business_project FIELDS is_business_project_batch; 