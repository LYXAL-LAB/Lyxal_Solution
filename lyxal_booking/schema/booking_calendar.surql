-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_calendar                                                       │
-- │  Calendriers associés aux sources distantes - Version SurrealDB         │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_calendar TYPE NORMAL SCHEMAFULL
    COMMENT "Calendriers associés aux sources distantes"
    PERMISSIONS
        FOR select, create, update, delete WHERE source.account = $auth.id OR $auth.role = 'admin';

-- ----------------------------------------------------------------------------
-- PROPRIÉTÉS DU CALENDRIER
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS source
    ON TABLE booking_calendar
    TYPE record<booking_caldav_source>
    COMMENT "Source CalDAV ou externe rattachée";

DEFINE FIELD IF NOT EXISTS href
    ON TABLE booking_calendar
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) > 0
    COMMENT "Chemin ou URL href unique du calendrier distant";

DEFINE FIELD IF NOT EXISTS display_name
    ON TABLE booking_calendar
    TYPE option<string>
    VALUE {
        IF $value != NONE 
            { string::trim($value) }
        ELSE { NONE }
    }
    COMMENT "Nom d'affichage du calendrier";

DEFINE FIELD IF NOT EXISTS color
    ON TABLE booking_calendar
    TYPE option<string>
    VALUE {
        IF $value != NONE 
            { string::trim($value) }
        ELSE { NONE }
    }
    COMMENT "Code couleur Hex (ex: #3b82f6)";

DEFINE FIELD IF NOT EXISTS ctag
    ON TABLE booking_calendar
    TYPE option<string>
    COMMENT "Jeton CTAG de détection des changements";

DEFINE FIELD IF NOT EXISTS is_busy
    ON TABLE booking_calendar
    TYPE bool
    DEFAULT true
    COMMENT "Si vrai, les événements de ce calendrier bloquent la disponibilité";

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE booking_calendar
    TYPE datetime
    DEFAULT time::now()
    VALUE $before OR time::now()
    COMMENT "Date d'enregistrement du calendrier";

-- ----------------------------------------------------------------------------
-- INDEX
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_calendar_source
    ON TABLE booking_calendar
    FIELDS source;
