-- Ordres de fabrication
DEFINE TABLE manuf_order SCHEMAFULL;
DEFINE FIELD code ON manuf_order TYPE string;
DEFINE FIELD description ON manuf_order TYPE string;
DEFINE FIELD isToInvoice ON manuf_order TYPE bool DEFAULT false;
DEFINE FIELD invoiced ON manuf_order TYPE bool DEFAULT false;
DEFINE FIELD project ON manuf_order TYPE record<project>;
DEFINE FIELD timesheetLine ON manuf_order TYPE array<timesheet_line>;

-- Opérations de fabrication
DEFINE TABLE operation_order SCHEMAFULL;
DEFINE FIELD code ON operation_order TYPE string;
DEFINE FIELD isToInvoice ON operation_order TYPE bool DEFAULT false;
DEFINE FIELD employeeSet ON operation_order TYPE array<employee>;
DEFINE FIELD timesheetLineList ON operation_order TYPE array<timesheet_line>;

-- Imputations de temps
DEFINE TABLE timesheet_line SCHEMAFULL;
DEFINE FIELD date ON timesheet_line TYPE datetime;
DEFINE FIELD duration ON timesheet_line TYPE duration;
DEFINE FIELD employee ON timesheet_line TYPE record<employee>;
DEFINE FIELD manufOrder ON timesheet_line TYPE record<manuf_order>;
DEFINE FIELD operationOrder ON timesheet_line TYPE record<operation_order>;

-- Lien OF / Projet
DEFINE TABLE production_order SCHEMAFULL;
DEFINE FIELD code ON production_order TYPE string;
DEFINE FIELD project ON production_order TYPE record<project>;

-- Projet de facturation
DEFINE TABLE invoicing_project SCHEMAFULL;
DEFINE FIELD name ON invoicing_project TYPE string;
DEFINE FIELD manufOrderSet ON invoicing_project TYPE array<manuf_order>;

-- Détail ligne de vente
DEFINE TABLE sale_order_line_details SCHEMAFULL;
DEFINE FIELD name ON sale_order_line_details TYPE string;
DEFINE FIELD projectSaleOrderLine ON sale_order_line_details TYPE record<sale_order_line>;

-- Configuration production
DEFINE TABLE app_production SCHEMAFULL;
DEFINE FIELD manageBusinessProduction ON app_production TYPE bool DEFAULT true;
DEFINE FIELD enableTimesheetOnManufOrder ON app_production TYPE bool DEFAULT false;
DEFINE FIELD autoGenerateTimesheetLine ON app_production TYPE bool DEFAULT false;
DEFINE FIELD updateProjectSolDetailsLineTypeSelect ON app_production TYPE int;
