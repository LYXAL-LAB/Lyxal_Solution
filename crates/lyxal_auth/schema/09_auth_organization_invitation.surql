-- ============================================================================
-- TABLE  : auth_organization_invitation
-- MODULE : lyxal_auth
-- RÔLE   : Invitations à rejoindre une organisation
-- ============================================================================
-- Modèle : Logto `organization_invitations`, Keycloak `ORG_INVITATION`. Seule l'empreinte BLAKE3
-- du jeton est conservée. Le lien scellé (enc:v2) arrive dans le champ transitoire `delivery`,
-- illisible, que l'événement de création publie dans `auth.invitation.created` puis efface dans
-- la même transaction : il n'est jamais enregistré (events/auth_events.surql).

DEFINE TABLE OVERWRITE auth_organization_invitation
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::auth_has_permission({ permission: "auth.organization.manage" })
            OR fn::auth_has_permission({ permission: "auth.member.manage", tenant: organization })
            OR ($auth IS NOT NONE AND accepted_by = $auth.identity)
            OR ($auth IS NOT NONE AND state = "pending" AND email IN (SELECT VALUE value FROM auth_credential_identifier WHERE identity = $auth.identity AND type = "email"))
        FOR update WHERE fn::auth_has_permission({ permission: "auth.organization.manage" })
            OR fn::auth_has_permission({ permission: "auth.member.manage", tenant: organization })
            -- L'invitée accepte : la condition vaut avant (en attente, son adresse) et après
            -- (acceptée par elle) la modification
            OR ($auth IS NOT NONE AND state = "pending" AND email IN (SELECT VALUE value FROM auth_credential_identifier WHERE identity = $auth.identity AND type = "email"))
            OR ($auth IS NOT NONE AND state = "accepted" AND accepted_by = $auth.identity)
        FOR create WHERE fn::auth_has_permission({ permission: "auth.organization.manage" })
            OR fn::auth_has_permission({ permission: "auth.member.manage", tenant: organization })
        FOR delete NONE
    COMMENT "Invitations expirantes à rejoindre une organisation, avec rôles prévus";

DEFINE FIELD OVERWRITE organization ON TABLE auth_organization_invitation
    TYPE record<auth_organization>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation qui invite";

DEFINE FIELD OVERWRITE email ON TABLE auth_organization_invitation
    TYPE string
    ASSERT string::len($value) >= 3 AND string::len($value) <= 254 AND $value == string::lowercase($value)
    READONLY
    COMMENT "Adresse invitée (normalisée)";

DEFINE FIELD OVERWRITE roles ON TABLE auth_organization_invitation
    TYPE array<record<auth_role>>
    DEFAULT []
    READONLY
    COMMENT "Rôles d'organisation attribués à l'acceptation";

DEFINE FIELD OVERWRITE inviter ON TABLE auth_organization_invitation
    TYPE option<record<auth_identity>>
    READONLY
    COMMENT "Identité qui a invité (NONE : session système)";

DEFINE FIELD OVERWRITE token_hash ON TABLE auth_organization_invitation
    TYPE string
    ASSERT string::len($value) = 64 AND string::is_hexadecimal($value)
    READONLY
    COMMENT "Empreinte BLAKE3 (hex) du jeton d'invitation ; jamais le jeton";

DEFINE FIELD OVERWRITE state ON TABLE auth_organization_invitation
    TYPE string
    DEFAULT "pending"
    ASSERT $value IN ["pending", "accepted", "revoked", "expired"]
    COMMENT "État de l'invitation";

DEFINE FIELD OVERWRITE expires_at ON TABLE auth_organization_invitation
    TYPE datetime
    READONLY
    COMMENT "Fin de validité";

DEFINE FIELD OVERWRITE delivery ON TABLE auth_organization_invitation
    TYPE option<object>
    PERMISSIONS FOR select NONE
    COMMENT "Transitoire : { event_id, secret } publiés puis effacés par l'événement de création ; jamais enregistré ni lisible";

DEFINE FIELD OVERWRITE delivery.event_id ON TABLE auth_organization_invitation
    TYPE string
    PERMISSIONS FOR select NONE;

DEFINE FIELD OVERWRITE delivery.secret ON TABLE auth_organization_invitation
    TYPE string
    ASSERT string::starts_with($value, "enc:v2:")
    PERMISSIONS FOR select NONE;

DEFINE FIELD OVERWRITE accepted_by ON TABLE auth_organization_invitation
    TYPE option<record<auth_identity>>
    COMMENT "Identité qui a accepté";

DEFINE FIELD OVERWRITE accepted_at ON TABLE auth_organization_invitation
    TYPE option<datetime>
    COMMENT "Date d'acceptation";

DEFINE FIELD OVERWRITE created_at ON TABLE auth_organization_invitation
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE auth_organization_invitation
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de dernière modification";

DEFINE INDEX OVERWRITE auth_organization_invitation_token ON TABLE auth_organization_invitation FIELDS token_hash UNIQUE;
DEFINE INDEX OVERWRITE auth_organization_invitation_lookup ON TABLE auth_organization_invitation FIELDS organization, email, state;

-- Une invitation terminée ne change plus d'état
DEFINE EVENT OVERWRITE auth_organization_invitation_guard ON TABLE auth_organization_invitation
WHEN $event = "UPDATE" AND $before.state != $after.state
THEN {
    IF $before.state != "pending" { THROW "AUTH_INVITATION_INVALID"; };
};
