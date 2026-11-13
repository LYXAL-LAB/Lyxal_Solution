-- ============================================================================
-- FONCTIONS : lecture d'une valeur (ticket à usage unique)
-- MODULE    : lyxal_secrets
-- ============================================================================
-- 1. fn::secrets_read_begin, avec les droits du demandeur : contrôles, puis ticket créé ; la
--    création du ticket écrit l'entrée « read » du journal dans la même transaction.
-- 2. fn::secrets_read_envelope, session système seulement (service Rust) : le ticket, valable
--    60 secondes, est échangé une seule fois contre l'enveloppe et son contexte de scellement.
-- Sans trace au journal, aucune enveloppe n'est remise.

-- ----------------------------------------------------------------------------
-- fn::secrets_read_refusal (interne, garde du ticket)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_read_refusal($ticket: object) -> option<object> {
    LET $caller = fn::secrets_caller();
    IF !$caller.valid { RETURN { code: "SECRETS_PERMISSION_DENIED", details: {} }; };
    LET $secret = (SELECT * FROM ONLY $ticket.secret);
    IF $secret == NONE { RETURN { code: "SECRETS_SECRET_NOT_FOUND", details: {} }; };
    IF !fn::secrets_can({ action: "read_value", tenant: $secret.tenant }) { RETURN { code: "SECRETS_PERMISSION_DENIED", details: {} }; };
    IF $secret.state = "deleted" { RETURN { code: "SECRETS_SECRET_DELETED", details: {} }; };
    IF $secret.state = "disabled" { RETURN { code: "SECRETS_SECRET_DISABLED", details: {} }; };
    IF $secret.expires_at IS NOT NONE AND $secret.expires_at <= time::now() {
        RETURN { code: "SECRETS_SECRET_EXPIRED", details: { expires_at: $secret.expires_at } };
    };
    LET $version = (SELECT secret, number, state FROM ONLY $ticket.version);
    IF $version == NONE OR $version.secret != $secret.id OR $version.number != $ticket.number {
        RETURN { code: "SECRETS_VERSION_NOT_FOUND", details: { number: $ticket.number } };
    };
    IF $version.state != "enabled" { RETURN { code: "SECRETS_VERSION_STATE_INVALID", details: { state: $version.state } }; };
    LET $listed = array::len($secret.consumers) > 0;
    IF $caller.system {
        -- Module de l'hôte : il s'annonce ; s'il y a une liste, il doit y figurer
        RETURN IF $listed AND $ticket.consumer NOTINSIDE $secret.consumers { { code: "SECRETS_CONSUMER_NOT_ALLOWED", details: { consumer: $ticket.consumer } } } ELSE { NONE };
    };
    IF $caller.kind = "interactive" {
        -- Humain : secret révélable seulement, avec le niveau d'assurance le plus haut et récent
        IF $secret.visibility != "revealable" { RETURN { code: "SECRETS_REVEAL_FORBIDDEN", details: {} }; };
        LET $assurance = fn::auth_assurance_check({ min_aal: "highest_available", fresh: true });
        RETURN IF $assurance.ok { NONE } ELSE { { code: $assurance.error.code, details: $assurance.error.details ?? {} } };
    };
    -- Programme (compte de service, clé d'API) : identifiant de son application, seul consommateur qu'il peut annoncer
    IF $ticket.consumer IS NOT NONE AND $ticket.consumer != $caller.consumer {
        RETURN { code: "SECRETS_CONSUMER_NOT_ALLOWED", details: { consumer: $ticket.consumer } };
    };
    RETURN IF $listed AND ($caller.consumer IS NONE OR $caller.consumer NOTINSIDE $secret.consumers) {
        { code: "SECRETS_CONSUMER_NOT_ALLOWED", details: { consumer: $caller.consumer } }
    } ELSE { NONE };
} COMMENT "Interne : refus d'une lecture de valeur ($ticket : { secret, version, number, consumer }) : droit de lecture de valeur ; secret actif, non expiré ; version active ; session système : consommateur annoncé dans la liste s'il y en a une ; humain : secret revealable et assurance la plus haute et récente (fn::auth_assurance_check) ; programme : identifiant de son application (auth_application:…) dans la liste s'il y en a une. NONE ou { code, details }";

-- ----------------------------------------------------------------------------
-- fn::secrets_read_begin
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_read_begin($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            secret: { pipeline: [{ rule: "record", options: { expected_table: "secrets_secret" } }], required: true },
            label: { pipeline: [{ rule: "slug", options: { max_length: 32 } }] },
            number: { pipeline: [{ rule: "integer", options: { min_value: 1 } }] },
            consumer: { pipeline: [{ rule: "optional_string", options: { min_length: 1, max_length: 128 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $secret = (SELECT id, tenant, labels FROM ONLY $p.secret);
    IF $secret == NONE { RETURN fn::error_result("SECRETS_SECRET_NOT_FOUND", $p.language, { secret: <string> $p.secret }); };
    IF !fn::secrets_can({ action: "read_value", tenant: $secret.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    -- Version : numéro donné, sinon étiquette (current par défaut)
    LET $number = $p.number ?? $secret.labels[$p.label ?? "current"];
    LET $version = IF $number IS NONE { NONE } ELSE { (SELECT id, key_id FROM ONLY secrets_version WHERE secret = $secret.id AND number = $number LIMIT 1) };
    IF $version == NONE { RETURN fn::error_result("SECRETS_VERSION_NOT_FOUND", $p.language, { label: $p.label ?? "current", number: $number }); };
    LET $caller = fn::secrets_caller();
    LET $ticket = {
        secret: $secret.id,
        version: $version.id,
        tenant: $secret.tenant,
        number: $number,
        actor: $caller.identity,
        application: $caller.application,
        consumer: IF $caller.system { $p.consumer } ELSE { $p.consumer ?? $caller.consumer }
    };
    LET $refusal = fn::secrets_read_refusal($ticket);
    IF $refusal IS NOT NONE { RETURN fn::error_result($refusal.code, $p.language, $refusal.details); };
    LET $created = (CREATE ONLY secrets_read_ticket CONTENT $ticket);
    IF $created == NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_read_ticket" }); };
    RETURN fn::result_ok({
        ticket: $created.id,
        secret: $secret.id,
        number: $number,
        key_id: $version.key_id,
        expires_at: $created.expires_at
    });
} COMMENT "Ouvre la lecture d'une valeur ({ secret, label (current par défaut) ou number, consumer }) : contrôles (fn::secrets_read_refusal), puis ticket à usage unique valable 60 secondes, tracé au journal dans la même transaction. La valeur est remise par le service Rust (fn::secrets_read_envelope). Droit : lecture de valeur";

-- ----------------------------------------------------------------------------
-- fn::secrets_read_envelope
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_read_envelope($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            ticket: { pipeline: [{ rule: "record", options: { expected_table: "secrets_read_ticket" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $ticket = (SELECT * FROM ONLY $p.ticket);
    IF $ticket == NONE OR $ticket.used_at IS NOT NONE OR $ticket.expires_at <= time::now() {
        RETURN fn::error_result("SECRETS_READ_TICKET_INVALID", $p.language, {});
    };
    -- L'état a pu changer depuis le ticket (désactivation d'incident, destruction)
    LET $secret = (SELECT id, tenant, state, expires_at FROM ONLY $ticket.secret);
    LET $version = (SELECT number, state, envelope, key_id FROM ONLY $ticket.version);
    IF $secret == NONE OR $secret.state != "active" OR ($secret.expires_at IS NOT NONE AND $secret.expires_at <= time::now())
        OR $version == NONE OR $version.state != "enabled" OR $version.envelope IS NONE {
        RETURN fn::error_result("SECRETS_READ_TICKET_INVALID", $p.language, {});
    };
    LET $used = (UPDATE ONLY $ticket.id SET used_at = time::now() WHERE used_at IS NONE);
    IF $used == NONE { RETURN fn::error_result("SECRETS_READ_TICKET_INVALID", $p.language, {}); };
    RETURN fn::result_ok({
        envelope: $version.envelope,
        key_id: $version.key_id,
        number: $version.number,
        context: {
            tenant: IF $secret.tenant IS NONE { "lyxal_installation" } ELSE { <string> record::id($secret.tenant) },
            module: "lyxal_secrets",
            resource: "secrets_version",
            record_id: string::concat(<string> record::id($secret.id), ":", <string> $version.number),
            field: "value"
        }
    });
} COMMENT "Échange un ticket de lecture contre l'enveloppe ({ ticket }) : une seule fois, dans les 60 secondes, si le secret et la version sont encore lisibles ; renvoie { envelope, key_id, number, context } (contexte de scellement de lyxal_crypto). Session système seulement (service Rust)";
