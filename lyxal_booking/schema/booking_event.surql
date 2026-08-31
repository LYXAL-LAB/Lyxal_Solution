-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_event                                                          │
-- │  Événements d'agenda synchronisés - Version SurrealDB Avancée          │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_event TYPE NORMAL SCHEMAFULL
    COMMENT "Événements d'agenda synchronisés depuis les calendriers externes"
    PERMISSIONS
        FOR select, create, update, delete WHERE calendar.source.account = $auth.id OR $auth.role = 'admin';

-- ----------------------------------------------------------------------------
-- PROPRIÉTÉS ET REPRÉSENTATION ICAL
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS calendar
    ON TABLE booking_event
    TYPE record<booking_calendar>
    COMMENT "Calendrier rattaché";

DEFINE FIELD IF NOT EXISTS uid
    ON TABLE booking_event
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) > 0
    COMMENT "Identifiant UID iCal unique";

DEFINE FIELD IF NOT EXISTS etag
    ON TABLE booking_event
    TYPE option<string>
    COMMENT "Jeton ETag de version d'événement";

DEFINE FIELD IF NOT EXISTS summary
    ON TABLE booking_event
    TYPE option<string>
    VALUE {
        IF $value != NONE 
        { string::trim($value) }
     ELSE { NONE }
    }
    COMMENT "Titre / résumé de l'événement";

DEFINE FIELD IF NOT EXISTS description
    ON TABLE booking_event
    TYPE option<string>
    VALUE {
        IF $value != NONE 
        { string::trim($value) }
     ELSE { NONE }
    }
    COMMENT "Description de l'événement";

DEFINE FIELD IF NOT EXISTS location
    ON TABLE booking_event
    TYPE option<string>
    VALUE {
        IF $value != NONE 
        { string::trim($value) }
     ELSE { NONE }
    }
    COMMENT "Lieu ou lien de réunion";

-- ----------------------------------------------------------------------------
-- DATES ET CRÉNEAUX DE DISPONIBILITÉ
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS start_at
    ON TABLE booking_event
    TYPE datetime
    COMMENT "Date et heure de début de l'événement";

DEFINE FIELD IF NOT EXISTS end_at
    ON TABLE booking_event
    TYPE datetime
    ASSERT $value >= start_at
    COMMENT "Date et heure de fin de l'événement (doit être >= start_at)";

DEFINE FIELD IF NOT EXISTS all_day
    ON TABLE booking_event
    TYPE bool
    DEFAULT false
    COMMENT "Indique s'il s'agit d'un événement journée entière";

DEFINE FIELD IF NOT EXISTS timezone
    ON TABLE booking_event
    TYPE option<string>
    VALUE {
        IF $value != NONE 
        { string::trim($value) }
     ELSE { NONE }
    }
    COMMENT "Fuseau horaire de l'événement";

DEFINE FIELD IF NOT EXISTS rrule
    ON TABLE booking_event
    TYPE option<string>
    COMMENT "Règle de récurrence iCal RRULE";

DEFINE FIELD IF NOT EXISTS status
    ON TABLE booking_event
    TYPE string
    DEFAULT 'confirmed'
    VALUE string::lowercase(string::trim($value))
    ASSERT $value IN ['confirmed', 'tentative', 'cancelled']
    COMMENT "Statut d'occupation : confirmed | tentative | cancelled";

DEFINE FIELD IF NOT EXISTS raw_ical
    ON TABLE booking_event
    TYPE option<string>
    COMMENT "Données iCalendar brutes (.ics)";

DEFINE FIELD IF NOT EXISTS synced_at
    ON TABLE booking_event
    TYPE datetime
    DEFAULT time::now()
    VALUE time::now()
    COMMENT "Horodatage de dernière synchronisation";

-- ----------------------------------------------------------------------------
-- INDEX
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_booking_event_uid
    ON TABLE booking_event
    FIELDS uid UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_booking_event_calendar
    ON TABLE booking_event
    FIELDS calendar;

DEFINE INDEX IF NOT EXISTS idx_booking_event_dates
    ON TABLE booking_event
    FIELDS start_at, end_at;
