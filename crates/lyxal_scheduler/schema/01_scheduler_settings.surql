-- ============================================================================
-- TABLE  : scheduler_settings
-- MODULE : lyxal_scheduler
-- RÔLE   : Réglages du planificateur (installation, surcharge par organisation)
-- ============================================================================
-- Une ligne par portée. Un champ absent prend la valeur de l'installation, sinon la valeur par
-- défaut du module (fn::scheduler_settings_effective) : rattrapage 1 h, conservation 30 jours,
-- 10 dernières exécutions gardées, 10 exécutions simultanées par organisation et par file,
-- 1 000 planifications, 10 000 exécutions en attente, arguments de 16 Kio.

DEFINE TABLE OVERWRITE scheduler_settings
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE tenant IS NONE OR fn::scheduler_can({ action: "read", tenant: tenant })
            OR fn::scheduler_can({ action: "worker" })
        FOR create, update WHERE fn::scheduler_can({ action: "settings", tenant: tenant })
        FOR delete NONE
    COMMENT "Réglages du planificateur (installation, surcharge par organisation)";

DEFINE FIELD OVERWRITE tenant ON TABLE scheduler_settings
    TYPE option<record<auth_organization>>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation (NONE : installation)";

DEFINE FIELD OVERWRITE scope_key ON TABLE scheduler_settings
    TYPE string
    VALUE IF $this.tenant IS NONE { "installation" } ELSE { <string> record::id($this.tenant) }
    COMMENT "Portée : installation ou clé de l'organisation";

DEFINE FIELD OVERWRITE catchup_window ON TABLE scheduler_settings
    TYPE option<duration>
    ASSERT $value IS NONE OR ($value >= 1m AND $value <= 30d)
    COMMENT "Fenêtre de rattrapage des échéances manquées (1 min à 30 jours, défaut 1 h)";

DEFINE FIELD OVERWRITE run_retention ON TABLE scheduler_settings
    TYPE option<duration>
    ASSERT $value IS NONE OR ($value >= 1d AND $value <= 3650d)
    COMMENT "Conservation des exécutions terminées (1 à 3650 jours, défaut 30 jours)";

DEFINE FIELD OVERWRITE keep_last_runs ON TABLE scheduler_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 0 AND $value <= 1000)
    COMMENT "Exécutions terminées toujours gardées par planification (0 à 1000, défaut 10)";

DEFINE FIELD OVERWRITE tenant_concurrency ON TABLE scheduler_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 1 AND $value <= 10000)
    COMMENT "Exécutions simultanées d'une organisation dans une file (1 à 10000, défaut 10)";

DEFINE FIELD OVERWRITE max_schedules ON TABLE scheduler_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 1 AND $value <= 1000000)
    COMMENT "Planifications par organisation (défaut 1000)";

DEFINE FIELD OVERWRITE max_pending_runs ON TABLE scheduler_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 1 AND $value <= 10000000)
    COMMENT "Exécutions en attente par organisation (défaut 10000)";

DEFINE FIELD OVERWRITE max_args_bytes ON TABLE scheduler_settings
    TYPE option<int>
    ASSERT $value IS NONE OR ($value >= 256 AND $value <= 1048576)
    COMMENT "Taille maximale des arguments d'une planification ou d'une exécution, en octets (défaut 16 Kio)";

DEFINE FIELD OVERWRITE updated_at ON TABLE scheduler_settings
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE scheduler_settings_scope ON TABLE scheduler_settings FIELDS scope_key UNIQUE;
