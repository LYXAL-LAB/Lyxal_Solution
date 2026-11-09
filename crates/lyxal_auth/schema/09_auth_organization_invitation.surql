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
        -- L'invitée n'écrit rien : l'acceptation passe par une demande (auth_invitation_claim)
        -- vérifiée par la base
        FOR update WHERE fn::auth_has_permission({ permission: "auth.organization.manage" })
            OR fn::auth_has_permission({ permission: "auth.member.manage", tenant: organization })
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
    TYPE option<record<auth_identity>> REFERENCE ON DELETE UNSET
    PERMISSIONS FOR update NONE
    COMMENT "Identité qui a invité (NONE : session système, ou identité purgée)";

DEFINE FIELD OVERWRITE token_hash ON TABLE auth_organization_invitation
    TYPE string
    ASSERT string::len($value) = 64 AND string::is_hexadecimal($value)
    READONLY
    PERMISSIONS FOR select NONE
    COMMENT "Empreinte BLAKE3 (hex) du jeton d'invitation ; jamais le jeton ; illisible hors session système";

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
    TYPE option<record<auth_identity>> REFERENCE ON DELETE UNSET
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

-- ----------------------------------------------------------------------------
-- TABLE : auth_invitation_claim — demande d'acceptation d'une invitation
-- ----------------------------------------------------------------------------
-- L'identité connectée dépose l'empreinte du jeton reçu ; l'événement de la base (qui voit les
-- empreintes, illisibles pour elle) vérifie l'invitation, crée l'adhésion et ses rôles, et écrit
-- l'issue. Sans le jeton, aucune adhésion n'est possible, même avec la bonne adresse.

DEFINE TABLE OVERWRITE auth_invitation_claim
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE $auth IS NOT NONE AND identity = $auth.identity
        FOR create WHERE $auth IS NOT NONE AND identity = $auth.identity AND fn::auth_session_valid({}).valid
        FOR update, delete NONE
    COMMENT "Demandes d'acceptation d'invitation (empreinte du jeton), vérifiées par la base";

DEFINE FIELD OVERWRITE identity ON TABLE auth_invitation_claim
    TYPE record<auth_identity>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Identité qui accepte";

DEFINE FIELD OVERWRITE token_hash ON TABLE auth_invitation_claim
    TYPE string
    ASSERT string::len($value) = 64 AND string::is_hexadecimal($value)
    READONLY
    PERMISSIONS FOR select NONE
    COMMENT "Empreinte BLAKE3 (hex) du jeton présenté";

DEFINE FIELD OVERWRITE outcome ON TABLE auth_invitation_claim
    TYPE option<string>
    COMMENT "Issue écrite par la base : accepted, ou code d'erreur AUTH_*";

DEFINE FIELD OVERWRITE membership ON TABLE auth_invitation_claim
    TYPE option<record<auth_member_of>> REFERENCE ON DELETE UNSET
    COMMENT "Adhésion créée";

DEFINE FIELD OVERWRITE organization ON TABLE auth_invitation_claim
    TYPE option<record<auth_organization>> REFERENCE ON DELETE CASCADE
    COMMENT "Organisation rejointe";

DEFINE FIELD OVERWRITE created_at ON TABLE auth_invitation_claim
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de la demande";

DEFINE EVENT OVERWRITE auth_invitation_claim_process ON TABLE auth_invitation_claim
WHEN $event = "CREATE"
THEN {
    LET $identity = $after.identity;
    LET $invitation = (SELECT * FROM ONLY auth_organization_invitation WHERE token_hash = $after.token_hash LIMIT 1);
    LET $emails = (SELECT VALUE value FROM auth_credential_identifier WHERE identity = $identity AND type = "email");
    -- Invitation inconnue ou adressée à une autre adresse : même issue (pas d'énumération)
    LET $outcome = IF $invitation == NONE OR $invitation.state != "pending" OR $invitation.email NOTINSIDE $emails {
        "AUTH_INVITATION_INVALID"
    } ELSE IF $invitation.expires_at <= time::now() {
        "AUTH_INVITATION_EXPIRED"
    } ELSE IF array::len(SELECT VALUE id FROM auth_member_of WHERE in = $identity AND out = $invitation.organization LIMIT 1) > 0 {
        "AUTH_ALREADY_A_MEMBER"
    } ELSE { NONE };
    IF $outcome IS NOT NONE {
        UPDATE $after.id SET outcome = $outcome;
    } ELSE {
        LET $joined = fn::auth_membership_create({ identity: $identity, organization: $invitation.organization, roles: $invitation.roles, by: $invitation.inviter });
        IF $joined.code IS NOT NONE { THROW $joined.code; };
        UPDATE $invitation.id SET state = "accepted", accepted_by = $identity, accepted_at = time::now();
        UPDATE $after.id SET outcome = "accepted", membership = $joined.membership, organization = $invitation.organization;
    };
};
