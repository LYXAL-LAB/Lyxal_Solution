-- Index sur les champs critiques
DEFINE INDEX idx_manuf_order_code ON TABLE manuf_order COLUMNS code;
DEFINE INDEX idx_manuf_invoiced ON TABLE manuf_order COLUMNS invoiced;
DEFINE INDEX idx_manuf_project ON TABLE manuf_order COLUMNS project;

DEFINE INDEX idx_operation_code ON TABLE operation_order COLUMNS code;
DEFINE INDEX idx_operation_employee ON TABLE operation_order COLUMNS employeeSet;

DEFINE INDEX idx_timesheet_date ON TABLE timesheet_line COLUMNS date;
DEFINE INDEX idx_timesheet_manuf ON TABLE timesheet_line COLUMNS manufOrder;
DEFINE INDEX idx_timesheet_operation ON TABLE timesheet_line COLUMNS operationOrder;

DEFINE INDEX idx_production_project ON TABLE production_order COLUMNS project;
DEFINE INDEX idx_invoicing_manuf_set ON TABLE invoicing_project COLUMNS manufOrderSet;
DEFINE INDEX idx_sol_details_line ON TABLE sale_order_line_details COLUMNS projectSaleOrderLine;
