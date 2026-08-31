-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_availability_rule (HÉRITÉ / MIGRATION VERS BOOKING_SCHEDULE)   │
-- │  Fichier conservé uniquement pour la migration de données existantes.  │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_availability_rule TYPE NORMAL SCHEMAFULL
    COMMENT "Règles de disponibilité directes héritées (Remplacé par booking_schedule_rule)"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update, delete WHERE event_type.account = $auth.id OR $auth.role = 'admin';

DEFINE FIELD IF NOT EXISTS event_type
    ON TABLE booking_availability_rule
    TYPE record<booking_event_type>
    COMMENT "Type d'événement rattaché";

DEFINE FIELD IF NOT EXISTS day_of_week
    ON TABLE booking_availability_rule
    TYPE int
    ASSERT $value >= 0 AND $value <= 6
    COMMENT "Jour de la semaine (0 = Dimanche, 1 = Lundi, ..., 6 = Samedi)";

DEFINE FIELD IF NOT EXISTS start_time
    ON TABLE booking_availability_rule
    TYPE string
    VALUE string::trim($value)
    ASSERT $value !~ r"^\d{2}:\d{2}$" == false
    COMMENT "Heure de début (format HH:MM, ex: 09:00)";

DEFINE FIELD IF NOT EXISTS end_time
    ON TABLE booking_availability_rule
    TYPE string
    VALUE string::trim($value)
    ASSERT $value !~ r"^\d{2}:\d{2}$" == false AND $value > start_time
    COMMENT "Heure de fin (format HH:MM, ex: 17:00, doit être > start_time)";

DEFINE INDEX IF NOT EXISTS idx_avail_rule_event_type
    ON TABLE booking_availability_rule
    FIELDS event_type;
