DEFINE TABLE IF NOT EXISTS partner_price_list TYPE NORMAL SCHEMAFULL 
COMMENT 'Listes de prix associées au partenaire'
PERMISSIONS FULL;

-- ------------------------------
-- FIELDS
-- ------------------------------ 

DEFINE FIELD label ON partner_price_list TYPE string
COMMENT 'Libellé';
DEFINE FIELD tags ON partner_price_list TYPE array<record<system_tag>> DEFAULT []
COMMENT 'Tags de type (ex: price_list_type_sale / price_list_type_purchase)';
DEFINE FIELD priceListSet ON partner_price_list TYPE array<record<base_price_list>> DEFAULT []
COMMENT 'Listes de prix référencées';
DEFINE FIELD isExclusive ON partner_price_list TYPE bool DEFAULT false
COMMENT 'Exclusif';
DEFINE FIELD currency ON partner_price_list TYPE record<base_currency>
COMMENT 'Devise';
DEFINE FIELD created_at ON partner_price_list TYPE datetime DEFAULT time::now() 
COMMENT 'Date de création';
DEFINE FIELD created_by ON partner_price_list TYPE record<user> 
COMMENT 'Créé par';
DEFINE FIELD updated_at ON partner_price_list TYPE datetime DEFAULT time::now() 
COMMENT 'Dernière modification';

-- ------------------------------
-- INDEXES
-- ------------------------------ 

DEFINE INDEX idx_partner_price_list_label ON partner_price_list FIELDS label;
DEFINE INDEX idx_partner_price_list_currency ON partner_price_list FIELDS currency;
DEFINE INDEX idx_partner_price_list_created_at ON partner_price_list FIELDS created_at;
DEFINE INDEX idx_partner_price_list_created_by ON partner_price_list FIELDS created_by;
DEFINE INDEX idx_partner_price_list_updated_at ON partner_price_list FIELDS updated_at;