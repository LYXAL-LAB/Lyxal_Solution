-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_watcher                                                        │
-- │  Observateurs / e-mails notifiés - Version SurrealDB Avancée            │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_watcher TYPE NORMAL SCHEMAFULL
    COMMENT "E-mails d'observateurs notifiés lors d'une réservation"
    PERMISSIONS
        FOR select WHERE event_type.account = $auth.id OR $auth.role = 'admin'
        FOR create, update, delete WHERE event_type.account = $auth.id OR $auth.role = 'admin';

-- ----------------------------------------------------------------------------
-- PROPRIÉTÉS ET VALIDATION EMAIL
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS event_type
    ON TABLE booking_watcher
    TYPE record<booking_event_type>
    COMMENT "Type d'événement rattaché";

DEFINE FIELD IF NOT EXISTS email
    ON TABLE booking_watcher
    TYPE string
    VALUE string::lowercase(string::trim($value))
    ASSERT string::is::email($value)
    COMMENT "Adresse email de l'observateur";

-- ----------------------------------------------------------------------------
-- INDEX
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_booking_watcher_event_type
    ON TABLE booking_watcher
    FIELDS event_type;
