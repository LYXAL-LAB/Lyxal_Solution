-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_group                                                          │
-- │  Groupes d'utilisateurs et de synchronisation OIDC                      │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_group TYPE NORMAL SCHEMAFULL
    COMMENT "Groupes d'utilisateurs et de synchronisation OIDC"
    PERMISSIONS FOR select, create, update, delete WHERE true;

DEFINE FIELD IF NOT EXISTS provider ON TABLE booking_group TYPE string DEFAULT 'oidc';
DEFINE FIELD IF NOT EXISTS external_id ON TABLE booking_group TYPE string;
DEFINE FIELD IF NOT EXISTS display_name ON TABLE booking_group TYPE string;
DEFINE FIELD IF NOT EXISTS source ON TABLE booking_group TYPE string DEFAULT 'oidc';
DEFINE FIELD IF NOT EXISTS updated_at ON TABLE booking_group TYPE datetime DEFAULT time::now();
