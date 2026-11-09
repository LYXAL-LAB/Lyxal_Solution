-- ============================================================================
-- EVENTS : lyxal_auth
-- MODULE : lyxal_auth
-- RÔLE   : Publication des événements auth.* vers le bus lyxal_event
-- ============================================================================
-- Chaque événement est publié par la base dans la même transaction que la mutation qui le
-- motive (.agents/AGENTS.md §5.6.1) ; une publication refusée fait échouer la mutation. Aucune
-- charge utile ne contient de secret en clair : auth.invitation.created transporte le lien scellé
-- (enc:v2) reçu dans le champ transitoire `delivery`, effacé dans la même transaction.

DEFINE EVENT OVERWRITE auth_organization_created_event ON TABLE auth_organization
WHEN $event = "CREATE"
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "auth.organization.created",
        producer: "lyxal_auth",
        source: $after.id,
        payload: { organization_id: <string> $after.id, slug: $after.slug, name: $after.name },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE auth_organization_state_changed_event ON TABLE auth_organization
WHEN $event = "UPDATE" AND $before.state != $after.state
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "auth.organization.state_changed",
        producer: "lyxal_auth",
        source: $after.id,
        payload: { organization_id: <string> $after.id, previous_state: $before.state, state: $after.state },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE auth_identity_created_event ON TABLE auth_identity
WHEN $event = "CREATE"
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "auth.identity.created",
        producer: "lyxal_auth",
        source: $after.id,
        payload: { identity_id: <string> $after.id, state: $after.state },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE auth_identity_state_changed_event ON TABLE auth_identity
WHEN $event = "UPDATE" AND $before.state != $after.state
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "auth.identity.state_changed",
        producer: "lyxal_auth",
        source: $after.id,
        payload: { identity_id: <string> $after.id, previous_state: $before.state, state: $after.state },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE auth_member_added_event ON TABLE auth_member_of
WHEN $event = "CREATE"
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "auth.member.added",
        producer: "lyxal_auth",
        source: $after.id,
        payload: { tenant: <string> record::id($after.out), organization_id: <string> $after.out, identity_id: <string> $after.in },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE auth_member_removed_event ON TABLE auth_member_of
WHEN $event = "DELETE"
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "auth.member.removed",
        producer: "lyxal_auth",
        source: $before.id,
        payload: { tenant: <string> record::id($before.out), organization_id: <string> $before.out, identity_id: <string> $before.in },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE auth_role_assigned_event ON TABLE auth_has_role
WHEN $event = "CREATE"
THEN {
    LET $membership = record::tb($after.in) = "auth_member_of";
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "auth.role.assigned",
        producer: "lyxal_auth",
        source: $after.id,
        payload: {
            role_id: <string> $after.out,
            identity_id: IF record::tb($after.in) = "auth_application" { NONE } ELSE { <string> (IF $membership { $after.in.in } ELSE { $after.in }) },
            application_id: IF record::tb($after.in) = "auth_application" { <string> $after.in } ELSE { NONE },
            organization_id: IF $membership { <string> $after.in.out } ELSE { NONE }
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE auth_role_unassigned_event ON TABLE auth_has_role
WHEN $event = "DELETE"
THEN {
    LET $membership = record::tb($before.in) = "auth_member_of";
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "auth.role.unassigned",
        producer: "lyxal_auth",
        source: $before.id,
        payload: {
            role_id: <string> $before.out,
            holder_id: <string> $before.in,
            membership: $membership
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE auth_invitation_state_event ON TABLE auth_organization_invitation
WHEN $event = "UPDATE" AND $before.state != $after.state AND $after.state IN ["accepted", "revoked"]
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: string::concat("auth.invitation.", $after.state),
        producer: "lyxal_auth",
        source: $after.id,
        payload: {
            tenant: <string> record::id($after.organization),
            invitation_id: <string> $after.id,
            organization_id: <string> $after.organization,
            identity_id: IF $after.accepted_by IS NONE { NONE } ELSE { <string> $after.accepted_by }
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE auth_invitation_created_event ON TABLE auth_organization_invitation
WHEN $event = "CREATE"
THEN {
    -- Une invitation sans lien scellé ne peut être remise
    IF $after.delivery IS NONE { THROW "AUTH_INVITATION_INVALID"; };
    LET $identity = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE type = "email" AND value = $after.email LIMIT 1);
    LET $published = fn::event_publish({
        event_id: <uuid> $after.delivery.event_id,
        event_type: "auth.invitation.created",
        producer: "lyxal_auth",
        source: $after.id,
        payload: {
            tenant: <string> record::id($after.organization),
            invitation_id: <string> $after.id,
            identity_id: IF $identity IS NONE { NONE } ELSE { <string> $identity },
            recipient_email: $after.email,
            recipient_locale: IF $identity IS NONE { NONE } ELSE { (SELECT VALUE traits.locale FROM ONLY $identity) },
            recipient_name: IF $identity IS NONE { NONE } ELSE { (SELECT VALUE traits.name.first FROM ONLY $identity) },
            expires_at: $after.expires_at,
            secret: $after.delivery.secret,
            organization_name: (SELECT VALUE name FROM ONLY $after.organization),
            inviter_name: IF $after.inviter IS NONE { NONE } ELSE { (SELECT VALUE traits.name.first FROM ONLY $after.inviter) }
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
    -- Le lien scellé n'est jamais enregistré
    UPDATE $after.id SET delivery = NONE;
};

-- ----------------------------------------------------------------------------
-- Version des droits : tout retrait de droit (adhésion supprimée ou suspendue, rôle retiré,
-- permission ou inclusion retirée d'un rôle) incrémente `permissions_version` des identités et
-- des applications concernées. L'événement suit l'écriture dans la même transaction et n'est pas soumis aux
-- permissions des tables : l'appelant qui retire ses propres droits n'est pas bloqué.
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE auth_member_removed_version ON TABLE auth_member_of
WHEN $event = "DELETE" OR ($event = "UPDATE" AND $before.state = "active" AND $after.state != "active")
THEN {
    LET $identity = IF $event = "DELETE" { $before.in } ELSE { $after.in };
    UPDATE $identity SET permissions_version += 1;
};

DEFINE EVENT OVERWRITE auth_role_removed_version ON TABLE auth_has_role
WHEN $event = "DELETE"
THEN {
    LET $identity = IF record::tb($before.in) = "auth_member_of" { $before.in.in } ELSE { $before.in };
    IF $identity IS NOT NONE { UPDATE $identity SET permissions_version += 1; };
};

DEFINE EVENT OVERWRITE auth_role_grant_removed_version ON TABLE auth_role_grants
WHEN $event = "DELETE"
THEN {
    FOR $identity IN fn::auth_role_holders({ role: $before.in }) {
        UPDATE $identity SET permissions_version += 1;
    };
};

DEFINE EVENT OVERWRITE auth_role_include_removed_version ON TABLE auth_role_includes
WHEN $event = "DELETE"
THEN {
    FOR $identity IN fn::auth_role_holders({ role: $before.in }) {
        UPDATE $identity SET permissions_version += 1;
    };
};

-- ----------------------------------------------------------------------------
-- Sessions, codes, mots de passe, applications et clés d'API (lot 3)
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE auth_session_created_event ON TABLE auth_session
WHEN $event = "CREATE"
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "auth.session.created",
        producer: "lyxal_auth",
        source: $after.id,
        payload: {
            session_id: <string> $after.id,
            identity_id: IF $after.identity IS NONE { NONE } ELSE { <string> $after.identity },
            application_id: IF $after.application IS NONE { NONE } ELSE { <string> $after.application },
            organization_id: IF $after.organization IS NONE { NONE } ELSE { <string> $after.organization },
            kind: $after.kind,
            amr: $after.amr.method
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE auth_session_revoked_event ON TABLE auth_session
WHEN $event = "UPDATE" AND $before.state = "active" AND $after.state = "revoked"
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "auth.session.revoked",
        producer: "lyxal_auth",
        source: $after.id,
        payload: {
            session_id: <string> $after.id,
            identity_id: IF $after.identity IS NONE { NONE } ELSE { <string> $after.identity },
            application_id: IF $after.application IS NONE { NONE } ELSE { <string> $after.application },
            reason: $after.revoked_reason
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

-- Code ou lien à envoyer : contrat de lyxal_notification (README §4) ; le secret scellé arrive par
-- le champ transitoire `delivery`, publié puis effacé dans la même transaction
DEFINE EVENT OVERWRITE auth_code_delivery_event ON TABLE auth_one_time_code
WHEN $event = "CREATE" AND $after.delivery IS NOT NONE
THEN {
    LET $flow = (SELECT identity FROM ONLY $after.flow);
    LET $published = fn::event_publish({
        event_id: <uuid> $after.delivery.event_id,
        event_type: IF $after.purpose = "recovery" { "auth.recovery.requested" } ELSE { "auth.verification.requested" },
        producer: "lyxal_auth",
        source: $after.flow,
        payload: {
            tenant: NONE,
            identity_id: IF $flow.identity IS NONE { NONE } ELSE { <string> $flow.identity },
            recipient_email: $after.address,
            recipient_locale: $after.delivery.locale,
            recipient_name: $after.delivery.name,
            expires_at: $after.expires_at,
            secret: $after.delivery.secret
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
    -- Le secret n'est jamais enregistré
    UPDATE $after.id SET delivery = NONE;
};

DEFINE EVENT OVERWRITE auth_password_changed_event ON TABLE auth_credential
WHEN $after.type = "password" AND ($event = "CREATE" OR ($event = "UPDATE" AND $before.secret_data != $after.secret_data))
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "auth.password.changed",
        producer: "lyxal_auth",
        source: $after.identity,
        payload: {
            identity_id: <string> $after.identity,
            first: $event = "CREATE",
            recipient_email: $after.identity.traits.email,
            recipient_locale: $after.identity.traits.locale,
            recipient_name: $after.identity.traits.name.first
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE auth_application_created_event ON TABLE auth_application
WHEN $event = "CREATE"
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "auth.application.created",
        producer: "lyxal_auth",
        source: $after.id,
        payload: {
            application_id: <string> $after.id,
            client_id: $after.client_id,
            type: $after.type,
            organization_id: IF $after.tenant IS NONE { NONE } ELSE { <string> $after.tenant }
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE auth_api_key_created_event ON TABLE auth_api_key
WHEN $event = "CREATE"
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "auth.api_key.created",
        producer: "lyxal_auth",
        source: $after.id,
        payload: { api_key_id: <string> $after.id, identity_id: <string> $after.identity, prefix: $after.prefix, permissions: $after.permissions },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE auth_api_key_revoked_event ON TABLE auth_api_key
WHEN $event = "UPDATE" AND $before.revoked_at IS NONE AND $after.revoked_at IS NOT NONE
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "auth.api_key.revoked",
        producer: "lyxal_auth",
        source: $after.id,
        payload: { api_key_id: <string> $after.id, identity_id: <string> $after.identity, prefix: $after.prefix },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};
