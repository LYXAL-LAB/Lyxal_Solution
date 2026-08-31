-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_activity                                                       │
-- │  Journal d'historique immuable des modifications (Append-only)          │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_activity TYPE NORMAL SCHEMAFULL
    COMMENT "Historique immuable et audit trail de toutes les actions sur une réservation"
    PERMISSIONS
        FOR select WHERE true
        FOR create WHERE true
        FOR update, delete NONE; -- Journal immuable Append-Only (modification/suppression interdite)

-- ----------------------------------------------------------------------------
-- PROPRIÉTÉS ET ACTIVITÉ
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS booking
    ON TABLE booking_activity
    TYPE record<booking>
    COMMENT "Réservation concernée";

DEFINE FIELD IF NOT EXISTS action
    ON TABLE booking_activity
    TYPE string
    VALUE string::lowercase(string::trim($value))
    ASSERT $value IN [
        'created', 'confirmed', 'cancelled', 'rescheduled', 
        'host_changed', 'resource_added', 'resource_removed', 
        'reminder_sent', 'note_added'
    ]
    COMMENT "Type d'action : created | confirmed | cancelled | rescheduled | host_changed | resource_added | resource_removed | reminder_sent | note_added";

DEFINE FIELD IF NOT EXISTS actor
    ON TABLE booking_activity
    TYPE option<record<booking_account>>
    COMMENT "Compte à l'origine de l'action (NONE si automatique ou client anonyme)";

DEFINE FIELD IF NOT EXISTS metadata
    ON TABLE booking_activity
    TYPE option<object>
    COMMENT "Données de contexte de l'action (ex: anciennes et nouvelles valeurs de dates/statut)";

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE booking_activity
    TYPE datetime
    DEFAULT time::now()
    VALUE $before OR time::now()
    COMMENT "Horodatage immuable de l'activité";

-- ----------------------------------------------------------------------------
-- INDEX
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_booking_activity_booking
    ON TABLE booking_activity
    FIELDS booking, created_at;
