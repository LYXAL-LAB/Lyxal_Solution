-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_session                                                        │
-- │  Sessions utilisateurs actives - Version SurrealDB                       │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_session TYPE NORMAL SCHEMAFULL
    COMMENT "Sessions d'authentification actives"
    PERMISSIONS FOR select, create, update, delete WHERE true;

DEFINE FIELD IF NOT EXISTS account ON TABLE booking_session TYPE record<booking_account>;
DEFINE FIELD IF NOT EXISTS token ON TABLE booking_session TYPE string DEFAULT rand::uuid::v4();
DEFINE FIELD IF NOT EXISTS expires_at ON TABLE booking_session TYPE datetime;
DEFINE FIELD IF NOT EXISTS created_at ON TABLE booking_session TYPE datetime DEFAULT time::now();
DEFINE FIELD IF NOT EXISTS updated_at ON TABLE booking_session TYPE datetime DEFAULT time::now();

DEFINE INDEX IF NOT EXISTS idx_booking_session_token ON TABLE booking_session FIELDS token UNIQUE;
