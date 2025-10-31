DEFINE TABLE IF NOT EXISTS partner_link 
TYPE RELATION FROM partner TO partner SCHEMAFULL 
COMMENT 'Lien entre partenaires (type de relation configurable)'
PERMISSIONS FULL;

-- ------------------------------
-- FIELDS
-- ------------------------------ 

DEFINE FIELD partnerLinkType ON partner_link TYPE record<partner_link_type> 
COMMENT 'Type de lien';

DEFINE FIELD created_at ON partner_link TYPE datetime DEFAULT time::now() 
COMMENT 'Date de création';
DEFINE FIELD created_by ON partner_link TYPE record<user> 
COMMENT 'Créé par';
DEFINE FIELD updated_at ON partner_link TYPE datetime DEFAULT time::now() 
COMMENT 'Dernière modification';

-- ------------------------------
-- INDEXES
-- ------------------------------ 

DEFINE INDEX idx_partner_link_out_in_type_unique ON partner_link FIELDS out, in, partnerLinkType UNIQUE;