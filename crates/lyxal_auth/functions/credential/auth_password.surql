-- ============================================================================
-- FONCTIONS : mots de passe et actions imposées
-- MODULE    : lyxal_auth
-- ============================================================================
-- Le hachage (Argon2id) et la vérification sont faits en Rust (lyxal_crypto::password) ; la base
-- conserve l'empreinte scellée (enc:v2) et l'historique, et porte les règles (état de l'identité,
-- actions imposées). Fonctions de la session système, sauf mention contraire.

-- ----------------------------------------------------------------------------
-- fn::auth_password_credential_get : identité et empreinte scellée d'un identifiant
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_password_credential_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identifier: { pipeline: [{ rule: "email", options: { max_length: 254 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $value = fn::sanitize_pipeline_execute($p.identifier, [{ rule: "email" }], 5);
    LET $identity = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE type = "email" AND value = $value LIMIT 1);
    -- Identifiant inconnu : réponse sans identité ; l'hôte vérifie alors une empreinte factice
    IF $identity IS NONE { RETURN fn::result_ok({ identity: NONE, identifier: $value, state: NONE, secret: NONE, required_actions: [] }); };
    LET $state = (SELECT VALUE state FROM ONLY $identity);
    LET $secret = (SELECT VALUE secret_data FROM ONLY auth_credential WHERE identity = $identity AND type = "password" LIMIT 1);
    RETURN fn::result_ok({
        identity: $identity,
        identifier: $value,
        state: $state,
        secret: $secret,
        required_actions: (SELECT VALUE action FROM auth_required_action WHERE identity = $identity ORDER BY action)
    });
} COMMENT "Identité, état, empreinte scellée du mot de passe et actions imposées d'un identifiant e-mail ({ identifier }) ; identité absente si inconnu (pas d'énumération : l'hôte vérifie une empreinte factice). Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_password_set : enregistre l'empreinte scellée d'un mot de passe
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_password_set($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }], required: true },
            secret: { pipeline: [{ rule: "required_string", options: { min_length: 16, max_length: 16384 } }, { rule: "starts_with", options: { prefixes: ["enc:v2:"], case_sensitive: true, trim_value: false } }], required: true },
            revoke_sessions: { pipeline: [{ rule: "boolean" }], default: false },
            except_session: { pipeline: [{ rule: "record", options: { expected_table: "auth_session" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    IF !record::exists($p.identity) { RETURN fn::error_result("AUTH_IDENTITY_NOT_FOUND", $p.language, {}); };
    LET $existing = (SELECT VALUE id FROM ONLY auth_credential WHERE identity = $p.identity AND type = "password" LIMIT 1);
    LET $saved = IF $existing IS NONE {
        (CREATE ONLY auth_credential CONTENT { identity: $p.identity, type: "password", secret_data: $p.secret })
    } ELSE {
        (UPDATE ONLY $existing SET secret_data = $p.secret)
    };
    IF $saved == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_credential" }); };
    DELETE auth_required_action WHERE identity = $p.identity AND action = "update_password";
    LET $revoked = IF $p.revoke_sessions {
        (UPDATE auth_session SET state = "revoked", revoked_at = time::now(), revoked_reason = "password_changed"
            WHERE identity = $p.identity AND state = "active" AND ($p.except_session IS NONE OR id != $p.except_session) RETURN id)
    } ELSE { [] };
    RETURN fn::result_ok({ credential: $saved.id, sessions_revoked: array::len($revoked) });
} COMMENT "Enregistre l'empreinte scellée du mot de passe ({ identity, secret enc:v2, revoke_sessions, except_session }) : historique et politique contrôlés en Rust, action update_password levée, autres sessions révoquées si demandé. Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_required_action_add / _list / _complete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_required_action_add($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }], required: true },
            action: { pipeline: [{ rule: "enum", options: { allowed: ["verify_email", "update_password", "accept_terms"], case_sensitive: true } }], required: true },
            reason: { pipeline: [{ rule: "optional_string", options: { max_length: 256 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_has_permission({ permission: "auth.identity.manage" }) { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.identity.manage" }); };
    IF !record::exists($p.identity) { RETURN fn::error_result("AUTH_IDENTITY_NOT_FOUND", $p.language, {}); };
    LET $existing = (SELECT VALUE id FROM ONLY auth_required_action WHERE identity = $p.identity AND action = $p.action LIMIT 1);
    IF $existing IS NOT NONE { RETURN fn::result_ok({ action: $existing, created: false }); };
    LET $created = (CREATE ONLY auth_required_action CONTENT { identity: $p.identity, action: $p.action, reason: $p.reason });
    IF $created == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_required_action" }); };
    RETURN fn::result_ok({ action: $created.id, created: true });
} COMMENT "Impose une action à une identité avant sa prochaine session ({ identity, action : verify_email, update_password, accept_terms ; reason }). Permission auth.identity.manage";

DEFINE FUNCTION OVERWRITE fn::auth_required_action_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }] },
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
    LET $identity = $p.identity ?? (IF $check.system { NONE } ELSE { (SELECT VALUE identity FROM ONLY $auth) });
    IF $identity IS NONE { RETURN fn::error_result("AUTH_INVALID_PARAMETERS", $p.language, { fields: { identity: ["CORE_VALIDATION_REQUIRED"] } }); };
    RETURN fn::result_ok(SELECT id, action, reason, created_at FROM auth_required_action WHERE identity = $identity ORDER BY action);
} COMMENT "Actions imposées d'une identité ({ identity } ; par défaut celle de la session) visibles par l'appelant";

DEFINE FUNCTION OVERWRITE fn::auth_required_action_complete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }], required: true },
            action: { pipeline: [{ rule: "enum", options: { allowed: ["verify_email", "update_password", "accept_terms"], case_sensitive: true } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $deleted = (DELETE auth_required_action WHERE identity = $p.identity AND action = $p.action RETURN BEFORE);
    RETURN fn::result_ok({ completed: array::len($deleted) > 0 });
} COMMENT "Lève une action imposée ({ identity, action }) une fois faite dans le parcours. Session système";
