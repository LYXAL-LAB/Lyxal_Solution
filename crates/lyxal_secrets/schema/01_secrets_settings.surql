-- ============================================================================
-- TABLE  : secrets_settings
-- MODULE : lyxal_secrets
-- RÔLE   : Réglages du coffre-fort (installation, surcharge par organisation)
-- ============================================================================
-- Une ligne par portée. Un champ absent prend la valeur de l'installation, sinon la valeur par
-- défaut du module (fn::secrets_settings_effective). La protection contre la purge, une fois
-- activée, ne se retire plus (garde secrets_settings_guard).

DEFINE TABLE OVERWRITE secrets_settings
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE tenant IS NONE OR fn::secrets_can({ action: "list", tenant: tenant })
            OR fn::secrets_can({ action: "worker", tenant: tenant })
        FOR create, update WHERE fn::secrets_can({ action: "settings", tenant: tenant })
        FOR delete NONE
    COMMENT "Réglages du coffre-fort (installation, surcharge par organisation)";

DEFINE FIELD OVERWRITE tenant ON TABLE secrets_settings
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation (NONE : installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE secrets_settings
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée d'unicité : installation ou clé de l'organisation";

DEFINE FIELD OVERWRITE max_versions ON TABLE secrets_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 1 AND $value <= 100)
    COMMENT "Versions conservées par secret (au-delà, la plus ancienne sans étiquette est détruite)";

DEFINE FIELD OVERWRITE deleted_retention_days ON TABLE secrets_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 7 AND $value <= 90)
    COMMENT "Délai entre la suppression d'un secret et sa purge, en jours (7 à 90)";

DEFINE FIELD OVERWRITE purge_protection ON TABLE secrets_settings
    TYPE option<bool>
    COMMENT "Protection contre la purge anticipée ; irréversible une fois activée";

DEFINE FIELD OVERWRITE max_value_bytes ON TABLE secrets_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 1 AND $value <= 1048576)
    COMMENT "Taille maximale d'une valeur en octets (contrôlée par le service Rust), 1 Mio au plus";

DEFINE FIELD OVERWRITE default_visibility ON TABLE secrets_settings
    TYPE option<string>
    ASSERT $value IS NONE OR $value IN ["restricted", "revealable"]
    COMMENT "Visibilité d'un nouveau secret : restricted (un humain ne relit pas) ou revealable";

DEFINE FIELD OVERWRITE expiry_warning_days ON TABLE secrets_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 1 AND $value <= 365)
    COMMENT "Délai d'alerte avant l'échéance d'un secret, en jours";

DEFINE FIELD OVERWRITE tenant_key_rotation_days ON TABLE secrets_settings
    TYPE option<int>
    ASSERT $value IS NONE OR $value = 0 OR ($value >= 30 AND $value <= 3650)
    COMMENT "Rotation automatique de la clé d'organisation, en jours (30 à 3650 ; 0 : désactivée ; défaut 365)";

DEFINE FIELD OVERWRITE updated_at ON TABLE secrets_settings
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE secrets_settings_scope ON TABLE secrets_settings FIELDS scope_key UNIQUE;
