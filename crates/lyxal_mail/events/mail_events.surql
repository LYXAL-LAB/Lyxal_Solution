-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- EVENTS : lyxal_mail — publications
-- MODULE : lyxal_mail
-- RÔLE   : mail.domain.*, mail.account.*, mail.address.*, mail.quota.exceeded
-- ============================================================================
-- Publiés par fn::event_publish dans la transaction de la mutation (.agents/AGENTS.md §5.6.1) ;
-- une publication refusée annule la mutation. Charges utiles sans donnée personnelle :
-- identifiants d'enregistrement et compteurs seulement, ni adresse, ni nom de domaine, ni sujet.
-- Aucun événement par message au lot 4 (décision M16). Un retrait emporté par la suppression de
-- l'organisation ne publie rien (l'organisation n'existe plus).

DEFINE EVENT OVERWRITE mail_domain_created_event ON TABLE mail_domain
WHEN $event = "CREATE"
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "mail.domain.created",
        producer: "lyxal_mail",
        source: $after.id,
        payload: { domain_id: <string> $after.id, tenant: <string> $after.tenant },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE mail_domain_deleted_event ON TABLE mail_domain
WHEN $event = "DELETE" AND record::exists($before.tenant)
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "mail.domain.deleted",
        producer: "lyxal_mail",
        source: $before.id,
        payload: { domain_id: <string> $before.id, tenant: <string> $before.tenant },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE mail_account_created_event ON TABLE mail_account
WHEN $event = "CREATE"
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "mail.account.created",
        producer: "lyxal_mail",
        source: $after.id,
        payload: { account_id: <string> $after.id, tenant: <string> $after.tenant },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

-- Compte purgé : fin de l'état deleting (fn::mail_account_purge_step)
DEFINE EVENT OVERWRITE mail_account_deleted_event ON TABLE mail_account
WHEN $event = "DELETE" AND $before.state = "deleting" AND record::exists($before.tenant)
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "mail.account.deleted",
        producer: "lyxal_mail",
        source: $before.id,
        payload: { account_id: <string> $before.id, tenant: <string> $before.tenant },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE mail_address_created_event ON TABLE mail_address
WHEN $event = "CREATE"
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "mail.address.created",
        producer: "lyxal_mail",
        source: $after.id,
        payload: {
            address_id: <string> $after.id,
            account_id: IF $after.account IS NONE { NONE } ELSE { <string> $after.account },
            kind: $after.kind,
            tenant: <string> $after.tenant
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE mail_address_deleted_event ON TABLE mail_address
WHEN $event = "DELETE" AND record::exists($before.tenant)
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "mail.address.deleted",
        producer: "lyxal_mail",
        source: $before.id,
        payload: { address_id: <string> $before.id, kind: $before.kind, tenant: <string> $before.tenant },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

-- Premier dépôt refusé pour quota depuis le dernier passage sous le quota
DEFINE EVENT OVERWRITE mail_quota_exceeded_event ON TABLE mail_account
WHEN $event = "UPDATE" AND $before.quota_exceeded_at IS NONE AND $after.quota_exceeded_at IS NOT NONE
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "mail.quota.exceeded",
        producer: "lyxal_mail",
        source: $after.id,
        payload: {
            account_id: <string> $after.id,
            tenant: <string> $after.tenant,
            quota_bytes: $after.quota_bytes ?? fn::mail_settings_effective({ tenant: $after.tenant }).default_quota_bytes,
            used_bytes: $after.used_bytes
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};
