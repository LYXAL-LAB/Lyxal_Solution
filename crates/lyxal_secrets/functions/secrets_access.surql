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
        settings: "secrets.settings.manage",
        access: "secrets.access.manage",
        emergency: "secrets.access.emergency",
        share: "secrets.share.create"
    }[$params.action];
    IF $permission IS NONE { RETURN false; };
    IF fn::auth_has_permission({ permission: $permission, tenant: $params.tenant }) { RETURN true; };
    -- Accès temporaire (secrets_grant) : en plus du droit, pour un chemin et une opération sur un secret
    RETURN $params.path IS NOT NONE AND $params.action INSIDE ["list", "read_value", "write", "delete"]
        AND fn::secrets_grant_covers({ tenant: $params.tenant, path: $params.path, action: $params.action });
} COMMENT "Vrai si l'appelant peut effectuer l'action ({ action : list, read_value, write, delete, restore, purge, audit, settings, access, emergency, share, worker ; tenant : organisation ou NONE pour l'installation ; path : chemin du secret visé }). Permission lyxal_auth de l'organisation, ou, pour list, read_value, write et delete sur un chemin, accès temporaire en cours qui le couvre. Installation : secrets.installation.manage pour toute action sauf worker. Jamais d'erreur";

-- ----------------------------------------------------------------------------
-- fn::secrets_grant_covers (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_grant_covers($params: object) -> bool {
    IF $auth == NONE OR !type::is_record($auth, "auth_session") OR ($params.path IS NOT NONE AND !type::is_string($params.path)) { RETURN false; };
    IF !fn::auth_session_valid({}).valid { RETURN false; };
    LET $s = (SELECT identity, application, organization FROM ONLY $auth);
    -- Un accès vaut dans l'organisation active de la session seulement
    IF $s == NONE OR $s.organization IS NONE OR $s.organization != $params.tenant { RETURN false; };
    LET $now = time::now();
    LET $found = (SELECT VALUE id FROM secrets_grant
        WHERE tenant = $params.tenant
            AND ((subject_identity IS NOT NONE AND subject_identity = $s.identity) OR (subject_application IS NOT NONE AND subject_application = $s.application))
            AND revoked_at IS NONE AND starts_at <= $now AND expires_at > $now
            AND $params.action INSIDE actions
            AND ($params.path IS NONE OR path = $params.path OR (folder AND string::starts_with($params.path, path + "/")))
        LIMIT 1);
    RETURN array::len($found) > 0;
} COMMENT "Interne : vrai si un accès temporaire en cours de l'appelant (identité ou application de la session, organisation active = tenant) couvre le chemin et l'action ({ tenant, path, action }) : chemin exact, ou dossier dont le chemin est un préfixe suivi de / ; sans path, n'importe quel accès en cours pour l'action. Jamais d'erreur";

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
        tenant_key_rotation_days: $own.tenant_key_rotation_days ?? $base.tenant_key_rotation_days ?? 365,
        grant_default_duration: $own.grant_default_duration ?? $base.grant_default_duration ?? 8h,
        grant_max_duration: $own.grant_max_duration ?? $base.grant_max_duration ?? 90d,
        request_ttl: $own.request_ttl ?? $base.request_ttl ?? 7d,
        access_request_approvals: $own.access_request_approvals ?? $base.access_request_approvals ?? 1,
        share_default_ttl: $own.share_default_ttl ?? $base.share_default_ttl ?? 24h,
        share_max_ttl: $own.share_max_ttl ?? $base.share_max_ttl ?? 7d,
        share_max_views: $own.share_max_views ?? $base.share_max_views ?? 10
    };
} COMMENT "Réglages effectifs ({ tenant }) : organisation, sinon installation, sinon valeurs par défaut (10 versions, 30 jours avant purge, 64 Kio, visibilité restricted, alerte 30 jours avant l'échéance, rotation de la clé d'organisation tous les 365 jours, 0 : désactivée ; accès temporaire de 8 h par défaut, 90 jours au plus ; demande sans réponse expirée après 7 jours ; 1 approbation pour une demande d'accès ; partage de 24 h par défaut, 7 jours et 10 ouvertures au plus). La protection contre la purge s'applique si l'organisation ou l'installation l'a activée";

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
