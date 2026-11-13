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
            expiry_warning_days: $after.expiry_warning_days
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
                ELSE { {} }
        });
        LET $event_type = {
            "secret.create": "secrets.secret.created",
            "secret.update": "secrets.secret.updated",
            "secret.disable": "secrets.secret.disabled",
            "secret.enable": "secrets.secret.enabled",
            "secret.delete": "secrets.secret.deleted",
            "secret.restore": "secrets.secret.restored",
            "secret.purge": "secrets.secret.purged",
            "version.label": "secrets.version.labeled"
        }[$action];
        fn::secrets_publish($event_type, $doc, IF $action = "version.label" { { labels: $after.labels } } ELSE IF $action = "secret.update" { { fields: $fields } } ELSE { {} });
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
