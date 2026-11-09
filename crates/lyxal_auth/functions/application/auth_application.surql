-- ============================================================================
-- FONCTIONS : applications, comptes de service, clés d'API
-- MODULE    : lyxal_auth
-- ============================================================================
-- Modèle : Logto (applications, secrets, jetons personnels), Rauthy (clients, clés d'API).
-- Secrets et clés générés en Rust (OsRng), montrés une seule fois, conservés en empreinte.

-- ----------------------------------------------------------------------------
-- fn::auth_application_can : l'appelant gère-t-il les applications de cette portée ?
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_application_can($params: object) -> bool {
    RETURN fn::auth_has_permission({ permission: "auth.application.manage" })
        OR ($params.tenant IS NOT NONE AND fn::auth_has_permission({ permission: "auth.organization.application.manage", tenant: $params.tenant }));
} COMMENT "Vrai si l'appelant gère les applications de la portée ({ tenant : organisation ou NONE })";

-- ----------------------------------------------------------------------------
-- fn::auth_application_create / _update / _list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_application_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            type: { pipeline: [{ rule: "enum", options: { allowed: ["spa", "native", "machine"], case_sensitive: true } }], required: true },
            redirect_uris: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "each", options: { pipeline: [{ rule: "url" }] } }], default: [] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_application_can({ tenant: $p.tenant }) { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.application.manage" }); };
    LET $created = (CREATE ONLY type::record("auth_application", string::replace(<string> rand::uuid::v7(), "-", "")) CONTENT {
        tenant: $p.tenant,
        client_id: string::concat("lyx_", string::replace(<string> rand::uuid::v4(), "-", "")),
        name: $p.name,
        type: $p.type,
        redirect_uris: $p.redirect_uris
    });
    IF $created == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_application" }); };
    RETURN fn::result_ok($created);
} COMMENT "Crée une application ({ tenant, name, type : spa, native, machine ; redirect_uris }) avec un client_id public aléatoire. Permission auth.application.manage ou auth.organization.application.manage";

DEFINE FUNCTION OVERWRITE fn::auth_application_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            application: { pipeline: [{ rule: "record", options: { expected_table: "auth_application" } }], required: true },
            name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }] },
            redirect_uris: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "each", options: { pipeline: [{ rule: "url" }] } }] },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["active", "disabled"], case_sensitive: true } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $application = (SELECT * FROM ONLY $p.application);
    IF $application == NONE { RETURN fn::error_result("AUTH_APPLICATION_NOT_FOUND", $p.language, {}); };
    IF !fn::auth_application_can({ tenant: $application.tenant }) { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.application.manage" }); };
    LET $disabling = $p.state = "disabled" AND $application.state != "disabled";
    LET $updated = (UPDATE ONLY $application.id SET
        name = $p.name ?? name,
        redirect_uris = $p.redirect_uris ?? redirect_uris,
        state = $p.state ?? state,
        not_before = IF $disabling { time::now() } ELSE { not_before });
    IF $updated == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_application" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Modifie une application ({ application, name, redirect_uris, state }) ; désactivée : ses sessions sont refusées dès l'opération suivante. Permission de gestion des applications";

DEFINE FUNCTION OVERWRITE fn::auth_application_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_application_can({ tenant: $p.tenant }) { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.application.manage" }); };
    RETURN fn::result_ok(SELECT *, (SELECT id, prefix, expires_at, revoked_at, created_at FROM auth_application_secret WHERE application = $parent.id) AS secrets
        FROM auth_application WHERE ($p.tenant IS NONE AND tenant IS NONE) OR tenant = $p.tenant ORDER BY name LIMIT $p.limit);
} COMMENT "Applications d'une portée ({ tenant, limit }) avec leurs secrets (préfixe seulement). Permission de gestion des applications";

-- ----------------------------------------------------------------------------
-- fn::auth_application_secret_add / _revoke
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_application_secret_add($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            application: { pipeline: [{ rule: "record", options: { expected_table: "auth_application" } }], required: true },
            secret_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            prefix: { pipeline: [{ rule: "required_string", options: { min_length: 8, max_length: 8 } }], required: true },
            expires_at: { pipeline: [{ rule: "future_datetime", options: { allow_equal: false } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $application = (SELECT id, tenant, type FROM ONLY $p.application);
    IF $application == NONE { RETURN fn::error_result("AUTH_APPLICATION_NOT_FOUND", $p.language, {}); };
    IF !fn::auth_application_can({ tenant: $application.tenant }) { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.application.manage" }); };
    IF $application.type != "machine" { RETURN fn::error_result("AUTH_INVALID_PARAMETERS", $p.language, { fields: { application: ["machine application required"] } }); };
    LET $created = (CREATE ONLY auth_application_secret CONTENT { application: $application.id, secret_hash: string::lowercase($p.secret_hash), prefix: $p.prefix, expires_at: $p.expires_at });
    IF $created == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_application_secret" }); };
    RETURN fn::result_ok({ id: $created.id, prefix: $created.prefix, expires_at: $created.expires_at });
} COMMENT "Ajoute un secret client à une application machine ({ application, secret_hash, prefix, expires_at }) ; plusieurs secrets permettent une rotation sans coupure. Permission de gestion des applications";

DEFINE FUNCTION OVERWRITE fn::auth_application_secret_revoke($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            secret: { pipeline: [{ rule: "record", options: { expected_table: "auth_application_secret" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $secret = (SELECT id, application, application.tenant AS tenant FROM ONLY $p.secret);
    IF $secret == NONE { RETURN fn::error_result("AUTH_APPLICATION_NOT_FOUND", $p.language, {}); };
    IF !fn::auth_application_can({ tenant: $secret.tenant }) { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.application.manage" }); };
    LET $revoked = (UPDATE ONLY $secret.id SET revoked_at = time::now() WHERE revoked_at IS NONE);
    RETURN fn::result_ok({ secret: $secret.id, revoked: $revoked IS NOT NONE });
} COMMENT "Révoque un secret client ({ secret }). Permission de gestion des applications";

-- ----------------------------------------------------------------------------
-- fn::auth_application_permissions : permissions effectives d'une application
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_application_permissions($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            application: { pipeline: [{ rule: "record", options: { expected_table: "auth_application" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $application = (SELECT id, tenant, permissions_version FROM ONLY $p.application);
    IF $application == NONE { RETURN fn::error_result("AUTH_APPLICATION_NOT_FOUND", $p.language, {}); };
    IF !fn::auth_session_valid({}).system AND !fn::auth_application_can({ tenant: $application.tenant }) {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.application.manage" });
    };
    LET $roles = (SELECT VALUE out FROM auth_has_role WHERE in = $application.id);
    LET $expanded = array::distinct(array::flatten(array::map($roles, |$r| array::flatten([$r, $r.{..8+collect}(->auth_role_includes->auth_role)]))));
    RETURN fn::result_ok({
        application: $application.id,
        organization: $application.tenant,
        permissions: array::sort(array::distinct(SELECT VALUE out.code FROM auth_role_grants WHERE in IN $expanded)),
        version: $application.permissions_version
    });
} COMMENT "Permissions effectives d'une application ({ application }) : rôles reçus et rôles inclus ; version des droits. Session système ou gestion des applications";

-- ----------------------------------------------------------------------------
-- fn::auth_service_session_create : compte de service (client_credentials)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_service_session_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            client_id: { pipeline: [{ rule: "required_string", options: { min_length: 16, max_length: 64 } }], required: true },
            secret_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            client: { pipeline: [{ rule: "is_object" }], default: {} },
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
    LET $application = (SELECT id, tenant, type, state FROM ONLY auth_application WHERE client_id = $p.client_id LIMIT 1);
    LET $secret = (SELECT id, application, expires_at, revoked_at FROM ONLY auth_application_secret WHERE secret_hash = string::lowercase($p.secret_hash) LIMIT 1);
    -- Une seule erreur pour client inconnu, secret faux, révoqué ou expiré
    IF $application == NONE OR $application.type != "machine" OR $secret == NONE OR $secret.application != $application.id
        OR $secret.revoked_at IS NOT NONE OR ($secret.expires_at IS NOT NONE AND $secret.expires_at <= $now) {
        RETURN fn::error_result("AUTH_CLIENT_CREDENTIALS_INVALID", $p.language, {});
    };
    LET $opened = fn::auth_session_open({
        application: $application.id, kind: "service", organization: $application.tenant, amr: ["client_secret"],
        client: $p.client, access_slot: $p.access_slot
    });
    IF $opened.code IS NOT NONE { RETURN fn::error_result($opened.code, $p.language, {}); };
    RETURN fn::result_ok(object::remove($opened, "code"));
} COMMENT "Ouvre la session d'un compte de service ({ client_id, secret_hash, client, access_slot }) : application machine active et secret valide ; sans jeton de renouvellement. Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_api_key_create / _list / _revoke / fn::auth_api_key_session_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_api_key_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            key_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            prefix: { pipeline: [{ rule: "required_string", options: { min_length: 8, max_length: 8 } }], required: true },
            permissions: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: false } }], required: true },
            expires_at: { pipeline: [{ rule: "future_datetime", options: { allow_equal: false } }] },
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
    LET $sess = IF $check.system { NONE } ELSE { (SELECT identity, organization, kind FROM ONLY $auth) };
    IF $sess == NONE OR $sess.identity IS NONE OR $sess.kind != "interactive" { RETURN fn::error_result("AUTH_SESSION_REQUIRED", $p.language, {}); };
    IF !fn::auth_has_permission({ permission: "auth.self.manage" }) { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.self.manage" }); };
    -- Action sensible : AAL la plus haute disponible et authentification récente
    LET $assurance = fn::auth_assurance_state({ session: $auth, min_aal: "highest_available", fresh: true });
    IF $assurance.code IS NOT NONE { RETURN fn::error_result($assurance.code, $p.language, $assurance.details); };
    -- Une clé ne peut porter que des permissions que son propriétaire détient
    LET $held = IF type::is_array($token.permissions) { $token.permissions } ELSE { [] };
    LET $excess = array::filter($p.permissions, |$code| $code NOT IN $held);
    IF array::len($excess) > 0 { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permissions: $excess }); };
    LET $created = (CREATE ONLY auth_api_key CONTENT {
        identity: $sess.identity, name: $p.name, key_hash: string::lowercase($p.key_hash), prefix: $p.prefix,
        permissions: array::sort(array::distinct($p.permissions)), organization: $sess.organization, expires_at: $p.expires_at
    });
    IF $created == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_api_key" }); };
    RETURN fn::result_ok({ id: $created.id, name: $created.name, prefix: $created.prefix, permissions: $created.permissions, organization: $created.organization, expires_at: $created.expires_at });
} COMMENT "Crée une clé d'API personnelle pour l'identité connectée ({ name, key_hash, prefix, permissions, expires_at }) : permissions incluses dans celles de la session, organisation de la session. Permission auth.self.manage";

DEFINE FUNCTION OVERWRITE fn::auth_api_key_list($params: object) {
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
    RETURN fn::result_ok(SELECT id, name, prefix, permissions, organization, expires_at, last_used_at, revoked_at, created_at
        FROM auth_api_key WHERE identity = $identity ORDER BY created_at DESC);
} COMMENT "Clés d'API visibles d'une identité ({ identity } ; par défaut celle de la session), sans empreinte";

DEFINE FUNCTION OVERWRITE fn::auth_api_key_revoke($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            api_key: { pipeline: [{ rule: "record", options: { expected_table: "auth_api_key" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $key = (SELECT id, revoked_at FROM ONLY $p.api_key);
    IF $key == NONE { RETURN fn::error_result("AUTH_API_KEY_INVALID", $p.language, {}); };
    LET $revoked = (UPDATE ONLY $key.id SET revoked_at = time::now() WHERE revoked_at IS NONE);
    IF $revoked == NONE AND $key.revoked_at IS NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_api_key" }); };
    RETURN fn::result_ok({ api_key: $key.id, revoked: $revoked IS NOT NONE });
} COMMENT "Révoque une clé d'API ({ api_key }) : son propriétaire ou auth.identity.manage ; ses sessions sont refusées dès l'opération suivante";

DEFINE FUNCTION OVERWRITE fn::auth_api_key_session_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            key_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            client: { pipeline: [{ rule: "is_object" }], default: {} },
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
    LET $key = (SELECT * FROM ONLY auth_api_key WHERE key_hash = string::lowercase($p.key_hash) LIMIT 1);
    IF $key == NONE OR $key.revoked_at IS NOT NONE { RETURN fn::error_result("AUTH_API_KEY_INVALID", $p.language, {}); };
    IF $key.expires_at IS NOT NONE AND $key.expires_at <= $now { RETURN fn::error_result("AUTH_API_KEY_EXPIRED", $p.language, {}); };
    -- Permissions : celles de la clé, limitées à celles que le propriétaire détient encore
    LET $opened = fn::auth_session_open({
        identity: $key.identity, api_key: $key.id, kind: "api_key", organization: $key.organization, amr: ["api_key"],
        client: $p.client, access_slot: $p.access_slot, limit: $key.permissions
    });
    IF $opened.code IS NOT NONE { RETURN fn::error_result($opened.code, $p.language, {}); };
    UPDATE $key.id SET last_used_at = $now;
    RETURN fn::result_ok(object::remove($opened, "code"));
} COMMENT "Échange une clé d'API ({ key_hash, client, access_slot }) contre une session api_key : permissions de la clé limitées à celles que le propriétaire détient encore ; sans jeton de renouvellement. Session système";
