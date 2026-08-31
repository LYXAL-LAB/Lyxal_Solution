-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_schedule_rule                                                 │
-- │  Règles récurrentes hebdomadaires rattachées à un planning               │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_schedule_rule TYPE NORMAL SCHEMAFULL
    COMMENT "Règles d'horaires hebdomadaires récurrentes associées à un planning réutilisable"
    PERMISSIONS FOR select, create, update, delete WHERE true;

-- ----------------------------------------------------------------------------
-- PROPRIÉTÉS ET PLAGES HORAIRES
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS schedule
    ON TABLE booking_schedule_rule
    TYPE record<booking_schedule>
    COMMENT "Planning réutilisable rattaché";

DEFINE FIELD IF NOT EXISTS day_of_week
    ON TABLE booking_schedule_rule
    TYPE int
    ASSERT $value >= 0 AND $value <= 6
    COMMENT "Jour de la semaine (0 = Dimanche, 1 = Lundi, ..., 6 = Samedi)";

DEFINE FIELD IF NOT EXISTS start_time
    ON TABLE booking_schedule_rule
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) = 5
    COMMENT "Heure de début de la plage (format HH:MM, ex: 09:00)";

DEFINE FIELD IF NOT EXISTS end_time
    ON TABLE booking_schedule_rule
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) = 5 AND $value > start_time
    COMMENT "Heure de fin de la plage (format HH:MM, ex: 17:00, doit être > start_time)";

-- ----------------------------------------------------------------------------
-- INDEX
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_schedule_rule_schedule
    ON TABLE booking_schedule_rule
    FIELDS schedule;
