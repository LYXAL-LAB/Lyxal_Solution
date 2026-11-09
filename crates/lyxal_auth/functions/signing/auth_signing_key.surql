-- ============================================================================
-- FONCTIONS : clés de signature des jetons et clé de condensation des codes ; purge
-- MODULE    : lyxal_auth
-- ============================================================================
-- Les clés sont générées en Rust (OsRng) et scellées (SecretContext::global) ; la base garde
-- l'emplacement actif et la garde de réutilisation. Deux accès SurrealDB en alternance
-- (lyxal_auth_a, lyxal_auth_b) : un emplacement n'est écrasé qu'une fois expirés tous les jetons
-- qu'il a pu signer. Session système.

-- ----------------------------------------------------------------------------
-- fn::auth_signing_key_get_active
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_signing_key_get_active($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            purpose: { pipeline: [{ rule: "enum", options: { allowed: ["access_token", "code_pepper"], case_sensitive: true } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $keys = (SELECT slot, secret, state, activated_at, reusable_after FROM auth_signing_key WHERE purpose = $p.purpose ORDER BY activated_at DESC);
    LET $active = array::find($keys, |$k| $k.state = "active");
    IF $active IS NONE { RETURN fn::error_result("AUTH_SIGNING_KEY_UNAVAILABLE", $p.language, {}); };
    RETURN fn::result_ok({ active: $active, previous: array::find($keys, |$k| $k.state = "previous") });
} COMMENT "Clé active (et précédente) d'un usage ({ purpose : access_token, code_pepper }) : { active, previous } avec secret scellé et emplacement. Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_signing_key_rotate
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_signing_key_rotate($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            purpose: { pipeline: [{ rule: "enum", options: { allowed: ["access_token", "code_pepper"], case_sensitive: true } }], required: true },
            secret: { pipeline: [{ rule: "required_string", options: { min_length: 16, max_length: 4096 } }, { rule: "starts_with", options: { prefixes: ["enc:v2:"], case_sensitive: true, trim_value: false } }], required: true },
            force: { pipeline: [{ rule: "boolean" }], default: false },
            cache_seconds: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 600 } }], default: 30 },
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
    LET $active = (SELECT * FROM ONLY auth_signing_key WHERE purpose = $p.purpose AND state = "active" LIMIT 1);
    -- Clé de condensation des codes : créée une fois (la changer invaliderait les codes en cours)
    IF $p.purpose = "code_pepper" {
        IF $active IS NOT NONE { RETURN fn::result_ok({ slot: NONE, created: false }); };
        CREATE auth_signing_key CONTENT { purpose: "code_pepper", secret: $p.secret, state: "active", activated_at: $now };
        RETURN fn::result_ok({ slot: NONE, created: true });
    };
    IF $active == NONE {
        CREATE type::record("auth_signing_key", "access_token_a") CONTENT { purpose: "access_token", slot: "a", secret: $p.secret, state: "active", activated_at: $now };
        RETURN fn::result_ok({ slot: "a", created: true });
    };
    LET $target = IF $active.slot = "a" { "b" } ELSE { "a" };
    LET $existing = (SELECT * FROM ONLY type::record("auth_signing_key", string::concat("access_token_", $target)));
    -- Garde : l'emplacement visé ne doit plus pouvoir vérifier un jeton encore valide
    IF $existing IS NOT NONE AND !$p.force AND $existing.reusable_after IS NOT NONE AND $existing.reusable_after > $now {
        RETURN fn::error_result("AUTH_SIGNING_KEY_ROTATION_TOO_SOON", $p.language, { reusable_after: $existing.reusable_after });
    };
    -- Durée maximale d'un jeton d'accès : la plus longue des politiques (installation et organisations)
    LET $longest = math::max(array::concat([900], (SELECT VALUE session.access_seconds FROM auth_policy WHERE session.access_seconds IS NOT NONE)));
    -- Sérialisation : seule une rotation qui voit encore la même clé active la désactive
    LET $deactivated = (UPDATE ONLY $active.id SET state = "previous", deactivated_at = $now,
        reusable_after = $now + duration::from_secs($p.cache_seconds + $longest)
        WHERE state = "active" AND activated_at = $active.activated_at);
    IF $deactivated == NONE { RETURN fn::error_result("AUTH_SIGNING_KEY_ROTATION_TOO_SOON", $p.language, { reason: "concurrent_rotation" }); };
    UPSERT type::record("auth_signing_key", string::concat("access_token_", $target)) CONTENT {
        purpose: "access_token", slot: $target, secret: $p.secret, state: "active", activated_at: $now,
        deactivated_at: NONE, reusable_after: NONE
    };
    RETURN fn::result_ok({ slot: $target, created: true, previous_reusable_after: $deactivated.reusable_after });
} COMMENT "Active une nouvelle clé ({ purpose, secret enc:v2, force, cache_seconds }) : access_token dans l'emplacement inactif, refusé (AUTH_SIGNING_KEY_ROTATION_TOO_SOON) tant que des jetons signés par l'ancienne clé de cet emplacement peuvent être valides, sauf force (révocation d'urgence) ; code_pepper créé une seule fois. Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_purge
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_purge($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 10000 } }], default: 500 },
            session_retention_days: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 3650 } }], default: 30 },
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
    LET $keep = $now - duration::from_days($p.session_retention_days);
    LET $expired_sessions = (UPDATE auth_session SET state = "expired" WHERE state = "active" AND (expires_at <= $now OR idle_expires_at <= $now) RETURN id);
    LET $flows = (SELECT VALUE id FROM auth_flow WHERE expires_at <= $now LIMIT $p.limit);
    IF array::len($flows) > 0 { DELETE $flows; };
    LET $tokens = (SELECT VALUE id FROM auth_refresh_token WHERE expires_at <= $now OR (state != "active" AND created_at <= $keep) LIMIT $p.limit);
    IF array::len($tokens) > 0 { DELETE $tokens; };
    LET $sessions = (SELECT VALUE id FROM auth_session WHERE state != "active" AND (revoked_at ?? expires_at) <= $keep LIMIT $p.limit);
    IF array::len($sessions) > 0 { DELETE $sessions; };
    LET $failures = (SELECT VALUE id FROM auth_login_failure WHERE (locked_until IS NONE OR locked_until <= $now) AND updated_at <= $now - 1d LIMIT $p.limit);
    IF array::len($failures) > 0 { DELETE $failures; };
    LET $invitations = (UPDATE auth_organization_invitation SET state = "expired" WHERE state = "pending" AND expires_at <= $now RETURN id);
    -- TOTP jamais confirmés au-delà de la durée d'un parcours
    LET $pending_ttl = duration::from_secs(fn::auth_policy_value({ theme: "flow", key: "ttl_seconds", default: 900 }));
    LET $pending = (SELECT VALUE id FROM auth_credential WHERE type = "totp" AND state = "pending" AND created_at <= $now - $pending_ttl LIMIT $p.limit);
    IF array::len($pending) > 0 { DELETE $pending; };
    LET $claims = (SELECT VALUE id FROM auth_invitation_claim WHERE created_at <= $now - 1d LIMIT $p.limit);
    IF array::len($claims) > 0 { DELETE $claims; };
    RETURN fn::result_ok({
        sessions_expired: array::len($expired_sessions),
        flows: array::len($flows),
        refresh_tokens: array::len($tokens),
        sessions: array::len($sessions),
        login_failures: array::len($failures),
        invitations_expired: array::len($invitations),
        pending_totp: array::len($pending),
        invitation_claims: array::len($claims)
    });
} COMMENT "Purge par paquets ({ limit, session_retention_days }) : sessions expirées marquées, parcours et codes expirés, jetons usés ou expirés, sessions terminées au-delà de la conservation, compteurs d'échecs anciens, invitations expirées, TOTP non confirmés, demandes d'acceptation de plus d'un jour. Session système";
