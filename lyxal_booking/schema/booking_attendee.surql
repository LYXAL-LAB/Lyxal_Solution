-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_attendee                                                        │
-- │  Participants / invités aux réservations - Version SurrealDB Avancée     │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_attendee TYPE NORMAL SCHEMAFULL
    COMMENT "Participants et invités additionnels pour une réservation"
    PERMISSIONS
        FOR select WHERE true
        FOR create WHERE true
        FOR update, delete WHERE booking.event_type.account = $auth.id OR $auth.role = 'admin';

-- ----------------------------------------------------------------------------
-- PROPRIÉTÉS ET VALIDATIONS DES PARTICIPANTS
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS booking
    ON TABLE booking_attendee
    TYPE record<booking>
    COMMENT "Réservation rattachée";

DEFINE FIELD IF NOT EXISTS name
    ON TABLE booking_attendee
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) > 0
    COMMENT "Nom du participant";

DEFINE FIELD IF NOT EXISTS email
    ON TABLE booking_attendee
    TYPE string
    VALUE string::lowercase(string::trim($value))
    ASSERT string::is::email($value)
    COMMENT "Email du participant";

DEFINE FIELD IF NOT EXISTS status
    ON TABLE booking_attendee
    TYPE string
    DEFAULT 'accepted'
    VALUE string::lowercase(string::trim($value))
    ASSERT $value IN ['needs_action', 'accepted', 'declined', 'tentative']
    COMMENT "Statut de réponse du participant : needs_action | accepted | declined | tentative";

-- ----------------------------------------------------------------------------
-- INDEX DE RECHERCHE
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_booking_attendee_booking
    ON TABLE booking_attendee
    FIELDS booking;
