-- cash-management_structure.surql

DEFINE TABLE forecast SCHEMAFULL;
DEFINE FIELD forecastSeq ON forecast TYPE string;
DEFINE FIELD company ON forecast TYPE record<company>;
DEFINE FIELD bankDetails ON forecast TYPE record<bank_details>;
DEFINE FIELD forecastRecapLineType ON forecast TYPE record<forecast_recap_line_type>;
DEFINE FIELD amount ON forecast TYPE number;
DEFINE FIELD estimatedDate ON forecast TYPE datetime;
DEFINE FIELD realizationDate ON forecast TYPE datetime;
DEFINE FIELD comments ON forecast TYPE string;
DEFINE FIELD forecastGenerator ON forecast TYPE record<forecast_generator>;
DEFINE FIELD typeSelect ON forecast TYPE int;

DEFINE TABLE forecast_generator SCHEMAFULL;
DEFINE FIELD company ON forecast_generator TYPE record<company>;
DEFINE FIELD bankDetails ON forecast_generator TYPE record<bank_details>;
DEFINE FIELD forecastRecapLineType ON forecast_generator TYPE record<forecast_recap_line_type>;
DEFINE FIELD typeSelect ON forecast_generator TYPE int;
DEFINE FIELD amount ON forecast_generator TYPE number;
DEFINE FIELD fromDate ON forecast_generator TYPE datetime;
DEFINE FIELD toDate ON forecast_generator TYPE datetime;
DEFINE FIELD comments ON forecast_generator TYPE string;
DEFINE FIELD periodicitySelect ON forecast_generator TYPE int;

DEFINE TABLE forecast_recap SCHEMAFULL;
DEFINE FIELD forecastRecapSeq ON forecast_recap TYPE string;
DEFINE FIELD company ON forecast_recap TYPE record<company>;
DEFINE FIELD bankDetailsSet ON forecast_recap TYPE array<record<bank_details>>;
DEFINE FIELD userRecap ON forecast_recap TYPE record<user>;
DEFINE FIELD startingBalance ON forecast_recap TYPE number;
DEFINE FIELD endingBalance ON forecast_recap TYPE number;
DEFINE FIELD currentBalance ON forecast_recap TYPE number;
DEFINE FIELD fromDate ON forecast_recap TYPE datetime;
DEFINE FIELD toDate ON forecast_recap TYPE datetime;
DEFINE FIELD forecastRecapLineList ON forecast_recap TYPE array<record<forecast_recap_line>>;
DEFINE FIELD opportunitiesTypeSelect ON forecast_recap TYPE int;
DEFINE FIELD currency ON forecast_recap TYPE record<currency>;
DEFINE FIELD salesMan ON forecast_recap TYPE record<user>;
DEFINE FIELD displayTypeSelect ON forecast_recap TYPE int;
DEFINE FIELD isReport ON forecast_recap TYPE bool;
DEFINE FIELD isComplete ON forecast_recap TYPE bool DEFAULT false;
DEFINE FIELD calculationDate ON forecast_recap TYPE datetime;

DEFINE TABLE forecast_recap_line SCHEMAFULL;
DEFINE FIELD typeSelect ON forecast_recap_line TYPE int;
DEFINE FIELD amount ON forecast_recap_line TYPE number;
DEFINE FIELD estimatedDate ON forecast_recap_line TYPE datetime;
DEFINE FIELD balance ON forecast_recap_line TYPE number;
DEFINE FIELD forecastRecapLineType ON forecast_recap_line TYPE record<forecast_recap_line_type>;
DEFINE FIELD forecastRecap ON forecast_recap_line TYPE record<forecast_recap>;
DEFINE FIELD relatedToSelect ON forecast_recap_line TYPE string;
DEFINE FIELD relatedToSelectId ON forecast_recap_line TYPE int;
DEFINE FIELD relatedToSelectName ON forecast_recap_line TYPE string;
DEFINE FIELD relatedToSelectPaymentMode ON forecast_recap_line TYPE string;
DEFINE FIELD relatedToSelectBankDetails ON forecast_recap_line TYPE string;

DEFINE TABLE forecast_recap_line_type SCHEMAFULL;
DEFINE FIELD sequence ON forecast_recap_line_type TYPE int;
DEFINE FIELD elementSelect ON forecast_recap_line_type TYPE int;
DEFINE FIELD typeSelect ON forecast_recap_line_type TYPE int;
DEFINE FIELD operationTypeSelect ON forecast_recap_line_type TYPE int;
DEFINE FIELD payDaySelect ON forecast_recap_line_type TYPE int;
DEFINE FIELD statusSelect ON forecast_recap_line_type TYPE string;
DEFINE FIELD estimatedDuration ON forecast_recap_line_type TYPE int;
DEFINE FIELD name ON forecast_recap_line_type TYPE string;
DEFINE FIELD statusSelectSet ON forecast_recap_line_type TYPE array<record<opportunity_status>>;
DEFINE FIELD journalSet ON forecast_recap_line_type TYPE array<record<journal>>;
DEFINE FIELD functionalOriginSelect ON forecast_recap_line_type TYPE string;
