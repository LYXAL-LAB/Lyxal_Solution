-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_availability_override (HÉRITÉ / MIGRATION VERS BOOKING_SCHEDULE)│
-- │  Fichier conservé uniquement pour la migration de données existantes.  │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_availability_override TYPE NORMAL SCHEMAFULL
    COMMENT "Surcharges et blocages d'horaires hérités (Remplacé par booking_schedule_override)"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update, delete WHERE event_type.account = $auth.id OR $auth.role = 'admin';

DEFINE FIELD IF NOT EXISTS event_type
    ON TABLE booking_availability_override
    TYPE record<booking_event_type>
    COMMENT "Type d'événement rattaché";

DEFINE FIELD IF NOT EXISTS date
    ON TABLE booking_availability_override
    TYPE string
    VALUE string::trim($value)
    ASSERT $value !~ r"^\d{4}-\d{2}-\d{2}$" == false
    COMMENT "Date d'exception (format YYYY-MM-DD)";

DEFINE FIELD IF NOT EXISTS start_time
    ON TABLE booking_availability_override
    TYPE option<string>
    VALUE IF $value != NONE THEN string::trim($value) ELSE NONE END
    COMMENT "Heure de début spécifique (format HH:MM)";

DEFINE FIELD IF NOT EXISTS end_time
    ON TABLE booking_availability_override
    TYPE option<string>
    VALUE IF $value != NONE THEN string::trim($value) ELSE NONE END
    COMMENT "Heure de fin spécifique (format HH:MM)";

DEFINE FIELD IF NOT EXISTS is_blocked
    ON TABLE booking_availability_override
    TYPE bool
    DEFAULT true
    COMMENT "Si vrai, la journée entière ou la plage est totalement bloquée";

DEFINE INDEX IF NOT EXISTS idx_avail_override_event_type_date
    ON TABLE booking_availability_override
    FIELDS event_type, date;
