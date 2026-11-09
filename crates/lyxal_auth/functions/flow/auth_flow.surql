-- ============================================================================
-- FONCTIONS : parcours persistés et codes à usage unique
-- MODULE    : lyxal_auth
-- ============================================================================
-- Modèle : Kratos (parcours, codes en HMAC). Les codes, jetons et secrets sont produits en Rust ;
-- la base reçoit leurs empreintes et porte les règles (états, expiration, tentatives, usage
-- unique). Session système de l'hôte seulement.

-- ----------------------------------------------------------------------------
-- fn::auth_policy_value : valeur d'un réglage de la politique effective, avec défaut
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_policy_value($params: object) -> any {
    LET $policy = fn::auth_policy_get({ organization: IF $params.organization IS NONE { NONE } ELSE { <string> $params.organization } }).data ?? {};
    RETURN $policy[$params.theme][$params.key] ?? $params.default;
} COMMENT "Réglage de la politique effective ({ theme, key, default, organization }) ; défaut si absent";

-- ----------------------------------------------------------------------------
-- fn::auth_flow_states : états admis par type de parcours
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_flow_states($params: object) -> array {
    LET $allowed = {
        login: ["started", "action_required", "mfa_required", "completed", "failed"],
        registration: ["started", "completed", "failed"],
        verification: ["code_sent", "completed", "failed"],
        recovery: ["code_sent", "code_verified", "completed", "failed"],
        address_change: ["code_sent", "code_verified", "completed", "failed"],
        passkey_login: ["started", "completed", "failed"],
        mfa_enrollment: ["started", "completed", "failed"],
        reauthentication: ["started", "completed", "failed"]
    };
    RETURN $allowed[$params.type] ?? [];
} COMMENT "États admis d'un type de parcours ({ type })";

-- ----------------------------------------------------------------------------
-- fn::auth_flow_start
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_flow_start($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            type: { pipeline: [{ rule: "enum", options: { allowed: ["login", "registration", "verification", "recovery", "address_change", "passkey_login", "mfa_enrollment", "reauthentication"], case_sensitive: true } }], required: true },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["started", "action_required", "mfa_required", "code_sent"], case_sensitive: true } }] },
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }] },
            organization: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            invitation: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization_invitation" } }] },
            address: { pipeline: [{ rule: "email", options: { max_length: 254 } }] },
            required_actions: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "each", options: { pipeline: [{ rule: "enum", options: { allowed: ["verify_email", "update_password", "accept_terms", "configure_mfa"], case_sensitive: true } }] } }], default: [] },
            methods: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "each", options: { pipeline: [{ rule: "enum", options: { allowed: ["password", "totp", "passkey", "recovery_code"], case_sensitive: true } }] } }], default: [] },
            session: { pipeline: [{ rule: "record", options: { expected_table: "auth_session" } }] },
            client: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: { fields: {
                ip: { pipeline: [{ rule: "ip" }] },
                user_agent: { pipeline: [{ rule: "optional_string", options: { max_length: 512 } }] }
            }, unknown_keys: "reject" } } }], default: {} },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    -- Parcours ouverts sans authentification (récupération, connexion par passkey) : au plus 30
    -- par minute pour une même adresse IP (contre le remplissage de la base)
    IF $p.type IN ["recovery", "passkey_login"] AND $p.client.ip IS NOT NONE
        AND count(SELECT id FROM auth_flow WHERE client.ip = $p.client.ip AND type IN ["recovery", "passkey_login"] AND created_at > time::now() - 1m) >= 30 {
        RETURN fn::error_result("AUTH_TOO_MANY_ATTEMPTS", $p.language, { reason: "flow_rate" });
    };
    LET $initial = $p.state ?? (IF $p.type IN ["verification", "recovery", "address_change"] { "code_sent" } ELSE { "started" });
    LET $ttl = fn::auth_policy_value({ theme: "flow", key: "ttl_seconds", default: 900, organization: $p.organization });
    LET $flow = (CREATE ONLY type::record("auth_flow", string::replace(<string> rand::uuid::v7(), "-", "")) CONTENT {
        type: $p.type,
        state: $initial,
        identity: $p.identity,
        organization: $p.organization,
        invitation: $p.invitation,
        address: IF $p.address IS NONE { NONE } ELSE { fn::sanitize_pipeline_execute($p.address, [{ rule: "email" }], 5) },
        required_actions: $p.required_actions,
        methods: $p.methods,
        session: $p.session,
        client: $p.client,
        expires_at: time::now() + duration::from_secs($ttl)
    });
    IF $flow == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_flow" }); };
    RETURN fn::result_ok($flow);
} COMMENT "Démarre un parcours ({ type, state, identity, organization, invitation, address, required_actions, methods, session, client }) ; durée selon la politique. Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_flow_load : parcours utilisable (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_flow_load($params: object) -> object {
    LET $flow = (SELECT * FROM ONLY $params.flow);
    IF $flow == NONE { RETURN { code: "AUTH_FLOW_NOT_FOUND", flow: NONE }; };
    IF $flow.state IN ["completed", "failed"] { RETURN { code: "AUTH_FLOW_INVALID_STATE", flow: NONE }; };
    IF $flow.expires_at <= time::now() { RETURN { code: "AUTH_FLOW_EXPIRED", flow: NONE }; };
    IF $params.type IS NOT NONE AND $flow.type != $params.type { RETURN { code: "AUTH_FLOW_INVALID_STATE", flow: NONE }; };
    IF $params.states IS NOT NONE AND $flow.state NOT IN $params.states { RETURN { code: "AUTH_FLOW_INVALID_STATE", flow: NONE }; };
    RETURN { code: NONE, flow: $flow };
} COMMENT "Parcours utilisable ({ flow, type, states }) : { code, flow } ; inconnu, terminé, expiré ou dans un autre état refusés";

-- ----------------------------------------------------------------------------
-- fn::auth_flow_get / fn::auth_flow_submit
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_flow_get($params: object) {
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
    RETURN fn::result_ok($loaded.flow);
} COMMENT "Parcours en cours ({ flow }) ; inconnu, terminé ou expiré refusé. Session système";

DEFINE FUNCTION OVERWRITE fn::auth_flow_submit($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            flow: { pipeline: [{ rule: "record", options: { expected_table: "auth_flow" } }], required: true },
            from: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: false } }], required: true },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["started", "action_required", "mfa_required", "code_sent", "code_verified", "completed", "failed"], case_sensitive: true } }], required: true },
            methods: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }] },
            required_actions: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }] },
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
    LET $loaded = fn::auth_flow_load({ flow: $p.flow, states: $p.from });
    IF $loaded.code IS NOT NONE { RETURN fn::error_result($loaded.code, $p.language, {}); };
    IF $p.state NOT IN fn::auth_flow_states({ type: $loaded.flow.type }) { RETURN fn::error_result("AUTH_FLOW_INVALID_STATE", $p.language, {}); };
    -- Transition conditionnelle : un parcours soumis deux fois en même temps n'avance qu'une fois
    LET $updated = (UPDATE ONLY $p.flow SET
        state = $p.state,
        required_actions = $p.required_actions ?? required_actions,
        methods = $p.methods ?? methods,
        identity = $p.identity ?? identity
        WHERE state IN $p.from);
    IF $updated == NONE { RETURN fn::error_result("AUTH_FLOW_INVALID_STATE", $p.language, {}); };
    RETURN fn::result_ok($updated);
} COMMENT "Fait avancer un parcours ({ flow, from : états de départ admis, state, required_actions, methods, identity }) ; transition conditionnelle et contrôlée par la machine d'état. Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_code_issue
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_code_issue($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            flow: { pipeline: [{ rule: "record", options: { expected_table: "auth_flow" } }], required: true },
            purpose: { pipeline: [{ rule: "enum", options: { allowed: ["verification", "recovery", "address_change", "setup"], case_sensitive: true } }], required: true },
            address: { pipeline: [{ rule: "email", options: { max_length: 254 } }], required: true },
            code_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }] },
            link_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            event_id: { pipeline: [{ rule: "uuid_v7", options: { allow_string: true } }] },
            secret: { pipeline: [{ rule: "required_string", options: { min_length: 16, max_length: 8192 } }, { rule: "starts_with", options: { prefixes: ["enc:v2:"], case_sensitive: true, trim_value: false } }] },
            locale: { pipeline: [{ rule: "locale", options: { require_region: false } }] },
            name: { pipeline: [{ rule: "optional_string", options: { max_length: 128 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid OR (($report.value.event_id IS NONE) != ($report.value.secret IS NONE)) {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, { fields: { code_hash: { pipeline: [{ rule: "lowercase" }] }, link_hash: { pipeline: [{ rule: "lowercase" }] } }, unknown_keys: "keep" }, 20);
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $loaded = fn::auth_flow_load({ flow: $p.flow });
    IF $loaded.code IS NOT NONE { RETURN fn::error_result($loaded.code, $p.language, {}); };
    LET $organization = $loaded.flow.organization;
    LET $address = fn::sanitize_pipeline_execute($p.address, [{ rule: "email" }], 5);
    -- Plafond d'envoi par adresse et par usage (contre la force brute et l'inondation), que
    -- l'adresse corresponde ou non à un compte
    LET $now = time::now();
    LET $issued = (SELECT VALUE created_at FROM auth_code_issuance WHERE address = $address AND purpose = $p.purpose AND created_at > $now - 1d);
    IF array::len($issued) >= 10 OR array::len(array::filter($issued, |$t| $t > $now - 1h)) >= 3 OR array::any($issued, |$t| $t > $now - 1m) {
        RETURN fn::error_result("AUTH_TOO_MANY_ATTEMPTS", $p.language, { reason: "code_issuance" });
    };
    CREATE auth_code_issuance CONTENT { address: $address, purpose: $p.purpose };
    -- Un seul code actif par (parcours, usage) : les précédents sont invalidés
    UPDATE auth_one_time_code SET consumed_at = time::now() WHERE flow = $p.flow AND purpose = $p.purpose AND consumed_at IS NONE;
    LET $ttl = fn::auth_policy_value({ theme: "code", key: "ttl_seconds", default: 900, organization: $organization });
    LET $max = fn::auth_policy_value({ theme: "code", key: "max_attempts", default: 5, organization: $organization });
    LET $code = (CREATE ONLY type::record("auth_one_time_code", string::replace(<string> rand::uuid::v7(), "-", "")) CONTENT {
        flow: $p.flow,
        purpose: $p.purpose,
        address: $address,
        code_hash: IF $p.code_hash IS NONE { NONE } ELSE { $p.code_hash },
        link_hash: $p.link_hash,
        max_attempts: $max,
        expires_at: time::now() + duration::from_secs($ttl),
        delivery: IF $p.event_id IS NONE { NONE } ELSE { { event_id: <string> $p.event_id, secret: $p.secret, locale: $p.locale, name: $p.name } }
    });
    IF $code == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_one_time_code" }); };
    RETURN fn::result_ok({ code: $code.id, expires_at: $code.expires_at });
} COMMENT "Émet un code et un lien à usage unique ({ flow, purpose, address, code_hash, link_hash, event_id, secret enc:v2, locale, name }) ; message publié avec le secret scellé (jamais conservé), sans message si event_id et secret sont absents (code factice) ; précédent code invalidé ; au plus 1 code par minute, 3 par heure et 10 par jour pour une adresse et un usage (AUTH_TOO_MANY_ATTEMPTS). Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_code_verify
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_code_verify($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            flow: { pipeline: [{ rule: "record", options: { expected_table: "auth_flow" } }] },
            purpose: { pipeline: [{ rule: "enum", options: { allowed: ["verification", "recovery", "address_change", "setup"], case_sensitive: true } }], required: true },
            code_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }] },
            link_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    -- Un code se présente avec son parcours ; un lien se suffit à lui-même
    IF !$report.valid OR ($report.value.link_hash IS NONE AND ($report.value.code_hash IS NONE OR $report.value.flow IS NONE)) {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, { fields: { code_hash: { pipeline: [{ rule: "lowercase" }] }, link_hash: { pipeline: [{ rule: "lowercase" }] } }, unknown_keys: "keep" }, 20);
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $now = time::now();
    LET $code = IF $p.link_hash IS NOT NONE {
        (SELECT * FROM ONLY auth_one_time_code WHERE link_hash = $p.link_hash AND purpose = $p.purpose LIMIT 1)
    } ELSE {
        (SELECT * FROM ONLY auth_one_time_code WHERE flow = $p.flow AND purpose = $p.purpose AND consumed_at IS NONE ORDER BY created_at DESC LIMIT 1)
    };
    IF $code == NONE OR $code.consumed_at IS NOT NONE { RETURN fn::error_result("AUTH_CODE_INVALID", $p.language, {}); };
    IF $code.expires_at <= $now { RETURN fn::error_result("AUTH_CODE_EXPIRED", $p.language, {}); };
    IF $code.attempts >= $code.max_attempts { RETURN fn::error_result("AUTH_TOO_MANY_ATTEMPTS", $p.language, {}); };
    IF $p.link_hash IS NONE {
        -- Essai compté avant la comparaison, par une écriture conditionnelle : des essais
        -- simultanés ne dépassent pas le plafond
        LET $counted = (UPDATE ONLY $code.id SET attempts += 1 WHERE attempts < max_attempts AND consumed_at IS NONE);
        IF $counted == NONE { RETURN fn::error_result("AUTH_TOO_MANY_ATTEMPTS", $p.language, {}); };
        IF $code.code_hash != $p.code_hash {
            RETURN fn::error_result("AUTH_CODE_INVALID", $p.language, { attempts_left: $counted.max_attempts - $counted.attempts });
        };
    };
    -- Consommation conditionnelle : un code présenté deux fois en même temps ne sert qu'une fois
    LET $consumed = (UPDATE ONLY $code.id SET consumed_at = $now WHERE consumed_at IS NONE);
    IF $consumed == NONE { RETURN fn::error_result("AUTH_CODE_INVALID", $p.language, {}); };
    LET $flow = (SELECT * FROM ONLY $code.flow);
    IF $flow == NONE OR $flow.expires_at <= $now OR $flow.state IN ["completed", "failed"] { RETURN fn::error_result("AUTH_FLOW_EXPIRED", $p.language, {}); };
    RETURN fn::result_ok({ flow: $flow.id, type: $flow.type, identity: $flow.identity, address: $code.address, purpose: $code.purpose });
} COMMENT "Vérifie un code ({ flow, code_hash }) ou un lien ({ link_hash }) à usage unique ({ purpose }) : expiration, tentatives (chaque code présenté compté avant comparaison), consommation unique. Session système";
