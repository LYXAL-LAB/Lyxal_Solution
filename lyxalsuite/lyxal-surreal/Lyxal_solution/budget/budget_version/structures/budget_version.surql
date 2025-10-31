-- Versions de budget
DEFINE TABLE budget_version SCHEMAFULL;
DEFINE FIELD name ON budget_version TYPE string;
DEFINE FIELD code ON budget_version TYPE string;
DEFINE FIELD budget ON budget_version TYPE record<budget>;
DEFINE FIELD from_date ON budget_version TYPE date;
DEFINE FIELD to_date ON budget_version TYPE date;
DEFINE FIELD status_select ON budget_version TYPE int DEFAULT 1;
DEFINE FIELD is_current_version ON budget_version TYPE bool DEFAULT false;
DEFINE FIELD version_number ON budget_version TYPE int;
DEFINE FIELD description ON budget_version TYPE string;
DEFINE FIELD created_by ON budget_version TYPE record<user>;
DEFINE FIELD created_date ON budget_version TYPE datetime;
DEFINE FIELD version_expected_amounts_line_list ON budget_version TYPE array<record<version_expected_amounts_line>>;
DEFINE FIELD created_at ON budget_version TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON budget_version TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON budget_version TYPE int DEFAULT 0;

-- Index

DEFINE INDEX idx_budget_version_budget ON budget_version FIELDS budget;
DEFINE INDEX idx_budget_version_current ON budget_version FIELDS is_current_version;
DEFINE INDEX idx_budget_version_status ON budget_version FIELDS status_select;
DEFINE INDEX idx_budget_version_number ON budget_version FIELDS version_number;