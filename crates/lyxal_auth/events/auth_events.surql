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
            identity_id: <string> (IF $membership { $after.in.in } ELSE { $after.in }),
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
