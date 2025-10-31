DEFINE TABLE IF NOT EXISTS partner_link_type TYPE NORMAL SCHEMAFULL 
COMMENT 'Types de relation entre partenaires'
PERMISSIONS FULL;

-- ------------------------------
-- FIELDS
-- ------------------------------ 

DEFINE FIELD name ON partner_link_type TYPE string
COMMENT 'Nom';
DEFINE FIELD typeSelect ON partner_link_type TYPE option<string>
COMMENT 'Type (sélection)';
DEFINE FIELD link1Name ON partner_link_type TYPE option<string>
COMMENT 'Intitulé relation 1';
DEFINE FIELD link2Name ON partner_link_type TYPE option<string>
COMMENT 'Intitulé relation 2';

-- Audit
DEFINE FIELD created_at ON partner_link_type TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON partner_link_type TYPE option<record<user>>;
DEFINE FIELD updated_at ON partner_link_type TYPE datetime DEFAULT time::now();

-- ------------------------------
-- INDEXES
-- ------------------------------ 

DEFINE INDEX idx_base_partner_link_type_name ON base_partner_link_type FIELDS name;
DEFINE INDEX idx_base_partner_link_type_type ON base_partner_link_type FIELDS typeSelect;