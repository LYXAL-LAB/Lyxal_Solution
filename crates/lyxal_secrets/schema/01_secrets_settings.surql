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
    COMMENT "Rotation automatique de la clé « secrets » de l'organisation, en jours (30 à 3650 ; 0 : désactivée ; défaut 365)";

DEFINE FIELD OVERWRITE files_key_rotation_days ON TABLE secrets_settings
    TYPE option<int>
    ASSERT $value IS NONE OR $value = 0 OR ($value >= 30 AND $value <= 3650)
    COMMENT "Rotation automatique de la clé « fichiers » de l'organisation, en jours (30 à 3650 ; 0 : désactivée ; défaut 365)";

DEFINE FIELD OVERWRITE grant_default_duration ON TABLE secrets_settings
    TYPE option<duration>
    ASSERT $value IS NONE OR ($value >= 5m AND $value <= 90d)
    COMMENT "Durée d'un accès temporaire quand elle n'est pas donnée (défaut 8 h)";

DEFINE FIELD OVERWRITE grant_max_duration ON TABLE secrets_settings
    TYPE option<duration>
    ASSERT $value IS NONE OR ($value >= 5m AND $value <= 90d)
    COMMENT "Durée maximale d'un accès temporaire (défaut 90 jours)";

DEFINE FIELD OVERWRITE request_ttl ON TABLE secrets_settings
    TYPE option<duration>
    ASSERT $value IS NONE OR ($value >= 1h AND $value <= 30d)
    COMMENT "Délai avant expiration d'une demande sans réponse (défaut 7 jours)";

DEFINE FIELD OVERWRITE access_request_approvals ON TABLE secrets_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 1 AND $value <= 5)
    COMMENT "Approbations requises pour une demande d'accès hors protection (défaut 1)";

DEFINE FIELD OVERWRITE share_default_ttl ON TABLE secrets_settings
    TYPE option<duration>
    ASSERT $value IS NONE OR ($value >= 5m AND $value <= 30d)
    COMMENT "Durée d'un partage quand elle n'est pas donnée (défaut 24 h)";

DEFINE FIELD OVERWRITE share_max_ttl ON TABLE secrets_settings
    TYPE option<duration>
    ASSERT $value IS NONE OR ($value >= 5m AND $value <= 30d)
    COMMENT "Durée maximale d'un partage (défaut 7 jours)";

DEFINE FIELD OVERWRITE share_max_views ON TABLE secrets_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 1 AND $value <= 10)
    COMMENT "Ouvertures maximales d'un partage (défaut 10)";

DEFINE FIELD OVERWRITE updated_at ON TABLE secrets_settings
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE secrets_settings_scope ON TABLE secrets_settings FIELDS scope_key UNIQUE;
