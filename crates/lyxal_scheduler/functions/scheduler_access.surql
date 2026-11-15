-- ============================================================================
-- FONCTIONS : droits, appelant, réglages effectifs, journal et bus
-- MODULE    : lyxal_scheduler
-- ============================================================================
-- Contrôle unique des droits (fn::scheduler_can), utilisé par les PERMISSIONS des tables, par
-- les gardes et par les fonctions publiques.

-- ----------------------------------------------------------------------------
-- fn::scheduler_can
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_can($params: object) -> bool {
    IF fn::auth_session_valid({}).system { RETURN true; };
    IF $params.action = "worker" { RETURN fn::auth_has_permission({ permission: "scheduler.worker" }); };
    IF $params.action = "installation" { RETURN fn::auth_has_permission({ permission: "scheduler.installation.manage" }); };
    IF $params.action = "catalog" {
        IF fn::auth_has_permission({ permission: "scheduler.worker" }) OR fn::auth_has_permission({ permission: "scheduler.installation.manage" }) { RETURN true; };
        LET $context = fn::auth_context({});
        IF !$context.ok OR $context.data.organization IS NONE { RETURN false; };
        RETURN fn::auth_has_permission({ permission: "scheduler.schedule.read", tenant: $context.data.organization })
            OR fn::auth_has_permission({ permission: "scheduler.schedule.write", tenant: $context.data.organization });
    };
    LET $permission = {
        read: "scheduler.schedule.read",
        write: "scheduler.schedule.write",
        run_manage: "scheduler.run.manage",
        calendar: "scheduler.calendar.write",
        settings: "scheduler.settings.manage"
    }[$params.action];
    IF $permission IS NONE { RETURN false; };
    LET $base = IF $params.tenant IS NONE {
        fn::auth_has_permission({ permission: "scheduler.installation.manage" })
    } ELSE {
        fn::auth_has_permission({ permission: $permission, tenant: $params.tenant })
    };
    IF !$base OR $params.task IS NONE { RETURN $base; };
    -- Permission propre de la tâche (T2) : une tâche introuvable ou illisible vaut refus
    IF !type::is_record($params.task, "scheduler_task") { RETURN false; };
    LET $task = (SELECT permission FROM ONLY $params.task);
    IF $task == NONE { RETURN false; };
    RETURN $task.permission IS NONE OR fn::auth_has_permission({ permission: $task.permission, tenant: $params.tenant });
} COMMENT "Vrai si l'appelant peut effectuer l'action ({ action : read, write, run_manage, calendar, settings, catalog, installation, worker ; tenant : organisation ou NONE pour l'installation ; task : tâche dont la permission propre est aussi exigée }). Session système : tout. Organisation : permission scheduler.* de l'organisation active ; installation : scheduler.installation.manage ; catalog (tâches et files) : lecture ou écriture dans l'organisation active, installation ou moteur ; worker : scheduler.worker. Jamais d'erreur";

-- ----------------------------------------------------------------------------
-- fn::scheduler_caller (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_caller() -> object {
    LET $context = fn::auth_context({});
    IF !$context.ok {
        RETURN { valid: false, system: false, identity: NONE, application: NONE, kind: NONE, session: NONE };
    };
    LET $c = $context.data;
    RETURN { valid: true, system: $c.system, identity: $c.identity, application: $c.application, kind: $c.kind, session: $c.session };
} COMMENT "Interne : appelant { valid, system, identity, application, kind, session } d'après le contrat public fn::auth_context";

-- ----------------------------------------------------------------------------
-- fn::scheduler_scope_key (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_scope_key($tenant: option<record<auth_organization>>) -> string {
    RETURN IF $tenant IS NONE { "installation" } ELSE { <string> record::id($tenant) };
} COMMENT "Interne : portée d'un enregistrement : installation, ou clé de l'organisation";

-- ----------------------------------------------------------------------------
-- fn::scheduler_language (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_language($params: any) -> option<string> {
    RETURN IF type::is_object($params) AND type::is_string($params.language) { $params.language } ELSE { NONE };
} COMMENT "Interne : langue demandée par l'appelant avant validation des paramètres (NONE : langue par défaut de l'erreur)";

-- ----------------------------------------------------------------------------
-- fn::scheduler_invalid (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_invalid($params: any, $fields: object) -> object {
    RETURN fn::error_result("SCHEDULER_INVALID_PARAMETERS", fn::scheduler_language($params), { fields: $fields });
} COMMENT "Interne : erreur SCHEDULER_INVALID_PARAMETERS avec le détail par champ du rapport du Core";

-- ----------------------------------------------------------------------------
-- fn::scheduler_settings_effective (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_settings_effective($params: object) -> object {
    LET $base = (SELECT * FROM ONLY scheduler_settings WHERE scope_key = "installation" LIMIT 1) ?? {};
    LET $own = IF $params.tenant IS NONE { {} } ELSE {
        (SELECT * FROM ONLY scheduler_settings WHERE scope_key = fn::scheduler_scope_key($params.tenant) LIMIT 1) ?? {}
    };
    RETURN {
        catchup_window: $own.catchup_window ?? $base.catchup_window ?? 1h,
        run_retention: $own.run_retention ?? $base.run_retention ?? 30d,
        keep_last_runs: $own.keep_last_runs ?? $base.keep_last_runs ?? 10,
        tenant_concurrency: $own.tenant_concurrency ?? $base.tenant_concurrency ?? 10,
        max_schedules: $own.max_schedules ?? $base.max_schedules ?? 1000,
        max_pending_runs: $own.max_pending_runs ?? $base.max_pending_runs ?? 10000,
        max_args_bytes: $own.max_args_bytes ?? $base.max_args_bytes ?? 16384
    };
} COMMENT "Réglages effectifs ({ tenant }) : organisation, sinon installation, sinon valeurs par défaut (rattrapage 1 h, conservation 30 jours, 10 dernières exécutions gardées, 10 exécutions simultanées par organisation et par file, 1000 planifications, 10000 exécutions en attente, arguments de 16 Kio)";

-- ----------------------------------------------------------------------------
-- fn::scheduler_tenant_string (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_tenant_string($tenant: option<record<auth_organization>>) -> option<string> {
    RETURN IF $tenant IS NONE { NONE } ELSE { <string> $tenant };
} COMMENT "Interne : organisation sous forme de chaîne pour le journal et les charges d'événements (NONE : installation)";

-- ----------------------------------------------------------------------------
-- fn::scheduler_publish (interne, appelée par les événements)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_publish($event_type: string, $source: any, $payload: object) -> bool {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: $event_type,
        producer: "lyxal_scheduler",
        source: $source,
        payload: $payload,
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
    RETURN true;
} COMMENT "Interne (événements du module) : publie un événement scheduler.* sur le bus ($event_type, enregistrement source, charge : organisation, planification, tâche, exécution, date prévue, tentative, code d'erreur ; jamais d'arguments). Une publication refusée fait échouer la mutation";

-- ----------------------------------------------------------------------------
-- fn::scheduler_audit_write (interne, appelée par les événements)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_audit_write($entry: object) -> object {
    LET $caller = fn::scheduler_caller();
    LET $actor = IF $caller.identity IS NOT NONE { <string> $caller.identity } ELSE IF $caller.application IS NOT NONE { <string> $caller.application } ELSE { NONE };
    LET $created = (CREATE ONLY scheduler_audit CONTENT {
        tenant: $entry.tenant,
        action: $entry.action,
        actor: $actor,
        session_kind: IF $caller.system { "system" } ELSE { $caller.kind },
        ip: $session.ip,
        schedule: IF $entry.schedule IS NONE { NONE } ELSE { <string> $entry.schedule },
        run: IF $entry.run IS NONE { NONE } ELSE { <string> $entry.run },
        details: $entry.details ?? {}
    });
    RETURN $created;
} COMMENT "Interne (événements du module) : ajoute une entrée au journal ({ tenant, action, schedule, run, details }) ; auteur, type de session et adresse lus dans la session ; jamais d'arguments";
