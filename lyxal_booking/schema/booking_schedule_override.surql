-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_schedule_override                                             │
-- │  Exceptions et surcharges de dates spécifiques par planning              │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_schedule_override TYPE NORMAL SCHEMAFULL
    COMMENT "Exceptions et blocages d'horaires pour des dates spécifiques rattachés à un planning"
    PERMISSIONS FOR select, create, update, delete WHERE true;

-- ----------------------------------------------------------------------------
-- PROPRIÉTÉS ET EXCEPTIONS DE DATES
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS schedule
    ON TABLE booking_schedule_override
    TYPE record<booking_schedule>
    COMMENT "Planning réutilisable rattaché";

DEFINE FIELD IF NOT EXISTS date
    ON TABLE booking_schedule_override
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) = 10
    COMMENT "Date d'exception (format YYYY-MM-DD)";

DEFINE FIELD IF NOT EXISTS start_time
    ON TABLE booking_schedule_override
    TYPE option<string>
    VALUE IF $value != NONE { string::trim($value) } ELSE { NONE }
    COMMENT "Heure de début spécifique (format HH:MM)";

DEFINE FIELD IF NOT EXISTS end_time
    ON TABLE booking_schedule_override
    TYPE option<string>
    VALUE IF $value != NONE { string::trim($value) } ELSE { NONE }
    COMMENT "Heure de fin spécifique (format HH:MM)";

DEFINE FIELD IF NOT EXISTS is_blocked
    ON TABLE booking_schedule_override
    TYPE bool
    DEFAULT true
    COMMENT "Si vrai, la journée entière ou la plage est totalement bloquée";

-- ----------------------------------------------------------------------------
-- INDEX
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_schedule_override_schedule_date
    ON TABLE booking_schedule_override
    FIELDS schedule, date;
