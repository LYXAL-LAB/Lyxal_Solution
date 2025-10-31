-- =================================================
-- TABLE : sale_batch - Lot de commandes de vente
-- =================================================

DEFINE TABLE sale_batch SCHEMAFULL;
    COMMENT "Lot de commandes de vente";

DEFINE FIELD name ON sale_batch TYPE string;
DEFINE FIELD code ON sale_batch TYPE string;
DEFINE FIELD batch_type_select ON sale_batch TYPE int;
DEFINE FIELD description ON sale_batch TYPE string;
DEFINE FIELD company ON sale_batch TYPE record<company>;
DEFINE FIELD status_select ON sale_batch TYPE int DEFAULT 0;
DEFINE FIELD start_date ON sale_batch TYPE datetime;
DEFINE FIELD end_date ON sale_batch TYPE datetime;
DEFINE FIELD created_on ON sale_batch TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON sale_batch TYPE datetime DEFAULT time::now();