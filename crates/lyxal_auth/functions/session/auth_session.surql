-- ============================================================================
-- FONCTIONS : sessions et jetons de renouvellement
-- MODULE    : lyxal_auth
-- ============================================================================
-- Modèle : Kratos `sessions`, Rauthy (renouvellement à usage unique, révocation de la famille à
-- la réutilisation). Les jetons sont produits et signés en Rust ; la base reçoit les empreintes
-- et renvoie ce que le jeton d'accès doit porter (session, sujet, organisation, permissions,
-- version des droits, durées). Session système, sauf auth_session_list.

-- ----------------------------------------------------------------------------
-- fn::auth_subject_permissions : permissions et version des droits d'un sujet (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_subject_permissions($params: object) -> object {
    IF $params.application IS NOT NONE {
        LET $result = fn::auth_application_permissions({ application: <string> $params.application });
        RETURN IF $result.ok { { code: NONE, permissions: $result.data.permissions, version: $result.data.version } } ELSE { { code: $result.error.code } };
    };
    LET $result = fn::auth_identity_permissions({
        identity: <string> $params.identity,
        organization: IF $params.organization IS NONE { NONE } ELSE { <string> $params.organization }
    });
    IF !$result.ok { RETURN { code: $result.error.code }; };
    -- auth.self.manage (ses propres sessions, clés d'API, adresses) : accordée à toute identité
    LET $all = array::sort(array::distinct(array::concat($result.data.permissions, ["auth.self.manage"])));
    LET $permissions = IF $params.limit IS NONE { $all } ELSE {
        array::filter($all, |$code| $code IN $params.limit)
    };
    RETURN { code: NONE, permissions: $permissions, version: $result.data.version };
} COMMENT "Permissions effectives et version des droits d'un sujet ({ identity, organization, application, limit }) : { code, permissions, version }";

-- ----------------------------------------------------------------------------
-- fn::auth_session_open : crée la session et son jeton de renouvellement (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_session_open($params: object) -> object {
    LET $now = time::now();
    LET $subject = IF $params.identity IS NOT NONE { (SELECT state FROM ONLY $params.identity) } ELSE { (SELECT state FROM ONLY $params.application) };
    IF $subject == NONE { RETURN { code: IF $params.identity IS NOT NONE { "AUTH_IDENTITY_NOT_FOUND" } ELSE { "AUTH_APPLICATION_NOT_FOUND" } }; };
    IF $subject.state != "active" { RETURN { code: IF $params.identity IS NOT NONE { "AUTH_IDENTITY_INACTIVE" } ELSE { "AUTH_APPLICATION_INACTIVE" } }; };
    IF $params.organization IS NOT NONE AND (SELECT VALUE state FROM ONLY $params.organization) != "active" { RETURN { code: "AUTH_ORGANIZATION_INACTIVE" }; };
    LET $rights = fn::auth_subject_permissions({ identity: $params.identity, application: $params.application, organization: $params.organization, limit: $params.limit });
    IF $rights.code IS NOT NONE { RETURN { code: $rights.code }; };
    -- Méthodes (AMR) : chaînes d'une authentification qui vient d'avoir lieu, ou entrées { method, at }
    -- reprises d'une session (changement d'organisation). AAL calculé (Kratos) : 2 dès qu'un second
    -- facteur figure dans l'AMR (une passkey avec vérification de l'utilisateur en est un, Q3).
    LET $amr = array::map($params.amr ?? [], |$m| IF type::is_object($m) { $m } ELSE { { method: $m, at: $now } });
    LET $aal = IF array::len(array::intersect($amr.method, ["totp", "passkey", "recovery_code"])) > 0 { 2 } ELSE { 1 };
    -- Un second facteur désactivé par la politique effective n'ouvre pas de session
    LET $allowed = fn::auth_policy_value({ theme: "mfa", key: "methods", default: ["totp", "passkey", "recovery_code"], organization: $params.organization });
    IF array::any($amr.method, |$m| $m IN ["totp", "passkey", "recovery_code"] AND $m NOT IN $allowed) { RETURN { code: "AUTH_MFA_METHOD_DISABLED" }; };
    -- Session interactive : une identité qui a un second facteur, ou à qui il est exigé, n'ouvre
    -- pas de session sur le seul mot de passe
    IF $params.kind = "interactive" AND $aal < 2 AND (
        ((SELECT VALUE available_aal FROM ONLY $params.identity) ?? 0) >= 2
        OR fn::auth_mfa_required({ identity: $params.identity, organization: $params.organization })
    ) { RETURN { code: "AUTH_MFA_REQUIRED" }; };
    LET $policy = fn::auth_policy_get({ organization: IF $params.organization IS NONE { NONE } ELSE { <string> $params.organization } }).data ?? {};
    LET $access_ttl = $policy.session.access_seconds ?? 900;
    LET $idle = $policy.session.idle_seconds ?? 1800;
    LET $absolute = $policy.session.absolute_seconds ?? 43200;
    LET $refresh_ttl = $policy.refresh.ttl_seconds ?? 43200;
    LET $computed = IF $params.kind = "interactive" { $now + duration::from_secs($absolute) } ELSE { $now + duration::from_secs($access_ttl) };
    -- Plafond (changement d'organisation : jamais au-delà de la session d'origine)
    LET $expires_at = IF $params.expires_cap IS NONE { $computed } ELSE { array::min([$computed, $params.expires_cap]) };
    LET $sess = (CREATE ONLY type::record("auth_session", string::replace(<string> rand::uuid::v7(), "-", "")) CONTENT {
        identity: $params.identity,
        application: $params.application,
        api_key: $params.api_key,
        kind: $params.kind,
        organization: $params.organization,
        aal: $aal,
        amr: $amr,
        authenticated_at: $params.authenticated_at ?? $now,
        client: $params.client ?? {},
        access_slot: $params.access_slot,
        permissions_version: $rights.version,
        idle_expires_at: IF $params.kind = "interactive" { array::min([$now + duration::from_secs($idle), $expires_at]) } ELSE { $expires_at },
        expires_at: $expires_at
    });
    IF $sess == NONE { RETURN { code: "AUTH_WRITE_FORBIDDEN" }; };
    LET $refresh_expires_at = IF $params.refresh_token_hash IS NONE { NONE } ELSE { array::min([$now + duration::from_secs($refresh_ttl), $expires_at]) };
    IF $refresh_expires_at IS NOT NONE {
        CREATE auth_refresh_token CONTENT { session: $sess.id, token_hash: string::lowercase($params.refresh_token_hash), expires_at: $refresh_expires_at };
    };
    RETURN {
        code: NONE,
        session: $sess.id,
        identity: $params.identity,
        application: $params.application,
        organization: $params.organization,
        kind: $params.kind,
        permissions: $rights.permissions,
        version: $rights.version,
        aal: $aal,
        access_seconds: $access_ttl,
        idle_expires_at: $sess.idle_expires_at,
        expires_at: $expires_at,
        refresh_expires_at: $refresh_expires_at
    };
} COMMENT "Crée une session ({ identity | application, api_key, kind, organization, amr, authenticated_at, client, access_slot, refresh_token_hash, limit, expires_cap }) et son jeton de renouvellement ; AAL calculé depuis l'AMR ; session interactive sur le seul mot de passe refusée (AUTH_MFA_REQUIRED) si l'identité a un second facteur ou s'il lui est exigé ; renvoie ce que porte le jeton d'accès";

-- ----------------------------------------------------------------------------
-- fn::auth_session_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_session_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }], required: true },
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            amr: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: false } }, { rule: "each", options: { pipeline: [{ rule: "enum", options: { allowed: ["password", "totp", "passkey", "recovery_code"], case_sensitive: true } }] } }], required: true },
            client: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: { fields: {
                ip: { pipeline: [{ rule: "ip" }] },
                user_agent: { pipeline: [{ rule: "optional_string", options: { max_length: 512 } }] }
            }, unknown_keys: "reject" } } }], default: {} },
            access_slot: { pipeline: [{ rule: "enum", options: { allowed: ["a", "b"], case_sensitive: true } }], required: true },
            refresh_token_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $opened = fn::auth_session_open({
        identity: $p.identity, kind: "interactive", organization: $p.organization, amr: $p.amr,
        client: $p.client, access_slot: $p.access_slot, refresh_token_hash: $p.refresh_token_hash
    });
    IF $opened.code IS NOT NONE { RETURN fn::error_result($opened.code, $p.language, {}); };
    UPDATE $p.identity SET last_login_at = time::now();
    RETURN fn::result_ok(object::remove($opened, "code"));
} COMMENT "Ouvre une session interactive ({ identity, organization, amr : password, totp, passkey, recovery_code ; client, access_slot, refresh_token_hash }) après une authentification vérifiée par l'hôte : adhésion active exigée pour une organisation, double facteur contrôlé (AUTH_MFA_REQUIRED) ; renvoie session, permissions, version, AAL et durées. Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_session_refresh
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_session_refresh($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            token_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            new_token_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
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
    LET $refresh = (SELECT * FROM ONLY auth_refresh_token WHERE token_hash = string::lowercase($p.token_hash) LIMIT 1);
    IF $refresh == NONE { RETURN fn::error_result("AUTH_REFRESH_INVALID", $p.language, {}); };
    -- Réutilisation d'un jeton déjà échangé : vol probable, toute la session est révoquée
    IF $refresh.state = "used" {
        UPDATE $refresh.session SET state = "revoked", revoked_at = $now, revoked_reason = "refresh_reused";
        UPDATE auth_refresh_token SET state = "revoked" WHERE session = $refresh.session AND state = "active";
        LET $published = fn::event_publish({
            event_id: rand::uuid::v7(), event_type: "auth.refresh.reused", producer: "lyxal_auth", source: $refresh.session,
            payload: { session_id: <string> $refresh.session, identity_id: IF $refresh.session.identity IS NONE { NONE } ELSE { <string> $refresh.session.identity } },
            metadata: {}
        });
        IF !$published.ok { THROW $published.error.code; };
        RETURN fn::error_result("AUTH_REFRESH_REUSED", $p.language, {});
    };
    IF $refresh.state != "active" OR $refresh.expires_at <= $now { RETURN fn::error_result("AUTH_REFRESH_INVALID", $p.language, {}); };
    LET $sess = (SELECT * FROM ONLY $refresh.session);
    IF $sess == NONE OR $sess.state != "active" OR $sess.expires_at <= $now OR $sess.idle_expires_at <= $now {
        RETURN fn::error_result("AUTH_REFRESH_INVALID", $p.language, {});
    };
    -- Échange conditionnel : deux renouvellements simultanés avec le même jeton n'en valident qu'un
    LET $used = (UPDATE ONLY $refresh.id SET state = "used", used_at = $now WHERE state = "active");
    IF $used == NONE { RETURN fn::error_result("AUTH_REFRESH_REUSED", $p.language, {}); };
    LET $subject = (SELECT state, not_before FROM ONLY $sess.identity);
    IF $subject == NONE OR $subject.state != "active" OR ($subject.not_before IS NOT NONE AND $sess.created_at < $subject.not_before) {
        UPDATE $sess.id SET state = "revoked", revoked_at = $now, revoked_reason = "subject_inactive";
        RETURN fn::error_result("AUTH_REFRESH_INVALID", $p.language, {});
    };
    LET $rights = fn::auth_subject_permissions({ identity: $sess.identity, organization: $sess.organization });
    IF $rights.code IS NOT NONE {
        UPDATE $sess.id SET state = "revoked", revoked_at = $now, revoked_reason = "rights_lost";
        RETURN fn::error_result("AUTH_REFRESH_INVALID", $p.language, {});
    };
    LET $policy = fn::auth_policy_get({ organization: IF $sess.organization IS NONE { NONE } ELSE { <string> $sess.organization } }).data ?? {};
    LET $idle = array::min([$now + duration::from_secs($policy.session.idle_seconds ?? 1800), $sess.expires_at]);
    LET $refresh_until = array::min([$now + duration::from_secs($policy.refresh.ttl_seconds ?? 43200), $sess.expires_at]);
    UPDATE $sess.id SET idle_expires_at = $idle, last_seen_at = $now, access_slot = $p.access_slot, permissions_version = $rights.version;
    CREATE auth_refresh_token CONTENT { session: $sess.id, token_hash: string::lowercase($p.new_token_hash), expires_at: $refresh_until };
    RETURN fn::result_ok({
        session: $sess.id,
        identity: $sess.identity,
        application: NONE,
        organization: $sess.organization,
        kind: $sess.kind,
        permissions: $rights.permissions,
        version: $rights.version,
        aal: $sess.aal,
        access_seconds: $policy.session.access_seconds ?? 900,
        idle_expires_at: $idle,
        expires_at: $sess.expires_at,
        refresh_expires_at: $refresh_until
    });
} COMMENT "Échange un jeton de renouvellement ({ token_hash, new_token_hash, access_slot }) : usage unique ; réutilisation → session révoquée (AUTH_REFRESH_REUSED) ; permissions recalculées, inactivité repoussée (jamais l'expiration absolue). Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_session_revoke / fn::auth_session_revoke_all
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_session_revoke($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            session: { pipeline: [{ rule: "record", options: { expected_table: "auth_session" } }], required: true },
            reason: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], default: "logout" },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $revoked = (UPDATE ONLY $p.session SET state = "revoked", revoked_at = time::now(), revoked_reason = $p.reason WHERE state = "active");
    UPDATE auth_refresh_token SET state = "revoked" WHERE session = $p.session AND state = "active";
    RETURN fn::result_ok({ session: $p.session, revoked: $revoked IS NOT NONE });
} COMMENT "Révoque une session ({ session, reason }) et ses jetons de renouvellement ; sans effet sur une session déjà terminée. Session système";

DEFINE FUNCTION OVERWRITE fn::auth_session_revoke_all($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }], required: true },
            except_session: { pipeline: [{ rule: "record", options: { expected_table: "auth_session" } }] },
            reason: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], default: "revoke_all" },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $revoked = (UPDATE auth_session SET state = "revoked", revoked_at = time::now(), revoked_reason = $p.reason
        WHERE identity = $p.identity AND state = "active" AND ($p.except_session IS NONE OR id != $p.except_session) RETURN id);
    UPDATE auth_refresh_token SET state = "revoked" WHERE session IN $revoked AND state = "active";
    RETURN fn::result_ok({ revoked: array::len($revoked) });
} COMMENT "Révoque toutes les sessions d'une identité ({ identity, except_session, reason }). Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_session_switch_organization
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_session_switch_organization($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            session: { pipeline: [{ rule: "record", options: { expected_table: "auth_session" } }], required: true },
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            access_slot: { pipeline: [{ rule: "enum", options: { allowed: ["a", "b"], case_sensitive: true } }], required: true },
            refresh_token_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $current = (SELECT * FROM ONLY $p.session);
    IF $current == NONE OR $current.state != "active" OR $current.kind != "interactive" OR $current.expires_at <= time::now() {
        RETURN fn::error_result("AUTH_SESSION_REVOKED", $p.language, {});
    };
    LET $opened = fn::auth_session_open({
        identity: $current.identity, kind: "interactive", organization: $p.organization, amr: $current.amr,
        authenticated_at: $current.authenticated_at,
        client: $current.client, access_slot: $p.access_slot, refresh_token_hash: $p.refresh_token_hash,
        -- La nouvelle session hérite de l'expiration absolue de l'ancienne (aucun allongement)
        expires_cap: $current.expires_at
    });
    IF $opened.code IS NOT NONE { RETURN fn::error_result($opened.code, $p.language, {}); };
    UPDATE $current.id SET state = "revoked", revoked_at = time::now(), revoked_reason = "organization_switch";
    UPDATE auth_refresh_token SET state = "revoked" WHERE session = $current.id AND state = "active";
    RETURN fn::result_ok(object::remove($opened, "code"));
} COMMENT "Change l'organisation active ({ session, organization, access_slot, refresh_token_hash }) : nouvelle session pour la même identité (adhésion active exigée), même expiration absolue, ancienne session révoquée. Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_session_list : sessions visibles par l'appelant
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_session_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
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
    IF $p.organization IS NOT NONE AND !fn::auth_has_permission({ permission: "auth.session.manage", tenant: $p.organization }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.session.manage" });
    };
    LET $self = IF $check.system { NONE } ELSE { (SELECT VALUE identity FROM ONLY $auth) };
    LET $identity = $p.identity ?? (IF $p.organization IS NONE { $self } ELSE { NONE });
    LET $rows = (SELECT id, identity, application, kind, organization, aal, client, created_at, last_seen_at, idle_expires_at, expires_at
        FROM auth_session
        WHERE state = "active" AND expires_at > time::now()
            AND ($identity IS NONE OR identity = $identity)
            AND ($p.organization IS NONE OR organization = $p.organization)
        ORDER BY last_seen_at DESC LIMIT $p.limit);
    RETURN fn::result_ok(array::map($rows, |$r| object::extend($r, { current: $auth IS NOT NONE AND $r.id = $auth })));
} COMMENT "Sessions actives visibles par l'appelant ({ organization, identity, limit }) : les siennes par défaut ; celles d'une organisation avec auth.session.manage ; current marque la session de l'appel";

-- ----------------------------------------------------------------------------
-- fn::auth_session_check : validité d'une session désignée par un jeton vérifié par l'hôte
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_session_check($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            session: { pipeline: [{ rule: "record", options: { expected_table: "auth_session" } }], required: true },
            pv: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], required: true },
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
    LET $s = (SELECT * FROM ONLY $p.session);
    IF $s == NONE OR $s.state = "revoked" { RETURN fn::error_result("AUTH_SESSION_REVOKED", $p.language, {}); };
    IF $s.state != "active" OR $s.expires_at <= $now OR $s.idle_expires_at <= $now { RETURN fn::error_result("AUTH_SESSION_EXPIRED", $p.language, {}); };
    LET $subject = IF $s.identity IS NOT NONE { (SELECT state, not_before, permissions_version FROM ONLY $s.identity) } ELSE { (SELECT state, not_before, permissions_version FROM ONLY $s.application) };
    IF $subject == NONE OR $subject.state != "active" { RETURN fn::error_result(IF $s.identity IS NOT NONE { "AUTH_IDENTITY_INACTIVE" } ELSE { "AUTH_APPLICATION_INACTIVE" }, $p.language, {}); };
    IF $subject.not_before IS NOT NONE AND $s.created_at < $subject.not_before { RETURN fn::error_result("AUTH_SESSION_REVOKED", $p.language, {}); };
    IF $s.api_key IS NOT NONE {
        LET $key = (SELECT revoked_at, expires_at FROM ONLY $s.api_key);
        IF $key == NONE OR $key.revoked_at IS NOT NONE OR ($key.expires_at IS NOT NONE AND $key.expires_at <= $now) { RETURN fn::error_result("AUTH_SESSION_REVOKED", $p.language, {}); };
    };
    IF $p.pv < $subject.permissions_version { RETURN fn::error_result("AUTH_SESSION_STALE", $p.language, {}); };
    RETURN fn::result_ok({ session: $s.id, identity: $s.identity, application: $s.application, organization: $s.organization, kind: $s.kind });
} COMMENT "Validité d'une session ({ session, pv }) désignée par un jeton dont l'hôte a vérifié la signature : mêmes règles que fn::auth_session_valid (état, expirations, sujet actif, not_before, clé d'API, version des droits). Session système";
