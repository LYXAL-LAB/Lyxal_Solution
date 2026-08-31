-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_group_member                                                   │
-- │  Relation Graph d'appartenance aux groupes OIDC                         │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_group_member TYPE RELATION
    IN booking_account OUT booking_group SCHEMAFULL
    COMMENT "Relation Graph des membres de groupes OIDC"
    PERMISSIONS FOR select, create, update, delete WHERE true;

DEFINE FIELD IF NOT EXISTS source ON TABLE booking_group_member TYPE string DEFAULT 'oidc';
DEFINE FIELD IF NOT EXISTS created_at ON TABLE booking_group_member TYPE datetime DEFAULT time::now();
