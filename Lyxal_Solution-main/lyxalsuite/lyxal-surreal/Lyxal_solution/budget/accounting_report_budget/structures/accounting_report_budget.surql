-- Rapports comptables pour budget
DEFINE TABLE accounting_report_budget SCHEMAFULL;
DEFINE FIELD name ON accounting_report_budget TYPE string;
DEFINE FIELD report_type ON accounting_report_budget TYPE record<accounting_report_type>;
DEFINE FIELD company ON accounting_report_budget TYPE record<company>;
DEFINE FIELD period ON accounting_report_budget TYPE record<period>;
DEFINE FIELD date_from ON accounting_report_budget TYPE date;
DEFINE FIELD date_to ON accounting_report_budget TYPE date;
DEFINE FIELD currency ON accounting_report_budget TYPE record<currency>;
DEFINE FIELD budget ON accounting_report_budget TYPE record<budget>;
DEFINE FIELD global_budget ON accounting_report_budget TYPE record<global_budget>;
DEFINE FIELD budget_level ON accounting_report_budget TYPE record<budget_level>;
DEFINE FIELD include_expected ON accounting_report_budget TYPE bool DEFAULT true;
DEFINE FIELD include_committed ON accounting_report_budget TYPE bool DEFAULT true;
DEFINE FIELD include_reserved ON accounting_report_budget TYPE bool DEFAULT true;
DEFINE FIELD include_realized ON accounting_report_budget TYPE bool DEFAULT true;
DEFINE FIELD include_available ON accounting_report_budget TYPE bool DEFAULT true;
DEFINE FIELD status_select ON accounting_report_budget TYPE int DEFAULT 1;
DEFINE FIELD export_path ON accounting_report_budget TYPE string;
DEFINE FIELD created_at ON accounting_report_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON accounting_report_budget TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON accounting_report_budget TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_accounting_report_budget_company ON accounting_report_budget FIELDS company;
DEFINE INDEX idx_accounting_report_budget_type ON accounting_report_budget FIELDS report_type;
DEFINE INDEX idx_accounting_report_budget_status ON accounting_report_budget FIELDS status_select;
DEFINE INDEX idx_accounting_report_budget_budget ON accounting_report_budget FIELDS budget;
DEFINE INDEX idx_accounting_report_budget_global_budget ON accounting_report_budget FIELDS global_budget;