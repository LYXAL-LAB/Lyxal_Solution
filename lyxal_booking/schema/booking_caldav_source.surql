-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_caldav_source                                                  │
-- │  Sources de synchronisation CalDAV/Google/EWS - Version SurrealDB       │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_caldav_source TYPE NORMAL SCHEMAFULL
    COMMENT "Sources de synchronisation de calendrier externe (CalDAV, Google, EWS)"
    PERMISSIONS
        FOR select, create, update, delete WHERE account = $auth.id OR $auth.role = 'admin';

-- ----------------------------------------------------------------------------
-- PROPRIÉTÉS ET CONNEXION DISTANTE
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS account
    ON TABLE booking_caldav_source
    TYPE record<booking_account>
    COMMENT "Compte hôte propriétaire de la source";

DEFINE FIELD IF NOT EXISTS provider_type
    ON TABLE booking_caldav_source
    TYPE string
    DEFAULT 'caldav'
    VALUE string::lowercase(string::trim($value))
    ASSERT $value IN ['caldav', 'google', 'ews', 'icloud']
    COMMENT "Type de fournisseur : caldav | google | ews | icloud";

DEFINE FIELD IF NOT EXISTS name
    ON TABLE booking_caldav_source
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) > 0
    COMMENT "Nom d'identification de la source";

DEFINE FIELD IF NOT EXISTS url
    ON TABLE booking_caldav_source
    TYPE string
    VALUE string::trim($value)
    COMMENT "URL du serveur de calendrier";

DEFINE FIELD IF NOT EXISTS username
    ON TABLE booking_caldav_source
    TYPE string
    VALUE string::trim($value)
    COMMENT "Nom d'utilisateur d'authentification";

DEFINE FIELD IF NOT EXISTS password_enc
    ON TABLE booking_caldav_source
    TYPE option<string>
    COMMENT "Mot de passe chiffré AES-GCM";

DEFINE FIELD IF NOT EXISTS sync_token
    ON TABLE booking_caldav_source
    TYPE option<string>
    COMMENT "Jeton de synchronisation incrémentale";

DEFINE FIELD IF NOT EXISTS last_synced
    ON TABLE booking_caldav_source
    TYPE option<datetime>
    COMMENT "Date de dernière synchronisation";

DEFINE FIELD IF NOT EXISTS enabled
    ON TABLE booking_caldav_source
    TYPE bool
    DEFAULT true
    COMMENT "Indique si la source de synchronisation est active";

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE booking_caldav_source
    TYPE datetime
    DEFAULT time::now()
    VALUE $before OR time::now()
    COMMENT "Date de création de la source";

-- ----------------------------------------------------------------------------
-- INDEX
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_caldav_source_account
    ON TABLE booking_caldav_source
    FIELDS account;
