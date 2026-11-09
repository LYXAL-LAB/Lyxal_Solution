-- ============================================================================
-- FONCTIONS : invitations à rejoindre une organisation
-- MODULE    : lyxal_auth
-- ============================================================================
-- Le jeton est généré en Rust (OsRng) ; la base ne reçoit que son empreinte BLAKE3 et le lien
-- scellé (enc:v2). Le lien passe par le champ transitoire `delivery` : l'événement de création
-- le publie dans auth.invitation.created avec l'identifiant d'événement utilisé pour le sceller
-- (contrat : crates/lyxal_notification/README.md §4), puis l'efface dans la même
-- transaction ; un échec de publication annule la création (E3).

-- ----------------------------------------------------------------------------
-- fn::auth_invitation_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_invitation_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }], required: true },
            email: { pipeline: [{ rule: "email", options: { max_length: 254 } }], required: true },
            roles: { pipeline: [{ rule: "array" }, { rule: "each", options: { pipeline: [{ rule: "record", options: { expected_table: "auth_role" } }] } }], default: [] },
            event_id: { pipeline: [{ rule: "uuid_v7", options: { allow_string: true } }], required: true },
            token_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            secret: { pipeline: [{ rule: "required_string", options: { min_length: 16, max_length: 4096 } }, { rule: "starts_with", options: { prefixes: ["enc:v2:"], case_sensitive: true, trim_value: false } }], required: true },
            expires_at: { pipeline: [{ rule: "future_datetime", options: { allow_equal: false } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, { fields: { email: { pipeline: [{ rule: "email" }] }, token_hash: { pipeline: [{ rule: "lowercase" }] } }, unknown_keys: "keep" }, 20);
    LET $platform = fn::auth_has_permission({ permission: "auth.organization.manage" });
    IF !$platform AND !fn::auth_has_permission({ permission: "auth.member.manage", tenant: $p.organization }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.member.manage" });
    };
    LET $organization = (SELECT id, name, state FROM ONLY $p.organization);
    IF $organization == NONE { RETURN fn::error_result("AUTH_ORGANIZATION_NOT_FOUND", $p.language, {}); };
    IF $organization.state != "active" { RETURN fn::error_result("AUTH_ORGANIZATION_INACTIVE", $p.language, { state: $organization.state }); };
    LET $roles = (SELECT id, scope, tenant, is_default FROM auth_role WHERE id IN $p.roles);
    IF array::len($roles) != array::len(array::distinct($p.roles)) { RETURN fn::error_result("AUTH_ROLE_NOT_FOUND", $p.language, {}); };
    IF array::any($roles, |$r| $r.scope != "organization" OR ($r.tenant IS NOT NONE AND $r.tenant != $p.organization)) {
        RETURN fn::error_result("AUTH_ROLE_SCOPE_MISMATCH", $p.language, {});
    };
    IF array::any($roles, |$r| !$r.is_default) AND !$platform AND !fn::auth_has_permission({ permission: "auth.organization.role.manage", tenant: $p.organization }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.organization.role.manage" });
    };
    LET $identity = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE type = "email" AND value = $p.email LIMIT 1);
    IF $identity IS NOT NONE AND array::len(SELECT VALUE id FROM auth_member_of WHERE in = $identity AND out = $p.organization LIMIT 1) > 0 {
        RETURN fn::error_result("AUTH_ALREADY_A_MEMBER", $p.language, {});
    };
    LET $ttl = fn::auth_policy_get({ organization: <string> $p.organization }).data.invitation.ttl_seconds ?? 604800;
    LET $expires_at = $p.expires_at ?? (time::now() + duration::from_secs($ttl));
    -- Une nouvelle invitation remplace l'invitation en attente pour la même adresse
    UPDATE auth_organization_invitation SET state = "revoked" WHERE organization = $p.organization AND email = $p.email AND state = "pending";
    LET $caller = IF $auth != NONE AND type::is_record($auth, "auth_session") { (SELECT VALUE identity FROM ONLY $auth) } ELSE { NONE };
    LET $created = (CREATE ONLY type::record("auth_organization_invitation", string::replace(<string> rand::uuid::v7(), "-", "")) CONTENT {
        organization: $p.organization,
        email: $p.email,
        roles: $p.roles,
        inviter: $caller,
        token_hash: $p.token_hash,
        expires_at: $expires_at,
        delivery: { event_id: <string> $p.event_id, secret: $p.secret }
    });
    IF $created == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_organization_invitation" }); };
    RETURN fn::result_ok(object::remove($created, "token_hash"));
} COMMENT "Crée une invitation ({ organization, email, roles, event_id, token_hash, secret enc:v2, expires_at }) et publie auth.invitation.created avec ce même event_id. Permissions auth.member.manage (+ auth.organization.role.manage pour des rôles non par défaut)";

-- ----------------------------------------------------------------------------
-- fn::auth_invitation_accept
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_invitation_accept($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            token_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, { fields: { token_hash: { pipeline: [{ rule: "lowercase" }] } }, unknown_keys: "keep" }, 20);
    LET $check = fn::auth_session_valid({});
    IF !$check.valid { RETURN fn::error_result($check.code, $p.language, {}); };
    IF $check.system { RETURN fn::error_result("AUTH_SESSION_REQUIRED", $p.language, {}); };
    LET $identity = (SELECT VALUE identity FROM ONLY $auth);
    -- Demande vérifiée par la base (auth_invitation_claim_process) : l'empreinte des invitations
    -- est illisible pour la session, seule la base la compare
    LET $claim = (CREATE ONLY auth_invitation_claim CONTENT { identity: $identity, token_hash: $p.token_hash });
    IF $claim == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_invitation_claim" }); };
    LET $result = (SELECT outcome, membership, organization FROM ONLY $claim.id);
    IF $result.outcome != "accepted" { RETURN fn::error_result($result.outcome ?? "AUTH_INVITATION_INVALID", $p.language, {}); };
    RETURN fn::result_ok({ organization: $result.organization, membership: $result.membership, roles: (SELECT VALUE out FROM auth_has_role WHERE in = $result.membership) });
} COMMENT "Accepte une invitation ({ token_hash }) pour l'identité connectée dont l'adresse correspond : la base vérifie l'empreinte (demande auth_invitation_claim), crée l'adhésion, les rôles par défaut et les rôles prévus";

-- ----------------------------------------------------------------------------
-- fn::auth_invitation_revoke
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_invitation_revoke($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            invitation: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization_invitation" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $invitation = (SELECT id, organization, state FROM ONLY $p.invitation);
    IF $invitation == NONE { RETURN fn::error_result("AUTH_INVITATION_INVALID", $p.language, {}); };
    IF !fn::auth_has_permission({ permission: "auth.organization.manage" }) AND !fn::auth_has_permission({ permission: "auth.member.manage", tenant: $invitation.organization }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.member.manage" });
    };
    IF $invitation.state != "pending" { RETURN fn::error_result("AUTH_INVITATION_INVALID", $p.language, { state: $invitation.state }); };
    LET $revoked = (UPDATE ONLY $invitation.id SET state = "revoked");
    IF $revoked == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_organization_invitation" }); };
    RETURN fn::result_ok(object::remove($revoked, "token_hash"));
} COMMENT "Révoque une invitation en attente ({ invitation }). Permission auth.member.manage ou auth.organization.manage";

-- ----------------------------------------------------------------------------
-- fn::auth_invitation_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_invitation_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }], required: true },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["pending", "accepted", "revoked", "expired"], case_sensitive: true } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_has_permission({ permission: "auth.organization.manage" }) AND !fn::auth_has_permission({ permission: "auth.member.manage", tenant: $p.organization }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.member.manage" });
    };
    RETURN fn::result_ok(
        SELECT id, email, roles, inviter, state, expires_at, accepted_by, accepted_at, created_at,
            (state = "pending" AND expires_at <= time::now()) AS expired
        FROM auth_organization_invitation
        WHERE organization = $p.organization AND ($p.state IS NONE OR state = $p.state)
        ORDER BY created_at DESC
    );
} COMMENT "Liste les invitations d'une organisation ({ organization, state }) sans les empreintes de jetons. Permission auth.member.manage ou auth.organization.manage";
