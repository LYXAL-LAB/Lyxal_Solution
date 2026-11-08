-- ============================================================================
-- FONCTIONS : anti-force-brute
-- MODULE    : lyxal_auth
-- ============================================================================
-- Modèle : Keycloak `LOGIN_FAILURE`. Échecs comptés par identifiant (même inconnu : pas
-- d'énumération) et par adresse IP, sur une fenêtre glissante ; au seuil, verrouillage
-- temporaire. Clés en BLAKE3 (calculées par l'hôte). Session système.

DEFINE FUNCTION OVERWRITE fn::auth_login_failure_status($params: object) -> object {
    LET $now = time::now();
    LET $rows = (SELECT kind, locked_until FROM auth_login_failure
        WHERE (kind = "identifier" AND key_hash = $params.identifier_hash) OR (kind = "ip" AND $params.ip_hash IS NOT NONE AND key_hash = $params.ip_hash));
    LET $locked = array::filter($rows, |$r| $r.locked_until IS NOT NONE AND $r.locked_until > $now);
    RETURN { locked: array::len($locked) > 0, until: IF array::len($locked) = 0 { NONE } ELSE { array::max($locked.locked_until) } };
} COMMENT "État de verrouillage ({ identifier_hash, ip_hash }) : { locked, until }";

DEFINE FUNCTION OVERWRITE fn::auth_login_failure_check($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identifier_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            ip_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }] },
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    RETURN fn::result_ok(fn::auth_login_failure_status({ identifier_hash: $p.identifier_hash, ip_hash: $p.ip_hash }));
} COMMENT "Indique si un identifiant ou une adresse IP ({ identifier_hash, ip_hash, identity ignorée }) est verrouillé : { locked, until }. Session système";

DEFINE FUNCTION OVERWRITE fn::auth_login_failure_record($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identifier_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            ip_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }] },
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }] },
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
    LET $window = duration::from_secs(fn::auth_policy_value({ theme: "lockout", key: "window_seconds", default: 900 }));
    LET $lock = duration::from_secs(fn::auth_policy_value({ theme: "lockout", key: "lock_seconds", default: 900 }));
    LET $limits = {
        identifier: fn::auth_policy_value({ theme: "lockout", key: "max_failures", default: 10 }),
        ip: fn::auth_policy_value({ theme: "lockout", key: "ip_max_failures", default: 50 })
    };
    LET $keys = array::filter([["identifier", $p.identifier_hash], ["ip", $p.ip_hash]], |$k| $k[1] IS NOT NONE);
    LET $results = array::map($keys, |$k| {
        LET $kind = $k[0];
        LET $hash = string::lowercase($k[1]);
        LET $row = (SELECT * FROM ONLY auth_login_failure WHERE kind = $kind AND key_hash = $hash LIMIT 1);
        -- Fenêtre écoulée : le compteur repart de zéro
        LET $fresh = $row == NONE OR $row.window_start + $window <= $now;
        LET $failures = IF $fresh { 1 } ELSE { $row.failures + 1 };
        LET $locked_until = IF $failures >= $limits[$kind] { $now + $lock } ELSE { $row.locked_until };
        IF $row == NONE {
            CREATE auth_login_failure CONTENT { kind: $kind, key_hash: $hash, failures: $failures, window_start: $now, locked_until: $locked_until };
        } ELSE {
            UPDATE $row.id SET failures = $failures, window_start = IF $fresh { $now } ELSE { window_start }, locked_until = $locked_until;
        };
        RETURN { kind: $kind, failures: $failures, newly_locked: $failures = $limits[$kind] };
    });
    LET $identifier_locked = array::any($results, |$r| $r.kind = "identifier" AND $r.newly_locked);
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "auth.login.failed",
        producer: "lyxal_auth",
        payload: { identifier_hash: string::lowercase($p.identifier_hash), identity_id: IF $p.identity IS NONE { NONE } ELSE { <string> $p.identity }, locked: $identifier_locked },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
    IF $identifier_locked AND $p.identity IS NOT NONE {
        LET $locked_event = fn::event_publish({
            event_id: rand::uuid::v7(),
            event_type: "auth.identity.locked",
            producer: "lyxal_auth",
            source: $p.identity,
            payload: { identity_id: <string> $p.identity, until: $now + $lock },
            metadata: {}
        });
        IF !$locked_event.ok { THROW $locked_event.error.code; };
    };
    RETURN fn::result_ok(fn::auth_login_failure_status({ identifier_hash: string::lowercase($p.identifier_hash), ip_hash: IF $p.ip_hash IS NONE { NONE } ELSE { string::lowercase($p.ip_hash) } }));
} COMMENT "Compte un échec de connexion ({ identifier_hash, ip_hash, identity }) : fenêtre glissante, verrouillage au seuil de la politique, événements auth.login.failed et auth.identity.locked ; { locked, until }. Session système";

DEFINE FUNCTION OVERWRITE fn::auth_login_failure_reset($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identifier_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    DELETE auth_login_failure WHERE kind = "identifier" AND key_hash = string::lowercase($p.identifier_hash);
    RETURN fn::result_ok({ reset: true });
} COMMENT "Remet à zéro le compteur d'un identifiant après une connexion réussie ({ identifier_hash }). Session système";
