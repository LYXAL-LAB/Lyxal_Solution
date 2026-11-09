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
    LET $themes = ["password", "lockout", "session", "mfa", "invitation", "registration", "code", "refresh", "flow"];
    LET $base = (SELECT * FROM ONLY auth_policy WHERE scope_key = "installation" LIMIT 1) ?? {};
    LET $override = IF $p.organization IS NONE { {} } ELSE {
        (SELECT * FROM ONLY auth_policy WHERE scope_key = <string> record::id($p.organization) LIMIT 1) ?? {}
    };
    RETURN fn::result_ok(object::from_entries(array::map($themes, |$t| [
        $t,
        object::extend($base[$t] ?? {}, $override[$t] ?? {})
    ])));
} COMMENT "Politique effective ({ organization }) : installation surchargée par l'organisation, par thème (password, lockout, session, mfa, invitation, registration, code, refresh, flow)";

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
                privileged_max_age_seconds: { pipeline: [{ rule: "integer", options: { min_value: 60, max_value: 86400 } }] },
                passkey_user_verification: { pipeline: [{ rule: "enum", options: { allowed: ["required", "preferred"], case_sensitive: true } }] }
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
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 120);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
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
        array::map(["password", "lockout", "session", "mfa", "invitation", "registration", "code", "refresh", "flow"], |$t| [$t, $p[$t]]),
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
} COMMENT "Enregistre la politique de l'installation ou d'une organisation ({ organization, password, lockout, session, mfa, invitation, registration, code, refresh, flow }) ; seuls les thèmes fournis sont remplacés. Permission auth.policy.manage ou auth.organization.policy.manage";
