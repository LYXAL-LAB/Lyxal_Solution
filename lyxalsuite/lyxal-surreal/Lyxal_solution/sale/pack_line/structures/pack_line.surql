-- =================================================
-- TABLE : pack_line - Ligne de pack
-- =================================================

DEFINE TABLE pack_line SCHEMAFULL;
    COMMENT "Ligne de pack";

DEFINE FIELD pack ON pack_line TYPE record<pack>;
DEFINE FIELD product ON pack_line TYPE record<product>;
DEFINE FIELD product_name ON pack_line TYPE string;
DEFINE FIELD quantity ON pack_line TYPE float DEFAULT 1;
DEFINE FIELD unit ON pack_line TYPE record<unit>;
DEFINE FIELD price ON pack_line TYPE float;
DEFINE FIELD discount_amount ON pack_line TYPE float;
DEFINE FIELD discount_type_select ON pack_line TYPE int DEFAULT 0;
DEFINE FIELD type_select ON pack_line TYPE int DEFAULT 0;
DEFINE FIELD sequence ON pack_line TYPE int;
DEFINE FIELD created_on ON pack_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON pack_line TYPE datetime DEFAULT time::now();