-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_frequency_limit                                                 │
-- │  Quotas et limites de réservations - Version SurrealDB Avancée          │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_frequency_limit TYPE NORMAL SCHEMAFULL
    COMMENT "Limites de fréquence de réservation par période"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update, delete WHERE event_type.account = $auth.id OR $auth.role = 'admin';

-- ----------------------------------------------------------------------------
-- PROPRIÉTÉS ET LIMITES
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS event_type
    ON TABLE booking_frequency_limit
    TYPE record<booking_event_type>
    COMMENT "Type d'événement rattaché";

DEFINE FIELD IF NOT EXISTS limit_period
    ON TABLE booking_frequency_limit
    TYPE string
    DEFAULT 'day'
    VALUE string::lowercase(string::trim($value))
    ASSERT $value IN ['day', 'week', 'month']
    COMMENT "Période de limitation : day | week | month";

DEFINE FIELD IF NOT EXISTS max_bookings
    ON TABLE booking_frequency_limit
    TYPE int
    ASSERT $value > 0
    COMMENT "Nombre maximal de réservations autorisées sur la période";

-- ----------------------------------------------------------------------------
-- INDEX
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_freq_limit_event_type
    ON TABLE booking_frequency_limit
    FIELDS event_type;
