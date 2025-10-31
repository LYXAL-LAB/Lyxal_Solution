-- ================================================================
-- TABLE : sale_order_status - Statut de commande de vente
-- ================================================================
DEFINE TABLE sale_order_status SCHEMAFULL;
    COMMENT "Statut de commande de vente";
    
DEFINE FIELD code ON sale_order_status TYPE string; -- DRAFT, CONFIRMED, COMPLETED, CANCELLED
DEFINE FIELD name ON sale_order_status TYPE string;
DEFINE FIELD sequence ON sale_order_status TYPE int;
DEFINE FIELD color ON sale_order_status TYPE string; -- #FF0000
DEFINE FIELD icon ON sale_order_status TYPE string; -- draft, check, complete
DEFINE FIELD is_final ON sale_order_status TYPE bool DEFAULT false;
DEFINE FIELD allows_modification ON sale_order_status TYPE bool DEFAULT true;
DEFINE FIELD is_active ON sale_order_status TYPE bool DEFAULT true;
DEFINE FIELD created_on ON sale_order_status TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON sale_order_status TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX idx_sale_order_status_code ON sale_order_status COLUMNS code UNIQUE;
DEFINE INDEX idx_sale_order_status_sequence ON sale_order_status COLUMNS sequence;