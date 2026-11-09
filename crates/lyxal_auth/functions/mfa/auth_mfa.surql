-- ============================================================================
-- FONCTIONS : seconds facteurs (TOTP, passkeys, codes de secours)
-- MODULE    : lyxal_auth
-- ============================================================================
-- Modèle : Kratos (`totp`, `webauthn`/`passkey`, `lookup_secret`), Logto (anti-rejeu TOTP par
-- pas, codes de secours), Keycloak (remise à zéro par un administrateur). Écritures par la
-- session système de l'hôte, qui désigne l'acteur : la session de l'utilisateur (actions
-- sensibles : AAL la plus haute disponible et authentification récente) ou son parcours de
-- connexion en attente de configure_mfa. Le secret TOTP est scellé en Rust ; la base ne reçoit
-- que des résultats de vérification et des empreintes.

-- ----------------------------------------------------------------------------
-- fn::auth_mfa_actor : identité au nom de laquelle agit l'hôte (interne)
-- ----------------------------------------------------------------------------
-- { session, flow, sensitive } → { code, details, identity, session, flow, organization }

DEFINE FUNCTION OVERWRITE fn::auth_mfa_actor($params: object) -> object {
    LET $now = time::now();
    IF $params.session IS NOT NONE {
        LET $s = (SELECT identity, organization, kind, state, expires_at, idle_expires_at FROM ONLY $params.session);
        IF $s == NONE OR $s.state != "active" OR $s.kind != "interactive" OR $s.identity IS NONE OR $s.expires_at <= $now OR $s.idle_expires_at <= $now {
            RETURN { code: "AUTH_SESSION_REQUIRED", details: {} };
        };
        IF $params.sensitive ?? false {
            LET $state = fn::auth_assurance_state({ session: $params.session, min_aal: "highest_available", fresh: true });
            IF $state.code IS NOT NONE { RETURN { code: $state.code, details: $state.details }; };
        };
        RETURN { code: NONE, details: {}, identity: $s.identity, session: $params.session, flow: NONE, organization: $s.organization };
    };
    IF $params.flow IS NOT NONE {
        LET $loaded = fn::auth_flow_load({ flow: $params.flow, type: "login", states: ["action_required"] });
        IF $loaded.code IS NOT NONE { RETURN { code: $loaded.code, details: {} }; };
        LET $f = $loaded.flow;
        LET $available = (SELECT VALUE available_aal FROM ONLY $f.identity) ?? 0;
        LET $requested = "configure_mfa" IN (SELECT VALUE action FROM auth_required_action WHERE identity = $f.identity)
            OR fn::auth_mfa_required({ identity: $f.identity, organization: $f.organization });
        -- Enrôlement depuis la connexion : seulement pour configurer le double facteur exigé, ou
        -- pour compléter un facteur enrôlé dans ce même parcours (codes de secours)
        LET $enrolled_here = array::len(array::filter($f.methods, |$m| $m IN ["totp", "passkey"])) > 0;
        IF !(($requested AND $available < 2) OR $enrolled_here) { RETURN { code: "AUTH_FLOW_INVALID_STATE", details: {} }; };
        RETURN { code: NONE, details: {}, identity: $f.identity, session: NONE, flow: $f.id, organization: $f.organization };
    };
    RETURN { code: "AUTH_SESSION_REQUIRED", details: {} };
} COMMENT "Acteur d'une opération sur les seconds facteurs ({ session, flow, sensitive }) : session interactive (actions sensibles : AAL la plus haute disponible et authentification récente) ou parcours de connexion en attente de configure_mfa ; { code, details, identity, session, flow, organization }";

-- ----------------------------------------------------------------------------
-- fn::auth_mfa_publish : événement d'alerte de sécurité (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_mfa_publish($params: object) -> bool {
    LET $identity = (SELECT traits FROM ONLY $params.identity);
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: $params.event_type,
        producer: "lyxal_auth",
        source: $params.identity,
        payload: object::extend($params.data ?? {}, {
            identity_id: <string> $params.identity,
            recipient_email: $identity.traits.email,
            recipient_locale: $identity.traits.locale,
            recipient_name: $identity.traits.name.first,
            at: time::now()
        }),
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
    RETURN true;
} COMMENT "Publie un événement d'alerte de sécurité ({ event_type, identity, data }) avec le destinataire (recipient_email, recipient_locale, recipient_name) ; annule la mutation si la publication échoue";

-- ----------------------------------------------------------------------------
-- fn::auth_mfa_enrolled : effets d'un premier facteur actif (interne)
-- ----------------------------------------------------------------------------
-- Action configure_mfa levée ; une session actrice monte en AAL2 (possession prouvée) ; un
-- parcours acteur retient la méthode pour ouvrir la session en AAL2.

DEFINE FUNCTION OVERWRITE fn::auth_mfa_enrolled($params: object) -> bool {
    DELETE auth_required_action WHERE identity = $params.actor.identity AND action = "configure_mfa";
    IF $params.actor.session IS NOT NONE {
        UPDATE $params.actor.session SET aal = 2, authenticated_at = time::now(), amr += { method: $params.method, at: time::now() };
    };
    IF $params.actor.flow IS NOT NONE {
        UPDATE $params.actor.flow SET methods = array::distinct(array::concat(methods, [$params.method]));
    };
    RETURN fn::auth_mfa_publish({ event_type: "auth.mfa.enrolled", identity: $params.actor.identity, data: { method: $params.method, label: $params.label } });
} COMMENT "Effets de l'enrôlement d'un second facteur ({ actor, method, label }) : configure_mfa levée, session actrice en AAL2, méthode retenue par le parcours acteur, événement auth.mfa.enrolled";

-- ----------------------------------------------------------------------------
-- fn::auth_mfa_factor_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_mfa_factor_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            session: { pipeline: [{ rule: "record", options: { expected_table: "auth_session" } }] },
            flow: { pipeline: [{ rule: "record", options: { expected_table: "auth_flow" } }] },
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
    LET $identity = IF $check.system {
        IF $p.session IS NOT NONE OR $p.flow IS NOT NONE {
            LET $actor = fn::auth_mfa_actor({ session: $p.session, flow: $p.flow, sensitive: false });
            IF $actor.code IS NOT NONE { RETURN fn::error_result($actor.code, $p.language, $actor.details); };
            $actor.identity
        } ELSE { $p.identity }
    } ELSE IF $p.identity IS NOT NONE AND $p.identity != (SELECT VALUE identity FROM ONLY $auth) {
        IF !fn::auth_has_permission({ permission: "auth.identity.read" }) { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.identity.read" }); };
        $p.identity
    } ELSE { (SELECT VALUE identity FROM ONLY $auth) };
    IF $identity IS NONE { RETURN fn::error_result("AUTH_INVALID_PARAMETERS", $p.language, { fields: { identity: ["CORE_VALIDATION_REQUIRED"] } }); };
    LET $totp = (SELECT id, state, created_at, last_used_at FROM ONLY auth_credential WHERE identity = $identity AND type = "totp" LIMIT 1);
    LET $passkeys = (SELECT id, label, created_at, last_used_at, public_data.backup_eligible AS backup_eligible, public_data.backup_state AS backup_state
        FROM auth_credential WHERE identity = $identity AND type = "passkey" ORDER BY created_at);
    LET $codes = (SELECT used_at, created_at FROM auth_recovery_code WHERE identity = $identity);
    RETURN fn::result_ok({
        totp: $totp,
        passkeys: $passkeys,
        recovery_codes: IF array::len($codes) = 0 { NONE } ELSE {
            { total: array::len($codes), remaining: array::len(array::filter($codes, |$c| $c.used_at IS NONE)), created_at: array::min($codes.created_at) }
        },
        available_aal: (SELECT VALUE available_aal FROM ONLY $identity) ?? 0
    });
} COMMENT "Seconds facteurs d'une identité, sans secret ({ session | flow (session système) ; identity : la sienne, ou auth.identity.read }) : { totp, passkeys, recovery_codes { total, remaining }, available_aal }";

-- ----------------------------------------------------------------------------
-- fn::auth_mfa_totp_begin / _secret_get / _activate / _step_use
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_mfa_totp_begin($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            session: { pipeline: [{ rule: "record", options: { expected_table: "auth_session" } }] },
            flow: { pipeline: [{ rule: "record", options: { expected_table: "auth_flow" } }] },
            credential: { pipeline: [{ rule: "record", options: { expected_table: "auth_credential" } }], required: true },
            secret: { pipeline: [{ rule: "required_string", options: { min_length: 16, max_length: 8192 } }, { rule: "starts_with", options: { prefixes: ["enc:v2:"], case_sensitive: true, trim_value: false } }], required: true },
            algorithm: { pipeline: [{ rule: "enum", options: { allowed: ["SHA1", "SHA256"], case_sensitive: true } }], default: "SHA1" },
            digits: { pipeline: [{ rule: "integer", options: { min_value: 6, max_value: 8 } }], default: 6 },
            step_seconds: { pipeline: [{ rule: "integer", options: { min_value: 15, max_value: 120 } }], default: 30 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $actor = fn::auth_mfa_actor({ session: $p.session, flow: $p.flow, sensitive: true });
    IF $actor.code IS NOT NONE { RETURN fn::error_result($actor.code, $p.language, $actor.details); };
    IF "totp" NOT IN fn::auth_policy_value({ theme: "mfa", key: "methods", default: ["totp", "passkey", "recovery_code"], organization: $actor.organization }) {
        RETURN fn::error_result("AUTH_MFA_METHOD_DISABLED", $p.language, { method: "totp" });
    };
    LET $existing = (SELECT id, state FROM ONLY auth_credential WHERE identity = $actor.identity AND type = "totp" LIMIT 1);
    IF $existing != NONE AND $existing.state = "active" { RETURN fn::error_result("AUTH_MFA_ALREADY_ENROLLED", $p.language, { method: "totp" }); };
    -- Un enrôlement non confirmé est remplacé
    IF $existing != NONE { DELETE $existing.id; };
    LET $created = (CREATE ONLY $p.credential CONTENT {
        identity: $actor.identity, type: "totp", state: "pending", secret_data: $p.secret,
        public_data: { algorithm: $p.algorithm, digits: $p.digits, step_seconds: $p.step_seconds, last_step: NONE }
    });
    IF $created == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_credential" }); };
    RETURN fn::result_ok({ credential: $created.id, identity: $actor.identity, account: (SELECT VALUE traits.email FROM ONLY $actor.identity) });
} COMMENT "Enregistre un TOTP en attente de confirmation ({ session | flow, credential : identifiant choisi par l'hôte, secret enc:v2 scellé sur cet identifiant, algorithm, digits, step_seconds }) : action sensible, un TOTP actif refusé, un enrôlement non confirmé remplacé. Session système";

DEFINE FUNCTION OVERWRITE fn::auth_mfa_totp_secret_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }], required: true },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["pending", "active"], case_sensitive: true } }], default: "active" },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $credential = (SELECT id, secret_data, public_data, created_at FROM ONLY auth_credential WHERE identity = $p.identity AND type = "totp" AND state = $p.state LIMIT 1);
    IF $credential == NONE { RETURN fn::error_result("AUTH_MFA_NOT_ENROLLED", $p.language, { method: "totp" }); };
    -- Un enrôlement non confirmé expire avec la durée d'un parcours
    IF $p.state = "pending" AND $credential.created_at + duration::from_secs(fn::auth_policy_value({ theme: "flow", key: "ttl_seconds", default: 900 })) <= time::now() {
        RETURN fn::error_result("AUTH_MFA_NOT_ENROLLED", $p.language, { method: "totp" });
    };
    RETURN fn::result_ok({ credential: $credential.id, secret: $credential.secret_data, public_data: $credential.public_data });
} COMMENT "Secret TOTP scellé d'une identité ({ identity, state : active | pending }) pour vérification par l'hôte ; enrôlement non confirmé expiré refusé. Session système";

DEFINE FUNCTION OVERWRITE fn::auth_mfa_totp_activate($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            session: { pipeline: [{ rule: "record", options: { expected_table: "auth_session" } }] },
            flow: { pipeline: [{ rule: "record", options: { expected_table: "auth_flow" } }] },
            credential: { pipeline: [{ rule: "record", options: { expected_table: "auth_credential" } }], required: true },
            step: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $actor = fn::auth_mfa_actor({ session: $p.session, flow: $p.flow, sensitive: true });
    IF $actor.code IS NOT NONE { RETURN fn::error_result($actor.code, $p.language, $actor.details); };
    LET $activated = (UPDATE ONLY $p.credential SET state = "active", public_data.last_step = $p.step, last_used_at = time::now()
        WHERE identity = $actor.identity AND type = "totp" AND state = "pending");
    IF $activated == NONE { RETURN fn::error_result("AUTH_MFA_NOT_ENROLLED", $p.language, { method: "totp" }); };
    fn::auth_mfa_enrolled({ actor: $actor, method: "totp", label: NONE });
    RETURN fn::result_ok({ credential: $activated.id, identity: $actor.identity, recovery_codes: array::len(SELECT VALUE id FROM auth_recovery_code WHERE identity = $actor.identity AND used_at IS NONE) });
} COMMENT "Active le TOTP en attente après un premier code vérifié par l'hôte ({ session | flow, credential, step : pas accepté }) : action sensible, configure_mfa levée, événement auth.mfa.enrolled. Session système";

DEFINE FUNCTION OVERWRITE fn::auth_mfa_totp_step_use($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            credential: { pipeline: [{ rule: "record", options: { expected_table: "auth_credential" } }], required: true },
            step: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    -- Anti-rejeu : un pas déjà utilisé (ou antérieur) est refusé, même si le code était juste
    LET $used = (UPDATE ONLY $p.credential SET public_data.last_step = $p.step, last_used_at = time::now()
        WHERE type = "totp" AND state = "active" AND (public_data.last_step IS NONE OR public_data.last_step < $p.step));
    IF $used == NONE { RETURN fn::error_result("AUTH_MFA_INVALID", $p.language, {}); };
    RETURN fn::result_ok({ credential: $used.id, identity: $used.identity });
} COMMENT "Consomme un pas TOTP vérifié par l'hôte ({ credential, step }) : un pas déjà utilisé ou antérieur est refusé (anti-rejeu). Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_mfa_passkey_save / _find / _list_for / _update / _rename
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_mfa_passkey_save($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            session: { pipeline: [{ rule: "record", options: { expected_table: "auth_session" } }] },
            flow: { pipeline: [{ rule: "record", options: { expected_table: "auth_flow" } }] },
            credential_id: { pipeline: [{ rule: "required_string", options: { min_length: 16, max_length: 1366 } }], required: true },
            label: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], default: "Passkey" },
            public_data: { pipeline: [{ rule: "is_object" }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $actor = fn::auth_mfa_actor({ session: $p.session, flow: $p.flow, sensitive: true });
    IF $actor.code IS NOT NONE { RETURN fn::error_result($actor.code, $p.language, $actor.details); };
    IF "passkey" NOT IN fn::auth_policy_value({ theme: "mfa", key: "methods", default: ["totp", "passkey", "recovery_code"], organization: $actor.organization }) {
        RETURN fn::error_result("AUTH_MFA_METHOD_DISABLED", $p.language, { method: "passkey" });
    };
    -- Une même clé ne peut appartenir qu'à une identité (l'index unique le garantit aussi)
    IF (SELECT VALUE id FROM ONLY auth_credential WHERE credential_id = $p.credential_id LIMIT 1) IS NOT NONE {
        RETURN fn::error_result("AUTH_PASSKEY_TAKEN", $p.language, {});
    };
    LET $created = (CREATE ONLY type::record("auth_credential", string::replace(<string> rand::uuid::v7(), "-", "")) CONTENT {
        identity: $actor.identity, type: "passkey", state: "active", label: $p.label, credential_id: $p.credential_id, public_data: $p.public_data
    });
    IF $created == NONE { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_credential" }); };
    fn::auth_mfa_enrolled({ actor: $actor, method: "passkey", label: $p.label });
    RETURN fn::result_ok({ credential: $created.id, identity: $actor.identity, label: $created.label });
} COMMENT "Enregistre une passkey vérifiée par l'hôte ({ session | flow, credential_id, label, public_data : clé sérialisée par webauthn-rs }) : action sensible, clé déjà enregistrée refusée, configure_mfa levée, événement auth.mfa.enrolled. Session système";

DEFINE FUNCTION OVERWRITE fn::auth_mfa_passkey_find($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            credential_id: { pipeline: [{ rule: "required_string", options: { min_length: 16, max_length: 1366 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $credential = (SELECT id, identity, public_data FROM ONLY auth_credential WHERE credential_id = $p.credential_id AND type = "passkey" AND state = "active" LIMIT 1);
    IF $credential == NONE { RETURN fn::error_result("AUTH_PASSKEY_INVALID", $p.language, {}); };
    RETURN fn::result_ok({ credential: $credential.id, identity: $credential.identity, public_data: $credential.public_data, identity_state: (SELECT VALUE state FROM ONLY $credential.identity) });
} COMMENT "Passkey active désignée par son identifiant WebAuthn ({ credential_id }) : identité, état de l'identité, clé sérialisée (connexion sans mot de passe). Session système";

DEFINE FUNCTION OVERWRITE fn::auth_mfa_passkey_list_for($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    RETURN fn::result_ok(SELECT id AS credential, credential_id, public_data FROM auth_credential WHERE identity = $p.identity AND type = "passkey" AND state = "active" ORDER BY created_at);
} COMMENT "Passkeys actives d'une identité ({ identity }) avec leurs clés sérialisées, pour un défi de second facteur ou l'exclusion à l'enrôlement. Session système";

DEFINE FUNCTION OVERWRITE fn::auth_mfa_passkey_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            credential: { pipeline: [{ rule: "record", options: { expected_table: "auth_credential" } }], required: true },
            public_data: { pipeline: [{ rule: "is_object" }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $updated = (UPDATE ONLY $p.credential SET public_data = $p.public_data, last_used_at = time::now() WHERE type = "passkey" AND state = "active");
    IF $updated == NONE { RETURN fn::error_result("AUTH_PASSKEY_INVALID", $p.language, {}); };
    RETURN fn::result_ok({ credential: $updated.id, identity: $updated.identity });
} COMMENT "Met à jour une passkey après une authentification vérifiée par l'hôte ({ credential, public_data : compteur et indicateurs de sauvegarde }). Session système";

DEFINE FUNCTION OVERWRITE fn::auth_mfa_passkey_rename($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            session: { pipeline: [{ rule: "record", options: { expected_table: "auth_session" } }], required: true },
            credential: { pipeline: [{ rule: "record", options: { expected_table: "auth_credential" } }], required: true },
            label: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $actor = fn::auth_mfa_actor({ session: $p.session, sensitive: false });
    IF $actor.code IS NOT NONE { RETURN fn::error_result($actor.code, $p.language, $actor.details); };
    LET $updated = (UPDATE ONLY $p.credential SET label = $p.label WHERE identity = $actor.identity AND type = "passkey");
    IF $updated == NONE { RETURN fn::error_result("AUTH_PASSKEY_INVALID", $p.language, {}); };
    RETURN fn::result_ok({ credential: $updated.id, label: $updated.label });
} COMMENT "Renomme une de ses passkeys ({ session, credential, label }). Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_mfa_recovery_codes_replace / fn::auth_mfa_recovery_code_use
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_mfa_recovery_codes_replace($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            session: { pipeline: [{ rule: "record", options: { expected_table: "auth_session" } }] },
            flow: { pipeline: [{ rule: "record", options: { expected_table: "auth_flow" } }] },
            batch: { pipeline: [{ rule: "hexadecimal", options: { min_length: 32, max_length: 32, allow_prefix: false } }], required: true },
            code_hashes: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: false } }, { rule: "each", options: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }] } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid OR array::len($report.value.code_hashes) < 5 OR array::len($report.value.code_hashes) > 20
        OR array::len(array::distinct($report.value.code_hashes)) != array::len($report.value.code_hashes) {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $actor = fn::auth_mfa_actor({ session: $p.session, flow: $p.flow, sensitive: true });
    IF $actor.code IS NOT NONE { RETURN fn::error_result($actor.code, $p.language, $actor.details); };
    IF "recovery_code" NOT IN fn::auth_policy_value({ theme: "mfa", key: "methods", default: ["totp", "passkey", "recovery_code"], organization: $actor.organization }) {
        RETURN fn::error_result("AUTH_MFA_METHOD_DISABLED", $p.language, { method: "recovery_code" });
    };
    -- Les codes de secours complètent un second facteur ; ils ne le remplacent pas
    IF ((SELECT VALUE available_aal FROM ONLY $actor.identity) ?? 0) < 2 { RETURN fn::error_result("AUTH_MFA_NOT_ENROLLED", $p.language, { method: "recovery_code" }); };
    DELETE auth_recovery_code WHERE identity = $actor.identity;
    LET $created = (INSERT INTO auth_recovery_code array::map($p.code_hashes, |$h| { identity: $actor.identity, batch: string::lowercase($p.batch), code_hash: string::lowercase($h) }) RETURN id);
    IF array::len($created) != array::len($p.code_hashes) { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_recovery_code" }); };
    fn::auth_mfa_publish({ event_type: "auth.mfa.recovery_codes_generated", identity: $actor.identity, data: { count: array::len($created) } });
    RETURN fn::result_ok({ identity: $actor.identity, count: array::len($created) });
} COMMENT "Remplace tous les codes de secours d'une identité ({ session | flow, batch, code_hashes : empreintes HMAC, 5 à 20, distinctes }) : action sensible, second facteur actif exigé, événement auth.mfa.recovery_codes_generated. Session système";

DEFINE FUNCTION OVERWRITE fn::auth_mfa_recovery_code_use($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }], required: true },
            code_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    -- Consommation atomique : deux présentations simultanées du même code n'en valident qu'une
    LET $used = (UPDATE auth_recovery_code SET used_at = time::now()
        WHERE identity = $p.identity AND code_hash = string::lowercase($p.code_hash) AND used_at IS NONE RETURN id);
    IF array::len($used) = 0 { RETURN fn::error_result("AUTH_MFA_INVALID", $p.language, {}); };
    LET $remaining = array::len(SELECT VALUE id FROM auth_recovery_code WHERE identity = $p.identity AND used_at IS NONE);
    fn::auth_mfa_publish({ event_type: "auth.mfa.recovery_code_used", identity: $p.identity, data: { remaining: $remaining, low: $remaining <= 2 } });
    RETURN fn::result_ok({ identity: $p.identity, remaining: $remaining });
} COMMENT "Consomme un code de secours vérifié par son empreinte ({ identity, code_hash }) : usage unique atomique, événement auth.mfa.recovery_code_used (codes restants). Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_mfa_factor_remove : retrait d'un de ses facteurs (action sensible)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_mfa_factor_remove($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            session: { pipeline: [{ rule: "record", options: { expected_table: "auth_session" } }], required: true },
            credential: { pipeline: [{ rule: "record", options: { expected_table: "auth_credential" } }] },
            method: { pipeline: [{ rule: "enum", options: { allowed: ["totp", "passkey"], case_sensitive: true } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid OR ($report.value.method = "passkey" AND $report.value.credential IS NONE) {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $actor = fn::auth_mfa_actor({ session: $p.session, sensitive: true });
    IF $actor.code IS NOT NONE { RETURN fn::error_result($actor.code, $p.language, $actor.details); };
    LET $target = IF $p.method = "totp" {
        (SELECT id, label FROM ONLY auth_credential WHERE identity = $actor.identity AND type = "totp" LIMIT 1)
    } ELSE {
        (SELECT id, label FROM ONLY auth_credential WHERE id = $p.credential AND identity = $actor.identity AND type = "passkey" LIMIT 1)
    };
    IF $target == NONE { RETURN fn::error_result("AUTH_MFA_NOT_ENROLLED", $p.language, { method: $p.method }); };
    LET $others = (SELECT VALUE id FROM auth_credential WHERE identity = $actor.identity AND type IN ["totp", "passkey"] AND state = "active" AND id != $target.id);
    -- Double facteur exigé : le dernier facteur ne peut pas être retiré par son titulaire
    IF array::len($others) = 0 AND fn::auth_mfa_required({ identity: $actor.identity, organization: $actor.organization }) {
        RETURN fn::error_result("AUTH_MFA_LAST_FACTOR", $p.language, {});
    };
    LET $deleted = (DELETE $target.id RETURN BEFORE);
    IF array::len($deleted) = 0 { RETURN fn::error_result("AUTH_WRITE_FORBIDDEN", $p.language, { table: "auth_credential" }); };
    -- Sans second facteur, les codes de secours n'ont plus d'usage
    IF array::len($others) = 0 { DELETE auth_recovery_code WHERE identity = $actor.identity; };
    fn::auth_mfa_publish({ event_type: "auth.mfa.removed", identity: $actor.identity, data: { method: $p.method, label: $target.label, reason: "owner" } });
    RETURN fn::result_ok({ removed: $target.id, available_aal: (SELECT VALUE available_aal FROM ONLY $actor.identity) });
} COMMENT "Retire un de ses seconds facteurs ({ session, method : totp | passkey, credential pour une passkey }) : action sensible ; dernier facteur refusé si le double facteur est exigé (AUTH_MFA_LAST_FACTOR) ; codes de secours supprimés avec le dernier facteur ; événement auth.mfa.removed. Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_mfa_reset : remise à zéro par un administrateur (appareil perdu)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_mfa_reset($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            session: { pipeline: [{ rule: "record", options: { expected_table: "auth_session" } }], required: true },
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $actor = fn::auth_mfa_actor({ session: $p.session, sensitive: true });
    IF $actor.code IS NOT NONE { RETURN fn::error_result($actor.code, $p.language, $actor.details); };
    IF $actor.identity = $p.identity { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    IF !record::exists($p.identity) { RETURN fn::error_result("AUTH_IDENTITY_NOT_FOUND", $p.language, {}); };
    -- Droits de l'administrateur relus en base : auth.identity.manage, ou auth.member.manage dans
    -- son organisation active dont l'identité est membre
    LET $rights = fn::auth_subject_permissions({ identity: $actor.identity, organization: $actor.organization });
    IF $rights.code IS NOT NONE { RETURN fn::error_result($rights.code, $p.language, {}); };
    LET $allowed = "auth.identity.manage" IN $rights.permissions
        OR ($actor.organization IS NOT NONE AND "auth.member.manage" IN $rights.permissions
            AND (SELECT VALUE id FROM ONLY auth_member_of WHERE in = $p.identity AND out = $actor.organization LIMIT 1) IS NOT NONE);
    IF !$allowed { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, { permission: "auth.identity.manage" }); };
    LET $removed = (DELETE auth_credential WHERE identity = $p.identity AND type IN ["totp", "passkey"] RETURN BEFORE);
    DELETE auth_recovery_code WHERE identity = $p.identity;
    -- Toutes les sessions de l'identité sont révoquées ; le double facteur sera reconfiguré
    LET $revoked = (UPDATE auth_session SET state = "revoked", revoked_at = time::now(), revoked_reason = "mfa_reset" WHERE identity = $p.identity AND state = "active" RETURN id);
    UPDATE auth_refresh_token SET state = "revoked" WHERE session IN $revoked AND state = "active";
    IF fn::auth_mfa_required({ identity: $p.identity, organization: NONE }) OR ($actor.organization IS NOT NONE AND fn::auth_mfa_required({ identity: $p.identity, organization: $actor.organization })) {
        IF (SELECT VALUE id FROM ONLY auth_required_action WHERE identity = $p.identity AND action = "configure_mfa" LIMIT 1) IS NONE {
            CREATE auth_required_action CONTENT { identity: $p.identity, action: "configure_mfa", reason: "mfa_reset" };
        };
    };
    fn::auth_mfa_publish({ event_type: "auth.mfa.removed", identity: $p.identity, data: { method: "all", label: NONE, reason: "admin_reset", removed: array::len($removed) } });
    RETURN fn::result_ok({ identity: $p.identity, removed: array::len($removed), sessions_revoked: array::len($revoked) });
} COMMENT "Remise à zéro des seconds facteurs d'une identité par un administrateur ({ session de l'administrateur, identity }) : action sensible ; auth.identity.manage, ou auth.member.manage dans l'organisation active dont l'identité est membre ; facteurs et codes supprimés, sessions révoquées, configure_mfa posée si le double facteur est exigé ; événement auth.mfa.removed. Session système";

-- ----------------------------------------------------------------------------
-- fn::auth_mfa_passkey_flag : clé possiblement clonée (compteur qui recule)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::auth_mfa_passkey_flag($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            credential_id: { pipeline: [{ rule: "required_string", options: { min_length: 16, max_length: 1366 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("AUTH_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("AUTH_PERMISSION_DENIED", $p.language, {}); };
    LET $credential = (SELECT id, identity, label FROM ONLY auth_credential WHERE credential_id = $p.credential_id AND type = "passkey" LIMIT 1);
    IF $credential == NONE { RETURN fn::error_result("AUTH_PASSKEY_INVALID", $p.language, {}); };
    fn::auth_mfa_publish({ event_type: "auth.passkey.clone_detected", identity: $credential.identity, data: { credential_id: <string> $credential.id, label: $credential.label } });
    RETURN fn::result_ok({ credential: $credential.id, identity: $credential.identity });
} COMMENT "Signale une passkey possiblement clonée (compteur de signature qui recule, refus par l'hôte) ({ credential_id }) : événement auth.passkey.clone_detected avec le destinataire. Session système";
