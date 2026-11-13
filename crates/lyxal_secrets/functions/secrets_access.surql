-- ============================================================================
-- FONCTIONS : droits, appelant et réglages effectifs
-- MODULE    : lyxal_secrets
-- ============================================================================
-- Contrôle unique des droits, utilisé par les PERMISSIONS des tables et par les fonctions
-- publiques.

-- ----------------------------------------------------------------------------
-- fn::secrets_can
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_can($params: object) -> bool {
    IF fn::auth_session_valid({}).system { RETURN true; };
    IF $params.action = "worker" { RETURN fn::auth_has_permission({ permission: "secrets.worker" }); };
    IF $params.tenant IS NONE {
        RETURN fn::auth_has_permission({ permission: "secrets.installation.manage" });
    };
    LET $permission = {
        list: "secrets.secret.list",
        read_value: "secrets.value.read",
        write: "secrets.secret.write",
        delete: "secrets.secret.delete",
        restore: "secrets.secret.restore",
        purge: "secrets.secret.purge",
        audit: "secrets.audit.read",
        settings: "secrets.settings.manage"
    }[$params.action];
    IF $permission IS NONE { RETURN false; };
    RETURN fn::auth_has_permission({ permission: $permission, tenant: $params.tenant });
} COMMENT "Vrai si l'appelant peut effectuer l'action ({ action : list, read_value, write, delete, restore, purge, audit, settings, worker ; tenant : organisation ou NONE pour l'installation }). Installation : secrets.installation.manage pour toute action sauf worker. Jamais d'erreur";

-- ----------------------------------------------------------------------------
-- fn::secrets_caller (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_caller() -> object {
    LET $context = fn::auth_context({});
    IF !$context.ok {
        RETURN { valid: false, system: false, identity: NONE, application: NONE, kind: NONE, session: NONE, consumer: NONE };
    };
    LET $c = $context.data;
    RETURN {
        valid: true,
        system: $c.system,
        identity: $c.identity,
        application: $c.application,
        kind: $c.kind,
        session: $c.session,
        consumer: IF $c.application IS NONE { NONE } ELSE { <string> $c.application }
    };
} COMMENT "Interne : appelant { valid, system, identity, application, kind (interactive, service, api_key), session, consumer } d'après le contrat public fn::auth_context ; consumer = identifiant de l'application (auth_application:…) d'une session de programme";

-- ----------------------------------------------------------------------------
-- fn::secrets_settings_effective (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_settings_effective($params: object) -> object {
    LET $base = (SELECT * FROM ONLY secrets_settings WHERE scope_key = "installation" LIMIT 1) ?? {};
    LET $own = IF $params.tenant IS NONE { {} } ELSE {
        (SELECT * FROM ONLY secrets_settings WHERE scope_key = <string> record::id($params.tenant) LIMIT 1) ?? {}
    };
    RETURN {
        max_versions: $own.max_versions ?? $base.max_versions ?? 10,
        deleted_retention_days: $own.deleted_retention_days ?? $base.deleted_retention_days ?? 30,
        purge_protection: ($own.purge_protection ?? false) OR ($base.purge_protection ?? false),
        max_value_bytes: $own.max_value_bytes ?? $base.max_value_bytes ?? 65536,
        default_visibility: $own.default_visibility ?? $base.default_visibility ?? "restricted",
        expiry_warning_days: $own.expiry_warning_days ?? $base.expiry_warning_days ?? 30,
        tenant_key_rotation_days: $own.tenant_key_rotation_days ?? $base.tenant_key_rotation_days ?? 365
    };
} COMMENT "Réglages effectifs ({ tenant }) : organisation, sinon installation, sinon valeurs par défaut (10 versions, 30 jours avant purge, 64 Kio, visibilité restricted, alerte 30 jours avant l'échéance, rotation de la clé d'organisation tous les 365 jours, 0 : désactivée). La protection contre la purge s'applique si l'organisation ou l'installation l'a activée";

-- ----------------------------------------------------------------------------
-- fn::secrets_tenant_string (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_tenant_string($tenant: option<record<auth_organization>>) -> option<string> {
    RETURN IF $tenant IS NONE { NONE } ELSE { <string> $tenant };
} COMMENT "Interne : organisation sous forme de chaîne pour les charges d'événements (NONE : installation)";

-- ----------------------------------------------------------------------------
-- fn::secrets_publish (interne, appelée par les événements)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_publish($event_type: string, $secret: object, $extra: object) -> bool {
    LET $caller = fn::secrets_caller();
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: $event_type,
        producer: "lyxal_secrets",
        source: $secret.id,
        payload: object::extend({
            secret_id: <string> $secret.id,
            path: $secret.path,
            tenant: fn::secrets_tenant_string($secret.tenant),
            actor: IF $caller.identity IS NONE { NONE } ELSE { <string> $caller.identity },
            application: IF $caller.application IS NONE { NONE } ELSE { <string> $caller.application }
        }, $extra),
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
    RETURN true;
} COMMENT "Interne (événements du module) : publie un événement secrets.* sur le bus ($event_type, fiche $secret, champs $extra) : identifiants, chemin, organisation, auteur ; jamais de valeur. Une publication refusée fait échouer la mutation";
