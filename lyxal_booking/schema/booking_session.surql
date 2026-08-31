-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_session                                                        │
-- │  Sessions utilisateurs actives - Version SurrealDB                       │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_session TYPE NORMAL SCHEMAFULL
    COMMENT "Sessions d'authentification actives"
    PERMISSIONS
        FOR select, create, update, delete WHERE account = $auth.id OR $auth.role = 'admin';

DEFINE FIELD IF NOT EXISTS account ON TABLE booking_session TYPE record<booking_account>;
DEFINE FIELD IF NOT EXISTS token ON TABLE booking_session TYPE string;
DEFINE FIELD IF NOT EXISTS expires_at ON TABLE booking_session TYPE datetime;
DEFINE FIELD IF NOT EXISTS created_at ON TABLE booking_session TYPE datetime DEFAULT time::now();
DEFINE FIELD IF NOT EXISTS updated_at ON TABLE booking_session TYPE datetime DEFAULT time::now();
