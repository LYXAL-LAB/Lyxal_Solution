-- ============================================================================
-- FONCTIONS : mots de passe d'application
-- MODULE    : lyxal_auth
-- ============================================================================
-- Modèle (comportement seulement) : mots de passe d'application de Stalwart, jetons
-- d'application de RustiCal ; modèle interne : clés d'API et codes de secours. Le mot de passe
-- est tiré, normalisé et condensé en Rust (HMAC-SHA256, clé code_pepper) : la base ne reçoit que
-- des empreintes. Création, révocation, vérification et renouvellement : session système de
-- l'hôte, qui désigne l'acteur (session de l'utilisateur ou de l'administrateur) dont la base
-- revérifie les droits, l'AAL et l'ancienneté. Liste, journal et permissions utilisables :
-- session de l'utilisateur (règles des tables).

-- ----------------------------------------------------------------------------
-- fn::auth_app_password_allowed : permissions utilisables par un mot de passe d'application (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_app_password_allowed($params: object) -> array {
    RETURN SELECT VALUE code FROM auth_permission
        WHERE app_password = true AND scope = "organization" AND (min_aal ?? 1) = 1
        ORDER BY code;
} COMMENT "Codes des permissions déclarées utilisables par un mot de passe d'application ({}) : app_password vrai, portée organisation, niveau d'assurance 1 ; triés";

-- ----------------------------------------------------------------------------
-- fn::auth_app_password_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_app_password_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            session: { pipeline: [{ rule: "record", options: { expected_table: "auth_session" } }], required: true },
            name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
            permissions: { pipeline: [
                { rule: "array_of_strings", options: { allow_empty: false } },
                { rule: "array_length", options: { min_length: 1, max_length: 64 } },
                { rule: "array_unique" },
                { rule: "each", options: { pipeline: [{ rule: "lyxal_permission_name" }] } }
            ], required: true },
            expires_at: { pipeline: [{ rule: "future_datetime", options: { allow_equal: false } }] },
            password_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, { fields: {
        name: { pipeline: [{ rule: "trim" }] },
        password_hash: { pipeline: [{ rule: "lowercase" }] }
    }, unknown_keys: "keep" }, 20);
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    -- Action sensible (A7) : session interactive, AAL la plus haute disponible, authentification récente
    LET $actor = fn::auth_mfa_actor({ session: $p.session, sensitive: true });
    IF $actor.code IS NOT NONE { RETURN fn::error_result($actor.code, $p.language, $actor.details); };
    IF $actor.organization IS NONE { RETURN fn::error_result("AUTH_APP_PASSWORD_ORGANIZATION_REQUIRED", $p.language, {}); };
    -- Droits recalculés en base (pas lus dans un jeton)
    LET $rights = fn::auth_subject_permissions({ identity: $actor.identity, organization: $actor.organization });
    IF $rights.code IS NOT NONE { RETURN fn::error_result($rights.code, $p.language, {}); };
    IF "auth.self.manage" NOT IN $rights.permissions { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.self.manage" }); };
    LET $policy = (fn::auth_policy_get({ organization: <string> $actor.organization }).data ?? {}).app_password ?? {};
    IF !($policy.enabled ?? true) { RETURN fn::error_result("AUTH_APP_PASSWORD_DISABLED", $p.language, {}); };
    -- Permissions détenues dans l'organisation et déclarées utilisables (A4) : jamais auth.*
    LET $allowed = fn::auth_app_password_allowed({});
    LET $refused = array::filter($p.permissions, |$code| $code NOT IN $rights.permissions OR $code NOT IN $allowed);
    IF array::len($refused) > 0 { RETURN fn::error_result("AUTH_APP_PASSWORD_PERMISSION_NOT_ALLOWED", $p.language, { permissions: $refused }); };
    LET $now = time::now();
    -- Expiration : au plus la durée maximale de la politique, qui s'applique si aucune n'est donnée
    LET $latest = IF $policy.max_lifetime_days IS NONE { NONE } ELSE { $now + duration::from_days($policy.max_lifetime_days) };
    IF $latest IS NOT NONE AND $p.expires_at IS NOT NONE AND $p.expires_at > $latest {
        RETURN fn::error_result("AUTH_APP_PASSWORD_EXPIRY_TOO_LONG", $p.language, { max_lifetime_days: $policy.max_lifetime_days });
    };
    LET $active = array::len(SELECT VALUE id FROM auth_app_password
        WHERE identity = $actor.identity AND organization = $actor.organization AND revoked_at IS NONE AND (expires_at IS NONE OR expires_at > $now));
    IF $active >= ($policy.max_per_identity ?? 20) {
        RETURN fn::error_result("AUTH_APP_PASSWORD_LIMIT_REACHED", $p.language, { max_per_identity: $policy.max_per_identity ?? 20 });
    };
    -- Identifiant à saisir dans le logiciel : adresse e-mail de connexion du compte (A3)
    LET $emails = (SELECT VALUE value FROM auth_credential_identifier WHERE identity = $actor.identity AND type = "email" ORDER BY value);
    LET $traits_email = (SELECT VALUE traits.email FROM ONLY $actor.identity);
    LET $preferred = IF type::is_string($traits_email) { fn::sanitize_pipeline_execute($traits_email, [{ rule: "email" }], 5) } ELSE { NONE };
    LET $username = IF $preferred IS NOT NONE AND $preferred IN $emails { $preferred } ELSE { $emails[0] };
    IF $username IS NONE { RETURN fn::error_result("AUTH_IDENTITY_NOT_FOUND", $p.language, {}); };
    LET $created = (CREATE ONLY auth_app_password CONTENT {
        identity: $actor.identity,
        organization: $actor.organization,
        name: $p.name,
        password_hash: $p.password_hash,
        permissions: array::sort($p.permissions),
        expires_at: $p.expires_at ?? $latest
    });
    IF $created == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_app_password" }); };
    RETURN fn::result_ok({
        app_password: {
            id: $created.id,
            name: $created.name,
            organization: $created.organization,
            permissions: $created.permissions,
            expires_at: $created.expires_at,
            state: "active",
            last_used_at: NONE,
            last_used_protocol: NONE,
            last_used_ip: NONE,
            revoked_at: NONE,
            revoked_reason: NONE,
            created_at: $created.created_at
        },
        username: $username
    });
} COMMENT "Crée un mot de passe d'application ({ session : session interactive de l'utilisateur, name, permissions, expires_at, password_hash : HMAC calculé par l'hôte }) : action sensible ; organisation active exigée ; permissions détenues et déclarées utilisables ; politique de l'organisation (activation, nombre maximal, durée maximale) ; événement auth.app_password.created ; { app_password, username }. Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_app_password_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_app_password_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }] },
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
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
    LET $own = IF $check.system { NONE } ELSE { (SELECT VALUE identity FROM ONLY $auth) };
    LET $identity = $p.identity ?? $own;
    IF $identity IS NONE { RETURN fn::error_result("AUTH_INVALID_PARAMETERS", $p.language, { fields: { identity: ["CORE_VALIDATION_REQUIRED"] } }); };
    -- Ceux d'un autre : administrateur de l'installation, ou de l'organisation active (les mots de
    -- passe de cette organisation seulement, par la règle de la table)
    IF !$check.system AND $identity != $own
        AND !fn::auth_has_permission({ permission: "auth.identity.manage" })
        AND !fn::auth_has_permission({ permission: "auth.member.manage", tenant: (SELECT VALUE organization FROM ONLY $auth) }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.identity.manage" });
    };
    LET $now = time::now();
    LET $rows = (SELECT id, name, organization, permissions, expires_at, last_used_at, last_used_protocol, last_used_ip, revoked_at, revoked_reason, created_at
        FROM auth_app_password
        WHERE identity = $identity AND ($p.organization IS NONE OR organization = $p.organization)
        ORDER BY created_at DESC, id DESC);
    RETURN fn::result_ok(array::map($rows, |$r| object::extend($r, {
        state: IF $r.revoked_at IS NOT NONE { "revoked" } ELSE IF $r.expires_at IS NOT NONE AND $r.expires_at <= $now { "expired" } ELSE { "active" }
    })));
} COMMENT "Mots de passe d'application d'une identité, sans empreinte ({ identity : la sienne par défaut, organization }) : état calculé (active, expired, revoked) ; ceux d'un autre avec auth.identity.manage, ou auth.member.manage pour ceux de l'organisation active ; création la plus récente d'abord, puis identifiant décroissant";

-- ----------------------------------------------------------------------------
-- fn::auth_app_password_uses : journal regroupé des connexions
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_app_password_uses($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            app_password: { pipeline: [{ rule: "record", options: { expected_table: "auth_app_password" } }], required: true },
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
    -- Mot de passe invisible pour l'appelant (règle de la table) : introuvable
    IF (SELECT VALUE id FROM ONLY $p.app_password) IS NONE { RETURN fn::error_result("AUTH_APP_PASSWORD_NOT_FOUND", $p.language, {}); };
    RETURN fn::result_ok(SELECT id, protocol, ip, client_name, first_seen_at, last_seen_at, count
        FROM auth_app_password_use WHERE app_password = $p.app_password
        ORDER BY last_seen_at DESC, id DESC LIMIT $p.limit);
} COMMENT "Journal des connexions d'un mot de passe d'application ({ app_password, limit : 1 à 1000, défaut 100 }) : une ligne par protocole et adresse IP (logiciel, première et dernière connexion, nombre), dernière connexion la plus récente d'abord, puis identifiant décroissant ; titulaire ou administrateur (règles des tables)";

-- ----------------------------------------------------------------------------
-- fn::auth_app_password_revoke_all : révocation d'office (interne)
-- ----------------------------------------------------------------------------
-- Appelée par la récupération du compte, la remise à zéro du double facteur et l'événement de
-- sortie d'une organisation. Aucune écriture hors session système ou événement de la base (règle
-- de la table).

DEFINE FUNCTION OVERWRITE fn::auth_app_password_revoke_all($params: object) -> int {
    LET $revoked = (UPDATE auth_app_password SET revoked_at = time::now(), revoked_reason = $params.reason, revoked_by = $params.revoked_by
        WHERE identity = $params.identity AND revoked_at IS NONE AND ($params.organization IS NONE OR organization = $params.organization)
        RETURN id);
    RETURN array::len($revoked);
} COMMENT "Révoque les mots de passe d'application actifs d'une identité ({ identity, organization : toutes si absente, reason, revoked_by }) ; nombre révoqué";

-- ----------------------------------------------------------------------------
-- fn::auth_app_password_revoke
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_app_password_revoke($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            session: { pipeline: [{ rule: "record", options: { expected_table: "auth_session" } }], required: true },
            app_password: { pipeline: [{ rule: "record", options: { expected_table: "auth_app_password" } }] },
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }] },
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    -- Un mot de passe désigné, ou tous ceux d'une identité (dans une organisation ou toutes)
    IF !$report.valid OR ($report.value.app_password IS NONE) = ($report.value.identity IS NONE)
        OR ($report.value.app_password IS NOT NONE AND $report.value.organization IS NOT NONE) {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: IF $report.valid { { app_password: ["CORE_VALIDATION_COMBINATION"] } } ELSE { $report.by_field } });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $actor = fn::auth_mfa_actor({ session: $p.session, sensitive: false });
    IF $actor.code IS NOT NONE { RETURN fn::error_result($actor.code, $p.language, $actor.details); };
    -- Droits de l'acteur relus en base : les siens toujours ; auth.identity.manage : tous ;
    -- auth.member.manage : ceux de son organisation active
    LET $rights = fn::auth_subject_permissions({ identity: $actor.identity, organization: $actor.organization });
    LET $held = IF $rights.code IS NONE { $rights.permissions } ELSE { [] };
    LET $installation_admin = "auth.identity.manage" IN $held;
    LET $organization_admin = $actor.organization IS NOT NONE AND "auth.member.manage" IN $held;
    LET $targets = IF $p.app_password IS NOT NONE {
        (SELECT id, identity, organization, revoked_at FROM auth_app_password WHERE id = $p.app_password)
    } ELSE {
        (SELECT id, identity, organization, revoked_at FROM auth_app_password
            WHERE identity = $p.identity AND revoked_at IS NONE AND ($p.organization IS NONE OR organization = $p.organization))
    };
    LET $permitted = array::filter($targets, |$t| $t.identity = $actor.identity OR $installation_admin
        OR ($organization_admin AND $t.organization = $actor.organization));
    IF $p.app_password IS NOT NONE AND array::len($permitted) = 0 { RETURN fn::error_result("AUTH_APP_PASSWORD_NOT_FOUND", $p.language, {}); };
    LET $owner = IF $p.app_password IS NOT NONE { $permitted[0].identity = $actor.identity } ELSE { $p.identity = $actor.identity };
    IF !$owner AND !$installation_admin AND !$organization_admin {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.identity.manage" });
    };
    -- Révoquer ses propres mots de passe retire des droits : pas une action sensible. Révoquer
    -- ceux d'un autre (administrateur) en est une.
    IF !$owner {
        LET $assurance = fn::auth_assurance_state({ session: $p.session, min_aal: "highest_available", fresh: true });
        IF $assurance.code IS NOT NONE { RETURN fn::error_result($assurance.code, $p.language, $assurance.details); };
    };
    LET $revoked = (UPDATE auth_app_password
        SET revoked_at = time::now(), revoked_reason = IF $owner { "owner" } ELSE { "admin" }, revoked_by = $actor.identity
        WHERE id IN $permitted.id AND revoked_at IS NONE RETURN id);
    IF $p.app_password IS NOT NONE AND $permitted[0].revoked_at IS NONE AND array::len($revoked) = 0 {
        RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_app_password" });
    };
    RETURN fn::result_ok({ revoked: array::len($revoked) });
} COMMENT "Révoque un mot de passe d'application ({ session : acteur, app_password }) ou tous ceux d'une identité ({ session, identity, organization }) : le titulaire (motif owner) ; un administrateur (auth.identity.manage, ou auth.member.manage pour ceux de son organisation active ; motif admin, action sensible) ; sessions du mot de passe révoquées, événement auth.app_password.revoked ; { revoked }. Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_app_password_eligible : permissions que l'appelant peut donner
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_app_password_eligible($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
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
    LET $s = IF $check.system { NONE } ELSE { (SELECT identity, organization FROM ONLY $auth) };
    IF $s == NONE OR $s.identity IS NONE { RETURN fn::error_result("AUTH_SESSION_REQUIRED", $p.language, {}); };
    IF $s.organization IS NONE { RETURN fn::error_result("AUTH_APP_PASSWORD_ORGANIZATION_REQUIRED", $p.language, {}); };
    IF !fn::auth_policy_value({ theme: "app_password", key: "enabled", default: true, organization: $s.organization }) {
        RETURN fn::error_result("AUTH_APP_PASSWORD_DISABLED", $p.language, {});
    };
    LET $held = IF type::is_array($token.permissions) { $token.permissions } ELSE { [] };
    LET $allowed = fn::auth_app_password_allowed({});
    RETURN fn::result_ok(SELECT code, module, description FROM auth_permission
        WHERE code IN $allowed AND code IN $held ORDER BY code);
} COMMENT "Permissions que l'appelant peut donner à un mot de passe d'application ({}) : détenues dans son organisation active et déclarées utilisables ; { code, module, description }, triées par code";

-- ----------------------------------------------------------------------------
-- fn::auth_app_password_failure_record : échec compté
-- ----------------------------------------------------------------------------
-- Par adresse IP : verrouillage au seuil (mots de passe d'application seulement, A8). Par
-- identifiant : compté, jamais verrouillé ; événement au seuil, une fois par fenêtre. Appelée
-- par fn::auth_app_password_verify, et par l'hôte pour une saisie au mauvais format (refusée
-- sans recherche de l'empreinte).

DEFINE FUNCTION OVERWRITE fn::auth_app_password_failure_record($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            ip_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            identifier_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, { fields: {
        ip_hash: { pipeline: [{ rule: "lowercase" }] },
        identifier_hash: { pipeline: [{ rule: "lowercase" }] }
    }, unknown_keys: "keep" }, 20);
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $window = duration::from_secs(fn::auth_policy_value({ theme: "lockout", key: "window_seconds", default: 900 }));
    LET $lock = duration::from_secs(fn::auth_policy_value({ theme: "lockout", key: "lock_seconds", default: 900 }));
    LET $policy = (fn::auth_policy_get({}).data ?? {}).app_password ?? {};
    LET $ip = fn::auth_login_failure_count({ kind: "app_password_ip", hash: $p.ip_hash, window: $window, lock: $lock, limit: $policy.ip_max_failures ?? 20 });
    LET $identifier = fn::auth_login_failure_count({ kind: "app_password_identifier", hash: $p.identifier_hash, window: $window, lock: $lock, limit: NONE });
    IF $ip.newly_locked {
        LET $locked = fn::event_publish({
            event_id: rand::uuid::v7(),
            event_type: "auth.app_password.ip_locked",
            producer: "lyxal_auth",
            payload: { ip_hash: $p.ip_hash, until: $ip.locked_until },
            metadata: {}
        });
        IF !$locked.ok { THROW $locked.error.code; };
    };
    IF $identifier.failures = ($policy.identifier_alert_failures ?? 50) {
        LET $failed = fn::event_publish({
            event_id: rand::uuid::v7(),
            event_type: "auth.app_password.failed",
            producer: "lyxal_auth",
            payload: {
                identifier_hash: $p.identifier_hash,
                identity_id: IF $p.identity IS NONE { NONE } ELSE { <string> $p.identity },
                failures: $identifier.failures
            },
            metadata: {}
        });
        IF !$failed.ok { THROW $failed.error.code; };
    };
    RETURN fn::result_ok(fn::auth_login_failure_status({ ip_hash: $p.ip_hash, ip_kind: "app_password_ip" }));
} COMMENT "Compte l'échec d'un mot de passe d'application ({ ip_hash, identifier_hash, identity }) : adresse IP verrouillée au seuil app_password.ip_max_failures (événement auth.app_password.ip_locked), identifiant compté sans verrouillage (événement auth.app_password.failed au seuil identifier_alert_failures) ; { locked, until } de l'adresse IP. Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_app_password_log : journal regroupé (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_app_password_log($params: object) -> object {
    IF !fn::auth_session_valid({}).system { RETURN { code: "AUTH_PERMISSION_DENIED" }; };
    LET $now = time::now();
    LET $app = (SELECT identity, organization FROM ONLY $params.app_password);
    IF $app == NONE { RETURN { code: "AUTH_APP_PASSWORD_NOT_FOUND" }; };
    -- Une ligne par mot de passe, protocole et adresse IP (E1) : créée puis mise à jour
    UPSERT ONLY type::record("auth_app_password_use", [$params.app_password, $params.protocol, $params.ip]) SET
        app_password = $params.app_password,
        identity = $app.identity,
        organization = $app.organization,
        protocol = $params.protocol,
        ip = $params.ip,
        client_name = $params.client_name ?? client_name,
        last_seen_at = $now,
        count += 1;
    UPDATE $params.app_password SET last_used_at = $now, last_used_protocol = $params.protocol, last_used_ip = $params.ip;
    RETURN { code: NONE };
} COMMENT "Inscrit une connexion vérifiée ({ app_password, protocol, ip, client_name }) : ligne du journal créée ou mise à jour (dernière connexion, nombre, logiciel), dernier usage du mot de passe ; { code }. Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_app_password_session_open : session partagée d'un mot de passe (interne)
-- ----------------------------------------------------------------------------
-- Une session par mot de passe, reprise par ses connexions (A10) : celle désignée
-- (renouvellement), sinon la session active de ce mot de passe s'il lui reste plus de 5 min,
-- sinon une nouvelle. Droits recalculés à chaque fois (A5).

DEFINE FUNCTION OVERWRITE fn::auth_app_password_session_open($params: object) -> object {
    IF !fn::auth_session_valid({}).system { RETURN { code: "AUTH_PERMISSION_DENIED" }; };
    LET $now = time::now();
    LET $app = (SELECT * FROM ONLY $params.app_password);
    -- Révoqué ou expiré : un ancien appareil, refusé sans compter
    IF $app == NONE OR $app.revoked_at IS NOT NONE OR ($app.expires_at IS NOT NONE AND $app.expires_at <= $now) {
        RETURN { code: "AUTH_APP_PASSWORD_INVALID" };
    };
    LET $policy = fn::auth_policy_get({ organization: <string> $app.organization }).data ?? {};
    IF !($policy.app_password.enabled ?? true) { RETURN { code: "AUTH_APP_PASSWORD_DISABLED" }; };
    LET $subject = (SELECT state, not_before FROM ONLY $app.identity);
    IF $subject == NONE OR $subject.state != "active" { RETURN { code: "AUTH_IDENTITY_INACTIVE" }; };
    IF (SELECT VALUE state FROM ONLY $app.organization) != "active" { RETURN { code: "AUTH_ORGANIZATION_INACTIVE" }; };
    -- Permissions du mot de passe ∩ déclarées utilisables ∩ encore détenues
    LET $limit = array::intersect($app.permissions, fn::auth_app_password_allowed({}));
    LET $rights = fn::auth_subject_permissions({ identity: $app.identity, organization: $app.organization, limit: $limit });
    IF $rights.code IS NOT NONE { RETURN { code: $rights.code }; };
    IF array::len($rights.permissions) = 0 { RETURN { code: "AUTH_APP_PASSWORD_NO_PERMISSION" }; };
    LET $current = IF $params.session IS NOT NONE {
        (SELECT * FROM ONLY $params.session)
    } ELSE {
        (SELECT * FROM ONLY auth_session WHERE app_password = $app.id AND state = "active" AND expires_at > $now + 5m ORDER BY expires_at DESC LIMIT 1)
    };
    IF $params.session IS NOT NONE {
        IF $current == NONE OR $current.app_password != $app.id OR $current.state = "revoked" { RETURN { code: "AUTH_SESSION_REVOKED" }; };
        IF $current.state != "active" OR $current.expires_at <= $now { RETURN { code: "AUTH_SESSION_EXPIRED" }; };
    };
    -- Session antérieure au not_before de l'identité : jamais reprise
    LET $reusable = $current != NONE AND ($subject.not_before IS NONE OR $current.created_at >= $subject.not_before);
    IF $params.session IS NOT NONE AND !$reusable { RETURN { code: "AUTH_SESSION_REVOKED" }; };
    IF $reusable {
        UPDATE $current.id SET last_seen_at = $now, access_slot = $params.access_slot, permissions_version = $rights.version;
        RETURN {
            code: NONE,
            session: $current.id,
            identity: $app.identity,
            application: NONE,
            organization: $app.organization,
            kind: "app_password",
            permissions: $rights.permissions,
            version: $rights.version,
            aal: 1,
            access_seconds: $policy.session.access_seconds ?? 900,
            idle_expires_at: $current.idle_expires_at,
            expires_at: $current.expires_at,
            refresh_expires_at: NONE,
            app_password: $app.id
        };
    };
    LET $opened = fn::auth_session_open({
        identity: $app.identity, app_password: $app.id, kind: "app_password", organization: $app.organization,
        amr: ["app_password"], client: $params.client ?? {}, access_slot: $params.access_slot, limit: $limit
    });
    IF $opened.code IS NOT NONE { RETURN { code: $opened.code }; };
    RETURN object::extend($opened, { app_password: $app.id });
} COMMENT "Session app_password d'un mot de passe ({ app_password, session : à renouveler, client, access_slot }) : mot de passe valide, politique, identité et organisation actives, droits recalculés (permissions du mot de passe déclarées utilisables et encore détenues, sinon AUTH_APP_PASSWORD_NO_PERMISSION) ; session désignée, session active reprise s'il lui reste plus de 5 min, ou nouvelle ; ce que porte le jeton d'accès et app_password. Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_app_password_verify : connexion d'un logiciel par l'hôte des protocoles
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_app_password_verify($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            password_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            identifier: { pipeline: [{ rule: "email", options: { max_length: 254 } }], required: true },
            protocol: { pipeline: [{ rule: "enum", options: { allowed: ["smtp", "imap", "pop3", "managesieve", "dav", "jmap"], case_sensitive: true } }], required: true },
            client: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: { fields: {
                ip: { pipeline: [{ rule: "ip" }], required: true },
                user_agent: { pipeline: [{ rule: "optional_string", options: { max_length: 512 } }] }
            }, unknown_keys: "reject" } } }], required: true },
            client_name: { pipeline: [{ rule: "optional_string", options: { max_length: 128 } }] },
            ip_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            identifier_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            access_slot: { pipeline: [{ rule: "enum", options: { allowed: ["a", "b"], case_sensitive: true } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, { fields: {
        password_hash: { pipeline: [{ rule: "lowercase" }] },
        ip_hash: { pipeline: [{ rule: "lowercase" }] },
        identifier_hash: { pipeline: [{ rule: "lowercase" }] }
    }, unknown_keys: "keep" }, 20);
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    -- Adresse IP bloquée pour les mots de passe d'application : refus sans compter
    IF fn::auth_login_failure_status({ ip_hash: $p.ip_hash, ip_kind: "app_password_ip" }).locked {
        RETURN fn::error_result("AUTH_TOO_MANY_ATTEMPTS", $p.language, {});
    };
    LET $app = (SELECT id, identity FROM ONLY auth_app_password WHERE password_hash = $p.password_hash LIMIT 1);
    LET $email = fn::sanitize_pipeline_execute($p.identifier, [{ rule: "email" }], 5);
    LET $identity = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE type = "email" AND value = $email LIMIT 1);
    -- Mot de passe inconnu, ou présenté avec l'identifiant d'une autre identité (pas d'emprunt
    -- d'identité) : échec compté
    IF $app == NONE OR $identity IS NONE OR $app.identity != $identity {
        LET $status = fn::auth_app_password_failure_record({ ip_hash: $p.ip_hash, identifier_hash: $p.identifier_hash, identity: IF $identity IS NONE { NONE } ELSE { <string> $identity } });
        IF !$status.ok { RETURN $status; };
        RETURN fn::error_result(IF $status.data.locked { "AUTH_TOO_MANY_ATTEMPTS" } ELSE { "AUTH_APP_PASSWORD_INVALID" }, $p.language, {});
    };
    LET $issued = fn::auth_app_password_session_open({ app_password: $app.id, client: $p.client, access_slot: $p.access_slot });
    IF $issued.code IS NOT NONE { RETURN fn::error_result($issued.code, $p.language, {}); };
    LET $logged = fn::auth_app_password_log({ app_password: $app.id, protocol: $p.protocol, ip: $p.client.ip, client_name: $p.client_name });
    IF $logged.code IS NOT NONE { RETURN fn::error_result($logged.code, $p.language, {}); };
    RETURN fn::result_ok(object::remove($issued, "code"));
} COMMENT "Vérifie un mot de passe d'application présenté par un logiciel ({ password_hash, identifier : adresse e-mail de connexion, protocol, client { ip, user_agent }, client_name, ip_hash, identifier_hash, access_slot }) : adresse IP bloquée refusée ; mot de passe inconnu ou d'une autre identité compté (AUTH_APP_PASSWORD_INVALID, puis AUTH_TOO_MANY_ATTEMPTS) ; révoqué ou expiré refusé sans compter ; session app_password partagée, journal regroupé ; ce que porte le jeton d'accès et app_password. Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_app_password_session_renew : nouveau jeton pour une connexion longue
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_app_password_session_renew($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            session: { pipeline: [{ rule: "record", options: { expected_table: "auth_session" } }], required: true },
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
    LET $s = (SELECT kind, app_password FROM ONLY $p.session);
    IF $s == NONE OR $s.kind != "app_password" OR $s.app_password IS NONE { RETURN fn::error_result("AUTH_SESSION_REVOKED", $p.language, {}); };
    LET $issued = fn::auth_app_password_session_open({ app_password: $s.app_password, session: $p.session, access_slot: $p.access_slot });
    IF $issued.code IS NOT NONE { RETURN fn::error_result($issued.code, $p.language, {}); };
    RETURN fn::result_ok(object::remove($issued, "code"));
} COMMENT "Réémet ce que porte le jeton d'accès d'une session app_password ({ session, access_slot }) sans redemander le mot de passe : session et mot de passe valides, droits recalculés ; session expirée → AUTH_SESSION_EXPIRED (le logiciel se reconnecte). Session système";
