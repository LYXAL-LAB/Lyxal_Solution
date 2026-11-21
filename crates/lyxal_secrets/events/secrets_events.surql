-- ============================================================================
-- EVENTS : lyxal_secrets
-- MODULE : lyxal_secrets
-- RÔLE   : Gardes des écritures, journal chaîné, publication des événements secrets.*
-- ============================================================================
-- Exécutés dans la transaction de la mutation : une garde qui refuse, un journal qui ne peut
-- pas être écrit ou une publication refusée font échouer la mutation (.agents/AGENTS.md §5.6.1).
-- Les gardes valent aussi pour une écriture directe dans les tables. Jamais de valeur.

-- ----------------------------------------------------------------------------
-- Réglages : protection contre la purge irréversible ; journal
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE secrets_settings_guard ON TABLE secrets_settings
WHEN $event = "UPDATE" AND $before.purge_protection = true AND $after.purge_protection != true
THEN {
    THROW "SECRETS_PURGE_PROTECTED";
};

DEFINE EVENT OVERWRITE secrets_settings_journal ON TABLE secrets_settings
WHEN $event IN ["CREATE", "UPDATE"]
THEN {
    fn::secrets_audit_write({
        tenant: $after.tenant,
        action: "settings.update",
        details: {
            max_versions: $after.max_versions,
            deleted_retention_days: $after.deleted_retention_days,
            purge_protection: $after.purge_protection,
            max_value_bytes: $after.max_value_bytes,
            default_visibility: $after.default_visibility,
            expiry_warning_days: $after.expiry_warning_days,
            tenant_key_rotation_days: $after.tenant_key_rotation_days,
            files_key_rotation_days: $after.files_key_rotation_days,
            grant_default_duration: $after.grant_default_duration,
            grant_max_duration: $after.grant_max_duration,
            request_ttl: $after.request_ttl,
            access_request_approvals: $after.access_request_approvals,
            share_default_ttl: $after.share_default_ttl,
            share_max_ttl: $after.share_max_ttl,
            share_max_views: $after.share_max_views
        }
    });
};

-- ----------------------------------------------------------------------------
-- Fiches : gardes
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE secrets_secret_create_guard ON TABLE secrets_secret
WHEN $event = "CREATE"
THEN {
    LET $refusal = fn::secrets_secret_create_refusal($after);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

DEFINE EVENT OVERWRITE secrets_secret_update_guard ON TABLE secrets_secret
WHEN $event = "UPDATE"
THEN {
    LET $refusal = fn::secrets_secret_update_refusal($before, $after);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

DEFINE EVENT OVERWRITE secrets_secret_delete_guard ON TABLE secrets_secret
WHEN $event = "DELETE"
THEN {
    LET $refusal = fn::secrets_secret_delete_refusal($before);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

-- ----------------------------------------------------------------------------
-- Fiches : journal et bus
-- ----------------------------------------------------------------------------
-- Ajout d'une version : la fiche change de dernière version et d'étiquettes ; l'opération est
-- journalisée et publiée par la version (secrets.version.created), pas ici. Une fiche emportée par
-- la suppression de son organisation n'est ni journalisée ni publiée (le journal part avec elle).

DEFINE EVENT OVERWRITE secrets_secret_journal ON TABLE secrets_secret
WHEN ($event = "CREATE")
    OR ($event = "UPDATE" AND $before.latest_version = $after.latest_version)
    OR ($event = "DELETE" AND ($before.tenant IS NONE OR record::exists($before.tenant)))
THEN {
    LET $doc = IF $event = "DELETE" { $before } ELSE { $after };
    LET $action = IF $event = "CREATE" { "secret.create" }
        ELSE IF $event = "DELETE" { "secret.purge" }
        ELSE IF $before.state != $after.state {
            IF $after.state = "deleted" { "secret.delete" }
            ELSE IF $before.state = "deleted" { "secret.restore" }
            ELSE IF $after.state = "disabled" { "secret.disable" }
            ELSE { "secret.enable" }
        }
        ELSE IF $before.labels != $after.labels { "version.label" }
        -- Alertes posées par le worker (fn::secrets_due_mark)
        ELSE IF $before.expired_notified_at IS NONE AND $after.expired_notified_at IS NOT NONE { "secret.expired" }
        ELSE IF $before.expiry_warned_at IS NONE AND $after.expiry_warned_at IS NOT NONE { "secret.expiring" }
        ELSE IF $before.rotation_notified_at IS NONE AND $after.rotation_notified_at IS NOT NONE { "secret.rotation_due" }
        ELSE IF $before.last_check_at != $after.last_check_at AND $after.last_check_at IS NOT NONE { "rotation.check" }
        ELSE { "secret.update" };
    -- Mise à jour sans changement visible (updated_at seul) : rien à journaliser
    LET $fields = IF $event = "UPDATE" AND $action = "secret.update" {
        array::filter(["kind", "description", "contact", "consumers", "tags", "metadata", "visibility", "expires_at", "rotation_period", "next_rotation_at", "owner", "owner_application"],
            |$f| $before[$f] != $after[$f])
    } ELSE { [] };
    IF $action != "secret.update" OR array::len($fields) > 0 {
        fn::secrets_audit_write({
            tenant: $doc.tenant,
            action: $action,
            secret: $doc.id,
            path: $doc.path,
            details: IF $action = "version.label" { { before: $before.labels, after: $after.labels } }
                ELSE IF $action = "secret.update" { { fields: $fields } }
                ELSE IF $action = "secret.delete" { { purge_at: $after.purge_at } }
                ELSE IF $action = "secret.create" { { kind: $after.kind, visibility: $after.visibility } }
                ELSE IF $action IN ["secret.expiring", "secret.expired"] { { expires_at: $after.expires_at } }
                ELSE IF $action = "secret.rotation_due" { { next_rotation_at: $after.next_rotation_at } }
                ELSE IF $action = "rotation.check" { { ok: $after.last_check_ok, code: $after.last_check_code } }
                ELSE { {} },
            outcome: IF $action = "rotation.check" AND !$after.last_check_ok { "failure" } ELSE { "success" }
        });
        LET $event_type = {
            "secret.create": "secrets.secret.created",
            "secret.update": "secrets.secret.updated",
            "secret.disable": "secrets.secret.disabled",
            "secret.enable": "secrets.secret.enabled",
            "secret.delete": "secrets.secret.deleted",
            "secret.restore": "secrets.secret.restored",
            "secret.purge": "secrets.secret.purged",
            "version.label": "secrets.version.labeled",
            "secret.expiring": "secrets.secret.expiring",
            "secret.expired": "secrets.secret.expired",
            "secret.rotation_due": "secrets.secret.rotation_due",
            "rotation.check": "secrets.rotation.checked"
        }[$action];
        fn::secrets_publish($event_type, $doc, IF $action = "version.label" { { labels: $after.labels } }
            ELSE IF $action = "secret.update" { { fields: $fields } }
            ELSE IF $action IN ["secret.expiring", "secret.expired"] { { expires_at: <string> $after.expires_at } }
            ELSE IF $action = "secret.rotation_due" { { next_rotation_at: <string> $after.next_rotation_at } }
            ELSE IF $action = "rotation.check" { { ok: $after.last_check_ok, code: $after.last_check_code } }
            ELSE { {} });
    };
};

-- ----------------------------------------------------------------------------
-- Versions : gardes, journal et bus
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE secrets_version_create_guard ON TABLE secrets_version
WHEN $event = "CREATE"
THEN {
    LET $refusal = fn::secrets_version_create_refusal($after);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

DEFINE EVENT OVERWRITE secrets_version_update_guard ON TABLE secrets_version
WHEN $event = "UPDATE"
THEN {
    LET $refusal = fn::secrets_version_update_refusal($before, $after);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

DEFINE EVENT OVERWRITE secrets_version_journal ON TABLE secrets_version
WHEN $event = "CREATE" OR ($event = "UPDATE" AND ($before.state != $after.state OR $before.key_id != $after.key_id))
THEN {
    LET $secret = (SELECT id, tenant, path FROM ONLY $after.secret);
    LET $action = IF $event = "CREATE" { "version.create" }
        ELSE IF $after.state = "destroyed" { "version.destroy" }
        ELSE IF $before.state != $after.state { IF $after.state = "disabled" { "version.disable" } ELSE { "version.enable" } }
        ELSE { "version.reseal" };
    fn::secrets_audit_write({
        tenant: $secret.tenant,
        action: $action,
        secret: $secret.id,
        path: $secret.path,
        version: $after.number,
        details: IF $action = "version.reseal" { { key_id_before: $before.key_id, key_id: $after.key_id } }
            ELSE IF $action = "version.create" { { key_id: $after.key_id } }
            ELSE { {} }
    });
    -- Le rescellement ne change pas la valeur : rien à publier
    IF $action != "version.reseal" {
        fn::secrets_publish({
            "version.create": "secrets.version.created",
            "version.destroy": "secrets.version.destroyed",
            "version.disable": "secrets.version.disabled",
            "version.enable": "secrets.version.enabled"
        }[$action], $secret, { number: $after.number });
    };
};

-- ----------------------------------------------------------------------------
-- Tickets de lecture : garde et journal (aucune valeur n'est remise sans cette entrée)
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE secrets_read_ticket_guard ON TABLE secrets_read_ticket
WHEN $event = "CREATE"
THEN {
    LET $caller = fn::secrets_caller();
    IF $after.actor != $caller.identity OR $after.application != $caller.application
        OR $after.used_at IS NOT NONE OR $after.expires_at > time::now() + 60s OR $after.created_at > time::now() {
        THROW "SECRETS_READ_TICKET_INVALID";
    };
    LET $refusal = fn::secrets_read_refusal($after);
    IF $refusal IS NOT NONE { THROW $refusal.code; };
    LET $secret = (SELECT id, tenant, path FROM ONLY $after.secret);
    fn::secrets_audit_write({
        tenant: $secret.tenant,
        action: "secret.read",
        secret: $secret.id,
        path: $secret.path,
        version: $after.number,
        details: { ticket: <string> $after.id, consumer: $after.consumer }
    });
};

DEFINE EVENT OVERWRITE secrets_read_ticket_update_guard ON TABLE secrets_read_ticket
WHEN $event = "UPDATE"
THEN {
    IF $before.used_at IS NOT NONE OR $after.used_at IS NONE { THROW "SECRETS_READ_TICKET_INVALID"; };
};

-- ----------------------------------------------------------------------------
-- Versions : jamais supprimées tant que leur secret existe (seule la purge les emporte)
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE secrets_version_delete_guard ON TABLE secrets_version
WHEN $event = "DELETE"
THEN {
    IF record::exists($before.secret) { THROW "SECRETS_VERSION_STATE_INVALID"; };
};

-- ----------------------------------------------------------------------------
-- Clés des organisations : transitions gardées, journal (jamais de matière de clé)
-- ----------------------------------------------------------------------------
-- active → decrypt_only → destroyed ; la clé scellée ne change qu'au rescellement par une nouvelle
-- clé maîtresse (même état) ou à la destruction (effacée). Une clé emportée par la suppression
-- de son organisation n'est pas journalisée (le journal part avec elle).

DEFINE EVENT OVERWRITE secrets_tenant_key_guard ON TABLE secrets_tenant_key
WHEN $event = "UPDATE"
THEN {
    LET $allowed = { active: ["active", "decrypt_only"], decrypt_only: ["decrypt_only", "destroyed"], destroyed: [] }[$before.state];
    IF $after.state NOTINSIDE $allowed { THROW "SECRETS_TENANT_KEY_UNAVAILABLE"; };
    IF $after.state = "destroyed" AND $after.wrapped IS NOT NONE { THROW "SECRETS_TENANT_KEY_UNAVAILABLE"; };
    IF $after.state != "destroyed" AND $after.wrapped IS NONE { THROW "SECRETS_TENANT_KEY_UNAVAILABLE"; };
    IF $before.wrapped != $after.wrapped AND $after.state != "destroyed" AND $before.state != $after.state { THROW "SECRETS_TENANT_KEY_UNAVAILABLE"; };
};

DEFINE EVENT OVERWRITE secrets_tenant_key_journal ON TABLE secrets_tenant_key
WHEN $event = "CREATE" OR ($event = "UPDATE" AND ($before.state != $after.state OR $before.wrapped != $after.wrapped))
THEN {
    LET $action = IF $event = "CREATE" { "key.create" }
        ELSE IF $after.state = "destroyed" { "key.destroy" }
        ELSE IF $before.state != $after.state { "key.retire" }
        ELSE { "key.rewrap" };
    fn::secrets_audit_write({
        tenant: $after.tenant,
        action: $action,
        details: {
            key_id: $after.key_id,
            purpose: $after.purpose,
            master_key_id: $after.master_key_id,
            master_key_id_before: IF $action = "key.rewrap" { $before.master_key_id } ELSE { NONE },
            requested_by: $after.requested_by
        }
    });
};

-- ----------------------------------------------------------------------------
-- Rotations : garde, journal et bus
-- ----------------------------------------------------------------------------
-- Démarrage, bascule, échec et annulation sont publiés ; les étapes intermédiaires, les nouveaux
-- essais et les réservations du worker sont journalisés seulement (réservation : rien).

DEFINE EVENT OVERWRITE secrets_rotation_guard ON TABLE secrets_rotation
WHEN $event IN ["CREATE", "UPDATE"]
THEN {
    LET $refusal = fn::secrets_rotation_refusal($event, $before, $after);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

DEFINE EVENT OVERWRITE secrets_rotation_journal ON TABLE secrets_rotation
WHEN $event = "CREATE" OR ($event = "UPDATE" AND ($before.state != $after.state OR $before.attempts != $after.attempts))
THEN {
    LET $secret = (SELECT id, tenant, path FROM ONLY $after.secret);
    LET $action = IF $event = "CREATE" { "rotation.start" }
        ELSE IF $before.state = $after.state { "rotation.retry" }
        ELSE IF $after.state = "succeeded" { "rotation.succeed" }
        ELSE IF $after.state = "failed" { "rotation.fail" }
        ELSE IF $after.state = "cancelled" { "rotation.cancel" }
        ELSE { "rotation.step" };
    fn::secrets_audit_write({
        tenant: $secret.tenant,
        action: $action,
        outcome: IF $action IN ["rotation.fail", "rotation.retry"] { "failure" } ELSE { "success" },
        secret: $secret.id,
        path: $secret.path,
        version: $after.pending_number,
        details: {
            rotation: <string> $after.id,
            state: $after.state,
            emergency: $after.emergency,
            attempts: $after.attempts,
            code: $after.last_error,
            next_attempt_at: $after.next_attempt_at,
            reason: IF $action = "rotation.start" { $after.reason } ELSE { NONE }
        }
    });
    LET $event_type = {
        "rotation.start": "secrets.rotation.started",
        "rotation.succeed": "secrets.rotation.succeeded",
        "rotation.fail": "secrets.rotation.failed",
        "rotation.cancel": "secrets.rotation.cancelled"
    }[$action];
    IF $event_type IS NOT NONE {
        fn::secrets_publish($event_type, $secret, {
            rotation: <string> $after.id,
            emergency: $after.emergency,
            number: $after.pending_number,
            previous_number: $after.previous_number,
            code: $after.last_error
        });
    };
};

-- ----------------------------------------------------------------------------
-- Accès, demandes, protections : gardes, journal et bus
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE secrets_grant_guard ON TABLE secrets_grant
WHEN $event IN ["CREATE", "UPDATE"]
THEN {
    LET $refusal = fn::secrets_grant_refusal($event, $before, $after);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

DEFINE EVENT OVERWRITE secrets_grant_journal ON TABLE secrets_grant
WHEN $event = "CREATE" OR ($event = "UPDATE" AND $before.revoked_at IS NONE AND $after.revoked_at IS NOT NONE)
THEN {
    LET $action = IF $event = "UPDATE" { "access.revoke" } ELSE IF $after.emergency { "access.emergency" } ELSE { "access.grant" };
    LET $subject = IF $after.subject_identity IS NOT NONE { <string> $after.subject_identity } ELSE { <string> $after.subject_application };
    fn::secrets_audit_write({
        tenant: $after.tenant,
        action: $action,
        path: $after.path,
        details: { grant: <string> $after.id, subject: $subject, folder: $after.folder, actions: $after.actions,
            expires_at: $after.expires_at, reason: $after.reason, request: IF $after.request IS NONE { NONE } ELSE { <string> $after.request } }
    });
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: { "access.grant": "secrets.access.granted", "access.revoke": "secrets.access.revoked", "access.emergency": "secrets.access.emergency" }[$action],
        producer: "lyxal_secrets",
        source: $after.id,
        payload: { grant_id: <string> $after.id, tenant: <string> $after.tenant, subject: $subject, path: $after.path, folder: $after.folder,
            actions: $after.actions, expires_at: <string> $after.expires_at, reason: $after.reason, actor: fn::secrets_actor() },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE secrets_request_guard ON TABLE secrets_request
WHEN $event IN ["CREATE", "UPDATE"]
THEN {
    LET $refusal = fn::secrets_request_refusal($event, $before, $after);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

DEFINE EVENT OVERWRITE secrets_request_journal ON TABLE secrets_request
WHEN $event = "CREATE" OR ($event = "UPDATE" AND ($before.state != $after.state OR $before.approvals != $after.approvals))
THEN {
    -- Les passages par applying et ses retours en arrière ne se journalisent pas : seul le résultat compte
    LET $action = IF $event = "CREATE" { "request.create" }
        ELSE IF $after.state = $before.state { "request.approve" }
        ELSE { {
            approved: "request.approve", rejected: "request.reject", cancelled: "request.cancel",
            expired: "request.expire", applied: "request.apply"
        }[$after.state] };
    IF $action IS NOT NONE {
        fn::secrets_audit_write({
            tenant: $after.tenant,
            action: $action,
            outcome: IF $action IN ["request.reject", "request.expire"] { "failure" } ELSE { "success" },
            secret: $after.secret,
            path: $after.path,
            version: $after.number,
            details: { request: <string> $after.id, kind: $after.kind, operation: $after.operation, actions: $after.actions,
                state: $after.state, approvals: array::len($after.approvals), required_approvals: $after.required_approvals,
                emergency: $after.emergency, reason: IF $action = "request.create" { $after.reason } ELSE { $after.decision_reason } }
        });
        LET $event_type = {
            "request.create": "secrets.request.created", "request.reject": "secrets.request.rejected",
            "request.cancel": "secrets.request.cancelled", "request.expire": "secrets.request.expired", "request.apply": "secrets.request.applied"
        }[$action] ?? (IF $after.state = "approved" { "secrets.request.approved" } ELSE { NONE });
        IF $event_type IS NOT NONE {
            LET $published = fn::event_publish({
                event_id: rand::uuid::v7(),
                event_type: $event_type,
                producer: "lyxal_secrets",
                source: $after.id,
                payload: { request_id: <string> $after.id, tenant: <string> $after.tenant, kind: $after.kind, path: $after.path,
                    secret_id: IF $after.secret IS NONE { NONE } ELSE { <string> $after.secret }, operation: $after.operation,
                    actions: $after.actions, state: $after.state, emergency: $after.emergency,
                    requester: IF $after.requested_identity IS NOT NONE { <string> $after.requested_identity } ELSE { <string> $after.requested_application },
                    approvals: $after.approvals.by, required_approvals: $after.required_approvals, actor: fn::secrets_actor() },
                metadata: {}
            });
            IF !$published.ok { THROW $published.error.code; };
        };
    };
};

DEFINE EVENT OVERWRITE secrets_policy_guard ON TABLE secrets_policy
WHEN $event IN ["CREATE", "UPDATE"]
THEN {
    LET $refusal = fn::secrets_policy_refusal($after);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

DEFINE EVENT OVERWRITE secrets_policy_journal ON TABLE secrets_policy
WHEN $event IN ["CREATE", "UPDATE", "DELETE"] AND ($event != "DELETE" OR record::exists($before.tenant))
THEN {
    LET $doc = IF $event = "DELETE" { $before } ELSE { $after };
    fn::secrets_audit_write({
        tenant: $doc.tenant,
        action: IF $event = "DELETE" { "policy.delete" } ELSE { "policy.set" },
        path: $doc.path,
        details: { folder: $doc.folder, required_approvals: $doc.required_approvals, operations: $doc.operations, max_grant_duration: $doc.max_grant_duration }
    });
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "secrets.policy.updated",
        producer: "lyxal_secrets",
        source: $doc.id,
        payload: { tenant: <string> $doc.tenant, path: $doc.path, folder: $doc.folder, removed: $event = "DELETE",
            required_approvals: $doc.required_approvals, operations: $doc.operations, actor: fn::secrets_actor() },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

-- ----------------------------------------------------------------------------
-- Partages : garde, journal et bus
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE secrets_share_guard ON TABLE secrets_share
WHEN $event IN ["CREATE", "UPDATE"]
THEN {
    LET $refusal = fn::secrets_share_refusal($event, $before, $after);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

DEFINE EVENT OVERWRITE secrets_share_journal ON TABLE secrets_share
WHEN $event = "CREATE" OR ($event = "UPDATE" AND ($before.state != $after.state OR $before.views != $after.views OR $before.failed_attempts != $after.failed_attempts))
THEN {
    -- Une ouverture est journalisée et publiée ; une dernière ouverture aussi comme épuisement
    LET $actions = IF $event = "CREATE" { ["share.create"] }
        ELSE {
            array::concat(
                IF $after.views != $before.views { ["share.open"] } ELSE IF $after.failed_attempts != $before.failed_attempts AND $after.state = "active" { ["share.fail"] } ELSE { [] },
                IF $after.state != $before.state { [{ consumed: "share.consume", expired: "share.expire", revoked: "share.revoke", destroyed: "share.destroy" }[$after.state]] } ELSE { [] }
            )
        };
    LET $path = IF $after.secret IS NONE { NONE } ELSE { (SELECT VALUE path FROM ONLY $after.secret) };
    FOR $action IN $actions {
        fn::secrets_audit_write({
            tenant: $after.tenant,
            action: $action,
            outcome: IF $action IN ["share.fail", "share.destroy"] { "failure" } ELSE { "success" },
            secret: $after.secret,
            path: $path,
            version: $after.number,
            details: { share: <string> $after.id, views: $after.views, max_views: $after.max_views, failed_attempts: $after.failed_attempts,
                members_only: $after.members_only, protected: $after.protected, expires_at: $after.expires_at }
        });
        LET $event_type = { "share.create": "secrets.share.created", "share.open": "secrets.share.opened", "share.consume": "secrets.share.consumed",
            "share.expire": "secrets.share.expired", "share.revoke": "secrets.share.revoked", "share.destroy": "secrets.share.destroyed" }[$action];
        IF $event_type IS NOT NONE {
            LET $published = fn::event_publish({
                event_id: rand::uuid::v7(),
                event_type: $event_type,
                producer: "lyxal_secrets",
                source: $after.id,
                payload: { share_id: <string> $after.id, tenant: fn::secrets_tenant_string($after.tenant),
                    secret_id: IF $after.secret IS NONE { NONE } ELSE { <string> $after.secret }, path: $path,
                    author: IF $after.created_identity IS NOT NONE { <string> $after.created_identity } ELSE IF $after.created_application IS NOT NONE { <string> $after.created_application } ELSE { NONE },
                    views: $after.views, max_views: $after.max_views, note: $after.note },
                metadata: {}
            });
            IF !$published.ok { THROW $published.error.code; };
        };
    };
};
