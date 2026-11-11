-- ============================================================================
-- TABLE  : notification_settings
-- MODULE : lyxal_notification
-- RÔLE   : Réglages de l'installation et de chaque organisation
-- ============================================================================
-- `tenant` absent : réglages de l'installation (repli). Unicité par `scope_key` (un index unique
-- ignore les valeurs absentes).

DEFINE TABLE OVERWRITE notification_settings
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::notification_can({ action: "read_config", tenant: tenant })
        FOR create, update WHERE fn::notification_can({ action: "manage", tenant: tenant })
        FOR delete NONE
    COMMENT "Réglages des notifications (installation, surcharge par organisation)";

DEFINE FIELD OVERWRITE tenant ON TABLE notification_settings
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation (NONE : installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE notification_settings
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée d'unicité : installation ou clé de l'organisation";

DEFINE FIELD OVERWRITE from_name ON TABLE notification_settings
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 128
    COMMENT "Nom d'expéditeur affiché";

DEFINE FIELD OVERWRITE reply_to ON TABLE notification_settings
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 254
    COMMENT "Adresse de réponse";

DEFINE FIELD OVERWRITE max_attempts ON TABLE notification_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 1 AND $value <= 20)
    COMMENT "Tentatives d'envoi au plus";

DEFINE FIELD OVERWRITE retention_days_runs ON TABLE notification_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 1 AND $value <= 3650)
    COMMENT "Conservation des déclenchements et messages (jours)";

DEFINE FIELD OVERWRITE retention_days_log ON TABLE notification_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 1 AND $value <= 3650)
    COMMENT "Conservation du journal de livraison (jours)";

DEFINE FIELD OVERWRITE updated_at ON TABLE notification_settings
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE notification_settings_scope ON TABLE notification_settings FIELDS scope_key UNIQUE;
