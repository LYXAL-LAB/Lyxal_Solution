-- =================================================
-- TABLE : pack - Pack
-- =================================================

DEFINE TABLE pack SCHEMAFULL;
    COMMENT "Pack";

DEFINE FIELD code ON pack TYPE string;
DEFINE FIELD name ON pack TYPE string;
DEFINE FIELD is_show_total ON pack TYPE bool DEFAULT false;
DEFINE FIELD is_hide_unit_amounts ON pack TYPE bool DEFAULT false;
DEFINE FIELD do_not_display_header_and_end_pack ON pack TYPE bool DEFAULT false;
DEFINE FIELD unit ON pack TYPE record<unit>;
DEFINE FIELD currency ON pack TYPE record<currency>;
DEFINE FIELD company ON pack TYPE record<company>;
DEFINE FIELD created_on ON pack TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON pack TYPE datetime DEFAULT time::now();