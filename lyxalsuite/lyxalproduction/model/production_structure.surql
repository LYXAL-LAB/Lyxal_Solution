-- AppProduction
DEFINE TABLE app_production SCHEMAFULL;
DEFINE FIELD enableAutoImputation ON app_production TYPE bool;
DEFINE FIELD enableProdStatusUpdate ON app_production TYPE bool;

-- Employee
DEFINE TABLE employee SCHEMAFULL;
DEFINE FIELD name ON employee TYPE string;
DEFINE FIELD userAccount ON employee TYPE record<user>;
DEFINE FIELD isOperator ON employee TYPE bool;

-- InvoicingProject
DEFINE TABLE invoicing_project SCHEMAFULL;
DEFINE FIELD name ON invoicing_project TYPE string;
DEFINE FIELD project ON invoicing_project TYPE record<project>;
DEFINE FIELD amountToInvoice ON invoicing_project TYPE number;

-- ManufOrder
DEFINE TABLE manuf_order SCHEMAFULL;
DEFINE FIELD name ON manuf_order TYPE string;
DEFINE FIELD productionOrder ON manuf_order TYPE record<production_order>;
DEFINE FIELD saleOrderLineDetail ON manuf_order TYPE record<sale_order_line_details>;
DEFINE FIELD invoicingProject ON manuf_order TYPE record<invoicing_project>;
DEFINE FIELD toInvoice ON manuf_order TYPE bool;

-- OperationOrder
DEFINE TABLE operation_order SCHEMAFULL;
DEFINE FIELD name ON operation_order TYPE string;
DEFINE FIELD manufOrder ON operation_order TYPE record<manuf_order>;
DEFINE FIELD workCenter ON operation_order TYPE record<work_center>;
DEFINE FIELD employee ON operation_order TYPE record<employee>;
DEFINE FIELD duration ON operation_order TYPE duration;
DEFINE FIELD status ON operation_order TYPE string;

-- ProductionOrder
DEFINE TABLE production_order SCHEMAFULL;
DEFINE FIELD name ON production_order TYPE string;
DEFINE FIELD project ON production_order TYPE record<project>;
DEFINE FIELD saleOrderLine ON production_order TYPE record<sale_order_line>;
DEFINE FIELD status ON production_order TYPE string;

-- ProjectTask
DEFINE TABLE project_task SCHEMAFULL;
DEFINE FIELD name ON project_task TYPE string;
DEFINE FIELD project ON project_task TYPE record<project>;
DEFINE FIELD productionOrder ON project_task TYPE record<production_order>;

-- SaleOrderLine
DEFINE TABLE sale_order_line SCHEMAFULL;
DEFINE FIELD product ON sale_order_line TYPE record<product>;
DEFINE FIELD quantity ON sale_order_line TYPE number;
DEFINE FIELD price ON sale_order_line TYPE number;
DEFINE FIELD project ON sale_order_line TYPE record<project>;

-- SaleOrderLineDetails
DEFINE TABLE sale_order_line_details SCHEMAFULL;
DEFINE FIELD saleOrderLine ON sale_order_line_details TYPE record<sale_order_line>;
DEFINE FIELD productionOrder ON sale_order_line_details TYPE record<production_order>;
DEFINE FIELD details ON sale_order_line_details TYPE string;

-- TimesheetLine
DEFINE TABLE timesheet_line SCHEMAFULL;
DEFINE FIELD employee ON timesheet_line TYPE record<employee>;
DEFINE FIELD operationOrder ON timesheet_line TYPE record<operation_order>;
DEFINE FIELD duration ON timesheet_line TYPE duration;
DEFINE FIELD date ON timesheet_line TYPE datetime;

-- WorkCenter
DEFINE TABLE work_center SCHEMAFULL;
DEFINE FIELD name ON work_center TYPE string;
DEFINE FIELD location ON work_center TYPE string;
DEFINE FIELD capacity ON work_center TYPE int;
DEFINE FIELD employees ON work_center TYPE array;
