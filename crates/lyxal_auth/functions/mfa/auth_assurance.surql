-- ============================================================================
-- FONCTIONS : niveau d'assurance, exigences de connexion, réauthentification, tentatives
-- MODULE    : lyxal_auth
-- ============================================================================
-- Modèle : Kratos (AAL calculé depuis l'AMR, `available_aal`, `required_aal =
-- highest_available`, `privileged_session_max_age`), Keycloak (action imposée CONFIGURE_TOTP),
-- Logto (double facteur exigé par organisation). Les vérifications cryptographiques (TOTP,
-- WebAuthn, codes de secours) sont faites en Rust : la base reçoit des résultats.

-- ----------------------------------------------------------------------------
-- fn::auth_mfa_required : le double facteur est-il exigé pour cette identité ? (interne)
-- ----------------------------------------------------------------------------
-- Politique effective (`mfa.required`), organisation demandée (`mfa_required`) ou rôle détenu
-- dont la clé figure dans `mfa.required_roles` (rôles d'installation et rôles de l'adhésion).

DEFINE FUNCTION OVERWRITE fn::auth_mfa_required($params: object) -> bool {
    IF $params.identity IS NONE { RETURN false; };
    LET $policy = fn::auth_policy_get({ organization: IF $params.organization IS NONE { NONE } ELSE { <string> $params.organization } }).data ?? {};
    IF $policy.mfa.required ?? false { RETURN true; };
    IF $params.organization IS NOT NONE AND ((SELECT VALUE mfa_required FROM ONLY $params.organization) ?? false) { RETURN true; };
    LET $required_roles = $policy.mfa.required_roles ?? [];
    IF array::len($required_roles) = 0 { RETURN false; };
    LET $installation_roles = (SELECT VALUE out.key FROM auth_has_role WHERE in = $params.identity);
    LET $membership = IF $params.organization IS NONE { NONE } ELSE {
        (SELECT VALUE id FROM ONLY auth_member_of WHERE in = $params.identity AND out = $params.organization LIMIT 1)
    };
    LET $organization_roles = IF $membership IS NONE { [] } ELSE { (SELECT VALUE out.key FROM auth_has_role WHERE in = $membership) };
    RETURN array::len(array::intersect(array::concat($installation_roles, $organization_roles), $required_roles)) > 0;
} COMMENT "Vrai si le double facteur est exigé ({ identity, organization }) : politique, organisation ou rôle détenu listé dans mfa.required_roles";

-- ----------------------------------------------------------------------------
-- fn::auth_mfa_methods : seconds facteurs utilisables par une identité (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_mfa_methods($params: object) -> array {
    LET $allowed = fn::auth_policy_value({ theme: "mfa", key: "methods", default: ["totp", "passkey", "recovery_code"], organization: $params.organization });
    LET $kinds = (SELECT VALUE type FROM auth_credential WHERE identity = $params.identity AND state = "active" AND type IN ["totp", "passkey"]);
    LET $codes = array::len(SELECT VALUE id FROM auth_recovery_code WHERE identity = $params.identity AND used_at IS NONE) > 0;
    LET $present = array::concat(array::distinct($kinds), IF $codes AND array::len($kinds) > 0 { ["recovery_code"] } ELSE { [] });
    RETURN array::filter(["totp", "passkey", "recovery_code"], |$m| $m IN $present AND $m IN $allowed);
} COMMENT "Seconds facteurs actifs et autorisés par la politique ({ identity, organization }), dans l'ordre totp, passkey, recovery_code";

-- ----------------------------------------------------------------------------
-- fn::auth_login_requirements
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_login_requirements($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }], required: true },
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $available = (SELECT VALUE available_aal FROM ONLY $p.identity) ?? 0;
    LET $required = fn::auth_mfa_required({ identity: $p.identity, organization: $p.organization });
    LET $stored = (SELECT VALUE action FROM auth_required_action WHERE identity = $p.identity ORDER BY action);
    -- configure_mfa : posée par un administrateur ou calculée (double facteur exigé sans facteur)
    LET $actions = array::filter(array::distinct(array::concat($stored, IF $required AND $available < 2 { ["configure_mfa"] } ELSE { [] })),
        |$a| $a != "configure_mfa" OR $available < 2);
    RETURN fn::result_ok({
        required_actions: array::sort($actions),
        mfa_required: $required,
        available_aal: $available,
        methods: fn::auth_mfa_methods({ identity: $p.identity, organization: $p.organization })
    });
} COMMENT "Ce qu'exige la connexion d'une identité ({ identity, organization }) : actions imposées (dont configure_mfa calculée), double facteur exigé, niveau atteignable, seconds facteurs utilisables. Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_assurance_state : niveau et ancienneté d'une session au regard d'une exigence (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_assurance_state($params: object) -> object {
    LET $s = (SELECT aal, authenticated_at, identity, organization, kind FROM ONLY $params.session);
    IF $s == NONE OR $s.identity IS NONE { RETURN { code: "AUTH_SESSION_REQUIRED", details: {} }; };
    LET $available = (SELECT VALUE available_aal FROM ONLY $s.identity) ?? 0;
    LET $required = IF $params.min_aal = "aal2" { 2 } ELSE IF $params.min_aal = "aal1" { 1 } ELSE { math::max([$available, 1]) };
    LET $with = IF $available >= 2 { fn::auth_mfa_methods({ identity: $s.identity, organization: $s.organization }) } ELSE { ["password"] };
    IF $s.aal < $required {
        RETURN { code: "AUTH_AAL_INSUFFICIENT", details: { required_aal: $required, available_aal: $available, reauthenticate_with: IF $available >= $required { $with } ELSE { [] } } };
    };
    IF $params.fresh ?? false {
        LET $max_age = fn::auth_policy_value({ theme: "mfa", key: "privileged_max_age_seconds", default: 900, organization: $s.organization });
        IF $s.authenticated_at + duration::from_secs($max_age) <= time::now() {
            RETURN { code: "AUTH_REAUTHENTICATION_REQUIRED", details: { max_age_seconds: $max_age, reauthenticate_with: $with } };
        };
    };
    RETURN { code: NONE, details: {}, aal: $s.aal, available_aal: $available, authenticated_at: $s.authenticated_at };
} COMMENT "État d'assurance d'une session ({ session, min_aal : aal1 | aal2 | highest_available, fresh }) : { code, details, aal, available_aal, authenticated_at }";

-- ----------------------------------------------------------------------------
-- fn::auth_assurance_check : exigence d'assurance d'une action (tous les modules)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_assurance_check($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            session: { pipeline: [{ rule: "record", options: { expected_table: "auth_session" } }] },
            min_aal: { pipeline: [{ rule: "enum", options: { allowed: ["aal1", "aal2", "highest_available"], case_sensitive: true } }], default: "highest_available" },
            fresh: { pipeline: [{ rule: "boolean" }], default: false },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $check = fn::auth_session_valid({});
    IF !$check.valid { RETURN fn::error_result($check.code, $p.language, {}); };
    -- La session système vérifie une session désignée ; une session ne vérifie qu'elle-même
    IF $check.system AND $p.session IS NONE { RETURN fn::result_ok({ aal: NONE, available_aal: NONE, authenticated_at: NONE, system: true }); };
    IF !$check.system AND $p.session IS NOT NONE AND $p.session != $auth { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $state = fn::auth_assurance_state({ session: $p.session ?? $auth, min_aal: $p.min_aal, fresh: $p.fresh });
    IF $state.code IS NOT NONE { RETURN fn::error_result($state.code, $p.language, $state.details); };
    RETURN fn::result_ok({ aal: $state.aal, available_aal: $state.available_aal, authenticated_at: $state.authenticated_at, system: false });
} COMMENT "Vérifie qu'une session satisfait une exigence d'assurance ({ session (session système), min_aal : aal1 | aal2 | highest_available, fresh : authentification récente selon mfa.privileged_max_age_seconds }) ; AUTH_AAL_INSUFFICIENT ou AUTH_REAUTHENTICATION_REQUIRED avec les méthodes de réauthentification";

-- ----------------------------------------------------------------------------
-- fn::auth_session_reauthenticate
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_session_reauthenticate($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            session: { pipeline: [{ rule: "record", options: { expected_table: "auth_session" } }], required: true },
            method: { pipeline: [{ rule: "enum", options: { allowed: ["password", "totp", "passkey", "recovery_code"], case_sensitive: true } }], required: true },
            access_slot: { pipeline: [{ rule: "enum", options: { allowed: ["a", "b"], case_sensitive: true } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $now = time::now();
    LET $sess = (SELECT * FROM ONLY $p.session);
    IF $sess == NONE OR $sess.state != "active" OR $sess.kind != "interactive" OR $sess.expires_at <= $now OR $sess.idle_expires_at <= $now {
        RETURN fn::error_result("AUTH_SESSION_REVOKED", $p.language, {});
    };
    LET $available = (SELECT VALUE available_aal FROM ONLY $sess.identity) ?? 0;
    -- Une identité qui a un second facteur se réauthentifie avec lui (le mot de passe seul ne suffit pas)
    IF $p.method = "password" AND $available >= 2 { RETURN fn::error_result("AUTH_MFA_REQUIRED", $p.language, { methods: fn::auth_mfa_methods({ identity: $sess.identity, organization: $sess.organization }) }); };
    -- Second facteur actif et autorisé par la politique effective de l'organisation de la session
    IF $p.method != "password" AND $p.method NOT IN fn::auth_mfa_methods({ identity: $sess.identity, organization: $sess.organization }) {
        RETURN fn::error_result("AUTH_MFA_METHOD_DISABLED", $p.language, { method: $p.method });
    };
    LET $aal = IF $p.method = "password" { $sess.aal } ELSE { 2 };
    LET $rights = fn::auth_subject_permissions({ identity: $sess.identity, organization: $sess.organization });
    IF $rights.code IS NOT NONE { RETURN fn::error_result($rights.code, $p.language, {}); };
    LET $updated = (UPDATE ONLY $sess.id SET aal = $aal, authenticated_at = $now, amr += { method: $p.method, at: $now },
        access_slot = $p.access_slot, permissions_version = $rights.version WHERE state = "active");
    IF $updated == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_session" }); };
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(), event_type: "auth.session.reauthenticated", producer: "lyxal_auth", source: $sess.id,
        payload: { session_id: <string> $sess.id, identity_id: <string> $sess.identity, method: $p.method, aal: $aal },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
    LET $policy = fn::auth_policy_get({ organization: IF $sess.organization IS NONE { NONE } ELSE { <string> $sess.organization } }).data ?? {};
    RETURN fn::result_ok({
        session: $sess.id,
        identity: $sess.identity,
        application: NONE,
        organization: $sess.organization,
        kind: $sess.kind,
        permissions: $rights.permissions,
        version: $rights.version,
        aal: $aal,
        access_seconds: $policy.session.access_seconds ?? 900,
        idle_expires_at: $updated.idle_expires_at,
        expires_at: $updated.expires_at,
        refresh_expires_at: NONE
    });
} COMMENT "Réauthentification d'une session interactive ({ session, method, access_slot }) vérifiée par l'hôte : authenticated_at mis à jour, méthode ajoutée à l'AMR, AAL2 par un second facteur ; mot de passe refusé si l'identité a un second facteur. Renvoie ce que porte le nouveau jeton d'accès. Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_mfa_failure_check / _record / _reset : échecs du second facteur
-- ----------------------------------------------------------------------------
-- Même table et même verrouillage que la connexion (kind = mfa, clé = BLAKE3 de l'identité
-- calculé par l'hôte) ; un parcours n'accepte que mfa.max_attempts essais.

DEFINE FUNCTION OVERWRITE fn::auth_mfa_failure_check($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identity_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, { fields: { identity_hash: { pipeline: [{ rule: "lowercase" }] } }, unknown_keys: "keep" }, 20);
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $until = (SELECT VALUE locked_until FROM ONLY auth_login_failure WHERE kind = "mfa" AND key_hash = $p.identity_hash LIMIT 1);
    RETURN fn::result_ok({ locked: $until IS NOT NONE AND $until > time::now(), until: IF $until IS NOT NONE AND $until > time::now() { $until } ELSE { NONE } });
} COMMENT "Indique si le second facteur d'une identité est verrouillé ({ identity_hash }) : { locked, until }. Session système";

DEFINE FUNCTION OVERWRITE fn::auth_mfa_failure_record($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identity_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }], required: true },
            flow: { pipeline: [{ rule: "record", options: { expected_table: "auth_flow" } }] },
            method: { pipeline: [{ rule: "enum", options: { allowed: ["password", "totp", "passkey", "recovery_code"], case_sensitive: true } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, { fields: { identity_hash: { pipeline: [{ rule: "lowercase" }] } }, unknown_keys: "keep" }, 20);
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $now = time::now();
    LET $hash = $p.identity_hash;
    LET $window = duration::from_secs(fn::auth_policy_value({ theme: "lockout", key: "window_seconds", default: 900 }));
    LET $lock = duration::from_secs(fn::auth_policy_value({ theme: "lockout", key: "lock_seconds", default: 900 }));
    LET $limit = fn::auth_policy_value({ theme: "lockout", key: "max_failures", default: 10 });
    LET $row = (SELECT * FROM ONLY auth_login_failure WHERE kind = "mfa" AND key_hash = $hash LIMIT 1);
    LET $fresh = $row == NONE OR $row.window_start + $window <= $now;
    LET $failures = IF $fresh { 1 } ELSE { $row.failures + 1 };
    LET $locked_until = IF $failures >= $limit { $now + $lock } ELSE { $row.locked_until };
    IF $row == NONE {
        CREATE auth_login_failure CONTENT { kind: "mfa", key_hash: $hash, failures: $failures, window_start: $now, locked_until: $locked_until };
    } ELSE {
        UPDATE $row.id SET failures = $failures, window_start = IF $fresh { $now } ELSE { window_start }, locked_until = $locked_until;
    };
    -- Essais du parcours : au-delà de mfa.max_attempts, le parcours échoue
    LET $flow_failed = IF $p.flow IS NONE { false } ELSE {
        LET $max = fn::auth_policy_value({ theme: "mfa", key: "max_attempts", default: 5 });
        LET $f = (UPDATE ONLY $p.flow SET attempts += 1 WHERE state NOT IN ["completed", "failed"]);
        IF $f != NONE AND $f.attempts >= $max { UPDATE $p.flow SET state = "failed"; true } ELSE { false }
    };
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(), event_type: "auth.mfa.failed", producer: "lyxal_auth", source: $p.identity,
        payload: { identity_hash: $hash, method: $p.method, locked: $failures = $limit },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
    RETURN fn::result_ok({ locked: $locked_until IS NOT NONE AND $locked_until > $now, until: $locked_until, flow_failed: $flow_failed });
} COMMENT "Compte un échec du second facteur ({ identity_hash, identity, flow, method }) : verrouillage au seuil de lockout.max_failures, parcours échoué au-delà de mfa.max_attempts, événement auth.mfa.failed ; { locked, until, flow_failed }. Session système";

DEFINE FUNCTION OVERWRITE fn::auth_mfa_failure_reset($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identity_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, { fields: { identity_hash: { pipeline: [{ rule: "lowercase" }] } }, unknown_keys: "keep" }, 20);
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    DELETE auth_login_failure WHERE kind = "mfa" AND key_hash = $p.identity_hash;
    RETURN fn::result_ok({ reset: true });
} COMMENT "Remet à zéro le compteur du second facteur d'une identité après un succès ({ identity_hash }). Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_flow_state_save / fn::auth_flow_state_take : état scellé d'une cérémonie passkey
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_flow_state_save($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            flow: { pipeline: [{ rule: "record", options: { expected_table: "auth_flow" } }], required: true },
            secret_state: { pipeline: [{ rule: "required_string", options: { min_length: 16, max_length: 65536 } }, { rule: "starts_with", options: { prefixes: ["enc:v2:"], case_sensitive: true, trim_value: false } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $loaded = fn::auth_flow_load({ flow: $p.flow });
    IF $loaded.code IS NOT NONE { RETURN fn::error_result($loaded.code, $p.language, {}); };
    LET $saved = (UPDATE ONLY $p.flow SET secret_state = $p.secret_state);
    IF $saved == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_flow" }); };
    RETURN fn::result_ok({ flow: $saved.id, type: $saved.type });
} COMMENT "Conserve l'état scellé (enc:v2) d'une cérémonie passkey dans un parcours en cours ({ flow, secret_state }) ; un nouvel état remplace le précédent. Session système";

DEFINE FUNCTION OVERWRITE fn::auth_flow_state_take($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            flow: { pipeline: [{ rule: "record", options: { expected_table: "auth_flow" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $loaded = fn::auth_flow_load({ flow: $p.flow });
    IF $loaded.code IS NOT NONE { RETURN fn::error_result($loaded.code, $p.language, {}); };
    -- Lecture unique : l'état est effacé dans la même instruction (un défi ne sert qu'une fois)
    LET $prior = (UPDATE ONLY $p.flow SET secret_state = NONE WHERE secret_state IS NOT NONE RETURN BEFORE);
    IF $prior == NONE { RETURN fn::error_result("AUTH_FLOW_INVALID_STATE", $p.language, {}); };
    RETURN fn::result_ok({
        flow: $prior.id, type: $prior.type, state: $prior.state, identity: $prior.identity,
        organization: $prior.organization, session: $prior.session, methods: $prior.methods, secret_state: $prior.secret_state
    });
} COMMENT "Lit et efface l'état scellé d'une cérémonie passkey ({ flow }) : un défi ne sert qu'une fois ; AUTH_FLOW_INVALID_STATE s'il n'y en a pas. Session système";
