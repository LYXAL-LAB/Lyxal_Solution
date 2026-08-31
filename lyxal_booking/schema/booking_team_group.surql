-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_team_group                                                     │
-- │  Liaison entre équipes et groupes OIDC                                  │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_team_group TYPE RELATION
    IN booking_group OUT booking_team SCHEMAFULL
    COMMENT "Liaison entre équipes et groupes OIDC"
    PERMISSIONS FOR select, create, update, delete WHERE true;

DEFINE FIELD IF NOT EXISTS created_at ON TABLE booking_team_group TYPE datetime DEFAULT time::now();
