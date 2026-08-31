-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_setting                                                        │
-- │  Configurations système et paramètres SMTP - Version SurrealDB Avancée  │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_setting TYPE NORMAL SCHEMAFULL
    COMMENT "Paramètres système globaux de réservation et configuration SMTP"
    PERMISSIONS FOR select, create, update, delete WHERE true;

-- ----------------------------------------------------------------------------
-- PROPRIÉTÉS DE CONFIGURATION
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS setting_key
    ON TABLE booking_setting
    TYPE string
    VALUE string::lowercase(string::trim($value))
    ASSERT string::len($value) > 0
    COMMENT "Clé unique de paramètre (ex: base_url, allow_private_hosts, smtp_host)";

DEFINE FIELD IF NOT EXISTS value
    ON TABLE booking_setting
    TYPE option<string>
    VALUE {
        IF $value != NONE 
        { string::trim($value) }
     ELSE { NONE }
    }
    COMMENT "Valeur du paramètre système";

DEFINE FIELD IF NOT EXISTS updated_at
    ON TABLE booking_setting
    TYPE datetime
    DEFAULT time::now()
    VALUE time::now()
    COMMENT "Horodatage de dernière mise à jour du paramètre";

-- ----------------------------------------------------------------------------
-- INDEX D'UNICITÉ
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_booking_setting_key
    ON TABLE booking_setting
    FIELDS setting_key UNIQUE;
