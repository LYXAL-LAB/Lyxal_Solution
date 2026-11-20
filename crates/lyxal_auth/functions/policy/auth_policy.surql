-- ============================================================================
-- FONCTIONS : politique de sécurité
-- MODULE    : lyxal_auth
-- ============================================================================
-- La politique effective d'une organisation est celle de l'installation, surchargée thème par
-- thème et champ par champ par celle de l'organisation.

DEFINE FUNCTION OVERWRITE fn::auth_policy_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $themes = ["password", "lockout", "session", "mfa", "invitation", "registration", "code", "refresh", "flow", "retention", "app_password"];
    LET $base = (SELECT * FROM ONLY auth_policy WHERE scope_key = "installation" LIMIT 1) ?? {};
    LET $override = IF $p.organization IS NONE { {} } ELSE {
        (SELECT * FROM ONLY auth_policy WHERE scope_key = <string> record::id($p.organization) LIMIT 1) ?? {}
    };
    LET $merged = object::from_entries(array::map($themes, |$t| [
        $t,
        object::extend($base[$t] ?? {}, $override[$t] ?? {})
    ]));
    -- Durées de session et de renouvellement : une organisation les raccourcit, jamais au-delà de
    -- celles de l'installation (défauts : inactivité 30 min, absolue et renouvellement 12 h)
    LET $session_policy = object::extend($merged.session, {
        idle_seconds: math::min([$base.session.idle_seconds ?? 1800, $merged.session.idle_seconds ?? 1800]),
        absolute_seconds: math::min([$base.session.absolute_seconds ?? 43200, $merged.session.absolute_seconds ?? 43200])
    });
    LET $refresh_policy = object::extend($merged.refresh, {
        ttl_seconds: math::min([$base.refresh.ttl_seconds ?? 43200, $merged.refresh.ttl_seconds ?? 43200])
    });
    -- Mots de passe d'application : une organisation ne peut que restreindre (activés seulement si
    -- l'installation et l'organisation les activent, plafonds au plus petit des deux) ; seuils
    -- d'essais et durée du journal : installation seulement
    LET $app_base = $base.app_password ?? {};
    LET $app_org = $override.app_password ?? {};
    LET $app_lifetimes = array::filter([$app_base.max_lifetime_days, $app_org.max_lifetime_days], |$d| $d IS NOT NONE);
    LET $app_password_policy = {
        enabled: ($app_base.enabled ?? true) AND ($app_org.enabled ?? true),
        max_per_identity: math::min([$app_base.max_per_identity ?? 20, $app_org.max_per_identity ?? 20]),
        max_lifetime_days: IF array::len($app_lifetimes) = 0 { NONE } ELSE { math::min($app_lifetimes) },
        session_seconds: math::min([$app_base.session_seconds ?? 43200, $app_org.session_seconds ?? 43200]),
        ip_max_failures: $app_base.ip_max_failures ?? 20,
        identifier_alert_failures: $app_base.identifier_alert_failures ?? 50,
        log_days: $app_base.log_days ?? 90
    };
    RETURN fn::result_ok(object::extend($merged, { session: $session_policy, refresh: $refresh_policy, app_password: $app_password_policy }));
} COMMENT "Politique effective ({ organization }) : installation surchargée par l'organisation, par thème (password, lockout, session, mfa, invitation, registration, code, refresh, flow, retention, app_password) ; durées de session et de renouvellement d'une organisation plafonnées par celles de l'installation ; mots de passe d'application : une organisation ne peut que restreindre (enabled, max_per_identity, max_lifetime_days, session_seconds), seuils d'essais et journal de l'installation, défauts appliqués";

DEFINE FUNCTION OVERWRITE fn::auth_policy_save($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            password: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: { fields: {
                min_length: { pipeline: [{ rule: "integer", options: { min_value: 8, max_value: 128 } }] },
                require_classes: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 4 } }] },
                history: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 24 } }] }
            }, unknown_keys: "reject" } } }] },
            lockout: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: { fields: {
                max_failures: { pipeline: [{ rule: "integer", options: { min_value: 3, max_value: 100 } }] },
                lock_seconds: { pipeline: [{ rule: "integer", options: { min_value: 60, max_value: 86400 } }] },
                window_seconds: { pipeline: [{ rule: "integer", options: { min_value: 60, max_value: 86400 } }] },
                ip_max_failures: { pipeline: [{ rule: "integer", options: { min_value: 10, max_value: 10000 } }] }
            }, unknown_keys: "reject" } } }] },
            session: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: { fields: {
                access_seconds: { pipeline: [{ rule: "integer", options: { min_value: 60, max_value: 3600 } }] },
                idle_seconds: { pipeline: [{ rule: "integer", options: { min_value: 300, max_value: 2592000 } }] },
                absolute_seconds: { pipeline: [{ rule: "integer", options: { min_value: 3600, max_value: 31536000 } }] }
            }, unknown_keys: "reject" } } }] },
            mfa: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: { fields: {
                required: { pipeline: [{ rule: "boolean" }] },
                methods: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: false } }, { rule: "each", options: { pipeline: [{ rule: "enum", options: { allowed: ["totp", "passkey", "recovery_code"], case_sensitive: true } }] } }] },
                required_roles: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }] },
                max_attempts: { pipeline: [{ rule: "integer", options: { min_value: 3, max_value: 10 } }] },
                recovery_code_count: { pipeline: [{ rule: "integer", options: { min_value: 5, max_value: 20 } }] },
                privileged_max_age_seconds: { pipeline: [{ rule: "integer", options: { min_value: 60, max_value: 86400 } }] }
            }, unknown_keys: "reject" } } }] },
            invitation: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: { fields: {
                ttl_seconds: { pipeline: [{ rule: "integer", options: { min_value: 3600, max_value: 2592000 } }] }
            }, unknown_keys: "reject" } } }] },
            registration: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: { fields: {
                mode: { pipeline: [{ rule: "enum", options: { allowed: ["invitation_only"], case_sensitive: true } }] }
            }, unknown_keys: "reject" } } }] },
            code: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: { fields: {
                ttl_seconds: { pipeline: [{ rule: "integer", options: { min_value: 300, max_value: 86400 } }] },
                max_attempts: { pipeline: [{ rule: "integer", options: { min_value: 3, max_value: 10 } }] }
            }, unknown_keys: "reject" } } }] },
            refresh: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: { fields: {
                ttl_seconds: { pipeline: [{ rule: "integer", options: { min_value: 3600, max_value: 31536000 } }] }
            }, unknown_keys: "reject" } } }] },
            flow: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: { fields: {
                ttl_seconds: { pipeline: [{ rule: "integer", options: { min_value: 300, max_value: 3600 } }] }
            }, unknown_keys: "reject" } } }] },
            retention: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: { fields: {
                deleted_days: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 365 } }] }
            }, unknown_keys: "reject" } } }] },
            app_password: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: { fields: {
                enabled: { pipeline: [{ rule: "boolean" }] },
                max_per_identity: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 100 } }] },
                max_lifetime_days: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 3650 } }] },
                session_seconds: { pipeline: [{ rule: "integer", options: { min_value: 900, max_value: 86400 } }] },
                ip_max_failures: { pipeline: [{ rule: "integer", options: { min_value: 5, max_value: 10000 } }] },
                identifier_alert_failures: { pipeline: [{ rule: "integer", options: { min_value: 10, max_value: 10000 } }] },
                log_days: { pipeline: [{ rule: "integer", options: { min_value: 7, max_value: 365 } }] }
            }, unknown_keys: "reject" } } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 120);
    -- La conservation des supprimés vaut pour toute l'installation (la purge est globale), comme les
    -- seuils d'essais des mots de passe d'application (comptés avant de connaître l'organisation)
    -- et la durée de leur journal
    LET $installation_only = IF !$report.valid OR $report.value.organization IS NONE { [] } ELSE {
        array::concat(
            IF $report.value.retention IS NOT NONE { ["retention"] } ELSE { [] },
            IF array::any(["ip_max_failures", "identifier_alert_failures", "log_days"], |$k| ($report.value.app_password ?? {})[$k] IS NOT NONE) { ["app_password"] } ELSE { [] }
        )
    };
    IF !$report.valid OR array::len($installation_only) > 0 {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: IF $report.valid { object::from_entries(array::map($installation_only, |$k| [$k, ["CORE_VALIDATION_COMBINATION"]])) } ELSE { $report.by_field } });
    };
    LET $p = $report.value;
    LET $allowed = IF $p.organization IS NONE {
        fn::auth_has_permission({ permission: "auth.policy.manage" })
    } ELSE {
        fn::auth_has_permission({ permission: "auth.organization.manage" }) OR fn::auth_has_permission({ permission: "auth.organization.policy.manage", tenant: $p.organization })
    };
    IF !$allowed {
        RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: IF $p.organization IS NONE { "auth.policy.manage" } ELSE { "auth.organization.policy.manage" } });
    };
    IF $p.organization IS NOT NONE AND !record::exists($p.organization) {
        RETURN fn::error_result("AUTH_ORGANIZATION_NOT_FOUND", $p.language, {});
    };
    LET $scope_key = IF $p.organization IS NONE { "installation" } ELSE { <string> record::id($p.organization) };
    LET $changes = object::from_entries(array::filter(
        array::map(["password", "lockout", "session", "mfa", "invitation", "registration", "code", "refresh", "flow", "retention", "app_password"], |$t| [$t, $p[$t]]),
        |$e| $e[1] IS NOT NONE
    ));
    LET $existing = (SELECT VALUE id FROM ONLY auth_policy WHERE scope_key = $scope_key LIMIT 1);
    LET $saved = IF $existing IS NONE {
        (CREATE ONLY type::record("auth_policy", $scope_key) CONTENT object::extend($changes, { tenant: $p.organization }))
    } ELSE {
        (UPDATE ONLY $existing MERGE $changes)
    };
    IF $saved == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_policy" }); };
    RETURN fn::result_ok($saved);
} COMMENT "Enregistre la politique de l'installation ou d'une organisation ({ organization, password, lockout, session, mfa, invitation, registration, code, refresh, flow, retention, app_password }) ; seuls les thèmes fournis sont remplacés ; retention et seuils des mots de passe d'application (ip_max_failures, identifier_alert_failures, log_days) : installation seulement. Permission auth.policy.manage ou auth.organization.policy.manage";
