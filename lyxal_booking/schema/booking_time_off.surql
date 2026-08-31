-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_time_off                                                       │
-- │  Congés, absences et vacances bloquant tous les agendas d'un hôte        │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_time_off TYPE NORMAL SCHEMAFULL
    COMMENT "Congés et absences d'un hôte bloquant automatiquement tous ses plannings et types d'événements"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update, delete WHERE account = $auth.id OR $auth.role = 'admin';

-- ----------------------------------------------------------------------------
-- PROPRIÉTÉS ET PLAGE D'ABSENCE
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS account
    ON TABLE booking_time_off
    TYPE record<booking_account>
    COMMENT "Compte hôte en congé / absence";

DEFINE FIELD IF NOT EXISTS start_at
    ON TABLE booking_time_off
    TYPE datetime
    COMMENT "Date et heure de début d'absence";

DEFINE FIELD IF NOT EXISTS end_at
    ON TABLE booking_time_off
    TYPE datetime
    ASSERT $value > start_at
    COMMENT "Date et heure de fin d'absence (doit être > start_at)";

DEFINE FIELD IF NOT EXISTS reason
    ON TABLE booking_time_off
    TYPE option<string>
    VALUE {
        IF $value != NONE 
        { string::trim($value) }
     ELSE { NONE }
    }
    COMMENT "Raison de l'absence (ex: Congés payés, Maladie, Déplacement, Jour férié)";

DEFINE FIELD IF NOT EXISTS all_day
    ON TABLE booking_time_off
    TYPE bool
    DEFAULT true
    COMMENT "Indique s'il s'agit d'une absence journée entière";

DEFINE FIELD IF NOT EXISTS status
    ON TABLE booking_time_off
    TYPE string
    DEFAULT 'approved'
    VALUE string::lowercase(string::trim($value))
    ASSERT $value IN ['pending', 'approved', 'rejected']
    COMMENT "Statut de l'absence : pending | approved | rejected";

-- ----------------------------------------------------------------------------
-- HORODATAGES AUTOMATIQUES
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE booking_time_off
    TYPE datetime
    DEFAULT time::now()
    VALUE $before OR time::now()
    COMMENT "Date d'enregistrement de l'absence";

DEFINE FIELD IF NOT EXISTS updated_at
    ON TABLE booking_time_off
    TYPE datetime
    DEFAULT time::now()
    VALUE time::now()
    COMMENT "Date de dernière modification";

-- ----------------------------------------------------------------------------
-- INDEX
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_time_off_account_dates
    ON TABLE booking_time_off
    FIELDS account, start_at, end_at;
