-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking                                                                │
-- │  Enregistrement des réservations - Version SurrealDB Avancée            │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking TYPE NORMAL SCHEMAFULL
    COMMENT "Enregistrement principal des réservations de rendez-vous"
    PERMISSIONS
        FOR select WHERE true
        FOR create WHERE true
        FOR update, delete WHERE event_type.account = $auth.id OR host = $auth.id OR $auth.role = 'admin';

-- ----------------------------------------------------------------------------
-- PROPRIÉTÉS ET DONNÉES DU CLIENT / INVITÉ
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS event_type
    ON TABLE booking
    TYPE record<booking_event_type>
    COMMENT "Type d'événement réservé";

DEFINE FIELD IF NOT EXISTS host
    ON TABLE booking
    TYPE option<record<booking_account>>
    COMMENT "Membre hôte réellement affecté au rendez-vous (désigné ou attribué par Round-Robin)";

DEFINE FIELD IF NOT EXISTS assignment_method
    ON TABLE booking
    TYPE string
    DEFAULT 'fixed'
    VALUE string::lowercase(string::trim($value))
    ASSERT $value IN ['fixed', 'round_robin', 'manual', 'collective']
    COMMENT "Méthode d'affectation de l'hôte : fixed | round_robin | manual | collective";

DEFINE FIELD IF NOT EXISTS assigned_at
    ON TABLE booking
    TYPE option<datetime>
    COMMENT "Horodatage exact d'attribution de l'hôte au rendez-vous";

DEFINE FIELD IF NOT EXISTS uid
    ON TABLE booking
    TYPE string
    VALUE string::trim($value)
    COMMENT "Identifiant iCal / UUID unique de la réservation";

DEFINE FIELD IF NOT EXISTS guest_name
    ON TABLE booking
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) > 0
    COMMENT "Nom complet de l'invité / client";

DEFINE FIELD IF NOT EXISTS guest_email
    ON TABLE booking
    TYPE string
    VALUE string::lowercase(string::trim($value))
    ASSERT string::is::email($value)
    COMMENT "Adresse email de l'invité";

DEFINE FIELD IF NOT EXISTS guest_timezone
    ON TABLE booking
    TYPE string
    DEFAULT 'UTC'
    VALUE string::trim($value)
    COMMENT "Fuseau horaire de l'invité au moment de la réservation";

DEFINE FIELD IF NOT EXISTS notes
    ON TABLE booking
    TYPE option<string>
    VALUE {
        IF $value != NONE 
        { string::trim($value) }
     ELSE { NONE }
    }
    COMMENT "Notes, message ou réponses aux questions préalables";

-- ----------------------------------------------------------------------------
-- CRÉNEAU TEMPOREL ET STATUT
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS start_at
    ON TABLE booking
    TYPE datetime
    COMMENT "Date et heure de début du rendez-vous";

DEFINE FIELD IF NOT EXISTS end_at
    ON TABLE booking
    TYPE datetime
    ASSERT $value > start_at
    COMMENT "Date et heure de fin du rendez-vous (doit être > start_at)";

DEFINE FIELD IF NOT EXISTS status
    ON TABLE booking
    TYPE string
    DEFAULT 'confirmed'
    VALUE string::lowercase(string::trim($value))
    ASSERT $value IN ['pending', 'confirmed', 'cancelled', 'rescheduled']
    COMMENT "Statut de la réservation : pending | confirmed | cancelled | rescheduled";

-- ----------------------------------------------------------------------------
-- JETONS ET LIENS SÉCURISÉS
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS cancel_token
    ON TABLE booking
    TYPE string
    VALUE string::trim($value)
    COMMENT "Jeton unique d'annulation sécurisée";

DEFINE FIELD IF NOT EXISTS reschedule_token
    ON TABLE booking
    TYPE string
    VALUE string::trim($value)
    COMMENT "Jeton unique de reprogrammation sécurisée";

DEFINE FIELD IF NOT EXISTS meeting_url
    ON TABLE booking
    TYPE option<string>
    VALUE {
        IF $value != NONE 
        { string::trim($value) }
     ELSE { NONE }
    }
    COMMENT "URL de visioconférence générée (Meet, Jitsi, Zoom)";

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE booking
    TYPE datetime
    DEFAULT time::now()
    VALUE $before OR time::now()
    COMMENT "Date de création de la réservation";

-- ----------------------------------------------------------------------------
-- INDEX D'UNICITÉ ET DE RECHERCHE TEMPORELLE
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_booking_uid
    ON TABLE booking
    FIELDS uid UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_booking_cancel_token
    ON TABLE booking
    FIELDS cancel_token UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_booking_reschedule_token
    ON TABLE booking
    FIELDS reschedule_token UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_booking_host_dates
    ON TABLE booking
    FIELDS host, start_at, end_at;

DEFINE INDEX IF NOT EXISTS idx_booking_event_type_dates
    ON TABLE booking
    FIELDS event_type, start_at, end_at;
