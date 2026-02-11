DEFINE TABLE project SCHEMAFULL;
DEFINE FIELD name ON project TYPE string;
DEFINE FIELD code ON project TYPE string;
DEFINE FIELD description ON project TYPE string;
DEFINE FIELD customer ON project TYPE record<partner>;
DEFINE FIELD company ON project TYPE record<company>;
DEFINE FIELD contract ON project TYPE record<contract>;
DEFINE FIELD currency ON project TYPE record<currency>;
DEFINE FIELD projectFolder ON project TYPE record<project_folder>;
DEFINE FIELD statusSelect ON project TYPE int;
DEFINE FIELD progress ON project TYPE float;
DEFINE FIELD realMargin ON project TYPE float;
DEFINE FIELD estimatedMargin ON project TYPE float;
DEFINE FIELD invoicingMargin ON project TYPE float;
DEFINE FIELD turnover ON project TYPE float;
DEFINE FIELD cost ON project TYPE float;
DEFINE FIELD isArchived ON project TYPE bool;
DEFINE FIELD startDate ON project TYPE datetime;
DEFINE FIELD endDate ON project TYPE datetime;

DEFINE TABLE project_task SCHEMAFULL;
DEFINE FIELD name ON project_task TYPE string;
DEFINE FIELD description ON project_task TYPE string;
DEFINE FIELD project ON project_task TYPE record<project>;
DEFINE FIELD statusSelect ON project_task TYPE int;
DEFINE FIELD product ON project_task TYPE record<product>;
DEFINE FIELD startDate ON project_task TYPE datetime;
DEFINE FIELD endDate ON project_task TYPE datetime;
DEFINE FIELD duration ON project_task TYPE duration;
DEFINE FIELD progress ON project_task TYPE float;

DEFINE TABLE project_folder SCHEMAFULL;
DEFINE FIELD name ON project_folder TYPE string;
DEFINE FIELD project ON project_folder TYPE record<project>;
DEFINE FIELD path ON project_folder TYPE string;

DEFINE TABLE project_holdback SCHEMAFULL;
DEFINE FIELD project ON project_holdback TYPE record<project>;
DEFINE FIELD statusSelect ON project_holdback TYPE int;
DEFINE FIELD holdbackLineSet ON project_holdback TYPE array<record<project_holdback_line>>;

DEFINE TABLE project_holdback_line SCHEMAFULL;
DEFINE FIELD projectHoldBack ON project_holdback_line TYPE record<project_holdback>;
DEFINE FIELD name ON project_holdback_line TYPE string;
DEFINE FIELD amount ON project_holdback_line TYPE float;
DEFINE FIELD expectedDate ON project_holdback_line TYPE datetime;

DEFINE TABLE manual_element SCHEMAFULL;
DEFINE FIELD project ON manual_element TYPE record<project>;
DEFINE FIELD title ON manual_element TYPE string;
DEFINE FIELD date ON manual_element TYPE datetime;
DEFINE FIELD turnover ON manual_element TYPE float;
DEFINE FIELD cost ON manual_element TYPE float;
DEFINE FIELD currency ON manual_element TYPE record<currency>;
DEFINE FIELD typeSelect ON manual_element TYPE int;
DEFINE FIELD comments ON manual_element TYPE string;

DEFINE TABLE invoicing_project SCHEMAFULL;
DEFINE FIELD project ON invoicing_project TYPE record<project>;
DEFINE FIELD deadlineDate ON invoicing_project TYPE datetime;
DEFINE FIELD attachAnnexToInvoice ON invoicing_project TYPE bool;
DEFINE FIELD statusSelect ON invoicing_project TYPE int;
DEFINE FIELD consolidatePhaseWhenInvoicing ON invoicing_project TYPE bool;

DEFINE TABLE business_project_config SCHEMAFULL;
DEFINE FIELD company ON business_project_config TYPE record<company>;
DEFINE FIELD automaticProject ON business_project_config TYPE bool;
DEFINE FIELD generateProjectOrder ON business_project_config TYPE bool;
DEFINE FIELD projectInvoiceLines ON business_project_config TYPE bool;
DEFINE FIELD projectSaleOrderLines ON business_project_config TYPE bool;
DEFINE FIELD projectPurchaseOrderLines ON business_project_config TYPE bool;