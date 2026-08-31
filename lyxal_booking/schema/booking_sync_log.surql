-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_sync_log                                                      │
-- │  Journal des synchronisations distantes et erreurs de diagnostic       │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_sync_log TYPE NORMAL SCHEMAFULL
    COMMENT "Journal d'historique et de diagnostic des synchronisations distantes CalDAV/Google/EWS"
    PERMISSIONS
        FOR select, create, update, delete WHERE source.account = $auth.id OR $auth.role = 'admin';

-- ----------------------------------------------------------------------------
-- PROPRIÉTÉS ET DIAGNOSTIC DE SYNCHRO
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS source
    ON TABLE booking_sync_log
    TYPE record<booking_caldav_source>
    COMMENT "Source distante synchronisée";

DEFINE FIELD IF NOT EXISTS status
    ON TABLE booking_sync_log
    TYPE string
    VALUE string::lowercase(string::trim($value))
    ASSERT $value IN ['success', 'partial', 'failed', 'running']
    COMMENT "Statut de la passe de synchronisation : success | partial | failed | running";

DEFINE FIELD IF NOT EXISTS started_at
    ON TABLE booking_sync_log
    TYPE datetime
    DEFAULT time::now()
    COMMENT "Horodatage de début de la passe de synchronisation";

DEFINE FIELD IF NOT EXISTS finished_at
    ON TABLE booking_sync_log
    TYPE option<datetime>
    COMMENT "Horodatage de fin de la passe de synchronisation";

DEFINE FIELD IF NOT EXISTS events_created
    ON TABLE booking_sync_log
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0
    COMMENT "Nombre d'événements créés en base";

DEFINE FIELD IF NOT EXISTS events_updated
    ON TABLE booking_sync_log
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0
    COMMENT "Nombre d'événements mis à jour";

DEFINE FIELD IF NOT EXISTS events_deleted
    ON TABLE booking_sync_log
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0
    COMMENT "Nombre d'événements supprimés";

DEFINE FIELD IF NOT EXISTS error_code
    ON TABLE booking_sync_log
    TYPE option<string>
    VALUE {
        IF $value != NONE 
        { string::trim($value) }
     ELSE { NONE }
    }
    COMMENT "Code d'erreur système (ex: AUTH_EXPIRED, SERVER_TIMEOUT, CALDAV_PARSE_ERROR)";

DEFINE FIELD IF NOT EXISTS error_message
    ON TABLE booking_sync_log
    TYPE option<string>
    VALUE {
        IF $value != NONE 
        { string::trim($value) }
     ELSE { NONE }
    }
    COMMENT "Message d'erreur détaillé ou trace d'exception";

DEFINE FIELD IF NOT EXISTS attempt
    ON TABLE booking_sync_log
    TYPE int
    DEFAULT 1
    ASSERT $value > 0
    COMMENT "Numéro de tentative de synchronisation";

DEFINE FIELD IF NOT EXISTS metadata
    ON TABLE booking_sync_log
    TYPE option<object>
    COMMENT "Métadonnées et contextes additionnels de diagnostic";

-- ----------------------------------------------------------------------------
-- INDEX
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_sync_log_source_started
    ON TABLE booking_sync_log
    FIELDS source, started_at;
