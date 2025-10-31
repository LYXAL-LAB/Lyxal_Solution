-- Structures de budget
DEFINE TABLE budget_structure SCHEMAFULL;
DEFINE FIELD name ON budget_structure TYPE string;
DEFINE FIELD code ON budget_structure TYPE string;
DEFINE FIELD company ON budget_structure TYPE record<company>;
DEFINE FIELD section1_name ON budget_structure TYPE string;
DEFINE FIELD section2_name ON budget_structure TYPE string;
DEFINE FIELD section3_name ON budget_structure TYPE string;
DEFINE FIELD section4_name ON budget_structure TYPE string;
DEFINE FIELD section5_name ON budget_structure TYPE string;
DEFINE FIELD section1_meta_field ON budget_structure TYPE record<meta_field>;
DEFINE FIELD section2_meta_field ON budget_structure TYPE record<meta_field>;
DEFINE FIELD section3_meta_field ON budget_structure TYPE record<meta_field>;
DEFINE FIELD section4_meta_field ON budget_structure TYPE record<meta_field>;
DEFINE FIELD section5_meta_field ON budget_structure TYPE record<meta_field>;
DEFINE FIELD section1_required ON budget_structure TYPE bool DEFAULT false;
DEFINE FIELD section2_required ON budget_structure TYPE bool DEFAULT false;
DEFINE FIELD section3_required ON budget_structure TYPE bool DEFAULT false;
DEFINE FIELD section4_required ON budget_structure TYPE bool DEFAULT false;
DEFINE FIELD section5_required ON budget_structure TYPE bool DEFAULT false;
DEFINE FIELD is_active ON budget_structure TYPE bool DEFAULT true;
DEFINE FIELD sequence ON budget_structure TYPE int;
DEFINE FIELD description ON budget_structure TYPE string;
DEFINE FIELD created_at ON budget_structure TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON budget_structure TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON budget_structure TYPE int DEFAULT 0;

-- Index pour optimisation

DEFINE INDEX idx_budget_structure_company ON budget_structure FIELDS company;
DEFINE INDEX idx_budget_structure_active ON budget_structure FIELDS is_active;
DEFINE INDEX idx_budget_structure_code ON budget_structure FIELDS code;