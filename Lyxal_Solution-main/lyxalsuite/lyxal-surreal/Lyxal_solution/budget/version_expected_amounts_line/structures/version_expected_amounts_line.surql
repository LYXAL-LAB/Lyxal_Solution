-- Lignes de montants attendus par version
DEFINE TABLE version_expected_amounts_line SCHEMAFULL;
DEFINE FIELD budget_version ON version_expected_amounts_line TYPE record<budget_version>;
DEFINE FIELD budget_level ON version_expected_amounts_line TYPE record<budget_level>;
DEFINE FIELD period ON version_expected_amounts_line TYPE record<period>;
DEFINE FIELD amount_expected ON version_expected_amounts_line TYPE decimal;
DEFINE FIELD description ON version_expected_amounts_line TYPE string;
DEFINE FIELD sequence ON version_expected_amounts_line TYPE int;
DEFINE FIELD created_at ON version_expected_amounts_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON version_expected_amounts_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON version_expected_amounts_line TYPE int DEFAULT 0;

-- Index

DEFINE INDEX idx_version_expected_amounts_line_version ON version_expected_amounts_line FIELDS budget_version;
DEFINE INDEX idx_version_expected_amounts_line_level ON version_expected_amounts_line FIELDS budget_level;
DEFINE INDEX idx_version_expected_amounts_line_period ON version_expected_amounts_line FIELDS period; 